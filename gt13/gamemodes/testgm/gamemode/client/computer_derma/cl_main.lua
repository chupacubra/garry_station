local comps_frame = {}

CURRENT_COMP = {entity = Entity(-1), board = "", panel = false}

function NewCompPanel(name, func, upd_func)
    comps_frame[name] = {gen = func, upd = upd_func}
end

function CompPanel(name, parent)
    local gen_panel = comps_frame[name]["gen"]

    return gen_panel(parent)
end

NewCompPanel("board_cargo_order", function(parent)
    local money = 2500
    local sheet = vgui.Create("DPropertySheet", parent, "category_list")
    sheet:Dock(FILL)

    local p_orderRequest = vgui.Create("DPanel")
    p_orderRequest:Dock(FILL)

    local money_count = vgui.Create("DLabel", p_orderRequest, "money_label")
    money_count:Dock(TOP)
    money_count:DockMargin(10, 20, 0, 20)
    money_count:SetColor(Color(0,0,0))
    money_count:SetText("Current money: $"..string.Comma( money, ".") )
    local listRequest = vgui.Create("DListView", p_orderRequest, "list_order")

    listRequest:Dock(FILL)
    listRequest:SetMultiSelect( false )
    listRequest:AddColumn( "Item Identifier (ID)" )
    listRequest:AddColumn( "Status" )
    listRequest.ListId = {}

    SendCompCommand("get_list_orders")

    --local p_orderList = vgui.Create("DPanel")
    --p_orderList:Dock(FILL)

    sheet:AddSheet("Delivery status", p_orderRequest, "icon16/tick.png")
    
    for kategory, orders in pairs(Cargo_order_list) do
        local list = vgui.Create("DListView", sheet)
        list:Dock(FILL)
        list:SetMultiSelect( false )
        list:AddColumn( "Name" )
        list:AddColumn( "Item Identifier (ID)" )
        list:AddColumn( "Cost ($)" )
        list.ListId = {}
    
        function list:DoDoubleClick( lineID, line )
            local menu = DermaMenu(line)

            menu:AddOption( "Order", function()
                local id_item = tonumber(line:GetColumnText(2))
                SendCompCommand("order_id", {id_item})
            end)
            
            menu:AddOption( "Order several", function()
                Derma_StringRequest( "Specify the quantity of the item", "", "1",
                    function (num)
                        local id_item = tonumber(line:GetColumnText(2))
                        SendCompCommand("order_id",{id_item,tonumber(num)})
                    end,
                    nil,
                    "OK",
                    "Cancel"
                )
            end )

            menu:AddSpacer()
            menu:AddOption( "View content" )
    
            menu:Open()
        end

        for name, data in pairs(orders) do
            list:AddLine(data.name, data.id, data.cost)
        end

        sheet:AddSheet(kategory, list)
    end


    return sheet
end, {
    list_order = function(arg)
        local list = CURRENT_COMP.panel:Find("list_order")

        --[[
            here update the list
        ]]
    end
})

function OpenCompFrame(ent, typ)
    local frame = vgui.Create("DFrame")
    frame:SetSkin( "GMod98" )
    frame:SetSize(600, 600)
    frame:Center()
    frame:SetTitle("Computer")
    frame:MakePopup()

    CURRENT_COMP = {entity = ent, board = typ, panel = frame}

    local panel = CompPanel(typ, frame)

    function frame:OnClose()
        SendCompCommand("cls")
        CURRENT_COMP = {entity = Entity(-1), board = "", panel = false}
    end
end


function SendCompCommand(cmd, arg)
    --if !CURRENT_COMP.entity:IsValid() then
    --    return
    --end

    net.Start("gs_ent_comp_client_send_command")
    net.WriteEntity(CURRENT_COMP.entity)
    net.WriteString(cmd)
    net.WriteTable(arg or {})
    net.SendToServer()
end

function GetCompData()
    local ent = net.ReadEntity()
    local id  = net.ReadString()
    local arg = net.ReadTable()

    if CURRENT_COMP.entity != ent or !ent:IsValid() then
        GS_MSG("WTF? client watafak? why you receive data not for you! comp data")
        return
    end

    local func = comps_frame[CURRENT_COMP.board]["upd"][id]
    func(arg)
    
end

concommand.Add("gs_comp", function()
    OpenCompFrame(nil, "cargo_order")
end)

net.Receive("gs_ent_comp_client_get_data", GetCompData)