GS_Ammo = {}
--local Iter = 0 // for generating id for ammo calibres

--[[

    opt = {
        num_bullets = 1
    }

]]

function RegisterAmmo(type, dmg, opt)
    GS_Ammo[type] = {dmg = dmg, opt = opt}
end

function GetBulletDMG(type)
    return GS_Ammo[type].dmg or {}
end

function GetBulletOptions(type)
    return GS_Ammo[type].opt or {}
end