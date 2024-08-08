--[[
    GS_Job:CreateDept("service",{
        name  = "Service",
        color = Color(Gray),
        b_access = 7,
        b_items  = {
            backpack = {
                id = {"backpack_simple"},
                contain = {
                    {"data", "label"},
                    {},
                    {},
                },
            },

            pockets = {{"swep","screwdriver"}, {"swep", "knife"}}
            suit = "casual"
        }
    })

    GS_Job:Create({
        job = "assistent",
        name = "Assistent",
        
    })

    need shared version
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
    self.F_Jobs[name] = {}
end

function GS_Job:CreateJob(name, setting)
    if name == nil or setting == nil then
        GS_MSG("no args for creating jobs")
        return false
    end
    
    if setting.dept == nil or !self.Dept[setting.dept]  then
        GS_MSG("unable to create job for dept "..tostring(setting.dept).." don't have this dept")
        return false
    end

    self.Job[name] = setting
    self.F_Jobs[setting.dept][name] = true 
end

function GS_Job:GetDept(job)
    for k, v in pairs(self.F_Jobs) do
        if v[job] then
            return k
        end
    end

    return false
end

function GS_Job:GetDeptData(job)
    return self.Dept[self.Job[job]["dept"]]
end

function GS_Job:GetDeptDataD(dept)
    return self.Dept[dept]
end

function GS_Job:GetChoosenJob(name)
    return self.Job[name]
end

function GS_Job:GetDeptName(dept)
    return self.Dept[dept]["name"]
end

function GS_Job:GetAccess(job_name)
    return self.Job[job_name]["access"] or self.Dept[self.Job[job_name]["dept"]]["b_access"]
end

function GS_Job:GetColor(job)
    return self.Dept[self.Job[job_name]["dept"]]["color"]
end

function GS_Job:GetJobName(job)
    debug.Trace()
    print(job)
    return self.Job[job]["name"]
end
--[[
function GS_Job:GetJobData(job)
    return self.Job[job]
end
--]]

function GS_Job:GiveJobItem(ply, job)
    --timer.Simple(1.1, function()
        local deptData = self:GetDeptData(job)
        local jobItems = deptData.b_items

        GS_EntityControler.GiveItemFromArray(ply, jobItems)

        GS_ID:PrestartID(ply, job)
    --end)
end

function GS_Job:GivePlyJob(ply, job)
    local token = GS_PLY_Char:GetPlyChar(ply)
    GS_Info_DB:CrewChangeJob(token, self:GetJobName(job)) -- update db
end