#pragma once
#include "plana/plana.h"


class CCommonBaseTable;
struct CCommonTableEntity
{
    plana::entitys::Entity m_entity;

    // GameTable �������ڿ���
    EventNoMutex<CCommonBaseTable*> evInitModel;    // Table ��������֮���һ�����õĽӿ�
    EventNoMutex<CCommonBaseTable*> evResetTable;   // ��������״̬           resetTable
    EventNoMutex<CCommonBaseTable*> evResetRound;   // ����һ��             resetMembers(false)
    EventNoMutex<CCommonBaseTable*> evResetAll;     // ����table����Ҫ��������  resetMembers(true)

    EventNoMutex<CCommonBaseTable*> evComInit;      // ��ʼʱ������׼���� ģ����ء�ȡ������Ч�Լ�顢������ж�;ConstructGameData
    EventNoMutex<CCommonBaseTable*> evStartBefore;  // ��ʼ�����һ��: �������ӵ�;throwDices
    EventNoMutex<CCommonBaseTable*> evStartDoing;   // ��ʽ��ʼ�������Ƶȣ�startDeal
    EventNoMutex<CCommonBaseTable*> evStartAfter;   // ��ʼ���������CalcAfterDeal

    EventNoMutex<CCommonBaseTable*, void*, int> evPrepareNextBout;  // ���ݽ�����������һ�ֵ�״̬�仯

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
    virtual void        ResetTable() override;//���������Ϸ���������¿�ʼ
    virtual void        StartDeal()override;
    virtual int         CalcAfterDeal() override;
    virtual void        ConstructGameData() override;//������Ϸ���ݣ�����Ϸ��ʼǰ����
    virtual void        ThrowDices() override;
    virtual int         PrepareNextBout(void* pData, int nLen) override;
public:
    virtual void        YQW_ResetTable()override;

public:
    BOOL m_bOffline[MAX_CHAIR_COUNT];
    DWORD m_dwLastClockStop;
};

