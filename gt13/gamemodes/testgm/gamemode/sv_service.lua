function stringspacer(st, sz) -- fill string with spacers
    local st = tostring(st)
    if sz <= string.len(st) then
        return st
    end

    for i = string.len(st), sz do
        st = st .. " "
    end

    return st 
end

function RagdollGetBone(rag, hitpos)
    -- get bone from pos
    -- bone is close to pos
    if !rag then
        return
    end

end

function fixtable(tbl)
    --  from:
    --      key1 = true,
    --      key2 = true, 
    --      ...
    --  to:
    --      key1, key2, ...
    local t = {}
    for k, v in pairs(tbl) do
        table.insert(t, k)
    end
    return t
end


function getGameTimeStamp()
    -- ril lafe 2024
    -- gs13 teme 2024+28
    -- 2052-10-31 18:00:00
    local t = os.date("!*t")
    return tostring(t.year+28) .. "-" .. tostring(t.month) .. "-".. tostring(t.day) .. " " .. tostring(t.hour) ..":".. tostring(t.min) ..":".. tostring(t.sec)
end
