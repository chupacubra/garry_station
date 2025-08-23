local ENT = {}

ENT.Base = "gs_chem_container"

ENT.Name  = "Bucket"
ENT.Desc  = "dear god..."
ENT.Model = "models/props_junk/metalbucket01a.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Developing"

ENT.RenderChem = true
ENT.RenderChem_Data = {
    height_min = -8.033,
    height_max = 8.033,
    rad_max = 8.153,
    rad_min = 6.534,
}

ENT.ChemContainerInit = {
    Max = 100,
    Chems = {}
}


AddEntItem(ENT, "chem_bucket")
