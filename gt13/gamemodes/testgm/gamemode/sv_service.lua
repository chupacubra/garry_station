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