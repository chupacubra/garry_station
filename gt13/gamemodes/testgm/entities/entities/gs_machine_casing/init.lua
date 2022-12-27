AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_junk/wood_crate001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetExamine({name = "machine empty case", desc = "something is missing"})
    self:Breakable(100)
    self.parts = {}
end

function ENT:InsertItem()

end

function ENT:Use()

end