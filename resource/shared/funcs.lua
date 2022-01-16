-- whether a set contains a given key
function SetContains(set, key) return set[key] ~= nil end

-- whether a table contains a given value
function TableHasValue(table, value)
    for i, v in pairs(table) do
        if v == value then return true end
    end

    return false
end

-- custom iterator function
-- source: https://stackoverflow.com/a/15706820/6390292
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
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
