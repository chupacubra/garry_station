
function ContextMenu(open)
    //gui.EnableScreenClicker( open )
    if open then
    else

    end
    
end

hook.Add("OnContextMenuOpen", "GameContextMenu", function() ContextMenu(true) end)
hook.Add("OnContextMenuClose", "GameContextMenu", function() ContextMenu(false) end)
