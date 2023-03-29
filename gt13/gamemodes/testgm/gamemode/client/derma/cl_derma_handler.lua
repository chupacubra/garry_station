cl_handler = {}
cl_handler.derma = {}

function cl_handler:add(panel)
    local tocken = gentocken()
    self.derma[tocken] = panel

    net.Start("gs_cl_derma_open")
    net.WriteString(tocken)
    net.WriteBool(true)
    net.SendToServer()

    return tocken
end

function cl_handler:makeAction(tocken, action, ...)
    net.Start("gs_cl_derma_handler")
    net.WriteString(tocken)
    net.WriteString(action)
    net.WriteTable(arg)
    net.SendToServer()
end

function cl_handler:runActionforPanel(tocken, action, ...) -- getting from server name function for panel
    local panel  = self.derma[tocken]

    if panel == nil then
        return
    end

    if panel.action == nil then
        GS_MSG("cl_handler want to run function for panel, but he don't have this method ("..tostring(action)..")")
        return
    end
    

end

function cl_handler:remove(tocken)
    self.derma[tocken] = nil
    net.Start("gs_cl_derma_open")
    net.WriteString(tocken)
    net.WriteBool(false)
    net.SendToServer()
end

function cl_handler:closeByServer(tocken)
    --[[
        close panel
    ]]
    local panel = self.derma[tocken]
    
    if panel == nil then
        return
    end

    panel:Remove()

    self.derma[tocken] = nil
end

net.Receive("gs_cl_derma_handler",function()
    local tocken = net.ReadString()
    local action = net.ReadString()
    local arg    = net.ReadTable()

    cl_handler:runActionforPanel()
end)

net.Receive("gs_cl_derma_open", function()
    local tocken = net.ReadString()
    local 

end)