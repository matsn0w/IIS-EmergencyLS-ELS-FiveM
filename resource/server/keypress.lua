RegisterServerEvent('MISS-ELS:setSirenState')
AddEventHandler('MISS-ELS:setSirenState', function(state)
    TriggerClientEvent('MISS-ELS:updateSiren', -1, source, state)
end)

RegisterServerEvent('MISS-ELS:toggleHorn')
AddEventHandler('MISS-ELS:toggleHorn', function(state)
    TriggerClientEvent('MISS-ELS:updateHorn', -1, source, state)
end)

RegisterNetEvent('MISS-ELS:sv_Indicator')
AddEventHandler('MISS-ELS:sv_Indicator', function(direction, toggle)
    TriggerClientEvent('MISS-ELS:updateIndicators', source, direction, toggle)
end)
