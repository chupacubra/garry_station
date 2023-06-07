concommand.Add("gs_debug_human", function(ply)
    timer.Create("debug:"..ply:EntIndex(), function()
        debugoverlay.ScreenText( 100, 100, "HUMAN-", number lifetime = 1, table color = Color( 255, 255, 255 ) )
    end)
end