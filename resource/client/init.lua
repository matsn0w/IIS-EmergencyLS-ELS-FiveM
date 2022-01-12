kjEnabledVehicles = {}
kjxmlData = nil

AddEventHandler('onClientResourceStart', function(name)
    if not Config then
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    -- load audio banks
    for _, v in ipairs(Config.AudioBanks) do RequestScriptAudioBank(v, false) end
end)

RegisterNetEvent('kjELS:sendELSInformation')
AddEventHandler('kjELS:sendELSInformation', function(information) kjxmlData = information end)

RegisterNetEvent('kjELS:initVehicle')
AddEventHandler('kjELS:initVehicle', function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
end)
