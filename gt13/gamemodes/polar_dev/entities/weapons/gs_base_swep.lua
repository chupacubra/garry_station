SWEP.Author			    = ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.Category           = "GS"
SWEP.SlotPos            = 1

SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.HoldType = "crowbar"

SWEP.GMSWEP = true

SWEP.Primary.Automatic = true
SWEP.PrimarySound = "Weapon_Crowbar"
SWEP.PrimaryDelay = 0.5

SWEP.WorldModelCustom     = false
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}
SWEP.WorldModelOffsets    = {}


function SWEP:UpdateHoldType()
    self:SetHoldType(self.HoldType)
end

function SWEP:Initialize()
    self:UpdateHoldType()
end

function SWEP:Primary()
    //
    return true
end

function SWEP:Secondary()
    //
    return true
end

function SWEP:PrimaryAttack()
    if self:Primary() then
        self:SetNextPrimaryFire(CurTime() + self.PrimaryDelay)
    end
end

function SWEP:SecondaryAttack()
    if self:Secondary() then
        self:SetNextSecondaryFire(CurTime() + self.PrimaryDelay)
    end
end

function SWEP:Throw(force)
end

function SWEP:Deploy()
    self:UpdateHoldType()
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:UpdateWModelBodyGroups(toset)
    if SERVER then
        self:SetNW2String("Bodygroup", toset)
    else
        self:ChangeBodyGroup(toset)
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        self:InitializeWM()
        self:SetNW2VarProxy("Bodygroup", function(ent, name, old, new)
            self:UpdateWModelBodyGroups(new)
        end)
    end
    self.Init = true
end

function SWEP:InitializeWM()
    if !self.WorldModelCustom then return end

    self.WMGun = ClientsideModel(self.WModel)
    self.WMGun:SetModelScale(self.WorldModelScale or 1)
    self.WMGun:SetNoDraw(true)
    
    if self.WorldModelBodyGroups["base"] then
        self:ChangeBodyGroup("base")
    end
end


function SWEP:DrawWorldModel()
    if !self.WorldModelCustom then
        self:DrawModel()
        return
    end

    local ply = self:GetOwner()
    local gun = self.WMGun

    if (IsValid(ply)) then
        local offsetVec = self.WorldModelOffsets.pos
        local offsetAng = self.WorldModelOffsets.ang
        
        local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if !boneid then return end

        local matrix = ply:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        gun:SetRenderOrigin(newPos)
        gun:SetRenderAngles(newAng)

        gun:SetupBones()
	    gun:DrawModel()
    else
        // need add offsets
        //print(self:GetParent())
        local parent = self:GetParent()
        if IsValid(parent) then
            print(parent, parent.IsContainer)
            if parent.IsContainer then return end // это может означать только одно - предмет спрятан в контейнер и он не должен рисоваться
        end

        local w_offset_pos = self.WorldModelDrawOffset.pos
        local w_offset_ang = self.WorldModelDrawOffset.ang

        gun:SetRenderOrigin(self:LocalToWorld(w_offset_pos))
        gun:SetRenderAngles(self:LocalToWorldAngles(w_offset_ang))
	    gun:DrawModel()
        
    end
end

