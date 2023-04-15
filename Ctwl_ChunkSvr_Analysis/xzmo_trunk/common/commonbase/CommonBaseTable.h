#pragma once
#include "plana/plana.h"


class CCommonBaseTable;
struct CCommonTableEntity
{
    plana::entitys::Entity m_entity;

    // GameTable 生命周期控制
    EventNoMutex<CCommonBaseTable*> evInitModel;    // Table 构建函数之后第一个调用的接口
    EventNoMutex<CCommonBaseTable*> evResetTable;   // 清理桌子状态           resetTable
    EventNoMutex<CCommonBaseTable*> evResetRound;   // 到下一局             resetMembers(false)
    EventNoMutex<CCommonBaseTable*> evResetAll;     // 整个table清理，要被重用了  resetMembers(true)

    EventNoMutex<CCommonBaseTable*> evComInit;      // 开始时候数据准备； 模块加载、取消、有效性检查、特殊的判断;ConstructGameData
    EventNoMutex<CCommonBaseTable*> evStartBefore;  // 开始处理第一步: 比如骰子等;throwDices
    EventNoMutex<CCommonBaseTable*> evStartDoing;   // 正式开始处理：发牌等；startDeal
    EventNoMutex<CCommonBaseTable*> evStartAfter;   // 开始处理结束：CalcAfterDeal

    EventNoMutex<CCommonBaseTable*, void*, int> evPrepareNextBout;  // 根据结算来处理下一局的状态变化

    EventNoMutex<CCommonBaseTable*> evYQWResetTable;
};

class CCommonBaseTable : public CTable, public CCommonTableEntity
{
public:
    CCommonBaseTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1,
        int totalchairs = MAX_CHAIRS_PER_TABLE, DWORD gameflags = 0, DWORD gameflags2 = 0,
        int max_asks = MAX_ASK_REPLYS);

    virtual void        InitModel();

    virtual void        ResetMembers(BOOL bResetAll = TRUE)override;
    virtual void        ResetTable() override;//清除桌子游戏，局数重新开始
    virtual void        StartDeal()override;
    virtual int         CalcAfterDeal() override;
    virtual void        ConstructGameData() override;//创建游戏数据，在游戏开始前构建
    virtual void        ThrowDices() override;
    virtual int         PrepareNextBout(void* pData, int nLen) override;
public:
    virtual void        YQW_ResetTable()override;

public:
    BOOL m_bOffline[MAX_CHAIR_COUNT];
    DWORD m_dwLastClockStop;
};

