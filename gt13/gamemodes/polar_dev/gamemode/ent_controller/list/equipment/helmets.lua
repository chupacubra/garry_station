// models/eft_props/gear/helmets/helmet_6b47.mdl green
// models/eft_props/gear/helmets/helmet_achhc_b.mdl black
// models/eft_props/gear/helmets/helmet_achhc_g.mdl 

// models/eft_props/gear/helmets/helmet_altyn.mdl
// models/eft_props/gear/helmets/helmet_shpm.mdl ПОЖАРНЫЙ

// models/eft_props/gear/helmets/helmet_ulach_b.mdl

// models/eft_props/gear/helmets/helmet_s_sh_68.mdl dedov shlem

// models/eft_props/gear/helmets/helmet_psh97_jeta.mdl some big swat helmet

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

local function fast_hat(id, name, desk, model, protect ) // if EquipModelDraw == true, then copy base and set model
    local ent = {}
    
    ent.PrintName = name
    ent.Name = name
    ent.Desc = desk
    ent.Model = model

    ent.Protection = protect

    if !EquipModelDraw then
        local base_emd = table.Copy(base_EquipModelDraw)
        base_emd.model = model
        ent.EquipModelDraw = base_emd

        //PrintTable(ent.EquipModelDraw)
    else
        ent.EquipModelDraw = EquipModelDraw
    end

    AddEntItem(ent, id, "h_redcap")
end


fast_hat("h_helmet_g", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_6b47.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmeta_b", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_achhc_b.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmeta_g", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_achhc_g.mdl ", {[D_BRUTE] = 40})
fast_hat("h_helmet_altyn", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_altyn.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmet_fire", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_shpm.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmet_ulach", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_ulach_b.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmet_sov", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_s_sh_68.mdl", {[D_BRUTE] = 40})
fast_hat("h_helmet_swat", "Helmet", "iron hat", "models/eft_props/gear/helmets/helmet_psh97_jeta.mdl", {[D_BRUTE] = 40})

