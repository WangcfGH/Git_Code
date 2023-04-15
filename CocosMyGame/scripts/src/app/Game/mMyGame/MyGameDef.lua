
if nil == cc or nil == cc.exports then
    return
end

cc.exports.MyGameDef                        = {
    MY_TOTAL_PLAYERS                        = 4,    --玩家数
    MY_TOTAL_CARDS                          = 108,  --总牌数
    MY_THROW_WAIT                           = 25,   --出牌等待时间
    MY_CHAIR_CARDS                          = 33,   --各人牌数
    MY_TOTAL_PACK                           = 2,    --几副牌
    MY_TOP_CARD                             = 0,    --进张

    -- waitting session  BaseGameDef 到19结束
    MY_WAITING_JUDGE_WELFARE                = 20,

    MYGAME_TS_WAITING_BANKSHOW              = 0x00010000,
    MYGAME_TS_WAITING_SHOW                  = 0x00020000,
    MYGAME_TS_WAITING_TRIBUTE               = 0x10000000, --进贡
    MYGAME_TS_WAITING_RETURN                = 0x20000000, --还贡

    MYGAME_US_SHOW_DONE				        = 0x00000010,	--已经亮牌

    GAME_GR_CALL_FRIEND                     = 401000,
    GAME_GR_SHOW_CARDS                      = 401002,
    GAME_GR_THROW_READY                     = 401010,
    GAME_GR_SYSMSG                          = 401009,
    
    GAME_GR_TASKDATA                        = 402008,
    GAME_GR_UP_INFO                         = 402020,
    GAME_GR_UP_PLAYER                       = 402021,
    GAME_GR_CARDS_INFO                      = 229580, --旁观看牌内容
    
    GAME_GR_CONTINUALINFO                   = 220605,

    GAME_GR_CHECK_OFFLINE                   = 220615, --多局房检查是否断线
    GAME_GR_OFFLINE_KICKING_PLAYER          = 220616, --离线检查通知玩家被提出房间
    GAME_GR_OTHER_PLAYER_UPDATE_DEPOSIT     = 220617, --更新桌上银两信息
    GAME_GR_BUY_PROPS_THROW                 = 220618, --购买道具扔人

    GR_EXCHANGE_ROUND_TASK                  = 220623, -- 移动端兑换券每轮任务进度
    GR_FINISH_EXCHANGE_ROUND_TASK           = 220624, -- 领取移动端兑换券每轮任务

    GAME_GR_EXPRESSION_THROW                = 220650, --扔表情

    GAME_WAITING_CALL_FRIEND                = 1000,
    GAME_WAITING_SHOW_CARDS                 = 1001,

    GAME_CARDID_HELPER                      = 5,        --默认狗腿牌ID

    GAME_SYSMSG_RETURN_GAME                 = 2,
    --GAME_SYSMSG_CLOCK_STOP                  = 3,

    MY_CARD_UNITE_TYPE_ABT_THREE_1          = 0x00100000,  
    MY_CARD_UNITE_TYPE_FOUR_2				= 0x00200000,  
    MY_CARD_UNITE_TYPE_FOUR_2_COUPLE		= 0x00400000,  
	MY_CARD_UNITE_TYPE_2KING				= 0x00800000,

    HAGD_GAME_MSG_RETURN = 19840341, --还供
	HAGD_GAME_MSG_TRIBUTE = 19840342,--进贡
	HAGD_GAME_MSG_TRIBUTEOVER = 19840343,--进贡结束
    HAGD_GAME_MOVECARD_OVER =  19840344,

    GR_UPGRADE_USER_LEVEL = 404103,
    GR_GAME_WIN_GET_EXCHANGE = 220625,

    GR_GAME_UNABLE_TO_CONTINUE = 211138,

    GR_TABLE_PLAYER_5BOMB_DOUBLE = 220626,  -- 开局通知桌上玩家 是否5炸翻倍
    GR_GAME_RESULT_EXCHANGE_INFO = 220627,  -- 结算界面，服务段通知对局数相关
    GR_GAME_WIN_GET_ROOM_EXCHANGE = 220628, -- 客户端领取房间对局赠送的兑换券，可以区分新老客户端领或者不领
    GR_GAME_RESULT_ACTIVITY_SCORE = 220631, -- 结算通知客户端提示获得的积分 

    GR_OTHER_PLAYER_UPDATE_TIMING_GAME = 220701, --更新桌上定时赛积分信息

    --竞技场等分类型
    kArenaScoreTypeTongHua = 2,
	kArenaScoreTypeSuperBomb = 3,
	kArenaScoreType4Kin = 4,
	kArenaScoreTypeAbtSingle = 5,
	kArenaScoreTypeAbtCouple = 6,
	kArenaScoreTypeAbtThree = 7,
	kArenaScoreTypeBomb = 8,
	kArenaScoreTypeSuppress = 9, --压制得分
    MY_ZORDER_SORTEFFECT = 1216,    --理牌特效的层级高于手牌
    MY_ZORDER_CARD_HAND  = 1108,    -- 为了竖牌情况，自己的手牌层级 > 操作按钮> 其他玩家出的牌 (wuym add）
    MY_ZORDER_ARENAINFO = 1401,  --用于聊天排序按钮等层级高于自己的手牌 SK_ZORDER_PLAYERINFO
    MY_ZORDER_MYSELF = 1600,  --用于自己的头像高于ARENAINFO的Zorder SK_ZORDER_ARENA_INFO 1590

    SORT_CARD_BY_CROSS          = 1,
    SORT_CARD_BY_VERTICAL       = 2,

    MY_TAG_EFFECT_SORT = 999,

    MY_SDK_INFO = 220630,
    
    GR_EXPRESSION_PROP_GAME = 410210, --使用表情 or 购买表情  这里也放一份，仅仅是为了格式统一

    -- 主播建房
    GR_SET_GAME_RULE_INFO = 222000, -- 建房上报规则
    GR_GET_GAME_RULE_INFO = 222001, -- 加入房间获取规则
    GR_ANCHOR_LEAVE_GAME = 222002,  -- 主播离开房间
    ANCHORMATCH_ABORT_FLAG_ANCHOR_EXIT = 0x00008000,
    ANCHORMATCH_ABORT_FLAG_PLAYER_EXIT = 0x00010000,

    -- 组队2V2
    TEAM2V2GAME_ABORT_FLAG_PLAYER_EXIT = 0x00020000,


    -- 新手引导
    NEWUSERGUIDE_NOT_OPEN = 0,
    -- 第一局引导
    NEWUSERGUIDE_BOUTONE_START = 1,
    NEWUSERGUIDE_BOUTONE_STEP_1 = 2,
    NEWUSERGUIDE_BOUTONE_FINISHED = 10,
    -- 第二局引导
    NEWUSERGUIDE_BOUTTWO_START = 11,
    NEWUSERGUIDE_BOUTTWO_STEP_1 = 12,
    NEWUSERGUIDE_BOUTTWO_STEP_2 = 13,
    NEWUSERGUIDE_BOUTTWO_FINISHED = 20,
    -- 引导层Zorder
    NEWUSERGUIDE_BASE_ZORDER = 100000,

    GR_BOUTGUIDE_UPLOAD_DATA = 403600
}

local SKGameDef = cc.exports.SKGameDef
local MyGameDef = cc.exports.MyGameDef
local SKPublicInterface                     = import("src.app.Game.mSKGame.SKPublicInterface")
if SKPublicInterface then
    MyGameDef.MY_CARD_UNITE_TYPE_TOTAL      = SKPublicInterface:bits_or(
                                            SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_4KING)

    MyGameDef.MY_COMPARE_UNITE_TYPE_BOMB    = SKPublicInterface:bits_or(
                                            SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE)
    
    MyGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN    = SKPublicInterface:bits_or(
                                                    SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)

    MyGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB    = SKPublicInterface:bits_or(
                                                    SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB)

    MyGameDef.MY_COMPARE_UNITE_TYPE_4KING           = SKPublicInterface:bits_or(
                                                    SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN
                                                    ,SKGameDef.SK_CARD_UNITE_TYPE_4KING)
end


return cc.exports.MyGameDef