local ContextMenu = {}

local function ClearContextMenu()
    for k, v in pairs(ContextMenu.Items) do
        if v.Close then
            v:Close()
        else
            v:Remove()
        end
    end
end

function OpenMenu()
    ContextMenu.Items = {}
    local w, h = ScrW(), ScrH()

    local guip = vgui.Create("Panel")
    guip:Dock(FILL)
    guip:MakePopup()

    table.insert(ContextMenu.Items, guip)


    for i = 1, 2 do
        local x = (155) * math.cos( math.pi * i ) + (1-i) * (145)
        local frame = vgui.Create("GUIButton", guip)
        frame:SetSize(150,150)
        frame:SetPos(w/2 + x, h - 160) // lushe ruchkami koneshno

        --[[if i == 1 then
            local tab1panel = vgui.Create( "DPanel" )
            function tab1panel:Paint() end
            frame:AddSheet( "Left hand", tab1panel)
            frame:SetSize(150,170)
            frame:SetPos(w/2 + x, h - 180)
        end
        --]]


        table.insert(ContextMenu.Items, frame)
    end
    

end

function ContextMenuKey(open)
    gui.EnableScreenClicker(open)
    if open then
        //OpenMenu()
    else
        // close gui
        //ClearContextMenu()
        return
    end
end

hook.Add("OnContextMenuOpen", "GameContextMenu", function() ContextMenuKey(true) end)
hook.Add("OnContextMenuClose", "GameContextMenu", function() ContextMenuKey(false) end)
