GS_Craft_List = {}
GS_Craft_List.Receipts = {}

--type must be "Beatifule" id
--[[
    or create 
    GS_Craft_List:CreateCategory(name, service_name, ...)
    
    ent_rezult = {
        type = "item"/"swep",
        ent_name = "123"
    }
]]

function GS_Craft_List:NewReceipt(name_of_craft, type, ent_rezult, amount, comp, ent_data)
    
    if !self.Receipts[type] then
        self.Receipts[type] = {}
    end

    local craft =  {
        components = comp,
        rezult = ent_rezult,
        data = ent_data,
        amount = amount,
    }

    self.Receipts[type][name_of_craft] = craft
end

if CLIENT then

    function GS_Craft_List:CraftRequest(name)
        net.Start("gs_cl_craft_request")
        net.WriteString(name)
        net.SendToServer()
    end

end

function GS_Craft_List:GetReceipt(name)
    for type, list in pairs(self.Receipts) do
        if list[name] then
            return list[name], type
        end
    end
    GS_MSG("Warning! Don't find in craftlist the '"..tostring(name)"' receipt!")
    return false
end

function GS_Craft_List:GetAll()
    return self.Receipts
end

GS_Craft_List:NewReceipt("Hot dog", "shitpost", "food_hotdog", 1, {pile_wood = 1}, {})

