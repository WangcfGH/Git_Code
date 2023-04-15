
local SKGameTools = import("src.app.Game.mSKGame.SKGameTools")
local NetlessGameTools = class("NetlessGameTools", SKGameTools)

local SK_TOOLS_INDEX = {
    SK_TOOLS_INDEX_ADD         = 1,
    SK_TOOLS_INDEX_QUIT        = 2,
    SK_TOOLS_INDEX_SETTING     = 3,
    SK_TOOLS_INDEX_SAFEBOX     = 4,
    SK_TOOLS_INDEX_ROBOT       = 5,
    SK_TOOLS_INDEX_SHARE       = 6,
    SK_TOOLS_INDEX_MENU       = 7,
}

function NetlessGameTools:onGameStart()
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, false)
    self:disableSafeBox()  
end

return NetlessGameTools