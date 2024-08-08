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
    self.HideData.MT = ent:GetMoveType()
    self.HideData.SD = ent:GetSolid()
    
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
    
    self.Hided = true
end

function ENT:SetParentContainer(parent)
    // set/change parent - owner
    // i hope already hided items can be parent to other - backpack in player and etc

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