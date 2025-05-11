PLAYER_OTHER = {}

local BD_EX = {
    head   = "head",
    hand_l = "left hand",
    hand_r = "right hand",
    body   = "torse",
    leg_l  = "left leg",
    leg_r  = "right leg",
}

function PLAYER_OTHER:ExamineEquip(ply)
    --GS_ChatPrint(ply, self.Character.name .. " equipment:")
    for k, v in pairs(self.Player.Equipment) do
        if v != 0 then
            GS_ChatPrint("he have ".. v.Entity_Data.Name)
        end
    end
end

function PLAYER_OTHER:ExamineBody(ply)
    for k, v in pairs(BD_EX) do
        local pnd = self.Player.Body_Parts[k][1] + self.Player.Body_Parts[k][2]
        local st = "ok"

        if pnd > 0 and pnd < 15 then
            st = "numb"
        elseif pnd < 40 then
            st = "bruised"
        else 
            st = "crippled"
        end 
        
        GS_ChatPrint(ply, v.." is "..st)
    end
    
    if self.Player.Organism_Value.pain_shock or self.Player.Organism_Value.blood.value < 75 then
        GS_ChatPrint("the skin is pale")
    end
end

function PLAYER_OTHER:MakeAction(ply, id)
    if id == S_EXAMINE then
        self:Examine(ply)
    elseif id == s_EXAMINE_EQ then
        self:ExamineEquip(ply)
    elseif id == S_EXAMINE_BD then
        self:ExamineBody(ply)
    end
end

--[[
GOING TO player_ext.lua

function PLAYER_OTHER:GetID() -- getting id from equip and hands
    local id = self:GetEquipItem("KEYCARD")

    if !id then
        id = self:GetItemFromContext(context, key)
        
        if !id then
            return false
        end

        if GS_ID:IsID(id) then
            return id
        else
            return false
        end
    end

    return id
end

function PLAYER_OTHER:GetIDAccess()
    local id = self:GetID()
    if id then
        return id.Private_Data.access
    else
        return 0 -- zero access because don't have id
    end
end
--]]