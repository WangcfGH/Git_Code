#pragma once
#include "MjDef.h"
#include "MJHuUnitMake.h"
#include "plana.h"

struct XZMKMJConfig1
{
    static const int C_HAND_CARDS_COUNT = 14;//14�����ƺ�
    static const int C_LAYOUT_NUM = 29;// ����Ҳ��29��index 10 �� 10 �� 9Ͳ
    static const int C_JOKER_NUM = 0;   //Joker����

    static const int C_COLOR_COUNT = 3; //������Ͳ �޷���
    static const int C_COLOR_TABLE = 9 | (9 << 4) | (9 << 8);
    static const int C_COLOR_BIT = 4;
    static const int C_COLOR_FLAG = 0x0f;
};
typedef MJHuUnitMake<XZMKMJConfig1> MakerXZMK1;                 // �Ĵ��齫�����ͼ���


class GameHuUnitsMaker : public MakerXZMK1
{
public:

    bool HuResult2Details(HuResult& result, HU_DETAILS& details);



    bool CanHuFast(int lay[], int count);
    bool CanHuFast(LayIndexType lay[EM_CARD_COLOR_COUNT]);
    //////////////////////////////////////////////////////////////////////////
    // ����󷬽ӿ�
    bool HuPerfect(int lay[], int count, HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    bool HuPerfect(LayIndexType lay[EM_CARD_COLOR_COUNT], HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    int calcHuGains(HU_DETAILS& details);

    void HuUnitToDetails(int color, HuUnits& unit, HU_DETAILS& details);

    int HuPerfectTravel(RestultHunits* color_result[], int start, HU_DETAILS& detail_run, HU_DETAILS& detail_max, int& gain, int chairno, int cardid, DWORD dwFlags,
        std::function<int(int, int, HU_DETAILS&, DWORD)>& func);

    //////////////////////////////////////////////////////////////////////////
    // ������ʾ  ��Ҫ�������п��Ժ������
    struct TingCards
    {
        int throw_card_lay = -1;    //��Ҫ��������Ʋ��ܺ�
        int hu_lays[29];        //����Щ����
        int hu_fan[29];         //�����ٷ���
    };

    int calcTingCards(int lay[], int count, TingCards tings[EM_HAND_CARD_COUNT], int chairno, DWORD dwFlags, std::function<int(int, int, HU_DETAILS&, DWORD)>& func);
    int CalcCardIdByIndex(int nCardIndex);

    void OnNewTable(CCommonBaseTable* pTable);
    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
};

