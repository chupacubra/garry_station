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
    net.Start("gs_weapon_base_strip_magazine")
    net.WriteEntity(self)
    net.WriteBool(false)
    net.SendToServer()
end

function SWEP:StripMagazineHand()
    net.Start("gs_weapon_base_strip_magazine")
    net.WriteEntity(self)
    net.WriteBool(true)
    net.SendToServer()
end

function SWEP:Examine()
    return {self.Entity_Data.Name, self.Entity_Data.Desc}
end

function SWEP:GS_Pickup()
    net.Start("gs_ply_pickup_weapon")
    net.WriteEntity(self)
    net.SendToServer()
end

function SWEP:ShootGunEffect()
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:EmitSound(self.Primary.Sound)
    self.Owner:MuzzleFlash()
    self:ShootEffects()
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

net.Receive("gs_weapon_base_effect", function()
    local ef = {}
    ef.entity = net.ReadEntity()
    ef.origin = net.ReadVector()
    ef.startpos = net.ReadVector()
    ef.surfaceprop = net.ReadInt(8)
    ef.hitbox = net.ReadInt(8)

    local effect = EffectData()

    effect:SetEntity(ef.entity)
    effect:SetOrigin(ef.origin )
    effect:SetStart(ef.startpos)
    effect:SetSurfaceProp(ef.surfaceprop)
    effect:SetDamageType(DMG_BULLET) 
    effect:SetHitBox(ef.hitbox)
    util.Effect( "Impact", effect )

    local traceEf = EffectData()
    traceEf:SetOrigin(ef.origin)
    traceEf:SetScale(10000)
    traceEf:SetFlags(4)
    traceEf:SetStart(ef.startpos)
    util.Effect( "Tracer", traceEf )
end)
