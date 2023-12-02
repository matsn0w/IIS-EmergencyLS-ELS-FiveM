local function ToggleExtra(vehicle, extra, toggle)
    local value = toggle and 0 or 1

    SetVehicleAutoRepairDisabled(vehicle, true)
    SetVehicleExtra(vehicle, extra, value)
end

local function ToggleMisc(vehicle, misc, toggle)
    SetVehicleModKit(vehicle, 0)
    --- @todo respect custom wheel setting
    SetVehicleMod(vehicle, misc, toggle, false)
end

function SetLightStage(netVehicle, stage, toggle)
    local vehicle = NetToVeh(netVehicle)
    local ELSvehicle = ElsEnabledVehicles[netVehicle]
    local VCFdata = VcfData[GetCarHash(vehicle)]

    -- get the pattern data
    local patternData = VCFdata.patterns[ConvertStageToPattern(stage)]

    -- reset all extras and miscs
    TriggerEvent('MISS-ELS:resetExtras', vehicle)
    TriggerEvent('MISS-ELS:resetMiscs', vehicle)

    -- set the light state
    ELSvehicle[stage] = toggle

    -- update the light stage on the server
    TriggerServerEvent('MISS-ELS:server:toggleLightStage', netVehicle, { stage })

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
            while ELSvehicle[stage] do
                if ELSvehicle.highBeamEnabled then
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
            while ELSvehicle[stage] do
                -- play warning sound
                SendNUIMessage({ transactionType = 'playSound', transactionFile = 'WarningBeep', transactionVolume = 0.2 })

                -- this should be equal to the length of the audio file
                Citizen.Wait((Config.WarningBeepDuration or 0) * 1000)
            end
        end)
    end

    Citizen.CreateThread(function()
        while ELSvehicle[stage] do
            -- keep the engine on whilst the lights are activated
            SetVehicleEngineOn(vehicle, true, true, false)

            local lastFlash = {
                extras = {},
                miscs = {},
            }

            for _, flash in ipairs(patternData) do
                if ELSvehicle[stage] then
                    for _, extra in ipairs(flash['extras']) do
                        -- disable auto repairs
                        SetVehicleAutoRepairDisabled(vehicle, true)

                        -- turn the extra on
                        ToggleExtra(vehicle, extra, true)

                        -- save the extra as last flashed
                        table.insert(lastFlash.extras, extra)
                    end

                    for _, misc in ipairs(flash['miscs']) do
                        -- turn the misc on
                        ToggleMisc(vehicle, misc, true)

                        -- save the misc as last flashed
                        table.insert(lastFlash.miscs, misc)
                    end

                    Citizen.Wait(flash.duration)
                end

                -- turn off the last flashed lights
                for _, v in ipairs(lastFlash.extras) do
                    -- disable auto repairs
                    SetVehicleAutoRepairDisabled(vehicle, true)

                    ToggleExtra(vehicle, v, false)
                end

                for _, v in ipairs(lastFlash.miscs) do
                    ToggleMisc(vehicle, v, false)
                end

                lastFlash.extras = {}
                lastFlash.miscs = {}
            end

            Citizen.Wait(0)
        end

        Wait(0)
    end)
end

local function StaticsIncludesExtra(model, extra)
    return VcfData[model].statics.extras[extra] ~= nil
end

local function StaticsIncludesMisc(model, misc)
    return VcfData[model].statics.miscs[misc] ~= nil
end

RegisterNetEvent('MISS-ELS:resetExtras')
AddEventHandler('MISS-ELS:resetExtras', function(netVehicle)

    local vehicle = NetToVeh(netVehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not SetContains(VcfData, model) then
        CancelEvent()
        return
    end

    -- loop through all extra's
    for extra, info in pairs(VcfData[model].extras) do
        -- check if we can control this extra
        if info.enabled == true and not StaticsIncludesExtra(model, extra) then
            -- disable auto repairs
            SetVehicleAutoRepairDisabled(vehicle, true)

            -- disable the extra
            ToggleExtra(vehicle, extra, false)
        end
    end
end)

RegisterNetEvent('MISS-ELS:resetMiscs')
AddEventHandler('MISS-ELS:resetMiscs', function(netVehicle)
    local vehicle = NetToVeh(netVehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not SetContains(VcfData, model) then
        CancelEvent()
        return
    end

    -- loop through all miscs
    for misc, info in pairs(VcfData[model].miscs) do
        -- check if we can control this misc
        if info.enabled == true and not StaticsIncludesMisc(model, misc) then
            -- disable the misc
            ToggleMisc(vehicle, misc, false)
        end
    end
end)

RegisterNetEvent('MISS-ELS:toggleLights')
AddEventHandler('MISS-ELS:toggleLights', function(netVehicle, stage, toggle)
    if not netVehicle then
        CancelEvent()
        return
    end

    if ElsEnabledVehicles[netVehicle] == nil then AddVehicleToTable(netVehicle) end

    -- set the light stage
    SetLightStage(netVehicle, stage, toggle)
end)

RegisterNetEvent('MISS-ELS:updateHorn')
AddEventHandler('MISS-ELS:updateHorn', function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(GetPlayerFromServerId(playerid)))

    if not vehicle then
        CancelEvent()
        return
    end

    if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local ELSvehicle = ElsEnabledVehicles[vehicle]

    -- toggle the horn state (true = on, false = off)
    ELSvehicle.horn = status

    -- get the sounds from the VCF
    local sounds = VcfData[GetCarHash(vehicle)].sounds

    -- horn is honking
    if ELSvehicle.sound_id ~= nil then
        -- stop honking the horn
        StopSound(ELSvehicle.sound_id)
        ReleaseSoundId(ELSvehicle.sound_id)

        ELSvehicle.sound_id = nil
    end

    -- horn is set to 'on'
    if status then
        -- get a fresh sound id
        ELSvehicle.sound_id = GetSoundId()

        -- honk the horn
        PlaySoundFromEntity(
            ELSvehicle.sound_id,
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

    local ELSvehicle = ElsEnabledVehicles[vehicle]

    -- toggle the siren state (true = on, false = off)
    ELSvehicle.siren = status
    ElsEnabledVehicles[vehicle].siren = status

    -- siren is on
    if ELSvehicle.sound ~= nil then
        -- stop the siren
        StopSound(ELSvehicle.sound)
        ReleaseSoundId(ELSvehicle.sound)

        ELSvehicle.sound = nil
    end

    -- get the sounds from the VCF
    local sounds = VcfData[GetCarHash(vehicle)].sounds

    -- there are 4 possible siren sounds
    local statuses = { 1, 2, 3, 4 }

    if TableHasValue(statuses, status) then
        -- get a fresh sound id
        ELSvehicle.sound = GetSoundId()
        ElsEnabledVehicles[vehicle].sound = ELSvehicle.sound

        -- play the siren sound
        PlaySoundFromEntity(
            ELSvehicle.sound,
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

RegisterNetEvent('MISS-ELS:client:updateState')
AddEventHandler('MISS-ELS:client:updateState', function(netVehicle, state)
    UpdateVehicleState(netVehicle, state)
end)

Citizen.CreateThread(function()
    while true do
        -- wait for VCF data to load
        while not VcfData do Citizen.Wait(0) end

        for vehicle, _ in pairs(ElsEnabledVehicles) do
            local data = VcfData[GetCarHash(vehicle)]

            if data then
                for extra, info in pairs(data.extras) do
                    if IsVehicleExtraTurnedOn(vehicle, extra) and info.env_light then
                        local offset = vector3(info.env_pos.x, info.env_pos.y, info.env_pos.z)
                        local light = {
                            type = 'extra',
                            name = extra
                        }

                        -- flash on walls
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

                        -- flash on walls
                        CreateEnviromentLight(vehicle, light, offset, info.env_color)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)
