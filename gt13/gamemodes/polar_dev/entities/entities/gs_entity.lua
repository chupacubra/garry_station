AddCSLuaFile()


//include("pickup.lua")
include("container.lua")


ENT.Type = "anim"

ENT.PrintName   = "gs_base"
ENT.Author      = "chupa"
ENT.Spawnable   = false

ENT.GS_Entity   = true
ENT.CanPickup   = true

ENT.Name  = "NAME"
ENT.Desc  = "DESC"

ENT.Size  = ITEM_SMALL
ENT.Color = nil
ENT.CarryAng = Angle(0,0,0)


local function CanPickup(ent)
    local phys = ent:GetPhysicsObject(ent)
    if !phys then return end
    return phys:GetMass() < 40
end

function ENT:SetupNWVars()
end

function ENT:SetupDataTables()
    self:SetupNWVars()
end

function ENT:Initialize()
    self:PreInit()

    self:SetModel(self.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end

    self:SetCollisionGroup(COLLISION_GROUP_WEAPON) -- for no collide with ply, for items only, big structures will be collided

    if self.Color then
        self:SetColor(self.Color)
    end

    if SERVER then
        self:SetUseType(SIMPLE_USE)
        self:CallOnRemove("ItemDeleting", function(ent)
            if !ent.Container then return end 
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

    self:SetupBaseContextCallbacks()
    self:SetupContextCallbacks()

    self:PostInit()
end

function ENT:CarryAng()
    return self.CarryAng or Angle(0,0,0)
end

// UseItem()?
function ENT:UseItem(ply)
    print("ply used item")
end

function ENT:Use(ply)
    if ply:KeyPressed(IN_WALK) then
        self:UseItem(ply)
        return
    end

    //if !self:IsPlayerHolding() and CanPickup(self) then ply:PickupObject(self) end
end

// dont know, needed the pickupObject in game

function ENT:PreInit()

end

function ENT:PostInit()
    -- here or in preinit you can set custom initialize functions for your items
    if self.IsContainer then
        self:ContainerInit()
    end
end

function ENT:ItemPrimary(hands, ply)
    -- using item in hands LMB
end

function ENT:ItemSecondary(hands, ply)
    -- using item in hands RMB
end

function ENT:ItemInteraction(drop, ply)
    // custom func to interact item with item (drop -> receiver)
    // if true then delete item from last cont
    // false - dont delete
    // return false
    return false
end

/* "Use", sharedFunc, icon
AddContextCallback("Examine", 
    function(self, ply)
        if CLIENT then return end
        ...
    end,
"icon")
*/

function ENT:Examine()
    RichTextPrint("It's a {255 255 255}".. self.Name)
    RichTextPrint("{255 255 255}"..self.Desc)
end

function ENT:SetupBaseContextCallbacks()
    self:AddContextCallback("Examine",
        function()
            self:Examine()
        end,
    "icon16/eye.png")

    if self.IsContainer then
        self:AddContextCallback("Open",
        function(btn)
            if ispanel(btn) then
                ContextMenuRequestContainer(btn, self)
            end
            self:OpenContainer()
        end,
        "icon16/briefcase.png")
    end
end

function ENT:SetupContextCallbacks()
    -- here you can edit custom context callbacks
end

-- 
--  need add submenu
--  submenu only 1 level deep
--
--
function ENT:AddContextCallback(name, func, icon, sub, server)
    self.ContextCallback[name] = {
        name = name,
        func = func,
        icon = icon,
        sub  = sub,
        needServer = server or false,
    }
end

function ENT:AddCustomContextCallback(name, func)
    self.ContextCallback[name] = {
        custom = func
    }
end

function ENT:GetContextButtons(args)
    // local buttons = table.Copy(self.ContextCallback)
    // эту функцию можно переделать, чтобы она выдавала кнопки,
    // которые бы появлялись только при опред состоянии (к примеру одеть\снять что нить)
    

    return self.ContextCallback
end

function ENT:RunContext(name, ply)
    if self.ContextCallback[name] == nil then return end
    if self.ContextCallback[name].func == nil then return end

    if CLIENT and self.ContextCallback[name].needServer then
        net.Start("gs_ent_run_callback")
        net.WriteEntity(self)
        net.WriteString(name)
        net.SendToServer()
    end

    self.ContextCallback[name].func(self, ply)
end

function ENT:AddToThink(key, func)
    self.ThinkLine[key] = func
end

function ENT:RemoveFromThink(key)
    self.ThinkLine[func] = nil
end

function ENT:Think()
    if SERVER then
        for _, func in pairs(self.ThinkLine) do
            func(self)
        end
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