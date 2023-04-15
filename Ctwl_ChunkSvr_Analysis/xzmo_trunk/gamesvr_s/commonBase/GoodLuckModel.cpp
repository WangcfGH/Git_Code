#include "stdafx.h"

CGoodLuckModel::CGoodLuckModel()
{
    m_nGoodLuckPropUserID = 0;
}


CGoodLuckModel::~CGoodLuckModel()
{
}


void CGoodLuckModel::PushWaitBuyGoodLuckUserID(BUY_GOOD_LUCK_PROP buyGoodLuckProp)
{
    m_vWaitBuyGoodLuckUserIDs.push(buyGoodLuckProp);
}

BUY_GOOD_LUCK_PROP CGoodLuckModel::PopWaitBuyGoodLuckUserID()
{
    if (m_vWaitBuyGoodLuckUserIDs.empty())
    {
        BUY_GOOD_LUCK_PROP prop;
        prop.nUserID = -1;
        return prop;
    }
    BUY_GOOD_LUCK_PROP buyGoodLuckProp = m_vWaitBuyGoodLuckUserIDs.front();
    m_vWaitBuyGoodLuckUserIDs.pop();
    return buyGoodLuckProp;
}

void CGoodLuckModel::CleanWaitBuyGoodLuckUserID()
{
    while (!m_vWaitBuyGoodLuckUserIDs.empty())
    {
        m_vWaitBuyGoodLuckUserIDs.pop();
    }
    while (!m_vWaitExchGameGoods.empty())
    {
        m_vWaitExchGameGoods.pop();
    }
}

void CGoodLuckModel::PushWaitExchGameGoods(EXCH_GAME_GOODS buyGoodLuckProp)
{
    m_vWaitExchGameGoods.push(buyGoodLuckProp);
}

EXCH_GAME_GOODS CGoodLuckModel::PopWaitExchGameGoods()
{
    if (m_vWaitExchGameGoods.empty())
    {
        EXCH_GAME_GOODS prop;
        prop.nUserID = -1;
        return prop;
    }
    EXCH_GAME_GOODS buyGoodLuckProp = m_vWaitExchGameGoods.front();
    m_vWaitExchGameGoods.pop();
    return buyGoodLuckProp;
}