--[[
    cargo system

    order system with balance of money
    list with all orders is shared
]]

include("sh_cargo_list_order.lua")
AddCSLuaFile("sh_cargo_list_order.lua")

GS_Job:CreateDept("cargo",{
    name  = "Cargo",
    color = Color(212, 181, 40),
    b_access = 7, 
    b_items  = {
        equipment = {
            BACKPACK = {
                id = "simple_back",
                typ = "backpacks",
            },
            SUIT = {
                id = "suit_work",
                typ = "suit",
            },
        },
    },
    --b_suit   = "worker",
})

GS_Job:CreateJob("cargo_technician", {
    name = "Cargo Technician",
    dept = "cargo",
})


GS_Cargo = {}

local function GetItemFromCargoList(id)
    for k, v in pairs(Cargo_order_list) do
        for kk, vv in pairs(v) do
            if vv.id == id then
                return vv
            end
        end
    end
end

function GS_Cargo:Setup()
    self.OrderList = {}
    self.Timer = 0
    self.Status = 0
    self.ID_Iter = 1
    self.DeliveryStatus = false
    self.Money = math.random(30, 90) * 100 -- need remake this shit
    -- because i have idea making Bank account
    
    --self:SetupComputers()
end

--[[
function GS_Cargo:SetupComputers()
    self.Computers = {}
    -- get all comps with cargo board
end


function GS_Cargo:AddComputer(ent)
    self.Computers[ent:EntIndex()] = ent
end

function GS_Cargo:SubComputer(ent)
    self.Computers[ent:EntIndex()] = nil
end
--]]

function GS_Cargo:MakeOrder(id, amount, ply)    
    if self.DeliveryStatus then
        -- show client derma menu
        if ply:IsValid() then
            ShowNotify(ply, "Cargo", "You can't order things until the last delivery is over.")
        end
        return
    end
    
    local item = GetItemFromCargoList(id)

    if !item then
        return
    end

    local price = item.cost * amount

    if self.Money < price then
        --dont show notify because this action blocked in client
        return
    end

    self.Money = self.Money - price
    self.OrderList[self.ID_Iter] = {order = item, amount = amount}
    self.ID_Iter = self.ID_Iter + 1
end

function GS_Cargo:DeclineOrder(id)

end

function GS_Cargo:GetAllOrders()
    return self.OrderList
end

function GS_Cargo:Deliver()
    if self.DeliveryStatus then
        return false
    end

    if table.Count(self:GetAllApprovedOrders()) == 0 then
        return false
    end

    timer.Create("gs_cargo_delivery", 90, 1, function()
        --spawn entity in cargo zone
        self.DeliveryStatus = false
    end)
end


function GS_Cargo:OrderItem(id, amount, ply)
    -- find id
    if self.DeliveryStatus then
        -- show client derma menu
        if ply:IsValid() then
            ShowNotify(ply, "Cargo", "You can't order things until the last delivery is over.")
        end
        return
    end
end