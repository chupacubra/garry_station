AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Swing(trace)
	local entity = trace.Entity

	if !trace.Hit then
		return
	end

    if !entity:IsValid() then
        return
    end

	if entity:IsPlayer() then
		self:HitPlayer(entity, trace.PhysicsBone)
        return
    end


    local class = entity:GetClass()

    if entity.Screwdriver != nil then
        local succes, text =  entity:Screwdriver(self:GetOwner())
        print("screw")

        if succes and text then
            self:GetOwner():ChatPrint(text)
        end
    end
end

