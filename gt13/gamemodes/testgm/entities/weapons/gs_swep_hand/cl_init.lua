include("shared.lua")

SWEP.PrintName = "Hands" 
SWEP.HoldType = "normal"

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

function SWEP:Initialize()
    self.RCooldown = 0

    self:SetNWVarProxy("hands_model", function(_,_, old, new)
        if new == "" then
            if IsValid(self.IWorldModel) then
                self.IWorldModel:Remove()
                self.IWorldModel = nil
            end
        else
            local data = DeformatDataForCLHands(new)
            
            local model = data[1]
            local enum  = data[2]
            local color = data[3]

            if !model then return end

            if !IsValid(self.IWorldModel) then
                self.IWorldModel = ClientsideModel(model)
            end

            self.IWorldModel:SetModel(model)
            
            if color != "" and color != nil then
                self.IWorldModel:SetColor(hexTorgb(color))
            end

            self.Item_ENUM = enum
            self.WorldModel = model
        end
    end)
    
end

function SWEP:PrimaryAttack()
    if self:GetNWBool("FightHand") then
        if self.RCooldown > CurTime() then
            return
        end
        
        -- check this: if LocalPlayer() != self:GetOwner() because i think it
        self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

        self.RCooldown = CurTime() + 0.8
    end
end

function SWEP:SecondaryAttack()

end

function SWEP:DrawHUD() 
    surface.SetFont( "TargetID" )
    surface.SetTextPos((ScrW() / 2)-50, (ScrH() / 2) + 100)

    if self:GetNWBool("FightHand") then
        surface.SetTextColor( 255, 50, 50 )
        surface.DrawText( "PUNCH HIM!" )
    else
        surface.SetTextColor( 255, 255, 255 )
        surface.DrawText( "Click on item" )
    end

    if self:GetNWBool("ManipMode") then
        surface.SetTextPos((ScrW() / 2)-50, (ScrH() / 2) + 120)
        surface.SetTextColor( 50, 255, 50 )
        surface.DrawText( "Manipulate" )
    end
end 

function SWEP:Deploy()
    self:SetHoldType("normal")
    --self:WorldModelTriger(true)

    return true
end

function SWEP:Holster()
   --self:WorldModelTriger(false)
   return true
end

function SWEP:ShouldDrawViewModel()
    if self:GetNWBool("FightHand") or self.IWorldModel then
        return true
    end
    return false
end

function SWEP:MakeAction(id)
    --[[    
            1 = drop
            2 = examine
            ...
    --]]
    
    net.Start("gs_hand_item_make_action")
    net.WriteUInt(id,3)
    net.SendToServer()
end

function SWEP:Examine()
    self:MakeAction(2)
end

function SWEP:DropItem()
    self:MakeAction(1)
end

function SWEP:HaveItem()
    return self.itemModel != nil --bruh
end

function SWEP:ContextSlot()
    local options = {}
    
    if !self.IWorldModel then
        return
    end

    local button = {
        label = "Examine item in hand",
        icon  = "icon16/eye.png",
        click = function()
            self:Examine()
        end,
    }
    table.insert(options, button)

    local button = {
        label = "Drop item",
        icon  = "icon16/arrow_down.png",
        click = function()
            self:DropItem()
        end,
    }
    table.insert(options, button) 

    if self.Item_ENUM == GS_ITEM_CONTAINER then
        local button = {
            label = "Open container",
            icon  = "icon16/box.png",
            click = function()
                net.Start("gs_ent_container_open")
                net.WriteEntity(self)
                net.SendToServer()
            end,
        }
        table.insert(options, button) 
    end
    PrintTable(options)
    return options
end

function SWEP:DrawWorldModel()

end

function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
    if self.IWorldModel and self:GetNWBool("FightHand") == false then
        ViewModel:SetModel(self.IWorldModel:GetModel() or "")
        ViewModel:SetColor(self.IWorldModel:GetColor())
    else
        ViewModel:SetColor(Color(255,255,255))
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    if self.IWorldModel then
	    pos,ang = LocalToWorld(Vector(30, -5, -10), Angle(0, 180, 0), pos, ang)
	end
	return pos, ang
end

hook.Add( "PlayerButtonDown", "CheckManipControlDown", function(ply, key)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        local wep = ply:GetActiveWeapon()
        if !IsValid(wep) then return end
        if wep:GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end

            RunConsoleCommand("gs_manipcontrol_down", DIR_CMD[key])
        end
    end
end )

hook.Add( "PlayerButtonUp", "CheckManipControlUp", function(ply, key)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        print(ply, ply:Team(), TEAM_PLY, player_manager.GetPlayerClass(ply))
        local wep = ply:GetActiveWeapon()
        if !IsValid(wep) then return end
        if wep:GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end

            RunConsoleCommand("gs_manipcontrol_up", DIR_CMD[key])
        end
    end
end )


hook.Add("PostPlayerDraw", "GS_HandsDrawItem" , function(ply, flags)
    if ply:Team() == TEAM_SPEC or ply:GetNWBool("Ragdolled") then return end
    if ply:GetActiveWeapon():GetClass() != "gs_swep_hand" then return end
    local hands = ply:GetActiveWeapon()

    if IsValid(hands.IWorldModel) then
        local owner = hands:GetOwner()
        if !owner:IsValid() then return end
        local offsetVec = Vector(3, -3, -1)
        local offsetAng = Angle(0, 0, 180)
        
        local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if !boneid then return end

        local matrix = owner:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        hands.IWorldModel:SetPos(newPos)
        hands.IWorldModel:SetAngles(newAng)
        hands.IWorldModel:SetupBones()
        hands.IWorldModel:DrawModel()
    end
        

end)