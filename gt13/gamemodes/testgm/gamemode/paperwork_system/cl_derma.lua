
--[[
    somewhere on client...

    function ENT:ShowPaper()
        ShowPaper(self.text, function(text)
            ...
            send new text on server
            ...
        end
    end

--]]

CL_PW = {}
STYLE = ""

PW_size_frame = {x = 350, y = 500}

function CL_PW:ShowPaper(text, name, stamps, editf)
    local html = PWork:Format(text, LocalPlayer())

    local Frame = vgui.Create("DFrame")
    Frame:SetSize( PW_size_frame.x, PW_size_frame.y ) 
    Frame:SetTitle( name or "" )
    Frame:SetVisible( true )
    Frame:SetDraggable( true )
    Frame:ShowCloseButton( true )
    Frame:SetSizable( true )
    Frame:SetMinWidth(350)
    Frame:SetMinHeight(500)
    Frame:Center()
    Frame:MakePopup()

    local DPanel = vgui.Create( "DPanel",Frame )
    DPanel:SetPos( 1, 25 )
    DPanel:SetSize( PW_size_frame.x - 2, PW_size_frame.y - 26 )
    DPanel:SetBackgroundColor(Color(256,256,256))

    HTML = vgui.Create( "DHTML", DPanel )

    HTML:AddFunction( "paper", "luaprint", function(int)
        INPFrame = vgui.Create( "DFrame" )
        INPFrame:SetSize( 350, 400 ) 
        INPFrame:SetTitle( "Write" )
        INPFrame:SetVisible( true ) 
        INPFrame:SetDraggable( true ) 
        INPFrame:ShowCloseButton( true )
        INPFrame:Center() 
        INPFrame:MakePopup()
        
        local INP = vgui.Create( "DTextEntry", INPFrame )
        INP:Dock( TOP )
        INP:SetHeight(325)
        INP:SetMultiline( true )

        local INPB = vgui.Create( "DButton", INPFrame )
        INPB:SetText( "Write" )
        INPB:SetPos( 125, 360 )
        INPB:SetSize( 100, 30 )
        INPB.DoClick = function()
            editf(INP:GetValue(), tostring(int))
            INPFrame:Close()
        end
    end)

    function Frame:OnSizeChanged( w, h )
        PW_size_frame.x = w
        PW_size_frame.y = h

        HTML:SetSize( PW_size_frame.x - 2, PW_size_frame.y - 26 )
        DPanel:SetSize( PW_size_frame.x - 2, PW_size_frame.y - 26 )
    end

    HTML:SetHTML( STYLE..html..[[<a href="javascript:paper.luaprint(-1)">Write</a><br><hr>]] )
    HTML:SetSize( PW_size_frame.x - 2, PW_size_frame.y - 26 )

    function HTML:UpdateText(text, stamps)
       text = PWork:Format(text, LocalPlayer())
       self:SetHTML( STYLE..text..[[<a href="javascript:paper.luaprint(-1)">Write</a><br><hr>]])
    end

    return HTML
end
