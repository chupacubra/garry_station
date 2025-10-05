GS_Corpses = GS_Corpses or {}
local PLAYER = FindMetaTable("Player")

function PLAYER:CreateFakeRagdoll(isDeath)
	print("CREATE RAGDOLL", ply, "Is dead?", isDeath)
	if not self:Alive() and self.fake then return nil end
	local rag = self:GetNWEntity("Corpse")

	local Data = duplicator.CopyEntTable(self)
	local rag = ents.Create("prop_ragdoll")

	duplicator.DoGeneric(rag, Data) // watahel?
	
	rag:SetModel(self:GetModel())
	rag:SetColor(self:GetColor())
	rag:SetSkin(self:GetSkin())
	//rag:BetterSetPlayerColor(self:GetPlayerColor())
	rag:Spawn()
	rag:Activate()
	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	rag:SetNWEntity("RagdollOwner", self)
	rag:SetNWBool("IsCorpse", true)

	local vel = self:GetVelocity() / 1
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local physobj = rag:GetPhysicsObjectNum(i)
		local ragbonename = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
		local bone = self:LookupBone(ragbonename)
		if bone then
			local bonemat = self:GetBoneMatrix(bone)
			if bonemat then
				local bonepos = bonemat:GetTranslation()
				local boneang = bonemat:GetAngles()
				physobj:SetPos(bonepos, true)
				physobj:SetAngles(boneang)
				--УБРАТЬ ГОВНЕЦО ПОТОМ
				if not self:Alive() then
					vel = vel / 2
				end

				physobj:AddVelocity(vel)
			end
		end
	end

	self:SetNWEntity("Corpse", rag)
	if isDeath then
		SetCorpseDead(self, true)
	end
end

/*
function PLAYER:Ragdollize()
	//if !IsValid(self:GetNWEntity("Corpse")) then
	//	Faking(self)
	//end
end

function PLAYER:UnRagdollize()

end
*/

// from homidrad core
// peredelat

-- Сохранение игрока перед вставанием
function SavePlyInfoPreSpawn(ply)
	ply.RagPrespawnInfo = ply.RagPrespawnInfo or {}

	ply.RagPrespawnInfo.Body_Parts 			= ply.Body_Parts
	ply.RagPrespawnInfo.Organism_Value 		= ply.Organism_Value

	ply.RagPrespawnInfo.Chemicals 			= ply.Chemicals
	ply.RagPrespawnInfo.HealthStatus 		= ply.HealthStatus
	ply.RagPrespawnInfo.Ragdolled 			= ply.Ragdolled
	ply.RagPrespawnInfo.CritParalyzeDelay  	= ply.CritParalyzeDelay

	ply.RagPrespawnInfo.Equipment 	= ply.Equipment
	ply.RagPrespawnInfo.Pockets 	= ply.Pockets
end

-- возвращение информации игроку по его вставанию
function ReturnPlyInfo(ply)
	ply.Body_Parts 			= ply.RagPrespawnInfo.Body_Parts
	ply.Organism_Value 		= ply.RagPrespawnInfo.Organism_Value

	ply.Chemicals 			= ply.RagPrespawnInfo.Chemicals
	ply.HealthStatus 		= ply.RagPrespawnInfo.HealthStatus
	ply.Ragdolled 			= ply.RagPrespawnInfo.Ragdolled
	ply.CritParalyzeDelay	= ply.RagPrespawnInfo.CritParalyzeDelay
	
	ply.Equipment	= ply.RagPrespawnInfo.Equipment
	ply.Pockets		= ply.RagPrespawnInfo.Pockets

	ply:RunClass("RagdollWakeUp")
end

-- функция падения
-- добавить дроп всех предметов в руках

local function DropAll(ply)
	local sweps = ply:GetWeapons()

	for k, swep in pairs(sweps) do
		if swep.IsHands then
			swep:DropItem()
		else
			ply:DropWeapon(swep)
		end
	end
end

function PLAYER:RagSpectate()
	local ply = self
	ply:Spectate(OBS_MODE_ROAMING)
	ply:UnSpectate()
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetMoveType(MOVETYPE_OBSERVER)
end

function ForceFake(ply)
	if ply.InFake then return end
	SavePlyInfoPreSpawn(ply)

	if SERVER then
		ply:DrawWorldModel(false)
	end

	if ply:InVehicle() then
		ply:ExitVehicle()
	end
	
	DropAll(ply)

	ply:CreateFakeRagdoll()

	if IsValid(ply:GetNWEntity("Corpse")) then
		ply.fakeragdoll = ply:GetNWEntity("Corpse")
		ply:RagSpectate()
		ply:SetParent(ply:GetNWEntity("Corpse"))
		ply:SetSuppressPickupNotices(false)
		ply:SetActiveWeapon(nil)
		ply:DropObject()

		ply.InFake = true

	end

end

function ForceUnfake(ply)
	if !ply.InFake then return end

	if IsValid(ply:GetNWEntity("Corpse")) then
		ply.fakeragdoll = nil
		SavePlyInfoPreSpawn(ply)

		local pos = ply:GetNWEntity("Corpse"):GetPos()
		local vel = ply:GetNWEntity("Corpse"):GetVelocity()
		
		ply:UnSpectate()
		
		ply.unfaked = true
		ply:SetNWBool("unfaked", ply.unfaked)
		ply:Spawn()
		
		ReturnPlyInfo(ply)

		ply:SetNWInt("FakeShooting", false)
		ply:SetVelocity(vel)
		ply.unfaked = false

		ply:SetNWBool("unfaked", ply.unfaked)
		ply:SetParent()
		ply:SetPos(pos)
		ply:DrawWorldModel(true)

		ply:GetNWEntity("Corpse"):Remove()
		ply:SetNWEntity("Corpse", nil)

		ply.InFake = false
	end
end

function TryStand(ply)
	if !ply.InFake then return end
	if ply.ForceRagdoll then return false end

	ForceUnfake(ply)
end

function Faking(ply)
	ply.InFake = not ply.InFake
	ply:SetNWBool("fake", ply.InFake)

	if ply.InFake == true then
		SavePlyInfoPreSpawn(ply)

		if SERVER then
			ply:DrawWorldModel(false)
		end

		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		
		DropAll(ply)

		ply:CreateFakeRagdoll()

		if IsValid(ply:GetNWEntity("Corpse")) then
			ply.fakeragdoll = ply:GetNWEntity("Corpse")
			ply:RagSpectate()
			ply:SetParent(ply:GetNWEntity("Corpse"))
			ply:SetSuppressPickupNotices(false)
			ply:SetActiveWeapon(nil)
			ply:DropObject()
		end
	else
		if IsValid(ply:GetNWEntity("Corpse")) then
			ply.fakeragdoll = nil
			SavePlyInfoPreSpawn(ply)

			local pos = ply:GetNWEntity("Corpse"):GetPos()
			local vel = ply:GetNWEntity("Corpse"):GetVelocity()
			
			ply:UnSpectate()
			
			ply.unfaked = true
			ply:SetNWBool("unfaked", ply.unfaked)
			ply:Spawn()
			
			ReturnPlyInfo(ply)

			ply:SetNWInt("FakeShooting", false)
			ply:SetVelocity(vel)
			ply.unfaked = false

			ply:SetNWBool("unfaked", ply.unfaked)
			ply:SetParent()
			ply:SetPos(pos)
			ply:DrawWorldModel(true)

			ply:GetNWEntity("Corpse"):Remove()
			ply:SetNWEntity("Corpse", nil)
		end
	end
end

// в последствии будет необходимо написать какую - нибудь синхронизацию (можно использовать c hash)


function UpdateClModelsForRag(rag, new_equip)
	if SERVER then return end
	local function createModel(ent_eq)
		local mdl
		if ent_eq.CreateEquipDrawModel then
			// create with entfunc
			mdl = ent_eq:CreateEquipDrawModel(rag)
		else
			// creating with our forces
			if ent_eq.EquipModelDraw then
				local mdl = ClientsideModel(ent_eq.EquipModelDraw.model or ent_eq:GetModel())
				if ent_eq.EquipModelDraw.bodygroups then
					mdl:SetBodyGroups(ent_eq.EquipModelDraw.bodygroups)
				end
				
				if ent_eq.EquipModelDraw.skin then
					mdl:SetSkin(ent_eq.EquipModelDraw.skin)
				end

				if ent_eq.EquipModelDraw.size then
					mdl:SetModelScale(ent_eq.EquipModelDraw.size)
				end
			end
		end
		return mdl
	end

	rag.Equipment = new_equip

	//print(rag, rag.Equipment)
	//PrintTable(rag.Equipment)

	if !rag.Equipment then return end
	for eq_key, ent_eq in pairs(rag.Equipment) do
		if eq_key == EQUIP_ID or eq_key == EQUIP_SUIT then continue end
		if IsValid(ent_eq) then
			if rag.CLEquipment[eq_key] then
				// check, for this ent we draw
				if rag.CLEquipment[eq_key].item != ent_eq then
					rag.CLEquipment[eq_key].model:Remove()
					rag.CLEquipment[eq_key] = nil
					local model = createModel(ent_eq)

					rag.CLEquipment[eq_key] = {
						model = model,
						item = ent_eq,
					}
				end
			else
				local model = createModel(ent_eq)
				

				rag.CLEquipment[eq_key] = {
					model = model,
					item = ent_eq,
				}
			end
		else
			if rag.CLEquipment[eq_key] then
				// delete model
				rag.CLEquipment[eq_key].model:Remove()
				rag.CLEquipment[eq_key] = nil
			end
		end 
	end
end

local function SyncEquipRagdoll(rag)
	if SERVER then
		local equip = rag.Equipment
		net.Start("gs_corpse_update")
		net.WriteEntity(rag)
		net.WriteEntity(equip.BELT)
		net.WriteEntity(equip.KEYCARD)
		net.WriteEntity(equip.BACKPACK)
		net.WriteEntity(equip.VEST)
		net.WriteEntity(equip.HEAD)
		net.WriteEntity(equip.MASK)
		net.WriteEntity(equip.EAR)
		//net.WriteEntity(equip.SUIT) // какой смысл отправлять, если и так понятно, да и с трупов не снимишь костюм
		net.Broadcast()
	else
		local new_equip = {
			BELT      = net.ReadEntity(),
			KEYCARD   = net.ReadEntity(),
			BACKPACK  = net.ReadEntity(),
			VEST      = net.ReadEntity(),
			HEAD      = net.ReadEntity(),
			MASK      = net.ReadEntity(),
			EAR       = net.ReadEntity(),
			//SUIT	  = net.ReadEntity(),
		}
		//timer.Simple(0, function())
		//print("UPDATE FOR CORPSE", rag, new_equip)
		//print(rag, IsValid(rag))
		if !IsValid(rag) then
			util.WaitForValidEnt(rag, function()
				print(rag, "is valid!")
			end)
		end

		rag.CLEquipment = rag.CLEquipment or {}
		UpdateClModelsForRag(rag, new_equip)

		//after death return size of head
		rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Head1"), Vector(1,1,1))

		rag:CallOnRemove("RemoveCModels", function()
			if !rag.CLEquipment then return end
			for k, v in pairs(rag.CLEquipment) do
				if v.model then
					v.model:Remove()
				end
			end
		end)
	end
end

function SetCorpseDead(ply, needTime)
	local rag = ply:GetNWEntity("Corpse")
	if !IsValid(rag) then return end
	// apply damage
	// apply equipment

	rag:SetNWBool("DeadCorpse", true)
	rag:SetNWEntity("RagdollOwner", Entity(-1))

	rag.Name = ply:GetName()
	rag.Desc = "ded xD"

	rag.PlyID = ply:SteamID()

	rag.Body_Parts 			= ply.Body_Parts
	rag.Organism_Value 		= ply.Organism_Value

	rag.Chemicals 			= ply.Chemicals
	rag.HealthStatus 		= ply.HealthStatus
	rag.Ragdolled 			= ply.Ragdolled
	rag.CritParalyzeDelay  	= ply.CritParalyzeDelay

	rag.Equipment 	= ply.Equipment
	rag.Pockets 	= ply.Pockets
	
	if needTime then
		timer.Simple(0, function()
			SyncEquipRagdoll(rag)
		end)
	else
		SyncEquipRagdoll(rag)
	end
	//table.insert(GS_Corpses, rag)
	GS_Corpses[rag] = true
	// need broadcasting and syncing ragdoll trup data
end

hook.Add("PostDrawOpaqueRenderables", "CorpseEquipDraw", function()
	for k, rag in pairs(ents.FindByClass( "prop_ragdoll" )) do
		//print(rag, rag:GetNWBool("IsCorpse"))
		if !rag:GetNWBool("IsCorpse") then continue end
		
		local draw_target = rag

		local equip = rag.CLEquipment
		//print(rag:GetNWEntity("RagdollOwner"))
		if IsValid(rag:GetNWEntity("RagdollOwner")) then
			equip = rag:GetNWEntity("RagdollOwner").CLEquipment
			//PrintTable(equip)
		end

		if !equip then continue end

		for k, equip_item in pairs(equip) do
			if table.IsEmpty(equip_item) then
				continue
			end
			//print(equip_item)
			local drawData = equip_item.item.EquipModelDraw 
			local boneid = draw_target:LookupBone( drawData.bone )
				
			if not boneid then
				continue
			end
			
			local matrix = draw_target:GetBoneMatrix( boneid )
			
			if not matrix then 
				continue
			end

			local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

			debugoverlay.Axis(pos, ang, 10, 0, true)

			local ang_offset =  drawData.offset_ang
			local pos_offset =  drawData.offset_pos

			local Right, Forward, Up = ang:Right(), ang:Forward(), ang:Up()
			pos = pos + Right * pos_offset.x + Forward * pos_offset.y + Up * pos_offset.z

			local mdl = equip_item.model
			ang:RotateAroundAxis(Right, ang_offset.p)
			ang:RotateAroundAxis(Up,ang_offset.y)
			ang:RotateAroundAxis(Forward, ang_offset.r)

			mdl:SetRenderOrigin(pos)
			mdl:SetRenderAngles(ang)
			mdl:SetupBones()
			mdl:DrawModel()
		end
	end
end)

hook.Add("PlayerDeath", "resetfakes", function(ply, inflictor, attacker)
	if ply.InFake then
		SetCorpseDead(ply)

		ply:SetNWEntity("Corpse", nil)
		
		Faking(ply)
		ply:SetParent()
		ply:Spectate(OBS_MODE_ROAMING)
		//ply:SetNWEntity("Corpse", nil)

	end
end)

if SERVER then
	local sync_cd = 2
	local last_sync = CurTime()

	hook.Add("Think", "SyncEquipRagdoll", function()
		if last_sync > CurTime() then return end

		for corpse, v in pairs(GS_Corpses) do 
			if !IsValid(corpse) then  		// clean deleted rags
				GS_Corpses[corpse] = nil
				continue
			end
		
			SyncEquipRagdoll(corpse)
		end

		last_sync = CurTime() + sync_cd
	end)
end

if CLIENT then
	net.Receive("gs_corpse_update", function(len)
		local rag = net.ReadEntity()

		//print(len)
		SyncEquipRagdoll(rag)
	end)
end


if SERVER then
	concommand.Add("fake", function(ply)
		Faking(ply)
	end)
end