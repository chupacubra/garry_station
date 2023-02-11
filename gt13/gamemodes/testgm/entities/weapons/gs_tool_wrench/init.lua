AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + 0.5 ) 
    local trace = self:MakeTrace()
    
    self:SwingAnim(trace.Hit)
    self:SoundHit(trace.Hit)

    local entity = trace.Entity
    
    if !entity:IsValid() then

        return
    end

    if entity:IsPlayer() then
        -- punch human
        return
    end

    local class = entity:GetClass()
    if class == "gs_entity_base" or class == "gs_entity_base_container" then
        local succes, text =  entity:Wrench(self:GetOwner())
        if succes and text then
            self:GetOwner():ChatPrint(text)
        end
    end
end

function SWEP:SecondaryAttack()
end


