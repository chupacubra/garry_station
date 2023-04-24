Derma_Handlers = {}
Derma_OpenedMenu = {}


function AddMenuHandler(key,func)
    Derma_Handlers[key] = func
end

function HandlerMenuRun(ply,key,func,arg)
    print("===========")
    print("Menu Handler")
    print(ply)
    print(key, func)
    PrintTable(arg)
    print("===========")

    local handler_func = Derma_Handlers[key]["actions"]

    handler_func[func](ply,arg)
end

net.Receive("gs_cl_derma_handler", function(_,ply)
    local menu = net.ReadString()
    local func = net.ReadString()
    local arg = net.ReadTable()

    HandlerMenuRun(ply,menu,func,arg)
end)

