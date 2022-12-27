AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "gs_base_backpack"
 
ENT.PrintName		= "gs_base_backpack"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"

ENT.backpack_model = "models/blacksnow/backpack.mdl"

ENT.Entity_Data = {}
ENT.Entity_Data.Name = "simple backpack"
ENT.Entity_Data.Desc = "Cheap backpack"
ENT.Entity_Data.Model = ENT.backpack_model
ENT.Entity_Data.ENUM_Type = GS_ITEM_EQUIP
ENT.Entity_Data.ENUM_Subtype = GS_EQUIP_BACKPACK


if SERVER then
    ENT.Private_Data = {}
    ENT.Private_Data.Items = {}
    ENT.Private_Data.Max_Items = 8
end
