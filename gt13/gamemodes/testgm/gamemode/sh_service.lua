local list = {1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
function gentocken()
    local str = "" 
    while string.len(str) != 4 do
        local int = math.random(1, #list)
        str = str .. list[int]
    end
    return str
end

function getMainBodyPart(bone) -- hardcode
    print(bone,"123")
    if bone == GS_BPART_BODY_TORS then
        return true, "body"
    elseif bone ==  GS_BPART_HEAD then
        return true, "head"
    elseif bone == GS_BPART_L_HAND then
        return true, "hand_l"
    elseif bone == GS_BPART_R_HAND then
        return true, "hand_r"
    elseif bone == GS_BPART_L_LEG then
        return true, "leg_l"
    elseif bone == GS_BPART_R_LEG then
        return true, "leg_r"
    end
    return false
end

function cantype(receiver, typ)
    if type(receiver) == "table" then
        for k,v in pairs(receiver) do
            if typ == v then
                return true
            end
        end
        return false
    else
        return receiver == typ
    end
end