local BaseGameArenaInfoManager = import("src.app.Game.mBaseGame.BaseGameArena.BaseGameArenaInfoManager")
local MyGameArenaInfoManager = class("MyGameArenaInfoManager", BaseGameArenaInfoManager)
local mySignUpStatus = require("src.app.plugins.SignUp.SignUpStatus"):getInstance()

function MyGameArenaInfoManager:getDaySignUpCount()
    return mySignUpStatus:getSignUpCacheFile().signUpCount
end

return MyGameArenaInfoManager
