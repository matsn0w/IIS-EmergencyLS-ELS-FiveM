-- indicator state
local function HandleIndicators(type)
    if not type then return end

    local ped = PlayerPedId()
    local vehicle = VehToNet(GetVehiclePedIsUsing(ped))
    local Indicators = ElsEnabledVehicles[vehicle].indicators

    -- only the driver can control the indicators
    if not vehicle or not PedIsDriver(vehicle) then return end

    -- disable all other indicators
    if type ~= 'left' and Indicators.left then Indicators.left = false
    elseif type ~= 'right' and Indicators.right then Indicators.right = false
    elseif type ~= 'hazard' and Indicators.hazard then Indicators.hazard = false end

    -- toggle the indicator
    Indicators[type] = not Indicators[type]
    TriggerServerEvent('MISS-ELS:sv_Indicator', type, Indicators[type])

    -- play blip sound
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
end

-- indicators are allowed on all vehicles
if Config.Indicators then
    RegisterCommand('MISS-ELS:toggle-indicator-hazard', function ()
        HandleIndicators('hazard')
    end)

    RegisterCommand('MISS-ELS:toggle-indicator-left', function ()
        HandleIndicators('left')
    end)

    RegisterCommand('MISS-ELS:toggle-indicator-right', function ()
        HandleIndicators('right')
    end)
end

local function HandleHorn()
    local ped = PlayerPedId()
    local vehicle = VehToNet(GetVehiclePedIsUsing(ped))

    -- only the driver can control the horn
    if not vehicle or not PedIsDriver(vehicle) then return end

    -- get the horn info from the VCF
    local mainHorn = VcfData[GetVehicleModelName(vehicle)].sounds.mainHorn

    -- the custom horn is disabled
    if not mainHorn or not mainHorn.allowUse then return end

    -- disable default honk sound (INPUT_VEH_HORN)
    DisableControlAction(0, 86, true)

    -- INPUT_VEH_HORN (E or L3) is pressed
    if IsDisabledControlJustPressed(0, 86) then
        TriggerServerEvent('MISS-ELS:toggleHorn', true)
    end

    -- INPUT_VEH_HORN (E or L3) is released
    if IsDisabledControlJustReleased(0, 86) then
        TriggerServerEvent('MISS-ELS:toggleHorn', false)
    end
end

--- @param netVehicle number The network ID of the vehicle
---@param stage string The light stage to toggle
---@param toggle boolean Whether to turn the lights on or off
local function ToggleLights(netVehicle, stage, toggle)
    local ElsVehicle = ElsEnabledVehicles[netVehicle]

    -- turn light stage on or off based on the toggle
    SetLightStage(netVehicle, stage, toggle)

    -- turn siren off when all lights are off
    if not ElsVehicle.primary and not ElsVehicle.secondary and not ElsVehicle.warning then
        TriggerServerEvent('MISS-ELS:setSirenState', 0)
    end
end

--- @param stage string
local function HandleLightStage(stage)
    local ped = PlayerPedId()
    local netVehicle = VehToNet(GetVehiclePedIsUsing(ped))

    if not ElsEnabledVehicles[netVehicle] then
        Debug('warning', 'Vehicle not present in ElsEnabledVehicles table, adding it now')
        AddVehicleToTable(netVehicle)
    end

    Debug('info', 'Set light stage ' .. stage .. ' to ' .. tostring(not ElsEnabledVehicles[netVehicle].stages[stage]))

    if ElsEnabledVehicles[netVehicle].stages[stage] then
        -- turn lights off
        ToggleLights(netVehicle, stage, false)
    else
        -- turn lights on
        ToggleLights(netVehicle, stage, true)
    end
end

local function HandleSiren(siren)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)

    -- siren only works in the primary light stage
    if not ElsEnabledVehicles[vehicle].primary and not Config.SirenAlwaysAllowed then return end

    local currentSiren = ElsEnabledVehicles[vehicle].siren
    local sirenOn = currentSiren ~= 0

    if (not sirenOn) or (sirenOn and siren and siren ~= currentSiren) then
        -- siren only works if it is enabled
        if siren and not VcfData[GetVehicleModelName(vehicle)].sounds['srnTone' .. siren].allowUse then return end

        -- turn the (next) siren on
        TriggerServerEvent('MISS-ELS:setSirenState', siren or 1)

        if Config.HornBlip then
            SoundVehicleHornThisFrame(vehicle)
        end
    elseif sirenOn or not siren then
        -- turn the siren off
        TriggerServerEvent('MISS-ELS:setSirenState', 0)

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

local function HandleToggleHighbeams()
    local ped = PlayerPedId()
    local vehicle = VehToNet(GetVehiclePedIsUsing(ped))

    ElsEnabledVehicles[vehicle].highBeamEnabled = not ElsEnabledVehicles[vehicle].highBeamEnabled
end

local function NextSiren()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)

    -- get the next siren
    local next = ElsEnabledVehicles[vehicle].siren + 1

    -- keep track of the amount of tries, there are a total of 4 sirens
    local max = 4
    local count = 0

    -- go back to 1
    if next > 4 then next = 1 end

    -- check if the next siren is allowed
    while not VcfData[GetVehicleModelName(vehicle)].sounds['srnTone' .. next].allowUse do
        -- check if the maximum is reached, not even one siren is allowed!
        if count == max then return end

        -- try the next siren
        next = next + 1

        -- go back to 1
        if next > 4 then next = 1 end

        count = count + 1
    end

    -- turn the siren on
    HandleSiren(next)
end

RegisterCommand('MISS-ELS:toggle-stage-primary', function ()
    if not CanControlELS() then return end

    HandleLightStage('primary')
end)

RegisterCommand('MISS-ELS:toggle-stage-secondary', function ()
    if not CanControlELS() then return end

    HandleLightStage('secondary')
end)

RegisterCommand('MISS-ELS:toggle-stage-warning', function ()
    if not CanControlELS() then return end

    HandleLightStage('warning')
end)

RegisterCommand('MISS-ELS:toggle-siren', function ()
    if not CanControlELS() then return end

    HandleSiren()
end)

RegisterCommand('MISS-ELS:toggle-siren-next', function ()
    if not CanControlELS() then return end

    NextSiren()
end)

RegisterCommand('MISS-ELS:toggle-siren-one', function ()
    if not CanControlELS() then return end

    HandleSiren(1)
end)

RegisterCommand('MISS-ELS:toggle-siren-two', function ()
    if not CanControlELS() then return end

    HandleSiren(2)
end)

RegisterCommand('MISS-ELS:toggle-siren-three', function ()
    if not CanControlELS() then return end

    HandleSiren(3)
end)

RegisterCommand('MISS-ELS:toggle-siren-four', function ()
    if not CanControlELS() then return end

    HandleSiren(4)
end)

RegisterCommand('MISS-ELS:toggle-highbeams', function ()
    if not CanControlELS() then return end

    HandleToggleHighbeams()
end)

AddEventHandler('onClientResourceStart', function(name)
    if not Config then
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    -- OneSync render checking loop
    -- Checks if vehicle is within render on the client
    Citizen.CreateThread(function()
        while true do
            for netVehicle, vehicleState in pairs(ElsEnabledVehicles) do
                local exists = NetworkDoesEntityExistWithNetworkId(netVehicle)

                -- Vehicle got out of scope of the client
                if not exists and vehicleState.initialized then
                    Debug('info', 'Vehicle ' .. netVehicle .. ' got out of scope of the client')
                    UnloadVehicle(netVehicle)
                    goto continue
                end

                -- Vehicle got within scope of the client
                if exists and not vehicleState.initialized then
                    Debug('info', 'Vehicle ' .. netVehicle .. ' got within scope of the client')
                    LoadVehicle(netVehicle)
                end

                ::continue::
            end

            Citizen.Wait(50)
        end
    end)

    Citizen.CreateThread(function()
        while true do
            if not VcfData then
                -- request ELS data
                TriggerServerEvent('MISS-ELS:requestELSInformation')

                -- wait for the data to load
                while not VcfData do Citizen.Wait(0) end
            end

            -- wait untill the player is in a vehicle
            while not IsPedInAnyVehicle(PlayerPedId(), false) do Citizen.Wait(0) end

            local ped = PlayerPedId()
            local vehicle = VehToNet(GetVehiclePedIsUsing(ped))

            TriggerServerEvent('MISS-ELS:server:enteredVehicle', vehicle)
            TriggerEvent('MISS-ELS:initVehicle', ped)

            -- only run if player is in an ELS enabled vehicle and can control the sirens
            if IsElsVehicle(vehicle) and CanControlSirens(vehicle) then
                -- conflicting controls
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
                    DisableControlAction(control[1], control[2], true)
                end

                -- set vehicle state
                SetVehRadioStation(vehicle, 'OFF')
                SetVehicleRadioEnabled(vehicle, false)
                SetVehicleAutoRepairDisabled(vehicle, true)

                -- add vehicle to ELS table if not listed already
                if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

                -- handle the horn
                HandleHorn()

                if not IsUsingKeyboard(0) then
                    -- on controller
                    if IsDisabledControlJustReleased(1, 85 --[[ DPAD_LEFT ]]) then HandleLightStage('primary')
                    elseif IsDisabledControlJustReleased(1, 170 --[[ B ]]) then NextSiren()
                    elseif IsDisabledControlJustReleased(1, 173 --[[ DPAD_DOWN ]]) then HandleSiren()
                    end
                end
            end

            Citizen.Wait(0)
        end
    end)
end)