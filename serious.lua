
-- Simple Lua code for parsing XML adapted from
-- http://lua-users.org/wiki/LuaXml

-- Heavily modified to store:
-- elem[0] = name
-- elem[-1] = text
-- elem.att_name = att_value
-- elem[N] = child elem N

local function elem(name, atts)
    local elem = { [0]=name }
    string.gsub(atts, '(%w+)=(["\'])(.-)%2', function(k, _, v)
            elem[k] = tonumber(v) or v
        end)
    return elem
end

function parseXML(s)
    local stack = {}
    local top = {}
    table.insert(stack, top)
    local ni, c, name, atts, empty
    local i, j = 1, 1
    while true do
        ni, j, c, name, atts, empty = string.find(s, '<(%/?)([%w:]+)(.-)(%/?)>', i)
        if not ni then break end
        local text = string.sub(s, i, ni-1)
        if not string.find(text, '^%s*$') then
            top[-1] = (top[-1] or '') .. text
        end
        if empty == '/' then  -- empty element tag
            table.insert(top, elem(name, atts))
        elseif c == '' then  -- start tag
            top = elem(name, atts)
            table.insert(stack, top)  -- new level
        else  -- end tag
            local toclose = table.remove(stack)  -- remove top
            top = stack[#stack]
            if #stack < 1 then
                error('nothing to close with ' .. name)
            end
            if toclose[0] ~= name then
                error('trying to close ' .. toclose[0] .. ' with ' .. name)
            end
            toclose[-1] = tonumber(toclose[-1]) or toclose[-1]
            table.insert(top, toclose)
        end
        i = j+1
    end
    local text = string.sub(s, i)
    if not string.find(text, '^%s*$') then
        stack[#stack] = (stack[#stack] or '') .. text
    end
    if #stack > 1 then
        error('unclosed ' .. stack[#stack][0])
    end
    return stack[1]
end

-- write out a Lua object model that was parsed from XML

local function value(s)
    return type(s) == 'string' and ("'" .. s .. "'") or s
end

function export(file, t, level)
    if not level then
        file:write('return ')
        level = 0
    end
    local sep = ''
    file:write(string.format("%s{", string.rep('    ', level)))
    if t[0] then
        file:write(string.format(' [0]=%s', value(t[0])))
        sep = ','
    end
    for k, v in pairs(t) do
        if type(k) == 'string' then
            file:write(string.format('%s %s=%s', sep, k, value(v)))
            sep = ','
        end
    end
    if t[-1] then
        file:write(string.format('%s [-1]=%s', sep, value(t[-1])))
    end

    if #t ~= 0 then
        for i = 1, #t do
            file:write(sep, '\n')
            sep = ','
            export(file, t[i], level+1)
        end
        file:write(string.format('\n%s}', string.rep('    ', level)))
    else
        file:write(' }')
    end
    if level == 0 then
        file:write('\n')
    end
end
