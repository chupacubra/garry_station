--[[
        access. his whole idea
in the card we put information about the person and his access
--[[
    Private_Data = {
        Info = {
            Name = "Chupacbra",
            Job  = "Assistent",
            Another_Info = ...
        },
        Access = 3,
    }
    
    Access is a 32/16 binary key, where each number is an indicator of whether it has access to anything
    3 = 00000000000000000000000000000111
                                     |||
                            _________/|\________
                           /          |         \
                        exit       constr        civilian doors, lockers 
                    from station    site

    for example, an assistant is trying to get into the scientific zone
    the doors of the scientific zone request such access
    16 = 10000
    To check access, we do a logical operation AND

    000000000000000000000000000|0|0111|AND
                               |1|0000|
      --------------------------------|
                                     0|
    
    as you can see, the answer is zero and the door does not open
    now there is an access check with the scientist
    
    000000100001000000000000010|1|1111|AND
                               |1|0000|
      --------------------------------|
                                 10000|

    as we can see, the result is equal to the requested access and the scientist can pass
]]

GS_ID = {}

ID_base = {
    Entity_Data = {
        Name = "card",  -- Cargo ID
        Desc = "desc",  -- It is a Ivan Ivanich ID
        Model = "models/weapons/helios/id_cards/w_idcard.mdl",
        ENUM_Type = GS_ITEM_EQUIP,
        ENUM_Subtype = GS_EQUIP_ID,
        Simple_Examine = true,
        Size = ITEM_VERY_SMALL,
    },
    Private_Data = {
        tocken   = "",
        access   =  0,
        job_name = "",
        job_dept = "",
        name     = "",
        color    = "",
    }
}

function GS_ID:GenerateIDData(tocken, job)
    local id = ID_base

    local jn = GS_Job:GetChoosenJob(job)
    local ac = GS_Job:GetAccess(job)
    local name = GS_PLY_Char:Name(tocken)

    id.Private_Data.tocken   = tocken
    id.Private_Data.name     = name
    id.Private_Data.job_name = jn.name
    id.Private_Data.job_dept = GS_Job:GetDeptName(job)
    id.Private_Data.access   = ac
    id.Private_Data.color    = GS_Job:GetColor(job)

    id.Entity_Data.Name = GS_Job:GetJobName(job).." ID card"
    id.Entity_Data.Desc = "It is a "..name.." card"

    return id
end

function CheckAccess(have, need)
    return bit.band(have, need) == need
end

function GS_ID:SpawnID(ply, job)

end