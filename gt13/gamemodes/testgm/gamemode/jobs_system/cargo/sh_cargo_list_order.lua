Cargo_order_list = {}

Cargo_order_list.Other = {}

--[[
Cargo_order_list.Other = {
    {
        name = 
    }
}
]]

Cargo_order_list.Other {
    test_order = {
        name = "Test",       --  Name order in cargo console
        cost = 0,            --  cost 
        content = {          --  content
        "wooden_box"         --  only name from gs_controller list 
        },                   --
        container = ""       --  box, chest ( if container is "", then item spawn in cargo zone without container )
    }
}


-- generate unically id
-- new day - new id

for k,v in pairs(Cargo_order_list) do
    for kk, vv in pairs(v) do
        Cargo_order_list[k][kk]["id"] = generateID(kk)
    end
end