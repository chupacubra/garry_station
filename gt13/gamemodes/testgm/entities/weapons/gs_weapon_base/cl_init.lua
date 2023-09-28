--[[
    DELETE DrawWorldModel
]]


include("shared.lua")

SWEP.OffsetVector = Vector(-1, -1, 0)

function SWEP:Initialize()
    self.delay = CurTime()
    self.WorldModelDraw = ClientsideModel(self.WorldModel, RENDER_GROUP_VIEW_MODEL_OPAQUE)
    self.WorldModelDraw:SetNoDraw(true)
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:GetContextMenu()
    local contextButton = {}
    
    if self.CanExamine then
        local button = {
            label = "Examine item",
            icon  = "icon16/eye.png",
            click = function()
                local examine = self:Examine()
                for k,v in pairs(examine) do
                    if k == 1 then
                        v = "It is ".. v
                    end
                    LocalPlayer():ChatPrint(v)
                end
            end
        }
        table.insert(contextButton, button)
    end

    if self.CanUse then
        local button = {
            label = "Use",
            icon  = "icon16/resultset_next.png" ,
            click = function()
                self:Use()
            end
        }
        table.insert(contextButton, button)
    end

    if self.IsGS_Weapon then
        local button = {
            label = "Use",
            icon = "icon16/add.png", 
            click = function()
                self:GS_Pickup()
            end
        }
        table.insert(contextButton, button)
    end

    if self.IsGS_Weapon then
        local button = {
            label = "Equip",
            icon  = "icon16/tag_orange.png",
            click = function()
                self:GS_Equip()
            end 
        }
        table.insert(contextButton, button)
    end

    return contextButton
end


function SWEP:Deploy() 

end

function SWEP:Holster()
    self.WorldModelDraw:SetParent(nil)
end

function SWEP:StripMagazine()
    self:GetOwner():ConCommand("gs_weapon_strip_magazine 0")
end

function SWEP:StripMagazineHand()
    self:GetOwner():ConCommand("gs_weapon_strip_magazine 1")
end

function SWEP:PumpSlide()
    self:GetOwner():ConCommand("gs_weapon_pump_slide")
end

function SWEP:Examine()
    return {self.Entity_Data.Name, self.Entity_Data.Desc}
end

function SWEP:GS_Pickup()
    net.Start("gs_ply_pickup_weapon")
    net.WriteEntity(self)
    net.SendToServer()
end

function SWEP:ShootGunEffect(num, spr)
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:EmitSound(self.Primary.Sound)
    self.Owner:MuzzleFlash()
    self:ShootEffects()

    spr = spr or self.spread

    print(num, spr)

    local bullet = {
        Damage = 0,
        Force = 0,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(spr, spr,0),
        Num = num or 1,
    }

    self:FireBullets(bullet, false)
end

function SWEP:ReloadGunEffect()
    if self:GetOwner():GetActiveWeapon() != self then
        return
    end
    self.Weapon:DefaultReload(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
end

function SWEP:DrawWorldModel()
    local _Owner = self:GetOwner()

    self.WorldModelDraw:SetModel( (self:GetNWBool("magazine")) and self.LoadedWorldModel or self.UnloadedWorldModel  )

    if !IsValid(self:GetParent()) then
        self.WorldModelDraw:SetRenderOrigin(self:GetPos())
        self.WorldModelDraw:SetRenderAngles(self:GetAngles())
        self.WorldModelDraw:SetupBones()
        self.WorldModelDraw:DrawModel()
    else
        self:DrawModel()
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    if !self.CanZoom then return end
    
    if self:GetNWBool("Zoom") then
        local Offset = self.ZoomOffset

        local Right 	= ang:Right()
        local Up 		= ang:Up()
        local Forward 	= ang:Forward()
         
        pos = pos + Offset.x * Right
        pos = pos + Offset.y * Forward
        pos = pos + Offset.z * Up
            
        return pos, ang
    end

end

function SWEP:TranslateFOV(fov)
    if self:GetNWBool("Zoom") then
        return fov - 30
    end
end

net.Receive("gs_weapon_base_effect", function()
    local gun = net.ReadEntity()
    local num = net.ReadUInt(5)
    local spr = net.ReadUInt(8) / 100

    gun:ShootGunEffect(num, spr)
end)
