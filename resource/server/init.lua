--- Global storage of all VCF data
VcfData = {}

--- The determined OS of the server
--- @type string|nil
local systemOS = nil

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

local function parseObjSet(data, fileName)
    local xml = SLAXML:dom(data)

    if xml and xml.root and xml.root.name == 'vcfroot' then ParseVCF(xml, fileName) end
end

local function checkForUpdate()
    local versionFile = LoadResourceFile(GetCurrentResourceName(), 'version.json')

    if not versionFile then
        print('Couldn\'t read version file!')
        return
    end

    local currentVersion = Semver(json.decode(versionFile)['version'] or 'unknown')

    if currentVersion.prerelease then
        print('WARNING: you are using a pre-release of MISS ELS!')
        print('>> This version might be unstable and probably contains some bugs.')
        print('>> Please report bugs and other problems via https://github.com/matsn0w/MISS-ELS/issues')
    end

    PerformHttpRequest('https://api.github.com/repos/matsn0w/MISS-ELS/releases/latest', function(status, response, headers)
        if status ~= 200 then
            print('Something went wrong! Couldn\'t fetch latest version. Status: ' .. tostring(status))
            return
        end

        local newVersion = Semver(json.decode(response)['tag_name'] or 'unknown')

        if newVersion > currentVersion then
            print('---------------------------- MISS ELS ----------------------------')
            print('--------------------- NEW VERSION AVAILABLE! ---------------------')
            print('>> You are using v' .. tostring(currentVersion))
            print('>> You can upgrade to v' .. tostring(newVersion))
            print()
            print('Download it at https://github.com/matsn0w/MISS-ELS/releases/latest')
            print('------------------------------------------------------------------')
        end
    end)
end

local function determineOS()
    local system = nil

    local unix = os.getenv('HOME')
    local windows = os.getenv('HOMEPATH')

    if unix then system = 'unix' end
    if windows then system = 'windows' end

    --- this guy probably has some custom ENV var set...
    if unix and windows then error('Couldn\'t identify the OS unambiguously.') end

    return system
end

local function scanDir(folder)
    local pathSeparator = '/'
    local command = 'ls -A'

    if systemOS == 'windows' then
        pathSeparator = '\\'
        command = 'dir /R /B'
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local directory = resourcePath .. pathSeparator .. folder
    local i, t, popen = 0, {}, io.popen
    local pfile = popen(command .. ' "' .. directory .. '"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    if #t == 0 then
        error('Couldn\'t find any VCF files. Are they in the correct directory?')
    end

    pfile:close()
    return t
end

local function loadFile(file)
    return LoadResourceFile(GetCurrentResourceName(), file)
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

    Citizen.CreateThread(function()
        checkForUpdate()
    end)

    local folder = 'xmlFiles'

    --- determine the server OS
    systemOS = determineOS()

    if not systemOS then
        error('Couldn\'t determine your OS! Are your running on steroids??')
    end

    for _, file in pairs(scanDir(folder)) do
        local data = loadFile(folder .. '/' .. file)

        if data then
            if pcall(function() parseObjSet(data, file) end) then
                --- no errors
                print('Parsed VCF for: ' .. file)
            else
                --- VCF is faulty, notify the user and continue
                print('VCF file ' .. file .. ' could not be parsed: is your XML valid?')
            end
        else
            print('VCF file ' .. file .. ' not found: does the file exist?')
        end
    end

    --- send the ELS data to all clients
    TriggerClientEvent('MISS-ELS:sendELSInformation', -1, VcfData)
end)

RegisterServerEvent('MISS-ELS:requestELSInformation')
AddEventHandler('MISS-ELS:requestELSInformation', function()
    TriggerClientEvent('MISS-ELS:sendELSInformation', source, VcfData)
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

    TriggerClientEvent('MISS-ELS:client:registerVehicle', -1, netVehicle)
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
        return
    end

    for k, v in pairs(registeredElsVehicles[netVehicle].indicators) do
        if k == indicator then
            registeredElsVehicles[netVehicle].indicators[k] = not v
        else
            registeredElsVehicles[netVehicle].indicators[k] = false
        end
    end

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
        Debug('warning', 'Tried to toggle light stage(s) on vehicle, but vehicle is not registered')
        return
    end

    Debug('info', 'Toggling light stage(s) on vehicle')

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
