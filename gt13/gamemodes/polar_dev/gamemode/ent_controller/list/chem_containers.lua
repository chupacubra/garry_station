local ENT = {}

ENT.Base = "gs_chem_container"

ENT.Name  = "Bucket"
ENT.Desc  = "dear god..."
ENT.Model = "models/props_junk/metalbucket01a.mdl"
ENT.Size  = ITEM_MEDIUM

ENT.Spawnable = true
ENT.Category = "Developing"

ENT.RenderChem = true
ENT.RenderChem_Data = {
    height_min = -8.033,
    height_max = 8.033,
    rad_max = 8.153,
    rad_min = 6.534,
}

ENT.ChemContainerData = {
    Max = 100,
    Chems = {}
}

function ENT:ItemPrimary(hands, owner)
    local trace = owner:MakeViewTrace()
    local ent = trace.Entity

    if !IsValid(ent) then return end

    // pour
    if ent.ItemInteraction then
        ent:ItemInteraction(self)
    end    
end

AddEntItem(ENT, "chem_bucket")

ENT = {}

ENT.Base = "gs_chem_container"

ENT.Name  = "Magic bucket"
ENT.Desc  = "dear god..."
ENT.Model = "models/props_junk/metalbucket01a.mdl"
ENT.Size  = ITEM_MEDIUM
ENT.Color = Color(0,255,255)


ENT.Spawnable = true
ENT.Category = "Developing"

ENT.RenderChem = false

ENT.ChemContainerData = {
    Max = 100,
    Chems = {}
}

ENT.NetCommands = {
    ["SetChemical"] = {
        {id = "id", typ = "string"}
    }
}

local function OpenChemDerma(cont)
    // лист кнопок 
    local frame = vgui.Create( "DFrame" )
    frame:SetPos( 500, 500 )
    frame:SetSize( 200, 300 )
    frame:SetTitle( "Frame" )
    frame:MakePopup()

    local scroll = vgui.Create( "DScrollPanel", frame )
    scroll:Dock( FILL )

    for chem, chem_data in pairs(CHEMICALS) do
        local button = scroll:Add( "DButton" )
        button:SetText( chem_data.normalName )
        button:Dock( TOP )
        button:DockMargin( 0, 0, 0, 5 )
        button.chem_id = chem
        
        function button:DoClick()
            LocalPlayer():ChatPrint("You choose "..chem_data.normalName)
            cont:SetChemical(chem_id)
            frame:Close()
        end
    end
end

function ENT:PreInit()
    //self:SetNW2String("Chemical", "")
end

function ENT:SetChemical(id)
    if SERVER then
        self.Chemical = id
    else
        self:RunNetCommand("SetChemical", id)
    end
end

function ENT:ItemSecondary(hands, owner)
    if SERVER then return end
    OpenChemDerma(self)
end


// код гавна непроглядного
// надо что-то придумать с нв трансфером
function ENT:ItemPrimary(hands, owner)
    local trace = owner:MakeViewTrace()
    local ent = trace.Entity

    if !IsValid(ent) then return end
    
    if self.Chemical != "" then
        ent:AddUnit(self.Chemical, self:GetNW2Int("Transfer"))
    end
end