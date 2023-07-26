Cargo_order_list = {}

Cargo_order_list.Other = {}

--[[
Cargo_order_list.Other = {
    {
        name = 
    }
}
]]
 
Cargo_order_list.Other = {
    test_order = {
        name = "Wooden box",       --  Name order in cargo console
        cost = 100,                --  cost 
        content = {                --  content
            --{"typ","wooden_box"} --  only typ and name from gs_controller list 
        },
        container = "wooden_box", --  box, chest ( if container is "" or nil, then item spawn in cargo zone without container )
    }
}


-- generate unically id
-- new day - new id

for k,v in pairs(Cargo_order_list) do
    for kk, vv in pairs(v) do
        Cargo_order_list[k][kk]["id"] = generateID(kk)
    end
end