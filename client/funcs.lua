function GetCarHash(car)
    if car then
        for k, v in pairs(kjxmlData) do
            if GetEntityModel(car) == GetHashKey(k) then return k end
        end
    end

    return false
end

function CreateEnviromentLight(vehicle, extra, offsetX, offsetY, offsetZ, color)
    local boneIndex = GetEntityBoneIndexByName(vehicle, "extra_" .. extra)
    local coords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    if string.lower(color) == 'blue' then
        -- Blue
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY, coords.z + offsetZ, 
                                    0, 0, 255, 50.0, 0.020, 5.0)

    elseif string.lower(color) == 'red' then
        -- Red
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY, coords.z + offsetZ, 
                                    255, 0, 0, 50.0, 0.020, 5.0)

    elseif string.lower(color) == 'green' then
        -- Green
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY, coords.z + offsetZ, 
                                    0, 255, 0, 50.0, 0.020, 5.0)

    elseif string.lower(color) == 'white' then
        -- White
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY, coords.z + offsetZ, 
                                    255, 255, 255, 50.0, 0.020, 5.0)

    elseif string.lower(color) == 'amber' then
        -- Amber
        DrawLightWithRangeAndShadow(coords.x + offsetX, coords.y + offsetY, coords.z + offsetZ, 
                                    255, 194, 0, 50.0, 0.020, 5.0)
    end
end

function SetContains(set, key) return set[key] ~= nil end
