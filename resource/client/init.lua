ElsEnabledVehicles = {}

ElsxmlData = nil



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



RegisterNetEvent('MISS-ELS:sendELSInformation')

AddEventHandler('MISS-ELS:sendELSInformation', function(information) kjxmlData = information end)



RegisterNetEvent('MISS-ELS:initVehicle')

AddEventHandler('MISS-ELS:initVehicle', function()

    local vehicle = GetVehiclePedIsUsing(PlayerPedId())



    if ElsEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end

end)

