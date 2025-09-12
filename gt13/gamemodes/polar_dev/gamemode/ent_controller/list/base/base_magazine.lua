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

//ENT.HandOffsetAng = Angle()
//ENT.HandOffsetVec = Vector(3,-10,0)

function ENT:PostInit()
    self.Magazine = {}
end

local sounds = {
    Sound("weapons/357/357_reload1.wav"),
    Sound("weapons/357/357_reload1.wav")
}

function ENT:ItemInteraction(item, ply)
    // interaction with ammo boxes
    if !item.AmmoPile then return end

    if !self.AcceptCalibr[item.Calibr] then 
        RichTextPrint("{255 255 255}Mag dont accept this bullet...")
        return
    end

    if item:GetNWInt("Stack") < 1 then
        RichTextPrint("{255 255 255}its over...")
        return
    end

    local task = {}
    task.time = 0.8
    task.func = function()
        // зарядить в магазин
        // убрать из стека аммопила пулю
        // по новой до остановки или когда кончились пули
        if !IsValid(item) or !IsValid(self) or !IsValid(ply) then return end

        local ammo_stack = item:GetStack()

        if ammo_stack < 1 then
            RichTextPrint("{255 255 255}its over...", ply)
            return
        end

        local success, rstr_status = self:InsertBullet(item.Calibr)

        if rstr_status then
            RichTextPrint(rstr_status, ply)
        end
        if !success then return end

        ammo_stack = ammo_stack - 1

        item:SetStack(ammo_stack)

        sound.Play( table.Random(sounds), self:GetPos(), 75, math.random( 100 - 10, 100 + 10 ))

        if ammo_stack < 1 then return end
        if self:GetNWInt("Bullets") >= self.MaxAmmo then return end
        timer.Simple(0, function() ply:DoTask(task) end)
    end

    ply:DoTask(task)
end

function ENT:InsertBullet(bullet)
    //print(bullet)
    if !self.AcceptCalibr[bullet] then 
        return false, "{255 255 255}Mag dont accepts this calibr"
    end

    if table.Count(self.Magazine) + 1 > self.MaxAmmo then
        return false, "{255 255 255}Mag full!"
    end
    
    table.insert(self.Magazine, bullet)

    self:SetNWInt("Bullets", #self.Magazine)
    return true//, "{255 255 255} loaded some bullet"
end

function ENT:PopBullet()
    if #self.Magazine < 1 then return end
    local bul = table.remove(#self.Magazine)
    self:SetNWInt("Bullets", #self.Magazine)
    return bul
end

AddEntItem(ENT, "base_magazine")

local function GenerateMagazine(weap_class, mag_data)
    local ENT = {}

    ENT.AcceptCalibr = mag_data.accept
    ENT.MaxAmmo = mag_data.max
    ENT.Model = mag_data.model
    ENT.MagWeaponType = weap_class

    ENT.Name = mag_data.name
    ENT.Desc = mag_data.desc

    ENT.HandOffsetVec = mag_data.hand_vec
    ENT.HandOffsetAng = mag_data.hand_ang

    ENT.PrintName = ENT.Name or "magazine"
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
    desc = "Weapon magazine",
    hand_vec = Vector(3,-10,0),
    hand_ang = Angle(),
})


