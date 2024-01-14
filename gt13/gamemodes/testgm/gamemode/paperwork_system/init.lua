--[[
    в этой версии paperwork мы не будем делать какие либо действия на сервере с текстом клиента, кроме как очистка всех html тегов и 
    обработка ключевых тегов по типу [sign], [write], [time] и тд
    потому что при перекидываения текста теги типа [b][/b] весят меньше, чем <strong></strong>, а также мы убираем ненужную нагрузку с сервера
]]
include("bbc.lua")

PWork = {}

function PWork:RemoveHTMLTags(text) -- removing all <asfas> or </asdsad>
    while string.find(text, "<(%a+)>") and string.find(text, "<%/(%a+)>") do
        string.gsub(text, "<(%a+)>", "%1")
        string.gsub(text, "<%/(%a+)>", "%1")
    end

    return text
end

function PWork:Proccesing(old, new, id, ply)
    new = self:RemoveHTMLTags(new)
    new = BBCProccesing(new, BBCodeTags.paperwork_only, ply)
    
    if id == -1 then
        old = old .. new
    else
        paper.data = string.Replace(old, [[<a href="javascript:paper.luaprint(']]..id..[[')">Write</a>]], new)
    end

    return old
end


function PWork:Format(text)
    return BBCProccesing(text, BBCodeTags.all)
end
