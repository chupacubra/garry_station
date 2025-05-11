//
//  the problems
//  из-за того что у нас нстандартная система патронов, магазинов, возможны проблемсы
//  с предиктишионом выстрела на клиенте. Есть варианты как сообщить сколько патронов у нас есть
//      При перезарядке отправлять на клиент сколько у нас патронов. Время во время перезарядки у нас хватит, чтобы понять сколько
//      у нас сейчас патронов
//
//  с заменой модели оружия на без магазина пока повременим
//  нужно побольше посмотреть на замену модели оружия в руках
//  с помощью нативных функций без создавания новой клиентсайд модели
//
//  кстати, упор идёт на first person view как на хомиграде
//
//  это база для магазиных ружей
//
//  нужно проверить клиентсайд модели парентить к костям ent:FollowBone

SWEP.Author			    = "Devil right hand"
SWEP.Contact			= "Poeli"
SWEP.Purpose			= "KILL!"
SWEP.Instructions		= "KILL!"

SWEP.ViewModel          = ""
SWEP.WorldModel         = ""
SWEP.WorldModelLoaded   = ""
SWEP.ModelOffset = nil // if model need offset

/*
SWEP.WorldModels = {
    load = {
        "loaded model"
        type = "pistol"
        clientside-model = false
    },
    
    unload = {
        "unloade" model
        offsets
        type = "pistol" // holdtype povedenie, if nil use SWEP.HoldType
    }
}
*/

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Boomstick"
SWEP.Desc = "Palka-ubivalka"

SWEP.SoundShot   = ""
SWEP.SoundReload = ""
SWEP.Silenced    = false

//SWEP.MuzzlePos      = nil
//SWEP.ShellPos       = nil
//SWEP.MSUseFromModel = "load"

SWEP.HoldType       = "pistol"  // basic holdtype

SWEP.NeedTwoHand    = false     //
// if holdtype2 == nil then cant two handling

// its all a basic settings of weapon, "bullet" settings have a multiplier for this
SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

// active values
//SWEP.Magazine   = nil
SWEP.LastBullet = nil
SWEP.Active     = false
SWEP.Use2Hand   = false

local function MagHaveAmmo(ent)
    // check if have magazine bullets
    return #ent.Magazine > 0
end

function SWEP:SetupDataTables()
    self:NetworkVar("Entity", 0, "Magazine")
end

function SWEP:ItemInteract(ent, ply)
    if !ent.IsMagazine then return false end
    if ent.Gun != self:GetClass() then return false end
    return self:Reloading(ent)
end

function SWEP:Reloading(ent)
    //if CLIENT then return end
    // we have ent mag
    // and we have our mag in gun
    if self.Zoom then return false end
    if self:GetMagazine():IsValid() then
        // changiong?
        self:StripMag()
    end

    itm:MoveItemInContainer(self)
    return false
end

function SWEP:Reload()
    // strip mag
    self:StripMag()
    // TODO: reloading from equip unload
end

function SWEP:Deploy()
    //self.Active = true
    self:UpdateHoldWeapon()
    self:UpdateModelState()
end

function SWEP:Holster()
    //self.Active = false
    //self:UpdateHoldWeapon()
end

function SWEP:UpdateHoldWeapon()
    local holdtype = self.HoldType
    //self:SetHoldType(self:GetHoldType())
    if holdtype == "pistol" then
        if self.Zoom then holdtype = "revolver" end
    elseif holdtype == "shotgun" then
        if self.Zoom then holdtype = "ar2" end
    elseif holdtype == "ar2" then
        if self.Zoom then holdtype = "rpg" end
    end

    if self.NeedTwoHand and HandsFree(self:GetOwner()) then
        holdtype = "passive"
    end
    self:SetHoldType(holdtype)
end

/*
MAG.MagazineFor = {"9mm", "9mm", "9mm", "9mm", "9mm"}
*/
local spread_offset = 10

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
    self:EmitSound(SWEP.SoundShot)
end

function SWEP:ShotBullet(bullet)
    local bul = GS_Ammo.Get(bullet)
    local spread = spread_offset * self.ShotSpread

    local bullet = {
        Damage = bullet.damage,
        Force  = bullet.damage * 2,
        TracerName = "Tracer",
        Src = self.Owner:GetShootPos(),
        Dir = self.Owner:GetAimVector(),
        Spread = Vector(spread, spread * 1.5,0),
        Num = num or 1,
    }

    self:FireBullets(bullet, false)
    self:KickRecoil()
end

function SWEP:CalcRecoilMul()
    // calc recoil for ply
    local ply = self:GetOwner()

    local mul = 1
    if ply:KeyDown(IN_DUCK) then
        mul = 0.5
    elseif !ply:OnGround() then
        mul = 1.5
    end
    if ply:IsWalking() then
        mul = mul * 2 and ply:IsSprinting() or mul * 1.5
    end
    if self.Use2Hand and !self.NeedTwoHand then // for pistols
        mul = mul * 0.7 
    end
    return mul
end

function SWEP:KickRecoil()
    if SERVER then return end
    local mul = self:CalcRecoilMul()

    local KickUp            = self.RecoilUp * mul
    local KickDown          = self.Recoil * mul
    local KickHorizontal    = self.Recoil * mul

    local aRecoil = Angle(math.random(-KickDown,-KickUp),math.random(-KickHorizontal,KickHorizontal),0)

    self.Owner:ViewPunch(aRecoil)

    local aEyes = self.Owner:EyeAngles()
    
    aEyes:SetUnpacked(aEyes.p + aRecoil.p,aEyes.y + aRecoil.y,0)
    self.Owner:SetEyeAngles(aEyes)
end

function SWEP:ReloadEffect()
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:EmitSound(self.ReloadSound)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    self.ReloadTime = CurTime() + self:SequenceDuration() + 0.1
    self.Reloading = true
end

function SWEP:HaveMag()
    return IsValid(self:GetMagazine())
end

function SWEP:DropMag()
    if CLIENT then return end
    local mag = self:GetMagazine()
    if !IsValid(mag) then return end
    mag:ItemRecover(self:GetPos() + ply:GetAngles():Forward() * 10)
end

function SWEP:StripMag(silent)
    if !self:HaveMag() then return end
    // drop mag, in this dont load big
    // change worldmodel
    //1. Check hands, if hand free, strip mag to him
    local hands = GetHands(ply)
    if #hands > 0 then
        if !hands[1]:HaveItem() then
            hands[1]:InsertItem(self:GetMagazine())
        else
            self:DropMag()
        end
    else
        self:DropMag()
    end

    self:SetMagazine(nil)
    if silent then
        self:ChangeWorldModel("unload")
        self:ReloadEffect()
    end
end

//  ENT.Class = "weap_mag"
//  ENT.Magazine = {...}
//

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end

    self.LastShot = CurTime()
    local mag = self:GetMagazine()
    local bullet = mag.Magazine[#mag.Magazine]
end

function SWEP:CanPrimaryAttack()
    // going to PrimaryAttack
    //if CLIENT then return false end
    //if self:HaveMag() and
    if self.Reloading then return false end
    if !self:HaveMag() then return false end
    if #ent.Magazine == 0 then return false end
    if self.NeedTwoHand and !HandsFree(self:GetOwner()) then return false end
    return true
end

local zoom_time = 0.5
function SWEP:TranslateFOV( fov )
    return Lerp((CurTime() - self.ZoomTime) / zoom_time * (1 and self.Zoom or -1), fov - 30, fov)
end

function SWEP:CanZoom()
    if self.HoldType != "pistol" then return true end
    // if pistol check another hand
    if HandsFree(self:GetOwner()) then return true end 
end


function SWEP:SecondaryAttack()
end

function SWEP:Think()
    local ply = self:GetOwner()
    if !IsValid(ply) then return end

    local zooming = ply:KeyDown(IN_ATTACK2)
    if zooming != self.Zoom then
        if zooming == true and !self:CanZoom() then return end
        self.ZoomTime = CurTime()
        self.Zoom = ply:KeyDown(IN_ATTACK2)
        self:UpdateHoldWeapon()
    end

    if self.Reloading then
        if self.ReloadTime <= CurTime() then
            self.Reloading = false
        end
    end

    //self:UpdateHoldWeapon()
end

function SWEP:ClearWorldModel()
    if IsValid(self.ClWorldModel) then self.ClWorldModel:Remove() end
end

function SWEP:ChangeWorldModel(id)
    if !self.WorldModels[id] then return end
    local data = self.WorldModels[id]

    self:ClearWorldModel()
    
    // if model is not clientside then install simple worldmodel
    if !data.ClientModel then
        self.WorldModel = data.model
        self:SetModel(data.model) // check this!
    else
        // create clientside model
        if SERVER then return end
        local ply = self:GetOwner()

        local offsetPos = model.pos or Vector(0, 0, 0)
        local offsetAng = model.ang or Angle(0, 0, 0)
 
        local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")

        if !boneid then return end

        if data.HandOffset then
            // offsetting useing a bonepos of hand
            // with matrix and translations./..
        else
            // offsetting using a ply bos
            // this simple bonemerge, and its work when i tested this
            local mdl = ClientsideModel(data.model)
            mdl:SetPos(ply:LocalToWorld( offsetPos ))
            mdl:SetAngles(ply:GetAngles() + offsetAng )
            mdl:SetModelScale(data.scale)

            mdl:FollowBone(ply, boneid)
            self.ClWorldModel = mdl
        end
    end

    self.ModelState = id
end