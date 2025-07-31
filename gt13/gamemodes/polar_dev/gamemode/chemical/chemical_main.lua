CHEMICALS = CHEMICALS or {} -- all components
CHEMIC    = CHEMIC or {} -- for func
RECEIPTS  = {} -- all receipts
FAST_REC  = {} -- FAST receipts without perebor


CHEMIC_CONTAINER = {} -- is "container" for all

-- making OOP-style containers
-- working now

BASE_CHEM_COLOR = Color(255,255,255,20)

local function kv_sum(arr1, arr2)
	local rez = {}
	for k, v in pairs(arr1) do
		rez[k] = v + arr2[k]
	end
	return rez
end

function CHEMIC_CONTAINER:GetAll()
	return self.content
end

function CHEMIC_CONTAINER:GetSum()
	return tblsum(self.content)
end

function CHEMIC_CONTAINER:HaveComp(name)
	if self.content[name] then
		return true, self.content[name]
	else
		return false, 0
	end
end

function CHEMIC_CONTAINER:IsEmpty()
	return table.Count(self.content) == 0
end

function CHEMIC_CONTAINER:AddComponent(name, unit)
	if !CHEMICALS[name] then 
		return
	end

	if unit < 0 then return end

	local sum = tblsum(self.content) -- sum all units in container
	
	if sum == self.limit then -- if bucket already full
		return false
	elseif sum + unit > self.limit then -- if bucket have some space for part of unit
		unit = self.limit - sum
	end

	if self.content[name] then
		self.content[name] = self.content[name] + unit
	else
		self.content[name] = unit
	end
end

function CHEMIC_CONTAINER:DecComponent(name, unit)
	if self.content[name] then
		self.content[name] = self.content[name] - unit

		if self.content[name] <= 0 then
			self.content[name] = nil
		end
	end
end

function CHEMIC_CONTAINER:RemoveComponent(name)
	self.content[name] = nil
end

function CHEMIC_CONTAINER:HumanMetabolize(unit) // only for humanclass
	for chem, _ in pairs(self.content) do
		CHEMICALS[chem]["callbackInPly"](self.ent)
		self:DecComponent(chem, unit)
	end
end

function CHEMIC_CONTAINER:GetColor()
	if #self.content == 0 then return Color(0,0,0) 
	elseif #self.content == 1 then return CHEMICALS[table.GetKeys(self.content)[1]]["color"] or BASE_CHEM_COLOR end

	local sum = tblsum(self.content)
	local proc = {}

	for k, v in SortedPairsByValue(self.content, true) do
		proc[#proc+1] = {
			proc = (v * 100) / sum,
			clr =  CHEMICALS[k]["color"] or BASE_CHEM_COLOR
		}
	end

	local blend, rat = proc[1]["clr"], proc[1]["proc"]
	for i = 2, #proc do
 		blend:Lerp(proc[i]["clr"], proc[i][proc] / rat)
		rat = rat + proc[i][proc]
	end
 
	blend.a = math.Clamp(blend.a, 20, 255)

	return blend
end

function CHEMIC_CONTAINER:MixComp() -- i cant refactor this because is WORK and i dont want to do ths
	local finalcomp = {}
	for k, v in pairs(self.content) do
		if FAST_REC[k] then
			for kk,vv in pairs(FAST_REC[k]) do
				local count = 0
				local recept = RECEIPTS[kk]

				if CanMake(self, recept["inp"]) then
					while CanMake(self, recept["inp"])do
						for kkk,vvv in pairs(recept["inp"]) do
							self:DecComponent(kkk, vvv)
						end
						count = count + 1
					end
					for i = 1, count do
						for kkk,vvv in pairs(recept["out"]) do
							if !self.content[name] then
								table.insert(finalcomp, name)
							end
							self:AddComponent(kkk,vvv)
						end
					end

					self:MixComp()
				end
			end
		end
	end

	for k, v in pairs(finalcomp) do
		CHEMICALS[v]["callBackInMix"](self, self.ent)
	end
end


function CHEMIC_CONTAINER:New_Container(ent_container, _limit) -- ent_container can be a bucket or player
	local obj = {}

	obj = {
		limit = _limit or 100,
		content = {},
		ent = ent_container,
	}

	table.Merge( obj, self ) -- fak setmetatable

	return obj
end

function CHEMIC:New(name,data)
	/*
	CHEMICALS[data["simpleName"]] = {
		simpleName    = data["simpleName"],
		normalName    = name,
		callbackInPly = data["callbackInPly"],
		callBackInMix = data["callBackInMix"],
		activeid      = data["activeid"],
		active        = data["active"],
		notdispense   = data["notdispense"] or false
		color		  = data["color"]
	}
	*/

	CHEMICALS[data.simpleName] = data

	if data["receipt"] then
		RECEIPTS[data["simpleName"]] = data["receipt"]
	end

end

function list_length( t )
	local len = 0
	for _,_ in pairs( t ) do
		len = len + 1
	end
 
	return len
end

local function CanMake(have,need)
	local count = list_length(need)
	for k,v in pairs(need) do
		if have[k] == nil then
			return false
		elseif have[k] >= need[k] then
			count = count - 1
		else
			return false
		end
	end
		if count == 0 then
		return true
	end
end

function FormContent(bucket)
	local arr = {}
	for k,v in pairs(bucket.content) do
		arr[k] = v:getUnits()
	end
	return arr
end