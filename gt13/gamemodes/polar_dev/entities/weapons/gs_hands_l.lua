AddCSLuaFile("gs_hands_manipulate.lua")
include("gs_hands_manipulate.lua")

SWEP.Author			= "God"
SWEP.Contact		= "Sky"
SWEP.Purpose		= "Make"
SWEP.Instructions	= ""
SWEP.SlotPos        = 0
SWEP.PrintName = "Left hand"

SWEP.IsHands    = true
SWEP.CanDrop    = true

SWEP.HoldType = "normal"
SWEP.Category = "Other"

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false

SWEP.ViewModel = "models/weapons/c_arms.mdl" 
SWEP.WorldModel = ""
SWEP.DrawAmmo = false

SWEP.LeftHand = true

SWEP.CombatMode = false
SWEP.ManipMode  = false

SWEP.MinDMG = 3
SWEP.MaxDMG = 6
SWEP.CritRand = 0.2

SWEP.BlockCD = 0
SWEP.NextR = 0

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

/*
need make some hard work

this is base for 2 hands - gs_hand_l, gs_hand_r
need making this to work together(?)

for small arms (pistols) need 1 hand

always drawn item in hand

need SHARED version for 2 hands of combat mode or smthng

the "broker" will be a player
*/
/*
local function WMHandsModelUpdate(ply)
    local cl_model = ClientsideModel(item:GetModel())
    cl_model:SetColor(item:GetColor())

    local h1 = ply:GetWeapon( "gs_hand_l" )
    local h2 = ply:GetWeapon( "gs_hand_r" )

    local a = ply:GetActiveWeapon()

    if a != h1 and a != h2 then return end

    local h = {
        [h1] = ply:GetActiveWeapon() == h1,
        [h2] = ply:GetActiveWeapon() == h2
    }
    
    for hand, isActive in pairs(h) do
        local item = hand:GetItem()
        if !item then continue

        local offsetVec = Vector(3, -3, -1)
        local offsetAng = Angle(0, 0, 180)
        
        local boneid = ply:LookupBone( "ValveBiped.Bip01_R_Hand" and isActive or "ValveBiped.Bip01_L_Hand" )
        if !boneid then return end

        local matrix = ply:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        cl_model:SetPos(newPos)
        cl_model:SetAngles(newAng)
        cl_model:SetupBones()
        cl_model:FollowBone( ply, boneid )

        hand.WModel = cl_model
    end
end
*/
if SERVER then
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

    concommand.Add( "gs_throw", function(ply, str, arg)
        if ply:IsValid() and ply:Team() == TEAM_PLY then
            if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
                local wep = ply:GetActiveWeapon()
                wep:Throw(tonumber(arg[1]))
            end
        end
    end)

    concommand.Add( "gs_manipmode", function(ply, str, arg)
        if ply:IsValid() and ply:Team() == TEAM_PLY then
            if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
                local wep = ply:GetActiveWeapon()
                wep:ChangeManipulatemode()
            end
        end
    end)
end

function SWEP:MakeTrace(range)
    local trace = {
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * (70 or range),
        filter =  function( ent ) return ( ent != self:GetOwner() ) end
    }
    
    trace = util.TraceLine(trace)

    debugoverlay.Line( self:GetOwner():EyePos(), self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * (70 or range))

    return trace
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Entity", 0, "Item" )
    self:NetworkVar( "Bool", 0, "ManipMode")

	if SERVER then
		self:SetItem( NULL )
    else
        self:NetworkVarNotify( "Item", function(self, _, old, new)
            /*
            cl_plyhanddraw handle this

            if new:IsValid() then
                if !self.iwm:IsValid() then
                    self.iwm = ClientsideModel(new:GetModel())
                else
                    self.iwm:SetModel(new:GetModel())
                end
                
            else
                if self.iwm:IsValid() then
                    self.iwm:Remove()
                end
            end
            */
        end)
    end
end

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.BlockCD = 0
    if SERVER then return end
    self.iwm = NULL // clientside model
    self:CallOnRemove("RemoveCM", function(self)
        if self.iwm:IsValid() then
            self.iwm:Remove()
        end
    end)
end

function SWEP:Deploy()
    // TODO: make flag active for hand
    // if hand is not active - cant deploy
    //
    self:UpdateHoldType()
    return true
end

function SWEP:Holster( wep )
    //if not IsFirstTimePredicted() then return end
    self:ManipModeReset()

    //if wep and self.Blocking then
    //    return false
    //end
    return true
end

function SWEP:IsBlocking()
    return self.Blocking == true
end

function SWEP:UpdateHoldType()
    if self:IsCombat() then
        self:SetHoldType("fist")
    else
        if self:HaveItem() then
            self:SetHoldType("slam")
        else 
            self:SetHoldType("normal")
        end 
    end
end

function SWEP:ItemInteraction(itm)
    if self:GetItem():IsValid() then return end
    // put item in hand
    self:PickupItem(itm)
    return true
end

function SWEP:RemoveItem()
    if self:GetItem():IsValid() then return end

    self:SetItem(NULL)
    return true
end
 
function SWEP:UpdateItem(upd_ent, key)
    if key <= 0 then
        GS_MSG("Trying update item in cont, but ket is invalid")
        return
    end
    if upd_ent == nil then
        // removing item
        self:RemoveItem(key)
    else
        upd_ent:MoveItemInContainer(self)
        self:SetItem(upd_ent)
    end 
end

function SWEP:HaveItem()
    return IsValid(self:GetItem())
end

function SWEP:ChangeMode()
    if CLIENT then return end
    -- making request to a player class handler
    
    //local combat = player_manager.RunClass(self:GetOwner(), "HandsChangeMode")

    local combat = self:GetOwner():GetNWBool("CombatMode")
    
    if combat then
        self:SetHoldType("normal")
        GS_ChatPrint(self:GetOwner(), "You lowered your fists")
        self:GetOwner():SetNWBool("CombatMode", false)
    else
        self:SetHoldType("fist")
        GS_ChatPrint(self:GetOwner(), "You prepared FISTS", Color(255,50,50))
        self:GetOwner():SetNWBool("CombatMode", true)
    end
end

function SWEP:CanChangeMode()
    return !(self:HaveItem() or self:IsBlocking())
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if self.NextR > CurTime() then return end
    if IsValid(self:GetItem()) then
        self:DropItem()
        return
    end

    if self:CanChangeMode() then
        self:ChangeMode()
        self:UpdateHoldType()
    end

    self.NextR = CurTime() + 1
end

function SWEP:IsCombat()
    return self:GetOwner():GetNWBool("CombatMode")
end

function SWEP:UpdateCSModels()

    if CLIENT then
        PlayerUpdateWorldModelsSWEP(self:GetOwner(), self:GetOwner():GetWeapons(), self)
    else
        net.Start("gs_hands_model_update")
        net.WritePlayer(self:GetOwner())
        net.WriteEntity(self:GetItem())
        net.Broadcast()
    end
end

function SWEP:PickupItem(item)
    if CLIENT then return end

    if !item then
        local trace = self:MakeTrace()
        if !trace.Entity:IsValid() then
            return
        end
        item = trace.Entity
    end

    
    --[[
    if item:IsPlayerHolding() then return end

    local can = hook.Run("HandCanPickup", self:GetOwner(), self, item)

    if can == false then
        return
    end

    item:MoveItemInContainer(self)

    self:SetItem(item)
    self:UpdateCSModels()
    print("Ent pickip", item)
    --]]
    return true
end

local punch_force = 100
function SWEP:Punch()
    local own = self:GetOwner()
	own:SetAnimation( PLAYER_ATTACK1 )

    self:EmitSound(SwingSound)

    if CLIENT then return end

    timer.Simple(0.2, function()
        if !IsValid(self) then return end

        local trace = self:MakeTrace()
        if !trace.Hit then return end

        self:EmitSound(HitSound)

        local ent = trace.Entity

        if IsValid(ent) then
            local part = HitGroupPart[trace.HitGroup]
            local dmg = DamageInfo()

            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)

            if math.random() < self.CritRand then // CRIT!
                dmg:SetDamage( math.random(self.MinDMG*2, self.MaxDMG*2) )
            else
                dmg:SetDamage( math.random(self.MinDMG, self.MaxDMG) ) 
            end

            if ent:IsPlayer() then
                ent:SetLastHitGroup(trace.HitGroup)
            end

            ent:TakeDamageInfo(dmg)

            if ent:IsPlayer() or ent:IsNPC() then
                ent:SetVelocity(trace.Normal * punch_force, trace.HitPos)
            else
                ent:GetPhysicsObject():AddVelocity(trace.Normal * punch_force)
            end
        end
    end)

    self:SetNextPrimaryFire(CurTime() + 0.8)
end

local block_time = 1
local block_cooldown = 0.1

function SWEP:Block()
    if CurTime() < self.BlockCD then return end

    self.StartB = CurTime()
    self.Blocking = true
    self.BlockCD    = CurTime() + block_time + block_cooldown

    self:SetHoldType("camera")

    timer.Simple(block_time, function() 
        if !self:IsValid() then return end
        self.Blocking = false
        self:SetHoldType("fist")
    end)
end

function SWEP:ItemPrimary()
    print("PRIMARY ACTION", self:GetItem())
    local ent = self:GetItem()
    if ent.ItemPrimary then
        ent:ItemPrimary(self, ply)
    end
end

function SWEP:ItemSecondary()
    print("SECONDARY ACTION", self:GetItem())
    local ent = self:GetItem()
    if ent.ItemSecondary then
        ent:ItemSecondary(self, ply)
    end
end

function SWEP:PrimaryAttack()
    if !IsFirstTimePredicted then return end
    if self:IsCombat() then
        self:Punch()
    elseif self:GetManipMode() then
        self:ManipPickupEnt()
    else
        if self:HaveItem() then
            self:ItemPrimary()
        //else
            //self:PickupItem()
        end
    end
end

function SWEP:ChangeManipulatemode()
    if self.ManipulateMode then 
        self:ManipModeReset()
    else
        self:SetManipMode(true)
    end
end

function SWEP:SecondaryAttack()
    if !IsFirstTimePredicted then return end
    if self:IsCombat() then
        self:Block()
    else
        if self:HaveItem() then
            
            
        end
    end 
end

function SWEP:CanThrow()
    // check if we can item to throw
    // проверка перед нажатием q 
    return true
end

function SWEP:ThrowItem(force)
    if !self:HaveItem() then
        GS_MSG("watafak, ply want to throw item, but dont have some! its s tracnge")
        return
    end

    local ent = self:GetItem()

    if SERVER then
        local start  = self:GetOwner():EyePos()
        local vector = self:GetOwner():GetAimVector()

        local trace = {
            start = start,
            endpos = start + vector * 25,
            filter =  function( ent ) return ( ent != self:GetOwner() ) end
        }
        
        trace = util.TraceEntityHull(trace, ent)
        ent:ItemRecover(trace.HitPos)

        local phys = ent:GetPhysicsObject()
        if phys then
            phys:SetVelocity(vector * 5 * force )
        end
    end

    self:SetItem(nil)
    self:UpdateHoldType()
    
    // owner, hand, ent, throw
    hook.Run("HandDropItem", self:GetOwner(), self, ent, true)
end


function SWEP:DropItem()
    if !self:HaveItem() then
        return
    end

    local ent = self:GetItem()

    if SERVER then
        local start  = self:GetOwner():EyePos()
        local vector = self:GetOwner():EyeAngles()
        
        local trace = {
            start = start,
            endpos = start + vector:Forward() * 100,
            filter =  function( ent ) return ( ent != self:GetOwner() ) end
        }
        
        trace = util.TraceEntityHull(trace, ent)
        
        //debugoverlay.Line( self:GetOwner():EyePos(), trace.HitPos)
        debugoverlay.Cross(trace.HitPos, 5)
        ent:ItemRecover(trace.HitPos )
    end

    self:SetItem(nil)
    self:UpdateHoldType()

    self:UpdateCSModels()
    
    hook.Run("HandDropItem", self:GetOwner(), self, ent)
end


//============================================//

if CLIENT then
    local DIR_ROLLA   = KEY_PAD_8
    local DIR_ROLLB   = KEY_PAD_2
    local DIR_YAWA    = KEY_PAD_4
    local DIR_YAWB    = KEY_PAD_6
    local DIR_PITCHA  = KEY_PAD_7
    local DIR_PITCHB  = KEY_PAD_1
    
    local DIR_CMD = {
        [DIR_ROLLA] = 1,
        [DIR_ROLLB] = 2,
        [DIR_YAWA] = 3,
        [DIR_YAWB] = 4,
        [DIR_PITCHA] = 5,
        [DIR_PITCHB] = 6,
    }
/*
    hook.Add("PostPlayerDraw", "GS_HandsDrawItem" , function(ply, flags)
        
        //need make this with parenting to bone
        
        if ply:Team() == TEAM_SPEC or ply:GetNWBool("Ragdolled") then return end

        local h1 = ply:GetWeapon( "gs_hand_l" )
        local h2 = ply:GetWeapon( "gs_hand_r" )

        local a = ply:GetActiveWeapon()

        if a != h1 and a != h2 then return end

        local h = {
            [h1] = ply:GetActiveWeapon() == h1,
            [h2] = ply:GetActiveWeapon() == h2
        }
        
        for hand, isActive in pairs(h) do
            if !hand:IsValid() then continue end

            local owner = hands:GetOwner()
            if !owner:IsValid() then return end
            local offsetVec = Vector(3, -3, -1)
            local offsetAng = Angle(0, 0, 180)
            
            local boneid = owner:LookupBone( "ValveBiped.Bip01_R_Hand" and isActive or "ValveBiped.Bip01_L_Hand" )
            if !boneid then return end

            local matrix = owner:GetBoneMatrix(boneid)
            if !matrix then return end

            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

            hand.iwm:SetPos(newPos)
            hand.iwm:SetAngles(newAng)
            hand.iwm:SetupBones()
            hand.iwm:DrawModel()
        end
    end)
    */
    /*
    function SWEP:CalcViewModelView(wep, vm, oldPos, oldAng, pos, ang )
        if self.Blocking then
            local time = CurTime() - self.StartB
            local up = 0 
            if time <= .2 then
                up = Lerp( time / 0.2 , 0, 10 )
            elseif time <= 0.8 then
                up = 10
            else
                time = time - 0.8
                up = 10 - Lerp( time / 0.2 , 0, 10 )
            end
            return pos, oldAng - Angle(0,0,up)
        end

        return pos, ang
    end
    */
/*
    hook.Add("PreDrawPlayerHands", "DrawHand", function( hands, vm, ply, weapon )
        if weapon:GetClass() != "gs_swep_hand" then return end
        return !weapon:GetNWBool("CombatMode")
    end)
*/ 
    local THROW_START   = 0
    local THROWING      = false

    function ButtonHandler(key, down)
        if DIR_CMD[key] then
            RunConsoleCommand(down and "gs_manipcontrol_down" or "gs_manipcontrol_up", DIR_CMD[key])
            return
        end

        if key == MOUSE_MIDDLE and down then
            RunConsoleCommand("gs_manipmode")
            return
        end

        if key == KEY_Q then
            if down and self:CanThrow() then
                THROWING = true
                THROW_START = CurTime()
            else
                THROWING = false
                local force = math.Clamp(CurTime() - THROW_START, 0, 10)
                RunConsoleCommand("gs_throw", force)
                self:SetItem(nil)
            end
        end
    end

    function SWEP:DrawHUD()
        // show current mode (fight/basik/manip)
        // if basik, show a name/desk of item / and show a eye trace ent name
        // show force bar when throwing

        if THROWING then
            // draw bar
            // 1-10 force
        end

        if self:IsCombat() then
            // show some red text curses of douchebag
        else
            if self:HaveItem() then
                // show name and desk
            end

            // eyetrace ent, show name
        end
    end
    
    
    
    hook.Add( "PlayerButtonDown", "CheckManipControlDown", function(ply, key)
        if ply:IsValid() and ply:Team() == TEAM_PLY then
            local wep = ply:GetActiveWeapon()
            if !IsValid(wep) then return end
            if wep:GetClass() == "gs_swep_hand" then ButtonHandler(key, down) end
        end
    end)
    
    hook.Add( "PlayerButtonUp", "CheckManipControlUp", function(ply, key)
        if ply:IsValid() and ply:Team() == TEAM_PLY then
            --print(ply, ply:Team(), TEAM_PLY, player_manager.GetPlayerClass(ply))
            local wep = ply:GetActiveWeapon()
            if !IsValid(wep) then return end
            if wep:GetClass() == "gs_swep_hand" then ButtonHandler(key, down) end
        end
    end)
end

