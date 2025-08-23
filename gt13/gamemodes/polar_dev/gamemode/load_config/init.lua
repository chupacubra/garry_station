/*

    в папке data/polar_confing/maps будет конфигурация карт
    конфиг в txt json 


    data/
        polar_config/
            server.json
            map/
                spawns.json
                keypads.json
                entities.json
                buttons.json
                ...

    спец тулган для настройки значений карты

    все значения внутри GameConfig
    Значения по карте
*/

//local PS_MAP = "gs_boreas_night_d"
local config_dir = "polar_config/"

GameConfig = {}

local function FileToTable(path)
    local json_file = file.Read( path, "DATA" )
    if !json_file or json_file == "" then return false end

    local tbl = util.JSONToTable(json_file)
    if !tbl then return false end
    if table.IsEmpty(tbl) then return false end

    return tbl
end

function GameConfig:Apply()
    SetGlobalBool("Debug", self.debug or false)
end

local loading_map_files = {
    spawnpoints = "spawns.json",
    keypads = "keypads.json",
    entities = "entities.json",
    buttons = "buttons.json",
}

function GameConfig:LoadConfig()
    // read files, apply values
    //self.Config = {}

    local server = FileToTable(config_dir .. "server.json")
    if !server then
        GS_MSG("CANT LOAD SERVER CONFIG! stop loading config", "e" )
        return
    end

    table.Merge(self, server) // prikolishi

    for k, fn in pairs(loading_map_files) do
        GS_MSG("Loading "..fn)
        local config = FileToTable(config_dir .. "map/".. fn)
        if !config then 
            GS_MSG("Cant load file "..fn, "e")
            continue
        end

        self.Map[k] = fn
    end
end

function GameConfig:Initialize()
    self.Map = {}

    self:LocalConfig()
    self:Apply()
    self.Init = true
end
