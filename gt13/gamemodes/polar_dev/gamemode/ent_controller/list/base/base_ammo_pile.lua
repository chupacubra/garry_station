local ENT = {}

ENT.Base = "gs_entity"

ENT.PrintName = "ammo pile"
ENT.Name  = "patronchiki"
ENT.Desc  = "zhri svinec"
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.Size  = ITEM_SMALL

ENT.Stackable   = true
ENT.MaxStack    = 20

ENT.Spawnable = false
ENT.Category = "Developing"

ENT.Calibr = "9mm"


AddEntItem(ENT, "base_ammopile")

local function GenerateAmmoPile(weap_class, mag_data)
    local ENT = {}

    ENT.AcceptCalibr = mag_data.accept
    ENT.MaxAmmo = mag_data.max
    ENT.Model = mag_data.model
    ENT.MagWeaponType = weap_class

    ENT.Name = mag_data.name
    ENT.Desk = mag_data.desk

    ENT.Spawnable = true
    AddEntItem(ENT, "mag_"..weap_class, "base_magazine")
end
