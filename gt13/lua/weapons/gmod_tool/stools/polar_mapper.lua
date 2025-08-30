AddCSLuaFile()
include("sh_access.lua")
TOOL.AddToMenu = true

TOOL.Category = "Polar Station configuration"
TOOL.Name = "Access" 

TOOL.ClientConVar[ "CLIENTSIDE" ] = "default"
TOOL.ServerConVar[ "SERVERSIDE" ] = "default"

local path = "data/polar_config/map/"
local config_fn = "keypads.json"

PS_MapConfig = {}
PS_MapConfig_IsLoaded = false

local PS_Config_Keypad_Scheme = {
    Keypads = {}
}

local function GetConfig(name)
    local json_file = file.Read( path..name, "DATA" )
    if !json_file then return false end
    if json_file == "" then
        print("PS Mapper: file is empty, load shablon")
        tbl = PS_Config_Keypad_Scheme
        return tbl
    end
    local tbl = util.JSONToTable(json_file)
    if !tbl then return false end

    if table.IsEmpty(tbl) then
        print("PS Mapper: file is empty, load shablon")
        tbl = PS_Config_Keypad_Scheme
    end

    return tbl
end

local function FindFuncButtonForKeypad(keypad)
    local tbl = ents.FindInBox( Vector(-1,-1,-1), Vector(1,1,1) )
    //PrintTable(tbl)
    //print(#tbl)
end

concommand.Add("ps_config_load", function(ply)
    local conf = GetConfig(config_fn)
    if !conf then
        ply:ChatPrint("PS Mapper: Cant load "..path..config_fn)
        return
    end
    ply:ChatPrint("PS Mapper: loaded "..path..config_fn)
    PS_MapConfig = conf
    PS_MapConfig_IsLoaded = true
end)

concommand.Add("ps_config_save", function(ply)
    local conf = PS_MapConfig
    if !PS_MapConfig_IsLoaded then
        ply:ChatPrint("PS Mapper: Cant save "..path..config_fn..": is not loaded!")
        return
    end

    if table.IsEmpty(conf) then
        ply:ChatPrint("PS Mapper: Cant save "..path..config_fn..": table is EMPTY")
        return
    end
end)

local pairs_keypad_func = {}
local pairs_keypad_keypad = {}
local ents_keypads = ents.FindByModel("models/props_lab/keypad.mdl")
local func_buttons = ents.FindByClass("func_button")

concommand.Add("get_keypads_map_data", function (ply)
    print("keypads:", #ents_keypads)
    print("funcs:", #func_buttons)

    for k, func in pairs(func_buttons) do
        for kk, key in pairs(ents_keypads) do

            local f_pos, k_pos =  func:GetPos(), key:GetPos()
            if f_pos:Distance(k_pos) < 20 then

                pairs_keypad_func[func] = pairs_keypad_func[func] or {}
                table.insert(pairs_keypad_func[func], key)
            end
        end
    end

end)

function TOOL:LeftClick( trace )

    local ent = trace.Entity

    print(ent, ent:GetName())
    PrintTable(ent:GetKeyValues("targetname"))
    print(ent:GetParent())

end


function TOOL:RightClick( trace )
	Msg( "ALT FIRE\n" )
end

function TOOL:Reload( trace )
	Msg( "RELOAD\n" )
end

local draw_dist = 1000

function TOOL:Think()
	//if !PS_MapConfig_IsLoaded then return end
    if CLIENT then return end
    
    local config = PS_MapConfig

    //if table.IsEmpty(config.Keypads) then
    //    return
    //end
    local owner = self:GetOwner()
    local pos = owner:GetPos()
    for func, keypads in pairs(pairs_keypad_func) do

        local func_pos = func:GetPos()
        local dist = func_pos:Distance(pos)
        if dist > draw_dist then continue end
        
        debugoverlay.EntityTextAtPosition(func_pos, 0.1, tostring(func))
        debugoverlay.Cross(func_pos, 10, 0.1, Color(255,255,255), true)

        for _, pad in pairs(keypads) do
            local pad_pos = pad:GetPos()

            debugoverlay.EntityTextAtPosition(pad_pos, 0.1, tostring(pad))
        end


        FindFuncButtonForKeypad(keypad)

    end
 
    //self:NextThink(CurTime() + 1)
    return true
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.ballsocket.help" } )

	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "ballsocket", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "Slider", { Label = "#tool.forcelimit", Command = "ballsocket_forcelimit", Type = "Float", Min = 0, Max = 50000, Help = true } )

	CPanel:AddControl( "CheckBox", { Label = "#tool.nocollide", Command = "ballsocket_nocollide", Help = true } )

end

hook.Add("EntityTakeDamage", "123", function(ent, dmg)
    print(ent)
end)

//PrintTable(ents.FindByModel("models/props_lab/keypad.mdl"))

local pad = Entity(836)
local func = Entity(838)

print(pad:GetPos():Distance(func:GetPos()))