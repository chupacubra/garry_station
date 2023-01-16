include("shared.lua")

SWEP.PrintName = "Hands"
SWEP.HoldType = "normal"

function SWEP:DrawHUD()
    surface.SetFont( "TargetID" )
    surface.SetTextPos((ScrW() / 2)-25, (ScrH() / 2) + 50)
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
    if bool then
        if self.itemModel and !IsValid(self.IWorldModel) then
            self.IWorldModel = ClientsideModel(self.itemModel)
            self.IWorldModel:SetNoDraw( true )
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
    if self.ViewModel != nil then
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

function SWEP:GetContextMenu()
    local options = {}
    
    if self.ViewModel then -- HAVE item
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
        
    end
    
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

end


net.Receive("gs_hand_draw_model",function()
    local hands = net.ReadEntity()
    local haveItem = net.ReadBool()
    local model = net.ReadString()


    if haveItem then
        hands.itemModel = model
        hands.ViewModel = model
    else
        hands.itemModel = nil
        hands.ViewModel = nil
    end
    hands:WorldModelTriger(haveItem)
end)

function SWEP:CalcViewModelView(ViewModel, OldEyePos, OldEyeAng, EyePos, EyeAng)
    if self.ViewModel then
        ViewModel:SetModel(self.ViewModel or "")
    end
end

function SWEP:GetViewModelPosition( pos , ang)
	pos,ang = LocalToWorld(Vector(30,-5,-10),Angle(0,180,0),pos,ang)
	
	return pos, ang
end
