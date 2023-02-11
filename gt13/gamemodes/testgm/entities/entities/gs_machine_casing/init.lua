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

    self:SetMaterial("phoenix_storms/metalfloor_2-3")
    self:SetExamine({name = "machine empty case", desc = "something is missing"})
    self.parts = {}
    self.board = false
end



--[[
function ENT:Wrench(ply)
    --ply:ChatPrint("You don't know...")
end
--]]
--[[
]]

function ENT:Screwdriver(ply)

end

function ENT:Crowbar(ply)
    self:EjectItem()
end

function ENT:InsertPlate(item)
    self.plate = item
    return nil
end

function ENT:HandInsertItem(ply, item)
    if item.Entity_Data.ENUM_Type == GS_ITEM_BOARD and !self.board then
        return self:InsertPlate(item)
    end
end

function ENT:EjectItem()
    if #parts == 0 then

    end
end

function ENT:MakeMachine()

end


function ENT:Use()

end