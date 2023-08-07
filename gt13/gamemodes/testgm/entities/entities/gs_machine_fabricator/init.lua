AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:AfterInit()
    self.Materials = {}
end

function ENT:Screwdriver(ply)
    -- open hatch
end

function ENT:Crowbar(ply)
    -- if hatch opened:
    --     demontazh
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

net.Receive("gs_ent_mc_exam_parts",function(_,ply)
    local ent = net.ReadEntity()
    local examine = ent:ExamineParts(ply)

    --GS_ReturnExamineTable(ply, examine)
    for k, v in pairs(examine) do
        ply:ChatPrint(v)
    end
end)
