local function SetLightStage(vehicle, stage, toggle)
    local ELSvehicle = kjEnabledVehicles[vehicle]
    local VCFdata = kjxmlData[GetCarHash(vehicle)]

    -- get the pattern data
    local patternData = VCFdata.patterns[ConvertStageToPattern(stage)]

    -- reset all extras
    TriggerEvent('kjELS:resetExtras', vehicle)

    -- set the light state
    ELSvehicle[stage] = toggle

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

            local lastFlash = {}

            for _, flash in ipairs(patternData) do
                if ELSvehicle[stage] then
                    for _, extra in ipairs(flash['extras']) do
                        -- disable auto repairs
                        SetVehicleAutoRepairDisabled(vehicle, true)

                        -- turn the extra on
                        SetVehicleExtra(vehicle, extra, 0)

                        -- save the extra as last flashed
                        table.insert(lastFlash, extra)
                    end

                    Citizen.Wait(flash.duration)
                end

                -- turn off the last flashed extras
                for _, v in ipairs(lastFlash) do
                    -- disable auto repairs
                    SetVehicleAutoRepairDisabled(vehicle, true)

                    SetVehicleExtra(vehicle, v, 1)
                end

                lastFlash = {}
            end

            Citizen.Wait(0)
        end

        Wait(0)
    end)
end

RegisterNetEvent('kjELS:resetExtras')
AddEventHandler('kjELS:resetExtras', function(vehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not SetContains(kjxmlData, model) then
        CancelEvent()
        return
    end

    -- loop through all extra's
    for extra, info in pairs(kjxmlData[model].extras) do
        -- check if we can control this extra
        if info.enabled == true then
            -- disable auto repairs
            SetVehicleAutoRepairDisabled(vehicle, true)

            -- disable the extra
            SetVehicleExtra(vehicle, extra, true)
        end
    end
end)

RegisterNetEvent('kjELS:toggleLights')
AddEventHandler('kjELS:toggleLights', function(vehicle, stage, toggle)
    if not vehicle then
        CancelEvent()
        return
    end

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    -- set the light stage
    SetLightStage(vehicle, stage, toggle)
end)

RegisterNetEvent('kjELS:updateHorn')
AddEventHandler('kjELS:updateHorn', function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(GetPlayerFromServerId(playerid)))

    if not vehicle then
        CancelEvent()
        return
    end

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local ELSvehicle = kjEnabledVehicles[vehicle]

    -- toggle the horn state (true = on, false = off)
    ELSvehicle.horn = status

    -- get the sounds from the VCF
    local sounds = kjxmlData[GetCarHash(vehicle)].sounds

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

-- run on kjELS:setSirenState
RegisterNetEvent('kjELS:updateSiren')
AddEventHandler('kjELS:updateSiren', function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(GetPlayerFromServerId(playerid)))

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

    local ELSvehicle = kjEnabledVehicles[vehicle]

    -- toggle the siren state (true = on, false = off)
    ELSvehicle.siren = status

    -- siren is on
    if ELSvehicle.sound ~= nil then
        -- stop the siren
        StopSound(ELSvehicle.sound)
        ReleaseSoundId(ELSvehicle.sound)

        ELSvehicle.sound = nil
    end

    -- get the sounds from the VCF
    local sounds = kjxmlData[GetCarHash(vehicle)].sounds

    -- there are 4 possible siren sounds
    local statuses = {1, 2, 3, 4}

    if TableHasValue(statuses, status) then
        -- get a fresh sound id
        ELSvehicle.sound = GetSoundId()

        -- play the siren sound
        PlaySoundFromEntity(
            ELSvehicle.sound,
            sounds['srnTone' .. status].audioString,
            vehicle,
            sounds['srnTone' .. status].soundSet,
            0, 0
        )
    end

    -- mute the native siren
    SetVehicleHasMutedSirens(vehicle, true)
end)

RegisterNetEvent('kjELS:updateIndicators')
AddEventHandler('kjELS:updateIndicators', function(dir, toggle)
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
end)

local function CreateEnviromentLight(vehicle, extra, offset, color)
    local boneIndex = GetEntityBoneIndexByName(vehicle, 'extra_' .. extra)
    local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    local position = coords + offset

    local rgb = { 0, 0, 0 }
    local range = Config.EnvironmentalLights.Range or 50.0
    local intensity = Config.EnvironmentalLights.Intensity or 1.0
    local shadow = 1.0

    if string.lower(color) == 'blue' then rgb = { 0, 0, 255 }
    elseif string.lower(color) == 'red' then rgb = { 255, 0, 0 }
    elseif string.lower(color) == 'green' then rgb = { 0, 255, 0 }
    elseif string.lower(color) == 'white' then rgb = { 255, 255, 255 }
    elseif string.lower(color) == 'amber' then rgb = { 255, 194, 0}
    end

    -- draw the light
    DrawLightWithRangeAndShadow(
        position.x, position.y, position.z,
        rgb[1], rgb[2], rgb[3],
        range, intensity, shadow
    )
end

Citizen.CreateThread(function()
    while true do
        -- wait for VCF data to load
        while not kjxmlData do Citizen.Wait(0) end

        for vehicle, _ in pairs(kjEnabledVehicles) do
            local data = kjxmlData[GetCarHash(vehicle)]

            if data then
                for extra, info in pairs(data.extras) do
                    if IsVehicleExtraTurnedOn(vehicle, extra) and info.env_light then
                        local offset = vector3(info.env_pos.x, info.env_pos.y, info.env_pos.z)

                        -- flash on walls
                        CreateEnviromentLight(vehicle, extra, offset, info.env_color)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)
