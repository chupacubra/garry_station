CL_GS_Corpse = {}
--[[
    get CORPSE from server

    actions = 
        0 - ligth examine 
        1 - examine equipment
        2 - examine body (hp)
        3 - drop equip corpse
]]
--[[
function CL_GS_Corpse.MakeClientCoprse(rag)
    rag.corpse  = true
end
--]]

function CL_GS_Corpse.GetContextMenu(rag)
    local contextButton = {}

    local button = {
        label = "Examine corpse",
        icon  = "icon16/eye.png",
        click = function()
            CL_GS_Corpse.ExamineCoprse(rag)
        end
    }
    table.insert(contextButton, button)

    return contextButton
end

function CL_GS_Corpse.DrawMenu(pos, buttons)
    local Menu = DermaMenu()
            
    Menu:SetPos(pos.x, pos.y)

    for k,v in pairs(buttons) do
        local button = Menu:AddOption(v.label)
        button:SetIcon(v.icon)
        button.DoClick = v.click
    end
end

function CL_GS_Corpse.ExamineCoprse(rag)
    net.Start("gs_sys_corpse_action")
    net.WriteEntity(rag)
    net.WriteUInt(0, 4)
    net.WriteUInt(0, 4)
    net.SendToServer()
end

net.Receive("gs_sys_corpse_create",function()
    local rag   = net.ReadEntity()

    CL_GS_Corpse.MakeClientCoprse(rag)
end)

net.Receive("gs_sys_corpse_action", function()
    local rag = net.ReadEntity()

    local cntx = CL_GS_Corpse.GetContextMenu(rag)
    CL_GS_Corpse.DrawMenu(rag:GetPos():ToScreen(), cntx)
end)

