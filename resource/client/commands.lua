RegisterNetEvent('MISS-ELS:toggleExtra')
AddEventHandler('MISS-ELS:toggleExtra', function(vehicle, extra)
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

    TriggerEvent('MISS-ELS:toggleExtra', vehicle, extra)
end)

RegisterNetEvent('MISS-ELS:toggleMisc')
AddEventHandler('MISS-ELS:toggleMisc', function(vehicle, misc)
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

    TriggerEvent('MISS-ELS:toggleMisc', vehicle, ConvertMiscNameToId(misc))
end)
