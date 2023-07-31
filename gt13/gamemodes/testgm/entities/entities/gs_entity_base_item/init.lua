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
                if !v.GS_Entity then
                    return
                end

                if v.Entity_Data.ENUM_Type == self.Entity_Data.ENUM_Type and v.Entity_Data.ENUM_Subtype == self.Entity_Data.ENUM_Subtype and v != self then
                    print("adding to stack")
                    self:AddStack(v)
                    return
                end
                
            end
        end)
    end

    self:SetupFlag()
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
    net.WriteString(self.Data_Labels.id)
    net.WriteString(self.Data_Labels.type)
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

function ENT:PrivateExamine(ply)
    local arr = {self.Entity_Data.Name, self.Entity_Data.Desk}
--    local examine_f = self.Examine_Data.examine_string
    for k,v in pairs(self.Examine_Data) do
        local str = v.examine_string
        local arg = {}
        for k,v in pairs(v.arguments) do
            arg[k] = self[v[1]][v[2]]
        end
        arr[k] = string.format(str, unpack(arg))
    end

    for k, v in pairs(arr) do
        ply:ChatPrint(v)
    end
end

function ENT:SetupFlag()
    self.Key_State = 0
end

function ENT:SetFlagState(key, flag)
    local k = 2^key

    if flag then
        self.Key_State = bit.bor(self.Key_State, k)
    else
        if bit.band(self.Key_State, k) == k then
            self.Key_State = bit.bxor(self.Key_State , k)
        end
    end
end 

function ENT:GetFlagState(key)
    local k = 2 ^ key

    return bit.band(self.Key_State, k) == k
end

function ENT:GetFlag()
    return self.Key_State
end

--[[
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
--]]

net.Receive("gs_ent_client_init_item", function()
    local ent = net.ReadEntity()
    ent:LoadInfoAboutItem() 
end)

net.Receive("gs_ent_request_examine", function(_,ply)
    local ent = net.ReadEntity()

    ent:PrivateExamine(ply) 
end)
