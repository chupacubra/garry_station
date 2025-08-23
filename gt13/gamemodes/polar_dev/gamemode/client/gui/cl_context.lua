ContextMenu = ContextMenu or {}
ContextMenu.ShowEquipOpen = ContextMenu.ShowEquipOpen or false
ContextMenu.OpenedContainer = {}
ContextMenu.RequestedContainer = {}

ContextMenu.EquipButtons = {}
ContextMenu.PocketButtons = {}
//ContextMenu.EquipButtons = {}
ContextMenu.HandButtons = {}
ContextMenu.NextThink = 0
local DIR_UP = 0
local DIR_LEFT = 1

local BUTTON_SIZE = 150

local function ButtonContainerClose()
    for k, v in pairs(ContextMenu.OpenedContainer.items) do
        v:Close() 
    end
    
    ContextMenu.OpenedContainer = {}
end

local function ButtonContainerOpen(ent, tbl, btn)
    //if !table.IsEmpty(ContextMenu.OpenedContainer) then
    //    if ContextMenu.OpenedContainer.ent
    //    ButtonContainerClose()
        //return
    //end

    local w, h = ScrW(), ScrH()
    local btn_x, btn_y = 0, 0
    local btn = ContextMenu.RequestedContainer[ent] or btn
    local dir = DIR_LEFT

    ContextMenu.OpenedContainer = {
        btn = btn,
        ent = btn.item
    }

    if !IsValid(btn) then
        btn_x, btn_y = w/2, h/2
    else
        btn_x, btn_y = btn:GetPos()
        dir = btn.OpenDir
    end

    local i = 1

    local items = {}

    for k, item in pairs(tbl) do
        local x, y = btn_x, btn_y
        if dir == DIR_UP then
            y = y-(BUTTON_SIZE + 10) * i-1
        elseif dir == DIR_LEFT then
            x = x + (BUTTON_SIZE + 10) * i-1
        end

        local bitem = vgui.Create("GUIButton")
        bitem:SetSize(BUTTON_SIZE,BUTTON_SIZE)
        bitem:SetPos(x, y)
        bitem:MakePopup()
        bitem:SetText(item.Name or "nil name")

        if item.GetContextButtons then 
            local menu = item:GetContextButtons()
            if menu then bitem:SetContextMenu(menu) end
        end

        bitem.BtnContainer = btn
        bitem.cont = btn.item
        bitem.type = CONTEXT_CONTAINER_ITEM
        bitem.id = k
        bitem.item = item

        table.insert(ContextMenu.Items, bitem)
        table.insert(items, bitem)
        i = i + 1
    end
    ContextMenu.OpenedContainer.items = items
    ContextMenu.RequestedContainer[ent] = nil
end

local function ContextMenuUpdateContainer(ent, tbl)
    for k, v in pairs(ContextMenu.OpenedContainer.items) do
        v:Close() 
    end

    ButtonContainerOpen(ent, tbl)
end

local function ContextMenuEquipUpdated()
    if !ContextMenu.Open then return end
    if table.IsEmpty(ContextMenu.EquipButtons) then return end
    
    for typ, btn in pairs(ContextMenu.EquipButtons) do
        if !IsValid(btn) then continue end
        local item = LocalPlayer().Equipment[typ]
        local name = string.NiceName(string.lower(typ))

        if IsValid(item) then
            name = item.Name
        end

        btn.item = item
        btn.id = typ
        
        btn:SetText(name)

        if IsValid(item) then
            local menu = item:GetContextButtons()
            if menu then btn:SetContextMenu(menu) end
        end
    end
end

function ContextMenuRequestContainer(btn, ent)
    ContextMenu.RequestedContainer[ent] = btn
end

function ContextMenuSendCloseCont(ent)
    ent:CloseContainer()
end

local function ClearContextMenu()
    //PrintTable(ContextMenu.OpenedContainer)
    if !table.IsEmpty(ContextMenu.OpenedContainer) then
        ContextMenuSendCloseCont(ContextMenu.OpenedContainer.ent)
    end

    for k, v in pairs(ContextMenu.Items) do
        if v.Close then
            v:Close()
        else
            v:Remove()
        end
    end
    ContextMenu.ScanPanel:Remove()

    ContextMenu.OpenedContainer = {}
    ContextMenu.EquipButtons = {}
    ContextMenu.PocketButtons = {}
    ContextMenu.HandButtons = {}

    ContextMenu.Open = false
end

local function MakeButtonsPocket()
    local w, h = ScrW(), ScrH()

    for i = 1, 2 do
        local name = "Pocket"
        local item = LocalPlayer().Pocket[i]
        
        if IsValid(item) then
            name = item.Name
        end


        local x = (155) * math.cos( math.pi * i ) + (1-i) * (145)
        local bpocket = vgui.Create("GUIButton")
        bpocket:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        bpocket:SetPos(w/2 + x + 600, h - 160)
        bpocket:MakePopup()
        bpocket:SetText(name)

        bpocket.cont = LocalPlayer()
        bpocket.item = item
        bpocket.type = CONTEXT_POCKET
        bpocket.id = i

        table.insert(ContextMenu.Items, bpocket)
        table.insert(ContextMenu.PocketButtons, bpocket)
    end
end

local function ContextMenuPocketsUpdate()
    for i = 1, 2 do
        local name = "Pocket"
        local item = LocalPlayer().Pocket[i]
        
        if IsValid(item) then
            name = item.Name
        end

        local bpocket = ContextMenu.PocketButtons[i]
        bpocket:SetText(name)

        bpocket.cont = LocalPlayer()
        bpocket.item = item
        bpocket.type = CONTEXT_POCKET
        bpocket.id = i
    end
end

local KeyBelt = {
    "KEYCARD", "BELT"
}

local function MakeButtonsKeyBelt()
    local w, h = ScrW(), ScrH()

    local i = 1
    for k, v in ipairs(KeyBelt) do
        local name = string.NiceName(string.lower(v))
        local item = LocalPlayer().Equipment[EQUIP_NAMES_REV[v]]

        if IsValid(item) then
            name = item.Name
        end
        
        local x = (155) * math.cos( math.pi * i ) + (1-i) * (145) // нет причин использовать эту формулу. она нужна только для рук
        local bkb = vgui.Create("GUIButton")
        bkb:SetSize(BUTTON_SIZE,BUTTON_SIZE)
        bkb:SetPos(w/2 + x - 600, h - 160)
        bkb:MakePopup()
        bkb:SetText(name)

        
        bkb.cont = nil
        bkb.type = CONTEXT_EQUIP
        bkb.id = EQUIP_NAMES_REV[name]
        bkb.item = item

        bkb.OpenDir = DIR_UP

        if item then
            local menu = item:GetContextButtons()
            if menu then bhand:SetContextMenu(menu) end
        end

        table.insert(ContextMenu.Items, bkb)
        i = i + 1
    end
end

local function MakeButtonsHands()
    local w, h = ScrW(), ScrH()

    local activeWep = LocalPlayer():GetActiveWeapon()
    local weps = LocalPlayer():GetWeapons()

    for i = 1, 2 do
        local item
        local swep = weps[i]
        local name = swep.Name or swep.PrintName

        local x = (155) * math.cos( math.pi * i ) + (1-i) * (145)
        local bhand = vgui.Create("GUIButton")
        bhand:SetSize(BUTTON_SIZE,BUTTON_SIZE)
        bhand:SetPos(w/2 + x, h - 160)
        bhand:MakePopup()
        bhand:SetText(name)
        
        bhand.IsWepSelected = activeWep == swep

        if swep.IsHands then
            -- get item from hand
            item = swep:GetItem()
            if IsValid(item) then
                
                bhand:SetText(item.Name)
                local menu = item:GetContextButtons()
                if menu then bhand:SetContextMenu(menu) end
            end
        else
            item = swep
            local menu = swep:GetContextButtons()
            if menu then bhand:SetContextMenu(menu) end

        end
        if IsValid(item) then
            bhand:SetItem(item)
        end
        bhand.cont = nil
        bhand.item = item
        bhand.type = CONTEXT_SWEP
        bhand.id = i

        bhand.OpenDir = DIR_UP
        table.insert(ContextMenu.Items, bhand)
        table.insert(ContextMenu.HandButtons, bhand)
    end
end

function ContextMenuUpdateButtonsHands()
    local w, h = ScrW(), ScrH()

    local activeWep = LocalPlayer():GetActiveWeapon()
    local weps = LocalPlayer():GetWeapons()

    for i = 1, 2 do
        local item
        local swep = weps[i]
        local name = swep.Name or swep.PrintName

        local bhand = ContextMenu.HandButtons[i]
        bhand:SetText(name)
        
        bhand.IsWepSelected = activeWep == swep

        if swep.IsHands then
            item = swep:GetItem()
            if IsValid(item) then
                
                bhand:SetText(item.Name)
                local menu = item:GetContextButtons()
                if menu then bhand:SetContextMenu(menu) end
            end
        else
            item = swep
            if swep.GetContextButtons then
                local menu = swep:GetContextButtons()
                if menu then bhand:SetContextMenu(menu) end
            end
        end

        bhand.cont = nil
        bhand.item = item
        bhand.type = CONTEXT_SWEP
        bhand.id = i

        bhand.OpenDir = DIR_UP

    end
end


local EquipShowArr = {
    "BACKPACK",
    "VEST",
    "HEAD",
    "MASK",
    "EAR"  
}

local function MakeButtonsEquip()
    local w, h = ScrW(), ScrH()
    local ply = LocalPlayer()

    local bShowEquip = vgui.Create("GUIButton")
    bShowEquip:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    bShowEquip:SetPos(10, h - 160)
    bShowEquip:MakePopup()
    bShowEquip:SetText("Show equip")
    bShowEquip.Opened = false
    table.insert(ContextMenu.Items, bShowEquip)

    local function ShowEquip()

        for i, key in pairs(EquipShowArr) do
            local item = ply.Equipment[key]
            local name = string.NiceName(string.lower(key))
            if IsValid(item) then
                name = item.Name
            end

            local bEquip = vgui.Create("GUIButton")
            bEquip:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            bEquip:SetPos(-BUTTON_SIZE, (h - 160) - (BUTTON_SIZE + 10) * i)
            bEquip:MoveBy(160, 0, 0.2,0, 0.5)
            
            bEquip.cont = nil
            bEquip.item = item
            bEquip.type = CONTEXT_EQUIP
            bEquip.id = EQUIP_NAMES_REV[key]
            bEquip.OpenDir = DIR_LEFT

            bEquip:SetText(name)

            if IsValid(item) then
                local menu = item:GetContextButtons()
                if menu then bEquip:SetContextMenu(menu) end
            end

            table.insert(ContextMenu.Items, bEquip)

            ContextMenu.EquipButtons[key] = bEquip
        end

        bShowEquip.Opened = true
    end

    local function ClearEquip()
        for k, v in pairs(ContextMenu.EquipButtons) do
            v:Close()
        end
        ContextMenu.EquipButtons = {}
        bShowEquip.Opened = false
    end

    function bShowEquip:DoClick()
        if !bShowEquip.Opened then
            ShowEquip()
            ContextMenu.ShowEquipOpen = true
        else
            ClearEquip()
            ContextMenu.ShowEquipOpen = false
        end
    end

    if ContextMenu.ShowEquipOpen then
        ShowEquip()
    end
end

local function InitScannerPanel()
    // слишком сильно привязались DPropertySheet панелькам 
    // было хорошо бы если бы можно нарисовать напрямую саму панель

    local panel = vgui.Create("DPanel")
    panel:SetPaintedManually(true)

    function panel:GetActiveTab() return nil end
    function panel:Paint(w, h)
        derma.SkinHook( "Paint", "PropertySheet", self, w, h )
    end

    panel.Ent = nil
    panel.Draw = fasle
    ContextMenu.ScanPanel = panel
    
end

local function UpdateScannerPanelPos()
    local scanPanel = ContextMenu.ScanPanel
    if !scanPanel.Ent then return end
    
    local pos = scanPanel.Ent:WorldSpaceCenter():ToScreen()

    scanPanel:SetPos(pos.x - scanPanel:GetWide() / 2, pos.y - scanPanel:GetTall() / 2 )
end

local function UpdateScannerEnt(ent)
    local scanPanel = ContextMenu.ScanPanel

    if scanPanel.Ent == ent then return end

    if !IsValid(ent) then
        scanPanel:AlphaTo( 0, 0.2, nil, function() 
            scanPanel.Draw = false
        end)
    else
        scanPanel:SetAlpha(0)
        scanPanel:SetSize(150, 150)
        scanPanel:AlphaTo(200, 0.2)

        scanPanel.Draw = true
    end

    scanPanel.Ent = ent
    
    if IsValid(ent) then
        UpdateScannerPanelPos()
    end
end



local function OpenMenu()
    ContextMenu.Items = {}

    MakeButtonsHands()
    MakeButtonsEquip()
    MakeButtonsPocket()
    MakeButtonsKeyBelt()
    
    InitScannerPanel()
    ContextMenu.Open = true

end

function ContextMenuKey(open)
    gui.EnableScreenClicker(open)
    if open then
        OpenMenu()
    else
        ClearContextMenu()
    end
end

local cam_fov = 110

local function MakeScreenTrace(radius)
    local ply = LocalPlayer()
    local origin = EyePos()
    local dir = util.AimVector( EyeAngles(), cam_fov, gui.MouseX(), gui.MouseY(), ScrW(), ScrH() )

    return util.TraceLine({
        startpos = origin,
        endpos = origin + dir * radius,
        filter = ply,
    })
end

local THINK_CD = 0.1
// make trace for "scaning" ents and people - show his id or examine
local function ContextMenuThink()
    if !ContextMenu.Open then return end
    if ContextMenu.NextThink <= CurTime() then
        local ply = LocalPlayer()
        local tr = MakeScreenTrace(100)

        local target = tr.Entity

        if !IsValid(target) then target = nil end
        
        UpdateScannerEnt(target)

        ContextMenu.NextThink = ContextMenu.NextThink + THINK_CD
    end
end


hook.Add("Think", "ContextMenuThink", ContextMenuThink)

hook.Add("HUDPaint", "ScanPanelDraw", function()
    local scanPanel = ContextMenu.ScanPanel
    if !scanPanel then return end
    if !scanPanel.Draw then return end

    UpdateScannerPanelPos()
    scanPanel:PaintManual()

end)

hook.Add("ContextMenuEnabled", "block", function()
    return false
end)

hook.Add("OnContextMenuOpen", "GameContextMenu", function() ContextMenuKey(true) end)
hook.Add("OnContextMenuClose", "GameContextMenu", function() ContextMenuKey(false) end)

hook.Add("PlayerEquipUpdated", "ContextEquipUpdate", function(ply)
    if ply == LocalPlayer() and ContextMenu.Open then
        ContextMenuEquipUpdated()
    end
end)

hook.Add("UpdatePockets", "ContextPocketsUpdate", function()
    if ContextMenu.Open then
        ContextMenuPocketsUpdate()
    end
end)


net.Receive("gs_ent_container_open", function()
    local ent = net.ReadEntity()
    local items = net.ReadTable()

    print("try open container", ent, items)

    if !ContextMenu.Open then
        ent:CloseContainer()
        return
    end

    if ContextMenu.RequestedContainer[ent] then
        ButtonContainerOpen(ent, items)
    elseif ContextMenu.OpenedContainer.ent == ent then
        // update items in cointaner
    else
        // we have opened container and received container is not our?
        // close old, open new
        if !table.IsEmpty(ContextMenu.OpenedContainer) then
            ContextMenuSendCloseCont(ContextMenu.OpenedContainer.ent)
            ButtonContainerClose()
        end
    end
end)