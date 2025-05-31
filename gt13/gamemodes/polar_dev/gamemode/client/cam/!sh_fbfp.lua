if CLIENT and LocalPlayer ~= nil then
    local nearz
	local plymodel
	local shrunkbones = {}
    local timeSight = 0.5
    local mins, maxs = Vector( -5, -5, -5 ), Vector( 5, 5, 5 )

    local function init()
        hook.Remove("CalcView", "FPCalcView")
        hook.Remove("ShouldDrawLocalPlayer", "FPShouldDrawLocalPlayer")
        hook.Remove("CreateMove", "FPCreateMove")
        CreateClientConVar("fp", Entity(0):GetNWInt("fp_enabledbydefault", -1), false)
        CreateClientConVar("fp_complexity", 0, true)
        CreateClientConVar("fp_nearz", 1, true)
        //chat.AddText("Ott's Full Body First Person loaded! Run \"fp 1\" in the console to enable.")

        local realang = LocalPlayer():EyeAngles()
        local prevang = realang
        local viewpos = LocalPlayer():GetShootPos()
        local complexity = tonumber(GetConVarNumber("fp_complexity"))
        local sightStart = false
        local timeToSight  = 0
        local sighting = false
        local timeSightStart = 0

        nearz = GetConVarNumber("fp_nearz")

        local function GetRealEyeTrace(pos)
            local td = {}
            td.start = viewpos
            td.endpos = pos or viewpos + realang:Forward() * 23170 --Hypoteneus of maximum map size (yes I know it's only 2d shut up)
            td.filter = {LocalPlayer(), LocalPlayer():GetVehicle()}
            local tr = util.TraceLine(td)
            return tr
        end 

		local function shrinkbones(bone)
			for k, v in pairs(LocalPlayer():GetChildBones(bone)) do
				shrinkbones(v) --Should stop when table is empty
			end
			if not shrunkbones[bone] then
				shrunkbones[bone] = LocalPlayer():GetManipulateBoneScale(bone)
			end
			LocalPlayer():ManipulateBoneScale(bone, Vector(0, 0, 0))
		end

		local function restorebones()
			for bone, vec in pairs(shrunkbones) do
				LocalPlayer():ManipulateBoneScale(bone, vec)
				shrunkbones[bone] = nil
			end
		end

        local function MyCalcView( ply, pos, angles, fov )
			if plymodel ~= ply:GetModel() then
				plymodel = ply:GetModel()
				restorebones()
			end
            if ply:GetViewEntity() == ply and ply:Alive() then
                local view = {}
                local hat = ply:LookupBone("ValveBiped.Bip01_Head1") or 6
                hatpos, hatang = ply:GetBonePosition(hat)
                hatpos = hatpos or LocalPlayer():GetShootPos()
				shrinkbones(hat)

                campos = hatpos  + angles:Up() * 5

                local weap = ply:GetActiveWeapon()

                if weap then
                    if weap.Zoom and !sightStart then
                        sightStart = true
                        timeSightStart = SysTime()
                        //print("Time to Sight")
                    elseif !weap.Zoom and sightStart then
                        timeSightStart = SysTime()
                        sightStart = false
                        //print("Time to unsight")
                    end
                end

                local hand = ply:LookupBone("ValveBiped.Bip01_R_Hand")
                local handPos, handAng = ply:GetBonePosition(hand)
                //campos = LocalToWorld( weap.SightPos, weap.SightAng, handPos, handAng)

                if weap.Zoom then
                    campos = LocalToWorld( weap.SightPos, weap.SightAng, handPos, handAng)
                    //print(timeSightStart, timeSightStart + timeSight,timeSight < CurTime())
                    if timeSightStart + timeSight > SysTime()  then
                        campos = Lerp( ( SysTime() - timeSightStart ) / timeSight, viewpos, campos )
                    end
                    //realang = realang + weap.SightAng
                
                    local gunang = handAng

                    local trace = util.TraceLine({
                        start = handPos + weap.WorldModelOffsets.pos,
                        endpos = handPos + gunang:Forward()*10000
                    })
                    //debugoverlay.Line( handPos + weap.WorldModelOffsets.pos, trace.HitPos, 1, nil , true)
                else
                    if timeSightStart + timeSight > SysTime()  then
                        campos = Lerp( ( SysTime() - timeSightStart ) / timeSight, viewpos, campos )
                    end
                end
                //local realang = LocalPlayer():EyeAngles()
                view.origin = campos
                viewpos = view.origin

                handAng = handAng + Angle(0,0,180)

                if weap.Zoom then
                    view.angles = realang//realang + weap.SightAng 
                else
                    view.angles = realang
                end
                view.znear = nearz
                
                local trace = util.TraceLine({
                    start = view.origin,
                    endpos = view.origin + view.angles:Forward()*10000
                })
                //debugoverlay.Line( view.origin, trace.HitPos, 1, nil )
                return view
            else
				restorebones()
            end
        end


        local function MyCreateMove(cmd)
            realang = realang + cmd:GetViewAngles() - prevang
            realang:Normalize()
            if realang.p > 89 then realang.p = 89 elseif realang.p < -89 then realang.p = -89 end
            if complexity >= 1 then

                local tr = GetRealEyeTrace()
                local targetang = (tr.HitPos - LocalPlayer():GetShootPos()):Angle()
                if complexity == 2 then
                    local tr2 = LocalPlayer():GetEyeTrace()
                    local hitpos = tr2.HitPos - LocalPlayer():GetShootPos()
                    hitpos.z = 0
                    local vpos = viewpos - LocalPlayer():GetPos()
                    vpos.z = 0
                    if vpos:Length() > hitpos:Length() then
                        local newang = (Vector(vpos:Length(), 0, 0) - LocalPlayer():GetShootPos()):Angle()
                        newang.y = 0
                        newang.r = 0
                        realang = realang + (realang.p < 0 and -newang or newang)
                    end

                end
                cmd:SetViewAngles(targetang)
            end
            prevang = cmd:GetViewAngles()
        end


        local function MyDrawPlayer( ply )
            return true
        end


        local function MyCamera(ply)
            if ply:GetViewEntity() == ply then
                ply:SetNoDraw(true)
                timer.Simple(1, function()
                    ply:SetNoDraw(false)
                end)
            end
        end


        if GetConVarNumber("fp") ~= 0 then
            hook.Add("CalcView", "FPCalcView", MyCalcView )
            hook.Add("ShouldDrawLocalPlayer", "FPShouldDrawLocalPlayer",  MyDrawPlayer)
            hook.Add("CreateMove", "FPCreateMove", MyCreateMove)
            hook.Add("CameraTakePicture", "FPCam", MyCamera)
            chat.AddText("Full Body First Person enabled! To disable, run \"fp 0\".\nIf FBFP is laggy, then change fp_complexity to a lower value.\n\nfp_complexity 0 is the simplest mode but offers no aim correction.\nfp_complexity 1 corrects the aim, but introduces a feedback loop if you look down while using certain weapons.\nfp_complexity 2 corrects the aim and prevents feedback loops.")
        end

        cvars.AddChangeCallback("fp", function()
            local new = tonumber(GetConVarNumber("fp"))
            if new ~= 0 then
                hook.Add( "CalcView", "FPCalcView", MyCalcView )
                hook.Add( "ShouldDrawLocalPlayer", "FPShouldDrawLocalPlayer",  MyDrawPlayer)
                hook.Add("CreateMove", "FPCreateMove", MyCreateMove)
                hook.Add("CameraTakePicture", "FPCam", MyCamera)
                chat.AddText("Full Body First Person enabled! To disable, run \"fp 0\" in the console.\nIf FBFP is laggy, then change fp_complexity to a lower value.\n\nfp_complexity 0 is the simplest mode but offers no aim correction.\nfp_complexity 1 corrects the aim, but introduces a feedback loop if you look down while using certain weapons.\nfp_complexity 2 corrects the aim and prevents feedback loops.")
            else
                hook.Remove("CalcView", "FPCalcView")
                hook.Remove("ShouldDrawLocalPlayer", "FPShouldDrawLocalPlayer")
                hook.Remove("CreateMove", "FPCreateMove")
                hook.Remove("CameraTakePicture", "FPCam")
                chat.AddText("Full Body First Person disabled.")
                LocalPlayer():ManipulateBoneScale(LocalPlayer():LookupBone("ValveBiped.Bip01_Head1") or 6, Vector(1, 1, 1))
            end
        end)

        cvars.AddChangeCallback("fp_complexity", function()
            local c = tonumber(GetConVarNumber("fp_complexity"))
            c = tonumber(c)
            c = c >= 0 and c or 0
            c = c <= 2 and c or 2
            complexity = tonumber(c)
        end)

        cvars.AddChangeCallback("fp_nearz", function()
            nearz = GetConVarNumber("fp_nearz")
            if nearz > 25 then
                nearz = 25
                RunConsoleCommand("fp_nearz", 25)
            end
            if nearz < 1 then
                nearz = 1
                RunConsoleCommand("fp_nearz", 1)
            end
        end)

    end

    local function retry()
        if LocalPlayer() == NULL then
            timer.Simple(1, retry)
        else
            init()
        end
    end

    retry()

    local function populate()
        spawnmenu.AddToolMenuOption("Options", "Player", "fbfp_control", "Full Body First Person", "", "", function(panel)
            panel:AddControl("Header", {Text = "Full Body First Person", Description = "Gives you a lower body"})
            panel:AddControl("CheckBox", {Label = "Enabled", Command = "fp"})
            panel:AddControl("Slider", {Label = "Complexity", Type = "Int", Min = 0, Max = 2, Comamnd = "fp_complexity"})
            panel:AddControl("Slider", {Label = "NearZ", Type = "Float", Min = 1, Max = 25, Command = "fp_nearz"})
        end)
    end

    hook.Add("PopulateToolMenu", "fbfp_tm", populate)
end
if SERVER then
    //CreateConVar("fp_enabledbydefault", 1, FCVAR_ARCHIVE + FCVAR_SERVER_CAN_EXECUTE, "Enable Full Body First Person on new players by default")
    //Entity(0):SetNWInt("fp_enabledbydefault", GetConVarNumber("fp_enabledbydefault"))
    //cvars.AddChangeCallback("fp_enabledbydefault", function(name, old, new)
    //    Entity(0):SetNWInt("fp_enabledbydefault", GetConVarNumber("fp_enabledbydefault"))
    //end)
end

