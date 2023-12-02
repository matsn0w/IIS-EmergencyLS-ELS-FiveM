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

--- source: http://lua-users.org/wiki/CopyTable
--- @param orig table
function deepcopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end
