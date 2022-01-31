-- indicator state
Indicators = {
    left = false,
    right = false,
    hazard = false
}

local function HandleIndicators(vehicle)
    -- only the driver can control the indicators
    if not PedIsDriver(vehicle) then return end

    local type = nil

    if IsControlJustReleased(0, Config.KeyBinds['IndicatorHazard']) and IsUsingKeyboard(0) then type = 'hazard'
    elseif IsControlJustReleased(0, Config.KeyBinds['IndicatorLeft']) and IsUsingKeyboard(0) then type = 'left'
    elseif IsControlJustReleased(0, Config.KeyBinds['IndicatorRight']) and IsUsingKeyboard(0) then type = 'right' end

    if not type then return end

    -- disable all other indicators
    if type ~= 'left' and Indicators.left then Indicators.left = false
    elseif type ~= 'right' and Indicators.right then Indicators.right = false
    elseif type ~= 'hazard' and Indicators.hazard then Indicators.hazard = false end

    -- toggle the indicator
    Indicators[type] = not Indicators[type]
    TriggerServerEvent('kjELS:sv_Indicator', type, Indicators[type])

    -- play blip sound
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
end

local function HandleHorn(vehicle)
    -- only the driver can control the horn
    if not PedIsDriver(vehicle) then return end

    -- get the horn info from the VCF
    if kjxmlData[GetCarHash(vehicle)] == nil then return end
    local mainHorn = kjxmlData[GetCarHash(vehicle)].sounds.mainHorn

    -- the custom horn is disabled
    if not mainHorn.allowUse then return end

    -- disable default honk sound (INPUT_VEH_HORN)
    DisableControlAction(0, 86, true)

    -- INPUT_VEH_HORN (E or L3) is pressed
    if IsDisabledControlJustPressed(0, 86) then
        TriggerServerEvent('kjELS:toggleHorn', true)
    end

    -- INPUT_VEH_HORN (E or L3) is released
    if IsDisabledControlJustReleased(0, 86) then
        TriggerServerEvent('kjELS:toggleHorn', false)
    end
end

local function ToggleLights(vehicle, stage, toggle)
    -- turn light stage on or off based on the toggle
    TriggerServerEvent('kjELS:updateStatus', stage, toggle)
    SetVehicleSiren(vehicle, toggle)
    TriggerServerEvent('kjELS:setSirenState', 0)
end

local function HandleLightStage(vehicle, stage)
    if kjEnabledVehicles[vehicle][stage] then
        ToggleLights(vehicle, stage, false)
    else
        ToggleLights(vehicle, stage, true)

        if stage == 'primary' and kjxmlData[GetCarHash(vehicle)].sounds.nineMode then
            -- play 999 sound effect
            SendNUIMessage({ transactionType = 'playSound', transactionFile = '999mode', transactionVolume = 1.0 })
        end
    end
end

local function HandleSiren(vehicle, siren)
    -- siren only works in the primary light stage
    if not kjEnabledVehicles[vehicle].primary then return end

    local currentSiren = kjEnabledVehicles[vehicle].siren
    local sirenOn = currentSiren ~= 0

    if (not sirenOn) or (sirenOn and siren and siren ~= currentSiren) then
        -- siren only works if it is enabled
        if siren and not kjxmlData[GetCarHash(vehicle)].sounds['srnTone' .. siren].allowUse then return end

        -- turn the (next) siren on
        TriggerServerEvent('kjELS:setSirenState', siren or 1)

        if Config.HornBlip then
            SoundVehicleHornThisFrame(vehicle)
        end
    elseif sirenOn or not siren then
        -- turn the siren off
        TriggerServerEvent('kjELS:setSirenState', 0)

        if Config.HornBlip then
            Wait(100)
            SoundVehicleHornThisFrame(vehicle)
            Wait(100)
            SoundVehicleHornThisFrame(vehicle)
        end
    end

    if Config.Beeps then
        SendNUIMessage({ transactionType = 'playSound', transactionFile = 'Beep', transactionVolume = 0.025 })
    end
end

local function NextSiren(vehicle)
    -- get the next siren
    local next = kjEnabledVehicles[vehicle].siren + 1

    -- keep track of the amount of tries, there are a total of 4 sirens
    local max = 4
    local count = 0

    -- check if the next siren is allowed
    while not kjxmlData[GetCarHash(vehicle)].sounds['srnTone' .. next].allowUse do
        -- check if the maximum is reached, not even one siren is allowed!
        if count == max then return end

        -- try the next siren
        next = next + 1

        -- go back to 1
        if next > 4 then next = 1 end

        count = count + 1
    end

    -- go back to 1
    if next > 4 then next = 1 end

    -- turn the siren on
    HandleSiren(vehicle, next)
end

AddEventHandler('onClientResourceStart', function(name)
    if not Config then
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    Citizen.CreateThread(function()
        while true do
            if not kjxmlData then
                -- request ELS data
                TriggerServerEvent('kjELS:requestELSInformation')

                -- wait for the data to load
                while not kjxmlData do Citizen.Wait(0) end
            end

            -- wait untill the player is in a vehicle
            while not IsPedInAnyVehicle(PlayerPedId(), false) do Citizen.Wait(0) end

            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(ped)

            if IsUsingKeyboard(0) then
                -- indicators are allowed on all vehicles
                if Config.Indicators then HandleIndicators(vehicle) end
            end

            -- only run if player is in an ELS enabled vehicle and can control the sirens
            if IsELSVehicle(vehicle) and CanControlSirens(vehicle) then

                local controls = {
                    { 0, 58 }, -- INPUT_THROW_GRENADE
                    { 0, 73 }, -- INPUT_VEH_DUCK
                    { 0, 80 }, -- INPUT_VEH_CIN_CAM
                    { 1, 80 }, -- INPUT_VEH_CIN_CAM
                    { 0, 81 }, -- INPUT_VEH_NEXT_RADIO
                    { 0, 82 }, -- INPUT_VEH_PREV_RADIO
                    { 0, 83 }, -- INPUT_VEH_NEXT_RADIO_TRACK
                    { 0, 84 }, -- INPUT_VEH_PREV_RADIO_TRACK
                }

                -- disable all conflicting controls
                for _, control in ipairs(controls) do
                    -- do not disable if the control is in the key binds
                    if not TableHasValue(Config.KeyBinds, control[2]) then
                        DisableControlAction(control[1], control[2], true)
                    end
                end

                -- set vehicle state
                SetVehRadioStation(vehicle, 'OFF')
                SetVehicleRadioEnabled(vehicle, false)
                SetVehicleAutoRepairDisabled(vehicle, true)

                -- add vehicle to ELS table if not listed already
                if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

                -- handle the horn
                HandleHorn(vehicle)

                if IsUsingKeyboard(0) then
                    -- light stages
                    if IsControlJustReleased(0, Config.KeyBinds['PrimaryLights']) then HandleLightStage(vehicle, 'primary')
                    elseif IsControlJustReleased(0, Config.KeyBinds['SecondaryLights']) then HandleLightStage(vehicle, 'secondary')
                    elseif IsControlJustReleased(0, Config.KeyBinds['MiscLights']) then HandleLightStage(vehicle, 'warning')
                    end

                    -- siren toggles
                    if IsControlJustReleased(0, Config.KeyBinds['ActivateSiren']) then HandleSiren(vehicle)
                    elseif IsControlJustReleased(0, Config.KeyBinds['NextSiren']) then NextSiren(vehicle)
                    elseif IsControlJustReleased(0, Config.KeyBinds['Siren1']) then HandleSiren(vehicle, 1)
                    elseif IsControlJustReleased(0, Config.KeyBinds['Siren2']) then HandleSiren(vehicle, 2)
                    elseif IsControlJustReleased(0, Config.KeyBinds['Siren3']) then HandleSiren(vehicle, 3)
                    elseif IsControlJustReleased(0, Config.KeyBinds['Siren4']) then HandleSiren(vehicle, 4)
                    end
                else -- on controller
                    if IsControlJustReleased(1, 85 --[[ DPAD_LEFT ]]) then HandleLightStage(vehicle, 'primary')
                    elseif IsControlJustReleased(1, 170 --[[ B ]]) then NextSiren(vehicle)
                    elseif IsControlJustReleased(1, 173 --[[ DPAD_DOWN ]]) then HandleSiren(vehicle)
                    end
                end
            end

            Citizen.Wait(0)
        end
    end)
end)
