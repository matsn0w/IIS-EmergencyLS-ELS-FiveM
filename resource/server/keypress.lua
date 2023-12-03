RegisterServerEvent('MISS-ELS:server:toggleHorn')
AddEventHandler('MISS-ELS:server:toggleHorn', function(state)
    TriggerClientEvent('MISS-ELS:client:updateHorn', -1, source, state)
end)
