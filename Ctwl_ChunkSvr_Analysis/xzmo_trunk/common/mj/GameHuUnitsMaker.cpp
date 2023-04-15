#include "StdAfx.h"
#include <cstdlib>
#include "..\common\mj\GameHuUnitsMaker.h"

bool GameHuUnitsMaker::HuResult2Details(HuResult& result, HU_DETAILS& detail)
{
    memset(&detail, 0, sizeof(detail));
    int color = 0;
    for (int color = 0; color < HuResult::COUNT && result.valid[color]; ++color)
    {
        auto& unit = result.hus[color];

        for (int i = 0; i < unit.units_count; ++i)
        {
            auto& u = detail.HuUnits[detail.nUnitsCount++];
            u.dwType = unit.v_t[i];
            u.aryIndexes[0] = unit.v_i[i][0] + EM_LAYOUT_MOD * color;
            u.aryIndexes[1] = unit.v_i[i][1] + EM_LAYOUT_MOD * color;
            u.aryIndexes[2] = unit.v_i[i][2] + EM_LAYOUT_MOD * color;
        }
    }

    if (result.joker_left == 1)
    {
        return false;
    }
    else if (result.joker_left == 2)
    {
        auto& u = detail.HuUnits[detail.nUnitsCount++];
        u.dwType = MJ_CT_DUIZI;
        u.aryIndexes[0] = u.aryIndexes[1] = -1;
    }
    else if (result.joker_left == 3) //三个财神！
    {
        auto& u = detail.HuUnits[detail.nUnitsCount++];
        u.dwType = MJ_CT_KEZI;
        u.aryIndexes[0] = u.aryIndexes[1] = u.aryIndexes[2] = -1;
    }

    return true;
}

bool GameHuUnitsMaker::HuPerfect(int lay[], int count, HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags,
    std::function<int(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)>& func)
{
    RestultHunits* color_result[EM_CARD_COLOR_COUNT] = {0};
    int jiangNum = 0;

    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        int nMax = (Strategy::C_COLOR_TABLE >> i *  Strategy::C_COLOR_BIT) & Strategy::C_COLOR_FLAG;
        int safe_count = (count - EM_LAYOUT_MOD * i) < nMax ? (count - EM_LAYOUT_MOD * i) : nMax;
        nMax = std::min<int>(nMax, safe_count);

        int nCardAll = 0;
        for (int n = 1; n <= nMax; ++n)
        {
            nCardAll += lay[EM_LAYOUT_MOD * i + n];
        }
        if (nCardAll == 0)
        {
            continue;
        }

        LayIndexType layTmp;
        memset(layTmp.data(), 0, layTmp.size());
        for (int m = 1; m <= safe_count; ++m)
        {
            layTmp[m - 1] += (lay + EM_LAYOUT_MOD * i)[m];
        }
        if (!getHuUnits(i, layTmp, color_result[i]))
        {
            return false;
        }
        jiangNum += color_result[i]->units.begin()->is_jiang();
    }

    if (jiangNum == 0)
    {
        return false;
    }
    HU_DETAILS detail_run;
    memset(&detail_run, 0, sizeof(detail_run));
    gain = 0;
    return HuPerfectTravel(color_result, 0, detail_run, details, gain, chairno, cardid, dwFlags, func);
}

bool GameHuUnitsMaker::HuPerfect(LayIndexType lay[EM_CARD_COLOR_COUNT], HU_DETAILS& details, int& gain, int chairno, int cardid, DWORD dwFlags,
    std::function<int(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)>& func)
{
    RestultHunits* color_result[EM_CARD_COLOR_COUNT] = { 0 };
    int jiangNum = 0;
    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        if (!getHuUnits(i, lay[i], color_result[i]))
        {
            return false;
        }
        jiangNum += color_result[i]->units.begin()->is_jiang();
    }

    if (jiangNum == 0)
    {
        return false;
    }
    HU_DETAILS detail_run;
    memset(&detail_run, 0, sizeof(detail_run));
    gain = 0;
    return HuPerfectTravel(color_result, 0, detail_run, details, gain, chairno, cardid, dwFlags, func);
}

bool GameHuUnitsMaker::CanHuFast(int lay[], int count)
{
    RestultHunits* color_result[EM_CARD_COLOR_COUNT] = { 0 };
    int jiangNum = 0;

    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        int nMax = (Strategy::C_COLOR_TABLE >> i *  Strategy::C_COLOR_BIT) & Strategy::C_COLOR_FLAG;
        int safe_count = (count - EM_LAYOUT_MOD * i) < nMax ? (count - EM_LAYOUT_MOD * i) : nMax;
        nMax = std::min<int>(nMax, safe_count);

        int nCardAll = 0;
        for (int n = 1; n <= nMax; ++n)
        {
            nCardAll += lay[EM_LAYOUT_MOD * i + n];
        }
        if (nCardAll == 0)
        {
            continue;
        }

        LayIndexType layTmp;
        memset(layTmp.data(), 0, layTmp.size());
        for (int m = 1; m <= safe_count; ++m)
        {
            layTmp[m - 1] += (lay + EM_LAYOUT_MOD * i)[m];
        }
        if (!getHuUnits(i, layTmp, color_result[i]))
        {
            return false;
        }
        jiangNum += color_result[i]->units.begin()->is_jiang();
    }

    return jiangNum == 1;
}

bool GameHuUnitsMaker::CanHuFast(LayIndexType lay[EM_CARD_COLOR_COUNT])
{
    RestultHunits* color_result[EM_CARD_COLOR_COUNT] = { 0 };
    int jiangNum = 0;

    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        if (!getHuUnits(i, lay[i], color_result[i]))
        {
            return false;
        }
        jiangNum += color_result[i]->units.begin()->is_jiang();
    }

    return jiangNum == 1;
}

int GameHuUnitsMaker::calcHuGains(HU_DETAILS& details)
{
    int n = 0;
    for (int i = 0; i < details.nUnitsCount; ++i)
    {
        n += details.HuUnits[i].dwType + 1;
    }
    return n;
}

void GameHuUnitsMaker::HuUnitToDetails(int color, HuUnits& unit, HU_DETAILS& details)
{
    for (int i = 0; i < unit.units_count; ++i)
    {
        auto& u = details.HuUnits[details.nUnitsCount++];
        u.dwType = unit.v_t[i];
        u.aryIndexes[0] = unit.v_i[i][0] + EM_LAYOUT_MOD * color;
        u.aryIndexes[1] = unit.v_i[i][1] + EM_LAYOUT_MOD * color;
        u.aryIndexes[2] = unit.v_i[i][2] + EM_LAYOUT_MOD * color;
    }
}

int GameHuUnitsMaker::HuPerfectTravel(RestultHunits* color_result[], int start, HU_DETAILS& detail_run, HU_DETAILS& detail_max, int& gain, int chairno, int cardid, DWORD dwFlags,
    std::function<int(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)>& func)
{
    if (start >= EM_CARD_COLOR_COUNT)
    {
        int n = func(chairno, cardid, detail_run, dwFlags);
        //int n = calcHuGains(detail_run);
        if (n > gain)
        {
            gain = n;
            detail_max = detail_run;
        }
        //清理
        for (int j = 0; j < HU_MAX; j++)
        {
            detail_run.nHuGains[j] = 0;
        }
        return gain;
    }

    HU_DETAILS tmp_details;
    if (!color_result[start])
    {
        memcpy(&tmp_details, &detail_run, sizeof(tmp_details));
        HuPerfectTravel(color_result, start + 1, tmp_details, detail_max, gain, chairno, cardid, dwFlags, func);
    }
    else
    {
        for (auto unit : color_result[start]->units)
        {
            memcpy(&tmp_details, &detail_run, sizeof(tmp_details));
            HuUnitToDetails(start, unit, tmp_details);
            HuPerfectTravel(color_result, start + 1, tmp_details, detail_max, gain, chairno, cardid, dwFlags, func);
        }
    }

    if (start == 0)
    {
        for (int j = 0; j < HU_MAX; j++)
        {
            detail_max.nHuGains[j] = 0;
        }
        return gain;
    }
    else
    {
        return 0;
    }
}

int GameHuUnitsMaker::calcTingCards(int lay[], int count, TingCards tings[EM_HAND_CARD_COUNT], int chairno, DWORD dwFlags,
    std::function<int(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)>& func)
{
    int total_lays[] =
    {
        1, 2, 3, 4, 5, 6, 7, 8, 9,
        11, 12, 13, 14, 15, 16, 17, 18, 19,
        21, 22, 23, 24, 25, 26, 27, 28, 29
    };

    int pos = 0;    //
    for (int i = 0; i < count; ++i)
    {
        if (lay[i] == 0)
        {
            continue;
        }
        lay[i]--;

        bool canTing = false;
        int start = 0;
        int cardid = -1;
        for (int j = 0; j < _countof(total_lays); ++j)
        {
            HU_DETAILS detail = { 0 };
            int gain = 0;
            lay[total_lays[j]] ++;
            cardid = CalcCardIdByIndex(total_lays[j]);
            if (HuPerfect(lay, count, detail, gain, chairno, cardid, dwFlags, func))
            {
                tings[pos].hu_lays[start] = total_lays[j];
                tings[pos].hu_fan[start] = gain;
                tings[pos].throw_card_lay = i;
                start++;
                canTing = true;
            }
            lay[total_lays[j]] --;
        }
        if (canTing)
        {
            pos++;
        }
        lay[i]++;
    }

    return pos;
}

int GameHuUnitsMaker::CalcCardIdByIndex(int nCardIndex)
{
    int nCardID = -1;
    if (nCardIndex % MJ_LAYOUT_MOD)
    {
        if (nCardIndex < 38)
        {
            nCardID = nCardIndex % MJ_LAYOUT_MOD + (nCardIndex / MJ_LAYOUT_MOD) * 36 - 1;
        }
        else if (nCardIndex > 40 && nCardIndex < 49)//花牌
        {
            nCardID = nCardIndex % MJ_LAYOUT_MOD + 135;
        }
    }

    if (nCardID >= TOTAL_CARDS)
    {
        nCardID = -1;
    }

    return nCardID;
}

void GameHuUnitsMaker::OnNewTable(CCommonBaseTable* pTable)
{
    using namespace plana::events;
    typedef bool(GameHuUnitsMaker::* t_HuPerfect)(int[], int, HU_DETAILS&, int&, int, int, DWORD,
        std::function<int(int, int, HU_DETAILS&, DWORD)>&);
    typedef bool (GameHuUnitsMaker:: * t_CanHuFast)(int lay[], int count);

    ((CMJTable*)pTable)->imHuPerfect = make_function_wrapper(this, (t_HuPerfect)&GameHuUnitsMaker::HuPerfect);
    ((CMJTable*)pTable)->imCanHuFast = make_function_wrapper(this, (t_CanHuFast)&GameHuUnitsMaker::CanHuFast);
}

void GameHuUnitsMaker::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    genAllHuUnits();
}
