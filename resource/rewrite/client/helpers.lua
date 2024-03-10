--- Checks if indicators are enabled in the configuration file.
local function indicatorsEnabled()
    return Config.Indicators
end

--- Determines if the current ped can control sirens based on the given vehicle
function CanControlSirens(vehicle)
    -- driver can always control the sirens
    if PedIsDriver(vehicle) then return true end

    -- either true or false based on the config value
    return Config.AllowPassengers
end

--- Determines if the current ped can control the ELS of the given (net) vehicle
function CanControlELS(netVehicle)
    if not kjxmlData then
        -- wait for the data to load
        while not kjxmlData do Citizen.Wait(0) end
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    if netVehicle then
        vehicle = netToVeh(netVehicle)
    end

    -- player must be in a vehicle
    if not IsPedInAnyVehicle(ped, false) then return false end

    -- player must be in an ELS vehicle
    if not IsELSVehicle(vehicle) then return false end

    -- player must be in a position to control the sirens
    if not CanControlSirens(vehicle) then return false end

    return true
end

--- Toggles a misc on the given (net) vehicle
local function toggleMisc(netVehicle, misc)
    local vehicle = netToVeh(netVehicle)

    if not vehicle or not misc then
        CancelEvent()
        return
    end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not DoesMiscExist(vehicle, misc) then
        print('Misc ' .. ConvertMiscIdToName(misc) .. ' does not exist on your ' .. model .. '!')
        CancelEvent()
        return
    end

    local index = IsVehicleMiscTurnedOn(vehicle, misc) and 0 or -1

    -- toggle the misc
    SetVehicleModKit(vehicle, 0)
    -- TODO: respect custom wheel setting
    SetVehicleMod(vehicle, misc, index, false)
end

--- Toggle an extra on a (net) vehicle
local function toggleExtra(netVehicle, extra)
    local vehicle = netToVeh(netVehicle)

    if not vehicle or not extra then
        CancelEvent()
        return
    end

    extra = tonumber(extra) or -1

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    if not DoesExtraExist(vehicle, extra) then
        print('Extra ' .. extra .. ' does not exist on your ' .. model .. '!')
        CancelEvent()
        return
    end

    -- see if the extra is currently on or off
    local toggle = IsVehicleExtraTurnedOn(vehicle, extra)

    -- disable auto repairs
    SetVehicleAutoRepairDisabled(vehicle, true)

    -- toggle the extra
    SetVehicleExtra(vehicle, extra, toggle)
end

local function toggleIndicators(netVehicle, type)
    --- If no incicator type is passed, we should not execute any code
    if not type then return end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)
    
    if netVehicle then 
        vehicle = netToVeh(netVehicle)
    end

    -- only the driver can control the indicators
    if not vehicle or not PedIsDriver(vehicle) then return end

    --- @todo check current state, modify it, and toggle the indicators that should be on and off.
    --- see old snippet: 
    -- if type ~= 'left' and Indicators.left then Indicators.left = false
    -- elseif type ~= 'right' and Indicators.right then Indicators.right = false
    -- elseif type ~= 'hazard' and Indicators.hazard then Indicators.hazard = false end

    -- play blip sound
    PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', 1)
end

--- Toggle vehicle horn sound
local function toggleHorn(netVehicle)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)

    if netVehicle then
        vehicle = netToVeh(netVehicle)
    end

    -- only the driver can control the horn
    if not vehicle or not PedIsDriver(vehicle) then return end

    -- get the horn info from the VCF
    local mainHorn = kjxmlData[GetCarHash(vehicle)].sounds.mainHorn

    -- the custom horn is disabled
    if not mainHorn or not mainHorn.allowUse then return end

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