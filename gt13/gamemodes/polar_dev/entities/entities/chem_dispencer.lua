ENT.Base = "gs_entity"


ENT.Name  = "Chemical Dispencer"
ENT.Desc  = "Nalivay davay"

ENT.Size  = ITEM_V_BIG
ENT.Model = ""

function ENT:UseItem(ply)
    // open menu
end

function ENT:ItemInteraction(item)
    return self:InsertChemContainer(item)
end

function ENT:InsertChemContainer(item)
end

function ENT:EjectChemContainer()
end

function ENT:Action(ply, action, arg)
end