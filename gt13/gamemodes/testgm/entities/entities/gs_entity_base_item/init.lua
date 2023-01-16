AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    PrintTable(self.Entity_Data)
    PrintTable(self.Private_Data)
    if self.Entity_Data then
        self:SetModel(self.Entity_Data.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    else
        self:SetModel(self:GetModel())
    end
    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end


    if self.Entity_Data.ENUM_Type == GS_ITEM_MATERIAL then
        timer.Create("gs_ent_find_material", 1, 1, function()
            for k,v in pairs(ents.FindInSphere( self:GetPos(), 100 )) do
                if v.GS_Entity then
                    if v.Entity_Data.ENUM_Type == self.Entity_Data.ENUM_Type and v.Entity_Data.ENUM_Subtype == self.Entity_Data.ENUM_Subtype and v != self then
                        print("adding to stack")
                        self:AddStack(v)
                        return
                    end
                end
            end
        end)
    end


end

function ENT:SetItemModel(model)
    self.Entity_Data.Model = model or ""
    self:SetModel(model)
end


function ENT:SetData(data)
    self.Entity_Data = data
    if self.Entity_Data.Model then
        self:SetModel(self.Entity_Data.Model)
    end
end

function ENT:SetExamineData(data)
    self.Examine_Data = data
end

function ENT:SetPrivateData(data)
    self.Private_Data = data
end

function ENT:GetPrivateData()
    return self.Private_Data
end

function ENT:GetHandData()
    return self.Entity_Data
end


function ENT:LoadInfoAboutItem() -- !!!!!! 
    net.Start("gs_ent_update_info_item")
    net.WriteEntity(self)
    net.WriteTable(self.Entity_Data)
    net.Broadcast()
end

function ENT:OnReloaded() 
    self:SetData(self.Entity_Data)
    self:LoadInfoAboutItem()
end


function ENT:AddStack(pile)
    if self.Entity_Data.ENUM_Type != GS_ITEM_MATERIAL and pile.Entity_Data.ENUM_Type != GS_ITEM_MATERIAL then
        return
    end

    if pile.Private_Data.Stack == pile.Private_Data.Max_Stack then
        return
    end

    if pile.Private_Data.Stack + self.Private_Data.Stack <= pile.Private_Data.Max_Stack then
        pile.Private_Data.Stack = pile.Private_Data.Stack + self.Private_Data.Stack
        pile:LoadInfoAboutItem()
        self:Remove()
        return
    else
        pile.Private_Data.Stack = pile.Private_Data.Max_Stack
        self.Private_Data.Stack = pile.Private_Data.Max_Stack - (pile.Private_Data.Stack + self.Private_Data.Stack)
        pile:LoadInfoAboutItem()
        self:LoadInfoAboutItem()
        return
    end
end

function ENT:BuildPrivateExamine()
    local arr = {}
    
    for k,v in pairs(self.Examine_Data) do
        arr[k] = string.format(v[1], self.Private_Data[v[2]])
    end

    return arr
end

function ENT:RequestPrivateData(ply)
    local examine = self:BuildPrivateExamine()
    GS_MSG(ply:GetName().. " requested private info for "..self.Entity_Data.Name.." ("..self:EntIndex()..")", MSG_INFO)

    net.Start("gs_ent_get_private_info")
    net.WriteEntity(self)
    net.WriteTable(examine)
    net.Send(ply)

end

net.Receive("gs_ent_client_init_item", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAboutItem() 
end)

net.Receive("gs_ent_request_private_info", function(_,ply)
    local ent = net.ReadEntity()

    ent:RequestPrivateData(ply) 
end)
