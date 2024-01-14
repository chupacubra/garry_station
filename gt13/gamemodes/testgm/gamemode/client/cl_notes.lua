GS_Notes = {}
GS_Notes.Note = ""

function GS_Notes:Init()
    --self:Add("")
end

function GS_Notes:SetUp()

end

function GS_Notes:Add(text)

end


--[[

Hello im a [b]kaloed[/b]
ya nasral pod [i]tvoy[/i] dver

string = "Hello <p>im</p> a [b]kaloed[/b]"
pattern '<%a+>'

-- part of removing all html tags from client text
"<%a+>(%a+)<%A%a+>", "%1"
"<(%a+)>" "%1"
"</(%a+)>" "%1"

-- now we replacing all BBCode tags with html tags
text = "[b]skibidi[/b]" 
pattern = "%[b%](%a+)%[%/b%]",
replace = [[<strong>%1</strong>]]
--[[

its a key for BBCode - real copy of SS13 papers

--]]