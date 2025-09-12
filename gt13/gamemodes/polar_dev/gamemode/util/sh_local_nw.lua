// нужна какая то библиотека, которая бы делала локальные нет вары для игроков, дабы не засирать остальным бендвитч
if SERVER then
    util.AddNetworkString("gs_local_nwvar")
    util.AddNetworkString("gs_local_nwvar_new")
end

local NET_TYPE = {
    "number",
    "string",
    "vector",
    "entity",
    "boolean",
    "color",
}

local NET_TYPE_WRITE_FUNC = {
    ["number"] = function(val)
        net.WriteFloat(val)
    end,
    ["string"] = function(val)
        net.WriteString(val)
    end,
    ["vector"] = function(val)
        net.WriteVector(val)
    end, 
    ["entity"] = function(val)
        net.WriteEntity(val)
    end,
    ["boolean"] = function(val)
        net.WriteBool(val)
    end,
    ["color"] = function(val)
        net.WriteColor(val)
    end,
}

local NET_TYPE_READ_FUNC = {
    ["number"] = function()
        return net.ReadFloat()
    end,
    ["string"] = function()
        return net.ReadString()
    end,
    ["vector"] = function()
        return net.ReadVector()
    end, 
    ["entity"] = function()
        return net.ReadEntity()
    end,
    ["boolean"] = function()
        return net.ReadBool()
    end,
    ["color"] = function()
        return net.ReadColor()
    end,
}

local ENUM_NET_TYPE = {}

for i=1, #NET_TYPE do
    ENUM_NET_TYPE[NET_TYPE[i]] = i
end


local PLAYER = FindMetaTable("Player")

PLAYER.LocalNWVars = PLAYER.LocalNWVars or {}
PLAYER.KeyNWVars = PLAYER.KeyNWVars or {}
PLAYER.ProxyNWVars = PLAYER.ProxyNWVars or {}

function PLAYER:GetLocalNWVar(key, def)
    return self.LocalNWVars[key] or def
end

function PLAYER:RegisterNWKey(key, id)
    if self.LocalNWVars[key] then return end

    self.LocalNWVars[key] = 0

    local id = id or table.Count(self.LocalNWVars)
    self.KeyNWVars[key] = id
    if SERVER then
        net.Start("gs_local_nwvar_new")
        net.WriteString(key)
        net.WriteUInt(id, 8)
        net.Send(self)
    end

end

function PLAYER:LocalNWVarProxyAdd(key, func)
    //if self.LocalNWVars[key] then return end
    
    self.ProxyNWVars[key] = func
end

function PLAYER:LocalNWVarProxyRemove(key)
    if self.LocalNWVars[key] then return end
    
    self.ProxyNWVars[key] = nil
end

// force type
// example - need send small int but can send only big float? - force change type to somthg int8, int16 ..
function PLAYER:SetLocalNWVar(key, val, force_typ)
    if CLIENT then
        local nid = key
        local fliped = table.Flip(self.KeyNWVars)
        local key = fliped[nid]
        if !key then return end

        self.LocalNWVars[key] = val

        local proxy = self.ProxyNWVars[key]

        if proxy then
            proxy(self, key, old, val)
        end
        return
    end

    if !self.LocalNWVars[key] then
        self:RegisterNWKey(key)
    end
    local old = self.LocalNWVars[key]
    self.LocalNWVars[key] = val
    local nid = self.KeyNWVars[key]

    if SERVER then
        local val_typ  = type(val)
        local send_typ = ENUM_NET_TYPE[val_typ]
        
        if !send_typ then
            error("SetLocalNWVar: not valid type - "..val_typ)
        end

        net.Start("gs_local_nwvar")
        net.WriteUInt(nid, 8)
        net.WriteUInt(send_typ, 5)
        NET_TYPE_WRITE_FUNC[NET_TYPE[send_typ]](val)
        net.Send(self)
    end

    local proxy = self.ProxyNWVars[key]

    if proxy then
        proxy(self, key, old, val)
    end
end

net.Receive("gs_local_nwvar", function()
    local nid = net.ReadUInt(8)
    local enum_typ = net.ReadUInt(5)
    local var = NET_TYPE_READ_FUNC[NET_TYPE[enum_typ]]()

    LocalPlayer():SetLocalNWVar(nid, var)
end)

net.Receive("gs_local_nwvar_new", function()
    local key = net.ReadString()
    local nid = net.ReadUInt(8)

    LocalPlayer():RegisterNWKey(key, id)
end)
