local function GetDebugVariant (type)
    local variant = { text = '', color = Colors.WHITE }

    if type == DebugType.INFO then
        variant = { text = 'INFO: ', color = Colors.CYAN }
    elseif type == DebugType.WARNING then
        variant = { text = 'WARNING: ', color = Colors.YELLOW }
    elseif type == DebugType.ERROR then
        variant = { text = 'ERROR: ', color = Colors.RED }
    elseif type == DebugType.SUCCESS then
        variant = { text = 'SUCCESS: ', color = Colors.GREEN }
    else
        Debug('warning', 'Unknown debug type \'' .. type .. '\'')
    end

    return variant
end

local function Print (message, color)
    if not color then color = PrintColors.WHITE end

    print(color .. message .. PrintColors.WHITE)
end

--- @param type string The type of debug message
--- @param message string The message to print
function Debug (type, message)
    if not Config.Debug then return end

    local debug = GetDebugVariant(type)

    Print(debug.text .. message, debug.color)
end

--- Print contents of `table`, with indentation.
--- @param table table The table to print
--- @param indent number The initial level of indentation
--- source: https://gist.github.com/ripter/4270799
function PrintTable (table, indent)
    if not indent then indent = 0 end

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
end

function GetResourceVersion ()
    return GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
end

function GetCarHash(car)
    if not car then return false end

    for k, v in pairs(VcfData) do
        -- @todo: is this check still functional?
        if GetEntityModel(car) == GetHashKey(k) and v.extras ~= nil then return k end
    end

    return false
end

function IsELSVehicle(vehicle)
    return GetCarHash(vehicle) ~= false
end

function PedIsDriver(vehicle)
    return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
end

function CanControlSirens(vehicle)
    -- driver can always control the sirens
    if PedIsDriver(vehicle) then return true end

    -- either true or false based on the config value
    return Config.AllowPassengers
end


function ConvertStageToPattern(stage)
    local pattern = stage

    -- yeah...
    if stage == 'secondary' then pattern = 'rearreds'
    elseif stage == 'warning' then pattern = 'secondary' end

    return pattern
end

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
    if not IsELSVehicle(vehicle) then return false end

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
