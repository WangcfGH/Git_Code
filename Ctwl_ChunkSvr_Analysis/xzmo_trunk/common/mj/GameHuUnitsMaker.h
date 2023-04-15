#pragma once
#include "MjDef.h"
#include "MJHuUnitMake.h"
#include "plana.h"

struct XZMKMJConfig1
{
    static const int C_HAND_CARDS_COUNT = 14;//14张手牌胡
    static const int C_LAYOUT_NUM = 29;// 川麻也就29个index 10 万 10 条 9筒
    static const int C_JOKER_NUM = 0;   //Joker数量

    static const int C_COLOR_COUNT = 3; //万、条、筒 无风字
    static const int C_COLOR_TABLE = 9 | (9 << 4) | (9 << 8);
    static const int C_COLOR_BIT = 4;
    static const int C_COLOR_FLAG = 0x0f;
};
typedef MJHuUnitMake<XZMKMJConfig1> MakerXZMK1;                 // 四川麻将的牌型计算


class GameHuUnitsMaker : public MakerXZMK1
{
public:

    bool HuResult2Details(HuResult& result, HU_DETAILS& details);



    bool CanHuFast(int lay[], int count);
    bool CanHuFast(LayIndexType lay[EM_CARD_COLOR_COUNT]);
    //////////////////////////////////////////////////////////////////////////
    // 胡最大番接口
    bool HuPerfect(int lay[], int count, HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    bool HuPerfect(LayIndexType lay[EM_CARD_COLOR_COUNT], HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    int calcHuGains(HU_DETAILS& details);

    void HuUnitToDetails(int color, HuUnits& unit, HU_DETAILS& details);

    int HuPerfectTravel(RestultHunits* color_result[], int start, HU_DETAILS& detail_run, HU_DETAILS& detail_max, int& gain, int chairno, int cardid, DWORD dwFlags,
        std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    //////////////////////////////////////////////////////////////////////////
    // 听牌提示  主要计算所有可以胡的组合
    struct TingCards
    {
        int throw_card_lay = -1;    //需要打出哪张牌才能胡
        int hu_lays[29];        //胡哪些牌呢
        int hu_fan[29];         //胡多少番数
    };

    int calcTingCards(int lay[], int count, TingCards tings[EM_HAND_CARD_COUNT], int chairno, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);
    int CalcCardIdByIndex(int nCardIndex);

    void OnNewTable(CCommonBaseTable* pTable);
    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
};

