// shield vest protect
// models/eft_props/gear/armor/ar_kirasa_black.mdl some small and black
// models/eft_props/gear/armor/ar_kirasa_camo.mdl green
// models/eft_props/gear/armor/ar_korundvm.mdl black big armor
// models/eft_props/gear/armor/ar_slick_b.mdl small light black
// models/eft_props/gear/armor/ar_slick_o.mdl same but green
// models/eft_props/gear/armor/ar_gjel.mdl gray norm
// models/eft_props/gear/armor/ar_iotv.mdl green norm
// models/eft_props/gear/armor/ar_paca.mdl jmod norm armor vest
// models/eft_props/gear/armor/cr/cr_6b3.mdl olive big vest (with some pockets)
// models/eft_props/gear/armor/ar_beetle3.mdl press vest
/*
local ENT = {}

ENT.Base = "gs_equip"

ENT.Name  = "Duffle bag"
ENT.Desc  = "Cool shit"
ENT.Model = "models/eft_props/gear/backpacks/bp_forward.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Developing"

ENT.TypeEquip   = "BACKPACK"

ENT.EquipModelDraw = {
    model       = "models/eft_props/gear/backpacks/bp_forward.mdl",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = Vector(-2.7,-0.2,0),//Vector(-4.5, 5,0),
    offset_ang  = Angle(-93,0,90),
    size = 0.85,
}

ENT.HandOffsetVec = Vector(-2,0,10)
ENT.HandOffsetAng = Angle(0,0,-90)


function ENT:ItemInteraction(ent)
    return self:InsertItemInContainer(ent)
end

AddEntItem(ENT, "test_dufflebag")
*/