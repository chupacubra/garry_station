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
end

function SWEP:PrimaryAttack()
    if self:GetNWBool("FightHand") then
        if self.RCooldown > CurTime() then
            return
        end

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

    local trace = LocalPlayer():GetEyeTrace()

    if !trace.Entity:IsValid() or (LocalPlayer():EyePos() - trace.HitPos):Length() > 70 then 
        return
    end
    
    local e_class = trace.Entity:GetClass()
    
    if string.Left(e_class, 3) == "gs_"  then
        surface.SetTextPos(ScrW() / 2,ScrH() / 2) 
        surface.DrawText( trace.Entity.Entity_Data.Name )
    end
end 

function SWEP:WorldModelTriger(bool)
    print(bool)
    if bool then
        if self.itemModel and !IsValid(self.IWorldModel) then
            self.IWorldModel = ClientsideModel(self.itemModel)
            self.IWorldModel:SetNoDraw( true )
            print(self.IWorldModel:GetPos())
        end
    else
        if IsValid(self.IWorldModel) then
            self.IWorldModel:Remove()
        end
    end
end

function SWEP:Deploy()
    self:SetHoldType("normal")
    self:WorldModelTriger(true)

    return true
end

function SWEP:Holster()
   self:WorldModelTriger(false)
   return true
end

function SWEP:ShouldDrawViewModel()
    if self:GetNWBool("FightHand") or self.itemModel then
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
    
    if !self.itemModel then
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

    PrintTable(options)
    return options
end

function SWEP:DrawWorldModel()
    local _Owner = self:GetOwner()

    if (IsValid(_Owner) and IsValid(self.IWorldModel)) then
        local offsetVec = Vector(3, -3, -1)
        local offsetAng = Angle(0, 0, 180)
        
        local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if !boneid then return end

        local matrix = _Owner:GetBoneMatrix(boneid)
        if !matrix then return end

        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

        self.IWorldModel:SetPos(newPos)
        self.IWorldModel:SetAngles(newAng)
        self.IWorldModel:SetupBones()
        self.IWorldModel:DrawModel()
    end

end

function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
    if self.itemModel and self:GetNWBool("FightHand") == false then
        ViewModel:SetModel(self.itemModel or "")
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    if self.itemModel then
	    pos,ang = LocalToWorld(Vector(30, -5, -10), Angle(0, 180, 0), pos, ang)
	end
	return pos, ang
end
--[[
function SWEP:Think()
    if !self:GetNWBool("ManipMode") then return end
    if self:GetOwner() != LocalPlayer() then return end -- dont know
    
    --if input.IsKeyDown(DIR_ROLLA) then

    -- check inputs
    --input.StartKeyTrapping()
    --print(input.CheckKeyTrapping())
    for key, id in pairs(DIR_CMD) do
        if input.IsKeyDown(key) then
            print("gs_manipcontrol", id)
            RunConsoleCommand("gs_manipcontrol", id)
        end
    end
end
--]]


net.Receive("gs_hand_draw_model",function()
    local hands = net.ReadEntity()
    local haveItem = net.ReadBool()
    local model = net.ReadString()
    local e_type = net.ReadUInt(5)

    if haveItem then
        hands.itemModel = model
        hands.Item_ENUM = e_type
        hands.WorldModel = model
    else
        hands.itemModel = nil
        hands.Item_ENUM = 0
        hands.WorldModel = ""
    end

    print(model)

    hands:WorldModelTriger(haveItem)
end)


hook.Add( "PlayerButtonDown", "CheckManipControl", function(ply, key_down)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end
            for key, id in pairs(DIR_CMD) do
                if key_down == key then
                    RunConsoleCommand("gs_manipcontrol_down", id)
                end
            end
        end
    end
end )

hook.Add( "PlayerButtonUp", "CheckManipControl", function(ply, key_down)
    if ply:IsValid() and ply:Team() == TEAM_PLY then
        if ply:GetActiveWeapon():GetClass() == "gs_swep_hand" then
            local wep = ply:GetActiveWeapon()
            if !wep:GetNWBool("ManipMode") then
                return
            end
            for key, id in pairs(DIR_CMD) do
                if key_down == key then
                    RunConsoleCommand("gs_manipcontrol_up", id)
                end
            end
        end
    end
end )
