local PLAYER = FindMetaTable("Player")

function EquipmentActionMenu(ply)
    local function UpdateMenu()
        -- restart
    end

    local function GetItem(typ, id) -- typ
        net.Start("get item")
        net.WriteUInt(typ-1, 3)
        net.WriteUInt(id, 5)
        net.SendToServer()
    end

    -- additional buttons:
    --      wear ply item from hand
    --      put on hand/give swep
    --      put on pocket item from hand
end

function PLAYER:GetContextMenu()
    --[[
        return buttons:
            examine -- basic information
            examine_equipments -- examine our stuff
            examine_body -- info about hurts
            open_eq_menu -- for robbing in our yeys
    ]]

    local buttons = {}

    table.insert(buttons, {
        label = "Examine",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_cl_actions_human")
            net.WriteUInt(S_EXAMINE,3)
            net.WriteEntity(self)
            net.SendToServer()
        end
    })

    table.insert(buttons, {
        label = "Examine equipment",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_cl_actions_human")
            net.WriteUInt(s_EXAMINE_EQ,3)
            net.WriteEntity(self)
            net.SendToServer()
        end
    })

    table.insert(buttons, {
        label = "Examine body",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_cl_actions_human")
            net.WriteUInt(S_EXAMINE_BD,3)
            net.WriteEntity(self)
            net.SendToServer()
        end
    })

    table.insert(buttons, {
        label = "Action with equipments",
        icon  = "icon16/eye.png",
        click = function()
            EquipmentActionMenu(ply)
        end
    })

    return buttons
end