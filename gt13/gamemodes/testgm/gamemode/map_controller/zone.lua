Zone_meta = {}

--[[
	ZONES!
]]
if CLIENT then

	D_Zones = {}

	net.Receive("gs_zones_draw", function()
		local a = net.ReadFloat()
		local b = net.ReadFloat()

		table.insert(D_Zones, {a,b})
	end)

	hook.Add("PostDrawOpaqueRenderables", "debugzonedraw", function()
		for k, v in pairs(D_Zones) do
			render.DrawWireframeBox(vector_origin, Angle(0,0,0), v[1], v[2], color_white)
		end
	end)

else
	function Zone_meta:In(pos)
		return pos:WithinAABox( self.points[1], self.points[8] )
	end

	function Zone_meta:EntIn(ent)
		local maxs, mins = ent:WorldSpaceAABB()
		return maxs:WithinAABox( self.points[1], self.points[8] ) and mins:WithinAABox( self.points[1], self.points[8] )
	end

	function Zone_meta:RandomPos()
		-- get bounds randomization and genere value
		local vec1, vec2 = self.points[1], self.points[8]
		local pos = Vector(math.random(vec1.x, vec2.x), math.random(vec1.y, vec2.y), math.random(vec1.z, vec2.z))

		return pos
	end

	function Zone_meta:EntityHere()
		return ents.FindInBox(self.points[1], self.points[8])
	end

	function Zone_meta:PosFix(pos)
		-- fix the pos, make him IN box

		local a, b = {self.points[1]:Unpack()}, {self.points[8]:Unpack()}
		local pos  = pos:Unpack()
		local fixed = {}

		-- test this
		for k, v in pairs(a) do 
			if v > pos[k] then
				fixed[k] = v 
			else
				fixed[k] = pos[k]
			end
		end

		for k, v in pairs(b) do
			if v < pos[k] then
				fixed[k] = v 
			else
				fixed[k] = pos[k]
			end
		end

		return Vector(unpack(fixed))
	end 

	function Zone_meta:EntPosFix(ent, pos)
		-- return fixed center pos
		local maxs, mins = ent:WorldSpaceAABB()
		local dmax, dmin = ent:OBBMaxs(), ent:OBBMins()

		local fmaxs, fmins = self:PosFix(maxs), self:PosFix(mins)

		if fmaxs == maxs and fmins == mins then
			-- nothing fix
			return
		end

		if fmax != maxs then
			pos = pos - (dmax + Vector(0.1, 0.1, 0.1))
		elseif fmins != mins then
			pos = pos + (dmin - Vector(0.1, 0.1, 0.1))
		end

		return pos
	end

	function Zone_meta:SetPosIN(ent)
		local rand_pos = self:RandomPos()
		local fix_pos  = self:EntPosFix(ent, rand_pos)

		ent:SetPos(fix_pos)
	end

	function Zone_meta:StartDebugDraw(ent)
		--[[
		net.Start("gs_zones_draw")
		net.WriteFloat(self.points[1])
		net.WriteFloat(self.points[8])
		net.Broadcast()
		--]]
		debug.Trace()
		PrintTable(self)
		debugoverlay.Box( vector_origin, self.points[1], self.points[8], 0)
	end

	function Zone(a, b, draw) --low and high points
		local zone = {} 
		-- get 8 points of cube zone
		-- i don't know i need it all
		local x,y,z = {}, {}, {}

		table.insert(x, a.x)
		table.insert(x, b.x)

		table.insert(y, a.y)
		table.insert(y, b.y)

		table.insert(z, a.z)
		table.insert(z, b.z)

		zone.points = {}

		for k, v in pairs(x) do
			for kk, vv in pairs(y) do
				for kkk, vvv in pairs(z) do
					table.insert(zone.points, Vector(v,vv,vvv))
				end
			end
		end

		-- the "a" and "b" points = first and last index in zone.points

		--[[if draw then
			self:StartDebugDraw()
		end--]]
		PrintTable(zone) 
		return zone
	end
end

Zone_meta.__index = Zone_meta