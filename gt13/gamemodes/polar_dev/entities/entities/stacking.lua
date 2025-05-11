// Stacking item in 1 stack
// suitable for materials

ENT.Stackable   = false
ENT.MaxStack    = 5
ENT.Stack       = 1

function ENT:SetStack(amount)
    if !self.Stackable then return end
    if amount < 1 then
        self:Remove()
    end
    self.Stack = math.Clamp(amount, 1, self.MaxStack)
end

function ENT:GetStack()
    return self.Stack
end

function ENT:AddToStack(amount)
    local remains = 0;
    if amount > 0 then
        remains = (self.MaxStack - self.Stack) - amount
    end
    self:SetStack(math.Clamp(self.Stack + amount, 0, self.MaxStack))
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