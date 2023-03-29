--[[
    GS_Job:CreateDept("service",{
        name  = "Service",
        color = Color(Gray),
        b_access = 7,
        b_items  = {
            backpack,
            screwdriver,
        }
        b_costum = "model_" -- male07,female08
    })

    GS_Job:Create({
        job = "assistent",
        name = "Assistent",
        
    })









]]

GS_Job = {}
GS_Job.Dept = {}
GS_Job.F_Jobs = {}
GS_Job.Job  = {}


function GS_Job:CreateDept(name, setting)
    if self.Dept[name] then
        GS_MSG("rewrite dept "..name)
    end

    self.Dept[name] = setting
    self.F_Jobs = {}
end

function GS_Job:CreateJob(name, setting)
    if name == nil or setting == nil then
        GS_MSG("no args for creating jobs")
        return false
    end
    
    if setting.dept == nil or setting then
        GS_MSG("unable to create job for dept "..tostring(setting.dept).." don't have this dept")
        return false
    end

    if self.Job[name] then
        GS_MSG("rewrite job "..name)
    end

    self.Job[name] = name
    self.F_Jobs[setting.dept][name] = true 
end
