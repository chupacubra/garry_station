local function GetSpawnEntTable()
    local arr = {}
    for k, v in pairs(GS_EntityList) do
        if !v.Spawnable then continue end
        local cat = v.Category or "Other"
        arr[cat] = arr[cat] or {}

        table.insert(arr[cat], {
            model = v.Model or "models/props_junk/cardboard_box004a_gib01.mdl",
            class = k,
            name  = v.Name,
            desc  = v.Desc,
        })
    end

    //PrintTable(arr)
    return arr
end

spawnmenu.AddCreationTab( "Polar Entities", function(content)
    local main =  vgui.Create("DPanel")
    main:Dock(FILL)
    function main:Paint() end
    local grid = vgui.Create( "DGrid", main )
    grid:SetColWide( 105 )
    grid:SetRowHeight( 105 )

    for category, items in pairs(GetSpawnEntTable()) do
        //local label = vgui.Create("DLabel", main)
        //label:SetSize(500,100)
        //label:SetFont("DermaLarge")
        //label:SetText(category)
        
        //local pnl = vgui.Create("DPanel", main)
        //pnl:Dock(TOP)
        //function pnl:Paint() end

        for k, ent in pairs(items) do
            local icon = vgui.Create( "SpawnIcon" )
            icon:SetModel(ent.model)
            icon:SetSize( 100, 100 )
            icon:SetTooltip(ent.name .."\n".. ent.desc)
            grid:AddItem( icon )
        
            function icon:DoClick()
                net.Start("ps_spawn_ent")
                net.WriteString(ent.class)
                net.SendToServer()
            end
        end

        //pnl:SizeToChildren()
    end
    return main
end, "icon16/transmit.png", 200 )