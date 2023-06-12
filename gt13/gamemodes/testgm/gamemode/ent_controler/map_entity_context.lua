map_context = {}
--[[
map_context.keypad = {
    {
        label = "Examine",
        icon = "icon16/eye.png", 
        click = function()
            net.Start("gs_map_entity_controler")
            net.WriteEntity()
        end
    },
}
--]]
function MapEntityGetContext(entity)
    net.Start("gs_map_entity_get_type")
    net.WriteEntity(entity)
    net.SendToServer()
end

function MapEntityMakeAction(entity, action)
    net.Start("gs_map_ent_action")
    net.WriteEntity(entity)
    net.WriteUInt(action, 4)
    net.SendToServer()
end

if CLIENT then
    net.Receive("gs_map_entity_get_type", function()
        --print("12312312312312313123")
        local ent = net.ReadEntity()
        local typ = net.ReadString()
        --print(ent,typ)
        local context_menu = {}

        local button = {
            label = "Examine",
            icon = "icon16/eye.png", 
            click = function()
                MapEntityMakeAction(ent, A_EXAMINE)
            end
        }

        table.insert(context_menu, button)

        if typ == "keypad" then
            local button = {
                label = "Use",
                icon = "icon16/add.png", 
                click = function()
                    MapEntityMakeAction(ent, A_USE)
                end
            }
        end

        local scrpos = ent:GetPos():ToScreen()
        local Menu = DermaMenu()
        
        Menu:SetPos(scrpos.x,scrpos.y)

        if context_menu != nil then
            for k,v in pairs(context_menu) do
                local button = Menu:AddOption(v.label)
                button:SetIcon(v.icon)
                button.DoClick = v.click
            end
        end
    end)
end