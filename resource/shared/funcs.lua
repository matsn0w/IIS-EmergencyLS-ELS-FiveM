function SetContains(set, key) return set[key] ~= nil end

function TableHasValue(table, value)
    for i, v in pairs(table) do
        if v == value then return true end
    end

    return false
end

function GetCarHash(car)
    if not car then return false end

    for k, v in pairs(kjxmlData) do
        if GetEntityModel(car) == GetHashKey(k) and v.extras ~= nil then return k end
    end

    return false
end

function AddVehicleToTable(vehicle)
    kjEnabledVehicles[vehicle] = {
        primary = false,
        secondary = false,
        warning = false,
        siren = 0,
        sound = nil
    }
end

function IsELSVehicle(vehicle)
    return GetCarHash(vehicle) ~= false
end

function PedIsDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

function CanControlSirens(vehicle)
    -- driver can always control the sirens
    if PedIsDriver(vehicle) then return true end

    -- either true or false based on the config value
    return Config.AllowPassengers
end

function ConvertStageToPattern(stage)
    local pattern = stage

    -- yeah...
    if stage == 'secondary' then pattern = 'rearreds'
    elseif stage == 'warning' then pattern = 'secondary' end

    return pattern
end
