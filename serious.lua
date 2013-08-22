
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
