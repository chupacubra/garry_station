AddCSLuaFile()

if SERVER then
include("container.lua")
include("pickup.lua")
end

ENT.Type = "anim"

ENT.PrintName		= "gs_base"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"

ENT.GS_Entity  = true
ENT.CanPickup = true

ENT.Name  = "NAME"
ENT.Desc  = "DESC"
ENT.Model = ""
ENT.Size  = ITEM_SMALL
ENT.Color = nil
/*
ENT.IsEquip = false
ENT.TypeEquip = EQUIP_BACKPACK  
*/

function ENT:Initialize()
    self.PreInit()

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

//  self:SetupFlag()

    if self.Color then
        self:SetColor(self.ENT_Color)
    end

    if SERVER then
        self:CallOnRemove("ItemDeleting", function(ent)
            timer.Simple(0, function() -- fear parent item will acuse some phys problems to childs 
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
        end)
    end

    self.ThinkLine = {}
    self.ContextCallback = {}

    self:PostInit()
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
/*
function ENT:CanItemInteract(item)
    // check here for test item can be interact
    // это под обсуждением
    return false
end
*/
function ENT:ItemInteraction(drop)
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
        name = name
        func = func
        icon = icon
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

function ENT:AddToThink(func)
    table.Add(self.ThinkLine, func)
end

function ENT:Think()
    if #self.ThinkLine == 0 then return end
    for _, func in pairs(self.ThikLine) do
        func(self)
    end
end

if SERVER then
    net.Receive("gs_ent_run_callback", function(_, ply)
        local ent = net.ReadEntity()
        local name = net.ReadEntity()

        if ent:IsValid() then
            ent:RunContext(name, ply)
        end
    end)
end