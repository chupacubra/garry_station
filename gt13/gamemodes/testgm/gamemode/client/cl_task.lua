CL_GS_Tasks = {}
CL_GS_Tasks.MyTasks = {}

function CL_GS_Tasks:GetProgressBarPos(tid)

end

function CL_GS_Tasks:CreateProgressBar(tid)
    local task = self.MyTasks[tid]

    local start = CurTime()

    local H = ScrH()
    local W = ScrW()

    hook.Add( "HUDPaint", task.hookName, function()
        draw.RoundedBox( 2, (W/2)-100, (H/2)+150+(25*(tid-1)) , Lerp( (CurTime() - start)/ task.time , 0, 200 ), 20, Color(25,25,175,200) )
        surface.SetFont( "TargetID" )
        surface.SetTextColor( 255, 255, 255 )
        surface.SetTextPos( (W/2)-100, (H/2)+150+(25*(tid-1))) 
        surface.DrawText( task.text )
    end )
end

function CL_GS_Tasks:RemoveProgressBar(tid)
    hook.Remove("HUDPaint", self.MyTasks[tid]["hookName"])
end

function CL_GS_Tasks:NewTask(id, time, p_text)
    local tocken = "GS_Task_ProgressBarID"..gentocken()
    local task = {
        time = time,
        text = p_text,
        id   = id,
        hookName = "GS_Task_ProgressBarID"..gentocken() -- wtf i dont know
    }
    local tid = table.insert(self.MyTasks, task)

    self:CreateProgressBar(tid)
end

function CL_GS_Tasks:RemoveTask(tid)
    print("END TASK")
    local kt
    for k,v in pairs(self.MyTasks) do
        if v.id == tid then
            kt = k
        end
    end

    if !kt then
        return
    end

    timer.Simple(1, function()
        self:RemoveProgressBar(kt)
        self.MyTasks[kt] = nil
    end)
end

net.Receive("gs_sys_task_send", function()
    local id     = net.ReadUInt(8)
    local time   = net.ReadUInt(8)
    local p_text = net.ReadString()

    CL_GS_Tasks:NewTask(id, time, p_text)
end)

net.Receive("gs_sys_task_end", function()
    local id     = net.ReadUInt(8)

    CL_GS_Tasks:RemoveTask(id)
end)