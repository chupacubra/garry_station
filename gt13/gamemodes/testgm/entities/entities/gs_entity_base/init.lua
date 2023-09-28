AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.DisassembleData = {
    board = ""
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

    self:AfterInit()

    self.ConnectedPly = {}

    timer.Create("gs_ent_connected_ply_timer", 1, 0, function()
        if table.IsEmpty(self.ConnectedPly) then return end

        for ply, time in pairs(self.ConnectedPly) do
            if CurTime() - time > 2 then
                self:DisconnectPly(ply)
            end
        end
    end)

    self:CallOnRemove("DisconnectAllPly", function()
        timer.Remove("gs_ent_connected_ply_timer")
        
        self:DisconnectPlyAll(true)
    end)
end

function ENT:AfterInit() -- need for setup values after init

end

function ENT:SetExamine(data) -- name, description
    if data == false then
        return
    end

    self.Entity_Data.Name = data.name 
    self.Entity_Data.Desc = data.desc
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

function ENT:FlipFlag(key)
    local k = 2^key
    local bool = bit.band(self.Key_State, k) == k

    if bool then
        if bit.band(self.Key_State, k) == k then
            self.Key_State = bit.bxor(self.Key_State , k)
        end
    else
        self.Key_State = bit.bor(self.Key_State, k)
    end

    return !bool
end

function ENT:GetFlagState(key)
    local k = 2 ^ key

    return bit.band(self.Key_State, k) == k
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

function ENT:Disassemble()
    local machine_parts = {}

    table.insert(machine_parts, "gs_item_tech_plate_"..self.DisassembleData.board)

    for part, amnt in pairs(GS_EntityList["tech_plate"][self.DisassembleData.board]["Private_Data"]["Parts"]) do
        local id = GS_EntityList.Board_Parts_Fast[part]

        for i = 0, amnt do
            table.insert(machine_parts, "gs_item_parts_"..id)
        end
    end

    local pos, ang = self:GetPos(), self:GetAngles()
    self:Remove()

    local mc = ents.Create("gs_machine_casing")
    mc:SetPos(pos)
    mc:SetAngles(ang)
    mc:Spawn()

    for i = 1, #machine_parts do 
        local part = ents.Create(machine_parts[i])
        part:SetPos(pos)
        part:Spawn()
    end

end

function ENT:ConnectPly(ply)
    self.ConnectedPly[ply] = CurTime()
end

function ENT:DisconnectPly(ply, fromClient)
    self.ConnectedPly[ply] = nil

    if !fromClient then
        net.Start("gs_ent_connect_ply")
        net.WriteEnt(self)
        net.Send(ply)
    end
end

function ENT:DisconnectPlyAll(onRemove)
    for ply, _ in pairs(self.ConnectedPly) do
        self:DisconnectPly(ply, onRemove)
    end
end

net.Receive("gs_ent_connect_ply", function(_, ply)
    local ent = net.ReadEntity()
    local connect = net.ReadBool()

    if !ent:IsValid() then return end

    if connect then
        ent:ConnectPly(ply)
    else
        ent:DisconnectPly(ply, true)        
    end
end)