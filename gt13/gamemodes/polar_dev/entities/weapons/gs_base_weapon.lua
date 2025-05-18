//
//  the problems
//  из-за того что у нас нстандартная система патронов, магазинов, возможны проблемсы
//  с предиктишионом выстрела на клиенте. Есть варианты как сообщить сколько патронов у нас есть
//      При перезарядке отправлять на клиент сколько у нас патронов. Время во время перезарядки у нас хватит, чтобы понять сколько
//      у нас сейчас патронов
//
//  с заменой модели оружия на без магазина пока повременим
//  нужно побольше посмотреть на замену модели оружия в руках
//  с помощью нативных функций без создавания новой клиентсайд модели
//
//  кстати, упор идёт на first person view как на хомиграде
//
//  это база для магазиных ружей
//
//  нужно проверить клиентсайд модели парентить к костям ent:FollowBone

SWEP.Author			    = "Devil right hand"
SWEP.Contact			= "Poeli"
SWEP.Purpose			= "KILL!"
SWEP.Instructions		= "KILL!"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.Automatic      = false
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.Automatic    = false

SWEP.UseHands           = true
SWEP.m_bPlayPickupSound = false
SWEP.DrawAmmo           = false
SWEP.DrawCrosshair      = false
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false 

SWEP.Name = "Boomstick"
SWEP.Desc = "Palka-ubivalka"

SWEP.SoundShot   = ""
SWEP.SoundReload = ""
SWEP.Silenced    = false

SWEP.MuzzlePos      = nil
SWEP.ShellPos       = nil

SWEP.HoldType       = "pistol"  // basic holdtype

SWEP.NeedTwoHand    = false

SWEP.Recoil     = 10
SWEP.RecoilUp   = 15
SWEP.ShotSpeed  = 0.5
SWEP.ShotSpread = 0.5

SWEP.LastBullet = nil
SWEP.Active     = false
SWEP.Use2Hand   = false

SWEP.ViewModel  = ""
SWEP.WorldModel = ""

SWEP.WorldModelCustom     = false
SWEP.WorldModelBonemerge  = true
SWEP.WorldModelBodyGroups = {}
SWEP.WorldModelOffsets    = {
//    pos = Vector(),
//    vector = Angle(0,0,90)
}

--[[
bodygroups can chang in some situation
SWEP.WorldModelCustom   = true
SWEP.WorldModelBodygroups = {
    base   = {} // setup in init
    reload = {} // ply start reload proces
    reload_end   = {} // or you can set base
}
--]]

if SERVER then
    util.AddNetworkString("gs_swep_update_wm")
end

function SWEP:UpdateHoldType()
    local holdtype = self.HoldType

    if holdtype == "pistol" then
        if self.Zoom then holdtype = "revolver" end
    elseif holdtype == "shotgun" then
        if self.Zoom then holdtype = "ar2" end
    elseif holdtype == "ar2" or holdtype == "smg" then
        if self.Zoom then holdtype = "rpg" end
    end

   -- if self.NeedTwoHand and !HandsFree(self:GetOwner()) then
    --    holdtype = "passive"
    --end

    self:SetHoldType(holdtype)
end

function SWEP:GetWMOpt()
    // function, thats generating table of bg
end

function SWEP:UpdateWModelBodyGroups(toset)
    if SERVER then
        net.Start("gs_swep_update_wm")
        net.WriteEntity(self)
        net.WriteString(toset)
        net.Broadcast()
    else
        self:ChangeBodyGroup(toset)
    end
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    if CLIENT then
        self:InitializeWM()
    end
end

function SWEP:Deploy()
    self:UpdateHoldType()
    if CLIENT then
        self:UpdateWMState()
    end

    return true
end

function SWEP:Holster()
    if CLIENT then
        self:UpdateWMState(true)
    end
    return true
end

function SWEP:Equip()
    self:UpdateHoldType()
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    self.Zoom = !self.Zoom
    self:UpdateHoldType()
    if CLIENT then
        self:ChangeBodyGroup("base2")
    end
end

function SWEP:InitializeWM()
    print("Init cl wm", self, self.WorldModelCustom)
    if !self.WorldModelCustom then return end

    self.WMGun = ClientsideModel(self.WorldModel)
    print(self, self.WMGun, self.WorldModel)
    self:UpdateWMState()

    if self.WorldModelBodyGroups["base"] then
        self:ChangeBodyGroup("base")
    end
end


function SWEP:ChangeBodyGroup(bodygroups_set)
    print("Change bgs", bodygroups_set, self.WMGun)
    if SERVER then return end
    local gun = self.WMGun
    if !IsValid(gun) then return end
    if type(bodygroups_set) == "string" then
        bodygroups_set = self.WorldModelBodyGroups[bodygroups_set]
    end
    if !bodygroups_set then return end

    local bodygroups_data = gun:GetBodyGroups()
    if #bodygroups_data == 0 then return end
    
    for name_id, name_subid in pairs(bodygroups_set) do
        local bg_id = name_id
        if type(name_id) == "string" then
            bg_id = gun:FindBodygroupByName(name_id)
        end
        
        if bg_id == nil or bg_id == -1 then continue end
        local bg_subid = name_id
        
        if type(name_id) == "number" then 
            gun:SetBodygroup(bg_id, bg_subid)
        else
            for subid, subname in pairs(bodygroups_data[bg_id+1].submodels) do
                if subname == name_subid then
                    
                    gun:SetBodygroup(bg_id, subid)
                end
            end
        end

    end
end

function SWEP:DrawWorldModel()
    if !self.WorldModelCustom then self:DrawModel() end
end

function SWEP:UpdateWMState(holster)
    print("Update wm state",self.WMGun, holster)
    local gun = self.WMGun
    
    if !gun then return end
    local owner = self:GetOwner()
    if owner then
        // weapon in hands (active)
        // need to bonemerge to him

        if !holster then
            print("parent")
            //local offset_pos = self.WorldModel
            //gun:SetPos(owner:GetPos())
            //gun:SetParent(owner, owner:LookupBone("ValveBiped.Bip01_R_Hand"))
            
            gun:FollowBone(owner, owner:LookupBone("ValveBiped.Bip01_R_Hand"))
            gun:SetAngles(owner:LocalToWorldAngles(self.WorldModelOffsets.ang))
            gun:SetPos(owner:LocalToWorld(self.WorldModelOffsets.pos))
            //gun:SetParent(self)
            gun:SetNoDraw(false)
        else
            // i want delegate PlayerUpdateWorldModelsSWEP() draw wm
            gun:SetNoDraw(true)
        end
    else
        gun:SetParent(self)
        gun:SetNoDraw(false)
    end

    print(gun:GetPos(), owner:GetPos(), self:GetPos())

    debugoverlay.Cross( owner:GetPos() ,10, 5, Color(0,0,255), true)
    debugoverlay.Cross( self:GetPos() ,10, 5, Color(255,0,0), true)
    debugoverlay.Cross( gun:GetPos(), 10,  5, Color(0,255,0), true)

end

function SWEP:OnRemove()
    if IsValid(self.WMGun) then self.WMGun:Remove() end
end

net.Receive("gs_swep_update_wm", function(_, ply)
    local self = net.ReadEntity()
    local set  = net.ReadString()

    self:ChangeBodyGroup(set)
end)

local mdl = "models/kali/weapons/black_ops/pm-63 rak.mdl"

function PrintBones( entity )
    for i = 0, entity:GetBoneCount() - 1 do
        print( i, entity:GetBoneName( i ) )
    end
end

concommand.Add("getbg", function()
    local prop = ents.Create("prop_physics")
    prop:SetModel(mdl)
    prop:Spawn()
    
    PrintTable(prop:GetBodyGroups())
    PrintTable(prop:GetAttachments())
    //print(prop:FindBodygroupByName( "Stock" ))
    
    //SetBodyGroup(prop, bgs)

    PrintBones(prop)

    prop:Remove()
end)
