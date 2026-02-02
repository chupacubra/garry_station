AddCSLuaFile()


//include("pickup.lua")
include("container.lua")
include("stacking.lua")

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
ENT.Material = nil
ENT.CarryAng = Angle(0,0,0)

ENT.HandOffsetVec = Vector()
ENT.HandOffsetAng = Angle()

// с помощью нет комманд можно предустановить "команду" в которую можно засунуть аргументы
// всё для экономии нетворкинга
// очень хочется чтобы оно ещё могло создавать короткие функции, в которые бы можно было сразу передать аргументы и передавать неты
// каллбаки не могли передавать аргументов, а нэткоманды могут
// с помощью неткомманд можно не создавать для энтити отдельные нетстроки, если нужно что-то передать
// шаред
--[[
    ENT.NetCommands = {
        ["SetChemical"] = {
            {"id", "string"}
        }
    }

    // на клиенте
    self:NetCommand("SetChemical", "water")



    // на сервере
    
    net.Receive("ps_ent_netcmd", function(_, ply) ... end) --->
        ent:SetChemical("water")




        необходимо поставить проверки на валидность выполнения комманды
--]]
ENT.NetCommands = {}



local function CanPickup(ent)
    local phys = ent:GetPhysicsObject(ent)
    if !phys then return end
    return phys:GetMass() < 40
end

function ENT:SetupNWVars()
end


function ENT:RunNetCommand(cmd, ...)
    if !self.NetCommands[cmd] then return end
    
    local net_args = self.NetCommands[cmd]

    if #args != #net_args then return end


    local netsend = {}

    for i, v in pairs(args) do
        local typ = net_args[i][2] 
        local id = net_args[i][1]
        
        if type(v) != typ then 
            GS_Error("NetCommand for "..tostring(self)..": Unexpected type for '"..tostring(id).."' - "..type(v) .." but need "..typ)
            return
        end

        table.insert(netsend, {id = id, var = v, typ = typ})
    end

    util.SendNetCommand(ent, cmd, netsend)
end

function ENT:HandleNetCommands(netcmd, args, ply)
    // some shiiiieeeet
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
    
    self:SetColor(self.Color or Color(255, 255, 255) )
    if self.Material then
        self:SetMaterial(self.Material)
    end

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
                player_manager.RunClass(ent.Container, "RemoveItemFromInventary", ent)
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

    if self.Stackable then
        if self.RemoveAfterOver then
            self:SetNWVarProxy( "RemoveAfterOver", function(_, _, old, new)
                print("STACK UPDATA, ", old, new)
                if new < 1 then
                    self:Remove()
                end
            end)
        end
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

// can be called on server and on client
function ENT:Examine(ply)
    if SERVER and !ply then GS_MSG("try ent exam on server but no ply") return end
    RichTextPrint("It's a {255 255 255}".. self.Name, ply)
    RichTextPrint("{255 255 255}"..self.Desc, ply)

    //debug.Trace()
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