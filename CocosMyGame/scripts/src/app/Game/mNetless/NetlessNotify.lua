local MyGameNotify = import("src.app.Game.mMyGame.MyGameNotify")
local NetlessNotify = class("NetlessNotify", MyGameNotify)

function NetlessNotify:onDataReceived(clientID, msgType, session, request, data)
    
end
return NetlessNotify