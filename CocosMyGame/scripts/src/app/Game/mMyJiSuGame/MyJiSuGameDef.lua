
if nil == cc or nil == cc.exports then
    return
end

local BaseGameDef = import("src.app.Game.mBaseGame.BaseGameDef")
local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
local MyGameDef = import("src.app.Game.mMyGame.MyGameDef")

local MyJiSuGameDef = {}
table.merge(MyJiSuGameDef, BaseGameDef)
table.merge(MyJiSuGameDef, SKGameDef)
table.merge(MyJiSuGameDef, MyGameDef)

table.merge(MyJiSuGameDef, {
    FIRST_DUN_CARD_COUNT = 4,
    SECOND_DUN_CARD_COUNT = 6,
    THIRD_DUN_CARD_COUNT = 8,

    SK_CARD_START_POS_X                     = 171.81,       --最左边的牌的X坐标
    SK_CARD_START_POS_X_RAW                 = 171.81,
    SK_CARD_START_POS_Y                     = 68,           --最左边的牌的Y坐标

    SK_CARD_COLUMN_INTERVAL                 = 48.05,        --默认45
    SK_CARD_COLUMN_INTERVAL_RAW             = 48.05,
    SK_CARD_COLUMN_INTERVAL_MAX             = 55,           --默认72

    MYJISU_ZORDER_PAIXING                   = 1205,         --用于出牌牌型排序按钮等层级高于自己的出牌，出的牌层级是1108
    MYJISU_ZORDER_PANEL_PLAYER              = 1530,         --个人信息界面高于牌型 MY_ZORDER_PAIXING

    MYJISUGAME_TS_WAITING_ADJUST            = 0x00002000,   --等待理牌

    HAGD_GAME_MSG_ADJUST_OVER               = 19840352,     --理牌结束      
    
    GAME_WAITING_ADJUST                     = 1500,         --发送理牌结束消息的等待
})

cc.exports.MyJiSuGameDef = MyJiSuGameDef

return MyJiSuGameDef