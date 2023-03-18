GS_Task = {}
GS_Task.Tasks_Active = {}
GS_Task.Tasks_Active.Tasks = {}
GS_Task.Entity_Tasks = {}
--[[
    !TASK!

    whan you screw send client
     _________
    |///______| -- progress bar!

    synchronise 2 sec
    check if serv_time-cl_time > 0.1
        cl_time = serv_time

    callbacks = {
        succes function()
        unsucces function()
        accidentaly function() -- you cut self finger,  needflag 
    }

    flags = {
        nomove = canmove/nomove -- check if yo move -> unsucces
        freeze = freezeply/nofreeze
        fixweapon = canchangetrowcurrentweapon/weldweaponinhands, false/weapon
        onlyoneply = if ply make task and 2 ply want make task on entity -> "Some people already make for entity"
        accident = % for accidentaly
    }

    GS_Task.Tasks_Active = {
        Players = {
            [1]Chupa = {
                id = {
                    1
                }
            }
        }
        Tasks   = {
            1 = {
                name = "screw_machine",
                entity =  [145][machine_casing],
                flags = {
                    fixweapon = [screwdriver]
                    no_move = true
                }
                callbacks = {
                    success = createMachine function()
                    unsucces = stopMakeMachine function()
                }
            }
        }
    }

    GS_Task.Entity_Task = {
        someenity = {
            tasks_id = {
                name_1 = {1,3,4}
            }
        }
    }

    WHEN 1 entity, and 1>ply making tasks
        when task maked stop for other (if doing same task)

    {
        succes = function(ply, ent)
            ply:ChatPrint("succes!!11")
            ent:ScrewdriverDo()
        end
    }
]]

function GS_Task:GetTask(id)
    return self.Tasks_Active.Tasks[id]
end


function GS_Task:FinishTask(id) -- succes
    self:RunCallback(id, "succes")
    print("finish")
    self:RemoveTask(id)
end

function GS_Task:StopTask(id) -- unsucces 
    self:RunCallback(id, "unsucces")
    print("unfichi")
    self:RemoveTask(id)
end

function GS_Task:RunCallback(id, func)
    local task = self:GetTask(id)
    
    if !task then
        return
    end
    
    if !IsValid(task.ply) then
        return
    end

    local callback = task.callbacks[func]
    
    if !callback then
        return
    end

    callback(task.ply, task.ent)
end

function GS_Task:RemoveTask(id)
    debug.Trace()
    local task = self:GetTask(id)
    
    if task == nil then
        return
    end
    
    self:Client_EndTask(id)
    self.Tasks_Active.Tasks[id] = nil
    print(id)
    PrintTable(self.Tasks_Active)
    if task.entity then
        table.RemoveByValue(self.Entity_Tasks[task.entity][task.name], id)
    end
    
end

function GS_Task:StartGlobalThink()
    --[[
        creating hook.think
    ]]
    hook.Add("Think", "GS_TasksTimers", function()
        --print("make tasksk")
        --PrintTable(self.Tasks_Active)
        if #GS_Task.Tasks_Active.Tasks == 0 then
            self:StopGlobalThink()
            return
        end

        for k,v in pairs(self.Tasks_Active.Tasks) do

            if !IsValid(v.ply) then
                self:RemoveTask(k)
                continue
            end

            local cont = self:CheckTaskFlag(k)
            --print(cont)
            if !cont then
                self:StopTask(k)
                continue
            end
            --print(v.time_end , CurTime())
            if v.time_end < CurTime() then
                self:FinishTask(k)
                continue
            end

        end
    end)
end

function GS_Task:StopGlobalThink() --we don't need think, when no tasks
    hook.Remove("Think","GS_TasksTimers")
end

function GS_Task:CreateNew(ply, task_name, time, ent, callbacks, flags, progressbar_text)
    if !IsValid(ply) then
        return false
    end

    local t_start = CurTime()
    local t_stop  = CurTime() + time 
    
    local task = {
        name       = task_name,
        ply        = ply,
        time_start = t_start,
        time_end   = t_stop,
        time_do    = time,
        entity     = ent,
        callbacks  = callbacks,
        flags      = flags,
    }

    local succes = self:Predstart_Check(task)
    print(succes)
    if succes then
        local flag_data = self:Prepare_FlagData(task)
        task["flag_data"] = flag_data

        local id = table.insert(self.Tasks_Active.Tasks, task)
        
        if ent != nil then
            if !self.Entity_Tasks[ent] then
                self.Entity_Tasks[ent] = {}
                self.Entity_Tasks[ent][task_name] = {id}
            else
                if !self.Entity_Tasks[ent][task_name] then
                    self.Entity_Tasks[ent][task_name] = {id}
                else
                    table.insert(self.Entity_Tasks[ent][task_name],id)
                end
            end
        end

        self:RunCallback(id, "start")
        self:Client_StartTask(id, progressbar_text)
        self:StartGlobalThink()
    else
        return false
    end
end

function GS_Task:Predstart_Check(task)
    -- check flag onlyone
    if task.flags["onlyone"] == true then
        if !self.Entity_Tasks[task.entity] then
            return true
        elseif !self.Entity_Tasks[task.entity][task_name] then
            return true
        else
            return false
        end
    end
    return true

end

function GS_Task:Prepare_FlagData(task)
    local flag_data = {}

    for k,v in pairs(task.flags) do
        if v then
            flag_data[k] = true
        end
    end

    if flag_data["no_move"] then
        flag_data["no_move"] = {
            ply_pos = task.ply:GetPos()
        }
    end

    --[[
        anothers
    ]]


    return flag_data
end

function GS_Task:CheckTaskFlag(id) -- check execution
    local task = self:GetTask(id)

    if task.flags["no_move"] then
        local task_pos = task.flag_data.no_move.ply_pos
        if task_pos != task.ply:GetPos() then
            return false
        end
    end

    return true
end

function GS_Task:RemoveTasksForEntity(ent, name)

end

function GS_Task:Client_StartTask(id, p_text)
    local task = self:GetTask(id)

    net.Start("gs_sys_task_send")
    net.WriteUInt(id, 8)
    net.WriteUInt(task.time_do, 8)
    net.WriteString(p_text or "...")
    net.Send(task.ply)
end

function GS_Task:Client_EndTask(id)
    local task = self:GetTask(id)

    net.Start("gs_sys_task_end")
    net.WriteUInt(id, 8)
    net.Send(task.ply)
end