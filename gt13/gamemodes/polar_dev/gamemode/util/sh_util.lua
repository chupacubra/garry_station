function util.FindCloserEntsAndRun(radius, func)
    for k, ent in pairs(ents.FindInSphere(radius)) do
        func(ent)
    end
end

function util.FindCloserPlysAndRun(radius, func)
    for k, ply in pairs(ents.FindInSphere(radius)) do
        if !ply:IsPlayer() then continue end
        func(ply)
    end
end

function util.getGameTimeStamp()
    -- ril lafe 2024
    -- gs13 teme 2024+28
    -- 2052-10-31 18:00:00
    local t = os.date("!*t")
    return tostring(t.year+28) .. "-" .. tostring(t.month) .. "-".. tostring(t.day) .. " " .. tostring(t.hour) ..":".. tostring(t.min) ..":".. tostring(t.sec)
end

function util.TableMul(value, count)
    local tbl = {}
    for i = 1, count do
        table.insert(tbl, value)
    end
    return tbl
end

function util.TableToHash(tbl)
    if type(tbl) ~= "table" then
        error("TableToHash ожидает таблицу в качестве аргумента", 2)
    end
    
    local sortedKeys = {}

    for k in pairs(tbl) do
        table.insert(sortedKeys, k)
    end
    
    table.sort(sortedKeys, function(a, b)
        local typeA, typeB = type(a), type(b)

        if typeA ~= typeB then
            return tostring(typeA) < tostring(typeB)
        end
        
        if typeA == "number" then
            return a < b
        elseif typeA == "string" then
            return a < b
        elseif typeA == "boolean" then
            return tostring(a) < tostring(b)
        else
            return tostring(a) < tostring(b)
        end
    end)
    
    local hash = ""

    for _, key in ipairs(sortedKeys) do
        local value = tbl[key]
        local keyType = type(key)
        local valueType = type(value)
        
        hash = hash .. "[" .. keyType .. ":" .. tostring(key) .. "]"
        
        if valueType == "table" then
            hash = hash .. "=" .. TableToHash(value)
        else
            hash = hash .. "=" .. valueType .. ":" .. tostring(value)
        end
        
        hash = hash .. ";"
    end
    
    return util.CRC(hash)
end