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

local size_bdy =  Vector(0.9,0.9,0.9)
local pos_bdy =   Vector(-2.7,-0.2,0)
local ang_bdy =   Angle(-93,0,90)


local base_EquipModelDraw = {
    model = "",
    bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = pos_bdy,
    offset_ang  = ang_bdy,
    size = 1,
    mat = ""
}


local ENT = {}

ENT.Base = "gs_equip"

ENT.Name  = "Armor vest"
ENT.Desc  = "Security"
ENT.Model = "models/eft_props/gear/armor/ar_kirasa_black.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Polar Station: Armor"


ENT.TypeEquip   = "VEST"

ENT.EquipModelDraw = {
    model       = "models/eft_props/gear/armor/ar_kirasa_black.mdl",
    //bodygroups  = "1",
    bone        = "ValveBiped.Bip01_Spine2",
    offset_pos  = pos_bdy,//Vector(-4.5, 5,0),
    offset_ang  = ang_bdy,
    size = 0.9,
}

ENT.HandOffsetVec = Vector(-2,0,10)
ENT.HandOffsetAng = Angle(0,0,-90)

ENT.Protection = {
    [D_BRUTE] = 10
}

AddEntItem(ENT, "dev_armorvest")

local function fast_vest(id, name, desk, model, protect, EquipModelDraw, material  ) // if EquipModelDraw == true, then copy base and set model
    local ent = {}
    
    ent.PrintName = name
    ent.Name = name
    ent.Desc = desk
    //ent.MaxItems = max_items
    ent.Model = model
    ent.Protection = protect
    ent.Material = material
    if EquipModelDraw == true then
        local base_emd = table.Copy(base_EquipModelDraw)
        base_emd.model = model
        ent.EquipModelDraw = base_emd

        //PrintTable(ent.EquipModelDraw)
    elseif EquipModelDraw then
        ent.EquipModelDraw = EquipModelDraw
    end

    AddEntItem(ent, id, "dev_armorvest")
end


fast_vest("av_greenkirasa" ,"Armor vest", "Security", "models/eft_props/gear/armor/ar_kirasa_camo.mdl", {[D_BRUTE] = 15} , true )
fast_vest("av_armorkirasa" ,"Armor kirasa", "for big Security", "models/eft_props/gear/armor/ar_korundvm.mdl", {[D_BRUTE] = 30} , true )
fast_vest("av_lightvest" ,"Light vest", "for small Security", "models/eft_props/gear/armor/ar_slick_b.mdl", {[D_BRUTE] = 10} , true )
fast_vest("av_lightvestg" ,"Light vest", "for small Security", "models/eft_props/gear/armor/ar_slick_o.mdl", {[D_BRUTE] = 10} , true )
fast_vest("av_medvest" ,"Medium vest", "Normal grey vest", "models/eft_props/gear/armor/ar_gjel.mdl", {[D_BRUTE] = 20} , true )
fast_vest("av_armyvest" ,"Army vest", "Skibidi shield", "models/eft_props/gear/armor/ar_iotv.mdl", {[D_BRUTE] = 25} , true )
fast_vest("av_civil" ,"Civil armorvest", "Classic vest", "models/eft_props/gear/armor/ar_paca.mdl", {[D_BRUTE] = 15} , true )
fast_vest("av_bigkirasa" ,"Tank kirasa", "invincible", "models/eft_props/gear/armor/cr/cr_6b3.mdl", {[D_BRUTE] = 40} , true )
fast_vest("av_press" ,"Press vest", "unreliable", "models/eft_props/gear/armor/ar_beetle3.mdl", {[D_BRUTE] = 15} , true )
fast_vest("av_blackkirasa" ,"Armor vest", "Security", "models/eft_props/gear/armor/ar_kirasa_black.mdl", {[D_BRUTE] = 15} , true )

fast_vest("av_blackkirasa_gco" ,"Armor vest", "Sus vest", "models/eft_props/gear/armor/ar_kirasa_black.mdl", {[D_BRUTE] = 15} , true, "models/eft/armor/mats/armor_kora_kulon_black_d_gco")
fast_vest("av_armorkirasa_gco" ,"Armor kirasa gco", "for big sus Security", "models/eft_props/gear/armor/ar_korundvm.mdl", {[D_BRUTE] = 30} , true, "models/eft/armor/armor_korundvm_gco")
fast_vest("av_lightvest_gco" ,"Light vest", "sus vest", "models/eft_props/gear/armor/ar_slick_b.mdl", {[D_BRUTE] = 10} , true, "models/eft/armor/armor_slick_black_gco" )





