surface.CreateFont( "GS_CEFont", {
	font = "DermaDefault",
	extended = false,
	size = 14,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
} )

surface.CreateFont( "GS_CEFontHead", {
	font = "DermaDefault",
	extended = false,
	size = 20,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
} )

list_models = {}
list_pers   = {}
bapply_cooldown = false

new_char = {
    name = "John Jonson",
    model = 1,
    person_notes = "",
    examine_info = "",
    job_prefer   = "",
    char_settings = {},
}

--[[
    chars saved in gs13
    config.txt
    chars/
         random1.txt
         random2.txt
]]

function CreateNewChar()
    local a = {
        id = gentocken(),
        char_data = {
            name = gentocken(),
            model = 1,
            person_notes = "",
            examine_info = "",
            job_prefer   = {},
            char_settings = {},
        }
    }
    return table.Copy(a)
end

function SaveNewCharacter(char_data)
    local id = gentocken()

    local data = util.TableToJSON( char_data )
    local filename = "gs13/chars/"..id..".txt"

    file.Write(filename, data)

    return file.Exists(filename, "DATA")
end

function SaveCharacter(id, char_data)
    if id == nil then
        SaveNewCharacter(char_data)
        return
    end

    local filename = "gs13/chars/"..id..".txt"
    local data = util.TableToJSON( char_data )
    
    file.Write(filename, data)

    return file.Exists(filename, "DATA")
end

function OpenCharacter(id)
    local filename = "gs13/chars/"..id..".txt"

    if !file.Exists(filename, "DATA") then
        return
    end

    local json = file.Read( filename, "DATA" )
    local tbl  = util.JSONToTable(json)

    return tbl
end

function DeleteCharacter(id)
    local filename = "gs13/chars/"..id..".txt"

    file.Delete( filename )

    return !file.Exists(filename, "DATA")
end

function FindAllCharacters()
    local chars_id = file.Find( "gs13/chars/*", "DATA" )
    local chars_tbl = {}
    for k,v in pairs(chars_id) do
        --chars_id[k] = string.StripExtension(v)
        local json = file.Read("gs13/chars/"..v , "DATA" )
        local data = util.JSONToTable(json)
        if data then
            table.insert(chars_tbl, data)
        end
    end
    
    return chars_tbl
end

function DrawCharacterEditor()
    --local derma_table = {}
    local char_selected = {}
    local chat_selected_bool = false


    local CEFrame = vgui.Create("DFrame")
    CEFrame:SetSize(500, 240)
    CEFrame:Center()
    CEFrame:SetTitle("Character card")
    CEFrame:MakePopup()
    --CEFrame:ShowCloseButton(false)

    local DPModel = vgui.Create( "DPanel", CEFrame )
    DPModel:SetSize( 200, 200 )
    DPModel:SetPos(5,30)

    local icon = vgui.Create( "DModelPanel", DPModel )
    icon:SetSize(200,200)
    icon:SetModel( "" )
    function icon:LayoutEntity( Entity ) return end

    --function icon.Entity:GetPlayerColor() return Vector (1, 0, 0) end

    local DPOpt = vgui.Create( "DPanel", CEFrame )
    DPOpt:SetSize( 285, 200 )
    DPOpt:SetPos(210,30)
 
    local DCharList = vgui.Create( "DComboBox", DPOpt)
    DCharList:SetPos( 5, 5 )
    DCharList:SetSize( 100, 20 )
    DCharList:SetValue( "None" )

    function DCharList:ResetAndSelect(tocken)
        self:Clear()
        for k,v in pairs(FindAllIDCharacters()) do
            local append_id = DCharList:AddChoice(v.char_data.name, v)
            if v.id == tocken then
                DCharList:ChooseOptionID( append_id )
                ChooseChar(data)
            end
        end
    end

    local BNewChar = vgui.Create("DImageButton", DPOpt)
    BNewChar:SetPos(110,6)
	BNewChar:SetSize(18,18)
	BNewChar:SetIcon("icon16/page_add.png")
--[[
    function BNewChar:DoClick()
        local new = CreateNewChar()
        local id_new = DCharList:AddChoice(new.char_data.name, new)
        DCharList:ChooseOptionID( id_new )
    end
--]]

    local BSaveChar = vgui.Create("DImageButton", DPOpt)
    BSaveChar:SetPos(132,6)
	BSaveChar:SetSize(18,18)
	BSaveChar:SetIcon("icon16/page_save.png")

    local BDelChar = vgui.Create("DImageButton", DPOpt)
    BDelChar:SetPos(160,6)
	BDelChar:SetSize(18,18)
	BDelChar:SetIcon("icon16/page_delete.png")

    local PLabel = vgui.Create( "DLabel" , DPOpt)
    PLabel:SetPos(5, 30)
    PLabel:SetSize(164,20)
    PLabel:SetFont("GS_CEFontHead")
    PLabel:SetColor(Color(0,0,238))
    PLabel:SetText("Person information")

    local PNameChar = vgui.Create( "DLabel" , DPOpt)
    PNameChar:SetPos(5, 60)
    PNameChar:SetSize(164,20)
    PNameChar:SetColor(Color(0,0,0))
    PNameChar:SetFont("GS_CEFont")
    PNameChar:SetText("Name: Select Person First!")
    PNameChar:SetMouseInputEnabled( true )

    local PModel = vgui.Create( "DLabel" , DPOpt)
    PModel:SetPos(5, 76)
    PModel:SetSize(150,20)
    PModel:SetColor(Color(0,0,0))
    PModel:SetFont("GS_CEFont")
    PModel:SetText("Model: Click")
    PModel:SetMouseInputEnabled( true )

    local PNotes = vgui.Create( "DLabel" , DPOpt)
    PNotes:SetPos(5, 92)
    PNotes:SetSize(250,20)
    PNotes:SetColor(Color(0,0,0))
    PNotes:SetFont("GS_CEFont")
    PNotes:SetText("Person information(Person notes): Click")
    PNotes:SetMouseInputEnabled( true )

    local PExamine = vgui.Create( "DLabel" , DPOpt)
    PExamine:SetPos(5, 124)
    PExamine:SetSize(150,20)
    PExamine:SetColor(Color(0,0,0))
    PExamine:SetFont("GS_CEFont")
    PExamine:SetText("Examine info: Click")
    PExamine:SetMouseInputEnabled( true )

    local PJob = vgui.Create( "DLabel" , DPOpt)
    PJob:SetPos(5, 156)
    PJob:SetSize(150,20)
    PJob:SetColor(Color(0,0,0))
    PJob:SetFont("GS_CEFont")
    PJob:SetText("Job Preferences: Click")
    PJob:SetMouseInputEnabled( true )

    local PRole = vgui.Create( "DLabel" , DPOpt)
    PRole:SetPos(5, 172)
    PRole:SetSize(150,20)
    PRole:SetColor(Color(0,0,0))
    PRole:SetFont("GS_CEFont")
    PRole:SetText("Role setting: Click")
    PRole:SetMouseInputEnabled( true )

    local PApply = vgui.Create( "DLabel" , DPOpt)
    PApply:SetPos(175, 172)
    PApply:SetSize(150,20)
    PApply:SetColor(Color(0,0,0))
    PApply:SetFont("GS_CEFont")
    PApply:SetText("Use this character")
    PApply:SetMouseInputEnabled( true )

    local function ChooseChar(char_data)
        char_selected_bool = true
        char_selected = char_data
        PNameChar:SetText("Name: "..char_selected.char_data.name)
        PrintTable(char_selected)
    end

    function BSaveChar:DoClick()
        --DCharList:AddChoice(char_selected.char_data.name, char_selected)
        SaveCharacter(char_selected.id,char_selected)
        local tocken = char_selected.id
        char_selected = {}
        DCharList:ResetAndSelect(tocken)
    end

    for k,v in pairs(FindAllCharacters()) do
        print(k,v)
        DCharList:AddChoice(v.char_data.name, v)
    end

    function DCharList:OnSelect( index, val, data )
        --char_selected = data
         --PNameChar:SetText("Name: "..char_selected.char_data.name)
        PrintTable(data)
        ChooseChar(data)
    end

    function PNameChar:DoClick()
        if !char_selected_bool then
            return
        end
        print("Change name, call derma")
        Derma_StringRequest(
            "Name of character", 
            "Name of character write here",
            "Ivan Ivanov",
            function(text) 
                if table.IsEmpty(char_selected) then
                    return
                end
                
                char_selected.char_data.name = text
                PNameChar:SetText("Name: "..text)
                --DCharList:ChooseOption( text, DCharList:GetSelectedID())
            end,
            function(text) print("Cancelled input") end
        )
    end

    function BNewChar:DoClick()
        local new = CreateNewChar()
        local id_new = DCharList:AddChoice("New", new)
        DCharList:ChooseOptionID( id_new )
        ChooseChar(new)
    end

    function PNotes:DoClick()
        print("Change model")
    end

    function PExamine:DoClick()
        Derma_StringRequest(
            "Examine data", 
            "Examine char",
            char_selected.char_data.examine_info or "bald",
            function(text)
                if table.IsEmpty(char_selected) then
                    return
                end
                
                char_selected.char_data.examine_info = text
                --PNameChar:SetText("Name: "..text)
            end,
            function(text) print("Cancelled input") end
        )
    end

    function PJob:DoClick()
    end

    function PRole:DoClick()
    end

    function PApply:DoClick()
        if bapply_cooldown then
            return 
        end

        MakeDermaAction("menu_prestart", "loadchar", char_selected.char_data)

        loaded_char = char_selected
        loaded_char_bool = true
        bapply_cooldown = true
        self:SetColor(Color(200,40,40))
        timer.Simple(3, function()
            if IsValid(self) then
                bapply_cooldown = nil
                self:SetColor(Color(0,0,0))
            end
        end)
    end

end 

function DrawStartroundMenu()
    local loaded_char = {}
    local loaded_char_bool = false
    local Menu = vgui.Create("DFrame")

    Menu:SetSize(200, 400)
    Menu:Center()
    Menu:SetTitle("Start menu")
    Menu:MakePopup()
    --Menu:ShowCloseButton(false)

    local InfoPanel = vgui.Create("DPanel", Menu)
    InfoPanel:Dock(BOTTOM)
    InfoPanel:SetSize(150,150)
    InfoPanel:DockMargin(5, 5, 10, 5)

    local LStatus = vgui.Create( "DLabel" , InfoPanel)
    LStatus:SetPos(5, 5)
    LStatus:SetSize(150,20)
    LStatus:SetColor(Color(0,0,0))
    LStatus:SetText("Station status: ...")

    local LTime = vgui.Create( "DLabel" , InfoPanel)
    LTime:SetPos(5, 25)
    LTime:SetSize(150,20)
    LTime:SetColor(Color(0,0,0))
    LTime:SetText("Time: ...")

    local LPly = vgui.Create( "DLabel" , InfoPanel)
    LPly:SetPos(5, 45)
    LPly:SetSize(150,20)
    LPly:SetColor(Color(0,0,0))
    LPly:SetText("Players: ...")

    local BChar = vgui.Create( "DButton" , Menu)
    BChar:SetText( "Open Character menu" )
    BChar:SetSize( 70, 30 )
    BChar:DockMargin(10, 10, 10, 10)
    BChar:Dock(TOP)

    function BChar:DoClick()
        DrawCharacterEditor()
    end

    local BJoin = vgui.Create( "DButton",Menu )
    BJoin:SetText( "..." )
    BJoin:SetSize( 70, 30 )
    BJoin:DockMargin(10, 10, 10, 10)
    BJoin:Dock(TOP)
    
    BJoin.Mode = -1
    BJoin.Ready = false

    function Menu:Think()
        local time = GS_RoundStatus:GetRoundTime(true)
        local stat = GS_RoundStatus:GetRoundStatus()
        local str = roundstr(stat)

        LStatus:SetText("Station status: "..str)
        LTime:SetText("Time: "..time)
        --LPly:SetText("Players: ")

        if BJoin.Mode != stat then
            if stat == GS_ROUND_PREPARE then
                BJoin:SetText("Ready: NO")
                BJoin.DoClick = function(self)
                    self.Ready = not self.Ready
                    if self.Ready == true then
                       self:SetText("Ready: YES") 
                    else
                        self:SetText("Ready: NO")
                    end
                    print(self.Ready)
                    --[[
                        menu handler ready button
                    ]]
                    
                    MakeDermaAction("menu_prestart", "ready", {ready = self.Ready})
                end

            elseif stat == GS_ROUND_RUNNING then
                BJoin:SetText("Enter to station")

                BJoin.DoClick = function(self)
                    --[[
                        menu handler join button
                    ]]

                    MakeDermaAction("menu_prestart", "join", {})
                end
            end
            BJoin.Mode = stat
        end
    end

end

DrawStartroundMenu()

concommand.Add("gs_d", function()
    DrawStartroundMenu()
end)   

if file.IsDir( "gs13", "DATA" ) == false then
    file.CreateDir("gs13")
    file.CreateDir("gs13/chars")
    file.Write( "gs13/config.txt", util.TableToJSON( {last_char = "0"} ) )
end



net.Receive("gs_sys_char_send",function()

    local bool = net.ReadBool()
    if bool then
        Derma_Message("Character applied", "Character editor", "OK")
    else
        Derma_Message("Character IS NOT applied. I gues is a error?", "Character editor", "Why?")
    end
end)