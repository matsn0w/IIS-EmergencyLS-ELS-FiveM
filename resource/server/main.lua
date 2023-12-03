--- Global storage of all VCF data
VcfData = {}

--- Default state of a vehicle
local defaultState = {
    stages = {
        primary = false,
        secondary = false,
        rearreds = false,
    },
    siren = 0,
    sound = nil,
    horn = false,
    indicators = {
        left = false,
        right = false,
        hazard = false,
    },
}

RegisterServerEvent('MISS-ELS:server:requestElsInformation')
AddEventHandler('MISS-ELS:server:requestElsInformation', function()
    TriggerClientEvent('MISS-ELS:client:sendElsInformation', source, VcfData)
end)

--- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
--- ┃      OneSync Compatability       ┃
--- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

--- A table of all registered ELS vehicles
local registeredElsVehicles = {}

--- Check if the vehicle is currently registered as ELS vehicle
--- @param netVehicle number
--- @return boolean
local function isElsVehicleRegistered(netVehicle)
    return registeredElsVehicles[netVehicle] ~= nil
end

--- Register the vehicle as ELS vehicle
--- @param netVehicle number
local function registerElsVehicle(netVehicle)
    registeredElsVehicles[netVehicle] = deepcopy(defaultState)
end

RegisterNetEvent('MISS-ELS:server:requestState')
--- Allow to get the vehicle state
--- @param netVehicle number
AddEventHandler('MISS-ELS:server:requestState', function(netVehicle)
    TriggerClientEvent('MISS-ELS:client:updateState', source, netVehicle, registeredElsVehicles[netVehicle])
end)

RegisterNetEvent('MISS-ELS:server:enteredVehicle')
--- Register the vehicle as ELS vehicles
--- @param netVehicle number
AddEventHandler('MISS-ELS:server:enteredVehicle', function(netVehicle)
    
    TriggerClientEvent('MISS-ELS:client:registerVehicle', -1, netVehicle)

    if isElsVehicleRegistered(netVehicle) then return end

    registerElsVehicle(netVehicle)
end)

--- Reset the state of the vehicle
--- @param netVehicle number
function ResetState(netVehicle)
    registeredElsVehicles[netVehicle] = deepcopy(defaultState)

    TriggerClientEvent('MISS-ELS:client:updateState', -1, netVehicle, registeredElsVehicles[netVehicle])
end

RegisterNetEvent('MISS-ELS:server:toggleSiren')
--- Toggle the siren of the vehicle
--- @param netVehicle number
AddEventHandler('MISS-ELS:server:toggleSiren', function(netVehicle, status, sound)
    if not registeredElsVehicles[netVehicle] then
        Debug.warning('Vehicle ' .. netVehicle .. ' is not registered as ELS vehicle')
        return
    end

    registeredElsVehicles[netVehicle].siren = status
    registeredElsVehicles[netVehicle].sound = sound

    TriggerClientEvent('MISS-ELS:client:updateState', -1, netVehicle, registeredElsVehicles[netVehicle])
end)

RegisterNetEvent('MISS-ELS:server:toggleIndicator')
--- Toggle the indicators of the vehicle
--- @param netVehicle number
AddEventHandler('MISS-ELS:server:toggleIndicator', function(netVehicle, indicator)
    if not registeredElsVehicles[netVehicle] then
        Debug.warning('Vehicle ' .. netVehicle .. ' is not registered as ELS vehicle')
        return
    end

    for k, v in pairs(registeredElsVehicles[netVehicle].indicators) do
        if k == indicator then
            registeredElsVehicles[netVehicle].indicators[k] = not v
        else
            registeredElsVehicles[netVehicle].indicators[k] = false
        end
    end

    Debug.info('MISS-ELS:client:updateState: Toggling indicator on vehicle ' .. netVehicle)
    TriggerClientEvent('MISS-ELS:client:updateState', -1, netVehicle, registeredElsVehicles[netVehicle])
end)

RegisterNetEvent('MISS-ELS:server:horn')
--- Toggle the horn of the vehicle
--- @param netVehicle number
AddEventHandler('MISS-ELS:server:horn', function(netVehicle, pressed)
    if not registeredElsVehicles[netVehicle] then
        return
    end

    if pressed then
        if not (registeredElsVehicles[netVehicle].siren > 0) then
            return
        end

        if registeredElsVehicles[netVehicle].siren ~= 2 then
            registeredElsVehicles[netVehicle].siren = 2
            goto continue
        end

        if registeredElsVehicles[netVehicle].siren == 2 then
            registeredElsVehicles[netVehicle].siren = 1
            goto continue
        end
    end

    ::continue::

    TriggerClientEvent('MISS-ELS:client:updateState', -1, netVehicle, registeredElsVehicles[netVehicle])
end)

RegisterNetEvent('MISS-ELS:server:toggleLightStage')
--- Toggle lights tage(s) on the vehicle
--- @param netVehicle number
--- @param lightStages table
AddEventHandler('MISS-ELS:server:toggleLightStage', function(netVehicle, lightStages)
    if not registeredElsVehicles[netVehicle] then
        Debug.warning('Tried to toggle light stage(s) on vehicle, but vehicle is not registered')
        return
    end

    Debug.info('Toggling light stage(s) on vehicle')

    -- Loop over the light stages of the vehicle, and toggle them according to the light stages suppplied by the client
    for k, v in pairs(registeredElsVehicles[netVehicle].stages) do
        -- If the light stage is in the list of light stages, then toggle it
        if lightStages[k] then
            registeredElsVehicles[netVehicle].stages[k] = not v
        -- Else it should be turned off
        else
            registeredElsVehicles[netVehicle].stages[k] = false
        end
    end

    TriggerClientEvent('MISS-ELS:client:updateState', -1, netVehicle, registeredElsVehicles[netVehicle])
end)
