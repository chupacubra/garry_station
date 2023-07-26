MAP = {}

include("ent_config.lua")
include("keydoor_list.lua")
include("loot_config.lua")
include("spec_map_items.lua")
include("zone_config.lua")
include("hammer_function.lua")

--[[
function MAP:Init()
  
end

function MAP:PrestartSpawnEntitys()

end
--]]

function MAP:KeyDoorListInit()
    for k, v in pairs(MAP.keydoor_list) do
        MAP.keydoor_list[k]["status"] = {0}
    end 
end

function MAP:GetExamineEntity(entity, context_type)
    if context_type == "keypad" then
        return {
            "keypad",
            "need access to open"
        }
    elseif context_type == "button" then
        return {
            "button",
            "it's a red?"
        }
    end
end