AddCSLuaFile()

//include()

ENT.Base = "gs_entity"

ENT.IsEquip     = true
ENT.TypeEquip   = "HEAD"
//ENT.EquipedPos  = Vector(0,0,0)
ENT.Protection = {
    //[D_BRUTE] = 0
}

ENT.EquipModelDraw = {
    model       = "models/eft_props/gear/backpacks/bp_forward.mdl",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = Vector(),
    offset_ang  = Angle(),
    // color = Color(),
    // skin = 0,
}

--[[
    args = {
        inEquip = contextbutton equip type 
                    OR
                    check ent.EquipOwner == LocalPlayer(), this more accurate
    }
--]]

function ENT:GetContextButtons(args)
    // добавляем кнопки, которые зависят от статуса предмета
    local buttons = table.Copy(self.ContextCallback)
    local ply = LocalPlayer()
    
    if !IsValid(ply.Equipment[self.TypeEquip]) then
        buttons["equip"] = {
            name = "Equip",
            func = function()
                self:Equip()
            end,
            icon = "icon16/arrow_up.png",
        }
    else
        if ply.Equipment[self.TypeEquip] == self then
            buttons["dequip"] = {
                name = "Dequip",
                func = function()
                    self:DeEquip()
                end,
                icon = "icon16/arrow_down.png",
            }
        end
    end
    
    return buttons
end

// here you can create custom equipmodels
function ENT:CreateEquipDrawModel(ply)
    if SERVER then return end
    local cmodel = ClientsideModel(self.EquipModelDraw.model)
    cmodel:SetBodyGroups(self.EquipModelDraw.bodygroups)
    cmodel:SetModelScale(self.EquipModelDraw.size)
    return cmodel
end

function ENT:Equip(ply) // ply want to wear ent
    if CLIENT then
       net.Start("gs_equip_item")
       net.WriteBool(true)
       net.WriteEntity(self)
       net.SendToServer() 
    else
        //PrintTable(ply.Equipment)
        local cont = self:ItemGetParentContainer()
        // need delete ent from old cont, from Items
        
        local success = player_manager.RunClass(ply, "EquipItem", self)
        if success then
            if cont then
                cont:RemoveItem(self)
            end
            self.EquipOwner = ply
        end
    end
end

function ENT:DeEquip(ply)
    if CLIENT then
       net.Start("gs_equip_item")
       net.WriteBool(false)
       net.WriteEntity(self)
       net.SendToServer() 
    else
        local success = player_manager.RunClass(ply, "DequipItem", self)
        if success then
            self.EquipOwner = nil
        end
    end
end

function ENT:BroadcastOnEquip(ply)
    net.Start("gs_equip_on")
    net.WriteBool(true)
    net.WritePlayer(ply)
    net.WriteEntity(self)
    net.Broadcast()
end

function ENT:BroadcastOnDeEquip(ply)
    net.Start("gs_equip_on")
    net.WriteBool(false)
    net.WritePlayer(ply)
    net.WriteEntity(self)
    net.Broadcast()
end


function ENT:OnEquip(ply)
    if SERVER then
        self:BroadcastOnEquip()
    else
        self.EquipOwner = ply
    end
end

function ENT:OnDeEquip(ply)
    if SERVER then
        self:BroadcastOnDeEquip()
    else
        self.EquipOwner = nil
    end
end

// client
net.Receive("gs_equip_on", function()
    local onEquip = net.ReadBool()
    local ply = net.ReadPlayer()
    local ent = net.ReadEntity()

    print("EQUIP ONEQUIP", ply, ent )

    if onEquip then
        ent:OnEquip()
    else
        ent:OnDeEquip()
    end
end)

// server
net.Receive("gs_equip_item", function(_, ply)
    local equiping = net.ReadBool()
    local ent = net.ReadEntity()

    if equiping then
        ent:Equip(ply)
    else
        ent:DeEquip(ply)
    end
end)

// ply want to Equip -> click on Equip
//  client              server
//  ContextButton   ->  EquipClass, EquipSync
//  OnEquip         <-  OnEquip
