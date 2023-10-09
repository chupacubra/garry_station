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

    self.Items = {}
    self.HaveBoard = false
end

function ENT:Screwdriver(ply)
    if !self:CanMakeMachine() then
        ply:ChatPrint("Where parts?")
        return
    end
    
    self:MakeMachine(ply)
end

function ENT:Crowbar(ply)
    self:EjectItem()
end

function ENT:CanMakeMachine()
    if !self.HaveBoard then
        return false
    end

    for part, amount in pairs(self.Items[self.HaveBoard]["item"]["Private_Data"]["Parts"]) do
        if !self.Items[part]then
            return false
        end
        if self.Items[part]["count"] != amount then
            return false
        end
    end

    return true
end

function ENT:EjectItem()
    if table.IsEmpty(self.Items) then
        return
    end
    
    local ej_tbl = self.Items
    ej_tbl[self.HaveBoard] = nil

    local key, ent = 0, {}

    if table.IsEmpty(ej_tbl) then
        key = self.HaveBoard
    else
        _, key = table.Random( ej_tbl )
    end

    if self.Items[key]["count"] == 1 then
        ent = self.Items[key]["item"]
        self.Items[key] = nil
    else
        self.Items[key]["count"] = self.Items[key]["count"] - 1
        ent = self.Items[key]["item"]
    end
    
    local entity = duplicator.CreateEntityFromTable(Entity(0), ent)
    entity:SetPos(self:GetPos())
    entity:Spawn()
end

function ENT:InsertPlate(item)
    self.Items[item.Class] = {
        item = item,
        count = 1,
    }
    
    self.HaveBoard = item.Class
    return nil
end

function ENT:InsertItem(ply, item)
    if self.HaveBoard == false and item.Entity_Data.ENUM_Type == GS_ITEM_BOARD and item.Entity_Data.ENUM_Subtype  == GS_BOARD_MACHINE then
        return self:InsertPlate(item)
    else
        local inReceipt, amount = GS_EntityControler.ItemInBoardReceipt(self.Items[self.HaveBoard]["item"], item)
        if self.HaveBoard and inReceipt then
            if self.Items[item.Class] == nil then
                self.Items[item.Class] = {
                    item = item,
                    count = 1,
                }
            else
                if self.Items[item.Class]["count"] >= amount then
                    return false
                end 
                self.Items[item.Class]["count"] = self.Items[item.Class]["count"] + 1
                return nil
            end
        end

    end
end

function ENT:MakeMachine(ply)
    if !self:CanMakeMachine() then
        ply:ChatPrint("Something is missing...")
        return
    end


    local rez_ent = ents.Create(self.Items[self.HaveBoard]["item"]["Private_Data"]["Machine"])

    local zpos = rez

    rez_ent:SetPos(self:GetPos())

    if !EntityCanBeSpawned(rez_ent) then
        rez_ent:Remove()
        ply:ChatPrint("The future machine if very big for this space")
        return
    end

    GS_Task:CreateNew(ply,"make_machine", 5, self,{
        start  = function(ply,_)
            ply:ChatPrint("You start screwing the machine casing")
        end,
        succes = function(ply,_)
            ply:ChatPrint("You screwed machine case")
            rez_ent:Spawn()

            local pos = {rez_ent:OBBCenter(),  rez_ent:OBBMaxs(),  rez_ent:OBBMins()}
            
            local npos = (pos[1] - pos[3])

            rez_ent:SetPos(self:GetPos() + Vector(0,0,npos.z))
            self:Remove()
        end,
        unsucces = function(ply,_)
            ply:ChatPrint("You stop screwing machine case")
        end
    },{},"Screwdriving some...")
end

function ENT:Use()

end

function ENT:ExamineParts(ply)
    if self.HaveBoard == false then
        ply:ChatPrint("This machine don't have board")
    else
        local board = self.Items[self.HaveBoard]["item"]
        local receipt = board.Private_Data.Parts
        local name = board.Entity_Data.Name

        ply:ChatPrint("Board: "..name)
        ply:ChatPrint("Parts:")

        for part_class, r_amount in pairs(receipt) do
            local count, n_name = 0, ""
            if self.Items[part_class] == nil then
                -- we need to use ents.GetTable because with him we can print nice name for 
                -- all items without GS_EntityList.GetPartNiceName() 
                n_name = scripted_ents.Get(part_class).Entity_Data.Name
            else
                n_name = self.Items[part_class]["item"]["Entity_Data"]["Name"]
                count   = self.Items[part_class]["count"]
            end
            ply:ChatPrint("  "..n_name..": "..count.."/"..r_amount)
        end

        return exam
    end
end

net.Receive("gs_ent_mc_exam_parts",function(_,ply)
    local ent = net.ReadEntity()
    local examine = ent:ExamineParts(ply)
end)
