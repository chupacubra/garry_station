PS_Jobs = {}

PS_Jobs.list = {}
--[[
    assistent
    cook
    engineer
    medic
    science team
    security
    director/boss
    !spec ops
]]

// как насчет того, чтобы сделать рюкзак ункомон предеметов (с малым шансом будет выдаваться при спавне)

--[[
PS_Jobs.list["assistent"] = {
    id = "assistent",
    name = "Assistent",
    ? aliases = "smth",
    access
    color
    equip = {
        ["BACKPACK"] = {
            ["assistent_backpack"] = { // содержимое
                content = {
                    ["random_assistent_item"]
                }, // труба, нож, кружка, 
            }
        },
        ["SUIT"] = "random_assistent_suit"
        ["KEY"] = "job_keycard"
        // можно так
        ["BACKPACK"] = function(ply)
            return ents.Create("bp_duffelbag")
        end

    } 
}
--]]

// так ли нужна будет эта функция? только для проведения всяких random_item
//function ConvertJobSpawnEquip(equip_tbl)
//end

local job_equip_func = {}



job_equip_func["assistent_backpack"] = function(self, ply, job_id) // не обязательно но окэй
    // ne ochen optimiz func but ok
    // особенно когда в начале раунда, но потом память подчищается
    local rand_back = {
        "bp_dufflebag",
        // ...
    }
    return table.Random(rand_back)
end

function JobPlyKeycard(ply, job_id)
    local key 
end

function PlyKeycardCustom(ply, data)
    //local key 
end

job_equip_func["job_keycard"] = JobPlyKeycard

// перегрузки?
// JobPlyEquip(ply, job_id)
// JobPlyEquip(ply, job_id = nil, equip_tbl)
//
function JobPlyEquip(ply, job_id, equip_tbl)
    //if 
    for typ, item in pairs(equip_tbl) do
        //
        
    end
end