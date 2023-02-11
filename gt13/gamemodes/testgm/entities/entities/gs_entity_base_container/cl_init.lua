include("shared.lua")

function ENT:Use()
    --LocalPlayer():ChatPrint("This is not working now...")
end

function ENT:AddContextMenu() 
    local options = {}

    local button = {
        label = "Open",
        icon  = "icon16/box.png",
        click = function()
            net.Start("gs_ent_container_open")
            net.WriteEntity(self)
            net.SendToServer()
        end
    }
    table.insert(options,button)


    return options
end