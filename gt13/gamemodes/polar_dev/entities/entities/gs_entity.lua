AddCSLuaFile()

if SERVER then
    include("pickup.lua")
end

ENT.Type = "anim"

ENT.PrintName   = "gs_base"
ENT.Author      = "chupa"
ENT.Spawnable   = false

ENT.GS_Entity   = true
ENT.CanPickup   = true

ENT.Name  = "NAME"
ENT.Desc  = "DESC"
ENT.Model = ""
ENT.Size  = ITEM_SMALL
ENT.Color = nil
ENT.CarryAng = Angle(0,0,0)

/*
ENT.IsEquip = false
ENT.TypeEquip = EQUIP_BACKPACK  
*/

local function CanPickup(ent)
    local phys = ent:GetPhysicsObject(ent)
    if !phys then return end
    return phys:GetMass() < 40
end

function ENT:Initialize()
    self:PreInit()

    self:SetModel(self.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetCollisionGroup(COLLISION_GROUP_WEAPON) -- for no collide with ply, for items only, big structures will be collided

    if self.Color then
        self:SetColor(self.ENT_Color)
    end

    if SERVER then
        self:CallOnRemove("ItemDeleting", function(ent)
            if ent.Container:IsPlayer() then
                player_manager.RunClass(ent.Container, "RemoveFromInventary", ent)
            end
            
            if IsValid(ent.Container) and ent.Container.RemoveItem then
                -- for sync
                ent.Item_Container:RemoveItem(self)
            end

            if ent.Item_Container then
                for _, item in pairs(ent.Private_Data.Items) do
                    ItemRecover(item, ent:GetPos())
                end
            end
        end)
    end

    self.ThinkLine = {}
    self.ContextCallback = {}

    self:PostInit()
end

function ENT:CarryAng()
    return self.CarryAng or Angle(0,0,0)
end

// UseItem()?
function ENT:Use(ply)
    if ply:KeyPressed(IN_WALK) then
        self:UseItem()
        return
    end

    if !self:IsPlayerHolding() and CanPickup(self) then ply:PickupObject(self) end
end

function ENT:PostInit()

end

function ENT:PreInit()

end

function ENT:ItemPrimary(hands, ply)
    -- using item in hands LMB
end

function ENT:ItemSecondary(hands, ply)
    -- using item in hands RMB
end
 
function ENT:GetButtons(self)
    -- buttons for context menu
end

function ENT:ItemInteraction(drop, ply)
    // custom func to interact item with item (drop -> receiver)
    // if true then delete item from last cont
    // false - dont delete
    // return false
end

/* "Use", sharedFunc, icon
AddContextCallback("Examine", 
    function(self, ply)
        if CLIENT then return end
        ...
    end,
"icon")
*/
function ENT:AddContextCallback(name, func, icon)
    self.ContextCallback[name] = {
        name = name,
        func = func,
        icon = icon,
    }
end

function ENT:GetContextButtons()
    return self.ContextCallback
end

function ENT:RunContext(name, ply)
    if self.ContextCallback[name] == nil then return end
    if self.ContextCallback[name]["func"] == nil then return end

    if CLIENT then
        net.Start("gs_ent_run_callback")
        net.WriteEntity(self)
        net.WriteString(name)
        net.SendToServer()
    end

    self.ContextCallback[name][func](self, ply)
end

function ENT:AddToThink(key, func)
    self.ThinkLine[func] = func
end

function ENT:RemoveFromThink(key)
    self.ThinkLine[func] = nil
end

function ENT:Think()
    //if #self.ThinkLine == 0 then return end
    for _, func in pairs(self.ThikLine) do
        func(self)
    end
end

if SERVER then
    net.Receive("gs_ent_run_callback", function(_, ply)
        local ent = net.ReadEntity()
        local name = net.ReadString()

        if ent:IsValid() then
            ent:RunContext(name, ply)
        end
    end)
end