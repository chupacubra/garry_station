if SERVER then
	include("gs_inventary.lua")
	include("gs_human_body_new.lua")
	include("gs_human_body_organs.lua")
	include("gs_effects.lua")
	include("gs_char.lua")

	AddCSLuaFile("gs_cl_equipment.lua")
else
	include("gs_cl_equipment.lua")
end

DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
PLAYER.BaseWalkSpeed = PLAYER.WalkSpeed
PLAYER.BaseRunSpeed  = PLAYER.RunSpeed
PLAYER.UseVMHands = true
PLAYER.PLYModel  = "models/player/Group01/male_07.mdl"

function PLAYER:SetModel(name)
	local modelname = name or self.PLYModel
	
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

	self.Player:SetupHands()
end

if SERVER then

	--INCLUDE INVENTARY FUNCTION
	for k,v in pairs(PLAYER_INVENTARY) do
		PLAYER[k] = v
	end

	--INCLUDE BODY AND HP FUNCTION
	for k,v in pairs(PLAYER_HP) do
		PLAYER[k] = v
	end

	for k,v in pairs(PLAYER_ORGANS) do
		PLAYER[k] = v
	end

	--INCLUDE EFFECTS
	for k,v in pairs(PLAYER_EFFECT) do
		PLAYER[k] = v
	end

	--INCLUDE CHAR
	for k,v in pairs(PLAYER_CHAR) do
		PLAYER[k] = v
	end

else
	--INCLUDE CLIENT VIEW EQUIP FUNCTION
	for k,v in pairs(PLAYER_CL_EQ) do
		PLAYER[k] = v
	end

end

function PLAYER:GetHandsModel()
	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )
end

function PLAYER:StopThink()
	local i = self.Player:EntIndex()
	timer.Destroy("gs_player_think_"..i)
	timer.Destroy("gs_bleed"..i)
	timer.Destroy("gs_hunger_"..i)
	timer.Destroy("gs_organs_think_"..i)
end

function PLAYER:InitHudClient()
	net.Start("gs_cl_init_stat")
	net.WriteBool(true)
	net.Send(self.Player)
end

function PLAYER:CloseHudClient()
	net.Start("gs_cl_init_stat")
	net.WriteBool(false)
	net.Send(self.Player)
end

function PLAYER:SetupEquipDraw()
	net.Start("gs_ply_equip_setup")
	net.WriteEntity(self.Player)
	net.Broadcast()
end

function PLAYER:SetupSystems()
	self:SetupInventary()
	self:SetupHPSystem() -- !!!
	self:InitHudClient()
	--self:SetupThink()
end

function PLAYER:Spawn()
	self:SetupSystems()
	self:SetupEquipDraw()
end

function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()
	GS_EquipWeapon(self.Player, "gs_swep_hand")

	self.Player.Hands = self.Player:GetWeapon("gs_swep_hand")
end



player_manager.RegisterClass( "gs_human", PLAYER, "player_default" )


net.Receive("gs_cl_inventary_request_backpack",function(_, ply) 
	player_manager.RunClass( ply, "SendToClientItemsFromBackpack" )
end)

net.Receive("gs_cl_inventary_use_weapon", function(_, ply)
	local from = net.ReadUInt(5)
	local key = net.ReadUInt(6)
	player_manager.RunClass( ply, "UseWeaponFromInventory", key, from)
end)

net.Receive("gs_cl_inventary_drop_ent", function(_, ply)
	local from = net.ReadUInt(5)
	local key = net.ReadUInt(6)
	player_manager.RunClass( ply, "DropEntFromInventary", key, from)
end)

net.Receive("gs_cl_weapon_drop", function(_, ply)
	local ent = net.ReadEntity()
	player_manager.RunClass( ply, "DropSWEP", ent )
end)

net.Receive("gs_cl_inventary_examine_item", function(_, ply)
	local from    = net.ReadUInt(5)
	local keyitem = net.ReadUInt(6)
	player_manager.RunClass( ply, "ExamineItemFromInventory", keyitem, from)
end)


net.Receive("gs_cl_contex_item_action", function(len, ply)
	local receiver = {}
	local drop     = {}

	receiver.entity = net.ReadEntity()
	receiver.key    = net.ReadUInt(6)
	receiver.from   = net.ReadUInt(5)

	drop.entity = net.ReadEntity()
	drop.key    = net.ReadUInt(6)
	drop.from   = net.ReadUInt(5)

	GS_MSG(ply:GetName().." make action on context menu")

	PrintTable(receiver)
	PrintTable(drop)
	player_manager.RunClass( ply, "MakeNormalContext", receiver, drop)
end)

net.Receive("gs_ent_container_close",function(_,ply)
	player_manager.RunClass( ply, "CloseEntContainer", true)
end)

net.Receive("gs_cl_actions_human", function(_, ply)
	local target = net.ReadEntity()
	local act    = net.ReadUInt(3)

	player_manager.RunClass(target, "MakeAction", ply, act)
end)

net.Receive("gs_equipment_update", function(_, ply)
	local key = net.ReadUInt(5)

	player_manager.RunClass(ply, "RemoveEquip", FAST_EQ_TYPE[key] )
end)