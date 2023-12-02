--- @param netVehicle number
function AddVehicleToTable(netVehicle)
    ElsEnabledVehicles[netVehicle] = {
        initialized = false,
        vehicle = NetToVeh(netVehicle),
        netVehicle = netVehicle,
        highBeamEnabled = false,
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

--- @param vehicle number The vehicle to get the model name of
--- @return string|boolean model The model name of the vehicle or false if not found
function GetVehicleModelName(vehicle)
    for model, _ in pairs(VcfData) do
        if GetEntityModel(vehicle) == GetHashKey(model) then return model end
    end

    return false
end

function IsElsVehicle(vehicle)
    return GetVehicleModelName(vehicle) ~= false
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
    ResetVehicleExtras(vehicle)
    ResetVehicleMiscs(vehicle)

    -- Request the state of the vehicle
    TriggerServerEvent('MISS-ELS:server:requestState', netVehicle)
end

--- Update the overall state of the network vehicle
--- @param netVehicle number The network ID of the vehicle
--- @param state table The fully updated state of the vehicle
function UpdateVehicleState(netVehicle, state)
    local elsVehicle = ElsEnabledVehicles[netVehicle]

    if not elsVehicle.initialized then
        Debug('warning', 'Vehicle ' .. netVehicle .. ' is not initialized');
        return
    end

    -- Update siren when state changed
    if state.siren ~= elsVehicle.siren then
        Debug('info', 'Updated siren of vehicle ' .. netVehicle .. ' to ' .. state.siren)
        SetVehicleSiren(netVehicle, state.siren)
    end

    if state.indicators.left ~= elsVehicle.indicators.left then
        Debug('info', 'Updated indicators of vehicle ' .. netVehicle .. ' to ' .. state.indicators.left)
    end

    if state.indicators.right ~= elsVehicle.indicators.right then
        Debug('info', 'Updated indicators of vehicle ' .. netVehicle .. ' to ' .. state.indicators.right)
    end
    
    if state.indicators.hazard ~= elsVehicle.indicators.hazard then
        Debug('info', 'Updated indicators of vehicle ' .. netVehicle .. ' to ' .. state.indicators.hazard)
    end
    -- Update primary when primary changed
    if state.primary ~= elsVehicle.primary then
        SetLightStage(netVehicle, 'primary', state.primary)
        Debug('info', 'Updated primary stage of vehicle ' .. netVehicle .. ' to ' .. state.primary)
    end

    -- Update secondary when secondary changed
    if state.secondary ~= elsVehicle.secondary then
        SetLightStage(netVehicle, 'secondary', state.secondary)
        Debug('info', 'Updated secondary stage of vehicle ' .. netVehicle .. ' to ' .. state.secondary)
    end

    -- Update warning lights when warning lights changed
    if state.warning ~= elsVehicle.warning then
        SetLightStage(netVehicle, 'warning', state.warning)
        Debug('info', 'Updated warning stage of vehicle ' .. netVehicle .. ' to ' .. state.warning)
    end
end
