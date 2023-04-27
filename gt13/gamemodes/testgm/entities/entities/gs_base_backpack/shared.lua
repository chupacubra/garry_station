ENT.Type = "anim"
 
ENT.PrintName		= "gs_base_backpack"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"

ENT.GS_Entity = true
ENT.GS_Equipable = true
ENT.TypeEq = GS_EQUIP_BACKPACK
ENT.CanExamine = true
ENT.EType = "type"
ENT.CanUse = false
ENT.CanBreak = false
ENT.CanPickup = true


ENT.backpack_model = "model/backpack"

ENT.Entity_Data = {}

ENT.Entity_Data.Name = "name"
ENT.Entity_Data.Desc = "test"
ENT.Entity_Data.Model = ENT.backpack_model
ENT.Entity_Data.ENUM_Type = GS_ITEM_EQUIP
ENT.Entity_Data.ENUM_Subtype = GS_EQUIP_BACKPACK
ENT.Entity_Data.Item_Max_Size =  ITEM_MEDIUM
ENT.Entity_Data.Size = ITEM_V_MEDIUM

if SERVER then
    --ENT.Private_Data = {}
    --ENT.Private_Data.Items = {}
    --ENT.Private_Data.Max_Items = 0
end
