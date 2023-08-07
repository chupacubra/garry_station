CButtons = {}

-- don't know i need it

function CButtons.New(name, icn, func)
    return {
        label = name,
        icon  = icn,
        click = func()
    }
end

function CButtons.ExamineSWEP(swep)
    return {
        label = "Examine item",
        icon  = "icon16/eye.png",
        click = function()
            local examine = self:Examine()
            for k,v in pairs(examine) do
                if k == 1 then
                    v = "It is ".. v
                end
                LocalPlayer():ChatPrint(v)
            end
        end
    }
end

function CButtons.ExamineItem(entity)
    return {
        label = "Examine item",
        icon  = "icon16/eye.png",
        click = function()
            local examine = self:Examine()
            for k,v in pairs(examine) do
                if k == 1 then
                    v = "It is ".. v
                end
                LocalPlayer():ChatPrint(v)
            end
        end
    }
end