AddCSLuaFile()
include("sh_access.lua")

TOOL.AddToMenu = true

TOOL.Category = "Polar Station configuration"
TOOL.Name = "Access" 

TOOL.ClientConVar[ "CLIENTSIDE" ] = "default"
TOOL.ServerConVar[ "SERVERSIDE" ] = "default"

if CLIENT then
    language.Add("tool.polar_mapper.name", "Кейпады")
    language.Add("tool.polar_mapper.desc", "выбрал настроил сохранил")
end

local path = "polar_config/map/"
local config_fn = "keypads.json"

PS_MapConfig = PS_MapConfig or {}
PS_MapConfig_IsLoaded = PS_MapConfig_IsLoaded or false 

local PS_Config_Keypad_Scheme = {
    Keypads = {}
}

local Access_list = {
    "no_access",       
    "interior_0",      
    "interior_1",      
    "interior_2",      
    "service",
    "medical",
    "engineer",
    "science",
    "security",
    "director",
}

local convar_name = "ps_mapper_keypad_setflag_"
local list_convars_access = {}

if SERVER then
    for k, v in pairs(Access_list) do
        local var = CreateConVar("ps_mapper_keypad_setflag_"..v, "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "This is a server-side convar.")
        list_convars_access[v] = var
    end
end

local function GetAccess()
    local access_id = {}
    for index, cvar in pairs(list_convars_access) do
        if cvar:GetBool() then
            table.insert(access_id, index)
        end
    end

    PrintTable(access_id)

    local access_val = Access.Set(access_id)
    print(access_val)

    return access_val
end

local function GetConfig(name)
    local json_file = file.Read( path..name, "DATA" )
    if !json_file then return false end
    if json_file == "" then
        print("PS Mapper: file is empty, load shablon")
        tbl = PS_Config_Keypad_Scheme
        return tbl
    end
    local tbl = util.JSONToTable(json_file)

    if table.IsEmpty(tbl) or !tbl then
        print("PS Mapper: file is empty, load shablon")
        tbl = table.Copy(PS_Config_Keypad_Scheme)
    end

    return tbl
end


local function SaveConfig(name)
    if !PS_MapConfig_IsLoaded then
        print("PS Mapper: load first!")
        return
    end

    if table.IsEmpty(PS_MapConfig.Keypads) then
        print("PS Mapper: data is empty, dont save")
        return
    end

    local json = util.TableToJSON(PS_MapConfig)
    if file.Write( path..name, json ) then
        print("PS Mapper: file saved")
    end
end

//concommand.Add("")


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

concommand.Add("ps_mapper_keypad_access", function(ply, args)
    print(args)
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
    SaveConfig(config_fn)
end)

local pairs_keypad_func = {}
local invert_func_keypad = {}
local ents_keypads = ents.FindByModel("models/props_lab/keypad.mdl")
local func_buttons = ents.FindByClass("func_button")
 
concommand.Add("get_keypads_map_data", function (ply)
    print("keypads:", #ents_keypads)
    print("funcs:", #func_buttons)
    pairs_keypad_func = {}
    invert_func_keypad = {}
    for k, func in pairs(func_buttons) do
        for kk, key in pairs(ents_keypads) do

            local f_pos, k_pos =  func:GetPos(), key:GetPos()
            if f_pos:Distance(k_pos) < 40 then

                pairs_keypad_func[func] = pairs_keypad_func[func] or {}
                table.insert(pairs_keypad_func[func], key)
                invert_func_keypad[key] = func
            end
        end
    end
end)

function TOOL:LeftClick( trace )
    local pad = trace.Entity
    if !IsValid(pad) then return end
    self.SelectedFunc = pad 
end


function TOOL:RightClick( trace )
	// apply
    local func = self.SelectedFunc 
    if !func then return end
    local owner = self:GetOwner()

    local props_keypads = pairs_keypad_func
    //PrintTable(props_keypads)
    local access = GetAccess()
    local keypad_data = {}
    keypad_data.access = access
    keypad_data.func = func:MapCreationID()
    keypad_data.pads = {}
    for k, pad in pairs(props_keypads[func]) do
        //for kk, pad in pairs(pads) do
            table.insert(keypad_data.pads, pad:MapCreationID())
        //end
    end

    PS_MapConfig.Keypads[keypad_data.func] = keypad_data
    owner:ChatPrint("PS Mapper: applied options for func "..keypad_data.func)
    self.SelectedFunc = nil
end

function TOOL:Reload( trace )
    self.SelectedFunc = nil
end

local draw_dist = 1000
local select_color = Color(255,255,0)
local def_color = Color(255,255,255)

function TOOL:Think()
	//if !PS_MapConfig_IsLoaded then return end
    if CLIENT then return end
    
    local owner = self:GetOwner()

    local config = PS_MapConfig.Keypads
    /*
    if !config then
        owner:ChatPrint("PS Mapper: где конфиг")
    end
    */
    local pos = owner:GetPos()

    local selected_func = self.SelectedFunc
    local color = def_color

    local config_loaded = PS_MapConfig_IsLoaded
    local config = PS_MapConfig.Keypads
    for func, keypads in pairs(pairs_keypad_func) do
        color = def_color
        local is_selected = func == selected_func
        if is_selected  then
            color = select_color
        end

        local func_pos = func:GetPos()
        local dist = func_pos:Distance(pos)
        if dist > draw_dist then continue end

        local i = 0

        debugoverlay.EntityTextAtPosition(func_pos, i, tostring(func), 0.1)
        debugoverlay.Cross(func_pos, 10, 0.1, color, true)

        for _, pad in pairs(keypads) do
            i = i + 1
            debugoverlay.EntityTextAtPosition(func_pos, i, "KEYPAD "..tostring(pad),0.1)
        end

        if !config_loaded then continue end
        local data = config[func:MapCreationID()]
        //print(func, data)
        if !data then continue end
        local access = data.access
        //print(func, data, access)
        local access_list = Access.GetList(access)
        //print(access_list, #access_list)
        //PrintTable(access_list)
        //print("123213")
        //PrintTable(access_list)
        for _, ind in pairs(access_list) do
            i = i + 1
            debugoverlay.EntityTextAtPosition(func_pos, i, ind ,0.1)

        end
        

    end

    return true
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl( "Header", { Description = "Настройка кейпадов на доступ" } )
    for k, v in pairs(Access_list) do
	    local checkbox = CPanel:AddControl( "CheckBox", { Label = v, Command = "ps_mapper_keypad_setflag_"..v, Help = false} )
    end
 

    CPanel:AddControl( "Button", { Label = "Обновить информацию про кейпады(сначала сюда)",  Command = "get_keypads_map_data", Help = false} )

    CPanel:AddControl( "Button", { Label = "Открыть конфиг", Command = "ps_config_load", Help = false} )

    CPanel:AddControl( "Button", { Label = "СОХРАНИТЬ КЕЙПАДЫ В КОНФИГЕ", Command = "ps_config_save", Help = false} )
end


hook.Add("PlayerUse", "12313", function(ply, ent)
    print(ply, ent)
end)

hook.Add( "AcceptInput", "UseMapObject", function( ent, name, activator, caller, data )
    print(ent, name, activator, caller, data)
    //return true
end)