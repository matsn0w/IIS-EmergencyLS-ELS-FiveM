--- Client event to toggle a MISC on a vehicle
RegisterNetEvent('MISS-ELS:toggleMisc')
AddEventHandler('MISS-ELS:toggleMisc', function(netVehicle, misc)
    --- Toggle MISC on vehicle
    toggleMisc(netVehicle, misc)
end)

RegisterNetEvent('MISS-ELS:toggleExtra')
AddEventHandler('MISS-ELS:toggleExtra', function(netVehicle, extra)
    toggleExtra(netVehicle, extra)
end)

RegisterNetEvent('MISS-ELS:toggleIndicators')
AddEventHandler('MISS-ELS:toggleIndicators', function(netVehicle, type)
    --- If indicators are not enabled, we do not execute any code.
    if not indicatorsEnabled() then return end

    local vehicle = netToVeh(netVehicle)

    if not vehicle or not type then return end

    --- Toggle the requested indicators
    toggleIndicators()
    
end)