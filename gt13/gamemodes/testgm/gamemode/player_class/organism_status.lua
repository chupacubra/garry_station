local organism_status_list = {
    heart_failure = {
        start_function = function(self)
            -- print(cheto vam nehorosho)
            -- start slow
            self:EffectSpeedAdd("heart_failure",-150, -250)
        end,
        end_function = function(self) 
            self:EffectSpeedRemove("heart_failure")
        end,
        think_function = function(self)
            self:DamageHypoxia(4)
        end
    },

    stamina_crit = {
        start_function = function(self)
            self:EffectSpeedAdd("stamina_crit",-100, -200)
            self:CritParalyze(5)
            
            timer.Simple(5, function()
                --[[
                    remove self
                ]]
            end)
        end,
        end_function = function(self)
            self:EffectSpeedRemove("stamina_crit")
            --[[
                if stamina < 0:
                    stamina = 0
            ]]
        end,
        think_function = function(self)

        end
    },

    bleeding = {
        start_function = function(self)
            --[[
                if self already have bleeding:
                    add some int to bleed_rate
            ]]
        end,
        end_function = function(self) 
            
        end,
        think_function = function(self)
            --[[
                blood -= bleedrate
            ]]
        end
    }
} 