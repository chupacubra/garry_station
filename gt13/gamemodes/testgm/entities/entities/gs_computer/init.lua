AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    if self.Entity_Data then
        self:SetModel(self.Entity_Data.Model or "models/props_junk/cardboard_box004a_gib01.mdl")
    else
        self:SetModel(self:GetModel())
    end

    self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
    end
    
    self.Player = Entity(-1)
    self.HaveBoard = False
    self.Items = {}
    self.Work  = False
end

function ENT:Examine()
    local exam = {}

    table.insert(exam, "It is ".. self.Entity_Data.Name)
    table.insert(exam, self.Entity_Data.Desc)

    return exam
end

function ENT:OnReloaded()
    self:LoadInfoAbout()
end

function ENT:InsertPlate(item)
    self.Items[item.Entity_Data.ENT_Name] = item
    
    self.HaveBoard = item.Entity_Data.ENT_Name
    return nil
end

function ENT:RemoveItem(id)

end

function ENT:InsertItem(ply, item)
    if self.HaveBoard == false and item.Entity_Data.ENUM_Type == GS_ITEM_BOARD and item.Entity_Data.ENUM_Subtype  == GS_BOARD_COMPUTER then
        self:InsertPlate(item)
        return
    elseif self.Work then
        -- work with id, disk?
        -- the board set ID of inserted item
    end
end

function ENT:Crowbar(ply)
    -- ex if build and maint open --> uncraft machine

    if self.Work and self:GetFlagState(KS_MAINTANCE) then
        self:RemoveBoard()
    end
end

function ENT:Screwdriver(ply)
    if self.Work then
        if self:GetFlagState(KS_MAINTANCE) then
            self:SetFlagState(KS_MAINTANCE, false)
        else
            self:SetFlagState(KS_MAINTANCE, true)
        end
    else
        if self.HaveBoard then
            self:MakeComp()
        end
    end
end

function ENT:Use(ply)    
    if self.Work then
        if !self.Player:IsValid() then
            ply:ChatPrint("another guy is using is already")
        end

        net.Start("gs_comp_show_derma")
        net.WriteEntity(self)
        net.WriteString(board)
        net.Send(ply)

        self.Player = ply
    end
end

function ENT:BoardFunction(act, arg)
    local plate_func = GS_EntityList["pc_plate"][self.HaveBoard.Data_Labels.id]["Plate_functions"]
    
    local func = plate_func[act]
    
    if func then
        func(self.Player, self, arg)
    end
end

function ENT:ClientSendData(id, data)
    if !self.Player:IsValid() then
        return
    end

    net.Start("gs_ent_comp_client_get_data")
    net.WriteEntity(self)
    net.WriteString(id)
    net.WriteTable(data)
    net.Send(self.Player)
end

function ENT:ClientFunction(func, arg)
    -- ALL functions:
    -- buttons, request of data,
    -- client = self.Player
    -- cls - is function of closing derma
    if func == "cls" then
        self.Player = Entity(-1)
    else
        self:BoardFunction(func, arg)
    end
end

net.Receive("gs_ent_comp_client_send_command", function(_,ply)
    local ent = net.ReadEntity()
    local cmd = net.ReadString()
    local arg = net.ReadTable()

    if ent.Player == ply then
        ent:ClientFunction()
    end
end)