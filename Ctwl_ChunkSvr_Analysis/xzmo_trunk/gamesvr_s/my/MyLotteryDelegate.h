#pragma once
class CMyExLotteryDelegate :
    public CLotteryDelegate
{
public:
    // 直接把消息发送给任务就行了么。。。
    virtual void ChangeLotteryTaskProcessOnGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData) override;
    //
    virtual void ChangeLotteryTaskProcessOnYQWGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData) override;
};

