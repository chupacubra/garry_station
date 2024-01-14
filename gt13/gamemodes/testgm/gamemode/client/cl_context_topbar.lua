-- here be a topbar for some func
-- craft,
-- notes (if you a have dementia),
-- ooc (ex make a admin report)
-- ic(some does)
-- taunt
-- some hl2 person sounds(cry, cheese)

TopBar = {}
TopBar.Buttons = {}

function TopBar:Init()
    self.Bar = vgui.Create( "DMenuBar", frame )
    self.Bar:DockMargin( 0, 0, 0, 0 )
    
    self:Build()
end

function TopBar:Build()
    local function createsub(parrent, child)
        for k, v in pairs(child) do -- rooooot
            for kk,vv in pairs(v) do
                PrintTable(v)
                if vv.func then
                    parrent:AddOption(vv.nice, vv.func)
                elseif vv.array then
                    local sub, _ = parrent:AddSubMenu(vv.nice)
                    createsub(sub, vv.array)
                end
            end
        end

    end

    self.ButtonsMenu = {}

    for k, v in pairs(self.Buttons) do
        local m = self.Bar:AddMenu(v.nice)

        if v.func then
            local b = self.Bar:GetChild(k-1)
            b.DoClick = v.func
        elseif v.array then
            print(v.nice)
            createsub(m, v.array)
        end
    end

    --PrintTable(self.Bar:GetChildren()
end

function TopBar:Reload()

end

function TopBar:Close()
    self.Bar:Remove()
end

-- TopBar:AddButton("Cool strange button", function() ... end)
function TopBar:AddButton(label, fun)
    table.insert(self.Buttons, {
        nice = label,
        func = fun,
    })
end

--[[
    TopBar:AddSubButton("Mega button", tbl)

    structure of table
    
    {
     --root
      { -- some unification of buttons, he separated with spacers
        button,
        button,
        ...
      }
    }

    structure of button:
    {
        nice = "str"
        func OR array
        if type == "submenu" then
            array = {
                button,
                button,
                ...
            }
        elseif type == "func" then
            function() ... end
        end
    }
--]]
function TopBar:AddSubButton(label, arr)
    table.insert(self.Buttons, {
        nice = label,
        array = arr,
    })
end

TopBar:AddButton("Craft", function() print("shhiiiiieeet") end)
TopBar:AddButton("Emotions", function() end)
TopBar:AddButton("IC", function() print("toieled") end)
TopBar:AddButton("OOC", function() print("toieled") end)
TopBar:AddSubButton("Help", {
    {
        {
            nice = "Open help reference ",
            func = function()
                print("NAZRAl")
            end,
        },
        {
            nice = "About",
            func = function()
                print("NAZRAl X2")
            end
        }
    }
})