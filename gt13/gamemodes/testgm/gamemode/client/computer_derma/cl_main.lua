local comps_frame = {}

--[[
    function(parent)
        create and parent to parent
    end
]]

function NewCompPanel(name, func)
    comps_frame[name] = func
end

function CompPanel(name, parent)
    local gen_panel = comps_frame[name]

    return gen_panel(parent)
end

NewCompPanel("cargo_order", function(parent)
    local sheet = vgui.Create("DPropertySheet", parent)
    sheet:Dock(FILL)

    local test = vgui.Create("DListView", sheet)
    test:Dock(FILL)
    test:SetMultiSelect( false )
    test:AddColumn( "Name" )
    test:AddColumn( "Item Identifier (ID)" )
    test:AddColumn( "Cost ($)" )

    
    test:AddLine( "Pizza box", tostring( math.random(0, 1000)), "30" )
    test:AddLine( "Automobile 'Oka'", tostring( math.random(0, 1000)), "2500" )
    test:AddLine( "TV 'Media player'", tostring( math.random(0, 1000)),  "200")
    test:AddLine( "Civilian wear pack'", tostring( math.random(0, 1000)),  "120")

    function test:DoDoubleClick( lineID, line )
        local menu = DermaMenu(line)
        menu:AddOption( "Order")
        menu:AddOption( "Order several" )
        menu:AddSpacer()
        menu:AddOption( "View content" )
        menu:SetPos(input.GetCursorPos())
        menu:Open()
    end

    sheet:AddSheet("Delivery status", test, "icon16/tick.png")
    sheet:AddSheet("Other", test)
    sheet:AddSheet("Medical", test)
    sheet:AddSheet("Security", test)
    sheet:AddSheet("Engineering", test)
    sheet:AddSheet("Science", test)


    return sheet
end)



function OpenCompFrame(ent, typ)
    local frame = vgui.Create("DFrame")
    frame:SetSkin( "GMod98" )
    frame:SetSize(600, 600)
    frame:Center()
    frame:SetTitle("Computer")
    frame:MakePopup()

    local panel = CompPanel(typ, frame)
end

concommand.Add("gs_comp", function()
    OpenCompFrame(nil, "cargo_order")
end)

