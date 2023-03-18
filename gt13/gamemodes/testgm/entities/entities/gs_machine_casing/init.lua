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
    self.Items = {}
    self.HaveBoard = false
end

function ENT:Screwdriver(ply)

end

function ENT:Crowbar(ply)
    self:EjectItem()
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

function ENT:InsertPlate(item)
    local new = {
        item = item,
        count = 1,
    }
    
    self.Items[item.Entity_Data.ENT_Name] = new
    
    self.HaveBoard = item.Entity_Data.ENT_Name -- ?
    return nil
end

function ENT:InsertItem(ply, item)
    --[[
        if board == nil then
            receive ONLY boards
        else have board then
            receive ONLY parts in board RECEIPT       
]]
--[[
    if item.Entity_Data.ENUM_Type == GS_ITEM_BOARD and !self.board then
        return self:InsertPlate(item)
    end
    if self.Items[item.Entity_Data.ENT_Name] == nil then
        local new = {
            item = item,
            count = 1,
        }
        self.Items[item.Entity_Data.ENT_Name] = new
    else
        self.Items[item.Entity_Data.ENT_Name]["count"] = self.Items[item.Entity_Data.ENT_Name]["count"] + 1
    end
    --PrintTable(self.Items)
    --print(self.Items)
    return nil
    --]]
    if self.HaveBoard == false and item.Entity_Data.ENUM_Type == GS_ITEM_BOARD then
        return self:InsertPlate(item)
    else
        local inReceipt, amount = GS_EntityControler.ItemInBoardReceipt(self.Items[self.HaveBoard]["item"], item)
        if self.HaveBoard and inReceipt then
            if self.Items[item.Entity_Data.ENT_Name] == nil then
                local new = {
                    item = item,
                    count = 1,
                }
                self.Items[item.Entity_Data.ENT_Name] = new
            else
                if self.Items[item.Entity_Data.ENT_Name]["count"] >= amount then
                    return false
                end 
                self.Items[item.Entity_Data.ENT_Name]["count"] = self.Items[item.Entity_Data.ENT_Name]["count"] + 1
                return nil
            end
        end
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

    if self.HaveBoard == false then
        table.insert(exam,"This machine don't have board")
        return exam
    else
        print(self.HaveBoard)
        PrintTable(self.Items)
        local board = self.Items[self.HaveBoard]["item"]
        local receipt = board.Private_Data.Parts
        local name = board.Entity_Data.Name

        table.insert(exam, "Board: "..name)
        table.insert(exam, "Parts:")

        local parts_in_ent = {} -- ent_name, amount, need

        for part_name, r_amount in pairs(receipt) do
            if self.Items[part_name] == nil then
                local n_name = GS_EntityList.GetPartNiceName(part_name)--["Entity_Data"]["Name"]
                print(n_name)
                table.insert(parts_in_ent,{nice_name = n_name, amount = 0, need = r_amount })
            else
                local n_name = self.Items[part_name]["item"]["Entity_Data"]["Name"]
                local count   = self.Items[part_name]["count"]
                table.insert(parts_in_ent,{nice_name = n_name,amount = count, need = r_amount})
            end
        end

        for k,v in pairs(parts_in_ent) do
            table.insert(exam, "  "..v.nice_name..": "..v.amount.."/"..v.need)
        end
        
        return exam
    end
end

net.Receive("gs_ent_mc_exam_parts",function(_,ply)
    local ent = net.ReadEntity()
    local examine = ent:ExamineParts(ply)

    GS_ReturnExamineTable(ply, examine)
end)
