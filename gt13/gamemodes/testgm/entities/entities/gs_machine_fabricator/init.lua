AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.DissasembleData = {
    board = "fabricator"
}

function ENT:AfterInit()
    self.Materials = {metal = 0, glass = 0}
    self.OrderList = {}
    self.CreatedItems = {}
    self.CreatingItem = false

    timer.Create("gs_fabricator_"..self:EntIndex().."_client_update", 1, 0, function() self:StatusClientUpdate() end)
end

function ENT:Screwdriver(ply)
    -- open/close hatch
    local maint = self:FlipFlag(KS_MAINTANCE)
    --if maint then
    --    ply:ChatPrint("")
    --else
    --    ply:ChatPrint("")
    --end
end

function ENT:Crowbar(ply)
    -- if hatch opened:
    --     demontazh
    if self:GetFlagState(KS_MAINTANCE) then
        self:DissasembleMachine()
    end
end

function ENT:InsertItem(ply, item)
    -- the fabricator allow insert metal and glass
end

function ENT:StatusClientUpdate()
    -- we send big string order list
    -- cheaper then table
    local all = self:GetConnectedPly()

    if #all > 0 then
        for ply, _ in pairs(all) do
            net.Start("gs_fabricator_update")
            net.ReadEntity(self)
            net.WriteString(table.concat(self.OrderList, "."))
            net.WriteUInt(self.Materials.metal, 16)
            net.WriteUInt(self.Materials.glass, 16)
            net.Send(ply)
        end
    end
end

function ENT:InsertItemInOrderList(category, name)
    -- order will be placed in order list
    -- for waiting crafting another item
    -- if item first - CraftItem()

    table.insert(self.OrderList, {category, name})
    if #self.OrderList == 1 then
        self:CraftItem(category, name)
    end
end

function ENT:OrderListNext()
    table.remove(self.OrderList, 1)
    
    if #self.OrderList != 0 then
        self:CraftItem(self.OrderList[1][1], self.OrderList[1][2])
    end
    
end

function ENT:CraftItem(category, name)
    -- check can we create item
    local craft = FABRICATOR_RECEIPTS[category]["items"][name]["craft"]
    
    if self.Materials.metal - (craft.metal or 0) < 0 or self.Materials.glass - (craft.glass or 0) < 0 then
        -- cant create!
        return false
    end

    self.Materials.metal = self.Materials.metal  - (craft.metal or 0)
    self.Materials.glass = self.Materials.glass - (craft.glass or 0)

    local time = tblsum(item.craft) / 20

    timer.Simple(time, function()
        table.insert(self.CreatedItems, FABRICATOR_RECEIPTS[category]["items"][name]["id"])
        self:OrderListNext()
    end)

    return true
end

function ENT:Think()
    --local plys = self:GetConnectedPly()
    --if #plys == 0 then return end

    for ply, _ in pairs(self:GetConnectedPly()) do
        if !ply:IsValid() then continue end

        if self:GetPos():Distance( ply:GetPos() ) > 100 then
            self:PlyDisconnect(ply)
        end
    end
end