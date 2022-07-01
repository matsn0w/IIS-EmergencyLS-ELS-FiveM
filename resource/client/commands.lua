RegisterCommand('extra', function (source, args)
    local ped = GetPlayerPed(-1)
    if not IsPedInAnyVehicle(ped) then return end

    local extraId = args[1] or -1
    extraId = tonumber(extraId) or -1

    ToggleExtra(extraId)
end)
