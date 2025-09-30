local PANEL = {}

local function AllowDrop(receiver, drop)
    // exmpl - container, if cant put more items
    //if !IsValid(drop.item) then return false, "nothing" 
    if !drop:IsEnabled() then return false, "drop is disabled" end
    if receiver == drop then return false, "same box" end
    return true, ""
end

local function SendItemAction(itemRec, itemDrp)
    net.Start("gs_cl_contex_item_action")
    
    net.WriteEntity(itemRec.ent)
    net.WriteUInt(itemRec.type, 5)
    net.WriteUInt(itemRec.id, 5)

    net.WriteEntity(itemDrp.ent)
    net.WriteUInt(itemDrp.type, 5)
    net.WriteUInt(itemDrp.id, 5)

    net.SendToServer()
end

function PANEL:DragAndDrop(panels, dropped, Command, x, y)
    local drop  = panels[1]
    //local rec   = self
    local canDrop, reason = AllowDrop(self, drop)

    if AllowDrop(self, drop) then
        if dropped then
            local itemRec = {
                ent     = self.cont,
                type    = self.type,
                id      = self.id,
            }
            local itemDrp = {
                ent     = drop.cont,
                type    = drop.type,
                id      = drop.id,
            }

            PrintTable(itemRec)
            PrintTable(itemDrp)

            SendItemAction(itemRec, itemDrp)
        end
    else
        // some anim or text, red panels
    end
end

function PANEL:Init()
    self.Hovering = false

    self:SetTextColor( Color( 72, 72, 72))
    self:SetFont("GModToolSubtitle")
    
    if self.item then
        self:Droppable( "GUIButton" )
    end
    self:Receiver( "GUIButton", self.DragAndDrop)
    
    self:SetAlpha(0)
    self:SetEnabled(false)
    timer.Simple(0, function()
        if self.NoAnim then
            self:SetAlpha(220)
            self:SetEnabled(true)
        elseif self.item then
            self:SetAlpha(0)
            self:AlphaTo( 255, 0.2, 0, function() self:SetEnabled(true) end)
        else
            self:SetAlpha(0)
            self:SetEnabled(true)
            self:AlphaTo( 220, 0.2, 0, function() self:SetEnabled(true) end)
            self:SetMouseInputEnabled(true)
        end
    end)
end

/*
function PANEL:SetItem(item)
    self.item = item
    self:SetText(item:GetIName() or "N/A")
    self:SetTextColor(Color( 0, 0, 0))

end
*/
function PANEL:GetActiveTab()
    return nil
end

function PANEL:SetContextMenu(btns)
    self.ContextButtons = btns
end

function PANEL:DoRightClick()
    if !self.ContextButtons then return end

    local menu = DermaMenu()
    for k, v in pairs(self.ContextButtons) do
        if v.custom then
            //
            //
            //
            v.custom(self, menu)
        elseif !v.sub then
            local btn = menu:AddOption( v.name, function()
                v.func(self)
            end)
            btn:SetIcon( v.icon )
        else
            local subMenu, opt = menu:AddSubMenu(v.name)
            subMenu:SetIcon(v.icon)
            for kk, vv in pairs(v.sub) do
                local btn = subMenu:AddOption( v.name, function()
                    vv.func(self)
                end)
                btn:SetIcon( v.icon )
            end
        end
    end
    menu:Open()
end

function PANEL:Paint(w, h)
    derma.SkinHook( "Paint", "PropertySheet", self, w, h )
    if self.IsWepSelected then
        draw.RoundedBox( 4, 5, 5, w-10, h-10, Color( 255, 255, 255 ) )
    end
end

function PANEL:PaintOver( w, h ) end

function PANEL:SetItem(item, noContexMenu)
    if !IsValid(item) then 
            if IsValid(self.item) then
                self.item = nil 

                self:SetTextColor(Color( 0, 0, 0))
                
                if self.m_DragSlot then
                    self.m_DragSlot["GUIButton"] = nil // i dont see another way of stop being droppable
                end

                timer.Simple(0, function()
                    self:SetAlpha(220)
                end)

            end
        return
        
    end

    self.item = item
    
    self:SetText(item:GetIName() or "N/A")
    self:SetTextColor(Color( 0, 0, 0))
    self:Droppable( "GUIButton" )

    if !noContexMenu then
        if item.GetContextButtons then
            local menu = item:GetContextButtons()
            if menu then self:SetContextMenu(menu) end
        end
    end

    self:SetTooltipPanelOverride("GUITooltip")
    
    timer.Simple(0, function()
        self:SetAlpha(255)
    end)
    
end


function PANEL:ClearItem()
end

function PANEL:Think()
    local ply = LocalPlayer()
    if !self:IsEnabled() then return end
    if self:IsHovered() or self:IsChildHovered() then
        if !self.Hovering then
            self:AlphaTo(255, 0.1,0)
            self.Hovering = true
        end
        if ply:KeyPressed(IN_ATTACK) then
            self:DoClick()
        elseif ply:KeyPressed(IN_ATTACK2) then
            //self:DoClick()
        end
    else
        if self.Hovering then
            if IsValid(self.item) then
                //self:AlphaTo(220, 0.1,0)
                self:SetAlpha(255)
            else
                self:AlphaTo(220, 0.1,0)
            end
            self.Hovering = false
        end
    end
end

function PANEL:Close()
    if !self.DontAnim then
        self:AlphaTo(0,0.2, 0)
        timer.Simple(0.2, function() self:Remove() end )
    end
end

vgui.Register("GUIButton", PANEL, "DButton")