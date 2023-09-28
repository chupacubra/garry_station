include("shared.lua")

function ENT:AddContextMenu()
    local opt = {}

    local button = {
        label = "Examine parts",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_ent_mc_exam_parts")
            net.WriteEntity(self)
            net.SendToServer()
        end
    }
    table.insert(opt, button)

    return opt
end

function ENT:OpenGUI()

end

function ENT:Use()
    self:ConnectPly()

    self:OpenGUI()
end