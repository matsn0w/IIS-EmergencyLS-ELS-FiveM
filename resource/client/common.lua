function GetCurrentVehicle ()
    local ped = GetPlayerPed(-1)
    return GetVehiclePedIsUsing(ped)
end
