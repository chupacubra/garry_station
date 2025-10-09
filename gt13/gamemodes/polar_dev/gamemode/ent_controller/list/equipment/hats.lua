// models/eft_props/gear/headwear/cap_boss_tagillacap.mdl red reverse cap
// models/eft_props/gear/headwear/head_ushanka.mdl
// models/eft_props/gear/headwear/head_beret_blk.mdl
// models/eft_props/gear/headwear/head_beret_blue.mdl
// models/eft_props/gear/headwear/head_beret_od.mdl 
// models/eft_props/gear/headwear/head_military2_black.mdl
// models/eft_props/gear/headwear/head_claus.mdl
// models/eft_props/gear/headwear/head_dedmoroz.mdl

local ENT = {}

local size_head = Vector(0.95,0.95,0.95)
local pos_head =  Vector(0.5,2.2,0.15)
local ang_head =  Angle(-80,0,-90)

local base_EquipModelDraw = {
    model = "",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Head1",
    offset_pos  = pos_head,
    offset_ang  = ang_head,
    size = 0.85,
}

ENT.Base = "gs_equip"

ENT.Name  = "Red cap"
ENT.Desc  = "red caper"
ENT.Model = "models/eft_props/gear/headwear/cap_boss_tagillacap.mdl"
ENT.Size  = ITEM_SMALL

ENT.PrintName = ENT.Name
ENT.Spawnable = true
ENT.Category = "Polar Station: Hats"

ENT.TypeEquip   = "HEAD"

ENT.EquipModelDraw = {
    model       = ENT.Model,
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Head1",
    offset_pos  = pos_head,
    offset_ang  = ang_head,
    size = 0.85,
}

ENT.HandOffsetVec = Vector(5, 20, -4)
ENT.HandOffsetAng = Angle(0, 0, 180)

ENT.PrintName = ENT.Name

function ENT:ItemInteraction(ent)
    return self:InsertItemInContainer(ent)
end

AddEntItem(ENT, "h_redcap")

local function fast_hat(id, name, desk, model, EquipModelDraw ) // if EquipModelDraw == true, then copy base and set model
    local ent = {}
    
    ent.PrintName = name
    ent.Name = name
    ent.Desc = desk
    ent.Model = model

    if EquipModelDraw == true then
        local base_emd = table.Copy(base_EquipModelDraw)
        base_emd.model = model
        ent.EquipModelDraw = base_emd

        //PrintTable(ent.EquipModelDraw)
    elseif EquipModelDraw then
        ent.EquipModelDraw = EquipModelDraw
    end

    AddEntItem(ent, id, "h_redcap")
end


fast_hat("h_ushanka", "Ushanka", "ruzke", "models/eft_props/gear/headwear/head_ushanka.mdl", true)
fast_hat("h_beret_black", "Black beret", "Мы одеты во все черное и не оставляем в живых", "models/eft_props/gear/headwear/head_beret_blk.mdl", true)
fast_hat("h_beret_blue", "Blue beret", "Blue beret for faggots", "models/eft_props/gear/headwear/head_beret_blue.mdl", true)
fast_hat("h_beret_green", "Green beret", "Green hat", "models/eft_props/gear/headwear/head_beret_od.mdl", true) 
fast_hat("h_sec_cap", "Security cap", "Cap for debilny", "models/eft_props/gear/headwear/head_military2_black.mdl", true) 
fast_hat("h_cap_brown", "Brown cap", "Poopmadnes", "models/eft_props/gear/headwear/head_military2_brown.mdl", true) 
fast_hat("h_shapka1", "Shapka", "Shapka", "models/eft_props/gear/headwear/head_knitcap.mdl", true) 
fast_hat("h_cap1", "Cap", "the caper", "models/eft_props/gear/headwear/cap_scav.mdl", true)
fast_hat("h_sec_cap2", "Service cap", "Cap for debilny", "models/eft_props/gear/headwear/cap_mhs.mdl", true) 




