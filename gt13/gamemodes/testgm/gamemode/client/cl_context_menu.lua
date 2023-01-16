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

        local swepoptions = entity:ContextSlot()
        
        table.Add(option, swepoptions)
    
    elseif entity.GS_Hand then

    end

    if !entity.GS_Hand then -- drop weapon
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

function ContextMenu:MakeContextItem(key, itemData,from, x, y)
    print(key,itemData,x,y,from)
    --1 make all actions in array
    --2 generate all "buttons"
    if !itemData.Name then
        return
    end
    
    local option = {}
    PrintTable(itemData)
    if itemData.Name and itemData.Desc then  -- examine
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                net.Start("gs_cl_inventary_examine_item")
                net.WriteUInt(from, 5)
                net.WriteUInt(key, 6)
                net.SendToServer()
            end
        }
        table.insert(option, button)
    end
    
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
                GS_ClPlyStat:UseWeaponFromInventary(key, from)
            end
        }
        table.insert(option, button)
    end

    local drop = {
        label = "Drop this s#!t",
        icon  = "icon16/arrow_down.png",
        click = function()
            GS_ClPlyStat:DropEntFromInventary(key, from)
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

local function DragAndDropItem(self, panels, bDoDrop, Command, x, y) -- cursed
    if bDoDrop then
        local receivr = self
        local drop     = panels[1]
        print(drop, receiver)
        local item1 = {
            receiver = true,
            item = receivr.ent or receivr.key,
            type = receivr.type,
        }

        local item2 = {
            receiver = false,
            item = drop.ent or drop.key,
            type = drop.type,
        }

        GS_ClPlyStat:SendActionToServer(item1,item2)
    end
end
--[[
function ContextMenu:InitPockets(items)
    
    for i = 1, 2 do
        local pocket = vgui.Create("gt_button")
        pocket:SetColorB(Color(0,0,0,0))
        pocket:SetSize( 100, 100 )
        pocket:SetPos((W / 1.5 ) + (110 * i), H - (H / 8))
        pocket.key = i
        pocket.type = "pocket"
        
        function pocket:DoClick()
            print("123")
            PrintTable(GS_ClPlyStat:GetItemFromPocket(i))
            ContextMenu:MakeContextItem(v, GS_ClPlyStat:GetItemFromPocket(i), self:GetPos())
        end

        pocket:Receiver( "item_drop", DragAndDropItem )
        pocket:Droppable("item_drop")

        table.insert(self.derma, pocket)
    end
    --self.open = true
end
--]]

function ContextMenu:OpenBackpack(items)
    print("open!")
    self.backpackItems = {}

    local i = 1
    local H = ScrH()
    local W = ScrW()

    for k,v in pairs(items) do
        local itemB = vgui.Create("gt_button")
        itemB:SetText( v.Name )
        itemB:SetSize( 90, 90 )
        itemB:SetPos(W - 100, (H - ((H / 8) + 110*i)))

        function itemB:DoClick()
            ContextMenu:MakeContextItem(k, v, CONTEXT_ITEM_IN_BACK, self:GetPos())
        end
        
        itemB.type = "item"
        itemB.key = k
        itemB:Droppable("item_drop")
        itemB:Receiver( "item_drop", DragAndDropItem )

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
        self.derma.button.type = "backpack"
        self.derma.button.key  = 0
        self.derma.button:Receiver("item_drop", DragAndDropItem )
        function self.derma.button:DoClick()
            if context.openback == false then
                context:RequestBackpack()
            else
                context:CloseBackpack()
            end
        end
    end
    
    -- weapon slot button

    for k, v in pairs(GS_ClPlyStat:GetWeaponsSlot(true)) do
        local weapb = vgui.Create("gt_button")
        weapb:SetColorB(Color(0,0,0,0))
        weapb:SetSize( 100, 100 )
        weapb:SetPos((W / 3.5 ) + (110 * k), H - (H / 8))
        weapb.ent = v
        weapb.type = "weap"
        function weapb:DoClick()
            context:MakeContextSWEP(v, self:GetPos())
        end

        weapb:Receiver( "item_drop", DragAndDropItem )
        weapb:Droppable("item_drop")

        table.insert(self.derma,weapb)
    end

    -- pocket button

    for i = 1, 2 do
        local pocket = vgui.Create("gt_button")
        pocket:SetColorB(Color(0,0,0,0))
        pocket:SetSize( 100, 100 )
        pocket:SetPos((W / 1.5 ) + (110 * i), H - (H / 8))
        pocket.key = i
        pocket.type = "pocket"
        function pocket:DoClick()
           context:MakeContextItem(i, GS_ClPlyStat:GetItemFromPocket(i), CONTEXT_POCKET, self:GetPos())
        end

        pocket:Receiver( "item_drop", DragAndDropItem )
        pocket:Droppable("item_drop")

        table.insert(self.derma,pocket)
    end


    self.Open = true
end

function ContextMenu:UpdateInventoryItems(items)
    if self.openback then
        self:CloseBackpack()
    end
    self:OpenBackpack(items)
end

function ContextMenu:ContextMenuClose()
    for k,v in pairs(self.derma) do
        v:Remove()
    end

    self.Open = false
end

function GM:GUIMousePressed( mouse,vector )

    if !ContextMenu.Open then
        return
    end
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

            if cntx != nil then
                for k,v in pairs(cntx) do
                    local button = Menu:AddOption(v.label)
                    button:SetIcon(v.icon)
                    button.DoClick = v.click
                end
            end

        end
end

--[[
function GM:GUIMouseReleased( mouse,vector )

end
--]]
