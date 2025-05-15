

-- 1인칭 풀바디 시점 설정
local enableFirstPerson = true -- 1인칭 모드 활성화 여부
local customFOV = 100 -- 기본 FOV 값
local customPitchMin, customPitchMax = -90, 90 -- 시야 제한
local customYawMin, customYawMax = -360, 360
local customForwardOffset, customUpOffset = -2, 5 -- 뷰 오프셋
local enableHeadScale = true -- 머리 크기 조정 활성화 여부

-- 설정 저장 함수
local function SaveSettings()
    if not file.Exists("fullbody_settings", "DATA") then
        file.CreateDir("fullbody_settings")
    end
    file.Write("fullbody_settings/settings.txt", util.TableToJSON({
        fov = customFOV,
        pitchMin = customPitchMin,
        pitchMax = customPitchMax,
        yawMin = customYawMin,
        yawMax = customYawMax,
        forwardOffset = customForwardOffset,
        upOffset = customUpOffset,
        headScale = enableHeadScale,
        firstPerson = enableFirstPerson
    }))
end

-- 설정 로드 함수
local function LoadSettings()
    if file.Exists("fullbody_settings/settings.txt", "DATA") then
        local data = util.JSONToTable(file.Read("fullbody_settings/settings.txt", "DATA"))
        if data then
            customFOV = data.fov or customFOV
            customPitchMin = data.pitchMin or customPitchMin
            customPitchMax = data.pitchMax or customPitchMax
            customYawMin = data.yawMin or customYawMin
            customYawMax = data.yawMax or customYawMax
            customForwardOffset = data.forwardOffset or customForwardOffset
            customUpOffset = data.upOffset or customUpOffset
            enableHeadScale = data.headScale ~= nil and data.headScale or enableHeadScale
            enableFirstPerson = data.firstPerson ~= nil and data.firstPerson or enableFirstPerson
        end
    end
end

LoadSettings()

-- 명령어 추가
concommand.Add("set_fov", function(ply, cmd, args)
    local newFOV = tonumber(args[1])
    if newFOV then
        customFOV = newFOV
        SaveSettings()
        print("FOV updated: " .. customFOV)
    else
        print("Invalid FOV value. Please enter a number.")
    end
end)

concommand.Add("set_pitch", function(ply, cmd, args)
    local minPitch = tonumber(args[1])
    local maxPitch = tonumber(args[2])
    if minPitch and maxPitch then
        customPitchMin = minPitch
        customPitchMax = maxPitch
        SaveSettings()
        print("Pitch updated: Min = " .. customPitchMin .. ", Max = " .. customPitchMax)
    else
        print("Invalid Pitch values. Please enter two numbers.")
    end
end)

concommand.Add("set_yaw", function(ply, cmd, args)
    local minYaw = tonumber(args[1])
    local maxYaw = tonumber(args[2])
    if minYaw and maxYaw then
        customYawMin = minYaw
        customYawMax = maxYaw
        SaveSettings()
        print("Yaw updated: Min = " .. customYawMin .. ", Max = " .. customYawMax)
    else
        print("Invalid Yaw values. Please enter two numbers.")
    end
end)

concommand.Add("set_view_offset", function(ply, cmd, args)
    local forwardOffset = tonumber(args[1])
    local upOffset = tonumber(args[2])
    if forwardOffset and upOffset then
        customForwardOffset = forwardOffset
        customUpOffset = upOffset
        SaveSettings()
        print("View offset updated: Forward = " .. customForwardOffset .. ", Up = " .. customUpOffset)
    else
        print("Invalid View offset values. Please enter two numbers.")
    end
end)

concommand.Add("toggle_first_person", function(ply, cmd, args)
    enableFirstPerson = not enableFirstPerson
    SaveSettings()
    print("First person mode toggled: " .. (enableFirstPerson and "Enabled" or "Disabled"))
end)

concommand.Add("toggle_head_scale", function(ply, cmd, args)
    enableHeadScale = not enableHeadScale
    SaveSettings()
    print("Head scale toggled: " .. (enableHeadScale and "Enabled" or "Disabled"))
end)

-- UI 설정
hook.Add("PopulateToolMenu", "FullBodyFirstPersonSettings", function()
    spawnmenu.AddToolMenuOption("Options", "First Person", "First Person Settings", "Settings", "", "", function(panel)
        panel:ClearControls()
        panel:Help("First Person Full Body Settings")

        local firstPersonCheckbox = panel:CheckBox("Enable First Person Mode", "")
        firstPersonCheckbox:SetChecked(enableFirstPerson)
        firstPersonCheckbox.OnChange = function(_, value)
            enableFirstPerson = value
            SaveSettings()
        end

        local fovSlider = panel:NumSlider("FOV", "", 1, 300, 0)
        fovSlider:SetValue(customFOV)
        fovSlider.OnValueChanged = function(_, value)
            customFOV = value
            SaveSettings()
        end

        -- Pitch Min 슬라이더 추가
        local pitchMinSlider = panel:NumSlider("Pitch Min", "", -90, 0, 0)
        pitchMinSlider:SetValue(customPitchMin)
        pitchMinSlider.OnValueChanged = function(_, value)
            customPitchMin = value
            SaveSettings()
        end

        -- Pitch Max 슬라이더 추가
        local pitchMaxSlider = panel:NumSlider("Pitch Max", "", 0, 90, 0)
        pitchMaxSlider:SetValue(customPitchMax)
        pitchMaxSlider.OnValueChanged = function(_, value)
            customPitchMax = value
            SaveSettings()
        end

        local forwardOffsetSlider = panel:NumSlider("Forward Offset", "", -50, 50, 0)
        forwardOffsetSlider:SetValue(customForwardOffset)
        forwardOffsetSlider.OnValueChanged = function(_, value)
            customForwardOffset = value
            SaveSettings()
        end

        local upOffsetSlider = panel:NumSlider("Up Offset", "", -50, 50, 0)
        upOffsetSlider:SetValue(customUpOffset)
        upOffsetSlider.OnValueChanged = function(_, value)
            customUpOffset = value
            SaveSettings()
        end

        local headScaleCheckbox = panel:CheckBox("Enable Head Scale", "")
        headScaleCheckbox:SetChecked(enableHeadScale)
        headScaleCheckbox.OnChange = function(_, value)
            enableHeadScale = value
            SaveSettings()
        end
    end)
end)

-- CalcView 훅
hook.Add("CalcView", "FullBodyFirstPersonView", function(ply, pos, angles, fov)
    if not IsValid(ply) or not ply:Alive() or ply ~= LocalPlayer() or not enableFirstPerson then return end

    local headPos = pos
    if IsValid(ply) then
        local headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            local bonePos = ply:GetBonePosition(headBone)
            if bonePos then
                headPos = bonePos
                if enableHeadScale then
                    ply:ManipulateBoneScale(headBone, Vector(0, 0, 0)) -- 머리 숨기기
                else
                    ply:ManipulateBoneScale(headBone, Vector(1, 1, 1)) -- 원래 크기로 복원
                end
            end
        end
    end

    local limitedAngles = Angle(
        math.Clamp(angles.p, customPitchMin, customPitchMax),
        math.Clamp(angles.y, customYawMin, customYawMax),
        angles.r
    )

    local view = {}
    view.origin = headPos + limitedAngles:Forward() * customForwardOffset + limitedAngles:Up() * customUpOffset
    view.angles = limitedAngles
    view.fov = customFOV
    view.drawviewer = true

    return view
end)

-- 머리 관련 추가 코드
function RagdollOwner(rag)
    if not IsValid(rag) then return end

    local ent = rag:GetNWEntity("RagdollController")

    return IsValid(ent) and ent
end

net.Receive("pophead",function(len)
    local rag = net.ReadEntity()
    if rag:IsValid() then
        rag:ManipulateBoneScale(6,Vector(1,1,1)) -- 머리 크기 조정
    end
end)

hook.Add("Think","pophead",function()
    for i,ent in pairs(ents.FindByClass("prop_ragdoll")) do
        if not IsValid(RagdollOwner(ent)) or not RagdollOwner(ent):Alive() then
            ent:ManipulateBoneScale(6,Vector(1,1,1)) -- 머리 크기 복원
        end
    end
end)

local ply = LocalPlayer()
if IsValid(ply) and ply:Alive() then
    local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
    if bone then
        ply:ManipulateBoneScale(bone, enableFirstPerson and Vector(0,0,0) or Vector(1,1,1))
    end
end

net.Receive("nodraw_helmet",function()
    helmEnt = net.ReadEntity()
end)
