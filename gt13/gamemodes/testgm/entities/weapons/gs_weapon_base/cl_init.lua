include("shared.lua")

function SWEP:Initialize()
    self.delay = CurTime()
    --self.automatic = false
end

function SWEP:PrimaryAttack()
    if self.delay > CurTime() then
        return
    end

    self.delay = CurTime() + self.shoot_speed
    self:EmitSound("Weapon_Pistol.Single")
    self:ShootEffects()
end

function SWEP:SecondaryAttack()
    if self.delay > CurTime() then
        return
    end

    self.delay = CurTime() + self.shoot_speed
    self:EmitSound("Weapon_Pistol.Single")
    self:ShootEffects()
end

function SWEP:GetContextMenu()
    local contextButton = {}
    
    if self.CanExamine then
        local button = {
            label = "Examine",
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
    --self.GunModel = ClientsideModel(SWEP.WorldModel)

    --WorldModel:SetSkin(1)
    --self.GunModel:SetNoDraw(true)
end



net.Receive("gs_weapon_base_effect", function()
    local ef = {}
    ef.entity = net.ReadEntity()
    ef.origin = net.ReadVector()
    ef.startpos = net.ReadVector()
    ef.surfaceprop = net.ReadInt(8)
    --damagetype on client
    ef.hitbox = net.ReadInt(8)

    local effect = EffectData()

    effect:SetEntity(ef.entity)
    effect:SetOrigin(ef.origin )
    effect:SetStart(ef.startpos)
    effect:SetSurfaceProp(ef.surfaceprop)
    effect:SetDamageType(DMG_BULLET) 
    effect:SetHitBox(ef.hitbox)
    util.Effect( "Impact", effect )

    --Origin, Scale, Flags (TRACER_FLAG_WHIZ), Start
    local traceEf = EffectData()
    traceEf:SetOrigin(ef.origin)
    traceEf:SetScale(5000)
    traceEf:SetFlags(4)
    traceEf:SetStart(ef.startpos)
    util.Effect( "Tracer", traceEf )
end)

function SWEP:Examine()
    return {self.Entity_Data.Name, self.Entity_Data.Desc}
end

function SWEP:GS_Pickup()
    net.Start("gs_ply_pickup_weapon")
    net.WriteEntity(self)
    net.WriteEntity(LocalPlayer())
    net.SendToServer()
end
