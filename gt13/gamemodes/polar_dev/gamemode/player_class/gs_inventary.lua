/*
ALERT!
All inventory funcs uses "Hided" items,
*/

PLAYER_INVENTARY = {}

function PLAYER_INVENTARY:SetupInventary()
	self.Player.Equipment = {
		BELT      = NULL,
		KEYCARD   = NULL,
		BACKPACK  = NULL,
		VEST      = NULL,
		HEAD      = NULL,
		MASK      = NULL,
		EAR       = NULL,
		SUIT	  = NULL,
	}

	if CLIENT then
		self.Player.CLEquipment = {}
	end

	self.Player.Pocket = {NULL, NULL}

	//if SERVER then
	//	self:EquipSync()
	//end

	//self:EquipSync()

	if CLIENT then
		self:EquipSyncClient(self.Player.Equipment)
	end
end

function PLAYER_INVENTARY:CanOpenContainer()
	// check some ply cond, dont have some
	return true
end

function PLAYER_INVENTARY:GetEquip(key)
	return self.Player.Equipment[key]
end

function PLAYER_INVENTARY:GetAllEquip()
	return self.Player.Equipment
end

function PLAYER_INVENTARY:HaveEquipment(key)	
	if IsValid(self.Player.Equipment[key]) then 
		return true
	end

	return false
end

function PLAYER_INVENTARY:CanEquipItem(item)
	// check item equiped already
	if IsValid(item.EquipOwner) then return false end
	// check item is real
	if !IsValid(item) then return false end
	// check item is equip
	if !item.IsEquip then return false end
	// check item type we already have
	if IsValid(self.Player.Equipment[item.TypeEquip]) then return false end

	return true
end

function PLAYER_INVENTARY:EquipItem(item)
	if !self:CanEquipItem(item) then
		return false
	end

	if item.TypeEquip == "SUIT" then
		return self:ChangeSuit(item)
	end
	
	if item.OnEquip then
		item:OnEquip(ply)
	end

	self.Player.Equipment[item.TypeEquip] = item
	item:SetParentContainer(self.Player)
	self:EquipSync()

	return true
end

local function recover(ply, ent)
	local trace = {
		start = self.Player:EyePos(),
		endpos = self.Player:EyePos() + self.Player:GetAimVector() * (70),
		filter =  function( ent ) return ( ent != self.Player ) end
	}
	
	trace = util.TraceLine(trace)

	item:ItemRecover(trace.HitPos)
end

function PLAYER_INVENTARY:DequipItem(item, container)
	if item.TypeEquip == "SUIT" then
		// we cant remove suit, only change to another
		return false
	end
	
	self.Player.Equipment[item.TypeEquip] = NULL
	self:EquipSync()

	if item.OnDeEquip then
		item:OnDeEquip(ply)
	end
	/*
	if IsValid(container) then
		// move in container or drop
		//if container.IsHands then
			local success = container:ItemInteraction(item)
			if !success then
				// item recover
				recover(self.Player, item)
			end
		//else
			
		//end
	else
		// drop equip in somewhere
		local trace = {
			start = self.Player:EyePos(),
			endpos = self.Player:EyePos() + self.Player:GetAimVector() * (70),
			filter =  function( ent ) return ( ent != self.Player ) end
		}
		
		trace = util.TraceLine(trace)

		item:ItemRecover(trace.HitPos)
	end
	*/

	PrintTable(self.Player.Equipment)
	self:EquipSync()
	return true
end

function PLAYER_INVENTARY:RemoveEquipItem(key)
	local item = self.Player.Equipment[key]

	print(item, key)
	PrintTable(self.Player.Equipment)

	if !IsValid(item) then
		return false
	end

	return self:DequipItem(item)
end

function PLAYER_INVENTARY:SyncPockets()
	net.Start("gs_sync_pockets")
	net.WriteTable(self.Player.Pocket)
	net.Send(self.Player)
end

function PLAYER_INVENTARY:GetItemFromPocket(key)
	return self.Player.Pocket[key]
end

function PLAYER_INVENTARY:PutItemInPocket(item, key)
	if IsValid(self.Player.Pocket[key]) then 
		self.Player:ChatPrint("Your pocket is full")
		return false
	end
	
	// item.Size = ITEM_SMALL
	if item.Size > ITEM_SMALL then 
		self.Player:ChatPrint(item.Name.." dont fit in pocket")
		return false
	end

	item:SetParentContainer(self.Player)

	self.Player.Pocket[key] = item
	self:SyncPockets()
	return true
end

function PLAYER_INVENTARY:RemoveItemFromPocket(key)
	if !IsValid(self.Player.Pocket[key]) then 
		self.Player:ChatPrint("Pocket is empty")
		return false
	end

	self.Player.Pocket[key] = NULL
	self:SyncPockets()
	
	return true
end

function PLAYER_INVENTARY:RemoveItemFromInventary(ent)
	// equip or pocket or swep
	// check pocket first
	for i = 1, 2 do
		if self.Player.Pocket[i] == ent then
			return self:RemoveItemFromPocket(i)
		end
	end
	// if not in pocket, then check equip
	for k, v in pairs(self.Player.Equipment) do
		if v == ent then
			return self:RemoveEquipItem(k)
		end
	end
end



function PLAYER_INVENTARY:HandleContextAction(rec, drp)
	local function transform(slot)
		if slot.context == CONTEXT_EQUIP then
			local item = self:GetEquip(EQUIP_NAMES[slot.key])
			slot.cont  = self.Player
			slot.item  = item
			slot.empty = item == NULL
		elseif slot.context == CONTEXT_SWEP then
			local item = self.Player:GetWeapons()[slot.key]

			if item.IsHands then
				// if have item then slot.item will be this item
				// if no - item will be hands
				local h_item = item:GetItem()
				if IsValid(h_item) then
					slot.cont  = item
					slot.item  = item:GetItem()
					slot.empty = item == NULL
				else
					slot.item  = item
					slot.empty = false
				end
			else
				slot.cont  = self.Player
				slot.item  = item
				//slot.empty = item == NULL
			end
			

		elseif slot.context == CONTEXT_CONTAINER_ITEM then
			//slot.cont
			print(slot.cont)
			local item = slot.cont:GetItem(slot.key)

			slot.item  = item
			slot.empty = item == NULL
		elseif slot.context == CONTEXT_POCKET then
			//slot.cont
			local item = self.Player.Pocket[slot.key]

			slot.item  = item
			slot.empty = item == NULL
		end

		return slot
	end

	local function deleteItem(slot)
		// remove item from his cont
		if slot.cont:IsPlayer() then
			if slot.context == CONTEXT_EQUIP then
				print("removing item from equip")
				self:RemoveEquipItem(EQUIP_NAMES[slot.key])
			elseif slot.context == CONTEXT_POCKET then
				self:RemoveItemFromPocket(slot.key)
			end
		else
			slot.cont:RemoveItem(slot.key)
		end
	end

	local slot_rec = transform(rec)
	local slot_drp = transform(drp)

	if IsValid(slot_rec.item) and IsValid(slot_drp.item) then
		if slot_drp.item.IsHands then return end
		print("try put item in another", slot_rec.item, slot_drp.item)
		if slot_rec.item:ItemInteraction(slot_drp.item) then
			deleteItem(slot_drp)
		end
	elseif slot_rec.empty and IsValid(slot_drp.item) then
		local success = false
		if slot_rec.context == CONTEXT_EQUIP then
			success = self:EquipItem(slot_drp.item)
		elseif slot_rec.context == CONTEXT_POCKET then
			success = self:PutItemInPocket(slot_drp.item, slot_rec.key)
		end

		if success then
			deleteItem(slot_drp)
		end
	end

end

function PLAYER_INVENTARY:EquipSync(ply_target)
	// potom optimiz

	net.Start("gs_equip_sync")
	net.WritePlayer(self.Player)
	net.WriteTable(self.Player.Equipment)
	if IsValid(ply_target) then
		net.Send(ply_target)
	else
		net.Broadcast()
	end
end

function PLAYER_INVENTARY:EquipSyncClient(new_equip)
	if SERVER then return end
	local function createModel(ent_eq)
		local mdl
		if ent_eq.CreateEquipDrawModel then
			// create with entfunc
			mdl = ent_eq:CreateEquipDrawModel(self.Player)
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

	self.Player.Equipment = new_equip

	//PrintTable(self.Player.Equipment)

	for eq_key, ent_eq in pairs(self.Player.Equipment) do
		if eq_key == EQUIP_ID or eq_key == EQUIP_SUIT then continue end
		if IsValid(ent_eq) then
			if self.Player.CLEquipment[eq_key] then
				// check, for this ent we draw
				if self.Player.CLEquipment[eq_key].item != ent_eq then
					self.Player.CLEquipment[eq_key].model:Remove()
					self.Player.CLEquipment[eq_key] = nil
					local model = createModel(ent_eq)

					self.Player.CLEquipment[eq_key] = {
						model = model,
						item = ent_eq,
					}
				end
			else
				local model = createModel(ent_eq)
				

				self.Player.CLEquipment[eq_key] = {
					model = model,
					item = ent_eq,
				}
			end
		else
			if self.Player.CLEquipment[eq_key] then
				// delete model
				self.Player.CLEquipment[eq_key].model:Remove()
				self.Player.CLEquipment[eq_key] = nil
			end
		end 
	end
end



net.Receive("gs_cl_contex_item_action", function(_, ply)
	local rec = {
		cont	= net.ReadEntity(),
		context = net.ReadUInt(5),
		key 	= net.ReadUInt(5)
	}
	
	local drp = {
		cont	= net.ReadEntity(),
		context = net.ReadUInt(5),
		key  	= net.ReadUInt(5)
	}

	player_manager.RunClass(ply, "HandleContextAction", rec, drp)
end)

net.Receive("gs_equip_sync", function()
	local ply = net.ReadPlayer()
	local tbl = net.ReadTable()

	player_manager.RunClass(ply, "EquipSyncClient", tbl)
	hook.Run("PlayerEquipUpdated", ply, tbl)
end)

if SERVER then return end

function PLAYER_INVENTARY:DrawEquip()
	if !self.Player.CLEquipment then return end
    for k, eq in pairs(self.Player.CLEquipment) do
        if !table.IsEmpty(eq) then
			local drawData = eq.item.EquipModelDraw
            local boneid = self.Player:LookupBone( drawData.bone )
                
            if not boneid then
                return
            end
            
            local matrix = self.Player:GetBoneMatrix( boneid )
            
            if not matrix then 
                return 
            end

			local pos, ang = matrix:GetTranslation(), matrix:GetAngles()

			//debugoverlay.Axis(bone_pos, bone_ang, 10, 0, true)

			local ang_offset =  drawData.offset_ang
			local pos_offset =  drawData.offset_pos

			local Right, Forward, Up = ang:Right(), ang:Forward(), ang:Up()
			pos = pos + Right * pos_offset.x + Forward * pos_offset.y + Up * pos_offset.z

			local mdl = eq.model
			ang:RotateAroundAxis(Right, ang_offset.p)
			ang:RotateAroundAxis(Up,ang_offset.y)
			ang:RotateAroundAxis(Forward, ang_offset.r)

            mdl:SetRenderOrigin(pos)
            mdl:SetRenderAngles(ang)
            mdl:SetupBones()
            mdl:DrawModel()
        end
    end
end

hook.Add( "PostPlayerDraw" , "gs_draw_equip_model", function( ply )
    if ply:IsValid() then
        player_manager.RunClass(ply, "DrawEquip")
    end
end)

net.Receive("gs_sync_pockets", function(_, ply)
	local pockets = net.ReadTable()

	LocalPlayer().Pocket = pockets

	hook.Run("UpdatePockets", pockets)
end)

if CLIENT then
	concommand.Add("clear_equip", function(ply)
		player_manager.RunClass(ply, "EquipSyncClient", {		
		BELT      = NULL,
		KEYCARD   = NULL,
		BACKPACK  = NULL,
		VEST      = NULL,
		HEAD      = NULL,
		MASK      = NULL,
		EAR       = NULL,
		SUIT	  = NULL,
	})
	end)

	concommand.Add("reset_equip", function(ply)
		player_manager.RunClass(ply, "EquipSyncClient", ply.Equipment)
	end)
end