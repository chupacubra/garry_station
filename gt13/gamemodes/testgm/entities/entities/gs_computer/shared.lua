ENT.Type = "anim"
ENT.Base = "gs_entity_base"
 
ENT.PrintName		= "gs_computer"
ENT.Spawnable = false


ENT.CanExamine = true
ENT.CanUse     = true
ENT.CanBreak   = false
ENT.CanBolted  = true
ENT.ItemReceiver = true

ENT.Entity_Data = {
    Name = "Computer",
    Desc = "for unusable things",
    Model = "models/props_lab/monitor02.mdl",
    Type = "computer_base",
}
--[[
ENT.Entity_Status = {
    build     = false, 
    maintance = false,
    bolt      = false,
    broken    = false
}
--]]
