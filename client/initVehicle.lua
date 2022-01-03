RegisterNetEvent("kjELS:initVehicle")
AddEventHandler("kjELS:initVehicle", function()
    vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if kjEnabledVehicles[vehicle] == nil then addVehicleToTable(vehicle) end
end)
