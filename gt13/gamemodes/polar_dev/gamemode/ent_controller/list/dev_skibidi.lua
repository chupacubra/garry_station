local ENT = {}

ENT.Base = "gs_entity"

ENT.Name  = "container test"
ENT.Desc  = "skibidi"
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Developing"

ENT.IsContainer = true
ENT.MaxItems    = 6
ENT.ItemMaxSize = ITEM_MEDIUM

AddEntItem(ENT, "test_container")
