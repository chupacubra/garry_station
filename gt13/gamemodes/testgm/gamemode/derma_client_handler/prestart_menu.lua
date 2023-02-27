local handler = {}

handler.actions = {}

function handler.actions.ready(ply,arg)
    GS_Round_System:PlayerReady(ply,arg.ready)
end

function handler.actions.observe(ply,arg)
    print("HANDLER")
end

function handler.actions.join(ply,arg)
    GS_Round_System:RoundSpawnPlayer(ply)
end


AddMenuHandler("menu_prestart", handler)