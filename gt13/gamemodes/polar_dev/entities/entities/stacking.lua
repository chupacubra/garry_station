// Stacking item in 1 stack
// suitable for materials
AddCSLuaFile()


ENT.Stackable   = false
ENT.MaxStack    = 20
ENT.SpawnStack  = 0
//ENT.Stack       = 1 // NWInt? YES
ENT.RemoveAfterOver = true

function ENT:SetStack(amount)
    if !self.Stackable then return end
    if amount < 1 then
        self:Remove()
    end

    self:SetNWInt("Stack", math.Clamp(amount, 1, self.MaxStack))
end

function ENT:GetStack()
    return self:GetNWInt("Stack")
end

function ENT:AddToStack(amount)
    local remains = 0
    local stack = self:GetStack()
    if amount > 0 then
        remains = (self.MaxStack - stack) - amount
    end
    self:SetStack(math.Clamp(stack + amount, 0, self.MaxStack))
    return remains
end

function ENT:AddFromStack(from)
    if from:GetClass() != self:GetClass() then return end
    local rem = self:AddToStack(self:GetStack())
    self:SetStack(rem)
end

function ENT:PhysicsCollide( data, phys )
    if !data.HitEntity then return end
    local to = data.HitEntity
    if to:GetClass() != self:GetClass() then return end
    if data.DeltaTime > 0.2 then
        if self:EntIndex() < to:EntIndex() then
            self:AddFromStack(to)
        end
    end
end