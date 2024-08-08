// its example of good item
// new style of writing objects

// neeed remove hardcoded funcs - examine


//GS_EntityList.food = {}


// making base class of food with base funcs
local Base = {}

// we need to cancel Entity_Data/Private_Data structure
// simple - way to succes
// all code shared

Base = {}

Base.Base = "gs_entity"

Base.Name  = "Base food"
Base.Desc  = "skibidi gyat food"
Base.Model = "balbes.mdl"
Base.Size  = ITEM_SMALL

Base.MakeBite = function(self, ply)
    if CLIENT then return end
    ply:ChatPrint("mmm delicios rap snitch knishes")

    local bite = foodBite(self.ChemContainer)
    
    for chem, unit in pairs(self.ChemContainer) do
        player_manager.RunClass(ply, "InjectChemical", chem, unit)
    end 

    if self.ChemContainer:IsEmpty() then
        self:Remove()
    end
end

Base.ItemPrimary = function(self, hands, ply)
    self:MakeBite()
end

Base.SecondaryPrimary = function(self, hands, ply)
    -- nothing?
end

--  Buttons from context menu

Base.GetButtons = function(self)
    return
end

// Add item in list,
// ENT, name, base (from list)
GS_AddItem(Base, "hotdog", "")
