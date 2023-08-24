ContextMenu = {}

local HUD_EQUEIP = {
    {
        "BELT",
        "KEYCARD",
        "PDA",
    },
    {
        "BACKPACK",
        "VEST",
        "GLOVES",
    },
    {
        "HEAD",
        "MASK",
        "EAR",
    },
}

local function DragAndDropItem(self, panels, bDoDrop, Command, x, y) -- cursed
    if bDoDrop then
        local receivr = self
        local drop     = panels[1]
        print(drop, receivr)
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

function ContextMenu:MakeContextSWEP(entity, x, y)

    --drop, use, examine, reload, sip, eat, and another shit
    if entity.GS_Hand then
        local option = {}
        local swepoptions = entity:ContextSlot()
        
        table.Add(option, swepoptions)
        local Menu = DermaMenu()
            
        Menu:SetPos(x,y)
    
        for k,v in pairs(option) do
            local button = Menu:AddOption(v.label)
            button:SetIcon(v.icon)
            button.DoClick = v.click
        end
        return
    end

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
    PrintTable(itemData)
    --1 make all actions in array
    --2 generate all "buttons"

    if !itemData.Name then
        return
    end
    
    local option = {}

    if itemData.Simple_Examine then  -- examine
        local button = {
            label = "Examine",
            icon  = "icon16/eye.png",
            click = function()
                LocalPlayer():ChatPrint("It's a "..itemData.Name)
                LocalPlayer():ChatPrint(itemData.Desc)
            end
        }
        table.insert(option, button)
    end
    --[[
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
--]]
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
        label = "Drop this",
        icon  = "icon16/arrow_down.png",
        click = function()
            GS_ClPlyStat:DropEntFromInventary(key, from)
        end
    }

    if from == CONTEXT_EQUIPMENT then
        local button = {
            label = "Take off",
            icon  = "icon16/add.png",
            click = function()
                GS_ClPlyStat:DeEquipItem(key)
            end
        }
        table.insert(option, button)
    end
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

function ContextMenu:OpenContainer(items)
    if self.containerOpen then
        ContextMenu:CloseContainer()
    end
    --(W / 3.5 ) + (110 * i), H - (H / 8) + ((LineRow)*) 
    local lines = #items
    local x, y = 0, - math.floor(lines / 6) + 1

    local H = ScrH()
    local W = ScrW()
    self.containerItems = {}
    local itemB = vgui.Create("gt_button")
    itemB:SetText( "Drop Item","Here" )
    itemB:SetSize( 90, 90 )
    itemB:SetPos((W / 3.5 ) + (110 * x), (H - ((H / 8) + ((y+1) * 100)))-200 )
    itemB.type = "container"
    itemB.key = 0

    itemB:Droppable("item_drop")
    itemB:Receiver( "item_drop", DragAndDropItem )
    
    table.insert(self.containerItems, itemB)
    table.insert(self.derma, itemB)
    
    for k,v in pairs(items) do
        local itemB = vgui.Create("gt_button")
        itemB:SetText( v.Name )
        itemB:SetSize( 90, 90 )
        itemB:SetPos((W / 3.5 ) + (110 * x), (H - ((H / 8) + (y * 100)))-200 )

        itemB.type = "c_item"
        itemB.key = k
        function itemB:DoClick()
            ContextMenu:MakeContextItem(k, v, CONTEXT_ITEM_IN_CONT, self:GetPos())
        end
        itemB:Droppable("item_drop")
        itemB:Receiver( "item_drop", DragAndDropItem )
        
        x = x + 1
        if x == 6 then
            x = 0
            y = y + 1
        end

        table.insert(self.containerItems, itemB)
        table.insert(self.derma, itemB)
    end

    self.containerOpen = true
end

function ContextMenu:CloseContainer()
    if self.containerOpen then
        for k,v in pairs(self.containerItems) do
            v:Remove()
        end
        self.containerOpen = false
    end
end

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

function ContextMenu:DrawBackpackButton()
    if self.derma == nil then
        return
    end 
    
    local H = ScrH()
    local W = ScrW()

    if self.derma["backpack_button"] then
        return
    end

    local context = self
    local button = vgui.Create("gt_button")

    button:SetText( "Open","backpack" ) 
    button:SetSize( 90, 90 )
    button:SetPos(W - 100, (H - (H / 8)))
    button.type = "backpack"
    button.key  = 0
    button:Receiver("item_drop", DragAndDropItem )

    function button:DoClick()
        if context.openback == false then
            context:RequestBackpack()
        else
            context:CloseBackpack()
        end
    end
    
    self.derma["backpack_button"] = button
end

function ContextMenu:ContextMenuOpen() 
    local H = ScrH()
    local W = ScrW()

    local context = self
    self.derma = {}
    self.openback = false

    if GS_ClPlyStat:HaveEquip("BACKPACK") then
        ContextMenu:DrawBackpackButton()
    end
    
    -- weapon slot button

    for k, v in pairs(ClGetWeaponsSlot(true, LocalPlayer())) do
        local weapb = vgui.Create("gt_button")
        weapb:SetColorB(Color(0,0,0,0))
        weapb:SetSize( 100, 100 )
        weapb:SetPos((W / 3.5 ) + (110 * k), H - (H / 8))
        weapb.ent = v
        weapb.type = "weap"

        if weapb.ent:GetClass() == "gs_swep_hand" then
            weapb.type = "hand"
        end

        function weapb:DoClick()
            context:MakeContextSWEP(v, self:GetPos())
        end

        weapb:Receiver( "item_drop", DragAndDropItem )
        weapb:Droppable("item_drop")

        self.derma["weapon_slot"..k] = weapb
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

        self.derma["pocket"..i] = pocket
    end

    --equipments
    self.derma_equip = {}
    local eq_i = 1

    for i = 1,3 do
        for k,v in pairs(HUD_EQUEIP[i]) do
            local slot = vgui.Create("gt_button")
            slot:SetSize(100,100)
            slot:SetPos(10 + (110 * (k-1)), (H - ((H / 8) + ((i-1) * 110))))
            slot.type = "equip"
            slot.key  = k

            if GS_ClPlyStat then
                if GS_ClPlyStat.init then
                    slot:SetText(v, GS_ClPlyStat:GetEquipName(v))
                end
            end
            
            slot:Receiver( "item_drop", DragAndDropItem )
            slot:Droppable("item_drop")
            
            function slot:DoClick()
                context:MakeContextItem(k, GS_ClPlyStat:GetEquipItem(v), CONTEXT_EQUIPMENT, self:GetPos())
            end

            self.derma_equip[v] = slot
            self.derma["equip_"..v] = slot            
            eq_i = eq_i + 1
        end
    end

    self.Open = true
end

function ContextMenu:UpdateEquipmentItem()
    if !self.Open then
        return
    end

    for k,v in pairs(self.derma_equip) do
        v:SetText(k, GS_ClPlyStat:GetEquipName(k))
    end

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

    if self.containerOpen then
        GS_ClPlyStat:ClientCloseContainer()
        self.containerOpen = false
    end

    self.openback = false
end

function GM:GUIMousePressed( mouse,vector )
    if !ContextMenu.Open then
        return
    end

    local trace = {
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() +  vector * 80 ,
        filter =  function( ent ) return ( ent != LocalPlayer() ) end
    }
    
    trace = util.TraceLine(trace)

    if trace.Entity != Entity(0) and trace.Entity:IsValid() then
        local scrpos = trace.HitPos:ToScreen()
        local Menu = DermaMenu()
        
        Menu:SetPos(scrpos.x,scrpos.y)
        local entity = trace.Entity
        local cntx = {}

        if entity.GetContextMenu then
            cntx = entity:GetContextMenu()
        else
            -- if getcontexmenu == nil:
            --     how about request for this entity context from server
            MapEntityGetContext(entity)
            return
        end


        if cntx != nil then
            for k,v in pairs(cntx) do
                local button = Menu:AddOption(v.label)
                button:SetIcon(v.icon)
                button.DoClick = v.click
            end
        end

    end

end
