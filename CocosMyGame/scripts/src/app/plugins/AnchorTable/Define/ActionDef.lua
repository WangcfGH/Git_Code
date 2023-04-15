--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
if nil == cc or nil == cc.exports then
    return
end

-- 供关心玩家动作的插件订阅
cc.exports.ActionDef = {
    EVENT_PLAYER_ENTERED                = "action_player_entered",                          -- 玩家进入房间动作
    EVENT_PLAYER_SEATED                 = "action_player_seated",                           -- 玩家坐下动作
    EVENT_PLAYER_UNSEATED               = "action_player_unseated",                         -- 玩家起立动作
    EVENT_PLAYER_LOOKON                 = "action_player_lookon",                           -- 玩家开始旁观动作
    EVENT_PLAYER_UNLOOKON               = "action_player_unlookon",                         -- 玩家结束旁观动作
    EVENT_PLAYER_STARTED                = "action_player_started",                          -- 玩家启动游戏客户端动作
    EVENT_PLAYER_PLAYING                = "action_player_playing",                          -- 非solo房玩家四人都举手游戏客户端启动后自动开局的动作
    EVENT_PLAYER_LEFT                   = "action_player_left",                             -- 玩家离开房间动作
    EVENT_PLAYER_LEAVETABLE             = "action_player_leavetable",                       -- 玩家离开桌子动作
    EVENT_PLAYER_NEWTABLE               = "action_player_newtable",                         -- 玩家换桌动作
    EVENT_PLAYER_GAMESTARTUP            = "action_player_gamestartup",                      -- solo房玩家游戏开局动作
    EVENT_PLAYER_GAMEBOUTEND            = "action_player_gameboutend",                      -- 玩家一局结束
    EVENT_SOLOTABLE_CLOSED              = "action_player_solotable_closed",                 -- 强制散桌
}

return cc.exports.ActionDef
--endregion
