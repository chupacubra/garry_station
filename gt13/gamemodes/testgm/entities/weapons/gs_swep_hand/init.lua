AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function SWEP:Initialize()
    self:SetHoldType( "normal" )
end

function SWEP:Deploy()
    self:HoldTypeTriger(self.hand_item != nil)
end

function SWEP:Equip()
    self:HoldTypeTriger(self.hand_item != nil)
end


function SWEP:HoldTypeTriger(bool)
    if bool then
        if self.hand_item.item then
            self:SetHoldType("slam")
        else
            self:SetHoldType("normal")
        end
    else
        self:SetHoldType("normal")
    end
end


function SWEP:PrimaryAttack()
    if self.hand_item.item then
        self:PrimaryItemAction()
    end

    --make trace
    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 70 ,
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    
    trace = util.TraceLine(trace)
    if !trace.Entity:IsValid() then
        return
    end

    if trace.Entity.CanPickup then
        self.hand_item.item = duplicator.CopyEntTable(trace.Entity)

        PrintTable(self.hand_item.item)
        
        trace.Entity:Remove()
        self:SendToClientDrawModel(true)
        self:HoldTypeTriger(self.hand_item != nil)
    end
end

function SWEP:SecondaryAttack()
    if self:GetOwner().Equipment.BACKPACK != 0 then
        if self.hand_item.item then
            player_manager.RunClass( self:GetOwner(), "InsertItemInBackpack", self.hand_item.item )
            self:SendToClientDrawModel(false)
            self.hand_item.item = nil
            self:HoldTypeTriger(self.hand_item != nil) 
        end
    end
end

function SWEP:HaveItem()
    print(self.hand_item.item != nil)
    return self.hand_item.item != nil
end

function SWEP:GetItem()
    return self.hand_item.item or false
end

function SWEP:UpdateItem(itm)
    if self.hand_item.item then

        self:SendToClientDrawModel(false)
        self.hand_item.item = nil
        self:HoldTypeTriger(self.hand_item != nil)
        
        return true
    end
end

function SWEP:RemoveItem()
    if self.hand_item.item then
        self:SendToClientDrawModel(false)
        self.hand_item.item = nil
        self:HoldTypeTriger(self.hand_item != nil)
        
        return true
    end
end

function SWEP:PutItemInHand(itemA)
    if self.hand_item.item then
        return false
    end

    PrintTable(itemA)
    self.hand_item.item = itemA
    self:SendToClientDrawModel(true)
    self:HoldTypeTriger(self.hand_item != nil)
    
    return true
end

function SWEP:PrimaryItemAction()
    if self.hand_item.primary_action == nil then
        return
    end
    self.hand_item.primary_action(self)
end


function SWEP:Holster()
    return true
end

function SWEP:Deploy()
    if !self.hand_item then
        self.hand_item = {}
    end

    self:HoldTypeTriger(self.hand_item != nil)

    return true
end

function SWEP:Holster()
   return true
end

function SWEP:DropItem()
    if !self.hand_item.item then
        return
    end

    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 50 ,
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    trace = util.TraceLine(trace)
    self:SendToClientDrawModel(false)


    local ent = duplicator.CreateEntityFromTable( nil, self.hand_item.item )
    ent:SetPos(trace.HitPos)
    ent:Spawn()

    self.hand_item.item = nil
    self:HoldTypeTriger(self.hand_item != nil)
end

function SWEP:Reload()
    self:DropItem()
end

function SWEP:ExamineItem()
	local examine = {self.hand_item.item.Entity_Data.Name, self.hand_item.item.Entity_Data.Desc}
	local priv = GS_EntityControler:ExamineData(self.hand_item.item)

	table.Add(examine, priv)

    net.Start("gs_cl_inventary_examine_return") -- because he does same
	net.WriteTable(examine)
	net.Send(self:GetOwner())
end

function SWEP:MakeAction(id)
    if id == 1 then -- drop item
        self:DropItem()
    elseif id == 2 then -- examine item
        self:ExamineItem()
    end
end

function SWEP:SendToClientDrawModel(haveItem)
    local model = ""
    if haveItem then
        model = self.hand_item.item.Model
    end
    net.Start("gs_hand_draw_model")
    net.WriteEntity(self)
    net.WriteBool(haveItem)
    net.WriteString(model)
    net.Broadcast()
end

net.Receive("gs_hand_item_make_action",function(_, ply)
    local id = net.ReadUInt(3)

    local hand = ply:GetWeapon("gs_weapon_hand")

    if hand == nil then
        return
    end

    hand:MakeAction(id)
end)