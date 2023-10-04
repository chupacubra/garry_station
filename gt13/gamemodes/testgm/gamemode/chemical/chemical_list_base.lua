
CHEMIC:New("Oxygen",{
	simpleName = "oxygen",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Nitrogen",{
	simpleName = "nitrogen",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Sugar",{
	simpleName = "sugar",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Hydrogen",{
	simpleName = "hydrogen",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Phosphorus",{
	simpleName = "phosphorus",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Saltpetre",{
	simpleName = "saltpetre",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
	receipt = {
	  inp = {
		oxygen = 3,
		nitrogen = 1,
		potassium = 1,
	  },
	  out = {
		saltpetre =  1,
	  }
	}
})

CHEMIC:New("Water",{
	simpleName = "water",
	normalName = "Water",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
	receipt = {
	  inp = {
		oxygen = 1,
		hydrogen = 2,
	  },
	  out = {
		water =  1,
	  }
	}
})

CHEMIC:New("Tea",{
	simpleName = "tea",
	normalName = "Tea",
	callbackInPly = function() end,
	callBackInMix = function(comp,bucket)
		for k, v in pairs(ents.FindByClass("player")) do
			local dist = v:GetPos():Distance(v:GetPos())
			if (dist <= 64) then
		  		v:ChatPrint( "Запахло чаем..." )
			end
	  	end
	end,
	activeid = -1,
	active = function() end,
	receipt = {
	  inp = {
		water = 1,
		tealeaf = 1,
	  },
	  out = {
		tea =  1,
	  },
	  notdispense = true
	}
})

CHEMIC:New("Tea leaf",{
	simpleName = "tealeaf",
	normalName = "Tea leaf" ,
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Potassium",{
	simpleName = "potassium",
	callbackInPly = function() end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})

CHEMIC:New("Toxin",{
	simpleName = "toxin",
	callbackInPly = function(comp,ply)
	  --ply:TakeDamage( 4, Entity(0), Entity(0))
	end,
	callBackInMix = function() end,
	activeid = -1,
	active = function() end,
})