AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
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
--    local examine_f = self.Examine_Data.examine_string
    for k,v in pairs(self.Examine_Data) do
        local str = v.examine_string
        local arg = {}
        for k,v in pairs(v.arguments) do
            arg[k] = self[v[1]][v[2]]
        end
        arr[k] = string.format(str, unpack(arg))
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
--[[
function ENT:GrabEntity(ply)
    if !self:OnGround() then
        return
    end

    if self.GrabPlayer then
        if self.GrabPlayer == ply then
            self:UnGrabEntity() -- simple ungrab
            return
        else
            self:UnGrabEntity() -- drive by entity
        end
    end
    
    self.GrabPlayer = ply
    self.Grabed     = true
    self.GrabPos    = ply:WorldToLocal(self:GetPos())
    self.GrabAng    = self:GetAngles()
    self.GrabMat    = self:GetPhysicsObject():GetMaterial()

    player_manager.RunClass( ply, "EffectSpeedAdd", "grab_entity", -150, -350 )
    construct.SetPhysProp( self:GetOwner(), self, 0, nil, { GravityToggle = true, Material = "slipperyslime" } )
    GS_ChatPrint(self.GrabPlayer, "You grab the "..self.Entity_Data.Name)
    
end

function ENT:UnGrabEntity()
    if self.GrabPlayer then
        player_manager.RunClass( self.GrabPlayer, "EffectSpeedRemove", "grab_entity")
        GS_ChatPrint(self.GrabPlayer, "You stop grabbing "..self.Entity_Data.Name)
    end

    construct.SetPhysProp( self:GetOwner(), self, 0, nil, { GravityToggle = true, Material = self.GrabMat } )

    self.GrabPlayer = nil
    self.Grabed     = false
    self.GrapPos    = nil
    self.GrabAng    = nil
    self.GrabMat    = nil
end
--]]
function ENT:Think()
    if self.Grabed then
        if !IsValid(self.GrabPlayer) then
            self:UnGrabEntity()
            return
        end

        local dist = self:GetPos():Distance( self.GrabPlayer:LocalToWorld(self.GrabPos))
        if dist > 100 then
            self:UnGrabEntity()
            return
        end

        if dist > 10 then
            local pos = self.GrabPlayer:LocalToWorld(self.GrabPos)
            local phys = self:GetPhysicsObject()

            local cpos = pos - self:GetPos()

            cpos:Normalize()

            local force = cpos * dist

            phys:SetVelocity(force)            
        end
    end
end

net.Receive("gs_ent_client_init_item", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAboutItem() 
end)

net.Receive("gs_ent_request_private_info", function(_,ply)
    local ent = net.ReadEntity()

    ent:RequestPrivateData(ply) 
end)
