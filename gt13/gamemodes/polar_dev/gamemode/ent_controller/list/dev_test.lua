// its example of good item


// making base class of food with base funcs

// we need to cancel Entity_Data/Private_Data structure
// simple - way to succes
// all code shared

local Base = {}

Base.Base = "gs_entity"

Base.Name  = "test object"
Base.Desc  = "skibidi"
Base.Model = "models/props_lab/cactus.mdl"
Base.Size  = ITEM_SMALL

Base.Spawnable = true
Base.Category = "Developing"


Base.TestPrimary = function(self, ply)
    if CLIENT then return end
    ply:ChatPrint("test")
end

Base.ItemPrimary = function(self, hands, ply)
    self:TestPrimary(ply)
end

Base.SecondaryPrimary = function(self, hands, ply)
    -- nothing?
end

--  Buttons from context menu
Base.GetButtons = function(self)
    return
end

// need more "standarted" action
// some GetActions()
//  some array of all actions we can make


// Add item in list,
// ENT, name, base (from list)

AddEntItem(Base, "test_object")

local Base = table.Copy(Base)
Base.Name  = "test object2"
Base.Desc  = "skibidi"
Base.Model = "models/props_lab/cactus.mdl"
Base.Size  = ITEM_SMALL

Base.Spawnable = true
Base.Category = "Developing 2"

AddEntItem(Base, "test_object_2")
