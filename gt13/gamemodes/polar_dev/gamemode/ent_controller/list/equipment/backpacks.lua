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

local ENT = {}

ENT.Base = "gs_equip"

ENT.Name  = "Duffle bag"
ENT.Desc  = "Old sport bag"
ENT.Model = "models/eft_props/gear/backpacks/bp_forward.mdl"
ENT.Size  = ITEM_MEDIUM

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
    offset_pos  = Vector(-2.7,-0.2,0),
    offset_ang  = Angle(-93,0,90),
    size = 0.85,
}

ENT.HandOffsetVec = Vector(5, 20, -4)
ENT.HandOffsetAng = Angle(0, 0, 180)

ENT.PrintName = ENT.Name

function ENT:ItemInteraction(ent)
    return self:InsertItemInContainer(ent)
end

AddEntItem(ENT, "test_dufflebag")
