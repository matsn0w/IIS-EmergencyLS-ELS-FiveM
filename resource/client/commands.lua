RegisterNetEvent('kjELS:toggleExtra')
AddEventHandler('kjELS:toggleExtra', function(vehicle, extra)
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
end)

RegisterCommand('extra', function(source, args)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then return end

    local vehicle = GetVehiclePedIsIn(ped)
    local extra = args[1] or -1

    TriggerEvent('kjELS:toggleExtra', vehicle, extra)
end)



-- Let the client configure the brightness of the lights
RegisterCommand('elsdaybrightness', function(source, args)
    local brightness = tonumber(args[1])
    local key = 'elsdaybrightness'
    if brightness then
        if math.floor(brightness) == brightness then brightness = brightness + 0.0 end --Convert to float
        SetResourceKvpFloat(key, brightness)
        SetVisualSettingFloat("car.defaultlight.day.emissive.on", brightness)
    end
end)

RegisterCommand('elsnightbrightness', function(source, args)
    local brightness = tonumber(args[1])
    local key = 'elsnightbrightness'
    if brightness then

        if math.floor(brightness) == brightness then brightness = brightness + 0.0 end --Convert to float
        SetResourceKvpFloat(key, brightness)
        SetVisualSettingFloat("car.defaultlight.night.emissive.on", brightness)
    end
end)



RegisterNetEvent('kjELS:toggleMisc')
AddEventHandler('kjELS:toggleMisc', function(vehicle, misc)
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
end)

RegisterCommand('misc', function(source, args)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then return end

    local vehicle = GetVehiclePedIsIn(ped)
    local misc = args[1] or -1

    if not string.match(misc, '%a') then
        print('Misc must be a single letter!')
        return
    end

    TriggerEvent('kjELS:toggleMisc', vehicle, ConvertMiscNameToId(misc))
end)
