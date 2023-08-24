AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "gs_entity_base_item"

ENT.PrintName		= "gs_base"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"

ENT.GS_Entity = true
--ENT.IsGS_Equip = true
ENT.CanExamine = true
ENT.EType = "type" 
ENT.CanUse = false
ENT.CanBreak = false
ENT.CanPickup = true
 --[[
ENT.Entity_Data = {}

ENT.Entity_Data.Name = "name"
ENT.Entity_Data.Desc = "test"
ENT.Entity_Data.Model = ENT.model
ENT.Entity_Data.ENUM_Type = GS_ITEM_EQUIP
ENT.Entity_Data.ENUM_Subtype = GS_EQUIP_HEAD
ENT.Entity_Data.Item_Max_Size =  ITEM_MEDIUM
ENT.Entity_Data.Size = ITEM_V_MEDIUM
--]]
--[[
if SERVER then
    --ENT.Private_Data = {}
    --ENT.Private_Data.Items = {}
    --ENT.Private_Data.Max_Items = 0
end
--]]
