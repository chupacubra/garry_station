hook.Add("PlayerSpawnedProp", "PGSpawn" , function( ply, model, entity )
    entity.Size = ITEM_SMALL
    entity.IsContainer = false
    entity.Name = "Prop"
end)

hook.Add( "AllowPlayerPickup", "physpickup", function( ply, ent )
    return true
end )

local ENT = FindMetaTable("Entity")

function ENT:ItemHide()
    // hide item - make invinsible, without physic, hide in client, parent to owner
    if self.Hided then
        LogColor("w", "whou, item already hided, but need moore!? - "..tostring(self))
        return
    end

    self.HideData = {}
    self.HideData.MT = self:GetMoveType()
    self.HideData.SD = self:GetSolid()
    
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
    
    self.Hided = true
end

function ENT:SetParentContainer(parent)
    if IsValid(self.Container) then
        if self.Container.IsHands then
            self.Container:SetItem(nil)
        end
    end

    if !parent:IsValid() then
        return
    end

    self:SetPos(parent:GetPos())
    self:SetParent(parent)

    self.Container = parent
end

function ENT:ItemGetParentContainer()
    return self.Container
end

function ENT:ItemRecover(pos)
    self:SetParent(nil)
    self:SetMoveType(self.HideData.MT)
    self:SetSolid(self.HideData.SD)
    self:SetNoDraw(false)
    self:SetPos(pos)
    self:SetAngles(Angle())
    self:PhysWake()
    self.HideData = nil
    self.Hided = false
end

function ENT:MoveItemInContainer(cont) // strange name but ok
    if !self.Hided then
        self:ItemHide()
    end
    self:SetParentContainer(cont)
end