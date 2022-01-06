function SetContains(set, key) return set[key] ~= nil end

function TableHasValue(table, value)
    for i, v in pairs(table) do
        if v == value then return true end
    end

    return false
end

function CreateEnviromentLight(vehicle, extra, offset, color)
    -- TODO: beam light from extra bone instead of the vehicle
    -- local boneIndex = GetEntityBoneIndexByName(vehicle, 'extra_' .. extra)
    -- local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    -- get the coord of a position around the car
    local position = GetOffsetFromEntityInWorldCoords(vehicle, offset.x, offset.y, offset.z)
    local x, y, z = table.unpack(position)

    local rgb = { 0, 0, 0 }
    local range = 10.0
    local intensity = 0.5
    local shadow = 5.1

    if string.lower(color) == 'blue' then rgb = { 0, 0, 255 }
    elseif string.lower(color) == 'red' then rgb = { 255, 0, 0 }
    elseif string.lower(color) == 'green' then rgb = { 0, 255, 0 }
    elseif string.lower(color) == 'white' then rgb = { 255, 255, 255 }
    elseif string.lower(color) == 'amber' then rgb = { 255, 194, 0}
    end

    -- draw the light
    DrawLightWithRangeAndShadow(x, y, z, rgb[1], rgb[2], rgb[3], range, intensity, shadow)
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
