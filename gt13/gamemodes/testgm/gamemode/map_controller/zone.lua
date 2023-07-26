Zone = {}

--[[
	ZONES!
]]


function Zone:__call(a,b) --low and high points
    local zone = {}

	-- get 8 points of cube zone
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

	setmetatable(zone, Zone)
	return zone
end

function Zone:In(pos)
	--check the first and last index
	local a = self.points[1]:ToTable()
	local b = self.points[8]:ToTable()

	for k, v in pairs(pos:ToTable()) do
		if v < a[k] and v > b[k] then
			return false
		end
	end

	return true
end

function Zone:RandomPos()
	-- get bounds randomization and genere value
	local x1,x2,y1,y2,z1,z2
	
	for k, x in pairs(self.points) do

	end
end