AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

local prop_force = 60000
local no_throw   = false

local DIR_ANG = {
    Angle(1,0,0),
    Angle(-1,0,0),
    Angle(0,1,0),
    Angle(0,-1,0),
    Angle(0,0,1),
    Angle(0,0,-1),
}

local function MoveObject(phys, pdir, maxforce, is_ragdoll)
    if not IsValid(phys) then return end
    local speed = phys:GetVelocity():Length()
 
    -- remap speed from 0 -> 125 to force 1 -> 4000
    local force = maxforce + (1 - maxforce) * (speed / 125)
 
    if is_ragdoll then
       force = force * 2
    end
 
    pdir = pdir * force
 
    local mass = phys:GetMass()
    -- scale more for light objects
    if mass < 50 then
       pdir = pdir * (mass + 0.5) * (1 / 50)
    end
 
    phys:ApplyForceCenter(pdir)
end


local function KillVelocity(ent)
    ent:SetVelocity(vector_origin)
    SetSubPhysMotionEnabled(ent, false)
    timer.Simple(0, function() SetSubPhysMotionEnabled(ent, true) end)
end


function SWEP:Equip()
    self.RCooldown = 0
    self.ManipEnt  = E_NIL

    self:SetHoldType( "normal" )
end

function SWEP:Holster()
    if self.OpenContainer then
        self:CloseContainer()
    end

    self:ManipModeReset()
    return true
end

function SWEP:Deploy()
    if !self.hand_item then
        self.hand_item = {}
    end
    
    self.dt = {}
    self.dt.carried_rag = nil

    self:ManipModeReset()
    self:HoldTypeTriger(self.hand_item != nil)

    return true
end

function SWEP:OnRemove()
    self:ManipModeReset()
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

function SWEP:MakeTrace(range)
    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * (70 or range),
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    
    trace = util.TraceLine(trace)

    return trace
end

function SWEP:BeatEntity()

    -- why is this dont work?
    --self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

    local VModel = self:GetOwner():GetViewModel()
    
    VModel:SendViewModelMatchingSequence( math.random(3, 5) )
    
    self:EmitSound(SwingSound)

    self:SetNextPrimaryFire(CurTime() + 0.8)

    timer.Simple(0.2, function()
        if !IsValid(self) then return end

        local trace = self:MakeTrace()

        if !trace.Hit then return end

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
    if self:GetNWBool("FightHand") then
        self:BeatEntity()
    else
        if self:HaveItem() then
            self:PrimaryItemAction()
        else
            if self:GetNWBool("ManipMode") then
                self:ManipPickupEnt()
            else
                self:PickupEntity()
            end
        end
    end
end

function SWEP:SecondaryAttack()
    if self:HaveItem() then
        self:InsertItemInEnt()
    elseif self:GetNWBool("ManipMode") then
        self:PushItem()
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
        end
    end
end

function SWEP:FightModeToggle(bool)
    if self:GetNWBool("ManipMode") or self:HaveItem() then
        return
    end

    self:SetNWBool("FightHand", self:GetNWBool("FightHand") != true )

    if !self:GetNWBool("FightHand") then
        self:HoldTypeTriger(false)
        GS_ChatPrint(self:GetOwner(), "You lowered your fists")
    else
        self:SetHoldType("fist")
        GS_ChatPrint(self:GetOwner(), "You prepared FISTS", Color(255,50,50))
    
        local VModel = self:GetOwner():GetViewModel()
        VModel:SendViewModelMatchingSequence( 2 )
    end

    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:HaveItem()
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
    self:SendToClientDrawModel(self:HaveItem())
    self:HoldTypeTriger(self:HaveItem())
    
    return true
end

function SWEP:RemoveItem()
    if !self:HaveItem() then
        return false
    end

    self:SendToClientDrawModel(false)
    self.hand_item.item = nil
    self:HoldTypeTriger(self:HaveItem())
    
    return true
end

function SWEP:PutItemInHand(itemA)
    if self:HaveItem() then
        return false
    end

    PrintTable(itemA)
    self.hand_item.item = itemA
    self:SendToClientDrawModel(true)
    self:HoldTypeTriger(self:HaveItem())
    
    self:GetOwner():SelectWeapon( self:GetClass() )

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

    if self.hand_item.item.Data_Labels then
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

function SWEP:DropItem()
    if !self:HaveItem() then
        return
    end

    if self.OpenContainer then
        self:CloseContainer()
    end

    self:SendToClientDrawModel(false)

    local trace = self:MakeTrace(50)
    local ent = duplicator.CreateEntityFromTable( nil, self.hand_item.item )
    ent:SetPos(trace.HitPos)
    ent:Spawn()

    self.hand_item.item = nil
    self:HoldTypeTriger(self:HaveItem())
    
    if self.OpenContainer then
        self:CloseContainer()
    end
end

function SWEP:ManipulatorMode()
    if ( !self:GetOwner():KeyPressed( IN_RELOAD ) ) then return end

    if self:GetNWBool("FightHand") then
        return
    end

    self:SetNWBool( "ManipMode", !self:GetNWBool("ManipMode") )

    if self:GetNWBool("ManipMode") then
        GS_ChatPrint(self:GetOwner(), "You prepared hands to manipulate object", Color(50,255,50))
    else
        GS_ChatPrint(self:GetOwner(), "You now don't manipulate object", Color(50,200,50))
        self:ManipModeReset()
    end
end

function SWEP:ManipModeReset()
    if IsValid(self.CarryHack) then
        self.CarryHack:Remove()
    end
  
    if IsValid(self.CarryConstr) then
        self.CarryConstr:Remove()
    end
    
    if !IsValid(self.ManipEnt) then
        return
    end

    local phys = self.ManipEnt:GetPhysicsObject()
    if IsValid(phys) then
        phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
        phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
        phys:EnableCollisions(true)
        phys:EnableGravity(true)
        phys:EnableDrag(true)
        phys:EnableMotion(true)
    end

    if (not keep_velocity) and (no_throw or self.ManipEnt:GetClass() == "prop_ragdoll") then
        KillVelocity(self.ManipEnt)
    end

    self.dt.carried_rag = nil

    self.ManipEnt = nil
    self.CarryHack = nil
    self.CarryConstr = nil
    self.ManipRotate = nil
end

function SWEP:ManipDrop()
    self.CarryConstr:Remove()
    self.CarryHack:Remove()

    local ent = self.ManipEnt

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
       phys:EnableCollisions(true)
       phys:EnableGravity(true)
       phys:EnableDrag(true)
       phys:EnableMotion(true)
       phys:Wake()
       phys:ApplyForceCenter(self:GetOwner():GetAimVector() * 500)

       phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
       phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
    end

    -- Try to limit ragdoll slinging
    if no_throw or ent:GetClass() == "prop_ragdoll" then
       KillVelocity(ent)
    end

    ent:SetPhysicsAttacker(self:GetOwner())
end

function SWEP:ManipToggleRotate(direct, status)
    if status then
        self.ManipRotate = direct
    else
        if self.ManipRotate == direct then
            self.ManipRotate = nil
        end
    end
end

function SWEP:ManipPickupEnt()
    if IsValid(self.ManipEnt) then
        -- drop last ent pickup
        self:ManipModeReset()
        return
    end

    -- get code from TTT 'carry'
    
    local trace = self:MakeTrace()

    if IsValid(trace.Entity) then
        local ent = trace.Entity
        local entphys = ent:GetPhysicsObject()

        if IsValid(ent) and IsValid(entphys) then
            self.ManipEnt = ent
            self.CarryHack = ents.Create("prop_physics")

            if !IsValid(self.CarryHack) then
                return
            end

            self.CarryHack:SetPos(self.ManipEnt:GetPos())

            self.CarryHack:SetModel("models/weapons/w_bugbait.mdl")
   
            self.CarryHack:SetColor(Color(50, 250, 50, 240))
            self.CarryHack:SetNoDraw(true)
            self.CarryHack:DrawShadow(false)
   
            self.CarryHack:SetHealth(999)
            self.CarryHack:SetOwner(ply)
            self.CarryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self.CarryHack:SetSolid(SOLID_NONE)
            

            self.CarryHack:SetAngles(self.ManipEnt:GetAngles())
   
            self.CarryHack:Spawn()

            local phys = self.CarryHack:GetPhysicsObject()
            if IsValid(phys) then
               phys:SetMass(200)
               phys:SetDamping(0, 1000)
               phys:EnableGravity(false)
               phys:EnableCollisions(false)
               phys:EnableMotion(false)
               phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            end
   
            entphys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
            local bone = math.Clamp(trace.PhysicsBone, 0, 1)
            local max_force = prop_force
   
            if ent:GetClass() == "prop_ragdoll" then
               self.dt.carried_rag = ent
   
               bone = trace.PhysicsBone
               max_force = 0
            else
               self.dt.carried_rag = nil
            end
   
            self.CarryConstr = constraint.Weld(self.CarryHack, self.ManipEnt, 0, bone, max_force, true)
   
        end
    end

end

function SWEP:PushItem()
    if !self:GetNWBool("ManipMode") then
        return
    end

    local trace = self:MakeTrace()
    
    if !IsValid(trace.Entity) then
        return
    end

    local is_ragdoll = trace.Entity:GetClass() == "prop_ragdoll"

    local ent = trace.Entity
    local phys = ent:GetPhysicsObject()
    local pdir = trace.Normal * -1

    if is_ragdoll then
       phys = ent:GetPhysicsObjectNum(trace.PhysicsBone)
    end

    if IsValid(phys) then
       MoveObject(phys, pdir, 6000, is_ragdoll)
       return
    end
end

function SWEP:Reload()
    if self:HaveItem() then
        self:DropItem()
    else
        self:ManipulatorMode()
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
    if haveItem then
        local model, enum, color = "", self.hand_item.item.Entity_Data.ENUM_Type, ""

        if self.hand_item.item.IsGS_Weapon then
            model = self.hand_item.item.WorldModel
        else
            model = self.hand_item.item.Entity_Data.Model
        end

        if self.hand_item.item.Private_Data then
            color = self.hand_item.item.Private_Data.ENT_Color or ""
        end

        self:SetNWString("hands_model", FormatDataForCLHands({model,enum,color}))
    else
        self:SetNWString("hands_model", "")
    end
end

local ent_diff = vector_origin
local ent_diff_time = CurTime()

function SWEP:Think()
    if !self:GetNWBool("ManipMode") then
        return
    end

    if !IsValid(self.ManipEnt) then
        self:ManipModeReset()
        return
    end

    if CurTime() > ent_diff_time then
        ent_diff = self:GetPos() - self.ManipEnt:GetPos()
        if ent_diff:Dot(ent_diff) > 40000 then
           self:Reset()
           return
        end
  
        ent_diff_time = CurTime() + 1
     end

    self.CarryHack:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 70)

    if self.ManipRotate then
        self.CarryHack:SetAngles(self.CarryHack:GetAngles() + DIR_ANG[self.ManipRotate])
    end

    self.ManipEnt:PhysWake()
end


net.Receive("gs_hand_item_make_action",function(_, ply)
    local id = net.ReadUInt(3)

    local hand = ply:GetWeapon("gs_swep_hand")

    if hand == nil then
        return
    end

    hand:MakeAction(id)
end)


-- controll
concommand.Add( "gs_manipcontrol_down", function(ply, str, arg)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end
            wep:ManipToggleRotate(tonumber(arg[1]), true)
        end
    end
end)

concommand.Add( "gs_manipcontrol_up", function(ply, str, arg)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end
            wep:ManipToggleRotate(tonumber(arg[1]), false)
        end
    end
end)