// list api
local ENT = {}

ENT.Base = "gs_entity"

ENT.Name  = "test object"
ENT.Desc  = "skibidi"
ENT.Model = "models/props_lab/cactus.mdl"
ENT.Size  = ITEM_SMALL

ENT.Spawnable = true
ENT.Category = "Developing"

function ENT:SetupNWVars()
end

function ENT:PreInit()
end

function ENT:PostInit()
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

function ENT:Examine(ply)
    if SERVER and !ply then GS_MSG("try ent exam on server but no ply") return end
    RichTextPrint("It's a {255 255 255}".. self.Name, ply)
    RichTextPrint("{255 255 255}"..self.Desc, ply)
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

function ENT:AddContextCallback(name, func, icon, sub, server)
    self.ContextCallback[name] = {
        name = name,
        func = func,
        icon = icon,
        sub  = sub,
        needServer = server or false,
    }
end

function ENT:GetContextButtons(args)
    // local buttons = table.Copy(self.ContextCallback)
    // эту функцию можно переделать, чтобы она выдавала кнопки,
    // которые бы появлялись только при опред состоянии (к примеру одеть\снять что нить)
    return self.ContextCallback
end

function ENT:UseItem(ply)
    print("ply used item")
end


// ENT:AddToThink(key, func)
// ENT:RemoveFromThink(key)