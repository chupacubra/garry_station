--[[
    server side wires:
    {
        COLOR_1,
        COLOR_2,
        COLOR_3,
    }
]]

function OpenServiceWires(entity, wires)
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 440)
    frame:Center()
    frame:SetTitle("Wire")
    frame:MakePopup()

    local panel = vgui.Create( "DPanel", frame )
    panel:Dock(FILL)
    panel:DockPadding(10, 10, 0, 0)

    local layout = vgui.Create("DTileLayout", panel)
    layout:SetBaseSize(#wires*4)
    layout:Dock(TOP)

    layout:SetSpaceX(10)
    layout:SetSpaceY(25)

    for k, wire in pairs(wires) do
        local l_wire = vgui.Create( "DLabel" )
        l_wire:SetText(W_NAME[wire])
        l_wire:SetColor(W_COLOR[wire])

        layout:Add(l_wire)
        l_wire:Remove()

        local b_cut = vgui.Create("DButton")
        b_cut:SetText("cut")
        b_cut:SetSize(45, 25)
        b_cut.wire = wire
        function b_cut:DoClick()
            net.Start("gs_wire_action")
            net.WriteEntity(entity)
            net.WriteUInt(W_CUT, 2)
            net.WriteUInt(self.wire, 5)
            net.SendToServer()
        end

        layout:Add(b_cut)
        b_cut:Remove()

        local b_connect = vgui.Create("DButton") -- connect CUTTED WIRES
        b_connect:SetText("connect")
        b_connect:SetSize(45, 25)
        b_connect.wire = wire
        function b_connect:DoClick()
            net.Start("gs_wire_action")
            net.WriteEntity(entity)
            net.WriteUInt(W_CONNECT, 2)
            net.WriteUInt(self.wire, 5)
            net.SendToServer()
        end

        layout:Add(b_connect)
        b_connect:Remove()

        local b_pulse = vgui.Create("DButton")
        b_pulse:SetText("connect")
        b_pulse:SetSize(45, 25)
        b_pulse.wire = wire
        function b_pulse:DoClick()
            net.Start("gs_wire_action")
            net.WriteEntity(entity)
            net.WriteUInt(W_PULSE, 2)
            net.WriteUInt(self.wire, 4)
            net.SendToServer()
        end

        layout:Add(b_pulse)
        b_pulse:Remove()
    end
end

net.Receive("gs_ent_service_wires_open", function()
    local ent = net.ReadEntity()
    local wires = net.ReadTable()

    OpenServiceWires(ent, wires)
end)

concommand.Add("gs_wires", function()
    OpenServiceWires(Entity(-1), {1,2,3})
end)
