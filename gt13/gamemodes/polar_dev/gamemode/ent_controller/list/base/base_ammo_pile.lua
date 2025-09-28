local ENT = {}

ENT.Base = "gs_entity"

ENT.PrintName = "ammo pile"
ENT.Name  = "patronchiki"
ENT.Desc  = "zhri svinec"
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.Size  = ITEM_SMALL

ENT.Stackable   = true
ENT.MaxStack    = 20


ENT.Spawnable = false
ENT.Category = "Developing"

ENT.Calibr = "9mm"
ENT.AmmoPile = true

function ENT:PostInit() 
    self:SetStack(self.MaxStack)
end

AddEntItem(ENT, "base_ammopile")

function ENT:Examine(ply)
    self.BaseClass.Examine(self, ply)
    RichTextPrint("{255 255 255}Have "..tostring(self:GetStack()).." bullets left")
end

local function GenerateAmmoPile(mag_data)
    local ENT = {}

    ENT.Calibr = mag_data.Calibr
    ENT.Model = mag_data.Model

    ENT.Name = mag_data.Name
    ENT.Desc = mag_data.Desc
    ENT.MaxStack = mag_data.MaxStack

    ENT.PrintName = ENT.Name
    ENT.Spawnable = true

    AddEntItem(ENT, "ammopile_"..ENT.Calibr, "base_ammopile")
end

GenerateAmmoPile({
    Name = "Ammo 9MM",
    Desc = "Maslini",
    Model = "models/Items/357ammo.mdl",
    MaxStack = 40,

    Calibr = "9mm",
})
if SERVER then
    RegisterAmmo("9mm", {D_BRUTE = 15, D_STAMINA = 10})
end