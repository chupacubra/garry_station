CL_GS_Corpse = {}
--[[
    get CORPSE from server

    actions = 
        0 - ligth examine 
        1 - examine equipment
        2 - examine body (hp)
        3 - drop equip corpse
]]

function CL_GS_Corpse.MakeClientCoprse(rag)
    --rag.PlayerID = ply:SteamID()
    
    --[[
        create ragdoll functions
    ]]

    rag.corpse  = true

end

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

