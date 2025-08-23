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