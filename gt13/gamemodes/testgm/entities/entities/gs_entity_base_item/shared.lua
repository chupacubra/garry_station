ENT.Type = "anim"

ENT.PrintName		= "gs_entity_item_base"
ENT.Author			= "chupa"
ENT.Spawnable = false
ENT.Category = "gs"
ENT.CanPickup = true

ENT.GS_Entity  = true
ENT.GS_Item    = true
ENT.CanPickup  = true
ENT.CanExamine = true
ENT.CanUse = false
ENT.ItemBox =  false

ENT.Entity_Data = {} -- the all we can broadcast to client
ENT.Entity_Data.Name = "NAME"
ENT.Entity_Data.Desc = "DESC"
ENT.Entity_Data.Model = ""
ENT.Entity_Data.ENUM_Type = 0
ENT.Entity_Data.ENUM_Subtype = 0

if SERVER then
    ENT.Private_Data = {}  -- example: the inventory of box item, the pistol magazine
end
