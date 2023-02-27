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
	font = "DermaDefault", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 20,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = true,
} )

list_models = {}

function DrawCharacterEditor()
    if CEFrame then
        return
    end

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
    icon:SetModel( "models/player/Group01/male_09.mdl" )
    function icon:LayoutEntity( Entity ) return end
    function icon.Entity:GetPlayerColor() return Vector (1, 0, 0) end
    

    local DPOpt = vgui.Create( "DPanel", CEFrame )
    DPOpt:SetSize( 285, 200 )
    DPOpt:SetPos(210,30)

    local DCharList = vgui.Create( "DComboBox", DPOpt)
    DCharList:SetPos( 5, 5 )
    DCharList:SetSize( 100, 20 )
    DCharList:SetValue( "Select..." )

    local BNewChar = vgui.Create("DImageButton", DPOpt)
    BNewChar:SetPos(110,6)
	BNewChar:SetSize(18,18)
	BNewChar:SetIcon("icon16/page_add.png")

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


    local PName = vgui.Create( "DLabel" , DPOpt)
    PName:SetPos(5, 60)
    PName:SetSize(164,20)
    PName:SetColor(Color(0,0,0))
    PName:SetFont("GS_CEFont")
    PName:SetText("Name: John Jonson")
    PName:SetMouseInputEnabled( true )

    function PName:DoClick()
        print("Change name, call derma")
        Derma_StringRequest(
        "Name of character", 
        "fack u",
        "Ivan Ivanov",
        function(text) print(text) end,
        function(text) print("Cancelled input") end
    )
    end

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

    function PNotes:DoClick()
        print("Change model")
    end

    local PExamine = vgui.Create( "DLabel" , DPOpt)
    PExamine:SetPos(5, 124)
    PExamine:SetSize(150,20)
    PExamine:SetColor(Color(0,0,0))
    PExamine:SetFont("GS_CEFont")
    PExamine:SetText("Examine info: Click")
    PExamine:SetMouseInputEnabled( true )

    function PExamine:DoClick()
    end

    local PJob = vgui.Create( "DLabel" , DPOpt)
    PJob:SetPos(5, 156)
    PJob:SetSize(150,20)
    PJob:SetColor(Color(0,0,0))
    PJob:SetFont("GS_CEFont")
    PJob:SetText("Job Preferences: Click")
    PJob:SetMouseInputEnabled( true )

    function PJob:DoClick()
    end

    local PRole = vgui.Create( "DLabel" , DPOpt)
    PRole:SetPos(5, 172)
    PRole:SetSize(150,20)
    PRole:SetColor(Color(0,0,0))
    PRole:SetFont("GS_CEFont")
    PRole:SetText("Role setting: Click")
    PRole:SetMouseInputEnabled( true )

    function PRole:DoClick()
    end
end


function DrawStartroundMenu()
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
--[[]]
concommand.Add("gs_d", function()
    DrawStartroundMenu()
end)

DrawStartroundMenu()
