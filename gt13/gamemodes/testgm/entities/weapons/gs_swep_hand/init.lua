AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:Deploy()
    self:HoldTypeTriger(self.hand_item != nil)
end

function SWEP:Equip()
    --self:HoldTypeTriger(self.hand_item != nil)
    self.FightHand = false
    self.RCooldown = 0
    self.BCooldown = 0
    self:SetHoldType( "normal" )
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

function SWEP:MakeTrace()
    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 70 ,
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    
    trace = util.TraceLine(trace)

    return trace
end

function SWEP:BeatEntity()
    if self.BCooldown > CurTime() then
        return
    end
    self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

    local VModel = self:GetOwner():GetViewModel()
    
    VModel:SendViewModelMatchingSequence( math.random(3, 5) )
    self:EmitSound(SwingSound)

    self.BCooldown = CurTime() + 0.8

    timer.Simple(0.2, function()
        if !IsValid(self) then
            return
        end

        local trace = self:MakeTrace()

        if trace.Hit == false then
            return
        end

        self:EmitSound(HitSound)
        
        if IsValid(trace.Entity) then
            if trace.Entity:IsPlayer() then
                player_manager.RunClass( trace.Entity, "HurtPart", trace.PhysicsBone, {[D_BRUTE] = math.random(3, 5)})
            end
        end

    end)

end

function SWEP:PickupEntity()
    if self:HaveItem() then
        return
    end
    
    local trace = self:MakeTrace()

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

function SWEP:PrimaryAttack()
    if self.FightHand then
        self:BeatEntity()
    else
        if self:HaveItem() then
            self:PrimaryItemAction()
        else
            self:PickupEntity()
        end
    end
end

function SWEP:SecondaryAttack()
    if self:HaveItem() then
        self:InsertItemInEnt()
    else
        self:FightModeToggle()
    end
end

function SWEP:InsertItemInEnt()
    local trace = self:MakeTrace()

    if !trace.Entity or trace.Entity:IsPlayer() or !trace.Entity:IsValid() then
        return
    end
    
    local entity = trace.Entity

    if entity.ItemReceiver then
        local item = entity:InsertItem(ply, self.hand_item.item)
        if item then
            self:UpdateItem(item)
        elseif item == nil then
            self:RemoveItem()
        elseif item == false then
            --nothing
        end
    end
end

function SWEP:FightModeToggle(bool)
    if self:HaveItem() or self.RCooldown > CurTime() then
        return
    end
    if bool == nil then
        if self.FightHand then
            self.FightHand = false
            self:HoldTypeTriger(false)
            GS_ChatPrint(self:GetOwner(), "You lowered your fists")
        else
            self.FightHand = true
            self:SetHoldType("fist")
            GS_ChatPrint(self:GetOwner(), "You prepared FISTS", Color(255,50,50))
        end
    else
        self.FightHand = bool 
    end
    
    self.RCooldown = CurTime() + 1
    self:ViewModeFight()

end

function SWEP:ViewModeFight()
    local VModel = self:GetOwner():GetViewModel()

    if self.FightHand then
        VModel:SendViewModelMatchingSequence( 2 )
    end
    
    net.Start("gs_hand_vm")
    net.WriteBool(self.FightHand)
    net.Send(self:GetOwner())

end

function SWEP:HaveItem()
    print(self.hand_item.item != nil)
    return self.hand_item.item != nil
end

function SWEP:GetItem()
    return self.hand_item.item or false
end

function SWEP:UpdateItem(itm)
    if !self:HaveItem()  then
        return false
    end

    self.hand_item.item = itm
    self:SendToClientDrawModel(self.hand_item != nil)
    self:HoldTypeTriger(self.hand_item != nil)
    
    return true
end

function SWEP:RemoveItem()
    if !self:HaveItem()  then
        return false
    end

    self:SendToClientDrawModel(false)
    self.hand_item.item = nil
    self:HoldTypeTriger(self.hand_item != nil)
    
    return true
end

function SWEP:PutItemInHand(itemA)
    if self:HaveItem() then
        return false
    end

    PrintTable(itemA)
    self.hand_item.item = itemA
    self:SendToClientDrawModel(true)
    self:HoldTypeTriger(self.hand_item != nil)
    
    return true
end

function SWEP:PrimaryItemAction()
    if self:HaveItem() == false then
        return false
    end
    
    if ItemType(self.hand_item.item) == GS_ITEM_CONTAINER then
        self:OpenHandContainer()
        self.OpenContainer = true
        return
    end

    
    local id,typ = self.hand_item.item.Data_Labels.id, self.hand_item.item.Data_Labels.type

    local rez_func = GS_EntityControler.RunFunctionEntity("hand_primary", id ,typ, self.hand_item.item, self:GetOwner(), CB_HAND)

    if rez_func != false then
        if rez_func == nil then
            self:RemoveItem()
        else
            self:UpdateItem(rez_func)
        end

    end



end

function SWEP:GetItemsContainer()
    return self.hand_item.item.Private_Data.Items
end

function SWEP:GetItemFromContainer(key)
    return self.hand_item.item.Private_Data.Items[key]
end

function SWEP:InsertItemInContainer(item)
    if #self.hand_item.item.Private_Data.Items + 1 > self.hand_item.item.Private_Data.Max_Items then
        return false
    end

    table.insert(self.hand_item.item.Private_Data.Items, item)
    player_manager.RunClass( self:GetOwner(), "OpenEntContainer", self)
    return true
end

function SWEP:RemoveItemFromContainer(key)
    if self.hand_item.item.Private_Data.Items[key] == nil then
        return false
    end

    table.remove(self.hand_item.item.Private_Data.Items, key)
    player_manager.RunClass( self:GetOwner(), "OpenEntContainer", self)
end

function SWEP:UpdateItemInContainer(item, key)
    if self.hand_item.item.Private_Data.Items[key] == nil then
        return false
    end
    
    if item == nil then
        self:RemoveItemFromContainer(key)
        return
    end

    self.hand_item.item.Private_Data.Items[key] = item
    player_manager.RunClass( self:GetOwner(), "OpenEntContainer", self)
end

function SWEP:CloseContainer()
    player_manager.RunClass( self:GetOwner(), "CloseEntContainer")
    self.OpenContainer = false
end

function SWEP:Holster()
    if self.OpenContainer then
        self:CloseContainer()
    end
    return true
end

function SWEP:Deploy()
    if !self.hand_item then
        self.hand_item = {}
    end

    self:HoldTypeTriger(self.hand_item != nil)

    return true
end

function SWEP:DropItem()
    if !self:HaveItem() then
        return
    end

    if self.OpenContainer then
        self:CloseContainer()
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
    
    if self.OpenContainer then
        self:CloseContainer()
    end
end

function SWEP:Reload()
    if self:HaveItem() then
        self:DropItem()
    end

end

function SWEP:ExamineItem()
	local examine = {self.hand_item.item.Entity_Data.Name, self.hand_item.item.Entity_Data.Desc}
	local priv = {}

    if self.hand_item.item.Entity_Data.Simple_Examine != true then
        local priv = GS_EntityControler:ExamineData(self.hand_item.item)
    end
	
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
    local model, enum = "", 0
    if haveItem then
        model = self.hand_item.item.Model
        enum = self.hand_item.item.Entity_Data.ENUM_Type
    end
    net.Start("gs_hand_draw_model")
    net.WriteEntity(self)
    net.WriteBool(haveItem)
    net.WriteString(model)
    net.WriteUInt(enum, 5)
    net.Broadcast()
end

net.Receive("gs_hand_item_make_action",function(_, ply)
    local id = net.ReadUInt(3)

    local hand = ply:GetWeapon("gs_swep_hand")

    if hand == nil then
        return
    end

    hand:MakeAction(id)
end)

