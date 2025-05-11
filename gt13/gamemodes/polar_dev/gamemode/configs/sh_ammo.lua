GS_Ammo = {}
GS_Ammo.AMMO        = {}
GS_Ammo.Category    = {}
function GS_Ammo.Add(ammo_id, ammo_data)
    if type(ammo_data) == "table" and type(ammo_id) == "string" then
        if GS_Ammo.AMMO[ammo_id] then
            GS_MSG("Already have ammotype("..tostring(ammo_id).."), rewriting")
        end
        
        GS_Ammo.AMMO[ammo_id] = {
            Damage      = ammo_data.Damage      or 10,
            MulSpread   = ammo_data.MulSpread   or 1,
            Num         = ammo_data.Num         or 1,
            MulRecoil   = ammo_data.MulRecoil   or 1,
            DMGType     = ammo_data.DMGType     or DMG_BULLET,
            Tracer      = ammo_data.Tracer      or TRACER_LINE_AND_WHIZ,
            Category    = ammo_data.Category    or nil,
        }

        GS_MSG("New ammotype ("..tostring(ammo_id)..")")
        if ammo_data.Category then
            if !GS_Ammo.Category[ammo_data.Category] then GS_Ammo.Category[ammo_data.Category] = {} end
            table.insert(GS_Ammo.Category[ammo_data.Category], ammo_id)
        end
    else
        GS_MSG("Unable to add new ammotype ("..tostring(ammo_id)..")")
    end
end

function GS_Ammo.Get(id)
    if type(GS_Ammo.AMMO[id]) == "table" then
        return GS_Ammo.AMMO[id]
    else
        GS_MSG("Watafak?, wht the ammo? ("..tostring(id)..")")
        return GS_Ammo.AMMO["bullet_base"]
    end
end

function GS_Ammo.GetCateg(categ)
    return GS_Ammo.Category[categ] or false
end

GS_Ammo.Add( "bullet_base",
    {
        Damage      = 10,
        MulSpread   = 1,
        Num         = 1,
        MulRecoil   = 1,
        DMGType     = DMG_BULLET, // in EntityTakeDamage razberutsya
        Tracer      = TRACER_LINE_AND_WHIZ,
        Category    = nil,
    }
)

GS_Ammo.Add( "9mm",
    {
        Damage      = 8,
        MulSpread   = 0.9,
        
        //Num         = 1,
        //MulRecoil   = 1,
        //DMGType     = DMG_BULLET, // in EntityTakeDamage razberutsya
        //Tracer      = TRACER_LINE_AND_WHIZ,
    }
)
