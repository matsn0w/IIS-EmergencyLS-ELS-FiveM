-- whether a set contains a given key
function SetContains(set, key) return set[key] ~= nil end

-- whether a table contains a given value
function TableHasValue(table, value)
    for i, v in pairs(table) do
        if v == value then return true end
    end

    return false
end

-- custom iterator function
-- source: https://stackoverflow.com/a/15706820/6390292
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function GetCarHash(car)
    if not car then return false end

    for k, v in pairs(kjxmlData) do
        if GetEntityModel(car) == GetHashKey(k) and v.extras ~= nil then return k end
    end

    return false
end

function AddVehicleToTable(vehicle)
    kjEnabledVehicles[vehicle] = {
        primary = false,
        secondary = false,
        warning = false,
        siren = 0,
        sound = nil,
        highBeamEnabled = true,
    }
    --Make sure every extra is turned off when they spawn!
    TriggerEvent('kjELS:resetExtras', vehicle)
    TriggerEvent('kjELS:resetMiscs', vehicle)
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
    if not kjxmlData then
        -- wait for the data to load
        while not kjxmlData do Citizen.Wait(0) end
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    -- player must be in a vehicle
    if not IsPedInAnyVehicle(ped, false) then return false end

    -- player must be in an ELS vehicle
    if not IsELSVehicle(vehicle) then return false end

    -- player must be in a position to control the sirens
    if not CanControlSirens(vehicle) then return false end

    return true
end

-- source: https://docs.fivem.net/natives/?_0x6AF0636DDEDCB6DD
local VMT = {
    SPOILER = 0,
    BUMPER_F = 1,
    BUMPER_R = 2,
    SKIRT = 3,
    EXHAUST = 4,
    CHASSIS = 5,
    GRILL = 6,
    BONNET = 7,
    WING_L = 8,
    WING_R = 9,
    ROOF = 10,
    ENGINE = 11,
    BRAKES = 12,
    GEARBOX = 13,
    HORN = 14,
    SUSPENSION = 15,
    ARMOUR = 16,
    NITROUS = 17,
    TURBO = 18,
    SUBWOOFER = 19,
    TYRE_SMOKE = 20,
    HYDRAULICS = 21,
    XENON_LIGHTS = 22,
    WHEELS = 23,
    WHEELS_REAR_OR_HYDRAULICS = 24,
    PLTHOLDER = 25,
    PLTVANITY = 26,
    INTERIOR1 = 27,
    INTERIOR2 = 28,
    INTERIOR3 = 29,
    INTERIOR4 = 30,
    INTERIOR5 = 31,
    SEATS = 32,
    STEERING = 33,
    KNOB = 34,
    PLAQUE = 35,
    ICE = 36,
    TRUNK = 37,
    HYDRO = 38,
    ENGINEBAY1 = 39,
    ENGINEBAY2 = 40,
    ENGINEBAY3 = 41,
    CHASSIS2 = 42,
    CHASSIS3 = 43,
    CHASSIS4 = 44,
    CHASSIS5 = 45,
    DOOR_L = 46,
    DOOR_R = 47,
    LIVERY_MOD = 48,
    LIGHTBAR = 49,
}

local miscs = {
    A = VMT.SPOILER,
    B = VMT.BUMPER_F,
    C = VMT.BUMPER_R,
    D = VMT.SKIRT,
    E = VMT.EXHAUST,
    F = VMT.CHASSIS,
    G = VMT.GRILL,
    H = VMT.BONNET,
    I = VMT.WING_L,
    J = VMT.WING_R,
    K = VMT.ROOF,
    L = VMT.PLTHOLDER,
    M = VMT.PLTVANITY,
    N = VMT.INTERIOR1,
    O = VMT.INTERIOR2,
    P = VMT.INTERIOR3,
    Q = VMT.INTERIOR4,
    R = VMT.INTERIOR5,
    S = VMT.SEATS,
    T = VMT.STEERING,
    U = VMT.KNOB,
    V = VMT.PLAQUE,
    W = VMT.ICE,
    X = VMT.TRUNK,
    Y = VMT.HYDRO,
    Z = VMT.ENGINEBAY1,
}

function ConvertMiscNameToId(misc)
    return miscs[string.upper(misc)]
end

function ConvertMiscIdToName(misc)
    for k, v in pairs(miscs) do
        if v == misc then return string.lower(k) end
    end
end

function IsVehicleMiscTurnedOn(vehicle, misc)
    return GetVehicleMod(vehicle, misc) == -1
end

function DoesMiscExist(vehicle, misc)
    return GetNumVehicleMods(vehicle, misc) > 0
end
