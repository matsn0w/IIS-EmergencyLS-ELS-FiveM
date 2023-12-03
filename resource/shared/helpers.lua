--- @param type string The type of debug message
local function GetDebugVariant (type)
    local variant = { text = '', color = PrintColors.WHITE }

    if type == DebugType.INFO then
        variant = { text = 'INFO: ', color = PrintColors.CYAN }
    elseif type == DebugType.WARNING then
        variant = { text = 'WARNING: ', color = PrintColors.YELLOW }
    elseif type == DebugType.ERROR then
        variant = { text = 'ERROR: ', color = PrintColors.RED }
    elseif type == DebugType.SUCCESS then
        variant = { text = 'SUCCESS: ', color = PrintColors.GREEN }
    else
        Debug.warning('Unknown debug type \'' .. type .. '\'')
    end

    return variant
end

function Print (message, color)
    if not color then color = PrintColors.WHITE end

    print(color .. message .. PrintColors.WHITE)
end

--- Print a debug message to the console.
--- @param type DebugType The type of debug message
--- @param message string The message to print
local function debug (type, message)
    if not Config.Debug then return end

    local debugVariant = GetDebugVariant(type)

    Print(debugVariant.text .. message, debugVariant.color)
end

Debug = {
    --- @param message string The message to print
    info = function (message) debug(DebugType.INFO, message) end,

    --- @param message string The message to print
    warning = function (message) debug(DebugType.WARNING, message) end,

    --- @param message string The message to print
    success = function (message) debug(DebugType.SUCCESS, message) end,

    --- @param message string The message to print
    error = function (message) debug(DebugType.ERROR, message) end,
}

--- Print contents of `table`, with indentation.
--- @param table table The table to print
--- @param indent? number The initial level of indentation (used for recursive printing, do not provide yourself)
--- source: https://gist.github.com/ripter/4270799
function PrintTable (table, indent)
    if not indent then indent = 0 end
    
    if indent == 0 then Print('----- START TABLE -----') end

    for k, v in pairs(table) do
        local formatting = string.rep('  ', indent) .. k .. ': '
        
        if type(v) == 'table' then
            Print(formatting)
            PrintTable(v, indent + 1)
        elseif type(v) == 'boolean' then
            Print(formatting .. tostring(v))
        else
            Print(formatting .. v)
        end
    end

    if indent == 0 then Print('----- END TABLE -----') end
end

function GetResourceVersion ()
    return GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
end

--- @param vehicle number The vehicle to check
function PedIsDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

--- @param vehicle number The vehicle to check
function CanControlSirens(vehicle)
    -- driver can always control the sirens
    if PedIsDriver(vehicle) then return true end

    -- either true or false based on the config value
    return Config.AllowPassengers
end

--- @param stage string The stage to convert
function ConvertStageToPattern(stage)
    local pattern = stage

    -- yeah...
    if stage == 'secondary' then pattern = 'rearreds'
    elseif stage == 'warning' then pattern = 'secondary' end

    return pattern
end

--- Whether the player can control ELS on the current vehicle
function CanControlELS()
    if not VcfData then
        -- wait for the data to load
        while not VcfData do Citizen.Wait(0) end
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- player must be in a vehicle
    if not IsPedInAnyVehicle(ped, false) then return false end

    -- player must be in an ELS vehicle
    if not IsElsVehicle(vehicle) then return false end

    -- player must be in a position to control the sirens
    if not CanControlSirens(vehicle) then return false end

    return true
end

function ConvertMiscNameToId(misc)
    return MISCS[string.upper(misc)]
end

function ConvertMiscIdToName(misc)
    for k, v in pairs(MISCS) do
        if v == misc then return string.lower(k) end
    end
end

function IsVehicleMiscTurnedOn(vehicle, misc)
    return GetVehicleMod(vehicle, misc) == -1
end

function DoesMiscExist(vehicle, misc)
    return GetNumVehicleMods(vehicle, misc) > 0
end
