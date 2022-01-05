kjEnabledVehicles = {}
kjxmlData = nil

-- load audio banks
for _, v in ipairs(Config.AudioBanks) do RequestScriptAudioBank(v, false) end

RegisterNetEvent('kjELS:sendELSInformation')
AddEventHandler('kjELS:sendELSInformation', function(information) kjxmlData = information end)

RegisterNetEvent('kjELS:initVehicle')
AddEventHandler('kjELS:initVehicle', function()
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())

    if kjEnabledVehicles[vehicle] == nil then AddVehicleToTable(vehicle) end
end)
