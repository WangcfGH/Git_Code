#include "StdAfx.h"

CCommonBaseTable::CCommonBaseTable(int roomid, int tableno, int score_mult,
    int totalchairs, DWORD gameflags, DWORD gameflags2,
    int max_asks)
    : CTable(roomid, tableno, score_mult, totalchairs, gameflags, gameflags2, max_asks)
{
}

void CCommonBaseTable::InitModel()
{
    ResetMembers();
    evInitModel.notify(this);
}

void CCommonBaseTable::ResetMembers(BOOL bResetAll /*= TRUE*/)
{
    __super::ResetMembers(bResetAll);
    if (bResetAll)
    {
        memset(m_bOffline, 0, sizeof(m_bOffline));
        // 全局结束了
        evResetAll(this);
    }

    // 动态信息，跟局数相关
    m_dwLastClockStop = 0;

    evResetRound(this);
}

void CCommonBaseTable::ResetTable()
{
    __super::ResetTable();
    evResetTable(this);
}

void CCommonBaseTable::StartDeal()
{
    __super::StartDeal();
    evStartDoing(this);
}

int CCommonBaseTable::CalcAfterDeal()
{
    evStartAfter(this);
    return 0;
}

void CCommonBaseTable::ConstructGameData()
{
    evComInit(this);
}

void CCommonBaseTable::ThrowDices()
{
    evStartBefore(this);
}

int CCommonBaseTable::PrepareNextBout(void* pData, int nLen)
{
    auto r = __super::PrepareNextBout(pData, nLen);
    evPrepareNextBout(this, pData, nLen);
    return r;
}

void CCommonBaseTable::YQW_ResetTable()
{
    __super::YQW_ResetTable();
    evYQWResetTable.notify(this);
}
