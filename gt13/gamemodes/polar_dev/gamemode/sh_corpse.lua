GS_Corpse = {}
local PLAYER = FindMetaTable("Player")

--[[
    THE CORPSE MUST BE APART HUMAN
    SAVE IN CORPSE ONLY ID PLY
]]
--[[
function GS_Corpse.SendCorpseClient(rag)
    net.Start("gs_sys_corpse_create")
    net.WriteEntity(rag)
    net.Broadcast()
end
--]]

function GS_Corpse.SetDrawEq(corpse, tbl)
    -- setNWString()
end
/*
function GS_Corpse.Create(ply)
    local ragdoll = ents.Create("prop_ragdoll")

    ragdoll:SetCustomCollisionCheck(true)
    ragdoll:SetPos( ply:GetPos() )
    ragdoll:SetModel( ply:GetModel() )
    ragdoll:SetAngles(Angle((ply:GetAngles().p), (ply:GetAngles().y), ply:GetAngles().r))
    ragdoll:Spawn()

    ragdoll.RagdollStartSpeed = ply:GetVelocity()

    local bones = ragdoll:GetPhysicsObjectCount()
    for i=1,bones-1 do
        local bone = ragdoll:GetPhysicsObjectNum( i )  
        if bone:IsValid() then  
            local bonepos = ply:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) ) 
            local bonematrix = ply:GetBoneMatrix(ragdoll:TranslatePhysBoneToBone( i ))
            local boneang = bonematrix:GetAngles()

            bone:SetPos( bonepos )  
            bone:SetAngles( boneang )  
            bone:SetVelocity(ragdoll.RagdollStartSpeed)  
        end  
    end

    ragdoll.ownerID = ply:SteamID()
    ragdoll.corpse  = true

    return ragdoll
end

*/
function GS_Corpse.SetRagdollDeath(ply, rag, leave) -- if ply death in crit paralyze -> set RAG to death
    --[[
        set equipment, pockets
        set hp (for redeem?!)
        set data
    
        if ply is DEAD ->
            all actions handler GS_Corpse
        else crit only
            all actions handler GS_Corpse AND gs_human CLASS
    ]]
    rag.ply_dead   = true
    rag.ownerID    = ply:SteamID()
    rag.disconnect = leave

    local items = {
        equip   = ply.Equipment,
        pocket  = ply.Pocket,
    }
    local body = {
        parts   = ply.Body_Parts,
        organs  = ply.Organs,
        bones   = ply.Bones,
        hp_eff  = ply.HP_Effect,
    }
    --local
    rag.Corpse = {
        /*
        Equipment = equip,
        Pocket    = pocket,
        Body      = body,
        hp_eff    = hp_effect,
        */
        Items   = items,
        Body    = body,
    }
end

function GS_Corpse.ExamineRag(viewer, rag)
    local examine = {}

    table.insert(examine, "It's human corpse.")
    --test: alive or ded

    if rag.ply_dead then
        if rag.disconnect then
            table.insert(examine, "Deep depression...")
        else
            table.insert(examine, "It's DEAD!")
        end 
    else
        --test: status hp
        local ply = player.GetBySteamID(rag.ownerID)

        if IsValid(ply) then
            local hp_stat = ply.HealthStatus
            if hp_stat == GS_HS_OK then
                table.insert(examine, "It's look good")
            elseif hp_stat == GS_HS_CRIT then
                table.insert(examine, "Face is pale...")
            end
        else
            --GS_MSG(rag.ownerID.." no in server but rag in not dead mark and this runned, WTF?")
            table.insert(examine, "The is strange")
        end
    end

    for k, v in pairs(examine) do
        ply:ChatPrint(v)
    end
end

function GS_Corpse.DamageHandler(trup, dmg)
    -- get part of body

    local typ = GS_DMG_LIST[dmg:GetDamageType()]
    if !typ then
        GS_MSG("want to apply damage to corpse, but type unknw: "..tostring(dmg:GetDamageType()))
        
        return
    end

    if trup.ply_dead then
        -- ply dead, simple add damage/break bone
    else
        -- ply is alive, give HIM damage

    end
end

net.Receive("gs_sys_corpse_action", function(_,ply)
    local rag = net.ReadEntity()
    local act = net.ReadUInt(4)
    local arg = net.ReadUInt(4)

    if !IsValid(rag) then
        return
    end

    if act == 0 then  -- EXAMINE COPRSE
        GS_Corpse.ExamineRag(ply, rag)
    else
        --[[
            other actions
        ]]
    end
end)





function PLAYER:CreateFakeRagdoll(attacker, dmginfo)
	print("CREATE RAGDOLL", ply)
	if not self:Alive() and self.fake then return nil end
	local rag = self:GetNWEntity("DeathRagdoll")

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

	self:SetNWEntity("DeathRagdoll", rag)

/*
	if self:Alive() then
		self:SetNWEntity("DeathRagdoll", rag)
	else
		self:SetNWEntity("DeathRagdoll", rag)
		self.curweapon = self:GetActiveWeapon():GetClass()
		local guninfo = weapons.Get(self.curweapon)
		if guninfo.Base == "salat_base" then
			SpawnWeapon(self)
		end

		self:Spectate(OBS_MODE_ROAMING)
		self:SetMoveType(MOVETYPE_OBSERVER)
		rag:SetEyeTarget(vector_origin)
		if self.IsBleeding then
			rag.IsBleeding = true
		end

		rag.deadbody = true
	end
	*/
end


function PLAYER:Ragdollize()
	//if !IsValid(self:GetNWEntity("DeathRagdoll")) then
		Faking(self)
	//end
end

function PLAYER:UnRagdollize()

end

// from homidrad core
// peredelat
function SavePlyInfo(ply)
	/*
	ply.Info = {}
	local info = ply.Info
	info.HasSuit = ply:IsSuitEquipped()
	info.SuitPower = ply:GetSuitPower()
	info.Ammo = ply:GetAmmo()
	info.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil
	info.ActiveWeapon2 = ply:GetActiveWeapon()
	//GetFakeWeapon(ply)
	info.Weapons = {}
	for i, wep in pairs(ply:GetWeapons()) do
		info.Weapons[wep:GetClass()] = {
			Clip1 = wep:Clip1(),
			Clip2 = wep:Clip2(),
		}
	end

	return info
	*/
	return {}
end


-- Сохранение игрока перед вставанием
function SavePlyInfoPreSpawn(ply)
	/*
	ply.Info = ply.Info or {}
	local info = ply.Info
	info.Hp = ply:Health()
	info.Armor = ply:Armor()

	*/
	return {}
end

-- возвращение информации игроку по его вставанию
function ReturnPlyInfo(ply)
	//ClearFakeWeapon(ply)
	/*
	local info = ply.Info
	if not info then return end
	ply:SetSuppressPickupNotices(true)
	ply:StripWeapons()
	ply:StripAmmo()
	for name, wepinfo in pairs(info.Weapons or {}) do
		local weapon = ply:Give(name, true)
		if IsValid(weapon) then
			weapon:SetClip1(wepinfo.Clip1)
			weapon:SetClip2(wepinfo.Clip2)
		end
	end

	for ammo, amt in pairs(info.Ammo or {}) do
		ply:GiveAmmo(amt, ammo)
	end

	if info.ActiveWeapon then
		ply:SelectWeapon(info.ActiveWeapon)
	end

	if info.HasSuit then
		ply:EquipSuit()
		ply:SetSuitPower(info.SuitPower or 0)
	else
		ply:RemoveSuit()
	end

	ply:SetHealth(info.Hp)
	ply:SetArmor(info.Armor)
	ply:SetSuppressPickupNotices(false)
	*/
end

-- функция падения
-- добавить дроп всех предметов в руках
function Faking(ply)
	ply.fake = not ply.fake
	ply:SetNWBool("fake", ply.fake)
	if ply.fake == true then
		SavePlyInfo(ply)
		//ply:DrawViewModel(false)
		if SERVER then
			ply:DrawWorldModel(false)
		end

		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		print("ply", ply, "is going to rag")
		ply:CreateFakeRagdoll()
		print(ply, ply:GetNWEntity("DeathRagdoll"), ply:GetRagdollEntity()) 
		if IsValid(ply:GetNWEntity("DeathRagdoll")) then
			ply.fakeragdoll = ply:GetNWEntity("DeathRagdoll")
			ply:RagSpectate()
			--ply:SetParent(ply:GetNWEntity("DeathRagdoll"))
			ply:SetSuppressPickupNotices(false)
			ply:SetActiveWeapon(nil)
			ply:DropObject()
			//timer.Create("faketimer" .. ply:EntIndex(), 2, 1, function() end)
			//local guninfo = weapons.Get(ply.curweapon)
			/*
			if guninfo and guninfo.Base == "salat_base" then
				ply.FakeShooting = true
				ply:SetNWInt("FakeShooting", true)
			else
				ply.FakeShooting = false
				ply:SetNWInt("FakeShooting", false)
			end
			*/
		end
	else
		if IsValid(ply:GetNWEntity("DeathRagdoll")) then
			ply.fakeragdoll = nil
			SavePlyInfoPreSpawn(ply)
			local pos = ply:GetNWEntity("DeathRagdoll"):GetPos()
			local vel = ply:GetNWEntity("DeathRagdoll"):GetVelocity()
			--ply:UnSpectate()
			ply.unfaked = true
			ply:SetNWBool("unfaked", ply.unfaked)
			//local eyepos = ply:EyeAngles()
			ply:Spawn()
			//ReturnPlyInfo(ply)
			//ply.FakeShooting = false
			ply:SetNWInt("FakeShooting", false)
			ply:SetVelocity(vel)
			//ply:SetEyeAngles(eyepos)
			ply.unfaked = false

			ply:SetNWBool("unfaked", ply.unfaked)
			ply:SetParent()
			ply:SetPos(pos)
			//ply:DrawViewModel(true)
			ply:DrawWorldModel(true)

			ply:GetNWEntity("DeathRagdoll"):Remove()
			ply:SetNWEntity("DeathRagdoll", nil)
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

hook.Add(
	"PlayerDeath",
	"resetfakes",
	function(ply, inflictor, attacker)
		if ply.fake then
			ply:SetNWEntity("DeathRagdoll", nil)
			Faking(ply)
			ply:SetParent()
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SetNWEntity("DeathRagdoll", nil)
		end
        /*
		if ply.Attacker ~= nil and ply.Attacker ~= ply:Nick() then
			if bonenames[tostring(ply.LastHit)] ~= nil then
				ply:ChatPrint("you were killed by a " .. ply.Attacker .. " in " .. bonenames[tostring(ply.LastHit)] .. ".")
			else
				ply:ChatPrint("you were killed by a " .. ply.Attacker .. ".")
			end

			print(bonenames[tostring(ply.LastHit)])
		else
			ply:ChatPrint("You dead.")
		end
        */
	end
)

if SERVER then
	concommand.Add("fake", function(ply)
		Faking(ply)
	end)
end