#pragma once
class CMyExLotteryDelegate :
    public CLotteryDelegate
{
public:
    // ֱ�Ӱ���Ϣ���͸����������ô������
    virtual void ChangeLotteryTaskProcessOnGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData) override;
    //
    virtual void ChangeLotteryTaskProcessOnYQWGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData) override;
};

