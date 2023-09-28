AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:AfterInit()
    self.Materials = {}
    self.OrderList = {}
end

function ENT:Screwdriver(ply)
    -- open hatch
    self:FlipFlag(KS_MAINTANCE)
end

function ENT:Crowbar(ply)
    -- if hatch opened:
    --     demontazh
    if self:GetFlagState(KS_MAINTANCE) then
        self:Disassemble()
    end
end

function ENT:EjectItem()
    if table.IsEmpty(self.Items) then
        return
    end
    
    local ent,key = table.Random( self.Items ) 

    if key == self.HaveBoard then -- check this
        if table.Count(self.Items) > 1 then
            return self:EjectItem() -- if board isnt last part then 
        end
        self.HaveBoard = false
    end

    if self.Items[key]["count"] == 1 then
        ent = self.Items[key]["item"]
        self.Items[key] = nil
    else
        self.Items[key]["count"] = self.Items[key]["count"] - 1
        ent = self.Items[key]["item"]
    end
    
    entity = duplicator.CreateEntityFromTable(Entity(0), ent)
    entity:SetPos(self:GetPos())
    entity:Spawn()
end

function ENT:InsertItem(ply, item)
    -- the fabricator allow insert metal and glass
end

function ENT:CraftItem(category, name)
    -- get
end

function ENT:Think()
    for ply, _ in pairs(self.ConnectedPly) do
        if self:GetPos():Distance(ply:GetPos()) > 100 then
            self:DisconnectPly(ply)
        end
    end
end

