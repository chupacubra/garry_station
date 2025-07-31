local ENT = {}

ENT.Base = "gs_entity"

ENT.PrintName = "magazie"
ENT.Name  = "magazine base"
ENT.Desc  = "asdasd"
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.Size  = ITEM_SMALL

ENT.Spawnable = false
ENT.Category = "Developing"

ENT.IsWeaponMagazine = true
ENT.MagWeaponTyp = {
    // here entity weapon class
    ["gs_mp5"] = true
}

ENT.AcceptCalibr = {
    ["9mm"] = true,
}

ENT.MaxAmmo = 5

function ENT:ItemInteraction(item)
    // interaction with ammo boxes
end

function ENT:InsertBullet()
    if !self.AcceptCalibr[bullet] then 
        return false
    end

    if table.Count(self.Magazine.Ammo) + 1 > self.Magazine.MaxAmmo then
        return false
    end
    
    table.insert(self.Magazine.Ammo, bullet) 

end

AddEntItem(ENT, "base_magazine")


/*
mag_data = {
    accept = {
        ["9mm"] = true
    }
    max = 30,
    model = "smg_mp5_mag.mdl"
}
*/
local function GenerateMagazine(weap_class, mag_data)
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

GenerateMagazine("gs_mp5", {
    accept = {
        ["9mm"] = true,
    },
    max = 25,
    model = "models/weapons/unloaded/smg_mp5_mag.mdl",
    name = "MP5 Magazine",
    desk = "Weapon magazine",
})
