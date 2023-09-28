include("shared.lua")

function ENT:Initialize()
    self.Materials = {
        metal = 0,
        glass = 0
    }
    self.OrderList = {}
end

function ENT:AddContextMenu()
    local opt = {}

    local button = {
        label = "Examine parts",
        icon  = "icon16/eye.png",
        click = function()
            net.Start("gs_ent_mc_exam_parts")
            net.WriteEntity(self)
            net.SendToServer()
        end
    }
    table.insert(opt, button)

    return opt
end

function ENT:OpenGUI()
    local frame = vgui.Create("DFrame")
    frame:SetSkin( "GMod98" )
    frame:SetSize(600, 600)
    frame:Center()
    frame:SetTitle("Fabricator")
    frame:MakePopup()

    local matPanel = vgui.Create("DPanel", frame)
    matPanel:SetSize(0, 100)
    matPanel:Dock(TOP)

    local matText = vgui.Create("RichText", matPanel)
    matText:Dock(FILL)
    matText:DockMargin( 4, 4, 0, 0 )

    matText:AppendText("Materials:\n    Metal: "..tostring(self.Materials.metal).." un\n    Glass: "..tostring(self.Materials.glass).." un")

    local sheetList = vgui.Create("DPropertySheet",frame)
    sheetList:Dock(TOP)

    for id, cat in pairs(FABRICATOR_RECEIPTS) do
        local list = vgui.Create("DListView")
        sheetList:AddSheet(cat.name, list)
        list:Dock(FILL)
        list:SetMultiSelect( false )
        list:AddColumn( "Name" )
        list:AddColumn( "Metal" )
        list:AddColumn( "Glass" )
        list:AddColumn( "Time" )
        list.ListId = {}

        for item_id, item in pairs(cat.items) do
            local ent = scripted_ents.Get(item.id) -- bad but ok
            --local ent_name = ent.Entity_Data.Name  -- because whe request ALL data for entity for 1 value

            local time = tblsum(item.craft) / 20

            list:AddLine(ent.Entity_Data.Name , item.craft.metal, item.craft.glass, time )
        end
    end
    -- another list with order list item 
    local orderlist = vgui.Create("DListView", frame)
    orderlist:Dock(BOTTOM)

    function frame:Think()
        matText:SetText("")
        matText:AppendText("Materials:\n    Metal: "..tostring(self.Materials.metal).." un\n    Glass: "..tostring(self.Materials.glass).." un")
    end
end

function ENT:UpdateData(orders, metal, glass)
    self.Materials.metal = metal
    self.Materials.glass = glass

    self.OrderList = {}

    for k, v in pairs(orders) do
        local ent = scripted_ents.Get(v)
        table.insert(self.OrderList, ent.Entity_Data.Name)
    end
end

function ENT:Use()
    -- GUI for autolats
end

net.Receive("gs_fabricator_update", function()
    local ent    = net.ReadEntity()
    local orders = string.Explode(".", net.ReadString())
    local metal  = net.ReadUInt(16)
    local glass  = net.ReadUInt(16)

    ent:UpdateData(orders, metal, glass)
end)