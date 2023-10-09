AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local function spawnPart(parts, ent, pos) -- theesee need check!!!!11
    timer.Simple(0.1, function()
        -- for this second the machine case can be exterminated, but parts MUST be spawned
        -- we saving ENT and last POS
        if ent:IsValid() then
            pos = ent:GetPos()
        end
        
        local pent = ents.Create(part[1])
        pent:SetPos(pos)
        pent:Spawn()

        table.remove(parts, 1)
        if #parts != 0 then
            spawnPart(parts, ent, pos)
        end
    end)
end

ENT.DissasembleData = {
    board = "" -- key GS_EntityList.tech_plate
}

function ENT:Initialize()
	self:SetModel( self.Entity_Data.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    
    if (phys:IsValid()) then
        phys:Wake()
    end

    self.PlyConnectList = {}
    
    self:AfterInit()

    self:CallOnRemove("DisconnectPiple", function()
        self:CleanConnect()
    end)
end

function ENT:AfterInit() -- need for setup values after init

end

function ENT:Use()

end

function ENT:SetExamine(data) -- name, description
    if data == false then
        return
    end

    self.Entity_Data.Name = data.name 
    self.Entity_Data.Desc = data.desc
    --self:LoadInfoAbout()
end

function ENT:SetData(data) 
    self.Entity_Data = data
    if self.Entity_Data.Model then
        self:SetModel(self.Entity_Data.Model)
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

function ENT:FlipFlag(key)
    local k = 2^key

    local flag = self:GetFlagState(key)

    if flag then
        self.Key_State = bit.bor(self.Key_State, k)
    else
        if bit.band(self.Key_State, k) == k then
            self.Key_State = bit.bxor(self.Key_State , k)
        end
    end

    return !flag -- logichno
end

function ENT:GetFlag()
    return self.Key_State
end

function ENT:Examine()
    local exam = {self.Entity_Data.Name, self.Entity_Data.Desc}

    if self:GetFlagState(KS_MAINTANCE) then
        table.insert(exam, "The service hatch is open")
    end

    if self:GetFlagState(KS_BOLT) then
        table.insert(exam, "It's bolted to ground")
    end

    if self:GetFlagState(KS_BROKEN) then
        table.insert(exam, "It's seems broken")
    end

    return exam
end

function ENT:Breakable(hp)
    if hp == false then
        self:SetCanBreak(false)
        return
    end
    
    self.HP = hp 
end

function ENT:EDamage(dmg)
    if !self:CanBreak() then
        return false
    end

    self.HP = self.HP - dmg

    if self.HP <= 0 then
        self:AfterBreak()
    end
end

function ENT:AfterBreak()
    self:Remove()
end

function ENT:Bolt()
    if self:GetVelocity() != Vector(0,0,0) then
        return false
    end
    
    self:GetPhysicsObject():EnableMotion( false )
    self:SetFlagState(KS_BOLT,true)
    return true, "You screwed this in ground"
end

function ENT:Unbolt()
    self:GetPhysicsObject():EnableMotion( true )
    self:SetFlagState(KS_BOLT,false)
    return true, "You unscrewed this from ground"
end

function ENT:Wrench(ply)
    if self.CanBolted then
        if self:GetFlagState(KS_BOLT) == false then
            return GS_Task:CreateNew(ply,"screw_entity", 4, self,{
                start  = function(ply,_)
                    ply:ChatPrint("You began to fasten the object to the floor")
                end,
                succes = function(ply,_)
                    return self:Bolt()
                end,
                unsucces = function(ply,_)
                    ply:ChatPrint("You stop screwing machine case")
                end
            },{},"Fastenning some...")
        else
            return GS_Task:CreateNew(ply,"unscrew_entity", 4, self,{
                start  = function(ply,_)
                    ply:ChatPrint("You began to unfasten the object to the floor")
                end,
                succes = function(ply,_)
                    return self:Unbolt()
                end,
                unsucces = function(ply,_)
                    ply:ChatPrint("You stop screwing machine case")
                end
            },{},"Unfastenning some...")
        end
    end
end

function ENT:DissasembleMachine()
    if !self.DissasembleData then self:Remove(); return end
    -- get board data
    -- get receipt list ents
    -- spawn machine case
    -- spawn parts

    local drop_ents = {}
    table.insert(drop_ents, "gs_item_tech_plate_"..self.DissasembleData.board)
    
    for k, v in pairs(GS_EntityList.tech_plate[self.DissasembleData.board]["Private_Data"]["Parts"]) do
        for i=0, v do
            table.insert(drop_ents, k)
        end
    end

    local pos, ang = self:GetPos(), self:GetAngles()
    self:Remove()
    
    local mc = ents.Create("gs_machine_casing")
    mc:SetPos(pos)
    mc:SetAngles(ang)
    mc:Spawn()
    
    spawnPart(drop_ents, mc)
end

function ENT:Crowbar(ply)
--[[
    ex if build and maint open --> uncraft machine
]]
end

function ENT:Screwdriver(ply)
--[[
    open maint
    machine casing build
]]
end

function ENT:Multitool(ply)

end

function ENT:PlyConnect(ply)
    local function checkDelay(ply)
        self.PlyConnectList[ply] = CurTime()
        timer.Simple(2, function()
            if CurTime() - self.PlyConnectList[ply] > 2 then
                self:PlyDisconnect(ply)
            else
                self.PlyConnectList[ply] = CurTime()
                checkDelay(ply) -- i think it's a bad idea to call checkDelay, but i want test it
            end
        end)
    end

    self.PlyConnectList = self.PlyConnectList or {}
end

function ENT:PlyDisconnect(ply)
    if !self.PlyConnectList then return end

    self.PlyConnectList[ply] = nil 

    net.Start("gs_connect_ent")
    net.WriteEntity(self)
    net.Send(ply)
end 

function ENT:GetConnectedPly()
    return self.PlyConnectList or {} 
end

function ENT:CleanConnect()
    for k, v in pairs(self.PlyConnectList) do
        self:PlyDisconnect(ply)
    end
end

net.Receive("gs_connect_ent", function(_, ply)
    local ent = ent.ReadEntity()
    local cnnct = ent.ReadBool()

    if cnnct then
        if ent:GetPos():Distance( ply:GetPos() ) <= (ent.ConnectDist or 75) then
            ent:PlyConnect(ply)
        else
            net.Start("gs_connect_ent")
            net.WriteEntity(self)
            net.Send(ply) -- for deleting timer on client
        end
    else
        ent:PlyDisconnect(ply)
    end
end)