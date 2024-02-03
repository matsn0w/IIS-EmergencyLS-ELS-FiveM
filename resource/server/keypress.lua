RegisterServerEvent('kjELS:setSirenState')

AddEventHandler('kjELS:setSirenState', function(state)

    TriggerClientEvent('kjELS:updateSiren', -1, source, state)

end)



RegisterServerEvent('kjELS:toggleHorn')

AddEventHandler('kjELS:toggleHorn', function(state)

    TriggerClientEvent('kjELS:updateHorn', -1, source, state)

end)



RegisterNetEvent('kjELS:sv_Indicator')

AddEventHandler('kjELS:sv_Indicator', function(direction, toggle)

    TriggerClientEvent('kjELS:updateIndicators', source, direction, toggle)

end)

