PLAYER_INVENTARY = {}

function PLAYER_INVENTARY:SetupInventary()
	self.Player.Equipment = {
		BELT      = 0,
		EYES      = 0,
		KEYCARD   = 0,
		PDA       = 0,
		BACKPACK  = 0,
		VEST      = 0,
		HEAD      = 0,
		MASK      = 0,
		EAR       = 0,
		--SUIT      = 0,
	}

	self.Player.Pocket = {{},{}}
	--self.Player.Suit = "casual"
end

function PLAYER_INVENTARY:InsertItemInPocket(item, pocket)
	if !FitInContainer(ITEM_SMALL, item.Entity_Data) then
		self.Player:ChatPrint(item.Entity_Data.Name.." is not fit in pocket")
		return false
	end

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


function PLAYER_INVENTARY:UpdateItemInPocket(item, pocket)
	if !item then
		self.Player.Pocket[pocket] = {}
	else
		self.Player.Pocket[pocket] = item
	end
	self:SendToClientItemsFromPocket()
	return true
end

function PLAYER_INVENTARY:GetItemFromPocket(pocket)
	if table.IsEmpty(self.Player.Pocket[pocket]) then
		return false
	end

	return self.Player.Pocket[pocket]
end

function PLAYER_INVENTARY:RemoveItemFromPocket(pocket)
	if table.IsEmpty(self.Player.Pocket[pocket]) then
		return false
	end

	self.Player.Pocket[pocket] = {}
	self:SendToClientItemsFromPocket()
end

function PLAYER_INVENTARY:MoveSWEPToPocket(weapon, key)
	local data = duplicator.CopyEntTable(weapon)

	local succes = self:InsertItemInPocket(data, key)
	
	if succes then
		self.Player:StripWeapon( weapon:GetClass() )
		self:SendToClientItemsFromPocket()
	end

end

function PLAYER_INVENTARY:HaveEquipment(key)	
	if self.Player.Equipment[key] != 0 then 
		return true
	end

	return false
end

function PLAYER_INVENTARY:EquipItem(itemData, key)
	if key == "SUIT" then
		return self:ChangeSuit(itemData)
	end

	if self:HaveEquipment(key) then
		return false
	end
	
	self.Player.Equipment[key] = itemData
	--PrintTable(itemData)
	self:EquipmentEquipClient(itemData, key)
	
	return true
end

function PLAYER_INVENTARY:GetEquipItem(key)
	if key == "SUIT" then
		return self:GetSuit()
	end

	if !self:HaveEquipment(key) then
		return false
	end

	return self.Player.Equipment[key]
end

function PLAYER_INVENTARY:RemoveEquip(key)
	if type(key) == "number" then
		key = FAST_EQ_TYPE[key]
	end

	--print(key)

	if !self:HaveEquipment(key) then
		return false
	end

	if self.Player.Hands:HaveItem() then
		self.Player:ChatPrint("Your hands is full!")
		return false -- deequip item only in hands
	end

	self.Player.Hands:PutItemInHand(self.Player.Equipment[key])
	self.Player.Equipment[key] = 0

	self:DeEquipItemClient(key)
end

function PLAYER_INVENTARY:GetItemFromBackpack(key)
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end
	
	return self.Player.Equipment.BACKPACK.Private_Data.Items[key]
end

function PLAYER_INVENTARY:RemoveItemFromBackpack(key)
	if self.Player.Equipment.BACKPACK == 0 then
		return
	end

	table.remove(self.Player.Equipment.BACKPACK.Private_Data.Items, key)
	self:SendToClientItemsFromBackpack()
end 

function PLAYER_INVENTARY:SendToClientItemsFromBackpack()
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

function PLAYER_INVENTARY:SendToClientItemsFromPocket()
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

function PLAYER_INVENTARY:UpdateItemInBackpack(key,data)
	if self.Player.Equipment.BACKPACK == 0 then
		return 
	end
	print(key, data)
	self.Player.Equipment.BACKPACK.Private_Data.Items[key] = data
end

function PLAYER_INVENTARY:InsertItemInBackpack(data)
	if self.Player.Equipment.BACKPACK == 0 then
		return 
	end
	
	if !FitInContainer(self.Player.Equipment.BACKPACK.Entity_Data.Item_Max_Size, data.Entity_Data) then
		self.Player:ChatPrint(data.Entity_Data.Name.." is not fit in "..self.Player.Equipment.BACKPACK.Entity_Data.Name)
		return false
	end

	table.insert(self.Player.Equipment.BACKPACK.Private_Data.Items, data)

	return true
end

function PLAYER_INVENTARY:OpenItemContainer() -- we can open the box while the in hands
	self.OpenContainer = self.Player.Hands
end

function PLAYER_INVENTARY:OpenEntContainer(entity)
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

function PLAYER_INVENTARY:CloseEntContainer(client)
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

function PLAYER_INVENTARY:GetItemFromContext(context, key)
	if context == CONTEXT_ITEM_IN_BACK then
		return self:GetItemFromBackpack(key)
	elseif context == CONTEXT_POCKET then
		return self:GetItemFromPocket(key)
	elseif context == CONTEXT_ITEM_IN_CONT then
		return self.OpenContainer:GetItemFromContainer(key)
	elseif context == CONTEXT_EQUIPMENT then
		return self:GetEquipItem(key)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:GetItem()
	end
end

function PLAYER_INVENTARY:InsertItemInContext(context, item, pocket)
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

function PLAYER_INVENTARY:RemoveItemFromContext(context, key)
	if context == CONTEXT_ITEM_IN_BACK then
		return self:RemoveItemFromBackpack(key)
	elseif context == CONTEXT_POCKET then
		return self:RemoveItemFromPocket(key)
	elseif context == CONTEXT_ITEM_IN_CONT then
		return self.OpenContainer:RemoveItemFromContainer(key)
	elseif context == CONTEXT_EQUIPMENT then
		return self:RemoveEquip(key)
	elseif context == CONTEXT_HAND then
		return self.Player.Hands:RemoveItem()
		
	end
end

function PLAYER_INVENTARY:UpdateItemInContext(context, item, key)
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

function PLAYER_INVENTARY:UseWeaponFromInventory(key, from)
	local weapon = self:GetItemFromContext(from, key)
	if weapon != nil then
		local ent = duplicator.CreateEntityFromTable(game.GetWorld(), weapon)
		self.Player:PickupWeapon(ent)
		self:RemoveItemFromContext(from, key)
	end
end

function PLAYER_INVENTARY:DropEntFromInventary(key, from)
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

function PLAYER_INVENTARY:DropSWEP(weapon)
	-- remake this with concmd 
	if weapon.GS_Hand then
		return
	end

	self.Player:SelectWeapon("gs_weapon_hands")
	self.Player:DropWeapon(weapon)
end

function PLAYER_INVENTARY:DropSWEPBeforeRagdollize()
	local weap = self.Player:GetActiveWeapon()
	if weap.GS_Hand then
		weap:DropItem()
	else
		self.Player:DropWeapon(weap)
	end
end

function PLAYER_INVENTARY:EquipmentEquipClient(itemData, key)
	net.Start("gs_equipment_update")
	net.WriteUInt(FAST_HUD_TYPE[key], 5)
	net.WriteBool(true)
	net.WriteString(itemData.Class)
	net.Send(self.Player)

	self:DrawEquipSync()
end 

function PLAYER_INVENTARY:DeEquipItemClient(key)
	net.Start("gs_equipment_update")
	net.WriteUInt(FAST_HUD_TYPE[key], 5)
	net.WriteBool(false)
	net.Send(self.Player)

	self:DrawEquipSync()
end

function PLAYER_INVENTARY:DrawEquipSync()
	for k, v in pairs(self.Player.Equipment) do
		if v != 0 then
			self.Player:SetNWString("EQ_"..k, v.Entity_Data.Model)
		else
			self.Player:SetNWString("EQ_"..k, "")
		end
	end
end

function PLAYER_INVENTARY:ExamineItemFromInventory(keyitem, from)
	local item = self:GetItemFromContext(from, keyitem)
	
	if !item then
		return
	end

	local examine = {"It's a "..item.Entity_Data.Name, item.Entity_Data.Desc}
	local priv = GS_EntityControler:ExamineData(item)

	table.Add(examine, priv)

	for k, v in pairs(examine) do
		self.Player:ChatPrint(v)
	end
end

function PLAYER_INVENTARY:CompareEntAndEnt(receiver, drop)
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

function PLAYER_INVENTARY:MakeNormalContext(receiver, drop)
	if receiver.from == CONTEXT_WEAPON_SLOT and receiver.entity != self.Player.Hands  then
		local drop_ent = self:GetItemFromContext(drop.from, drop.key)
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
	elseif receiver.from == CONTEXT_EQUIPMENT then
		local drop_item = self:GetItemFromContext(drop.from,drop.key)

		PrintTable(drop_item)

		local key = FAST_EQ_TYPE[ItemSubType(drop_item)]
		if !self:HaveEquipment(key) then
			local success = self:EquipItem(drop_item, key)

			if success then
				self:RemoveItemFromContext(drop.from, drop.key)
			end
		else
			self.Player:ChatPrint("Already have this one")
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
					self.Player:StripWeapon( drop.entity:GetClass() )
				end
			else
				local drop_item = self:GetItemFromContext(drop.from, drop.key)

				print(drop.from, drop.key)

				if drop_item then
					local succes = self:InsertItemInContext(receiver.from, drop_item, receiver.key)
					if succes then
						self:RemoveItemFromContext(drop.from, drop.key)
					end-- ____     
				end--    ||/\||      
			end --_______||  ||_____________
		end-- -- --  O  /     / -- 0  o -- --
	end  -- -- 0 -- 0  /     / 0  O -- O -- o
end  -- o  0 -- o --  ______  0 -- o -- 0 -- o
--___________________--------_________
--| the whole world   0    is theatre|
--| and YOU are the  /|\   main clown|
--|                  /\              |



function PLAYER_INVENTARY:SetSuit(suit)
	if !suit then
		return
	end

	local model = Ply_Models["male_0".. tostring(self.Character.model)][suit][1]
	
	if model then
		self:SetModel(model)
		self.Player.Suit = suit
	end

end

function PLAYER_INVENTARY:GetSuit()
	return self.Player.Suit
end

function PLAYER_INVENTARY:ChangeSuit(itemData)
	local ch_suit = itemData.Private_Data.suit
	local ply_suit = self.Player.Suit

	if !ch_suit then
		return
	end

    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 50 ,
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }

    trace = util.TraceLine(trace)

	GS_EntityControler:MakeEntity("suit_"..ply_suit, "suit", trace.HitPos)

	self:SetSuit(ch_suit)
	return true
end


