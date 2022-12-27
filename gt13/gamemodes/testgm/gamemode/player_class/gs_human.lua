DEFINE_BASECLASS( "player_default" )
 
local PLAYER = {} 


PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
PLAYER.UseVMHands = true
PLAYER.PLYModel  = "models/player/Group01/male_07.mdl"

function PLAYER:SetModel()

	local modelname = self.PLYModel

	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

function PLAYER:SetupHPSystem()
	self.Player.BODY = {
		head   = {0,0}, --BRUTE and BURN
		hand_l = {0,0},
		hand_r = {0,0},
		body   = {0,0},
		leg_l  = {0,0},
		leg_r  = {0,0},
		toxin  = {0}
	}

	self.Player.Chemicals = {}

end

function PLAYER:HurtPart(bone, damage, dtype)
	local bone = self.Player:TranslatePhysBoneToBone(bone)
	local mainpart

	function PrintBones( entity )
		for i = 0, entity:GetBoneCount() - 1 do
			print( i, entity:GetBoneName( i ) )
		end
	end
	PrintBones(self.Player)


	while true do
		local isPart, part = getMainBodyPart(bone)
		if isPart then
			mainpart = part
			break
		end
		
		bone = self.Player:GetBoneParent(bone)
	end

	self:DamageHealth(mainpart, dtype, damage)
	print(mainpart.. " = " ..self:GetHealthPercentPart(mainpart).. "%")
	print("HP: "..self:GetHealthPercent())
	print(self:GetSumDMG())
	if self:GetSumDMG() >= 100 then
		print("!!!CRIT!!!")
	end
end

function PLAYER:SetupEffectSystem()
	self.Player.Effects = {}
end

function PLAYER:GetHealthPercentPart(part)
	if self.Player.BODY[part] == nil then
		return 0
	end
	local dmg
	if part != "toxin" then
		dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)
	else
		dmg = 100 - self.Player.BODY[part][1]
	end

	if dmg < -100 then
		dmg = -100
	end

	return dmg
end


function PLAYER:GetHealthPercent()
	local dmg = 0
	

	for k,v in pairs(self.Player.BODY) do
		if k == "toxin" then -- potom
			continue
		end
		dmg = dmg + self:GetHealthPercentPart(k)
	end

	dmg = dmg / 6

	return dmg
end

function PLAYER:GetSumDMG()
	local dmg = 0
	
	for k,v in pairs(self.Player.BODY) do
		if k == "toxin" then -- potom
			dmg = dmg + v[1]
			continue
		end

		dmg = dmg + v[1] + v[2]
	end

	return dmg
end

function PLAYER:HealthClientUpdate(part)
	if self.Player.BODY[part] == nil then
		return false
	end

	dmg = self:GetHealthPercentPart(part)

	--send to client without info about toxin damage

end

function PLAYER:DamageHealth(part, typeD, dmg)
	if self.Player.BODY[part] == nil then
		return false
	end

	if typeD == D_TOXIN then
		self.Player.BODY[part][1] = self.Player.BODY[part][1] + dmg
	end
	
	self.Player.BODY[part][typeD] = self.Player.BODY[part][typeD] + dmg
end

function PLAYER:SetupInventary()
	self.Player.Equipment = {
		BELT      = 0,
		GLOVES    = 0,
		KEYCARD   = 0,
		PDA       = 0,
		BACKPACK  = 0,
		VEST      = 0,
		HEAD      = 0,
		MASK      = 0,
		EAR       = 0,
	}
end

function PLAYER:HaveEquipment(key)
	PrintTable(self.Player.Equipment)
	print(key,self.Player.Equipment[key])
	if self.Player.Equipment[key] != 0 then 
		return true
	end
	return false
end

function PLAYER:EquipItem(itemData,key)
	self.Player.Equipment[key] = itemData
	PrintTable(self.Player.Equipment)
	self:EquipmentEquipClient(itemData, key)
end


function PLAYER:GetItemFromBackpack(key)
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end
	
	return self.Player.Equipment.BACKPACK.Private_Data.Items[key]
end

function PLAYER:RemoveItemFromBackpack(key)
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	self.Player.Equipment.BACKPACK.Private_Data.Items[key] = nil
end 

function PLAYER:GetAllItemsFromBackpack()
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	local arr = {}
	for k,v in pairs(self.Player.Equipment.BACKPACK.Private_Data.Items) do
		table.insert(arr, v.Entity_Data)
	end
	
	PrintTable(arr)
	net.Start("gs_cl_inventary_request_backpack")
	net.WriteTable(arr)
	net.Send(self.Player)
end

function PLAYER:InsertItemInBackpack(data)
	if self.Player.Equipment.BACKPACK == 0 then
		return 
	end
	-- cursed
	table.insert(self.Player.Equipment.BACKPACK.Private_Data.Items, data)
	PrintTable(self.Player.Equipment.BACKPACK.Private_Data.Items)
end

function PLAYER:UseWeaponFromBackpack(key)
	local weapon = self:GetItemFromBackpack(key)
	print(weapon)
	if weapon != nil then
		local ent = duplicator.CreateEntityFromTable( game.GetWorld(), weapon )
		self.Player:PickupWeapon( ent )
		self:RemoveItemFromBackpack(key)

		self:UpdateClientInventory()
	end
end

function PLAYER:DropEntFromInventary(key)
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	local ent = self:GetItemFromBackpack(key)
	if ent != nil then
		local trace = {
			start = self.Player:EyePos(),
			endpos = self.Player:EyePos() + self.Player:GetAimVector() * 70 ,
			filter =  function( ent ) return ( ent != self.Player ) end
		}
		
		trace = util.TraceLine(trace)

		local ent = duplicator.CreateEntityFromTable( game.GetWorld(), ent )
		ent:SetPos(trace.HitPos)
		ent:Spawn()

		self:RemoveItemFromBackpack(key)

		self:UpdateClientInventory()
	end
end

function PLAYER:DropSWEP(weapon)
	if weapon.GS_Hand then
		return
	end

	self.Player:DropWeapon(weapon)
end

function PLAYER:MoveSWEPToBackpack(weapon)
	if weapon.GS_Hand or self.Player.Equipment.BACKPACK == 0 then
		return
	end
	local data = duplicator.CopyEntTable(weapon)

	self:InsertItemInBackpack(data)

	self.Player:StripWeapon( weapon:GetClass() )
end

function PLAYER:UpdateClientInventory()
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	local arr = {}
	for k,v in pairs(self.Player.Equipment.BACKPACK.Private_Data.Items) do
		table.insert(arr, v.Entity_Data)
	end

	net.Start("gs_cl_inventary_update")
	net.WriteTable(arr)
	net.Send(self.Player)
end

function PLAYER:EquipmentEquipClient(itemData, key)
	--FAST_HUD_TYPE
	itemData.Entity_Data.BaseClass = nil      --remove the trash
	net.Start("gs_equipment_update")
	net.WriteInt(FAST_HUD_TYPE[key], 8)
	net.WriteTable(itemData.Entity_Data)
	net.Send(self.Player)
end

function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()
	GS_EquipWeapon(self.Player, "gs_swep_hand")
end

function PLAYER:GetHandsModel()

	-- return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }

	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )

end

function PLAYER:InitHudClient()
	net.Start("gs_cl_init_stat")
	net.WriteBool(true)
	net.Send(self.Player)
end

function PLAYER:SetupSystems()
	self:SetupInventary()
	self:SetupHPSystem()
	self:InitHudClient()
end

function PLAYER:Spawn()
	self:SetupSystems()
end

function PLAYER:Think()

end

player_manager.RegisterClass( "gs_human", PLAYER, "player_default" )


net.Receive("gs_cl_inventary_request_backpack",function(_, ply) 
	player_manager.RunClass( ply, "GetAllItemsFromBackpack" )
end)

net.Receive("gs_cl_inventary_use_weapon", function(_, ply)
	local key = net.ReadInt(8)
	player_manager.RunClass( ply, "UseWeaponFromBackpack", key )
end)

net.Receive("gs_cl_inventary_drop_ent", function(_, ply)
	local key = net.ReadInt(8)
	player_manager.RunClass( ply, "DropEntFromInventary", key )
end)

net.Receive("gs_cl_weapon_drop", function(_, ply)
	local ent = net.ReadEntity()
	player_manager.RunClass( ply, "DropSWEP", ent )
end)

net.Receive("gs_cl_weapon_move_inventary", function(_, ply)
	local ent = net.ReadEntity()
	player_manager.RunClass( ply, "MoveSWEPToBackpack", ent )
end)