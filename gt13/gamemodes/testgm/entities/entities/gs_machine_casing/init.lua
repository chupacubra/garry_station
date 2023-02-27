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
    self.recept = {}
end

function ENT:Screwdriver(ply)

end

function ENT:Crowbar(ply)
    self:EjectItem()
end

function ENT:EjectItem()
    if self.board then
        --eject  ALL items

        --ejectBoard()

        for k,v in pairs(self.parts) do
            --ejectItem(v)
            --remove
        end
    end
end

function ENT:InsertPlate(item)
    self.plate = item
    self.recept = item.Private_Data.Parts
    
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


--[[
    Board: Vendomat
    Parts:
      Plug: 1/1
      Electronics: 0/2
]]
function ENT:ExamineParts(ply)
    local exam = {}
    if !self.board then
        table.insert(exam,"This machine don't have board")
        return exam
    end    
end

net.Receive("gs_ent_mc_exam_parts",function(_,ply)
    local ent = net.ReadEntity()
    local examine = ent:ExamineParts(ply)
end)
