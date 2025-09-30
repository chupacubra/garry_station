// backpacks
//  models/eft_props/gear/backpacks/bp_daypack.mdl - basic small mud hacki
//  models/eft_props/gear/backpacks/bp_forward.mdl - sport backpack russia
//  models/eft_props/gear/backpacks/bp_gr99_t30_b.mdl - big-medium grey backpack
//  models/eft_props/gear/backpacks/bp_gr99_t30_m.mdl - green yellow hacki big mediom
//  models/eft_props/gear/backpacks/bp_anatactical_beta.mdl medium green
//  models/eft_props/gear/backpacks/bp_oakley_mechanism.mdl grey medium
//  models/eft_props/gear/backpacks/bp_piligrimm.mdl blue black tourist backpack
//  models/eft_props/gear/backpacks/bp_tactical_backpack.mdl small tackickal
//  models/eft_props/gear/backpacks/bp_vkbo.mdl VESHMESHOK
//  models/eft_props/gear/backpacks/bp_mbss.mdl smal grey
//  models/eft_props/gear/backpacks/bp_med_bag.mdl medical sport backpack
// models/eft_props/gear/backpacks/bp_scav_backpack.mdl
-- local size_bdy =  Vector(0.9,0.9,0.9)
-- local pos_bdy =   Vector(-2.7,-0.2,0)
-- local ang_bdy =   Angle(-93,0,90)

-- local size_head = Vector(0.95,0.95,0.95)
-- local pos_head =  Vector(0.5,2.2,0.15)
-- local ang_head =  Angle(-80,0,-90)

-- local size_eye =  Vector(0.95,0.95,0.95)
-- local pos_eye =   Vector(0.45,2.1,0.12)
-- local ang_eye =   Angle(-80,0,-90)

-- local size_arms = Vector(0.9,0.9,0.9)

-- local pos_rarm =  Vector(0,6.7,0.8)
-- local ang_rarm =  Angle(180,90,5)

-- local pos_larm =  Vector(0,6.7,-0.8)
-- local ang_larm =  Angle(0,-90,-5)

local size_bdy =  Vector(0.9,0.9,0.9)
local pos_bdy =   Vector(-2.7,-0.2,0)
local ang_bdy =   Angle(-93, 0, 90)

local base_EquipModelDraw = {
    model = "",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = pos_bdy,
    offset_ang  = ang_bdy,
    size = 0.85,
}

local ENT = {}

ENT.Base = "gs_equip"

ENT.Name  = "Duffle bag"
ENT.Desc  = "Old sport bag"
ENT.Model = "models/eft_props/gear/backpacks/bp_forward.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.PrintName = ENT.Name
ENT.Spawnable = true
ENT.Category = "Polar Station: Backpacks"

ENT.IsContainer = true
ENT.MaxItems    = 6
ENT.ItemMaxSize = ITEM_MEDIUM

ENT.TypeEquip   = "BACKPACK"

ENT.EquipModelDraw = {
    model       = "models/eft_props/gear/backpacks/bp_forward.mdl",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = pos_bdy,
    offset_ang  = ang_bdy,
    size = 0.85,
}

ENT.HandOffsetVec = Vector(5, 20, -4)
ENT.HandOffsetAng = Angle(0, 0, 180)

ENT.PrintName = ENT.Name

function ENT:ItemInteraction(ent)
    return self:InsertItemInContainer(ent)
end

AddEntItem(ENT, "bp_dufflebag")

local function fast_backpack(id, name, desk, model, max_items, EquipModelDraw ) // if EquipModelDraw == true, then copy base and set model
    local ent = {}
    
    ent.PrintName = name
    ent.Name = name
    ent.Desc = desk
    ent.MaxItems = max_items
    ent.Model = model

    if EquipModelDraw == true then
        local base_emd = table.Copy(base_EquipModelDraw)
        base_emd.model = model
        ent.EquipModelDraw = base_emd

        //PrintTable(ent.EquipModelDraw)
    elseif EquipModelDraw then
        ent.EquipModelDraw = EquipModelDraw
    end

    AddEntItem(ent, id, "bp_dufflebag")
end

fast_backpack("bp_daypack" ,"Daypack", "Some gray small pack", "models/eft_props/gear/backpacks/bp_daypack.md", 5, true )
fast_backpack("bp_grizli_g" ,"Backpack Grizli", "Some big grey backpack", "models/eft_props/gear/backpacks/bp_gr99_t30_b.mdl", 6, true )
fast_backpack("bp_grizli_gy" ,"Backpack Grizli-F", "Haki skibidi backpack", "models/eft_props/gear/backpacks/bp_gr99_t30_m.mdl", 6, true )
fast_backpack("bp_polar" ,"Backpack Polar","Haki skibidi backpack", "models/eft_props/gear/backpacks/bp_anatactical_beta.mdl", 5, true )
fast_backpack("bp_cargobox" ,"Cargobag","Some stashiest back", "models/eft_props/gear/backpacks/bp_oakley_mechanism.mdl", 5, true )
fast_backpack("bp_tourist" ,"Tourist rucksack", "Dibilniy rucksack", "models/eft_props/gear/backpacks/bp_piligrimm.mdl", 5, true )
fast_backpack("bp_tactikool" ,"Tactikool bag","If you want to be a tacktickool master - kys now", "models/eft_props/gear/backpacks/bp_tactical_backpack.mdl", 4, true )
fast_backpack("bp_meshok" ,"Meshok", "thats all you need", "models/eft_props/gear/backpacks/bp_vkbo.mdl", 5, true )
fast_backpack("bp_mtgs3" ,"MTGS-3","The big brand of bags and other work equip", "models/eft_props/gear/backpacks/bp_mbss.mdl", 5, true )
fast_backpack("bp_megbag" ,"Medical bag","red cross backpack, you can hit with him somebody", "models/eft_props/gear/backpacks/bp_med_bag.mdl", 5, true )
fast_backpack("bp_scand" ,"Scandinavia bag", "Epic","models/eft_props/gear/backpacks/bp_scav_backpack.mdl", 5, true )




