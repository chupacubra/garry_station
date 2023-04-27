include("shared.lua")

SWEP.PrintName = "Hands" 
SWEP.HoldType = "normal"


function SWEP:Initialize()
    self.FightHand = false
    self.RCooldown = 0
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end


function SWEP:DrawHUD() 
    surface.SetFont( "TargetID" )
    surface.SetTextPos((ScrW() / 2)-50, (ScrH() / 2) + 100)
    surface.SetTextColor( 255, 255, 255 )
    surface.DrawText( "Click on item" )

    local trace = {
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + EyeAngles():Forward() * 150 ,
        filter =  function( ent ) return ( ent != LocalPlayer() ) end
    }
    
    trace = util.TraceLine(trace)
    if !trace.Entity:IsValid() then 
        return
    end
    
    e_class = trace.Entity:GetClass()
    
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
    print(self.IWorldModel:GetPos())
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
    if self.FightHand or self.itemModel then
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
--[[
function SWEP:SecondaryAttack()
    print("secondart")
    if self:HaveItem() == false and !self.FightHand then
        self:FightPlayerModel()
    elseif self.FightHand then
        self:FightPlayerModelStop()
    end
end

function SWEP:FightPlayerModel()
    if self.RCooldown > CurTime() then
        return 
    end
    self.FightHand = true
    self.RCooldown = CurTime() + 1
    print("Change to FIGHT")
end

function SWEP:FightPlayerModelStop()
    if self.RCooldown > CurTime() then
        return 
    end
    self.FightHand = false
    self.RCooldown = CurTime() + 1
    print("Change to NOFIGHT")
end
--]]
--[[
function SWEP:PrimaryAttack()
    if self.FightHand then
        print("BEATING")
        local VModel = self:GetOwner():GetViewModel()
        VModel:SendViewModelMatchingSequence( 4 )
    end
end
--]]
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

    elseif IsValid(self.IWorldModel) then

        self.IWorldModel:SetPos(self:GetPos())
        self.IWorldModel:SetAngles(self:GetAngles())
        self.IWorldModel:DrawModel()

    end

    print(self.IWorldModel)
end

function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
    if self.itemModel and self.FightHand == false then
        ViewModel:SetModel(self.itemModel or "")
    --elseif self.FightHand then
    --    ViewModel:SetModel(self.ViewModel)
    end

end

function SWEP:GetViewModelPosition(pos, ang)
    if self.itemModel then
	    pos,ang = LocalToWorld(Vector(30,-5,-10),Angle(0,180,0),pos,ang)
	elseif self.FightHand then
        pos,ang = LocalToWorld(Vector(0,0,0),Angle(0,0,0),pos,ang)
    end
	return pos, ang
end

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


    hands:WorldModelTriger(haveItem)
end)

net.Receive("gs_hand_vm", function()
    local bool = net.ReadBool()
    local hand = LocalPlayer():GetWeapon("gs_swep_hand")

    if !hand then
        return
    end

    hand.FightHand =  bool
end)