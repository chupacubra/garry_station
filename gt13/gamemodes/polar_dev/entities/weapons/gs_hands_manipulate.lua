// the main file already big

--[[
function SWEP:ManipulatorMode()
    if ( !self:GetOwner():KeyPressed( IN_RELOAD ) ) then return end

    if self:GetNWBool("FightHand") then
        return
    end

    self:SetNWBool( "ManipMode", !self:GetNWBool("ManipMode") )

    if self:GetNWBool("ManipMode") then
        GS_ChatPrint(self:GetOwner(), "You prepared hands to manipulate object", Color(50,255,50))
    else
        GS_ChatPrint(self:GetOwner(), "You now don't manipulate object", Color(50,200,50))
        self:ManipModeReset()
    end
end
--]]

function SWEP:ManipModeReset()
    if IsValid(self.CarryHack) then
        self.CarryHack:Remove()
    end
  
    if IsValid(self.CarryConstr) then
        self.CarryConstr:Remove()
    end
    
    if !IsValid(self.ManipEnt) then
        return
    end

    local phys = self.ManipEnt:GetPhysicsObject()
    if IsValid(phys) then
        phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
        phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
        phys:EnableCollisions(true)
        phys:EnableGravity(true)
        phys:EnableDrag(true)
        phys:EnableMotion(true)
    end

    if (not keep_velocity) and (no_throw or self.ManipEnt:GetClass() == "prop_ragdoll") then
        KillVelocity(self.ManipEnt)
    end

    self.dt.carried_rag = nil

    self.ManipEnt = nil
    self.CarryHack = nil
    self.CarryConstr = nil
    self.ManipRotate = nil

    self:SetManipMode(false)
end

function SWEP:ManipDrop()
    self.CarryConstr:Remove()
    self.CarryHack:Remove()

    local ent = self.ManipEnt

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
       phys:EnableCollisions(true)
       phys:EnableGravity(true)
       phys:EnableDrag(true)
       phys:EnableMotion(true)
       phys:Wake()
       phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 500)

       phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
       phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
    end

    -- Try to limit ragdoll slinging
    if no_throw or ent:GetClass() == "prop_ragdoll" then
       KillVelocity(ent)
    end

    ent:SetPhysicsAttacker(self:GetOwner())
end

function SWEP:ManipToggleRotate(direct, status)
    if status then
        self.ManipRotate = direct
    else
        if self.ManipRotate == direct then
            self.ManipRotate = nil
        end
    end
end

function SWEP:ManipPickupEnt()
    if IsValid(self.ManipEnt) then
        -- drop last ent pickup
        self:ManipModeReset()
        return
    end

    -- get code from TTT 'carry'
    
    local trace = self:MakeTrace()

    if IsValid(trace.Entity) then
        local ent = trace.Entity
        local entphys = ent:GetPhysicsObject()

        if IsValid(ent) and IsValid(entphys) then
            self.ManipEnt = ent
            self.CarryHack = ents.Create("prop_physics")

            if !IsValid(self.CarryHack) then
                return
            end

            self.CarryHack:SetPos(self.ManipEnt:GetPos())

            self.CarryHack:SetModel("models/weapons/w_bugbait.mdl")
   
            self.CarryHack:SetColor(Color(50, 250, 50, 240))
            self.CarryHack:SetNoDraw(true)
            self.CarryHack:DrawShadow(false)
   
            self.CarryHack:SetHealth(999)
            self.CarryHack:SetOwner(ply)
            self.CarryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.CarryHack:SetSolid(SOLID_NONE)
            
            self.CarryHack:SetAngles(self.ManipEnt:GetAngles())
   
            self.CarryHack:Spawn()

            local phys = self.CarryHack:GetPhysicsObject()
            if IsValid(phys) then
               phys:SetMass(200)
               phys:SetDamping(0, 1000)
               phys:EnableGravity(false)
               phys:EnableCollisions(false)
               phys:EnableMotion(false)
               phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            end
   
            entphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            local bone = math.Clamp(trace.PhysicsBone, 0, 1)
            local max_force = prop_force
   
            if ent:GetClass() == "prop_ragdoll" then
               self.dt.carried_rag = ent
   
               bone = trace.PhysicsBone
               max_force = 0
            else
               self.dt.carried_rag = nil
            end
   
            self.CarryConstr = constraint.Weld(self.CarryHack, self.ManipEnt, 0, bone, max_force, true)
            self:SetManipMode(true)
        end
    end

end

function SWEP:PushItem()
    if !self:GetNWBool("ManipMode") then
        return
    end

    local trace = self:MakeTrace()
    
    if !IsValid(trace.Entity) then
        return
    end

    local is_ragdoll = trace.Entity:GetClass() == "prop_ragdoll"

    local ent = trace.Entity
    local phys = ent:GetPhysicsObject()
    local pdir = trace.Normal * -1

    if is_ragdoll then
       phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)
    end

    if IsValid(phys) then
       MoveObject(phys, pdir, 6000, is_ragdoll)
       return
    end
end

if SERVER then
    function SWEP:Think()
        if !self:GetNWBool("ManipMode") then
            return
        end

        if !IsValid(self.ManipEnt) then
            self:ManipModeReset()
            return
        end

        if CurTime() > ent_diff_time then
            ent_diff = self:GetPos() - self.ManipEnt:GetPos()
            if ent_diff:Dot(ent_diff) > 40000 then
            self:Reset()
            return
            end
    
            ent_diff_time = CurTime() + 1
        end

        self.CarryHack:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 70)

        if self.ManipRotate then
            self.CarryHack:SetAngles(self.CarryHack:GetAngles() + DIR_ANG[self.ManipRotate])
        end

        self.ManipEnt:PhysWake()
    end
end