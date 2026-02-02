/*
    лучше конечно отправлять данные в net.WriteData(), но для этого необходимо писать сериализацию типов
    флоат переводить в строку
    
    в последствии можно будет добавлять кастомные функции для более экономного нетворкинга - uint8, int16 и тд
*/

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

function util.NetWriteType(type, var)
    NET_TYPE_WRITE_FUNC[type](var)
end

function util.NetReadType(type)
    return NET_TYPE_READ_FUNC[type]()
end


// client to server
function util.SendNetCommand(ent, id, args)
--    if !ent.NetCommands[id] then GS_Error("SendNetCommand: invalid netcmd for "..tostring(ent).." - "..tostring(id)) end
    net.Start("ps_ent_netcmd")
    for k, v in pairs(args) do
        util.NetWriteType(v.typ, v.var)
    end
    net.SendToServer()
end

function util.ReadNetCommand(len, ply)
    local ent = net.ReadEntity()
    local id = net.ReadString()

    if !IsValid(ent) then return end
    if ent.NetCommands[id] == nil then return end
    
    local net_args = ent.NetCommands[id]

    local args = {}

    for k, net_argument in pairs(net_args) do
        local key_arg = net_argument[1]
        local typ = net_argument[2]

        local var = util.NetReadType(typ)

        //table.insert(args, var)
        args[key_arg] = var
    end

    local func = id

    if ent[func] then
        ent[func](ent, unpack(args))
    else
        ent:HanleNetCommands(id, args)
    end
end

if SERVER then
    net.Receive("ps_ent_netcmd", util.ReadNetCommand)
end