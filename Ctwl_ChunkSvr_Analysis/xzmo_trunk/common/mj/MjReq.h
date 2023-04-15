#pragma once

//From tcgkd1.0
#define     GR_AUCTION_BANKER       (GAME_REQ_BASE_EX + 22070)      // 玩家叫庄信息
#define     GR_THROW_CARDS          (GAME_REQ_BASE_EX + 22080)      // 玩家出牌信息
#define     GR_THROW_AGAIN          (GAME_REQ_BASE_EX + 22100)      // 返回合法出牌
#define     GR_BANKER_AUCTION       (GAME_REQ_BASE_EX + 22165)      // 玩家叫庄通知
#define     GR_AUCTION_FINISHED     (GAME_REQ_BASE_EX + 22168)      // 叫庄结束通知
#define     GR_CARDS_THROW          (GAME_REQ_BASE_EX + 22170)      // 玩家出牌通知
#define     GR_INVALID_THROW        (GAME_REQ_BASE_EX + 22175)      // 非法出牌通知
#define     GR_MERGE_THROWCARDS     (GAME_REQ_BASE_EX + 29211)      // 合并后的出牌消息   client->svr
#define     GR_MERGE_CARDSTHROW     (GAME_REQ_BASE_EX + 29212)      // 合并后的出牌消息   svr->client
// req id from 229000 to 229999
// request (from game clients)
#define     GR_CATCH_CARD           (GAME_REQ_BASE_EX + 29000)      // 玩家抓牌
#define     GR_GUO_CARD             (GAME_REQ_BASE_EX + 29005)      // 玩家过牌
#define     GR_PREPENG_CARD         (GAME_REQ_BASE_EX + 29010)      // 玩家准备碰牌
#define     GR_PREGANG_CARD         (GAME_REQ_BASE_EX + 29015)      // 玩家准备杠牌
#define     GR_PRECHI_CARD          (GAME_REQ_BASE_EX + 29020)      // 玩家准备吃牌

#define     GR_PENG_CARD            (GAME_REQ_BASE_EX + 29025)      // 玩家碰牌
#define     GR_CHI_CARD             (GAME_REQ_BASE_EX + 29030)      // 玩家吃牌
#define     GR_MN_GANG_CARD         (GAME_REQ_BASE_EX + 29045)      // 玩家杠牌(明杠)
#define     GR_AN_GANG_CARD         (GAME_REQ_BASE_EX + 29047)      // 玩家杠牌(暗杠)
#define     GR_PN_GANG_CARD         (GAME_REQ_BASE_EX + 29049)      // 玩家杠牌(碰杠)
#define     GR_HUA_CARD             (GAME_REQ_BASE_EX + 29060)      // 玩家补花
#define     GR_HU_CARD              (GAME_REQ_BASE_EX + 29080)      // 玩家胡牌

// response (to game clients)
#define     GR_HU_GAINS_LESS        (GAME_REQ_BASE_EX + 29100)      // 胡牌失败(花数不够)
#define     GR_NO_CARD_CATCH        (GAME_REQ_BASE_EX + 29101)      // 抓牌失败(无牌可抓)

// nofication (to game clients)
#define     GR_CARD_CAUGHT          (GAME_REQ_BASE_EX + 29160)      // 玩家抓牌
#define     GR_CARD_GUO             (GAME_REQ_BASE_EX + 29165)      // 玩家过牌
#define     GR_CARD_PREPENG         (GAME_REQ_BASE_EX + 29170)      // 玩家准备碰牌
#define     GR_CARD_PRECHI          (GAME_REQ_BASE_EX + 29175)      // 玩家准备吃牌
#define     GR_PREGANG_OK           (GAME_REQ_BASE_EX + 29180)      // 玩家可以杠牌

#define     GR_CARD_PENG            (GAME_REQ_BASE_EX + 29185)      // 玩家碰牌
#define     GR_CARD_CHI             (GAME_REQ_BASE_EX + 29190)      // 玩家吃牌
#define     GR_CARD_MN_GANG         (GAME_REQ_BASE_EX + 29195)      // 玩家杠牌(明杠)
#define     GR_CARD_AN_GANG         (GAME_REQ_BASE_EX + 29197)      // 玩家杠牌(暗杠)
#define     GR_CARD_PN_GANG         (GAME_REQ_BASE_EX + 29199)      // 玩家杠牌(碰杠)
#define     GR_CARD_HUA             (GAME_REQ_BASE_EX + 29210)      // 玩家补花
//吃碰杠牌重构begin
#define     GR_RECONS_CHI_CARD      (GAME_REQ_BASE_EX + 29213)      //吃
#define     GR_RECONS_PENG_CARD     (GAME_REQ_BASE_EX + 29214)      //碰
#define     GR_RECONS_MNGANG_CARD   (GAME_REQ_BASE_EX + 29215)      //明杠
#define     GR_RECONS_PNGANG_CARD   (GAME_REQ_BASE_EX + 29216)      //碰杠
#define     GR_RECONS_ANGANG_CARD   (GAME_REQ_BASE_EX + 29217)      //暗杠
#define     GR_RECONS_GUO_CARD      (GAME_REQ_BASE_EX + 29218)      //过
#define     GR_RECONS_FANGPAO       (GAME_REQ_BASE_EX + 29219)          //放炮
//end

#define     GR_GAMEDATA_ERROR   (GAME_REQ_BASE_EX + 29450)  //客户端服务器端数据不同步
//从sk2.0移植来
#define     GR_SENDMSG_TO_PLAYER   (GAME_REQ_BASE_EX + 29500)       //系统通知，转发其他玩家
#define     GR_SENDMSG_TO_SERVER   (GAME_REQ_BASE_EX + 29510)       //系统通知, 发送给系统
#define     GR_INITIALLIZE_REPLAY  (GAME_REQ_BASE_EX + 29520)       //初始化replay
#define     GAME_MSG_DATA_LENGTH 256

//一共256+40BYTE
#define  GAME_MSG_DATA_LENGTH                      256
#define  GAME_MSG_SEND_EVERYONE                     -1 //包括自己,包括旁观
#define  GAME_MSG_SEND_OTHER                        -2 //除了自己,包括旁观
#define  GAME_MSG_SEND_EVERY_PLAYER                 -3 //发送给包括自己的其他玩家
#define  GAME_MSG_SEND_OTHER_PLAYER                 -4 //发送给包括自己的其他玩家
#define  GAME_MSG_SEND_VISITOR                      -5 //发送给所有旁观者

enum GAMEMSG
{
    SYSMSG_BEGIN = 19840323,
    SYSMSG_RETURN_GAME,            //
    SYSMSG_PLAYER_ONLINE,          //玩家在线
    SYSMSG_PLAYER_OFFLINE,         //有人掉线了
    SYSMSG_GAME_CLOCK_STOP,        //游戏时钟停止。停止5秒时发送该请求,
    SYSMSG_GAME_DATA_ERROR,        //服务器端通知客户端数据消息有异常
    SYSMSG_GAME_ON_AUTOPLAY,       //客户端托管
    SYSMSG_GAME_CANCEL_AUTOPLAY,   //托管中止
    SYSMSG_GAME_WIN,               //游戏结束
    SYSMSG_GAME_TEST,
    SYSMSG_END,
    //游戏消息，注与客户端共通,必须是流程消息，会保存到replay
    LOCAL_GAME_MSG_BEGIN,
    LOCAL_GAME_MSG_AUTO_THROW,                //出牌
    LOCAL_GAME_MSG_AUTO_CATCH,                 //过牌
    LOCAL_GAME_MSG_FRIENDCARD,         //对家牌
    LOCAL_GAME_MSG_END,
};

//yqwautoplay begin
enum GAMEMSG_EX
{
    //游戏消息，注与客户端共通,必须是流程消息，会保存到replay
    GAMEMSGEX_BEGIN = LOCAL_GAME_MSG_END + 1,
    LOCAL_GAME_MSG_QUICK_CATCH,
    YQW_SYSMSG_PLAYER_ONLINE,
    LOCAL_GAME_MSG_CHI,
    LOCAL_GAME_MSG_PENG,
    LOCAL_GAME_MSG_MN_GANG,
    LOCAL_GAME_MSG_PN_GANG,
    LOCAL_GAME_MSG_AN_GANG,
    LOCAL_GAME_MSG_HU,
    LOCAL_GAME_MSG_ZIMO_HU,
    LOCAL_GAME_MSG_QGANG_HU,
    GAMEMSGEX_END
};
//yqwautoplay end
typedef struct _tagAUCTION_BANKER
{
    int nUserID;                                // 用户ID
    int nRoomID;                                // 房间ID
    int nTableNO;                               // 桌号
    int nChairNO;                               // 位置
    BOOL bPassed;                               // 放弃
    int nGains;                                 // 叫分
    int nReserved[4];
} AUCTION_BANKER, *LPAUCTION_BANKER;

typedef struct _tagBANKER_AUCTION
{
    int nUserID;                                // 用户ID
    int nChairNO;                               // 位置
    BOOL bPassed;                               // 放弃
    int nGains;                                 // 叫分
    int nReserved[4];
} BANKER_AUCTION, *LPBANKER_AUCTION;

typedef struct _tagAUCTION_FINISHED
{
    int nBanker;                                // 庄家
    int nObjectGains;                           // 标的
    int nBottomIDs[MAX_BOTTOM_CARDS];           // 底牌ID
    int nReserved[4];
} AUCTION_FINISHED, *LPAUCTION_FINISHED;

typedef struct _tagTHROW_CARDS
{
    int nUserID;                                // 用户ID
    int nRoomID;                                // 房间ID
    int nTableNO;                               // 桌号
    int nChairNO;                               // 位置
    BOOL bPassive;                              // 是否被动
    SENDER_INFO sender_info;                    // 发送者信息
    DWORD dwCardsType;                          // 牌型
    int nReserved[4];
    int nCardsCount;                            // 牌张数
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // 打出的牌(ID)
} THROW_CARDS, *LPTHROW_CARDS;

typedef struct _tagCARDS_THROW
{
    int nUserID;                                // 用户ID
    int nChairNO;                               // 位置
    int nNextChair;                             // 下一个
    BOOL bNextFirst;                            // 下一个是否第一手出牌
    BOOL bNextPass;                             // 下一个是否自动放弃
    int nRemains;                               // 剩下几张
    DWORD dwFlags[MAX_CHAIR_COUNT];             // 标志
    DWORD dwCardsType;                          // 牌型
    int nThrowCount;                            // 出牌第几手计数
    int nReserved[4];
    int nCardsCount;                            // 牌张数
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // 打出的牌(ID)
} CARDS_THROW, *LPCARDS_THROW;

typedef struct _tagTHROW_AGAIN
{
    int nReserved[4];
    int nCardsCount;                            // 牌张数
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // 打出的牌(ID)
} THROW_AGAIN, *LPTHROW_AGAIN;

typedef struct _tagTHROW_OK
{
    int nNextChair;                             // 下一个出牌
    BOOL bNextFirst;                            // 是否第一手
} THROW_OK, *LPTHROW_OK;
//From end

typedef struct _tagMJ_START_DATA
{
    TCHAR   szSerialNO[MAX_SERIALNO_LEN];
    int     nBoutCount;             // 第几局
    int     nBaseDeposit;           // 基本银子
    int     nBaseScore;             // 基本积分
    int     nBanker;                // 庄家椅子号
    int     nBankerHold;            // 连续坐庄局数
    int     nCurrentChair;          // 当前活动椅子号
    DWORD   dwStatus;               // 当前状态
    DWORD   dwCurrentFlags;         // 当前能否天胡

    int     nFirstCatch;            // 先摸牌的人的座位
    int     nFirstThrow;            // 先出牌的人的座位

    int     nThrowWait;             // 出牌等待时间(秒)
    int     nMaxAutoThrow;          // 由系统指定的最大自动出牌数,达到这个数目就断线
    int     nEntrustWait;           // 托管等待时间(秒)

    BOOL    bNeedDeposit;           // 是否需要银子
    BOOL    bForbidDesert;          // 禁止强退

    int     nDices[MAX_DICE_NUM];   // 骰子大小
    BOOL    bQuickCatch;            // 快速抓牌
    BOOL    bAllowChi;              // 允许吃
    BOOL    bAnGangShow;            // 暗杠的牌能否显示
    BOOL    bJokerSortIn;           // 财神牌不固定放头上
    BOOL    bBaibanNoSort;          // 替代财神牌不排序放
    int     nBeginNO;               // 开始摸牌位置
    int     nJokerNO;               // 财神位置
    int     nJokerID;               // 财神牌ID
    int     nJokerID2;              // 财神牌ID2
    int     nFanID;                 // 翻牌ID
    int     nTailTaken;             // 尾上被抓牌张数
    int     nCurrentCatch;          // 当前抓牌位置
    int     nPGCHWait;              // 碰杠吃胡等待时间(秒)
    int     nPGCHWaitEx;            // 碰杠吃胡等待时间(追加)(秒)

    int     nReserved[8];
} MJ_START_DATA, *LPMJ_START_DATA;

typedef struct _tagMJ_PLAY_DATA
{
    CARDS_UNIT  PengCards[MJ_CHAIR_COUNT][MJ_MAX_PENG]; // 碰出的牌
    int         nPengCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  ChiCards[MJ_CHAIR_COUNT][MJ_MAX_CHI];   // 吃出的牌
    int         nChiCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  MnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 明杠出的牌
    int         nMnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  AnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 暗杠出的牌
    int         nAnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  PnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 碰杠出的牌
    int         nPnGangCount[MJ_CHAIR_COUNT];
    int         nOutCards[MJ_CHAIR_COUNT][MJ_MAX_OUT];  // 打出的牌
    int         nOutCount[MJ_CHAIR_COUNT];
    int         nHuaCards[MJ_CHAIR_COUNT][MJ_MAX_HUA];  // 补花打出的牌
    int         nHuaCount[MJ_CHAIR_COUNT];

    int     nReserved[8];
} MJ_PLAY_DATA, *LPMJ_PLAY_DATA;

typedef struct _tagTABLE_INFO_MJ
{
    //From TABLE_INFO
    int     nTableNO;                           // 桌号
    int     nScoreMult;                         // 积分放大
    int     nTotalChairs;                       // 椅子数目
    DWORD   dwGameFlags;                        // 游戏特征选项
    DWORD   dwUserConfig[MAX_CHAIRS_PER_TABLE]; // 用户设置
    DWORD   dwRoomOption[MAX_CHAIRS_PER_TABLE]; // 房间设置
    BOOL    bTableEqual;                        // 是否桌子相同
    BOOL    bNeedDeposit;                       // 是否需要银子
    BOOL    bForbidDesert;                      // 是否禁止强退
    int     nDepositMult;                       // 银子加倍
    int     nDepositMin;                        // 最少银子
    int     nFeeRatio;                          // 手续费百分比
    int     nMaxTrans;                          // 最大输赢
    int     nCutRatio;                          // 逃跑扣银百分比
    int     nDepositLogDB;                      // 记录日志最小银子
    int     nRoundCount;                        // 第几轮
    int     nBoutCount;                         // 第几局
    int     nBanker;                            // 庄家位置
    int     nPartnerGroup[MAX_CHAIRS_PER_TABLE];// 所属组
    int     nDices[MAX_DICE_NUM];               // 骰子大小
    DWORD   dwStatus;                           // 状态
    int     nCurrentChair;                      // 当前活动位置
    DWORD   dwCostTime[MAX_CHAIRS_PER_TABLE];   // 总共耗费时间
    int     nAutoCount[MAX_CHAIRS_PER_TABLE];   // 自动出牌计数
    int     nBreakCount[MAX_CHAIRS_PER_TABLE];  // 断线续玩计数
    DWORD   dwUserStatus[MAX_CHAIRS_PER_TABLE]; // 用户状态
    int     nBaseScore;                         // 本局基本积分
    int     nBaseDeposit;                       // 本局基本银子
    DWORD   dwWinFlags;                         // 输赢标志
    DWORD   dwIntermitTime;                     // 中断时间
    DWORD   dwBoutFlags;                        // 本局相关标志(与上局NextFlags等值)
    DWORD   dwRoomConfigs;                      // 房间设置

    //Form TABLE_INFO_KD
    int     nTotalCards;                        // 牌的张数
    int     nTotalPacks;                        // 几副牌
    int     nChairCards;                        // 每人的牌张数
    int     nBottomCards;                       // 底牌张数
    int     nLayoutNum;                         // 牌的方阵长度
    int     nLayoutMod;                         // 牌阵模数长度
    int     nLayoutNumEx;                       // 牌的方阵长度(扩展)
    int     nThrowWait;                         // 出牌等待时间(秒)
    int     nMaxAutoThrow;                      // 允许自动出牌的最大次数
    int     nEntrustWait;                       // 托管等待时间(秒)
    int     nMaxAuction;                        // 允许最大叫分
    int     nMinAuction;                        // 允许最小叫分
    int     nDefAuction;                        // 默认叫分
    int     nFirstCatch;                        // 第一个摸牌
    int     nFirstThrow;                        // 第一个出牌
    int     nBottomIDs[MAX_BOTTOM_CARDS];       // 底牌ID
    int     nIDMatrix[MAX_CHAIRS_PER_TABLE][MAX_CARDS_PER_CHAIR];   // 牌ID方阵
    int     nAuctionCount;                      // 叫庄计数
    AUCTION Auctions[MAX_AUCTION_COUNT];        // 叫庄情况记录
    int     nObjectGains;                       // 叫分标的
    int     nCatchFrom;                         // 开始摸牌位置
    int     nJokerNO;                           // 财神位置
    int     nJokerID;                           // 财神牌ID
    int     nThrowCount;                        // 出牌第几手计数

    int     nPGCHWait;          // 碰杠吃胡等待时间(秒)
    int     nMaxBankerHold;     // 最大连续坐庄局数
    DWORD   dwHuFlags[MJ_HU_FLAGS_ARYSIZE];     // 胡牌种类标志数组
    BOOL    bQuickCatch;        // 快速抓牌
    int     nBankerHold;        // 连续坐庄局数
    int     nJokerID2;          // 财神牌ID2
    int     nHeadTaken;         // 头上被抓牌张数
    int     nTailTaken;         // 尾上被抓牌张数
    int     nCurrentCatch;      // 当前抓牌位置
    DWORD   dwPGCHFlags[MJ_CHAIR_COUNT];    // 出牌后碰杠吃胡状态
    DWORD   dwGuoFlags[MJ_CHAIR_COUNT];     // 出牌后能否过牌标志
    int     nGangID;            // 杠牌ID
    int     nGangChair;         // 杠牌位置
    int     nCardChair;         // 牌所属位置
    int     nJokersThrown[MJ_CHAIR_COUNT]; // 财神打出个数
    int     nCaiPiaoChair;      // 财飘位置
    int     nCaiPiaoCount;      // 财飘个数
    int     nGangKaiCount;      // 杠开计数
    int     nPengFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // 被别人碰计数
    int     nChiFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // 被别人吃计数
    int     nGangFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // 被别人杠计数
    CARDS_UNIT  PengCards[MJ_CHAIR_COUNT][MJ_MAX_PENG]; // 碰出的牌
    int         nPengCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  ChiCards[MJ_CHAIR_COUNT][MJ_MAX_CHI];   // 吃出的牌
    int         nChiCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  MnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 明杠出的牌
    int         nMnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  AnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 暗杠出的牌
    int         nAnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  PnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // 碰杠出的牌
    int         nPnGangCount[MJ_CHAIR_COUNT];
    int         nOutCards[MJ_CHAIR_COUNT][MJ_MAX_OUT];  // 打出的牌
    int         nOutCount[MJ_CHAIR_COUNT];
    int         nHuaCards[MJ_CHAIR_COUNT][MJ_MAX_HUA];  // 补花打出的牌
    int         nHuaCount[MJ_CHAIR_COUNT];

    int         nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int         nTotalResult[MAX_CHAIR_COUNT];

    int         nReserved[4];
} TABLE_INFO_MJ, *LPTABLE_INFO_MJ;

typedef struct _tagGAME_WIN_MJ
{
    GAME_WIN    gamewin;
    int         nNewRound;                      // 下一局是新一轮开始

    int nMnGangs[MJ_CHAIR_COUNT];
    int nAnGangs[MJ_CHAIR_COUNT];
    int nPnGangs[MJ_CHAIR_COUNT];
    int nHuaCount[MJ_CHAIR_COUNT];

    int nResults[MJ_CHAIR_COUNT];   // 胡牌结果
    int nHuChairs[MJ_CHAIR_COUNT];  // 玩家是否胡牌
    int nLoseChair;     // 放冲或者被抢杠者位置
    int nHuChair;       // 胡牌位置
    int nHuCard;        // 胡牌ID
    int nBankerHold;    // 本局是几连庄
    int nNextBanker;    // 下一局谁做庄
    int nChengBaoID;    // 承包者ID
    int nHuCount;       // 胡牌人数

    int nTingChairs[MJ_CHAIR_COUNT];    // 玩家是否听牌
    int nTingCount;                     // 听牌人数
    int nDetailCount;                   // 详细个数

    int nReserved[26];
} GAME_WIN_MJ, *LPGAME_WIN_MJ;

typedef struct _tagCATCH_CARD
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    BOOL bPassive;              // 是否被动
    SENDER_INFO sender_info;    // 发送者信息
    int nReserved[4];
} CATCH_CARD, *LPCATCH_CARD;

typedef struct _tagCARD_CAUGHT
{
    int nChairNO;               // 位置
    int nCardID;                // 牌ID
    int nCardNO;                // 牌位置
    DWORD dwFlags;              // 标志
    int nReserved[4];
} CARD_CAUGHT, *LPCARD_CAUGHT;

typedef struct _tagGUO_CARD
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    int nCardChair;             // 牌所属位置
    int nCardID;                // 牌ID
    int nReserved[4];
} GUO_CARD, *LPGUO_CARD;

typedef struct _tagCOMB_CARD
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    int nCardChair;             // 吃碰杠牌所属位置
    int nCardID;                // 吃碰杠牌ID
    int nBaseIDs[MJ_UNIT_LEN - 1];// 手里或碰出的牌
    DWORD dwFlags;              // 标志位
    int nCardGot;               // 杠到的牌
    int nCardNO;                // 杠到的牌位置
    int nReserved[4];
} COMB_CARD, *LPCOMB_CARD;

typedef COMB_CARD PREPENG_CARD;
typedef LPCOMB_CARD LPPREPENG_CARD;

typedef COMB_CARD CARD_PREPENG;
typedef LPCOMB_CARD LPCARD_PREPENG;

typedef COMB_CARD PREGANG_CARD;
typedef LPCOMB_CARD LPPREGANG_CARD;

typedef COMB_CARD CARD_PREGANG;
typedef LPCOMB_CARD LPCARD_PREGANG;

typedef COMB_CARD PRECHI_CARD;
typedef LPCOMB_CARD LPPRECHI_CARD;

typedef COMB_CARD CARD_PRECHI;
typedef LPCOMB_CARD LPCARD_PRECHI;

typedef COMB_CARD PENG_CARD;
typedef LPCOMB_CARD LPPENG_CARD;

typedef COMB_CARD CARD_PENG;
typedef LPCOMB_CARD LPCARD_PENG;

typedef COMB_CARD CHI_CARD;
typedef LPCOMB_CARD LPCHI_CARD;

typedef COMB_CARD CARD_CHI;
typedef LPCOMB_CARD LPCARD_CHI;

typedef COMB_CARD GANG_CARD;
typedef LPCOMB_CARD LPGANG_CARD;

typedef COMB_CARD CARD_GANG;
typedef LPCOMB_CARD LPCARD_GANG;

typedef struct _tagPREGANG_OK
{
    int nChairNO;               // 位置
    int nCardChair;             // 吃碰杠牌所属位置
    int nCardID;                // 吃碰杠牌ID
    DWORD dwFlags;              // 标志位
    DWORD dwResults[MJ_CHAIR_COUNT];
    int nReserved[4];
} PREGANG_OK, *LPPREGANG_OK;

typedef struct _tagHUA_CARD
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    int nCardID;                // 花牌ID
    int nCardGot;               // 杠到的牌
    int nCardNO;                // 杠到的牌位置
    int nReserved[4];
} HUA_CARD, *LPHUA_CARD;

typedef HUA_CARD CARD_HUA;
typedef LPHUA_CARD LPCARD_HUA;

typedef struct _tagHU_CARD
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    int nCardChair;             // 胡牌所属位置
    int nCardID;                // 胡牌ID
    DWORD dwFlags;              // 标志位
    DWORD dwSubFlags;           // 辅助标志位
    int nReserved[4];
} HU_CARD, *LPHU_CARD;

typedef struct _tagGAME_ENTER_INFO
{
    ENTER_INFO     ei;
    int            nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int            nTotalResult[MAX_CHAIR_COUNT];
    int            nReserve[4];
} GAME_ENTER_INFO, *LPGAME_ENTER_INFO;

//事件
typedef struct _tagGAME_EVENT
{
    DWORD dwEventTime;                //事件时间
    DWORD dwEventIndex;               //事件序号
    DWORD dwOperateType;              //操作类型
    int   data[GAME_MSG_DATA_LENGTH]; //数据段
} GAME_EVENT, *LPGAME_EVENT;

typedef struct _tagGAME_MSG
{
    int   nRoomID;
    int   nUserID;                    // 用户ID            4
    int   nMsgID;                     // 消息号            4
    int   nVerifyKey;                 // 验证码            4
    int   nDatalen;                   // 数据长度          4
} GAME_MSG, *LPGAME_MSG;

typedef struct _tagMERGE_THROWCARDS
{
    int nUserID;                            // 用户ID
    int nRoomID;                            // 房间ID
    int nTableNO;                           // 桌号
    int nChairNO;                           // 位置
    BOOL bPassive;                          // 是否被动
    SENDER_INFO sender_info;                 // 发送者信息
    DWORD dwCardsType;                      // 牌型
    int nReserved[4];
    int nCardsCount;                        // 牌张数
    CARD_CAUGHT card_caught;                 // 抓牌的牌张信息
    int nCardIDs[MAX_CARDS_PER_CHAIR];      // 打出的牌(ID)
} MERGE_THROWCARDS, *LPMERGE_THROWCARDS;

typedef struct _tagCARD_TING_DETAIL
{
    DWORD   dwflags;
    int     nChairNO;
    int     nThrowCardsTing[MJ_GF_14_HANDCARDS];
    BYTE    nThrowCardsTingLays[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  // 出了某张牌之后能听的牌
    BYTE    nThrowCardsTingFan[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  //出了某张牌之后听的番数
    BYTE    nThrowCardsTingRemain[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];//听牌剩余的张数
    int     nReserved[4];
} CARD_TING_DETAIL, *LPCARD_TING_DETAIL;

typedef struct _tagCARD_TING_DETAIL_16
{
    DWORD   dwflags;
    int     nChairNO;
    int     nThrowCardsTing[MJ_GF_17_HANDCARDS];
    BYTE    nThrowCardsTingLays[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  // 出了某张牌之后能听的牌
    BYTE    nThrowCardsTingFan[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  //出了某张牌之后听的番数
    BYTE    nThrowCardsTingRemain[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];//听牌剩余的张数
    int     nReserved[4];
} CARD_TING_DETAIL_16, *LPCARD_TING_DETAIL_16;

typedef struct _tagMERGE_CARDSTHROW
{
    int nUserID;                                    // 用户ID
    int nChairNO;                                   // 位置
    int nNextChair;                                 // 下一个
    BOOL bNextFirst;                                // 下一个是否第一手出牌
    BOOL bNextPass;                                 // 下一个是否自动放弃
    int nRemains;                                   // 剩下几张
    DWORD dwFlags[MAX_CHAIR_COUNT];                 // 标志
    DWORD dwCardsType;                              // 牌型
    int nThrowCount;                                // 出牌第几手计数
    int nReserved[4];
    int nCardsCount;                                // 牌张数
    CARD_CAUGHT card_caught;                        // 抓牌的牌张信息
    int nCardIDs[MAX_CARDS_PER_CHAIR];              // 打出的牌(ID)
} MERGE_CARDSTHROW, *LPMERGE_CARDSTHROW;
