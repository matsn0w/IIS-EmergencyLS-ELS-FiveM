 function GetDebugVariant (type)
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

function Print (message, color)
    if not color then color = Colors.WHITE end

    print(color .. message .. Colors.WHITE)
end

function Debug (type, message)
    if not Config.Debug then return end

    local debug = GetDebugVariant(type)

    Print(debug.text .. message, debug.color)
end

-- whether a table contains a given value
function ArrayContains(table, value)
    for _, v in ipairs(table) do
        if v == value then return true end
    end

    return false
end


-- Print contents of `table`, with indentation.
-- `indent` sets the initial level of indentation.
-- Source: https://gist.github.com/ripter/4270799
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
