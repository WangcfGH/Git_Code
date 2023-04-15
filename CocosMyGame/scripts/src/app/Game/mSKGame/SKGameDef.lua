
if nil == cc or nil == cc.exports then
    return
end

cc.exports.SKGameDef                        = {
    SK_TOTAL_PLAYERS                        = 4,    --玩家数
    SK_TOTAL_CARDS                          = 108,  --总牌数
    SK_CHAIR_CARDS                          = 27,   --各人牌数
    SK_TOTAL_PACK                           = 2,    --几副牌
    SK_MAX_SCORE_CARD                       = 36,   --一共多少张分牌 最多支持4副牌
    SK_TOP_CARD                             = 0,    --进张
    SK_BOTTOM_CARD                          = 0,    --底牌
    SK_DEFAULT_RANK                         = 1,    --服务端未通知时默认值

    SK_MAX_CARDS_PER_CHAIR                  = 64,
    SK_MAX_CARDS_LAYOUT_NUM                 = 64,

    SK_CARD_BACK_ID                         = -2,
    SK_CARD_PER_LINE                        = 28,   --默认一列最多20张
    SK_CARD_LINE_INTERVAL                   = 75,
    SK_CARD_COLUMN_INTERVAL                 = 41.9,   --默认45
    SK_CARD_COLUMN_INTERVAL_RAW             = 41.9,
    SK_CARD_COLUMN_INTERVAL_MAX             = 55,   --默认72
    SK_CARD_THROWN_INTERVAL                 = 32,
    SK_CARD_THROWN_INTERVAL_RAW             = 32,
    SK_CARD_SHOWN_PER_LINE                  = 9,   --默认10
    SK_CARD_SHOWN_LINE_INTERVAL             = 38,  --默认35
    SK_CARD_SHOWN_LINE_INTERVAL_RAW         = 38,
    SK_CARD_SHOWN_COLUMN_INTERVAL           = 24,
    SK_CARD_SHOWN_COLUMN_INTERVAL_RAW       = 24,
    
    SK_CARD_START_POS_X                     = 0.5,   --最左边的牌的X坐标
    SK_CARD_START_POS_X_RAW                 = 0.5,
    SK_CARD_START_POS_Y                     = 25,   --最左边的牌的Y坐标

    SK_ZORDER_CARD_HAND                     = 900,
    SK_ZORDER_CARD_THROWN                   = 1000,
    SK_ZORDER_CARD_SHOWN                    = 1000,
    SK_ZORDER_UP_TIP                        = 1200,
    SK_ZORDER_SELFINFO                      = 1300,
    SK_ZORDER_PLAYERINFO                    = 1400,
    SK_ZORDER_FINISH_TASK                   = 1411,  --完成任务的效果
    SK_ZORDER_THROWN_ANIMATION              = 1500,
    SK_ZORDER_RANK_CARD                     = 1555,  --级牌显示成绩
    SK_ZORDER_TOOLS                         = 1560,  --工具栏层
    SK_ZORDER_ARENA_INFO                    = 1590,  --竞技场信息栏
    SK_ZORDER_CHAT                          = 1600,
	SK_ZORDER_RULE                          = 1700,
    SK_ZORDER_RESULT                        = 1800,
    SK_ZORDER_BREAK_EGGS                    = 1801, --金蛋动画的层级
    SK_ZORDER_CHARTEREDROOM                 = 1899, --包房层级
    SK_ZORDER_SETTING                       = 1900,
    SK_ZORDER_CUSTOM_PROMPT                 = 1910,
    SK_ZORDER_ARENA_RESULT                  = 2000,
    SK_ZORDER_UPGRADE_PANLE                 = 2500, --升级界面
    

    SK_DEAL_CARDS_INTERVAL                  = 0.08,
    SK_AUTO_QUIT_INTERVAL                   = 70,

    SK_JOKER_COUNT                          = 0,

    SK_THROW_WAIT                           = 20,   --出牌等待时间

    SK_LAYOUT_MOD                           = 13,
    SK_LAYOUT_NUM                           = 16,

    SK_LAYOUT_MOD_1                         = 14,
    SK_LAYOUT_NUM_1                         = 59,
    SK_LAYOUT_NUM_EX_1                      = 17,

    SK_MAX_UNITE_LENGTH                     = 10,
    SK_MAX_FIT_TYPE                         = 5,    --一手牌，最多解析为5种不同的牌型

    SK_AUTO_END_GAME                        = 90,   --自动脱离卡死时间
    SK_AUTO_CHECK_OFFLINE                   = 3,    --自动检测断线
    SK_CHECK_ONLINE_WAIT                    = 5,    --间隔5秒检查是否在线
    SK_ASK_ONLINE_SPACE                     = 30,   --30秒内最多做一次在线检查

    SK_INVALID_OBJECT_ID                    = -1,
    SK_INVALID_RELATIONSHIP                 = -2,

    SK_CS_DIAMOND                           = 0,    --方块
    SK_CS_CLUB                              = 1,    --草花
    SK_CS_HEART                             = 2,    --红心
    SK_CS_SPADE                             = 3,    --黑桃
    SK_CS_KING                              = 4,    --王牌
    SK_CS_JOKER                             = 5,    --百搭
    SK_CS_TOTAL                             = 5,

    SK_GF_USE_JOKER                         = 0x00000001,   --有百搭
    SK_GF_BOMB_SINGLE                       = 0x00000002,   --炸弹可以带1张散牌
    SK_GF_A23_ABT                           = 0x00000004,   --A23可以构成顺子
    SK_GF_ABT_A_END                         = 0x00000008,   --顺子到A为止

    SK_GW_SINGLE                            = 0x00010000,   --单扣
    SK_GW_COUPLE                            = 0x00020000,   --双扣

    --1.0
    SK_CT_SINGLE                            = 0x00000001,   --单张
    SK_CT_COUPLE                            = 0x00000002,   --对子
    SK_CT_THREE                             = 0x00000004,   --三同张
    SK_CT_ABT_SINGLE                        = 0x00000010,   --顺子
    SK_CT_ABT_COUPLE                        = 0x00000020,   --连对
    SK_CT_ABT_THREE                         = 0x00000040,   --连三同张
    SK_CT_BOMB                              = 0x00000100,   --炸弹
    SK_CT_ABT_BOMB                          = 0x00000200,   --连炸
    SK_CT_JOKER_BOMB                        = 0x00000400,   --天王炸
    SK_CT_THREE2                            = 0x00001000,   --三带二
    SK_CT_BUTTERFLY                         = 0x00002000,   --蝴蝶

    --2.0
    SK_CARD_UNITE_TYPE_SINGLE               = 0x00000001,   --单牌
    SK_CARD_UNITE_TYPE_COUPLE               = 0x00000002,   --对子
    SK_CARD_UNITE_TYPE_THREE                = 0x00000004,   --三张
    SK_CARD_UNITE_TYPE_THREE_1              = 0x00000008,   --3带1，1可以是散牌
    SK_CARD_UNITE_TYPE_THREE_2              = 0x00000010,   --3带2，2可以是散牌
    SK_CARD_UNITE_TYPE_THREE_COUPLE         = 0x00000020,   --3带2，2必须是对子
    SK_CARD_UNITE_TYPE_ABT_SINGLE           = 0x00000040,   --顺子
    SK_CARD_UNITE_TYPE_ABT_COUPLE           = 0x00000100,   --连对
    SK_CARD_UNITE_TYPE_ABT_THREE            = 0x00000200,   --三连张
    SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE     = 0x00000400,   --3连对带2连对，注意不支持财神
    SK_CARD_UNITE_TYPE_BOMB                 = 0x00001000,   --炸弹,4张
    SK_CARD_UNITE_TYPE_ABT_BOMB             = 0x00002000,   --连炸
    SK_CARD_UNITE_TYPE_TONGHUASHUN          = 0x00004000,   --同花顺
    SK_CARD_UNITE_TYPE_SUPER_BOMB           = 0x00008000,   --炸弹,4张
    SK_CARD_UNITE_TYPE_4KING                = 0x00080000,   --4王

    SK_CARD_UNITE_TYPE_BUG                  = 0x10000000,   --BUG一把扔
    SK_CARD_UNITE_TYPE_PASS                 = 0x20000000,   --不出

    SK_COMPARE_UNITE_TYPE_SINGLE            = 0x00000001,   --SK_CARD_UNITE_TYPE_SINGLE
    SK_COMPARE_UNITE_TYPE_COUPLE            = 0x00000002,   --SK_CARD_UNITE_TYPE_COUPLE
    SK_COMPARE_UNITE_TYPE_THREE             = 0x00000004,   --SK_CARD_UNITE_TYPE_THREE
    SK_COMPARE_UNITE_TYPE_THREE_COUPLE      = 0x00000020,   --SK_CARD_UNITE_TYPE_THREE_COUPLE
    SK_COMPARE_UNITE_TYPE_ABT_SINGLE        = 0x00000040,   --SK_CARD_UNITE_TYPE_ABT_SINGLE
    SK_COMPARE_UNITE_TYPE_ABT_COUPLE        = 0x00000100,   --SK_CARD_UNITE_TYPE_ABT_COUPLE
    SK_COMPARE_UNITE_TYPE_ABT_THREE         = 0x00000200,   --SK_CARD_UNITE_TYPE_ABT_THREE
    SK_COMPARE_UNITE_TYPE_ABT_THREE_COUPLE  = 0x00000400,   --SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE
    SK_COMPARE_UNITE_TYPE_SUPER_BOMB        = 0,
    SK_COMPARE_UNITE_TYPE_TONGHUASHUN       = 0,

    SK_COMPARE_UNITE_TYPE_BOMB              = 0,
    SK_COMPARE_UNITE_TYPE_4KING             = 0,

    SK_CARD_UNITE_TYPE_TOTAL                = 0,

    SK_CARD_STATUS_WAITDEAL                 = 0,        --等待发牌
    SK_CARD_STATUS_INHAND                   = 1,        --手中
    SK_CARD_STATUS_THROWDOWN                = 2,        --被打出
    SK_CARD_STATUS_COST                     = 3,        --废牌
    SK_CARD_STATUS_LAYDOWN                  = 4,        --放牌
    SK_CARD_STATUS_TRIBUTE                  = 5,        --进贡
    SK_CARD_STATUS_SCORECARD                = 6,        --分牌
    SK_CARD_STATUS_HIDE                     = 7,        --隐藏
    SK_CARD_STATUS_BOTTOM                   = 8,        --底牌

    SK_WAITING_THROW_CARDS                  = 100,
    SK_WAITING_PASS_CARDS                   = 101,
    SK_WAITING_AUCTIONBANKER                = 102,

    SK_GAME_MSG_DATA_LENGTH                 = 256,
    SK_GAME_MSG_SEND_EVERYONE               = -1,       --包括自己,包括旁观
    SK_GAME_MSG_SEND_OTHER                  = -2,       --除了自己,包括旁观
    SK_GAME_MSG_SEND_EVERY_PLAYER           = -3,       --发送给包括自己的其他玩家
    SK_GAME_MSG_SEND_OTHER_PLAYER           = -4,       --发送给包括自己的其他玩家
    SK_GAME_MSG_SEND_VISITOR                = -5,       --发送给所有旁观者

    SK_SYSMSG_BEGIN                         = 19840323,
    SK_SYSMSG_RETURN_GAME                   = 19840324,
    SK_SYSMSG_PLAYER_ONLINE                 = 19840325, --玩家在线
    SK_SYSMSG_PLAYER_OFFLINE                = 19840326, --有人掉线了
    SK_SYSMSG_GAME_CLOCK_STOP               = 19840327, --游戏时钟停止5秒时发送该请求
    SK_SYSMSG_GAME_DATA_ERROR               = 19840328, --游戏时钟停止5秒时发送该请求
    SK_SYSMSG_GAME_ON_AUTOPLAY              = 19840329, --客户端托管
    SK_SYSMSG_GAME_CANCEL_AUTOPLAY          = 19840330, --托管中止
    SK_SYSMSG_GAME_WIN                      = 19840331, --游戏结束
    SK_SYSMSG_GAME_TEST                     = 19840332,
    SK_SYSMSG_END                           = 19840333,
    --游戏消息，注意与PC端共通,必须是流程消息，会保存到replay
    SK_LOCAL_GAME_MSG_BEGIN                 = 19840334,
    SK_LOCAL_GAME_MSG_AUTO_THROW            = 19840335, --出牌
    SK_LOCAL_GAME_MSG_AUTO_PASS             = 19840336, --过牌
    SK_LOCAL_GAME_MSG_FRIENDCARD            = 19840337, --对家牌
    SK_LOCAL_GAME_MSG_END                   = 19840338,

    SK_GR_SENDMSG_TO_PLAYER                 = 229500,   --系统通知，转发其他玩家
    SK_GR_SENDMSG_TO_SERVER                 = 229510,   --系统通知, 发送给系统
    SK_GR_INITIALLIZE_REPLAY                = 229520,   --初始化replay

    --request (from game clients)
    SK_GR_AUCTION_BANKER                    = 221070,   --玩家叫庄信息
    SK_GR_THROW_CARDS                       = 221080,   --玩家出牌信息
    SK_GR_PASS_CARDS                        = 223000,   --玩家放弃出牌

    SK_GR_GAINS_BONUS                       = 211090,   --奖励通知

    --response (to game clients)
    SK_GR_THROW_AGAIN                       = 221100,   --返回合法出牌

    --nofication (to game clients)
    SK_GR_GAME_START                        = 211040,
    SK_GR_GAME_WIN                          = 211080,

    SK_GR_BANKER_AUCTION                    = 221165,   --玩家叫庄通知
    SK_GR_AUCTION_FINISHED                  = 221168,   --叫庄结束通知
    SK_GR_CARDS_THROW                       = 221170,   --玩家出牌通知
    SK_GR_INVALID_THROW                     = 221175,   --非法出牌通知
    SK_GR_CARDS_INFO                        = 221200,   --旁观看牌内容
    SK_GR_CARDS_PASS                        = 223100,   --玩家放弃通知
   
    GR_TOCLIENT_OFFLINE                     = 211240,

	    --local SK_UP_STATE = {
    SK_UP_SUCCESS      = 1,
    SK_UP_FULL         = 2,
    SK_UP_SELF_FULL    = 3,
    SK_UP_OTHER_FULL   = 4,
    SK_UP_SAME_ROUND   = 5,
    --}
	SORT_CARD_BY_ORDER                      = 1,
    SORT_CARD_BY_NUM                        = 2,
    SORT_CARD_BY_SHPAE                      = 3,
    SORT_CARD_BY_BOME                       = 4,

    CardKTagActionY                         = 100,
    CardKTagActionX                         = 101,
}

local SKGameDef = cc.exports.SKGameDef
local SKPublicInterface                     = import("src.app.Game.mSKGame.SKPublicInterface")
if SKPublicInterface then
    SKGameDef.SK_COMPARE_UNITE_TYPE_BOMB    = SKPublicInterface:bits_or(
                                             SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE)

    SKGameDef.SK_COMPARE_UNITE_TYPE_4KING   = SKPublicInterface:bits_or(
                                             SKGameDef.SK_CARD_UNITE_TYPE_4KING
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_BOMB
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                                            ,SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE)

    SKGameDef.SK_CARD_UNITE_TYPE_TOTAL      = SKPublicInterface:bits_or(
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
end

return cc.exports.SKGameDef
