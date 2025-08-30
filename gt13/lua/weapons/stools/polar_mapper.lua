
TOOL.AddToMenu = true

TOOL.Category = "Polar Station configuration"
TOOL.Name = "Access" 

TOOL.ClientConVar[ "CLIENTSIDE" ] = "default"
TOOL.ServerConVar[ "SERVERSIDE" ] = "default"

local path = "data/polar_config/map/"


local function GetConfig(name)
    local json_file = file.Read( path..name, "DATA" )
    if !json_file or json_file == "" then return false end

    local tbl = util.JSONToTable(json_file)
    if !tbl then return false end
    if table.IsEmpty(tbl) then return false end

    return tbl
end


function TOOL:LeftClick( trace )
	print("12313")
	print(trace)
	print(trace.Entity)
	print(trace.Entity:GetModel())
end


function TOOL:RightClick( trace )
		print("12313")
	print(trace)
	print(trace.Entity)
	print(trace.Entity:GetModel())
end

function TOOL:Reload( trace )
	Msg( "RELOAD\n" )
end


function TOOL:Think()
	
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#tool.ballsocket.help" } )

	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "ballsocket", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "Slider", { Label = "#tool.forcelimit", Command = "ballsocket_forcelimit", Type = "Float", Min = 0, Max = 50000, Help = true } )

	CPanel:AddControl( "CheckBox", { Label = "#tool.nocollide", Command = "ballsocket_nocollide", Help = true } )

end

print("123")