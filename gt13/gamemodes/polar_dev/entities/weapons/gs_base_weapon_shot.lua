SWEP.Base = "gs_base_weapon"

SWEP.IternalMagazine = true
SWEP.MaxAmmo = 5
SWEP.AcceptCalibr = {
    ["12g"] = true,
    ["slug"] = true,
}

SWEP.SoundInsert = Sound("weapons/shotgun/shotgun_reload1.wav")
SWEP.SoundReloaded = Sound("weapons/shotgun/shotgun_cock.wav")

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        self:InitializeWM()
    else
        self.Magazine = {}
        self:SetNW2Int("Ammo", 0)
    end
    self.Init = true
end

function SWEP:GetContextButtons()
    if !IsValid(self:GetOwner()) then return {} end

    local buttons = table.Copy(self.ContextCallback or {})

    
    buttons["pop_bullet"] = {
        name = "Get bullet", -- ?
        func = function()
            local bullet = self:PopUpBulletFromMagazine()
        end,
        icon = "icon16/arrow_right.png",
    }


    buttons["drop"] = {
        name = "Drop",
        func = function()
            self:Drop()
        end,
        icon = "icon16/arrow_down.png",
    }
    return buttons
end



function SWEP:GetBulletsInMag()
    if SERVER then
        
        local ammo = #self.Magazine
        self:SetNW2Int("Ammo", ammo)
        print(ammo)
        return ammo
    else
        print(self:GetNW2Int("Ammo"))

        return self:GetNW2Int("Ammo")
    end
end

function SWEP:PopUpBulletFromMag()
    if SERVER then
        local bullet = table.remove(self.Magazine, #self.Magazine)

        local next_bullet = self.Magazine[#self.Magazine]
        self:SetNW2Int("Ammo", #self.Magazine)
        self:SetNWString("NextCalibr", next_bullet or "" )
        
        return bullet
    else
        local bullet = self:GetNWString("NextCalibr")
        self:SetNW2Int("Ammo", self:GetNWInt("Ammo") - 1)

        return bullet
    end
end


-- function SWEP:InsertBullet(item)
--     // shotguns, bolt action rifles have iternal mag (tube or smthng)
--     if self:GetOwner():GetActiveWeapon() != self then return end
--     if CLIENT then return end

--     if !item.AmmoPile then
--         return false
--     end

--     if !self.AcceptCalibr[item.Calibr] then 
--         return false
--     end
    
--     local stack = item:GetStack()
    
--     if stack < 1 then 
--         return false
--     end
    
--     table.insert(self.Magazine, item.Calibr)
--     self:SetNW2Int("Ammo", #self.Magazine)
--     self:SetNWString("NextCalibr", item.Calibr)

--     item:SetStack(stack-1)
--     return false
-- end

function SWEP:InsertBullet(bullet)
    // shotguns, bolt action rifles have iternal mag (tube or smthng)
    if self:GetOwner():GetActiveWeapon() != self then return end
    if CLIENT then return false end

    
    if !self.AcceptCalibr[bullet] then 
        return false
    end
    
    -- local stack = item:GetStack()
    
    -- if stack < 1 then 
    --     return false
    -- end
    
    table.insert(self.Magazine, bullet)
    
    self:SetNW2Int("Ammo", #self.Magazine)
    self:SetNWString("NextCalibr", bullet)
    self:GetOwner():DoReloadEvent()

    //item:SetStack(stack-1)


    return true
end

function SWEP:FinishReload()
    sound.Play( self.SoundReloaded, self:GetPos(), 75, math.random( 100 - 10, 100 + 10 ))
end

function SWEP:ItemInteraction(item)
    local ply = self:GetOwner()
    if !IsValid(ply) then return end

    if !item.AmmoPile then
        return false
    end

    if !self.AcceptCalibr[item.Calibr] then 
        return false
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
            //sound.Play( self.SoundReloaded, self:GetPos(), 75, math.random( 100 - 10, 100 + 10 ))
            self:FinishReload()
            return
        end

        print(item, item.Calibr)

        local success, rstr_status = self:InsertBullet(item.Calibr)

        if rstr_status then
            RichTextPrint(rstr_status, ply)
        end
        if !success then 
            self:FinishReload()
            
            return
        end

        ammo_stack = ammo_stack - 1

        item:SetStack(ammo_stack)

        //sound.Play( table.Random(sounds), self:GetPos(), 75, math.random( 100 - 10, 100 + 10 ))
        sound.Play( self.SoundInsert, self:GetPos(), 75, math.random( 100 - 10, 100 + 10 ))

        if ammo_stack < 1 then 
            self:FinishReload()
            return
        end
        if self:GetNW2Int("Ammo") >= self.MaxAmmo then
            self:FinishReload()
            return
        end
        timer.Simple(0, function() ply:DoTask(task) end)
    end
    ply:DoReloadEvent()

    ply:DoTask(task)
    //return self:InsertBullet(item)    
end
