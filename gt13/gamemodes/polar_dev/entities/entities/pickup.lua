/*
IDEA: что если, при поднятии предмета в руки и помещение его в какой-либо инвентарь
не превращать его в мёртвую дататаблицу, а просто скрывать его, и спрятанный предмет припарентить к овнеру?

таким способ, к примеру активированные гранаты, помещёные в ящик взорвутся по истечении времени,
а предметами можно управлять, даже когда они спрятаны в кармане у игрока

какие обстоятельства "прячут" предмет:
    1. Взятие в руки
    2. Одевание предмета как снаряжение

*/

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
    ent:SetParent(nil)
    ent:SetPos(pos)
    ent:SetMoveType(ent.HideData.MT)
    ent:SetSolid(ent.HideData.SD)
    ent:SetNoDraw(false)
    
    ent.HideData = nil
    ent.Hided = false
end

function ENT:MoveItemInContainer(cont) // strange name but ok
    if !self.Hided then
        self:ItemHide()
    end
    self:SetParentContainer(parent)
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