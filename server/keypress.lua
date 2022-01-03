RegisterServerEvent("kjELS:setSirenState")

AddEventHandler("kjELS:setSirenState", function(state)
    TriggerClientEvent("kjELS:updateSiren", -1, source, state)
end)

RegisterServerEvent("kjELS:toggleHorn")

AddEventHandler("kjELS:toggleHorn", function(state)
    TriggerClientEvent("kjELS:updateHorn", -1, source, state)
end)

RegisterNetEvent("kjELS:updateStatus")

AddEventHandler("kjELS:updateStatus", function(type, status)
    TriggerClientEvent("kjELS:toggleLights", -1, source, type, status)
end)

RegisterNetEvent("kjELS:sv_Indicator")

AddEventHandler('kjELS:sv_Indicator', function(direction, toggle)
    local netID = source
    TriggerClientEvent('updateIndicators', -1, netID, direction, toggle)
end)
