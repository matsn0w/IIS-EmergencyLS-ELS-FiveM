kjxmlData = {}

AddEventHandler('onResourceStart', function(name)
    if name:lower() == GetCurrentResourceName():lower() then
        for i = 1, #Config.ELSFiles do
            local data = LoadResourceFile(GetCurrentResourceName(),
                                          "xmlFiles/" .. Config.ELSFiles[i])

            if data then parseObjSet(data, Config.ELSFiles[i]) end
        end

        TriggerClientEvent("kjELS:sendELSInformation", -1, kjxmlData)
    end
end)

RegisterServerEvent("kjELS:requestELSInformation")

AddEventHandler("kjELS:requestELSInformation", function()
    TriggerClientEvent("kjELS:sendELSInformation", source, kjxmlData)
end)

function parseObjSet(data, fileName)
    local xml = SLAXML:dom(data, fileName)
    if xml and xml.root then
        if xml.root.name == "vcfroot" then parseVehData(xml, fileName) end
    end
end

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(veh, seat, name)
    TriggerClientEvent('kjELS:initVehicle', source)
end)

function sendToDiscord(color, name, message, footer)
    local embed = {
        {
            ["color"] = color,
            ["title"] = "",
            ["description"] = message,
            ["footer"] = {["text"] = footer}
        }
    }

    PerformHttpRequest(
        'https://discordapp.com/api/webhooks/773656962746417202/czAx1DxypRUuutdykxiOCrK6k_0nSHe4i5BxD2VaDWirg_wlKbOR6LJnfRSkXlDfRTaK',
        function(err, text, headers) end, 'POST',
        json.encode({username = name, embeds = embed}),
        {['Content-Type'] = 'application/json'})
end
