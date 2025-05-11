if SERVER then
    AddCSLuaFile("stamps.lua")
    AddCSLuaFile("bbc.lua")
    AddCSLuaFile("cl_derma.lua")
end

include("stamps.lua")
include("bbc.lua")
include("cl_derma.lua")

PWork = {}

/*
Tags img, youtube for admins fun only
*/

function PWork:RemoveHTMLTags(text)
    while string.find(text, "<(%a+)>") and string.find(text, "<%/(%a+)>") do
        string.gsub(text, "<(%a+)>", "&lt;%1&gt;")
        string.gsub(text, "<%/(%a+)>", "&lt;&frasl;%1&gt;")
    end

    return text
end

function PWork:Proccesing(old, new, id, ply)

    new = self:RemoveHTMLTags(new)
    new = BBCProccesing(new, "proccesing", ply)

    if id == "-1" then
        old = old .. new
    else
        old = string.Replace(old, [[<a href="javascript:paper.luaprint(']]..id..[[')">Write</a>]], new)
    end

    return old
end

function PWork:AddAdminText(old, new, id, ply)
    -- insert VIDEO, IMAGE in paper (magic)
end

function PWork:Format(text, ply)
    return BBCProccesing(text, "all", ply)
end
