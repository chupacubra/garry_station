STAMP_APPROVED = 1
STAMP_DENIED = 2

STAMPS_ICON = {
    [STAMP_APPROVED] = "icon16/accept.png",
    [STAMP_DENIED]   = "icon16/cancel.png"
}

STAMPS_PNG = {
    [STAMP_APPROVED] = "https://i.imgur.com/cThrDiq.png",
    [STAMP_DENIED] = "https://i.imgur.com/smxoCQA.png"
}


function HTMLStamp(tbl)
    local str = ""

    for k,v in pairs(tbl) do
        str = str .. "<img src='"..STAMPS_PNG[v] .."'>"
    end

    return str
end