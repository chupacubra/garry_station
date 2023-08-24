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
        Name = "Card",  -- Cargo ID
        Desc = "The clean ID",  -- It is a Ivan Ivanich ID
        Model = "models/weapons/helios/id_cards/w_idcard.mdl",
        ENUM_Type = GS_ITEM_EQUIP,
        ENUM_Subtype = GS_EQUIP_ID,
        Size = ITEM_VERY_SMALL,
    },
    Private_Data = {
        tocken   = "",
        access   =  1,
        job_name = "",
        job_dept = "",
        name     = "",
        ENT_Color    = "",
    }
}


local ENT = {}

ENT.Base ="gs_entity_base_item"
ENT.Private_Data = ID_base.Private_Data
ENT.Entity_Data  = ID_base.Entity_Data
--ENT.Data_Labels  = {type = k, id = kk}
scripted_ents.Register( ENT, "gs_item_keycard" )


function GS_ID:IsID(data)
    return data.Entity_Data.ENUM_Type == GS_ITEM_EQUIP and data.Entity_Data.ENUM_Subtype == GS_EQUIP_ID
end

function GS_ID:GenerateIDData(tocken, job)
    local id = ID_base

    local ac = GS_Job:GetAccess(job)
    local name = GS_PLY_Char:Name(tocken)

    local jobdata = GS_Job:GetChoosenJob(job)
    local deptdata = GS_Job:GetDeptDataD(jobdata.dept)

    id.Private_Data.tocken   = tocken
    id.Private_Data.name     = name
    id.Private_Data.job_name = jobdata.name
    id.Private_Data.job_dept = deptdata.name
    id.Private_Data.access   = ac
    id.Private_Data.ENT_Color = rgbToHex(jobdata.color or deptdata.color)

    id.Entity_Data.Name = name.." ID card"
    id.Entity_Data.Desc = "It is a "..jobdata.name.." card"

    return id
end

function HaveAccess(have, need)
    return bit.band(have, need) == need
end

function GS_ID:CreateID()
    -- generate new ID and return entity
    return ents.Create("gs_item_keycard")
end

function GS_ID:PrestartID(ply, job)
    -- create and equip ply ID
    local tocken = GS_PLY_Char:GetPlyChar(ply)
    local id = self:GenerateIDData(tocken, job)

    local iddata = GS_EntityControler:GetEntData("gs_item_keycard")
    iddata.Private_Data = id.Private_Data
    iddata.Entity_Data  = id.Entity_Data

    PrintTable(iddata)

    player_manager.RunClass( ply, "EquipItem", iddata, "KEYCARD")
end