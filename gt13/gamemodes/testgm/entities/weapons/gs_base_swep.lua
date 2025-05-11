// shared functional with all SWEPs

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