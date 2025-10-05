/*
    task its some objective the ply is making and need time for making it

    loosing, salvage

    task = {
        id                                  // dont know about this
        progress_bar_label
        time
        func_success
    }

    ply can make only 1 task
    ply can abort task
    ply can view progress of task, and name

    need shared version?
*/

local PLAYER = FindMetaTable("Player")

// можно конечно по дибильному расшарить эту функцию, но 
// если когда с сервера на клиент придет таск, то клиентский таск идет на отмену 



if CLIENT then
    local clr_outline   = Color(0, 0, 0)
    local clr_back      = Color(128, 128, 128, 128)
    local clr_bar       = Color(220,220,220)

    local bar_width = ScreenScale(150)/ ( ScrW() / ScrH() )
    local bar_height = ScreenScale(20) / ( ScrW() / ScrH() )

    function PaintPBar()
        local task = LocalPlayer().Task
        if !task then return end
        
        local pb_label = task.pb_label
        local start_time = task.start_time
        local time = task.time
        local in_task_time = CurTime() - start_time

        local fract = math.Clamp(in_task_time / time , 0, 1)

        local w, h = ScrW(), ScrH()

        local x = w/2 - (bar_width/2)
        local y = h - (h/3) + (bar_height / 2)


        surface.SetDrawColor(clr_outline)
        surface.DrawOutlinedRect( x, y, bar_width, bar_height, 1 )

        surface.SetDrawColor(clr_bar)
        surface.DrawRect( x + 3 , y + 3, Lerp(fract, 0, bar_width - 6), bar_height - 6 )

    end
end

hook.Add( "StartCommand", "TaskStop", function( ply, cmd )
    if !ply:IsActive() or !ply:Alive() then return end
    if !ply:GetNWBool("HaveTask") then return end

    /*
    if cmd:GetButtons() != 0 then
        ply:ClearTask()
        return
    end
    */

    if cmd:KeyDown(IN_WALK) then
        ply:ClearTask()
        return
    end

end)

function PLAYER:ClearTask()
    timer.Remove("PlyTask:"..self:EntIndex())
    if CLIENT then hook.Remove("HUDPaint", "TaskPB") end
    self.Task = nil
    self:SetNWBool("HaveTask", false)
end

function PLAYER:DoTask(task, from_server)
    if !self:IsActive() then return end
    if self:GetNWBool("HaveTask") then
        print("ply have task", self:GetNWBool("HaveTask"))
        
        if CLIENT and from_server then
            // server tasks have more prioritet
            self:ClearTask()
        else
            
            RichTextPrint("{255 255 255}You already doing smthg!", self)
            self:SetNWBool("HaveTask", false)
            return
        end
    end

    // need validate?
    task.id = task.id or "task"
    task.pb_label = "Working"
    task.time = task.time or 3
    task.start_time = CurTime()
    //task.func = task.func or function() end

    self.Task = task
    
    timer.Create("PlyTask:"..self:EntIndex(), task.time, 1, function()
        if !IsValid(self) then return end
        if !self:IsActive() then self:ClearTask() return end
        if !self:GetNWBool("HaveTask") then self:ClearTask() return end

        if self.Task.func then
            self.Task.func(ply)
        end

        self:ClearTask()
    end)

    if SERVER then
        net.Start("gs_ply_task")
        net.WriteString(task.id)
        net.WriteString(task.pb_label)
        net.WriteFloat(task.time) // max 255 seconds
        net.Send(self)
    else
        hook.Add("HUDPaint", "TaskPB", PaintPBar)
    end

    self:SetNWBool("HaveTask", true)
end

/*
function PLAYER:StageTask()

end
*/
if CLIENT then
    net.Receive("gs_ply_task", function()
        local task = {}

        task.id         = net.ReadString()
        task.pb_label   = net.ReadString()
        task.time       = net.ReadFloat()

        LocalPlayer():DoTask(task, true)
    end)
end


if SERVER then
    concommand.Add("test_task", function(ply)
        ply:DoTask({})
    end)
end