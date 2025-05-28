SWEP.Author			    = ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category           = "GS"
SWEP.SlotPos            = 1

SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
SWEP.HoldType = "pistol"


SWEP.GMSWEP = true


SWEP.Primary.Automatic = false
SWEP.PrimarySound = "Weapon_Crowbar"
--[[
SWEP.Entity_Data = {}
SWEP.Entity_Data.Name = "tool"
SWEP.Entity_Data.Desc = "desc"
SWEP.Entity_Data.ENUM_Type = GS_ITEM_TOOL
SWEP.Entity_Data.Type = "toolname"

SWEP.Private_Data = {}
--]]
game.AddParticles( "particles/hunter_flechette.pcf" )
game.AddParticles( "particles/hunter_projectile.pcf" )

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    // from flechette_gun
	self:SetNextPrimaryFire( CurTime() + 0.1 )

	self:EmitSound( ShootSound )
	self:ShootEffects()

	if ( CLIENT ) then return end

	SuppressHostEvents( NULL ) -- Do not suppress the flechette effects

	local ent = ents.Create( "hunter_flechette" )
	if ( !IsValid( ent ) ) then return end

	local owner = self:GetOwner()

	local Forward = owner:GetAimVector()

	ent:SetPos( owner:GetShootPos() + Forward * 32 )
	ent:SetAngles( owner:EyeAngles() )
	ent:SetOwner( owner )
	ent:Spawn()
	ent:Activate()

	ent:SetVelocity( Forward * 2000 )
end

function SWEP:SecondaryAttack()
end

function SWEP:Throw(force)
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:ItemHide()
    // hide item - make invinsible, without physic, hide in client, parent to owner
    if self.Hided then
        LogColor("w", "whou, item already hided, but need moore!? - "..tostring(self))
        return
    end

    self.HideData = {}
    self.HideData.MT = ent:GetMoveType()
    self.HideData.SD = ent:GetSolid()
    
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
    
    self.Hided = true
end

function SWEP:SetParentContainer(parent)
    if !parent:IsValid() then
        return
    end

    self:SetPos(parent:GetPos())
    self:SetParent(parent)

    self.Container = parent
end

function SWEP:ItemGetParentContainer()
    return self.Container
end

function SWEP:ItemRecover(pos)
    ent:SetParent(nil)
    ent:SetPos(pos)
    ent:SetMoveType(ent.HideData.MT)
    ent:SetSolid(ent.HideData.SD)
    ent:SetNoDraw(false)
    
    ent.HideData = nil
    ent.Hided = false
end

function RemoveItemFromInv(ent)
    if ent.Container:IsPlayer() then
        player_manager.RunClass(ent.Container, "RemoveFromInventary", ent)
    end
    
    if IsValid(ent.Container) and ent.Container.RemoveItem then
        -- for sync
        ent.Item_Container:RemoveItem(self)
    end

    if ent.Item_Container then
        for _, item in pairs(ent.Private_Data.Items) do
            ItemRecover(item, ent:GetPos())
        end
    end
end