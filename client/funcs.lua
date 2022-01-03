function getCarHash(car)
    if car then
        for k, v in pairs(kjxmlData) do
            if GetEntityModel(car) == GetHashKey(k) then return k end
        end
    end

    return false
end

function createEnviromentLight(vehicle, extra, offsetX, offsetY, offsetZ, colour)
    local boneIndex = GetEntityBoneIndexByName(vehicle, "extra_" .. extra)
    local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    if string.lower(colour) == 'blue' then
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY,
                                    coords.z + offsetZ, 0, 0, 255, 50.0, 0.020,
                                    5.0) -- Blue Lights
    elseif string.lower(colour) == 'red' then
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY,
                                    coords.z + offsetZ, 255, 0, 0, 50.0, 0.020,
                                    5.0) -- Red Lights
    elseif string.lower(colour) == 'green' then
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY,
                                    coords.z + offsetZ, 0, 255, 0, 50.0, 0.020,
                                    5.0) -- Green Lights
    elseif string.lower(colour) == 'white' then
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY,
                                    coords.z + offsetZ, 255, 255, 255, 50.0,
                                    0.020, 5.0) -- White Lights
    elseif string.lower(colour) == 'amber' then
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY,
                                    coords.z + offsetZ, 255, 194, 0, 50.0,
                                    0.020, 5.0) -- Amber Lights
    end
end

function setContains(set, key) return set[key] ~= nil end

function has_value(tab, val)
    for index, value in ipairs(tab) do if value == val then return true end end

    return false
end
