Access = {}

// access testing lib

local Access_list = {
    "no_access",       
    "interior_0",      
    "interior_1",      
    "interior_2",      
    "service",
    "medical",
    "engineer",
    "science",
    "security",
    "director",
}

local flags = {}
local invert_flag = {}

for i = 1, #Access_list do
    local id = Access_list[i]
    local flag =  2 ^ (i-1)       // no_access = 0, interior_0 = 1, interior_1 = 2, interior_2 = 4 ... 

    flags[id] = flag
    invert_flag[flag] = id
end

function Access.Can(pad, key)
    return bit.band(pad, key) == pad
end

function Access.Add(key, flag)
    return bit.bor(key, flag)
end

function Access.Remove(key, flag)
    return bit.bxor(key, flag)
end

-- Access.New({"interior_0", "interior_1", "interior_2", "service"})
function Access.Set(access_list)
    local key = 0
    for _, id in ipairs(access_list) do
        key = key + (flags[id] or 0)
    end

    return key
end

function Access.GetList(key)
    local access_list = {}
    for flag, id in pairs(invert_flag) do
        if bit.band(flag, key) == pad then
            table.insert(access_list, id)
        end
    end
end

function Access.Have(key, id)
    local flag = flags[id]
    if !flag then return false end
    return Access.Can(flag, key)
end
