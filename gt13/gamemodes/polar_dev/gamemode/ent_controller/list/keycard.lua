local Base = {}

Base.Base = "gs_entity"

Base.Name  = "Keycard"
Base.Desc  = "The way to open doors"
Base.Model = "models/bkeycardscanner/w_keycard.mdl"
Base.Size  = ITEM_SMALL

Base.Spawnable = true
Base.Category = "Developing"


function Base:Examine()
    RichTextPrint("It's a {255 255 255}"..self.Name)
    RichTextPrint("{255 255 255}"..self.Desc)
end

function Base:SetupNWVars()
    self:NetworkVar("Int", 0, "Access")

    self:NetworkVar("String", 0, "Department")
    self:NetworkVar("String", 1, "Post")
    self:NetworkVar("String", 2, "OwnerName")
end

local show_radius = 200
function Base:ShowCard(owner, ply)
    // show a card
    if CLIENT then
        RichTextPrint("You are showing your access card...")
        return
    end
    
    local text_show = "You were shown an access card:\n"..self:GetDepartment().."\n"..self:GetPost().."\n"..self:GetOwnerName()

    if !ply then
        util.FindCloserPlysAndRun(show_radius, function(ply)
            if ply == owner then return end
            RichTextPrint(text_show, ply)
        end)
    else
        RichTextPrint(text_show, ply)
    end
end

function Base:GetKeyData()
    return {
        access = self:GetAccess(),
        department = self:GetDepartment(),
        post = self:GetDepartment(),
        ownerName = self:GetOwnerName()
    }
end

function Base:ItemPrimary(owner)
    if ply:KeyPressed(IN_WALK) then
        // show closer plys
        self:ShowCard(owner)
    else
        // show only for one
        local tr = owner:MakeTrace(show_radius)
        local target = tr.Entity
        if !IsValid(target) then return end
        if !target:IsPlayer() then return end
        
        self:ShowCard(owner, target)
    end
end
