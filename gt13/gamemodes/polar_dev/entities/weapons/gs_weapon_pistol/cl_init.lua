include("shared.lua") 

SWEP.PrintName        = "Tekov P9"			
SWEP.Slot		= 0
SWEP.SlotPos		= 0
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType = "pistol"
SWEP.OffsetVector = Vector(-1, -1, 0)


function SWEP:ContextSlot()
    local options = {}

    local strip = {
        label = "Eject magazine", -- if have
        icon  = "icon16/control_eject.png",
        click = function()
            self:StripMagazine()
        end,
    }
    
    table.insert(options, strip)

    local striptohand = {
        label = "Eject magazine in hand", -- if have
        icon  = "icon16/control_eject_blue.png",
        click = function()
            self:StripMagazineHand()
        end,
    }

    table.insert(options, striptohand)

    return options
end