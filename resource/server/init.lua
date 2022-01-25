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
        local file = Config.ELSFiles[i]
        local data = LoadResourceFile(GetCurrentResourceName(), 'xmlFiles/' .. file)

        if data then
            if pcall(function() ParseObjSet(data, file) end) then
                -- no errors
                print('Parsed VCF for: ' .. file)
            else
                -- VCF is faulty, notify the user and continue
                print('VCF file ' .. file .. ' could not be parsed: is your XML valid?')
            end
        else
            print('VCF file ' .. file .. ' not found: does the file exist?')
        end
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
