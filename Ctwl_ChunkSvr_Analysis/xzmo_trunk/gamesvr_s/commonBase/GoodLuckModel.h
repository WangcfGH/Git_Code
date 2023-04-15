#pragma once

typedef struct _tagBUY_GOOD_LUCK_PROP
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nResult; //1 - ����ɹ�, -1Ϊ������Ѵ����ɹ�;
    int nHappyCoin;
} BUY_GOOD_LUCK_PROP, *LPBUY_GOOD_LUCK_PROP;

class CGoodLuckModel
{
public:
    CGoodLuckModel();
    virtual ~CGoodLuckModel();

    virtual int GetGoodLuckPropUserID() { return m_nGoodLuckPropUserID; };
    virtual void SetGoodLuckPropUserID(int userid) { m_nGoodLuckPropUserID = userid; };
    virtual void PushWaitBuyGoodLuckUserID(BUY_GOOD_LUCK_PROP buyGoodLuckProp);
    virtual BUY_GOOD_LUCK_PROP PopWaitBuyGoodLuckUserID();
    virtual void CleanWaitBuyGoodLuckUserID();
    virtual void PushWaitExchGameGoods(EXCH_GAME_GOODS exchGameGoods);
    virtual EXCH_GAME_GOODS PopWaitExchGameGoods();

private:
    int m_nGoodLuckPropUserID;                                   // �����˺����������ID, -1Ϊ��������ڹ���;
    std::queue<BUY_GOOD_LUCK_PROP> m_vWaitBuyGoodLuckUserIDs;    // �ȴ��������Ҷ���;
    std::queue<EXCH_GAME_GOODS> m_vWaitExchGameGoods;            // �ȴ��������Ҷ���;
};

