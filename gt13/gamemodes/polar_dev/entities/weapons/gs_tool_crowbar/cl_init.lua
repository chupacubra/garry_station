include("shared.lua")
SWEP.PrintName        = "Crowbar"
SWEP.Slot		= 0
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= false
SWEP.HoldType = "melee"
--SWEP.OffsetVector = Vector(-1, -1, 0)

function SWEP:DrawWorldModel()
    self:DrawModel()
end

