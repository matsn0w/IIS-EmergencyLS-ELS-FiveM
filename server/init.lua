kjxmlData = {}

function ParseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root and xml.root.name == 'vcfroot' then ParseVCF(xml, fileName) end
end

AddEventHandler('onResourceStart', function(name)
    if name:lower() == GetCurrentResourceName():lower() then
        for i = 1, #Config.ELSFiles do
            local data = LoadResourceFile(GetCurrentResourceName(), 'xmlFiles/' .. Config.ELSFiles[i])

            if data then ParseObjSet(data, Config.ELSFiles[i]) end
        end

        -- send the ELS data to all clients
        TriggerClientEvent('kjELS:sendELSInformation', -1, kjxmlData)
    end
end)

RegisterServerEvent('kjELS:requestELSInformation')
AddEventHandler('kjELS:requestELSInformation', function()
    TriggerClientEvent('kjELS:sendELSInformation', source, kjxmlData)
end)

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(veh, seat, name)
    TriggerClientEvent('kjELS:initVehicle', source)
end)
