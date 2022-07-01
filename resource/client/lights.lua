function ToggleExtra (extraId)
    local vehicle = GetCurrentVehicle()

    if vehicle == 0 then
        Debug('warning', 'Player is not in a vehicle')
        return
    end

    if not DoesExtraExist(vehicle, extraId) then
        Print('Extra ' .. extraId .. ' does not exist on this vehicle', Colors.YELLOW)
        return
    end

    -- see if the extra is currently on or off
    local toggle = IsVehicleExtraTurnedOn(vehicle, extraId)

    -- disable auto repairs
    SetVehicleAutoRepairDisabled(vehicle, true)

    -- toggle the extra
    SetVehicleExtra(vehicle, extraId, toggle)

    Debug('info', 'Toggled extra ' .. tostring(extraId))
end
