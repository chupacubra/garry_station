ContextMenu = {}


function ContextMenu:MakeContextSWEP(entity, x, y)
    if entity.GS_Hand then
        print("is hand")
        --potom
        return
    end
    --drop, use, examine, reload, sip, eat, and another shit

    local itemData = entity.Entity_Data
    local option = {}

    if itemData.Name and itemData.Desc then  -- examine
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                local exm = {itemData.Name, itemData.Desc}
                --[[
                if itemData.ENUM_Type == GS_ITEM_AMMOBOX then
                    if itemData.AmmoInBox != 0 then
                        table.insert(exm, "In box "..itemData.AmmoInBox.." bullets")
                    else
                        table.insert(exm, "Ammobox is empty")
                    end
                elseif itemData.ENUM_Type == GS_ITEM_CONTAINER then
                    --liquid container, show units
                end
                --]]
                for k,v in pairs(exm) do
                    if k == 1 then
                        v = "It is ".. v
                    end
                    LocalPlayer():ChatPrint(v)
                end
            end
        }
        table.insert(option, button)
    end

    if entity.IsGS_Weapon then
        local typeOfWeapon = entity.Entity_Data.ENUM_Subtype
        if typeOfWeapon == GS_W_PISTOL then
            local button = {
                label = "Eject magazine", -- if have
                icon  = "icon16/control_eject.png",
                click = function()
                    entity:StripMagazine()
                end,
            }
        elseif typeOfWeapon == GS_W_SHOTGUN then
            local button = {
                label = "Twist the shutter",
                icon  = "icon16/arrow_right.png",
                click = function()
                    entity:TwistShutter() -- shotgun chik shik or bolt action
                end,
            }
        end
        table.insert(option, button)
    end

    if true then --move to inventar swep
        local button = {
            label = "Move the backpack",
            icon  = "icon16/box.png",
            click = function()
                GS_ClPlyStat:MoveSWEPToBackpack(entity)
            end,
        }
        table.insert(option, button)
    end

    if true then -- drop weapon
        local button = {
            label = "Drop",
            icon  = "icon16/box.png",
            click = function()
                GS_ClPlyStat:DropSWEP(entity)
            end,
        }
        table.insert(option, button)
    end

    local Menu = DermaMenu()
            
    Menu:SetPos(x,y)

    for k,v in pairs(option) do
        local button = Menu:AddOption(v.label)
        button:SetIcon(v.icon)
        button.DoClick = v.click
    end

end

function ContextMenu:MakeContextItem(key, itemData, x,y)
    --1 make all actions in array
    --2 generate all "buttons"

    local option = {}
    if itemData.Name and itemData.Desc then  -- examine
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                local exm = {itemData.Name, itemData.Desc}
                if itemData.ENUM_Type == GS_ITEM_AMMOBOX then
                    if itemData.AmmoInBox != 0 then
                        table.insert(exm, "In box "..itemData.AmmoInBox.." bullets")
                    else
                        table.insert(exm, "Ammobox is empty")
                    end
                elseif itemData.ENUM_Type == GS_ITEM_CONTAINER then
                    --liquid container, show units
                end
                for k,v in pairs(exm) do
                    if k == 1 then
                        v = "It is ".. v
                    end
                    LocalPlayer():ChatPrint(v)
                end
            end
        }
        table.insert(option, button)
    end
    
    --[[
        ITEM BOX CANT BE OPEN IN INVENTAR!!!!!!!!
    ]]

    if itemData.ENUM_Type == GS_ITEM_BOX then
        local button = {
            label = "Open box",
            icon  = "icon16/box.png",
            click = function()
                -- request from server, show box "inventar"
            end
        }
        table.insert(option, button)
    end

    if itemData.ENUM_Type == GS_ITEM_WEAPON then
        local button = {
            label = "Use",
            icon  = "icon16/add.png",
            click = function()
                GS_ClPlyStat:UseWeaponFromInventary(key)
            end
        }
        table.insert(option, button)
    end

    local drop = {
        label = "Drop this s#!t",
        icon  = "icon16/arrow_down.png",
        click = function()
            GS_ClPlyStat:DropEntFromInventary(key)
        end
    }
    table.insert(option, drop)


    local Menu = DermaMenu()
            
    Menu:SetPos(x,y)

    for k,v in pairs(option) do
        local button = Menu:AddOption(v.label)
        button:SetIcon(v.icon)
        button.DoClick = v.click
    end

end

function ContextMenu:ShowBoxInventary(boxinven)

end

function ContextMenu:DragAndDropItem()
    --box items, ammo in magazine, liquid lit'
end

function ContextMenu:Draw()
    surface.SetDrawColor( 0, 0, 0, 128 )
	surface.DrawRect( 50, 50, 128, 128 )
end

function ContextMenu:OpenBackpack(items)
    print("open!")
    self.backpackItems = {}
    --local items = GS_ClPlyStat:GetItemsFromBackpack()
    local i = 1
    local H = ScrH()
    local W = ScrW()

    for k,v in pairs(items) do
        local itemB = vgui.Create("gt_button")
        itemB:SetText( v.Name )
        itemB:SetSize( 90, 90 )
        itemB:SetPos(W - 100, (H - ((H / 8) + 110*i)))

        function itemB:DoClick()
            ContextMenu:MakeContextItem(k, v, self:GetPos())
        end
        
        itemB.type = "item_button"
        local t = itemB:Droppable( v.Name )
        self.backpackItems[v] = {}
        self.backpackItems[v]["button"] = itemB 
        table.insert(self.derma,itemB)
        i = i + 1
    end
    PrintTable(self.backpackItems)

    self.openback = true
end

function ContextMenu:CloseBackpack()
    for k,v in pairs(self.backpackItems) do
        v.button:Remove()
    end

    self.openback = false
end


function ContextMenu:RequestBackpack()
    GS_ClPlyStat:RequestItemsFromBackpack()
end

function ContextMenu:ContextMenuOpen()
    local H = ScrH()
    local W = ScrW()
    local context = self
    self.derma = {}
    self.openback = false

    if GS_ClPlyStat.equipment.BACKPACK != 0 then
        self.derma.button = vgui.Create("gt_button")
        self.derma.button:SetText( "Open","backpack" ) 
        self.derma.button:SetSize( 90, 90 )
        self.derma.button:SetPos(W - 100, (H - (H / 8)))

        function self.derma.button:DoClick()
            if context.openback == false then
                context:RequestBackpack()
            else
                context:CloseBackpack()
            end
        end
    end
    
    self.wslot = {}

    for k, v in pairs(GS_ClPlyStat:GetWeaponsSlot(true)) do
        local weapb = vgui.Create("gt_button")
        weapb:SetColorB(Color(0,0,0,0))
        weapb:SetSize( 90, 90 )
        weapb:SetPos((W / 3.5 ) + (110 * k), H - (H / 8))

        function weapb:DoClick()
            context:MakeContextSWEP(v, self:GetPos())
        end
        
        table.insert(self.wslot,weapb)
    end
    --(W / 3.5 ) + (110 * i), H - (H / 8), 90, 90

    self.Open = true
end

function ContextMenu:UpdateInventoryItems(items)
    self:CloseBackpack()
    self:OpenBackpack(items)
end

function ContextMenu:ContextMenuClose()
    for k,v in pairs(self.derma) do
        v:Remove()
    end

    self.Open = false
end

function GM:GUIMousePressed( mouse,vector )

    if ContextMenu.Open then
        local trace = {
            start = LocalPlayer():EyePos(),
            endpos = LocalPlayer():EyePos() +  vector * 250 ,
            filter =  function( ent ) return ( ent != LocalPlayer() ) end
        }
        
        trace = util.TraceLine(trace)


        -- THE context menu for entities
        if trace.Entity != Entity(0) and trace.Entity:IsValid() then

            local scrpos = trace.HitPos:ToScreen()
            local Menu = DermaMenu()
            
            Menu:SetPos(scrpos.x,scrpos.y)
            local entity = trace.Entity
            local cntx = entity:GetContextMenu()
            --print(entity,#cntx)
            --PrintTable(cntx)
            if cntx != nil then
                for k,v in pairs(cntx) do
                    local button = Menu:AddOption(v.label)
                    button:SetIcon(v.icon)
                    button.DoClick = v.click
                end
            end
        end
    end
end

function GM:GUIMouseReleased( mouse,vector )
    print(mouse,vector)
end
