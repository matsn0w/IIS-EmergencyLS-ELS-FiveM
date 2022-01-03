RegisterNetEvent("kjELS:resetExtras")
AddEventHandler("kjELS:resetExtras", function(vehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    if SetContains(kjxmlData,
                   GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))) then
        SetVehicleExtra(vehicle, 1, 1)
        SetVehicleExtra(vehicle, 2, 1)
        SetVehicleExtra(vehicle, 3, 1)
        SetVehicleExtra(vehicle, 4, 1)
        SetVehicleExtra(vehicle, 5, 1)
        SetVehicleExtra(vehicle, 6, 1)
        SetVehicleExtra(vehicle, 7, 1)
        SetVehicleExtra(vehicle, 8, 1)
        SetVehicleExtra(vehicle, 9, 1)
    end
end)

for _, v in ipairs(Config.AudioBanks) do RequestScriptAudioBank(v, false) end

RegisterNetEvent("kjELS:toggleLights")
AddEventHandler("kjELS:toggleLights", function(playerid, type, status)

    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(
                                             GetPlayerFromServerId(playerid)))

    if not vehicle then
        CancelEvent()
        return
    end

    if kjEnabledVehicles[vehicle] == nil then
        kjEnabledVehicles[vehicle] = {}
        kjEnabledVehicles[vehicle]["primary"] = false
        kjEnabledVehicles[vehicle]["secondary"] = false
        kjEnabledVehicles[vehicle]["warning"] = false
    end

    kjEnabledVehicles[vehicle][type] = status

    if type == "primary" then
        TriggerEvent("kjELS:primaryLights", vehicle)
    elseif type == "secondary" then
        TriggerEvent("kjELS:secondaryLights", vehicle)
    elseif type == "warning" then
        TriggerEvent("kjELS:warningLights", vehicle)
    end
end)

RegisterNetEvent("kjELS:primaryLights")
AddEventHandler("kjELS:primaryLights", function(vehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    for ex, _ in pairs(kjxmlData[GetCarHash(vehicle)].extras) do
        SetVehicleExtra(vehicle, ex, 1) -- Off
    end

    SetVehicleAutoRepairDisabled(vehicle, true)

    while kjEnabledVehicles[vehicle]["primary"] do -- Whilst the main lights ARE activated...
        SetVehicleEngineOn(vehicle, true, true, false) -- Keep engine on whilst lights are activated

        local lastFlash = {}
        for _, flash in pairs(kjxmlData[GetCarHash(vehicle)].patterns.primary) do
            if kjEnabledVehicles[vehicle]["primary"] then
                for _, extra in pairs(flash['extras']) do
                    SetVehicleExtra(vehicle, extra, 0)
                    table.insert(lastFlash, extra)
                end
                Citizen.Wait(flash['duration'])
            end

            -- Turn off the last flash's extras...
            for k, v in pairs(lastFlash) do
                SetVehicleExtra(vehicle, v, 1)
            end
            lastFlash = {}
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("kjELS:secondaryLights")
AddEventHandler("kjELS:secondaryLights", function(vehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    if not kjEnabledVehicles[vehicle]["secondary"] then
        for _, flash in pairs(kjxmlData[GetCarHash(vehicle)].patterns.rearreds) do
            for _, extra in pairs(flash['extras']) do
                SetVehicleExtra(vehicle, extra, 1)
            end
        end
    end

    while kjEnabledVehicles[vehicle]["secondary"] do
        SetVehicleEngineOn(vehicle, true, true, false)

        local lastFlash = {}
        for _, flash in pairs(kjxmlData[GetCarHash(vehicle)].patterns.rearreds) do
            if kjEnabledVehicles[vehicle]["secondary"] then
                for _, extra in pairs(flash['extras']) do
                    table.insert(lastFlash, extra)
                    SetVehicleExtra(vehicle, extra, 0)
                end
                Citizen.Wait(flash['duration'])
            end

            -- Turn off the last flash's extras...
            for k, v in pairs(lastFlash) do
                SetVehicleExtra(vehicle, v, 1)
            end
            lastFlash = {}
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("kjELS:warningLights")
AddEventHandler("kjELS:warningLights", function(vehicle)
    if not vehicle then
        CancelEvent()
        return
    end

    if not kjEnabledVehicles[vehicle]["warning"] then
        for _, flash in pairs(kjxmlData[GetCarHash(vehicle)].patterns.secondary) do
            for _, extra in pairs(flash['extras']) do
                SetVehicleExtra(vehicle, extra, 1)
            end
        end
    end

    while kjEnabledVehicles[vehicle]["warning"] do
        SetVehicleEngineOn(vehicle, true, true, false)

        local lastFlash = {}
        for _, flash in pairs(kjxmlData[GetCarHash(vehicle)].patterns.secondary) do
            if kjEnabledVehicles[vehicle]["warning"] then
                for _, extra in pairs(flash['extras']) do
                    table.insert(lastFlash, extra)
                    SetVehicleExtra(vehicle, extra, 0)
                end
                Citizen.Wait(flash['duration'])
            end

            -- Turn off the last flash's extras...
            for k, v in pairs(lastFlash) do
                SetVehicleExtra(vehicle, v, 1)
            end
            lastFlash = {}
        end
        Citizen.Wait(0)

    end
end)

RegisterNetEvent("kjELS:updateHorn")
AddEventHandler("kjELS:updateHorn", function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(
                                             GetPlayerFromServerId(playerid)))

    if not vehicle then
        CancelEvent()
        return
    end

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
    kjEnabledVehicles[vehicle]["horn"] = status

    if kjEnabledVehicles[vehicle]["horn_sound"] ~= nil then
        StopSound(kjEnabledVehicles[vehicle]["horn_sound"])
        ReleaseSoundId(kjEnabledVehicles[vehicle]["horn_sound"])
        kjEnabledVehicles[vehicle]["horn_sound"] = nil
    end

    if status == 1 then
        kjEnabledVehicles[vehicle]["horn_sound"] = GetSoundId()
        PlaySoundFromEntity(kjEnabledVehicles[vehicle]["horn_sound"],
                            "SIRENS_AIRHORN", vehicle, 0, 0, 0)
    end
end)

RegisterNetEvent("kjELS:updateSiren")
AddEventHandler("kjELS:updateSiren", function(playerid, status)
    local vehicle = GetVehiclePedIsUsing(GetPlayerPed(
                                             GetPlayerFromServerId(playerid)))

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
    kjEnabledVehicles[vehicle]["siren"] = status

    if kjEnabledVehicles[vehicle]["sound"] ~= nil then
        StopSound(kjEnabledVehicles[vehicle]["sound"])
        ReleaseSoundId(kjEnabledVehicles[vehicle]["sound"])
        kjEnabledVehicles[vehicle]["sound"] = nil
    end
    if kjxmlData[GetCarHash(vehicle)].sounds then
        vehicleSounds = kjxmlData[GetCarHash(vehicle)].sounds
    end

    if status == 1 then
        kjEnabledVehicles[vehicle]["sound"] = GetSoundId()
        PlaySoundFromEntity(kjEnabledVehicles[vehicle]["sound"],
                            vehicleSounds.srnTone1.audioString, vehicle,
                            vehicleSounds.srnTone1.soundSet, 0, 0)
        DisableVehicleImpactExplosionActivation(vehicle, true)
    elseif status == 2 then
        kjEnabledVehicles[vehicle]["sound"] = GetSoundId()
        PlaySoundFromEntity(kjEnabledVehicles[vehicle]["sound"],
                            vehicleSounds.srnTone2.audioString, vehicle,
                            vehicleSounds.srnTone2.soundSet, 0, 0)
        DisableVehicleImpactExplosionActivation(vehicle, true)
    elseif status == 3 then
        kjEnabledVehicles[vehicle]["sound"] = GetSoundId()
        PlaySoundFromEntity(kjEnabledVehicles[vehicle]["sound"],
                            vehicleSounds.srnTone3.audioString, vehicle,
                            vehicleSounds.srnTone3.soundSet, 0, 0)
        DisableVehicleImpactExplosionActivation(vehicle, true)
    elseif status == 4 then
        kjEnabledVehicles[vehicle]["sound"] = GetSoundId()
        PlaySoundFromEntity(kjEnabledVehicles[vehicle]["sound"],
                            vehicleSounds.srnTone4.audioString, vehicle,
                            vehicleSounds.srnTone4.soundSet, 0, 0)
        DisableVehicleImpactExplosionActivation(vehicle, true)
    else
        DisableVehicleImpactExplosionActivation(vehicle, true)
    end
end)

Citizen.CreateThread(function()
    while true do
        if kjxmlData then
            for vehicle, _ in pairs(kjEnabledVehicles) do
                if kjxmlData[GetCarHash(vehicle)] then
                    for ex, det in pairs(kjxmlData[GetCarHash(vehicle)].extras) do
                        if IsVehicleExtraTurnedOn(vehicle, ex) and det.enabled then
                            -- Flash on walls e.t.c.
                            local ExtraInfo =
                                kjxmlData[GetCarHash(vehicle)].extras[ex]
                            CreateEnviromentLight(vehicle, ex,
                                                  ExtraInfo.env_pos.x,
                                                  ExtraInfo.env_pos.y,
                                                  ExtraInfo.env_pos.z,
                                                  ExtraInfo.env_color)
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)
