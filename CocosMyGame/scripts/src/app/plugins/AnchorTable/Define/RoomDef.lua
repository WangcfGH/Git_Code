if nil == cc or nil == cc.exports then
    return
end
cc.exports.RoomDef = {

    SCORE_MIN                = -2000000000,  -- 最小的游戏积分
    DEPOSIT_MAX				 = 2000000000,

    -- begin 玩家状态
    PLAYER_STATUS_OFFLINE    = 0,   -- 离线
    PLAYER_STATUS_ONLINE     = 1,   -- 在线

    PLAYER_STATUS_WALKAROUND = 11,  -- 伺机入座（比赛中是进入房间）
    PLAYER_STATUS_SEATED     = 12,  -- 已入座，（比赛中是等待下一局，不拆桌）
    PLAYER_STATUS_WAITING    = 13,  -- 等待开始
    PLAYER_STATUS_PLAYING    = 14,  -- 玩游戏中
    PLAYER_STATUS_LOOKON     = 15,  -- 旁观
    PLAYER_STATUS_BEGAN      = 16,  -- 开始游戏
    -- end 玩家状态

    -- begin 桌子状态
    TABLE_STATUS_STATIC      = 0,
    TABLE_STATUS_PLAYING     = 1,
    -- end 桌子状态

    START_GAME_MODE = {
        MODE_QUICK  = 1,  -- 快速入桌
        MODE_MANUAL = 2,  -- 手动入桌
        MODE_INVITE = 3,  -- 邀请入桌
        MODE_JOIN   = 4,  -- 加入入桌
        MODE_LOOKON = 5,  -- 旁观入桌
        MODE_NEW    = 6,  -- 新建入桌
    }, 

    MSGTYPE        = {
        APPLYFRIEND = 1, -- 好友申请
        INVITEGAME  = 2, -- 邀请游戏
        APPLYLOOKON = 3, -- 申请看牌
    }, 
}

return cc.exports.RoomDef