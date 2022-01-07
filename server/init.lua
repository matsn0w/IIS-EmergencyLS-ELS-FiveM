kjxmlData = {}

function ParseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root and xml.root.name == 'vcfroot' then ParseVCF(xml, fileName) end
end

AddEventHandler('onResourceStart', function(name)
    if not Config then
        error('You probably forgot to copy the example configuration file. Please see the installation instructions for further details.')
        StopResource(GetCurrentResourceName())
        CancelEvent()
        return
    end

    if name:lower() ~= GetCurrentResourceName():lower() then
        CancelEvent()
        return
    end

    for i = 1, #Config.ELSFiles do
        local data = LoadResourceFile(GetCurrentResourceName(), 'xmlFiles/' .. Config.ELSFiles[i])

        if data then ParseObjSet(data, Config.ELSFiles[i])
        else print('VCF file not found: ' .. Config.ELSFiles[i]) end
    end

    -- send the ELS data to all clients
    TriggerClientEvent('kjELS:sendELSInformation', -1, kjxmlData)
end)

RegisterServerEvent('kjELS:requestELSInformation')
AddEventHandler('kjELS:requestELSInformation', function()
    TriggerClientEvent('kjELS:sendELSInformation', source, kjxmlData)
end)

RegisterNetEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(veh, seat, name)
    TriggerClientEvent('kjELS:initVehicle', source)
end)
