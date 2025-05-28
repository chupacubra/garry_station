/*
ALERT!
All inventory funcs uses "Hided" items,
*/

PLAYER_INVENTARY = {}

function PLAYER_INVENTARY:SetupInventary()
	self.Player.Equipment = {
		BELT      = NULL,
		//EYES      = NULL,
		KEYCARD   = NULL,
		//PDA       = NULL,
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
	// check item is real
	if !IsValid(item) then return false end
	// check item is equip
	if !item.IsEquip then return false end
	// check item type we already have
	if IsValid(self.Player.Equipment[item.TypeEquip]) then return false end

	return true
end

function PLAYER_INVENTARY:EquipItem(item)
	if item.TypeEquip == "SUIT" then
		return self:ChangeSuit(item)
	end
	
	if item.Equip then
		item:Equip(ply)
	end

	self.Player.Equipment[item.TypeEquip] = item
	item:SetParentContainer(self.Player)
	self:EquipSyncClient()
	return true
end

function PLAYER_INVENTARY:RemoveEquipItem(key)
	if item.TypeEquip == "SUIT" then
		// we cant remove suit, only change to another
		return false
	end
	
	self.Player.Equipment[item] = NULL
	self:EquipSyncClient()

	if item.DeEquip then
		item:DeEquip(ply)
	end
	
	return true
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

	return true
end

function PLAYER_INVENTARY:RemoveItemFromPocket(key)
	if !IsValid(self.Player.Pocket[key]) then 
		self.Player:ChatPrint("Pocket is empty")
		return false
	end

	self.Player.Pocket[key] = NULL
	
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

function PLAYER_INVENTARY:EquipSyncClient()
	if SERVER then return end
	for eq, ent_eq in pairs(self.Player.Equipment) do
		if ent_eq then
			if eq == EQUIP_ID or eq == EQUIP_SUIT then continue end
			if self.Player.CLEquipment[eq] then
				// check, for this ent we draw
				if self.Player.CLEquipment[eq].item != ent_eq then
					local model = self.Player.CLEquipment[eq]
					model.item  = ent_eq
					model.color = ent_eq:GetColor()
					model.pos = {} // for offsets and bones
					
					if model.ent:IsValid() then
						model.ent:Remove()
					end
					model.ent = ClientsideModel(ent_eq:GetModel())

					self.Player.CLEquipment = model
				end
			else
				local model = {}
				model.item  = ent_eq
				model.color = ent_eq:GetColor()
				model.pos = {} // for offsets and bones

				model.ent = ClientsideModel(ent_eq:GetModel())
				
				self.Player.CLEquipment = model
			end
		else
			if self.Player.CLEquipment[eq] then
				// delete model
				self.Player.CLEquipment[eq].ent:Remove()
				self.Player.CLEquipment[eq] = nil
			end
		end
	end
end


function PLAYER_INVENTARY:HandleContextAction(rec, drp)
	// i like it
	local function transform(slot)
		/*
		{
			slot  = "equip"/"cont"/"pocket"/"swep"
			key   = 1/-1 if empty (empty slot in container - insert)
			empty = true/false        -- SWEP:IsEmpty() neeeded
			item  = [Entity]/nil      
			cont  = [Player]/[Entity]
		}
		*/
		if slot.slot == CONTEXT_SWEP then
			-- if item can contain item
			-- SWEP:GetLastItem() => custom func
			-- hands it some like a container
			-- and can be cont
			local item = self.Player:GetWeapons()[slot.key]

			if item.IsHands then
				slot.slot = CONTEXT_CONTAINER
				slot.cont = item
				slot.item = item:GetItem()
				slot.empty = !slot.item
			end
			/// ...
			return
		end

		if slot.slot == CONTEXT_CONTAINER then
			local cont = self.Player.OpenedContainer
			slot.cont = cont
			if key > 0 then
				slot.item  = cont:GetContainerItem(slot.key)
				slot.empty = false
			else
				slot.item  = NULL
				slot.empty = true
			end
			return
		end

		if slot.slot == CONTEXT_EQUIP then
			local item = self:GetEquip(FAST_EQ_TYPE[slot.key])
			slot.cont  = self.Player
			slot.item  = item
			slot.empty = item == NULL
		end

		if slot.slot == CONTEXT_POCKET then 
			local item = self:GetItemFromPocket(slot.key)
			slot.cont  = self.Player
			slot.item  = item
			slot.empty = item == NULL
		end
	end

	local function deleteItem(slot)
		// remove item from his cont
		if slot.cont:IsPlayer() then
			if slot.slot == CONTEXT_EQUIP then
				self:RemoveEquipItem(slot.key)
			elseif slot.slot == CONTEXT_POCKET then
				self:RemoveItemFromPocket(slot.key)
			end
		else
			slot.cont:RemoveItem(slot.key)
		end
	end
	/*
	1. превращаем таблицы типа слот в тип item или пустой слот
	*/
	// ENT/SWEP:ItemInteraction(item) (?)
	
	local rec_slot = transform(rec)
	local drp_slot = transform(drp) 

	if !rec_slot.empty then
		if !drp_slot.empty then
			/*
			if rec_slot.item:ItemInteraction(rec_slot.item) then
				// need delete item from his cont/equip
				deleteItem(slot)
			end
			*/
			//if rec_slot.slot == CONTEXT_SWEP then
				
			//end
			local rez = rec_slot.item:ItemInteraction(rec_slot.item)
			if rez != false then
				drp_slot.item:UpdateItem(rez, drp_slot.key)
			end
		end
	else
		// then its a empty slot
		if rec_slot.cont:IsPlayer() then
			local succes = false
			if drp_slot.slot == CONTEXT_EQUIP then
				succes = self:EquipItem(drp_slot.item)
			elseif slot.slot == CONTEXT_POCKET then
				succes = self:PutItemInPocket(drp_slot.item, drp_slot.key)
			end
			if succes then
				deleteItem(drp_slot)
			end
		else
			// inserting item in cont
			if !drp_slot.empty then
				local rez = rec_slot.item:ItemInteraction(rec_slot.item)
				if rez != false then
					drp_slot.item:UpdateItem(rez, drp_slot.key)
				end
			end
		end
	end
	
end

net.Receive("gs_cl_contex_item_action", function(_, ply)
	local rec = {
		from = net.ReceiveUInt(6),
		key  = net.ReceiveUInt(5)
	}
	
	local drp = {
		from = net.ReceiveUInt(6),
		key  = net.ReceiveUInt(5)
	}

	player_manager.RunClass(ply, "HandleContextAction", rec, drp)
end)

if SERVER then return end

function PLAYER_INVENTARY:DrawEquip()
    self:EquipSync()

    for k, eq in pairs(self.Player.CLEquipment) do
        if !table.IsEmpty(eq) then
            local boneid = self.Player:LookupBone( eq.bone )
                
            if not boneid then
                return
            end
            
            local matrix = self.Player:GetBoneMatrix( boneid )
            
            if not matrix then 
                return 
            end
            
            local newpos, newang = LocalToWorld(eq.offset["vec"], eq.offset["ang"], matrix:GetTranslation(), matrix:GetAngles() )
            
            eq.model:SetRenderOrigin(newpos)
            eq.model:SetRenderAngles(newang)
            eq.model:SetupBones()
            eq.model:DrawModel()

			/*
			PARENT TO BONE!
			*/
        end
    end

end

hook.Add( "PostPlayerDraw" , "gs_draw_equip_model", function( ply )
    if ply:IsValid() then
        player_manager.RunClass(ply, "DrawEquip")
    end
end)