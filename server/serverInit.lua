kjxmlData = {}

AddEventHandler('onResourceStart', function(name)
    if name:lower() == GetCurrentResourceName():lower() then
        for i = 1, #Config.ELSFiles do
            local data = LoadResourceFile(GetCurrentResourceName(),
                                          "xmlFiles/" .. Config.ELSFiles[i])

            if data then ParseObjSet(data, Config.ELSFiles[i]) end
        end

        TriggerClientEvent("kjELS:sendELSInformation", -1, kjxmlData)
    end
end)

RegisterServerEvent("kjELS:requestELSInformation")

AddEventHandler("kjELS:requestELSInformation", function()
    TriggerClientEvent("kjELS:sendELSInformation", source, kjxmlData)
end)

function ParseObjSet(data, fileName)
    local xml = SLAXML:dom(data, fileName)
    if xml and xml.root then
        if xml.root.name == "vcfroot" then ParseVehData(xml, fileName) end
    end
end

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(veh, seat, name)
    TriggerClientEvent('kjELS:initVehicle', source)
end)
