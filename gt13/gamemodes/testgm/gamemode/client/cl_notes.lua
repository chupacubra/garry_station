GS_Notes = {}
GS_Notes.NoteText = "[b]My notes[/b]"
function GS_Notes:Init()
    self.NoteText = "[b]My notes[/b]"
end

--[[
    tbl = {
        name = "Skibidi Tualetovich",
        antag = "nil",
        antag_obj = {},
        id_acc(?) = 123123,
        obj = {}, 
    }
--]]

function GS_Notes:SetUp(tbl)
    -- add some data about character, objection, targets...
end

function GS_Notes:Add(text, id)
    self.NoteText = PWork:Proccesing(self.NoteText, text, id, LocalPlayer())

    if IsValid(self.Note) then
        self.Note:UpdateText(self.NoteText)
    end
end

function GS_Notes:View()
    if IsValid(self.Note) then return end
    self.Note = CL_PW:ShowPaper(self.NoteText, "My notes", nil, function(text, id) GS_Notes:Add(text, id) end)
end
