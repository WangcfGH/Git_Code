#pragma once

#define     MJ_CHAIR_COUNT           4  // 麻将牌人数
#define     MJ_BREAK_DOUBLE          8  // 逃跑扣分倍数
#define     MJ_THROW_WAIT           15  // 麻将出牌等待时间(秒)
#define     MJ_PGCH_WAIT             5  // 麻将碰杠吃胡等待时间(秒)
#define     MJ_PGCH_WAIT_EXT         2  // 麻将碰杠吃胡等待时间(追加)(秒)
#define     MJ_MAX_BANKER_HOLD       3  // 最大连续坐庄局数
#define     MJ_MAX_AUTO             INT_MAX // 
#define     MJ_UNDERTAKE_LIMEN       3  // 承包阈值
#define     MJ_TOTAL_CARDS          152 // 麻将牌总共张数
#define     MJ_TOTAL_PACKS           4  // 麻将牌相同牌张数
#define     MJ_CHAIR_CARDS          32  // 玩家手里最多牌张数
#define     MJ_LAYOUT_NUM           58  // 麻将牌方阵长度
#define     MJ_LAYOUT_MOD           10  // 麻将牌方阵模数
#define     MJ_MAX_CARDS            168 // 麻将牌最多张数
#define     MJ_MAX_OUT              36  // 最大打牌数
#define     MJ_MAX_PENG             6   // 最大碰牌数
#define     MJ_MAX_GANG             6   // 最大杠牌数
#define     MJ_MAX_CHI              6   // 最大吃牌数
#define     MJ_MAX_HUA              36  // 最大补花数
#define     MJ_INIT_HAND_CARDS      14

// 麻将牌状态
#define     MJ_STAT_PENG_OUT        10  // 碰出
#define     MJ_STAT_GANG_OUT        12  // 杠出
#define     MJ_STAT_CHI_OUT         14  // 吃出
#define     MJ_STAT_HUA_OUT         16  // 补花

#define     MJ_STAT_PENG_IN         30  // 碰进
#define     MJ_STAT_GANG_IN         32  // 杠进
#define     MJ_STAT_CHI_IN          34  // 吃进

// 麻将牌花色
#define     MJ_CS_WAN               0   // 万子
#define     MJ_CS_TIAO              1   // 条子
#define     MJ_CS_DONG              2   // 洞子
#define     MJ_CS_FENG              3   // 风板
#define     MJ_CS_HUA               4   // 花牌
#define     MJ_CS_TOTAL             5   // 花色总数

#define     TS_AFTER_CHI            0x00000020  //刚吃过一张牌
#define     TS_AFTER_PENG           0x00000040  //刚碰过一张牌
#define     TS_AFTER_GANG           0x00000080  //刚杠过一张牌

#define     MJ_PENG                 0x00000001  // 碰
#define     MJ_GANG                 0x00000002  // 杠
#define     MJ_CHI                  0x00000004  // 吃
#define     MJ_HU                   0x00000008  // 胡
#define     MJ_HUA                  0x00000010  // 补花
#define     MJ_GUO                  0x00000020  // 过牌

#define     MJ_GANG_MN              0x00000001  // 明杠
#define     MJ_GANG_PN              0x00000002  // 碰杠
#define     MJ_GANG_AN              0x00000004  // 暗杠

#define     MJ_HU_FLAGS_ARYSIZE     4
#define     MJ_HU_GAINS_ARYSIZE     64

// dwHuFlags[0]
#define     MJ_HU_FANG              0x00000001  // 放冲
#define     MJ_HU_ZIMO              0x00000002  // 自摸
#define     MJ_HU_QGNG              0x00000004  // 抢杠

#define     MJ_HU_7DUI              0x00000010  // 七对子
#define     MJ_HU_13BK              0x00000020  // 十三不靠
#define     MJ_HU_7FNG              0x00000040  // 七字全(七风)
#define     MJ_HU_QFNG              0x00000080  // 全风板

#define     MJ_HU_TIAN              0x00000100  // 天胡
#define     MJ_HU_DI                0x00000200  // 地胡
#define     MJ_HU_REN               0x00000400  // 人胡
#define     MJ_HU_BANK              0x00000800  // 庄家胡

#define     MJ_HU_PNPN              0x00001000  // 碰碰胡(对对胡)
#define     MJ_HU_1CLR              0x00002000  // 清一色
#define     MJ_HU_2CLR              0x00004000  // 混一色
#define     MJ_HU_FENG              0x00008000  // 字一色(全风)

//
#define     MJ_HU_WUDA              0x00010000  // 无搭
#define     MJ_HU_CSGW              0x00020000  // 财神归位(还原)|得国
#define     MJ_HU_3CAI              0x00040000  // 三财
#define     MJ_HU_4CAI              0x00080000  // 四财

#define     MJ_HU_GKAI              0x00100000  // 杠开
#define     MJ_HU_DDCH              0x00200000  // 大吊车
#define     MJ_HU_HDLY              0x00400000  // 海底捞月

#define     MJ_HU_258               0x01000000  // 258(将一色)

#define     MJ_HU_MQNG              0x10000000  // 大门清(不求人)
#define     MJ_HU_QQRN              0x20000000  // 全求人

// dwHuFlags[1]
#define     MJ_HU_BTOU              0x00000001  // 爆头
#define     MJ_HU_CAIP              0x00000002  // 财飘

#define     MJ_HU_DIAO              0x00000010  // 单吊
#define     MJ_HU_DUID              0x00000020  // 对倒
#define     MJ_HU_QIAN              0x00000040  // 嵌张
#define     MJ_HU_BIAN              0x00000080  // 边张
#define     MJ_HU_CHI               0x00000100  // 吃张

//
#define     MJ_UNIT_LEN             4           // 牌型最多牌张数
#define     MJ_MAX_UNITS            8           // 胡牌最多单元数

// 牌型
#define     MJ_CT_SHUN              0x00000001  // 顺子
#define     MJ_CT_KEZI              0x00000002  // 刻子
#define     MJ_CT_DUIZI             0x00000004  // 麻将(小对子)
#define     MJ_CT_GANG              0x00000008  // 杠子

#define     MJ_CT_13BK              0x00000020  // 十三不靠
#define     MJ_CT_7FNG              0x00000040  // 七字全(七风)
#define     MJ_CT_QFNG              0x00000080  // 全风板
#define     MJ_CT_258               0x00000100  // 258(将一色)

#define     MJ_CT_REGULAR(ct)       (MJ_CT_13BK != ct && MJ_CT_7FNG != ct && MJ_CT_QFNG != ct && MJ_CT_258 != ct)

// 游戏特征选项
#define     MJ_GF_USE_JOKER         0x00000001  // 有财神(百搭)
#define     MJ_GF_JOKER_PLUS1       0x00000002  // 翻牌加1是财神
#define     MJ_GF_BAIBAN_JOKER      0x00000004  // 白板可代替财神
#define     MJ_GF_JOKER_REVERT      0x00000008  // 财神可以还原(碰杠吃胡)

#define     MJ_GF_16_CARDS          0x00000010  // 16张麻将
#define     MJ_GF_FENG_CHI          0x00000020  // 风板可以吃

#define     MJ_GF_CHI_FORBIDDEN     0x00000100  // 不能吃
#define     MJ_GF_FANG_FORBIDDEN    0x00000200  // 不能放冲
#define     MJ_GF_QGNG_FORBIDDEN    0x00000400  // 不能抢杠

#define     MJ_GF_GANG_MN_ROB       0x00001000  // 允许抢明杠
#define     MJ_GF_GANG_PN_ROB       0x00002000  // 允许抢碰杠
#define     MJ_GF_NO_GANGROB_BAOTOU 0x00004000  // 爆头不许抢杠

#define     MJ_GF_JOKER_SHOWN_SKIP  0x00010000  // 摸到财神跳过
#define     MJ_GF_JOKER_THROWN_PIAO 0x00020000  // 支持财飘
#define     MJ_GF_ONE_THROW_MULTIHU 0x00040000  // 支持一炮多响
#define     MJ_GF_FEED_UNDERTAKE    0x00080000  // 吃碰要承包

#define     MJ_GF_7FNG_PURE         0x00400000  // 财神代替不算七字全

#define     MJ_GF_JOKER_DIAO_ZIMO   0x01000000  // 财神单吊必须自摸
#define     MJ_GF_JOKER_DUID_ZIMO   0x02000000  // 财神对倒必须自摸
#define     MJ_GF_JOKER_QIAN_ZIMO   0x04000000  // 财神嵌张必须自摸
#define     MJ_GF_JOKER_BIAN_ZIMO   0x08000000  // 财神边张必须自摸

#define     MJ_GF_DICES_TWICE       0x10000000  // 骰子要掷两次
#define     MJ_GF_ANGANG_SHOW       0x20000000  // 暗杠的牌能否显示
#define     MJ_GF_JOKER_SORTIN      0x40000000  // 财神牌不固定放头上
#define     MJ_GF_BAIBAN_NOSORT     0x80000000  // 替代财神牌不排序放

// 碰杠吃的牌的状态
#define     MJ_OUT_FENG             0x00000001  // 全风板
#define     MJ_OUT_258              0x00000002  // 258
#define     MJ_OUT_MIXUP            0x10000000  // 混合体

// 输赢类别
#define     MJ_GW_FANG              0x01000000  // 放冲胡
#define     MJ_GW_ZIMO              0x02000000  // 自摸胡
#define     MJ_GW_QGNG              0x04000000  // 抢杠胡

#define     MJ_GW_MULTI             0x10000000  // 一炮多响

// 玩家设置
#define     MJ_UC_QUICK_CATCH       0x00000001  // 快速抓牌

// 桌子状态
#define     MJ_TS_HU_READY          0x01000000  // 胡牌状态
#define     MJ_TS_GANG_MN           0x02000000  // 抢明杠状态
#define     MJ_TS_GANG_PN           0x04000000  // 抢碰杠状态
#define     MJ_TS_GANG_AN           0x08000000  // 抢暗杠状态

#define     MJ_FIRST_CATCH_13       13
#define     MJ_FIRST_CATCH_16       16

#define     MJ_INDEX_DONGFENG       31  // 东风
#define     MJ_INDEX_NANFENG        32  // 南风
#define     MJ_INDEX_XIFENG         33  // 西风
#define     MJ_INDEX_BEIFENG        34  // 北风

#define     MJ_INDEX_HONGZHONG      35  // 红中
#define     MJ_INDEX_FACAI          36  // 发财
#define     MJ_INDEX_BAIBAN         37  // 白板

#define     MJ_MATCH_HUFLAGS(demand, result, flag)  (IS_BIT_SET(demand, flag) && IS_BIT_SET(result, flag))

#define     MJ_ERR_HU_GAINS_LESS    -1000   // 胡数|台数|花数不够

#define     MJ_MAX_GAIN_TEXT_SIZE   256     // 胡牌名堂最大长度

#define     MJ_GF_14_HANDCARDS          14      // 14张麻将
#define     MJ_GF_17_HANDCARDS          17      // 17张麻将

//gameflag2
#define     PGL_MJGF_HUFIRST                0x00000001       //胡先不胡后
#define     PGL_MJGF_PENFIRST               0x00000002       //不能跟碰
#define     YQW_LIMIT_WINPOINTS             0x00000004  // 一起玩封顶规则
#define     MJ_HU_MAXWINPOINTS              0x00000008       //一炮多响,胡番最高的人胡牌

#define     MJ_HU_PRETING                   0x00000010       //胡牌前必须先听牌
#define     MJ_AUTO_BUHUA                   0x00000020 //服务端自动补花

#define     MJ_GF_GANG_AN_ROB               0x00008000        //允许抢暗杠
#define     MJ_TING                         0x00000040  // 听牌

#define     MERGE_THROWCARDS_CATCHCARDS     100
#define     CARD_BACK_ID                    -2

//pb msg
#define     MJ_GR_PREHU_TINGCARD            GAME_REQ_BASE_EX + 19002
#define     MJ_GR_BAOTING_THROWCARDS        GAME_REQ_BASE_EX + 19003
#define     MJ_GR_BAOTING_MERGETHROWCARDS   GAME_REQ_BASE_EX + 19004
#define     NTF_SOMEONE_BUHUA               GAME_REQ_BASE_EX + 19005

#define     MJ_MAX_DEEPTH  1000

#define     YQW_AUTOPLAY_WAIT                0// 碰撞杠吃的等待时间
#define     YQW_YQWQUICK_WAIT                9// 9秒快速房的等待时间
#define     YQW_LIMIT_WINPOINTS_VALUE        123         // 封顶分数
#define     YQWMJ_GAME_FLAGS2                0

#define     MJ_GAME_FIAGS    MJ_GF_USE_JOKER          \
                            | MJ_GF_GANG_PN_ROB       \
                            | MJ_GF_NO_GANGROB_BAOTOU \
                            | MJ_GF_JOKER_SHOWN_SKIP

enum MJ_PGC_TYPE
{
    MJ_TYPE_CHI = 1,
    MJ_TYPE_ANGANG = 2,
    MJ_TYPE_PNGANG = 3,
    MJ_TYPE_MNGANG = 4,
    MJ_TYPE_PENG = 5,
};
typedef struct _tagHU_UNIT
{
    DWORD dwType;   //
    int aryIndexes[MJ_UNIT_LEN];
    int nReserved[2];
} HU_UNIT, *LPHU_UNIT;

typedef struct _tagHU_DETAILS
{
    DWORD dwHuFlags[MJ_HU_FLAGS_ARYSIZE];       // 胡牌标志
    int nHuGains[MJ_HU_GAINS_ARYSIZE];          // 胡牌番数
    int nSubGains[MJ_HU_GAINS_ARYSIZE];         // 胡牌番数(辅助)
    int nUnitsCount;                            // 胡牌牌型单元数
    HU_UNIT HuUnits[MJ_MAX_UNITS];              // 胡牌具体牌型
    int nReserved2[4];
} HU_DETAILS, *LPHU_DETAILS;

typedef struct _tagCARDS_UNIT
{
    int nCardIDs[MJ_UNIT_LEN];
    int nCardChair;
    int nReserved[2];
} CARDS_UNIT, *LPCARDS_UNIT;

typedef CArray<CARDS_UNIT, CARDS_UNIT&> CCardsUnitArray;

