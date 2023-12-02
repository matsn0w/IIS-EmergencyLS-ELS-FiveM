--- @param netVehicle number
function AddVehicleToTable(netVehicle)
    ElsEnabledVehicles[netVehicle] = {
        initialized = false,
        vehicle = NetToVeh(netVehicle),
        netVehicle = netVehicle,
        stages = {
            primary = false,
            secondary = false,
            rearreds = false,
        },
        siren = 0,
        sound = nil,
        horn = false,
        indicators = {
            left = false,
            right = false,
            hazard = false,
        },
    }
end

--- Unload the vehicle when the vehicle becomes unavailable to the client
--- @param netVehicle number The network ID of the vehicle
function UnloadVehicle(netVehicle)
    local elsVehicle = ElsEnabledVehicles[netVehicle]

    if not elsVehicle.initialized then
        return
    end

    elsVehicle.initialized = false

    -- Stop all playing sounds by vehicle
    StopSound(elsVehicle.soundId)
    ReleaseSoundId(elsVehicle.soundId)
end

function LoadVehicle(netVehicle)
    local elsVehicle = ElsEnabledVehicles[netVehicle]

    elsVehicle.initialized = true

    local vehicle = NetToVeh(netVehicle)

    -- Set cached data
    elsVehicle.vehicle = vehicle
    elsVehicle.netVehicle = netVehicle

    -- Set vehicle defaults
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleRadioEnabled(vehicle, false)
    SetVehicleAutoRepairDisabled(vehicle, true)
    SetVehicleHasMutedSirens(vehicle, true)

    -- Reset all extras on the vehicle
    TriggerEvent('MISS-ELS:resetExtras', netVehicle)
    TriggerEvent('MISS-ELS:resetMiscs', netVehicle)

    -- Request the state of the vehicle
    TriggerServerEvent('MISS-ELS:server:requestState', netVehicle)
end

--- Update the overall state of the network vehicle
--- @param netVehicle number The network ID of the vehicle
--- @param state table The fully updated state of the vehicle
function UpdateVehicleState(netVehicle, state)
    local elsVehicle = ElsEnabledVehicles[netVehicle]

    if not elsVehicle.initialized then
        return
    end

    -- Update siren when state changed
    if state.siren ~= elsVehicle.state.siren then
        SetVehicleSiren(netVehicle, state.siren)
    end

    -- Update primary when primary changed
    if state.primary ~= elsVehicle.state.primary then
        SetLightStage(netVehicle, 'primary', state.primary)
    end

    -- Update secondary when secondary changed
    if state.secondary ~= elsVehicle.state.secondary then
        SetLightStage(netVehicle, 'secondary', state.secondary)
    end

    -- Update warning lights when warning lights changed
    if state.warning ~= elsVehicle.state.warning then
        SetLightStage(netVehicle, 'warning', state.warning)
    end
end
