CHEMIC:New("fiber",{
	simpleName = "fiber",
	callbackInPly = function(ply)
        player_manager.RunClass(ply, "AddSaturation", 3)
    end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})