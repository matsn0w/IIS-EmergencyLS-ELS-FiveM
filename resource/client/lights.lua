--- @param vehicle number The vehicle to toggle the extra on
--- @param extra number The extra to toggle
--- @param toggle boolean Whether to turn the extra on or off
local function ToggleVehicleExtra(vehicle, extra, toggle)
    local value = toggle and 0 or 1

    SetVehicleAutoRepairDisabled(vehicle, true)
    SetVehicleExtra(vehicle, extra, value)
end

--- @param vehicle number The vehicle to toggle the misc on
--- @param misc number The misc to toggle
--- @param toggle boolean Whether to turn the misc on or off
local function ToggleVehicleMisc(vehicle, misc, toggle)
    SetVehicleModKit(vehicle, 0)

    -- respect custom wheel setting
    local hasCustomWheelsEnabled = GetVehicleModVariation(vehicle, 23)

    SetVehicleMod(vehicle, misc, toggle, hasCustomWheelsEnabled)
end

local function CreateEnviromentLight(vehicle, light, offset, color)
    -- local boneIndex = GetEntityBoneIndexByName(vehicle, 'extra_' .. extra)
    local boneIndex = GetEntityBoneIndexByName(vehicle, light.type .. '_' .. tostring(light.name))
    local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    local position = coords + offset

    local rgb = { 0, 0, 0 }
    local range = Config.EnvironmentalLights.Range or 50.0
    local intensity = Config.EnvironmentalLights.Intensity or 1.0
    local shadow = 1.0

    if string.lower(color) == 'blue' then
        rgb = { 0, 0, 255 }
    elseif string.lower(color) == 'red' then
        rgb = { 255, 0, 0 }
    elseif string.lower(color) == 'green' then
        rgb = { 0, 255, 0 }
    elseif string.lower(color) == 'white' then
        rgb = { 255, 255, 255 }
    elseif string.lower(color) == 'amber' then
        rgb = { 255, 194, 0 }
    end

    -- draw the light
    DrawLightWithRangeAndShadow(
        position.x, position.y, position.z,
        rgb[1], rgb[2], rgb[3],
        range, intensity, shadow
    )
end

--- @param vehicle number The vehicle to handle the lights on
--- @param data table The VCF data for the vehicle
local function HandleEnvironmentLights(vehicle, data)
    for extra, info in pairs(data.extras) do
        if IsVehicleExtraTurnedOn(vehicle, extra) and info.env_light then
            local offset = vector3(info.env_pos.x, info.env_pos.y, info.env_pos.z)
            local light = {
                type = 'extra',
                name = extra
            }

            CreateEnviromentLight(vehicle, light, offset, info.env_color)
        end
    end

    for misc, info in pairs(data.miscs) do
        if IsVehicleMiscTurnedOn(vehicle, misc) and info.env_light then
            local offset = vector3(info.env_pos.x, info.env_pos.y, info.env_pos.z)
            local light = {
                type = 'misc',
                name = ConvertMiscIdToName(misc)
            }

            CreateEnviromentLight(vehicle, light, offset, info.env_color)
        end
    end
end

--- @param netVehicle number The network ID of the vehicle
--- @param stage string The light stage to set
--- @param toggle boolean Whether to turn the stage on or off
function SetLightStage(netVehicle, stage, toggle)
    local vehicle = NetToVeh(netVehicle)
    local ElsVehicle = ElsEnabledVehicles[netVehicle]
    local VCFdata = VcfData[GetVehicleModelName(vehicle)]

    -- get the pattern data
    local patternData = VCFdata.patterns[ConvertStageToPattern(stage)]

    -- reset all extras and miscs
    ResetVehicleExtras(vehicle)
    ResetVehicleMiscs(vehicle)

    -- set the light state
    ElsVehicle[stage] = toggle

    -- update the light stage on the server
    local stages = {}
    stages[stage] = toggle

    ElsEnabledVehicles[netVehicle].stages[stage] = toggle
    TriggerServerEvent('MISS-ELS:server:toggleLightStage', netVehicle, stages)

    if patternData.isEmergency then
        -- toggle the native siren ('emergency mode')
        SetVehicleSiren(vehicle, toggle)
    end

    if (patternData.flashHighBeam) then
        Citizen.CreateThread(function()
            -- get the current vehicle lights state
            local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)

            -- turn the lights on to avoid flashing tail lights
            if lightsOn == 0 then SetVehicleLights(vehicle, 2) end

            -- flash the high beam
            while ElsVehicle[stage] do
                if ElsVehicle.highBeamEnabled then
                    SetVehicleFullbeam(vehicle, true)
                    SetVehicleLightMultiplier(vehicle, Config.HighBeamIntensity or 5.0)

                    Wait(500)

                    SetVehicleFullbeam(vehicle, false)
                    SetVehicleLightMultiplier(vehicle, 1.0)

                    Wait(500)
                end

                Wait(0)
            end

            -- reset initial vehicle state
            if lightsOn == 0 then SetVehicleLights(vehicle, 0) end
            if highbeamsOn == 1 then SetVehicleFullbeam(vehicle, true) end

            Wait(0)
        end)
    end

    if patternData.enableWarningBeep then
        Citizen.CreateThread(function()
            while ElsVehicle[stage] do
                -- play warning sound
                SendNUIMessage({ transactionType = 'playSound', transactionFile = 'WarningBeep', transactionVolume = 0.2 })

                -- this should be equal to the length of the audio file
                Citizen.Wait((Config.WarningBeepDuration or 0) * 1000)
            end
        end)
    end

    Citizen.CreateThread(function()
        while ElsVehicle[stage] do
            -- keep the engine on whilst the lights are activated
            SetVehicleEngineOn(vehicle, true, true, false)

            local lastFlash = {
                extras = {},
                miscs = {},
            }

            for _, flash in ipairs(patternData) do
                if ElsVehicle[stage] then
                    for _, extra in ipairs(flash['extras']) do
                        -- disable auto repairs
                        SetVehicleAutoRepairDisabled(vehicle, true)

                        -- turn the extra on
                        ToggleVehicleExtra(vehicle, extra, true)

                        -- save the extra as last flashed
                        table.insert(lastFlash.extras, extra)
                    end

                    for _, misc in ipairs(flash['miscs']) do
                        -- turn the misc on
                        ToggleVehicleMisc(vehicle, misc, true)

                        -- save the misc as last flashed
                        table.insert(lastFlash.miscs, misc)
                    end

                    Citizen.Wait(flash.duration)
                end

                -- turn off the last flashed lights
                for _, v in ipairs(lastFlash.extras) do
                    -- disable auto repairs
                    SetVehicleAutoRepairDisabled(vehicle, true)

                    ToggleVehicleExtra(vehicle, v, false)
                end

                for _, v in ipairs(lastFlash.miscs) do
                    ToggleVehicleMisc(vehicle, v, false)
                end

                lastFlash.extras = {}
                lastFlash.miscs = {}
            end

            Citizen.Wait(0)
        end

        Wait(0)
    end)
end

--- @param model string The vehicle model to check
--- @param extra number The extra to check
local function StaticsIncludesExtra(model, extra)
    return VcfData[model].statics.extras[extra] ~= nil
end

--- @param model string The vehicle model to check
--- @param misc number The misc ID to check
local function StaticsIncludesMisc(model, misc)
    return VcfData[model].statics.miscs[misc] ~= nil
end

--- @param vehicle number The vehicle to reset the extras on
function ResetVehicleExtras(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not SetContains(VcfData, model) then
        Debug('warning', 'Model \'' .. model .. '\' is not in the VCF data')
        return
    end

    Debug('info', 'Resetting all enabled extras on vehicle')

    for extra, info in pairs(VcfData[model].extras) do
        if info.enabled == true and not StaticsIncludesExtra(model, extra) then
            -- disable auto repairs
            SetVehicleAutoRepairDisabled(vehicle, true)

            -- disable the extra
            ToggleVehicleExtra(vehicle, extra, false)
        end
    end
end

--- @param vehicle number The vehicle to reset the miscs on
function ResetVehicleMiscs(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not SetContains(VcfData, model) then
        Debug('warning', 'Model \'' .. model .. '\' is not in the VCF data')
        return
    end

    Debug('info', 'Resetting all enabled miscs on vehicle')

    for misc, info in pairs(VcfData[model].miscs) do
        if info.enabled == true and not StaticsIncludesMisc(model, misc) then
            ToggleVehicleMisc(vehicle, misc, false)
        end
    end
end

RegisterNetEvent('MISS-ELS:updateHorn')
AddEventHandler('MISS-ELS:updateHorn', function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(GetPlayerFromServerId(playerid)))

    if not vehicle then
        CancelEvent()
        return
    end

    if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local ElsVehicle = ElsEnabledVehicles[vehicle]

    -- toggle the horn state (true = on, false = off)
    ElsVehicle.horn = status

    -- get the sounds from the VCF
    local sounds = VcfData[GetVehicleModelName(vehicle)].sounds

    -- horn is honking
    if ElsVehicle.sound_id ~= nil then
        -- stop honking the horn
        StopSound(ElsVehicle.sound_id)
        ReleaseSoundId(ElsVehicle.sound_id)

        ElsVehicle.sound_id = nil
    end

    -- horn is set to 'on'
    if status then
        -- get a fresh sound id
        ElsVehicle.sound_id = GetSoundId()

        -- honk the horn
        PlaySoundFromEntity(
            ElsVehicle.sound_id,
            sounds.mainHorn.audioString,
            vehicle,
            sounds.mainHorn.soundSet or 0,
            0, 0
        )
    end
end)

-- run on MISS-ELS:setSirenState
RegisterNetEvent('MISS-ELS:updateSiren')
AddEventHandler('MISS-ELS:updateSiren', function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(GetPlayerFromServerId(playerid)))

    if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local ElsVehicle = ElsEnabledVehicles[vehicle]

    -- toggle the siren state (true = on, false = off)
    ElsVehicle.siren = status
    ElsEnabledVehicles[vehicle].siren = status

    -- siren is on
    if ElsVehicle.sound ~= nil then
        -- stop the siren
        StopSound(ElsVehicle.sound)
        ReleaseSoundId(ElsVehicle.sound)

        ElsVehicle.sound = nil
    end

    -- get the sounds from the VCF
    local sounds = VcfData[GetVehicleModelName(vehicle)].sounds

    -- there are 4 possible siren sounds
    local statuses = { 1, 2, 3, 4 }

    if TableHasValue(statuses, status) then
        -- get a fresh sound id
        ElsVehicle.sound = GetSoundId()
        ElsEnabledVehicles[vehicle].sound = ElsVehicle.sound

        -- play the siren sound
        PlaySoundFromEntity(
            ElsVehicle.sound,
            sounds['srnTone' .. status].audioString,
            vehicle,
            sounds['srnTone' .. status].soundSet,
            0, 0
        )
    end

    TriggerServerEvent('MISS-ELS:server:toggleSiren', VehToNet(vehicle), status)

    -- mute the native siren
    SetVehicleHasMutedSirens(vehicle, true)
end)

RegisterNetEvent('MISS-ELS:updateIndicators')
AddEventHandler('MISS-ELS:updateIndicators', function(dir, toggle)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())

    -- disable all indicators first
    SetVehicleIndicatorLights(vehicle, 1, false) -- 1 is left
    SetVehicleIndicatorLights(vehicle, 0, false) -- 0 is right

    if dir == 'left' then
        SetVehicleIndicatorLights(vehicle, 1, toggle)
    elseif dir == 'right' then
        SetVehicleIndicatorLights(vehicle, 0, toggle)
    elseif dir == 'hazard' then
        SetVehicleIndicatorLights(vehicle, 1, toggle)
        SetVehicleIndicatorLights(vehicle, 0, toggle)

    end

    -- update the indicator state
    for k, v in pairs(ElsEnabledVehicles[vehicle].indicators) do
        if k == dir then
            ElsEnabledVehicles[vehicle].indicators[k] = not v
        else
            ElsEnabledVehicles[vehicle].indicators[k] = false
        end
    end

    -- update the indicator state on the server
    TriggerServerEvent('MISS-ELS:server:toggleIndicator', VehToNet(vehicle), dir)
end)

RegisterNetEvent('MISS-ELS:client:updateState')
--- @param netVehicle number
---@param state table
AddEventHandler('MISS-ELS:client:updateState', function(netVehicle, state)
    UpdateVehicleState(netVehicle, state)
end)

Citizen.CreateThread(function()
    while true do
        -- wait for VCF data to load
        while not VcfData do Citizen.Wait(0) end

        for netVehicle, _ in pairs(ElsEnabledVehicles) do
            local vehicle = NetToVeh(netVehicle)
            local data = VcfData[GetVehicleModelName(vehicle)]

            if not data then
                Debug('warning', 'No VCF data found for vehicle ' .. GetVehicleModelName(vehicle))
                goto continue
            end

            HandleEnvironmentLights(vehicle, data)

            ::continue::
        end

        Citizen.Wait(50)
    end
end)
