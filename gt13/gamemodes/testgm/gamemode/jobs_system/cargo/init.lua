--[[
    cargo system

    order system with balance of money
    list with all orders is shared
]]

include("sh_cargo_list_order.lua")
AddCSLuaFile("sh_cargo_list_order.lua")

GS_Cargo = {}

function GS_Cargo:Setup()
    self.OrderList = {}
    self.Timer = 0
    self.Status = 0
    self.ID_Iter = 1
    self.DeliveryStatus = false
end

function GS_Cargo:MakeOrder(order_name)
    --return id
end

function GS_Cargo:ApproveOrder(id)

end

function GS_Cargo:DeclineOrder(id)

end

function GS_Cargo:GetAllOrders()
    return self.OrderList
end

function GS_Cargo:GetAllApprovedOrders()

end

function GS_Cargo:Deliver()
    if self.DeliveryStatus then
        return false, "already deliver"
    end
    if table.Count(self:GetAllApprovedOrders()) == 0 then
        return false
    end

    timer.Create("gs_cargo_delivery", 90, 1, function()
        --spawn entity in cargo zone
        self.DeliveryStatus = false
    end)
end

function GS_Cargo:GetDeliveryStatus()
    -- return (send to client who opened console derma):
    -- delivery status (true/false)
    -- time (0 or delivery time)
end

--[[


]]