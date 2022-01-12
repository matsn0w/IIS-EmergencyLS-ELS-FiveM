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
