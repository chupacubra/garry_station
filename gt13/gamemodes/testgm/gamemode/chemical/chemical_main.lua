CHEMICALS = {} -- all components
CHEMIC    = CHEMIC or {} -- for func
RECEIPTS  = {} -- all receipts
FAST_REC  = {} -- FAST receipts without perebor
FOR_CL    = {} -- information about chemicals for clients
chem = {}

function AllCompUnits(bucket)
	local i = 0
	for k,v in pairs(bucket.content) do
		i = i + v:getUnits()
	end
	return i
end

function CHEMIC:AddComp(name,unit,bucket)
	if !CHEMICALS[name] or !bucket then
		return
 	end

  	if bucket.content[name] then
		bucket.content[name]:AddUnit(unit)
		return
  	elseif bucket.content[name] == nil and unit > 0 then
		if bucket.limit then
			local all = AllCompUnits(bucket)
			local canfill = bucket.limit - all
			if canfill == 0 then 
				return
			end

			if canfill < unit then
				unit = canfill
			end
		end
  	end
  
	if unit < 1 then
		return
	end
  
  	local obj = {}
  
  	obj.unit = unit
  	obj.name = name
  	obj.fm   = false
	
  	function obj:getName()
		return self.name
  	end
  
  	function obj:getUnits()
		return self.unit
  	end
  
	function obj:DecUnit(int)
		self.unit = self.unit + int
		if self.unit < 1 then
	  		bucket.content[name] = nil
			return
		end
  	end

	function obj:AddUnit(int)
		if int < 0 then
			self:DecUnit(int)
			return
		end
		local all = AllCompUnits(bucket)
		local canfill = bucket.limit - all

		if bucket.limit then
			local all = AllCompUnits(bucket)
			local canfill = bucket.limit - all

			if canfill == 0 and int > 0 then 
				return
			elseif int < 0 then
				self.unit = self.unit + int
				if self.unit < 1 then
					bucket.content[name] = nil
					return
				end
			end
			
			if int > canfill then
				self.unit = self.unit + canfill
			else
				self.unit = self.unit + int
				if self.unit < 1 then
					bucket.content[name] = nil
					return
				end
			end
		else
			self.unit = self.unit + int
			if self.unit < 1 then
				bucket.content[name] = nil
				return
			end
		end
	end
  
  function obj:OnPlyClbck(ply)
	CHEMICALS[self:getName()]["callbackInPly"](self,ply)
  end
  
  function obj:OnFirstMix(bucket)
	if self.fm then
	  return
	end
	CHEMICALS[self:getName()]["callBackInMix"](self,bucket)
	self.fm = true
  end
  
  setmetatable(obj, self)
  self.__index = self; bucket.content[name] = obj
end



function CHEMIC:New(name,data --[[{simpleName,callbackInPly,callBackInMix,receipt}--]])
  CHEMICALS[data["simpleName"]] = {
	simpleName    = data["simpleName"],
	normalName    = name,
	callbackInPly = data["callbackInPly"],
	callBackInMix = data["callBackInMix"],
	activeid      = data["activeid"],
	active        = data["active"],
	notdispense   = data["notdispense"] or false
  }
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

function CHEMIC:MixComp(bucket)
	local finalcomp = {}
	for k,v in pairs(bucket.content) do
		if FAST_REC[k] then
			for kk,vv in pairs(FAST_REC[k]) do
				local count = 0
				local recept = RECEIPTS[kk]
				if CanMake(FormContent(bucket),recept["inp"]) then
					while CanMake(FormContent(bucket),recept["inp"]) != false do
						for kkk,vvv in pairs(recept["inp"]) do
						bucket.content[kkk]:AddUnit(vvv * -1)
						end
						count = count + 1
					end
					for i = 1,count do
						for kkk,vvv in pairs(recept["out"]) do
						CHEMIC:AddComp(kkk,vvv,bucket)
						finalcomp[kkk] = true
						end
					end
					CHEMIC:MixComp(bucket)
				end
			end
		end
	end

	for k,v in pairs(finalcomp) do
		if bucket.content[k] then
			bucket.content[k]:OnFirstMix(bucket)
		end
	end
end
