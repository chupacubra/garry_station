--[[
need more complicated actions

example

gs_ent_action:AddNew(
    { -- receiver
        item_name = "pda"
    },
    { -- drop
        item_name = "id"
    },
    function(receiver, drop)
        receiver:InsertID(drop)
        drop:Remove()
    end
)


]]