DEFINE_BASECLASS( "player_default" )
 
local PLAYER = {} 

PLAYER.WalkSpeed = 200
PLAYER.RunSpeed  = 400
PLAYER.BaseWalkSpeed = PLAYER.WalkSpeed
PLAYER.BaseRunSpeed  = PLAYER.RunSpeed
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
	}

	self.Player.HP_Effect = {
		toxin   = 0,
		stamina = 0,
		hypoxia = 0,
	}
	--[[]]
	self.Player.Chemicals = CHEMIC_CONTAINER:New_Container(1000)
	self.Player.BloodLevel = 100
	self.Player.BloodBleed = false
	self.Player.BloodBleedRate  = 0
	self.Player.HealthStatus = GS_HS_OK

	if self.Ragdolled != true then
		self.Chemicals = CHEMIC_CONTAINER:New_Container(1000)
		--self.HealthStatus = GS_HS_OK
		self.LastDamage = 0 
		self.CritParalyzeDelay = 0
		self.Ragdolled = false
		--self.BloodLevel = 100
		--self.BloodBleed = false
		--self.BloodBleedRate  = 0
		self.CurSpeedRun = self.RunSpeed
		self.CurSpeedWalk = self.WalkSpeed
		self.EffectSpeed  = {}
	end
end
--[[

bleeding:
if ragdolled:
	ragdoll must be blooded!131

function PLAYER:AddBleeding()
	if self.BloodBleed == false then
		self.BloodBleedRate = 2
		self.BloodBleed = true
	else
		if self.BloodBleedRate + 2 >= 8 then return end

		self.BloodBleedRate = self.BloodBleedRate + 2
	end
end

function PLAYER:RemoveBleeding()
	if self.BloodBleed then
		self.BloodBleedRate = 0 
		self.BloodBleed = false
	end
end
--]]
function PLAYER:SetSpeed(walk, run)
	self.Player:SetWalkSpeed(walk)
	self.Player:SetRunSpeed(run)
end

function PLAYER:SetCharacterData(char)
	--[[
		Setup chararcter in spawn
		char get from client
		generate spec uniq ID
		
		char = {
			name = "John Jonson",
			model = "modelstring",
			model_id = 9,
			...
		}
	]]

	self.Character = char
end

function PLAYER:GetGMName()
	--[[the name here is character name
	
	on client:
		if KNOW this man: (as John Jonson)
		UNKNOW: Unknown

		for knowing this man you need:
			hear talking this guy + be close with him some time

	]]
end

function PLAYER:EffectSpeedSet()
	print(self.CurSpeedWalk, self.CurSpeedRun)
	self.Player:SetWalkSpeed(self.CurSpeedWalk)
	self.Player:SetRunSpeed(self.CurSpeedRun) 
end

function PLAYER:EffectSpeedAdd(effect, walk, run)
	if self.EffectSpeed[effect] then
		return
	end

	self.EffectSpeed[effect] = {walk, run}
	self.CurSpeedRun = self.CurSpeedRun + run
	self.CurSpeedWalk = self.CurSpeedWalk + walk

	self:EffectSpeedSet()
end

function PLAYER:EffectSpeedRemove(effect)
	if self.EffectSpeed[effect] == nil then
		return
	end
	local walk, run = unpack(self.EffectSpeed[effect])

	self.CurSpeedRun = self.CurSpeedRun - run
	self.CurSpeedWalk = self.CurSpeedWalk - walk

	self.EffectSpeed[effect] = nil 

	self:EffectSpeedSet()
end

function PLAYER:Ragdollize() -- from ragmod
	if self.Ragdolled then
		return 
	end

	self:DropSWEPBeforeRagdollize()

	local ragdoll = GS_Corpse.Create(self.Player)
	self.Player.Ragdoll = ragdoll

	self.Player.SWEP = {}
	self.Player.SWEP.Hand_Item = false
	self.Player.SWEP.Weapons = {}
	

	for k, v in pairs(self.Player:GetWeapons()) do
		if v:GetClass() == "gs_swep_hand" then
			-- saving ONLY ent in hand
			self.Player.SWEP.Hand_Item = self.Player.Hands:GetItem()
			continue
		end
		table.insert(self.Player.SWEP.Weapons, duplicator.CopyEntTable(v))
	end

	self.Player:StripWeapons()
	self.Player:Spectate( OBS_MODE_CHASE )
	self.Player:SpectateEntity( ragdoll )
	self.Player:SetNoTarget( true )
	
	self.Ragdolled = true
end

function PLAYER:Unragdollize()
	if !IsValid(self.Player.Ragdoll) then
		GS_MSG(self.Player.." lose self corpse ragdoll, move to spectators")
		return
	end

	local sweps = self.Player.SWEP
	local equip = self.Player.Equipment
	local pocket = self.Player.Pocket
	local body   = self.Player.BODY
	local blood, blood_level, blool_rate = self.Player.BloodBleed, self.Player.BloodLevel, self.Player.BloodBleedRate
	local chem = self.Player.Chemicals
	local hp_stat = self.Player.HealthStatus
	local walks  = self.Player:GetWalkSpeed()
	local runs   = self.Player:GetRunSpeed()
	
	--[[this shit don't save after respawn]]

	self.Player:UnSpectate()
	self.Player:SetModel(self.Player.Ragdoll:GetModel())	--?

	self.Player:Spawn()

	self.Player.SWEP = nil

	local ragdoll = self.Player.Ragdoll
	self.Player:SetPos(ragdoll:GetPos())
	self.Player:SetEyeAngles( Angle(0,0,0) )
	self.Player:SetVelocity( ragdoll:GetVelocity() )
	self.Player:SetNoTarget ( false )
	self.Player.Ragdoll:Remove()
	self.Player.Ragdoll = nil
	self.Ragdolled = false

	GS_EquipWeapon(self.Player, "gs_swep_hand")
	self.Player.Hands = self.Player:GetWeapon("gs_swep_hand")


	if sweps.Hand_Item != false then
		self.Player.Hands:PutItemInHand(sweps.Hand_Item)
	end

	for k, v in pairs(sweps.Weapons) do
		local weap = duplicator.CreateEntityFromTable(Entity(0), v)
		self.Player:PickupWeapon(weap)
	end

	self.Player.Equipment = equip
	self.Player.Pocket = pocket

	self:SendToClientItemsFromPocket()

	for k,v in pairs(self.Player.Equipment) do
		if v == 0 then
			continue
		end
		self:EquipmentEquipClient(v, k)
	end

	self:SetHP(body)
	self:SetSpeed(walks, runs)
	self.Player.HealthStatus = hp_stat
end

function PLAYER:IsRagdolled()
	return self.Ragdolled
end

function PLAYER:CritParalyze(delay,hard)
	if self.Ragdolled or self.CritParalyzeDelay > CurTime() then
		return false
	end

	if !delay then
		delay = math.random(3, 5)
	end

	self:Ragdollize()
	if !hard then
		self.CritParalyzeDelay = CurTime() + delay + 7
		
		timer.Simple(delay, function()
			self:Unragdollize()
		end)
	end

	GS_ChatPrint(self.Player, "You paralized!", CHAT_COLOR.RED)
end

function PLAYER:HurtPart(bone, dmg)
	local bone = self.Player:TranslatePhysBoneToBone(bone)
	local mainpart

	function PrintBones( entity )
		for i = 0, entity:GetBoneCount() - 1 do
			print( i, entity:GetBoneName( i ) )
		end
	end
	--PrintBones(self.Player)

	while true do
		local isPart, part = getMainBodyPart(bone)
		if isPart then
			mainpart = part
			break
		end
		
		bone = self.Player:GetBoneParent(bone)
	end

	-- ???
	--PrintTable(dmg)
	for k,v in pairs(dmg) do
		print(k,v)
		if k == D_STAMINA or k == D_TOXIN then
			continue
		end
		self:DamageHealth(mainpart, k, v)
	end

	print(mainpart.. " = " ..self:GetHealthPercentPart(mainpart).. "%")
	print("HP: "..self:GetHealthPercent())
	print(self:GetSumDMG())

	if self:GetSumDMG() >= 100 then
		print("!!!CRIT!!!")
	end
	self:HealthPartClientUpdate(mainpart)
end

function PLAYER:SetHP(body)
	self.Player.BODY = body

	for k,v in pairs(self.Player.BODY) do
		self:HealthPartClientUpdate(k)
	end
end

function PLAYER:SetupEffectSystem()
	self.Player.Effects = {}
end

function PLAYER:GetHealthPercentPart(part)
	if self.Player.BODY[part] == nil then
		return 0
	end
	local dmg--[[
	if part != "toxin" and part != "stamina" then
		dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)
	else
		dmg = 100 - self.Player.BODY[part][1]
	end
	--]]
	dmg = 100 - (self.Player.BODY[part][1] + self.Player.BODY[part][2] or 0)

	if dmg < -100 then
		dmg = -100
	end

	return dmg
end


function PLAYER:GetHealthPercent()
	local dmg = 0

	for k,v in pairs(self.Player.BODY) do
		dmg = dmg + self:GetHealthPercentPart(k)
	end

	dmg = dmg / 6

	return dmg
end

function PLAYER:GetSumDMG()
	local dmg = 0
	
	for k,v in pairs(self.Player.BODY) do
		dmg = dmg + v[1] + v[2]
	end

	dmg = dmg + self.Player.HP_Effect.toxin + self.Player.HP_Effect.hypoxia
	return dmg
end

function PLAYER:HealthPartClientUpdate(part)
	local parthp
	print(part)
	if !part then
		part = 0
		parthp = 0
	else
		if self.Player.BODY[part] == nil then
			return false
		end
	
		parthp = math.floor(self:GetHealthPercentPart(part))
	end
	
	local hp = math.floor(self:GetHealthPercent())

	net.Start("gs_health_update")
	net.WriteString(part)   -- if we hurt the leg
	net.WriteInt(parthp, 8) -- the hp of leg
	net.WriteInt(hp, 8)     -- the ALL hp (100%...)
	net.WriteUInt(self.Player.HealthStatus,5)
	net.Send(self.Player)
end

--[[
function PLAYER:HealthEffectClienUpdate()
	-- if we have crit or smth

end
--]]

function PLAYER:HealHealth(part, typeD, hp)
	if self.Player.BODY[part] == nil then
		return false
	end

	if self.Player.BODY[part][typeD] - hp < 0 then
		self.Player.BODY[part][typeD] = 0
	else
		self.Player.BODY[part][typeD] = self.Player.BODY[part][typeD] - hp
	end
end

function PLAYER:DamageHealth(part, typeD, dmg)
	if self.Player.BODY[part] == nil then
		return false
	end

	self.Player.BODY[part][typeD] = self.Player.BODY[part][typeD] + dmg
end

function PLAYER:DamageStamina(dmg)
	self.Player.HP_Effect.stamina = self.Player.HP_Effect.stamina + dmg
end

function PLAYER:DamageHypoxia(dmg)
	self.Player.HP_Effect.hypoxia = self.Player.HP_Effect.hypoxia + dmg
end

function PLAYER:DamageToxin(dmg)
	self.Player.HP_Effect.toxin = self.Player.HP_Effect.toxin + dmg
end

function PLAYER:GetHypoxia()
	return self.Player.HP_Effect.hypoxia
end

function PLAYER:GetStamina()
	return self.Player.HP_Effect.stamina
end

function PLAYER:GetToxin()
	return self.Player.HP_Effect.toxin
end

function PLAYER:InjectChemical(chem,unit) -- insert in human chem  food, poison etc
	self.Player.Chemicals:Component(chem,unit)
	PrintTable(self.Chemicals)
end

function PLAYER:RemoveChemical(chem,unit)
	self.Player.Chemicals:Component(chem,-unit)
end

function PLAYER:Metabolize()
	-- activate 1 unit of chemicals on timer
	-- and mixing with another
end

function PLAYER:Death()
	--[[
		move to ghost
		spawn a ragdoll, ragdoll of death person
		set him equipments and other
	]]
	if self.Ragdolled then
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	else
		--[[ create ragdoll]]
		self:Ragdollize()
		GS_Corpse.SetRagdollDeath(self.Player, self.Player.Ragdoll)
	end
	self:StopThink()
	self:CloseHudClient()
	PlayerSpawnAsSpectator(self.Player)
	
	hook.Run("GS_PlayerDead", self.Player:SteamID())
	player_manager.ClearPlayerClass( self.Player )
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

	self.Player.Pocket = {{},{}}
end

function PLAYER:InsertItemInPocket(item, pocket)
	if !table.IsEmpty(self.Player.Pocket[pocket]) then
		return false
	end
	
	if !item then
		self.Player.Pocket[pocket] = {}
	else
		self.Player.Pocket[pocket] = item
	end
	self:SendToClientItemsFromPocket()
	return true
end


function PLAYER:UpdateItemInPocket(item, pocket)
	if !item then
		self.Player.Pocket[pocket] = {}
	else
		self.Player.Pocket[pocket] = item
	end
	self:SendToClientItemsFromPocket()
	return true
end

function PLAYER:GetItemFromPocket(pocket)
	if table.IsEmpty(self.Player.Pocket[pocket]) then
		return false
	end

	return self.Player.Pocket[pocket]
end

function PLAYER:RemoveItemFromPocket(pocket)
	if table.IsEmpty(self.Player.Pocket[pocket]) then
		return false
	end

	self.Player.Pocket[pocket] = {}
	self:SendToClientItemsFromPocket()
end

function PLAYER:MoveSWEPToPocket(weapon, key)
	local data = duplicator.CopyEntTable(weapon)

	local succes = self:InsertItemInPocket(data, key)
	if succes then
		self.Player:StripWeapon( weapon:GetClass() )
		self:SendToClientItemsFromPocket()
	end
end

function PLAYER:HaveEquipment(key)
	if self.Player.Equipment[key] != 0 then 
		return true
	end
	return false
end

function PLAYER:EquipItem(itemData,key)
	if self:HaveEquipment(key) then
		return false
	end
	self.Player.Equipment[key] = itemData
	self:EquipmentEquipClient(itemData, key)
	return true
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

	table.remove(self.Player.Equipment.BACKPACK.Private_Data.Items, key)
	self:SendToClientItemsFromBackpack()
end 

function PLAYER:SendToClientItemsFromBackpack()
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	local arr = {}
	for k,v in pairs(self.Player.Equipment.BACKPACK.Private_Data.Items) do
		table.insert(arr, {Name = v.Entity_Data.Name, ENUM_Type = v.Entity_Data.ENUM_Type})
	end

	net.Start("gs_cl_inventary_update")
	net.WriteUInt(CONTEXT_BACKPACK, 5)
	net.WriteTable(arr)
	net.Send(self.Player)
end

function PLAYER:SendToClientItemsFromPocket()
	if #self.Player.Pocket == 0 then
		return
	end

	local arr = {}

	for k,v in pairs(self.Player.Pocket) do
		if table.IsEmpty(v) then
			arr[k] = {Name = "", ENUM_Type = 0}
			continue
		end
		arr[k] = {Name = v.Entity_Data.Name, ENUM_Type = v.Entity_Data.ENUM_Type}
	end

	net.Start("gs_cl_inventary_update")
	net.WriteUInt(CONTEXT_POCKET, 5)
	net.WriteTable(arr)
	net.Send(self.Player)
end

function PLAYER:UpdateItemInBackpack(key,data)
	if self.Player.Equipment.BACKPACK == 0 then
		return 
	end
	print(key, data)
	self.Player.Equipment.BACKPACK.Private_Data.Items[key] = data
end

function PLAYER:InsertItemInBackpack(data)
	if self.Player.Equipment.BACKPACK == 0 then
		return 
	end
	-- cursed
	table.insert(self.Player.Equipment.BACKPACK.Private_Data.Items, data)

	return true
end

function PLAYER:OpenItemContainer() -- we can open the box while the in hands
	self.OpenContainer = self.Player.Hands
end

function PLAYER:OpenEntContainer(entity)
	self.OpenContainer = entity
	if entity != self.Player.Hands then
		entity.ContainerUser = self.Player
	end
	local items = {}

	for k,v in pairs(entity:GetItemsContainer()) do
		items[k] = {Name = v.Entity_Data.Name, ENUM_Type = v.Entity_Data.ENUM_Type}
	end
	PrintTable(items)
	net.Start("gs_ent_container_open")
	net.WriteTable(items)
	net.Send(self.Player)
end

function PLAYER:CloseEntContainer(client)
	if IsValid(self.OpenContainer) then
		if self.OpenContainer != self.Player.Hands then
			self.OpenContainer.ContainerUser = Entity(0)
		end
		self.OpenContainer = Entity(0)
		if !client then
			net.Start("gs_ent_container_close")
			net.Send(self.Player)
		end
		GS_MSG(self.Player:GetName()  .." close",MSG_INFO)
	end
end

function PLAYER:GetItemFromContext(context, key)
	if context == CONTEXT_ITEM_IN_BACK then
		return self:GetItemFromBackpack(key)
	elseif context == CONTEXT_POCKET then
		return self:GetItemFromPocket(key)
	elseif context == CONTEXT_ITEM_IN_CONT then
		print("get item from container",key)
		print(self.OpenContainer:GetItemFromContainer(key))
		return self.OpenContainer:GetItemFromContainer(key)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:GetItem()
	end
end

function PLAYER:InsertItemInContext(context, item, pocket)
	if context == CONTEXT_BACKPACK then
		return self:InsertItemInBackpack(item)
	elseif context == CONTEXT_POCKET then
		return self:InsertItemInPocket(item,pocket)
	elseif context == CONTEXT_CONTAINER then
		return self.OpenContainer:InsertItemInContainer(item)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:PutItemInHand(item)
	end
end

function PLAYER:RemoveItemFromContext(context, key)
	if context == CONTEXT_ITEM_IN_BACK then
		return self:RemoveItemFromBackpack(key)
	elseif context == CONTEXT_POCKET then
		return self:RemoveItemFromPocket(key)
	elseif context == CONTEXT_ITEM_IN_CONT then
		return self.OpenContainer:RemoveItemFromContainer(key)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:RemoveItem()
	end
end

function PLAYER:UpdateItemInContext(context, item, key)
	if context == CONTEXT_ITEM_IN_BACK or context == CONTEXT_BACKPACK then
		return self:UpdateItemInBackpack(item, key)
	elseif context == CONTEXT_POCKET then
		return self:UpdateItemInPocket(item, key)
	elseif context == CONTEXT_ITEM_IN_CONT then
		return self.OpenContainer:UpdateItemInContainer(item, key)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:UpdateItem(item)
	end
end

function PLAYER:UseWeaponFromInventory(key, from)
	local weapon = self:GetItemFromContext(from, key)
	if weapon != nil then
		local ent = duplicator.CreateEntityFromTable(game.GetWorld(), weapon)
		self.Player:PickupWeapon(ent)
		self:RemoveItemFromContext(from, key)
	end
end

function PLAYER:DropEntFromInventary(key, from)
	print(key,from)
	local ent = self:GetItemFromContext(from, key)

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

		self:RemoveItemFromContext(from, key)
	end
end

function PLAYER:DropSWEP(weapon)
	if weapon.GS_Hand then
		return
	end

	self.Player:DropWeapon(weapon)
end

function PLAYER:DropSWEPBeforeRagdollize()
	local weap = self.Player:GetActiveWeapon()
	if weap.GS_Hand then
		weap:DropItem()
	else
		self.Player:DropWeapon(weap)
	end
end

function PLAYER:EquipmentEquipClient(itemData, key)
	net.Start("gs_equipment_update")
	net.WriteUInt(FAST_HUD_TYPE[key], 5)
	net.WriteString(itemData.Entity_Data.Name)
	net.Send(self.Player)
end 

function PLAYER:ExamineItemFromInventory(keyitem, from)
	local examine

	local item = self:GetItemFromContext(from, keyitem)
	examine = {item.Entity_Data.Name, item.Entity_Data.Desc}
	local priv = GS_EntityControler:ExamineData(item)

	table.Add(examine, priv)

	net.Start("gs_cl_inventary_examine_return")
	net.WriteTable(examine)
	net.Send(self.Player)
end

function PLAYER:CompareEntAndEnt(receiver, drop)
	local item_receiver = self:GetItemFromBackpack(receiver)
	local item_drop     = self:GetItemFromBackpack(drop)

	item_receiver_rez, item_drop_rez, chat_rez  = GS_EntityControler:MakeActionEntData(item_receiver, item_drop, chat_rez)
	
	if item_receiver_rez then
		self:UpdateItemInBackpack(receiver, item_receiver_rez)
		self:UpdateItemInBackpack(drop, item_drop_rez or item_drop)
	end

	if chat_rez then
		self.Player:ChatPrint(chat_rez)
	end
end


function PLAYER:Loadout()
    self.Player:RemoveAllAmmo()
	GS_EquipWeapon(self.Player, "gs_swep_hand")

	self.Player.Hands = self.Player:GetWeapon("gs_swep_hand")
end

function PLAYER:GetHandsModel()

	-- return { model = "models/weapons/c_arms_cstrike.mdl", skin = 1, body = "0100000" }
 
	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )

end

function PLAYER:SetupThink()
	timer.Create("gs_player_think_"..self.Player:EntIndex(), 1, 0, function()
		if !self.Player:IsValid() then

			self:StopThink()
			return
		end
		print('think player '..self.Player:GetName())

		
		local procent = math.random(1, 100)
		local dmg = self:GetSumDMG()
		

		if dmg >= 200 then
			--[[DEATH]]
			print("DEATH STATUS")
			print("D")
			self:Death()
			self:HealthPartClientUpdate()
		elseif dmg >= 150 then
			print("HARDCRIT STATUS")
			self.Player.HealthStatus = GS_HS_CRIT
			--[[
				here we make the perm critparalyze
				make suffer from hypoxia
				fak y human die almost
				
				if person hp --> 100 then
					remove hypoxia uron( 5/7 in timer)
			]]

			if procent <= 50 then
				self:CritParalyze(0,true)
				self:DamageHypoxia(4)
			end
			print(dmg)
			--self:Ragdollize()
			self:HealthPartClientUpdate()
		elseif dmg >= 100 then
			self:EffectSpeedAdd("krit_status",-150, -250)
			print("SOFTCRIT STATUS")
			self.Player.HealthStatus = GS_HS_CRIT
			if procent <= 40 then
				self:CritParalyze()
			end
			--if self.Player.
			self:HealthPartClientUpdate()
		elseif dmg < 100 then
			--self:SetSpeed(self.BaseWalkSpeed, self.BaseRunSpeed)
			if self.Player.HealthStatus != GS_HS_OK then
				self.Player.HealthStatus = GS_HS_OK
				self:HealthPartClientUpdate()
			end
		end

	end)
end

function PLAYER:StopThink()
	timer.Destroy("gs_player_think_"..self.Player:EntIndex())
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


function PLAYER:SetupSystems()
	self:SetupInventary()
	self:SetupHPSystem()
	self:InitHudClient()
	self:SetupThink()
end

function PLAYER:Spawn()
	self:SetupSystems()
end

function PLAYER:MakeNormalContext(receiver, drop)
	if receiver.from == CONTEXT_WEAPON_SLOT and receiver.entity != self.Player.Hands  then
		local drop_ent = self:GetItemFromContext(drop.from, drop.key)
		print(drop_ent, drop.key)
		if drop_ent then
			local drop_rez = receiver.entity:CompareWithEnt(drop_ent)
			if drop_rez == false then
				return
			elseif drop_rez == nil then
				self:RemoveItemFromContext(drop.from, drop.key)
			else
				self:UpdateItemInContext(drop.from, drop_rez, drop.key)
			end
		end
	else
		local receiver_item = self:GetItemFromContext(receiver.from, receiver.key)

		if receiver_item then -- combine items
			if drop.from == CONTEXT_WEAPON_SLOT and drop.entity != self.Player.Hands then
				return
			end
			
			local drop_item = self:GetItemFromContext(drop.from,drop.key)
			local item_r_rez, item_d_rez, chat_rez  = GS_EntityControler:MakeActionEntData(receiver_item, drop_item)
	
			if item_r_rez then
				self:UpdateItemInContext(receiver.from, item_r_rez, receiver.key)
				self:UpdateItemInContext(drop.from, item_d_rez, drop.key)
			end

		else -- put item in context
			print("putitemincontext")
			if drop.from == CONTEXT_WEAPON_SLOT and drop.entity != self.Player.Hands then
				local data = duplicator.CopyEntTable(drop.entity)

				local succes = self:InsertItemInContext(receiver.from, data, receiver.key)
				if succes then
					self.Player:StripWeapon( weapon:GetClass() )
				end
				return
			else
				local drop_item = self:GetItemFromContext(drop.from, drop.key)

				if drop_item then
					print(drop_item)
					local succes = self:InsertItemInContext(receiver.from, drop_item, receiver.key)
					print(succes,"13")
					if succes then
						self:RemoveItemFromContext(drop.from, drop.key)
					end-- ____     
				end--    ||/\||     | => | 
			end --_______||  ||_____________     
		end-- -- --  O  /     / -- 0  o -- --
	end  -- -- 0 -- 0  /     / 0  O -- O -- o
end  -- o  0 -- o --  ______  0 -- o -- 0 -- o
--___________________--------_________
--| the whole world   0    is theatre|
--| and YOU are the  /|\   main clown
--                   /\



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