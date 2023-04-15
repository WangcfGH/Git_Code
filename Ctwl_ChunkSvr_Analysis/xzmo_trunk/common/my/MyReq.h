#pragma once
#include "../common/TaskReq.h"
#define     GR_PB_ENTER_GAME        (GAME_REQ_BASE_EX + 19001)

#define     GR_GAMEDATA_ERROR       (GAME_REQ_BASE_EX + 29450)  //游戏卡死
#define     GR_SYSTEMMSG            (GAME_REQ_BASE_EX + 29800)  //系统通知 
#define     GR_EXCHANGE_CARDS               (GAME_REQ_BASE_EX + 29820)  //请求换三张
#define     GR_EXCHANGE3CARDS_FINISHED      (GAME_REQ_BASE_EX + 29821)  //换3张结束通知
#define     GR_TASK_AWARD                   (GAME_REQ_BASE_EX + 29830)  //任务，有奖励的通知   
#define     GR_PLAYER_RECHARGE              (GAME_REQ_BASE_EX + 29840)  //玩家准备充值
#define     GR_PLAYER_RECHARGEOK            (GAME_REQ_BASE_EX + 29841)  //玩家准备充值
#define     GR_PLAYER_GOSENIOR              (GAME_REQ_BASE_EX + 29850)  //玩家显示去高级房
#define     GR_GET_WELFAREPRESENT           (GAME_REQ_BASE_EX + 29860)  //获取低保配置
#define     GR_GET_CHARGE_INFO              (GAME_REQ_BASE_EX + 29870)  //网页充值信息
#define     GR_ABORTPLAYER_INFO_DXXW        (GAME_REQ_BASE_EX + 29880)  //断线续玩，已离开用户的信息下发

#define     GR_ENTER_IN_TABLE               (GAME_REQ_INDIVIDUAL + 101)  //进入桌子后的消息，包括idle,dxxw
#define     GR_ON_PLAYER_HU                 (GAME_REQ_INDIVIDUAL + 102)  //血战先胡牌将相关结算信息发回去
#define     GR_MY_TAKE_SAFE_DEPOSIT         (GAME_REQ_INDIVIDUAL + 103)  //放开可以游戏中取银
#define     GR_PLAYING_DEPOSIT_NOT_ENOUGH   (GAME_REQ_INDIVIDUAL + 104)  //打牌过程中钱不足
#define     GR_ON_PLAYER_GIVE_UP            (GAME_REQ_INDIVIDUAL + 105)  //认输
#define     GR_PRE_SAVE_RESULT              (GAME_REQ_INDIVIDUAL + 106)  //提前结算
#define     GR_MY_TAKE_BACK_DEPOSIT         (GAME_REQ_INDIVIDUAL + 107)  //放开可以游戏中取银,后备箱

#define     UR_OPERATE_CANCEL               (UR_REQ_BASE + 10110)

/////////////////////////////////////////与RoomSvr的通讯自定义Windows消息
#define     WM_GTR_RECORD_USER_NETWORK_TYPE_EX  (WM_USER+5004)           //将用户网络类型传给RoomSvr   
/////////////////////////////////////////

#define     UT_ROBOT                        0x40000000                   //机器人,自定义用户类型

enum XOGAMEMSGEX
{
    //游戏消息，注与客户端共通,必须是流程消息，会保存到replay
    XOGAMEMSGEX_BEGIN = GAMEMSGEX_END + 1,

    SYSMSG_GAME_AUTOKICKOFF,                        //自动踢人
    LOCAL_GAME_MSG_AUTO_HU,                         //胡牌
    LOCAL_GAME_MSG_AUTO_GUO,                        //服务端帮助客户端过牌
    LOCAL_GAME_MSG_AUTO_FIXMISS,                    //定缺
    LOCAL_GAME_MSG_AUTO_EXCHANGECARDS,              //换三张
    LOCAL_GAME_MSG_AUTO_GIVEUP,                     //放弃

    XOGAMEMSGEX_END
};

enum GameResultFlag
{
    ResultByMnGang = 1,
    ResultByPnGang,
    ResultByAnGang,
    ResultByHu,
    ResultByGiveUp,
    ResultByFee,
};

typedef struct _tagLOOKER_GAME_START_INFO
{
    MJ_START_DATA StartData;

    DWORD   dwGameFlags;        //游戏状态
    int     nChairNO;// 记录椅子号，客户端保存录像时区别
    int     nCardsCount[TOTAL_CHAIRS];  // 每个玩家手里的牌的张数
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // 玩家手里的牌
    int     nReserved[4];
} LOOKER_GAME_START_INFO, *LPLOOKER_GAME_START_INFO;

typedef struct _tagENTER_IN_TABLE
{
    int nMinDeposit;
    int nMaxDeposit;
    int nReserved[8];
} ENTER_IN_TABLE, *LPENTER_IN_TABLE;

typedef struct _tagCHECK_INFO
{
    int nHuaZhuPoint[TOTAL_CHAIRS];
    int nHuaZhuDeposit[TOTAL_CHAIRS];
    int nDaJiaoPoint[TOTAL_CHAIRS];
    int nDaJiaoDeposit[TOTAL_CHAIRS];
    int nDrawbackPoint[TOTAL_CHAIRS];
    int nDrawbackDeposit[TOTAL_CHAIRS];
    int nReserved[4];
} CHECK_INFO, *LPCHECK_INFO;

typedef struct _tagPRESAVE_INFO
{
    int nPreSaveDeposit;
    int nPreSaveAllDeposit;
    int nPreSaveAllFan;
    int nUserID;
} PRESAVE_INFO, *LPPRESAVE_INFO;

typedef struct _tagGIVEUP_INFO
{
    int nNeedDeposit;
    int nLastSecond;
    int nGiveUpChair[TOTAL_CHAIRS];
    int nReserved[4];
} GIVEUP_INFO, *LPGIVEUP_INFO;

typedef struct _tagPLAYER_RECHARGE
{
    int nUserID;                                // 用户ID
    int nRoomID;                                // 房间ID
    int nTableNO;                               // 桌号
    int nChairNO;                               // 位置
    int nDelayTime;                             // 延时时间
    int nReserved[4];
} PLAYER_RECHARGE, *LPPLAYER_RECHARGE;

typedef struct _tagPRE_SAVE_RESULT
{
    int nFlag;
    int nHuStatus;
    int nOldScores[TOTAL_CHAIRS];                   // 旧积分
    int nOldDeposits[TOTAL_CHAIRS];                 // 旧银子
    int nScoreDiffs[TOTAL_CHAIRS];                  // 积分增减
    int nDepositDiffs[TOTAL_CHAIRS];                // 银子输赢
    int nIdlePlayerFlag;                            // 玩家状态;低位0～7位表示各个玩家状态，1为IdlePlayer，已经结算的空闲玩家，或者后来进入的空闲玩家
    int nChairNO;
    int nPreSaveAllDeposit;
    int nReserved[2];
} PRE_SAVE_RESULT, *LPPRE_SAVE_RESULT;

typedef struct _tagHU_ITEM_INFO
{
    BOOL bWin;                                      //是否输赢
    BOOL bSend;                                     //是否已经发送
    int nHuFlag;                                    //MJ_HU_FANG,MJ_HU_ZIMO,MJ_HU_QGNG等
    int nHuID;                                      //胡牌ID
    int nHuFan;                                     //胡牌番数(这里传的倍数)
    int nHuDeposits;                                //胡牌输赢
    int nHuGains[HU_MAX];                           //胡牌番数
    int nRelateChair[TOTAL_CHAIRS];                 //关系玩家，放炮者或者被抢杠者或者被自摸的人
    int nReserved[4];
} HU_ITEM_INFO, *LPHU_ITEM_INFO;

typedef struct _tagHU_ITEM_HEAD
{
    int nCount;
    int nChairNO;
    int nPreSaveAllDeposit;
    int nReserved[4];
} HU_ITEM_HEAD, *LPHU_ITEM_HEAD;

typedef struct _tagHU_ITEM_HEAD_PC
{
    int nItemCount[TOTAL_CHAIRS];
    int nReserved[4];
} HU_ITEM_HEAD_PC, *LPHU_ITEM_HEAD_PC;

typedef struct _tagHU_ID_HEAD
{
    int nCount[TOTAL_CHAIRS];
    int nReserved[4];
} HU_ID_HEAD, *LPHU_ID_HEAD;

typedef struct _tagHU_DETAILS_SMALL
{
    int nChairNO;
    DWORD dwHuFlags[2];                             // 胡牌标志
    int nHuGains[HU_MAX];                           // 胡牌番数
    int nTotalGains;                                // 总番数
    int nTotalDeposits;                             // 总输赢
    int nLoseChair[TOTAL_CHAIRS];                   // 放炮玩家，被自摸
    CHECK_INFO stCheckInfo;                         // 花猪大叫得分
    int nReserved[4];
} HU_DETAILS_SMALL, *LPHU_DETAILS_SMALL;

typedef struct _tagGAME_WIN_RESULT
{
    GAME_WIN_MJ gamewin;

    int     nCardsCount[TOTAL_CHAIRS];              // 每个玩家手里的牌的张数
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // 自己手里的牌
    int     nFees[TOTAL_CHAIRS];
    int     nTotalDepositDiff[TOTAL_CHAIRS];        //一局内总输赢
    CARDS_UNIT  nOutCards[TOTAL_CHAIRS][4];     // 玩家碰杠吃出的牌(每个玩家最多4敦)
    int     nOutCount[TOTAL_CHAIRS];
    int     nReserved[8];
} GAME_WIN_RESULT, *LPGAME_WIN_RESULT;

//一共255BYTE
typedef struct _tagSYSTEMMSG
{
    int  nRoomID;                                   // 房间ID
    int  nUserID;                                   // 用户ID
    int  nMsgID;                                    // 消息号
    int  nChairNO;                                  // 位置
    int  nFangCardChairNO;                          // 放冲位置
    DWORD nEventID;                                 // 事件号
    DWORD nMJID;                                    // 牌号
} SYSTEMMSG, *LPSYSTEMMSG;

//做牌
enum PLAYER_TYPE
{
    PLAYER_BASE = 0,    //基础情况
    PLAYER_NEW_LEVEL_ONE,       // 一类玩家
    PLAYER_NEW_LEVEL_TWO,       // 二类玩家
    PLAYER_ROBOT,
    PLAYER_ROBOT_USER,
    PLAYER_LOSS,        //连输两局接下来一局
    PLAYER_JUMP,        //跳转房间后两局
    PLAYER_PAY,         //充值成功后三局
    PALYER_MAX
};

#define  MAX_TYPE   PALYER_MAX

//做牌
enum INTERVENE_TYPE
{
    INTERVENE_CATCH_BASE = 0,    //基础情况
    INTERVENE_CATCH_ROBOT,
    INTERVENE_CATCH_ROBOTTING,
    INTERVENE_THROW_ROBOT,
    INTERVENE_THROW_TING,
};

typedef struct _tagMAKECARD_INFO
{
    int nHandScore; //初始手牌分数
    int nMakeDeal; //0:未做牌；1:shape；2:type
    int nMakeExchange; //0:未做牌
    int nMakeCatch; //0:未做牌；1:shape；2:type
    int nMakeCount; //做牌次数
    int nLossCount; //连输局数
    int nJumpCount; //房间跳转后局数
    int nPayCount;  //充值后局数
    int nWinBout;
    int nReserved[4];
} MAKECARD_INFO, *LPMAKECARD_INFO;

typedef struct _tagMAKECARD_CONFIG
{

    int nDealOpen;              //发牌开关
    int nExchangeOpen;          //换三张开关
    int nCatchOpen;             //摸牌开关

    int nTotalBount[MAX_TYPE];  // 新手用户等级判断条件: 总局数
    int nWinBount[MAX_TYPE];    // 新手用户等级判断条件: 胜场

    int nDealPercent[MAX_TYPE]; //发牌概率
    int nDShapeScore[MAX_TYPE]; //发牌花色干预分
    int nDTypeScore[MAX_TYPE];  //发牌牌型干预分

    int nGangScore;             //杠牌力分数
    int nPengScore;             //碰牌力分数
    int nDuizScore;             //对牌力分数
    int nShunScore;             //顺牌力分数

    int nCatchPercent;          //抓牌概率
    int nCXZExpectBei;          //血战预期倍数
    int nCXLExpectBei;          //血流预期倍数
    int nCGPDPercent[3];        //杠碰对的比例
    int nCShapeScore[MAX_TYPE]; //摸牌花色干预分
    int nCTypeScore[MAX_TYPE];  //摸牌牌型干预分

    int nReserved[4];
} MAKECARD_CONFIG, *LPMAKECARD_CONFIG;

typedef struct _tagPROB
{
    int    nRemainCout;
    int    nGangCardProb;
    int    nPengCardProb;
    int    nHuCardProb;
    int    nNotDingQueCardProb;
} PROB, *LPPROB;

typedef struct _tagMAKECARDPROB
{
    //做牌干预概率
    vector<PROB>    vPlayBoutCatch;
    vector<PROB>    vRobotBoutCatch;
    vector<PROB>    vRobotBoutTingCatch;

    //机器人出牌概率
    vector<PROB>    vRobotBoutThrow;
    vector<PROB>    vRobotBoutTingThrow; //用户听牌后机器人出牌概率

    int nReserved[4];
} MAKECARD_PROB, *LPMAKECARDPROB;

//定缺
typedef struct _tagAUCTION_DINGQUE
{
    int nDingQueCardType[TOTAL_CHAIRS];             //定缺的牌 nCards
    BOOL bAuto;                                     //
    int nUserID;                                    // 用户ID
    int nRoomID;                                    // 房间ID
    int nTableNO;                                   // 桌号
    int nChairNO;                                   // 位置
    DWORD dPGCH[TOTAL_CHAIRS];
    int nReserved[4];
} AUCTION_DINGQUE, *LPAUCTION_DINGQUE;

//换三张
typedef struct _tagEXCHANGE3CARDS
{
    int nUserID;                                    // 用户ID
    int nRoomID;                                    // 房间ID
    int nTableNO;                                   // 桌号
    int nChairNO;                                   // 位置
    int nSendTable;                                 //
    int nSendChair;
    int nSendUser;
    int nExchange3CardsCount;
    int nExchangeDirection;
    int nExchange3Cards[TOTAL_CHAIRS][EXCHANGE3CARDS_COUNT];//jiaohuan的牌
    int nReserved[4];
} EXCHANGE3CARDS, *LPEXCHANGE3CARDS;

typedef struct _tagCOMB_CARD_EX
{
    int nUserID;                                    // 用户ID
    int nRoomID;                                    // 房间ID
    int nTableNO;                                   // 桌号
    int nChairNO;                                   // 位置
    int nCardChair;                                 // 吃碰杠牌所属位置
    int nCardID;                                    // 吃碰杠牌ID
    int nBaseIDs[MJ_UNIT_LEN - 1];                  // 手里或碰出的牌
    DWORD dwFlags;                                  // 标志位
    int nCardGot;                                   // 杠到的牌
    int nCardNO;                                    // 杠到的牌位置
    int nGangPoint[TOTAL_CHAIRS];
    int nReserved[4];
} COMB_CARD_EX, *LPCOMB_CARD_EX;

typedef struct _tagCARD_CAUGHT_EX
{
    int nChairNO;                                   // 位置
    int nCardID;                                    // 牌ID
    int nCardNO;                                    // 牌位置
    DWORD dwFlags;                                  // 标志
    int nGangPoint[TOTAL_CHAIRS];
    int nReserved[4];
} CARD_CAUGHT_EX, *LPCARD_CAUGHT_EX;

typedef COMB_CARD_EX GANG_CARD_EX;
typedef LPCOMB_CARD_EX LPGANG_CARD_EX;
typedef COMB_CARD_EX CARD_GANG_EX;
typedef LPCOMB_CARD_EX LPCARD_GANG_EX;


// 任务
/////////////////////////////////////////////////////////////////////

#define MAX_TYPE_COUNT 3

typedef struct _tagPLAYERTASKINFO
{
    int nUserID;
    TASKDATAEX taskDataEx[MAX_TYPE_COUNT];
} PLAYERTASKINFO, *LPPLAYERTASKINFO;

#define     EXCEPTION_PLAY_TIME         (60*60)     //异常对局时间(秒)

typedef struct _tagROLERECORD
{
    //玩家对局信息
    int         nUserID;                            //玩家ID
    int         nUserType;                          //玩家类型
    int         nBeginDeposit;                      //初始银两
    int         nTakeDeposit;                       //从保险箱或后备箱取出的银两
    int         nLeftDeposit;                       //剩余银两
    int         nDepositDiff;                       //输赢银两
    int         nTimeCost;                          //对战耗时耗时
    int         nHuCount;                           //胡牌次数
    int         nHuTotalFan;                        //总番数
    int         nHandScore;                         //初始牌力值
    int         nMakeDeal;                          //发牌干预
    int         nMakeCatch;                         //摸牌干预
    int         nPengCount;                         //碰次数
    int         nGangCount;                         //杠次数
    //CTime     goSeniorTime;                       //点击去高级房时间

    _tagROLERECORD()
    {
        nUserID = 0;
        nUserType = UT_COMMON;
        nBeginDeposit = 0;
        nTakeDeposit = 0;
        nLeftDeposit = 0;
        nDepositDiff = 0;
        nTimeCost = 0;
        nHuCount = 0;
        nHuTotalFan = 0;
        nHandScore = 0;
        nMakeDeal = 0;
        nMakeCatch = 0;
        nPengCount = 0;
        nGangCount = 0;
        //goSeniorTime = CTime(2018, 11, 11, 0, 0, 0);
    }
} ROLE, LPROLE;

typedef struct _tagPLAYRECORD
{
    //游戏对局信息
    CTime   time;                                   //时间点
    int     nRoomID;                                //房间ID
    int     nTotalTimeCost;                         //总耗时(秒)
    int     nBaseDeposit;                           //基础银
    int     nFee;                                   //茶水费
    int     nMakeExchange;                          //换三张干预
    int     nDelayCount;                            //延迟输出次数
    CString strSerialNO;                            //本局序列号
    ROLE    role[TOTAL_CHAIRS];                     //玩家列表
    BOOL    isGameOver;                             //对局是否结束
    _tagPLAYRECORD()
    {
        nRoomID = 0;
        nTotalTimeCost = 0;
        nBaseDeposit = 0;
        nFee = 0;
        nMakeExchange = 0;
        nDelayCount = 0;
        isGameOver = FALSE;
    }
} PLAYRECORD, *LPPLAYRECORD;

typedef struct _tagTransferInfo
{
    int nAniChairNo;                        //扣钱玩家chairNO
    int nDeposit[MAX_CHAIR_COUNT];          //银子输赢变化
} TRANSFER_INFO, *LPTRANSFER_INFO;

typedef struct _tagGameEndCheckInfo
{
    int nHuaZhuPoint[TOTAL_CHAIRS];
    int nHuaZhuDePosit[TOTAL_CHAIRS];
    int nDajiaoPoint[TOTAL_CHAIRS];
    int nDajiaoDePosit[TOTAL_CHAIRS];
    int nDrawBackPoint[TOTAL_CHAIRS];
    int nDrawBackDeposit[TOTAL_CHAIRS];
    int nTransferPoint[TOTAL_CHAIRS];
    int nTransferDeposit[TOTAL_CHAIRS];
    int nHuPoint[TOTAL_CHAIRS];
    int nHuDeposit[TOTAL_CHAIRS];
    int nFlag;
    int nReserved[4];
} GAMEEND_CHECK_INFO, *LPGAMEEND_CHECK_INFO;

//新手任务 begin
typedef struct _tagPlayerNewbieTaskINFO
{
    int nUserID;                // userid
    int nType;                 //任务类型
    int nCompleteNum; //完成计数
    int nReserved[4];       // 保留字段
} PLAYERNEWBITASKINFO, *LPPLAYERNEWBITASKINFO;

//新手任务 end

typedef struct _tagPLAYER_ABORT_HEAD
{
    int nRoomID;                                // 房间ID
    int nTableNO;                               // 桌号
    int nAbortPlayerCount;                      // 已离开玩家数
    int nReserved[4];
} PLAYER_ABORT_HEAD, *LPPLAYER_ABORT_HEAD;

typedef struct _tagABORTPLAYER_INFO
{
    int nUserID;                                // 用户ID
    int nTableNO;                               // 桌号
    int nChairNO;                               // 位置
    TCHAR szUsername[MAX_USERNAME_LEN];         // 用户名
    int nDeposit;                               // 银子
    int nNickSex;                               // 显示性别 -1: 未知; 0: 男性; 1: 女性
    int nPortrait;                              // 头像
    int nWin;                                   // 赢
    int nLoss;                                  // 输
    int nStandOff;                              // 和
    int nReserved[4];
} ABORTPLAYER_INFO, *LPABORTPLAYER_INFO;

typedef struct _tagGET_WELFARE_PRESENT_OK
{
    int   nUserID;
    int   nActivityID;          // 活动ID
    int   nCount;                //剩余次数
    int   nReserved[5];
} GET_WELFARE_PRESENT_OK, *LPGET_WELFARE_PRESENT_OK;

typedef struct _tagCHARGE_INFO
{
    TCHAR   BaseUrl[MAX_PATH];
    int   nReserved[4];
} CHARGE_INFO, *LPCHARGE_INFO;

typedef struct _tagPLAYER_GO_SENIOR
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nSeniorID;
    BOOL bShowSenior;
    TCHAR szSerialNO[MAX_SERIALNO_LEN]; //本局序列号
    int nReserved[4];
} PLAYER_GO_SENIOR, *LPPLAYER_GO_SENIOR;

typedef struct _tagGET_WELFAREPRESENT
{
    int   nUserID;
    int   nRoomID;                              // 房间ID
    int   nTableNO;                             // 桌号
    int   nChairNO;                             // 位置
    DWORD dwIPAddr;
    int   nActivityID;                          // 活动ID
    TCHAR szHardID[MAX_HARDID_LEN];
    DWORD dwSoapFlags;
    TCHAR szSoapReturn[MAX_SOAP_URL_LEN];
    DWORD dwFlags;
    int   nReserved[8];
} GET_WELFAREPRESENT, *LPGET_WELFAREPRESENT;

#define TASK_TYPE_COUNT 3     //三种任务大类
typedef int GRUOPID;
typedef struct  _tagTaskConInfo
{
    int nGroupId;        //任务组ID
    int nSubId;          //子任务ID
    int nConType;        //任务类型
    int nConValue;       //任务完成条件
} TASK_CONDINFO, *LPTASK_CONDINFO;

typedef struct _tagHU_MULTI_INFO
{
    int nHuFlag;
    int nHuCard;
    int nHuCount;
    int nHuChair[TOTAL_CHAIRS];
    int nLossChair[TOTAL_CHAIRS];
} HU_MULTI_INFO, *LPHU_MULTI_INFO;

typedef struct _tagGAME_TABLE_INFO
{
    MJ_START_DATA StartData;
    MJ_PLAY_DATA PlayData;

    DWORD   dwGameFlags;        //游戏状态
    int     nCardsCount[TOTAL_CHAIRS];              // 每个玩家手里的牌的张数
    int     nChairCards[CHAIR_CARDS];               // 自己手里的牌
    int     nAskExit[TOTAL_CHAIRS];                 //请求退出的次数
    int     nGangKaiCount;                          // 杠个数
    int     nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int     nTotalResult[MAX_CHAIR_COUNT];
    int     nHuReady[TOTAL_CHAIRS];                 //胡牌情况
    int     nHuMJID[TOTAL_CHAIRS];                  //所胡牌
    int     nDingQueCardType[TOTAL_CHAIRS];         //定缺的牌
    int     nDingQueWait;                           //定缺等待时间
    int     nGiveupWait;                            //放弃等待时间
    int     nExchange3CardsWait;                    //换三张等待时间
    int     nExchange3Cards[EXCHANGE3CARDS_COUNT];  //换三张的牌
    int     nShowTask;                              //客户端是否显示任务
    int     nLastThrowNO;                           //最近一次出牌玩家
    DWORD   dwPGCHFlags[TOTAL_CHAIRS];
    DWORD   dwPregGangFlags;                        // 抢杠胡切后台回来用
    int     nPreGangCardID;
    int     nReserved[4];
} GAME_TABLE_INFO, * LPGAME_TABLE_INFO;

typedef struct _tagHU_DETAILS_EX
{
    int     nChairNO;
    DWORD   dwHuFlags[2];       // 胡牌标志
    int     nHuGains[HU_MAX];   // 胡牌番数
    int     nTotalGains;        // 总番数
    int     nGangGains;         // 杠牌奖励
    int     nHasGang;           // 是否杠过牌
    int     nFourBao;           // 4宝讨赏
    int     nFeiBao;            // 飞宝个数
    int     nBankerHold;        //连庄局数
    int     nReserved[4];
} HU_DETAILS_EX, * LPHU_DETAILS_EX;

typedef struct _tagGAME_START_INFO
{
    MJ_START_DATA StartData;

    int     nCardsCount[TOTAL_CHAIRS];              // 每个玩家手里的牌的张数
    int     nChairCards[CHAIR_CARDS];               // 自己手里的牌
    int     nDingQueWait;                           //定缺等待时间
    int     nGiveupWait;                            //放弃等待时间
    int     nShowTask;                              //客户端是否显示任务
    int     nReserved[4];

} GAME_START_INFO, * LPGAME_START_INFO;

typedef struct _tagLOOKER_TABLE_INFO
{
    BOOL    bRefuse[TOTAL_CHAIRS];
    BOOL    bAllowd[TOTAL_CHAIRS];
    int     nCardsCount[TOTAL_CHAIRS];  // 每个玩家手里的牌的张数
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // 玩家手里的牌
    int     nReserved[4];
} LOOKER_TABLE_INFO, * LPLOOKER_TABLE_INFO;


typedef struct _tagGAME_TIMER
{
    int     nRoomID;
    int     nTableNO;
    int     nChairNO;
    DWORD   dwStatus;
} GAME_TIMER, *LPGAME_TIMER;