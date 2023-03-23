local PLAYER = FindMetaTable("Player")

function PLAYER:GetContextMenu()
    --[[
        return buttons:
            examine -- basic information
            examine_equipments -- for robbing in our yeys
            examine_body -- info about hurts
            grab?
    ]]

    local buttons = {}

    table.insert(buttons, {
        label = "Examine",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_cl_actions_human")
            net.WriteUInt(1,3) -- simple examine
            net.WriteEntity(self)
            net.SendToServer()
        end
    })

    return buttons
end