#pragma once
// 游戏信息
#define     TOTAL_CHAIRS            4//多少玩家
#define     TOTAL_CARDS             108//总共多少张牌
#define     MAX_CARDSID             108//牌的最大ID(无二条)
#define     REST_CARDS              0//不包含的牌的数量，如天台麻将中无条。
#define     TOTAL_PACKS             4
#define     CHAIR_CARDS             32//每人手上最多多少张牌
#define     LAYOUT_MOD              10//同种花色中不同数值的牌数，麻将为10，扑克为13。
#define     LAYOUT_NUM_EX           LAYOUT_NUM

#define     THROW_WAIT              20// 出牌等待时间
#define     PGCH_WAIT               10// 碰撞杠吃的等待时间
#define     MAX_BANKER_HOLD         100// 最大连续坐庄局数
#define     BANKER_BONUS            0  // 连庄输赢追加番数
#define     LAYOUT_NUM              49//不同花色的牌共有多少张

#define     HU_MAX                  16  //胡牌种类数34

#define     XZMO_BASE_BONUS             1  //LIMK闲家底番
#define     XZMO_BASE_BANKER            3  //LIMK庄家底番

#define     DINGQUE_WAIT            10 //add 20130916 定缺

#define  MJ_HU_HUAZHU                   0x00000010
#define  MJ_HU_TING                     0x00000020
#define  MJ_GIVE_UP                     0x00000040

#define  MJ_HU_MNGANG                   0x00000100  // 明杠
#define  MJ_HU_PNGANG                   0x00000200  // 碰杠
#define  MJ_HU_ANGANG                   0x00000400  // 暗杠

#define  SYSMSG_PLAYER_HU               3
#define  SYSMSG_PLAYER_NEXTTURN         4
#define  SYSMSG_PLAYER_GIVEUP           5
#define  SYSMSG_PLAYER_FIXMISS          7
#define  SYSMSG_PLAYER_EXCHANGE3CARDS   8

#define  CARD_TYPE_COUNT                3
#define  SVR_WAIT_SECONDS               2
#define  FAPAITIME                      0.5 //发牌时每家0.5s
#define  EXCHANGE3CARDS_COUNT           3

#define  ROOM_TYPE_XUELIU               0x00000008
#define  ROOM_TYPE_EXCHANGE3CARDS       0x00000010
#define  TS_WAITING_EXCHANGE3CARDS      0x00000004 //等待换三张
#define  TS_WAITING_GIVEUP              0x00000008 //等待放弃

#define MJ_HU_CALLTRANSFER              0x00000008  // 呼叫转移
#define MJ_HU_DRAWBACK                  0x00000080  // 退税
#define MJ_HU_GPAO                      0x00200000  // 杠上炮
#define MJ_HU_DEPOSIT_LIMIT             0x00800000  // 触发以小博大
#define LAYOUT_XZMO             30
#define SHAPE_COUNT             3

enum
{
    Dir_Clockwise, //顺时针
    Dir_AntiClockwise, //逆时针
    Dir_Opposite, //对面的
    Dir_Max,
};

#define     GAME_FLAGSEX             MJ_GF_CHI_FORBIDDEN     \
                                    | MJ_GF_GANG_PN_ROB     \
                                    | MJ_GF_ONE_THROW_MULTIHU  \
                                    | MJ_GF_BAIBAN_NOSORT   \
                                    | MJ_GF_ANGANG_SHOW

#define     GAME_FLAGS2EX           PGL_MJGF_HUFIRST

#define     HU_FLAGS_0EX             MJ_HU_FANG            \
                                    | MJ_HU_ZIMO            \
                                    | MJ_HU_QGNG            \
                                    | MJ_HU_7DUI            \
                                    | MJ_HU_TIAN            \
                                    | MJ_HU_DI              \
                                    | MJ_HU_GKAI

#define     HU_FLAGS_1EX             0

enum HU_GAIN
{
    HU_GAIN_BASE,                // 小胡
    HU_GAIN_7DUI,                // 7队
    HU_GAIN_L7DUI,               // 龙7队
    HU_GAIN_PNPN,                // 碰碰胡
    HU_GAIN_1CLR,                // 清一色
    HU_GAIN_19,                  // 带幺九
    HU_GAIN_258,                 // 将对
    HU_GAIN_GEN,                 // 带勾
    HU_GAIN_GKAI,                // 杠上花
    HU_GAIN_GPAO,                // 杠炮
    HU_GAIN_QGNG,                // 抢杠
    HU_GAIN_TIAN,                // 天胡
    HU_GAIN_DI,                  // 地胡
    HU_GAIN_GANG,                // 杠
    HU_GAIN_SOUBAYI,             // 手把一
    HU_GAIN_SEABED,              // 海底捞月
};

static int g_nHuGains[HU_MAX] =
{
    1, // 小胡         //0
    2, // 7队         //1
    4, // 龙7队        //2
    1, // 碰碰胡       //3
    2, // 清一色       //4
    2, // 带幺九       //5
    3, // 将对         //6
    1, // 带勾         //7
    1, // 杠上花       //8
    1, // 杠上炮       //9
    1, // 抢杠         //10
    5, // 天胡           //11
    5, // 地胡         //12
    1, // 杠          //13
    1, // 手把一       //14
    2, // 海底捞月      15
};

static TCHAR g_aryGainText[HU_MAX][16] =
{
    _T("屁胡"),       //0
    _T("七对"),       //1
    _T("龙七对"),     //2
    _T("碰碰胡"),     //3
    _T("清一色"),     //4
    _T("带幺九"),     //5
    _T("将对"),       //6
    _T("带根"),       //7
    _T("杠上花"),     //8
    _T("杠上炮"),      //9
    _T("抢杠"),       //10
    _T("天胡"),         //11
    _T("地胡"),       //12
    _T("杠"),         //13
    _T("金钩钓"),     //14
    _T("未定义")      //15
};

#define TC_ASSERT_RETURN(DATA,RESULT)                   \
if (NULL == (DATA))                                     \
{                                                   \
    UwlLogFile("Data Is NULL, RESULT=%d, %s, %d", RESULT, __FILE__, __LINE__);  \
    return RESULT;                                  \
    }\

//for client

#define     GAME_SOCKET(nRoomID, nTableNO)              (-nRoomID)
#define     GAME_TOKEN(nRoomID, nTableNO)               (-nTableNO)
#define     GR_GAME_TIMER                               500000