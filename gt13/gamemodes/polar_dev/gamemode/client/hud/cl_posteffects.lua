local ScreenspaceEffects = {}
ScreenspaceEffects.Pain = {
    shocked = false,
    last_shock = -1,
    value = 0,
    old_value = 0,
    last_changed = 0,

}
ScreenspaceEffects.Stamina = {
    value = 100,

}
ScreenspaceEffects.Explosion = {}     // polnoe skibidi
ScreenspaceEffects.Faint = {}

local ply = LocalPlayer()

local time_change = 0.5

hook.Add( "RenderScreenspaceEffects", "PainEffect", function()
    local ply = LocalPlayer()
    if !ply:IsActive() then return end 
    local pain = ScreenspaceEffects.Pain.value
    local old_pain = ScreenspaceEffects.Pain.old_value

    if pain == old_pain and pain == 0 then return end

    local curtime = CurTime()
    local last_changed = ScreenspaceEffects.Pain.last_changed
    if last_changed + time_change > curtime and math.abs(pain - old_pain) > 0.05 then
        pain = Lerp((curtime - last_changed) / time_change, pain, old_pain)
    end

    local sharp = pain * 1.5
    local dist  = pain * math.abs(math.sin(curtime)) * 2

    DrawSharpen( sharp, dist )
end )


// необходимо ввести болевой порог?
// или обезболивающие, которые которые сносят боль и дают уменьшенную боль после ударов?
hook.Add("PlyClassInit", "ScreenspaceEffectsInit", function(ply)
    print("ply", ply, "class init")
    if ply != LocalPlayer() then return end

    ply:LocalNWVarProxyAdd("Pain", function(ply, key, old, new)

        if new < 0.4 then
            new = 0
        end
        old = ScreenspaceEffects.Pain.old_value
        ScreenspaceEffects.Pain.value = new
        ScreenspaceEffects.Pain.old_value = old
        ScreenspaceEffects.Pain.last_changed = CurTime()

    end)

end)

concommand.Add("pain_effect", function()
    timer.Simple(1, function()
        local old = ScreenspaceEffects.Pain.value
        ScreenspaceEffects.Pain.value = 1
        ScreenspaceEffects.Pain.old_value = old
        ScreenspaceEffects.Pain.last_changed = CurTime()
    end)
end)