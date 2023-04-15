#include "stdafx.h"

CMJReplayDelegate::CMJReplayDelegate(CCommonBaseServer* pServer)
    : CReplayDelegate(pServer)
{
}

CMJReplayDelegate::~CMJReplayDelegate()
{
}

void CMJReplayDelegate::SaveReplayTableInfo(CTable* pTable)
{
    REP_TABLE_EX stRepTable;
    memset(&stRepTable, 0, sizeof(REP_TABLE_EX));
    stRepTable.nRoomID = pTable->m_nRoomID;
    stRepTable.nTableNO = pTable->m_nTableNO;
    stRepTable.nTotalChairs = pTable->m_nTotalChairs;
    stRepTable.dwRoomOption = pTable->m_dwRoomOption[0];
    stRepTable.bNeedDeposit = m_pServer->IsNeedDepositRoom(pTable->m_nRoomID);
    stRepTable.nBoutCount = pTable->m_nBoutCount;
    stRepTable.nBanker = pTable->m_nBanker;
    stRepTable.nBaseScore = pTable->m_nBaseScore;
    stRepTable.nBaseDeposit = pTable->m_nBaseDeposit;
    stRepTable.dwRoomConfigs = pTable->m_dwRoomConfig[0];

    CYQWGameData yqwGameData;
    if (m_pServer->YQW_LookupGameData(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData))
    {
        stRepTable.nRoomNo = yqwGameData.game_data.nRoomNo;
        stRepTable.nUserId = yqwGameData.game_data.nUserId;
        stRepTable.bIsYQWAgent = pTable->IsYQWAgent();
        stRepTable.nBoutPerRound = pTable->m_nYqwBoutPerRound;  //

        if (pTable->IsYQWAsLap())
        {
            stRepTable.bIsAsLap = pTable->IsYQWAsLap();
            stRepTable.nLapBoutCount = pTable->m_nYqwLapBoutCount;
            stRepTable.nTotalLap = pTable->m_nYqwTotalLap;
            stRepTable.nLapCount = pTable->m_nYqwLapCount;
        }
    }

    memcpy(stRepTable.nDices, ((CMJTable*)pTable)->m_nDices, sizeof(stRepTable.nDices));
    //((CMJTable*)pTable)->m_pReplayModel->m_ReplayRecord.PushHead(&stRepTable, sizeof(stRepTable));

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        REP_YQWPLAYER stRepPlayer;
        memset(&stRepPlayer, 0, sizeof(REP_YQWPLAYER));

        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            SOLO_PLAYER soloPlayer;
            memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
            m_pServer->LookupSoloPlayer(pPlayer->m_nUserID, soloPlayer);
            stRepPlayer.nUserID = soloPlayer.nUserID;                           // �û�ID
            stRepPlayer.nUserType = soloPlayer.nUserType;                       // �û�����
            stRepPlayer.nStatus = soloPlayer.nStatus;                           // ���״̬
            stRepPlayer.nChairNO = soloPlayer.nChairNO;                         // λ��
            stRepPlayer.nNickSex = soloPlayer.nNickSex;                         // ��ʾ�Ա� -1: δ֪; 0: ����; 1: Ů��
            stRepPlayer.nPortrait = soloPlayer.nPortrait;                       // ͷ��
            stRepPlayer.nClothingID = soloPlayer.nClothingID;                   // ��װID
            memcpy(stRepPlayer.szUsername, soloPlayer.szUsername, sizeof(stRepPlayer.szUsername));
            memcpy(stRepPlayer.szNickName, soloPlayer.szNickName, sizeof(stRepPlayer.szNickName));
            stRepPlayer.nDeposit = soloPlayer.nDeposit;                         // ����
            stRepPlayer.nPlayerLevel = soloPlayer.nPlayerLevel;                 // ����
            PLAYERLEVEL_EX playerlevel;
            ZeroMemory(&playerlevel, sizeof(playerlevel));
            m_pServer->m_mapPlayerLevel.Lookup(pPlayer->m_nLevelID, playerlevel);
            strcpy_s(stRepPlayer.szLevelName, playerlevel.szLevelName);
            stRepPlayer.nScore = soloPlayer.nScore;                             // ����
            stRepPlayer.nBreakOff = soloPlayer.nBreakOff;                       // ����
            stRepPlayer.nWin = soloPlayer.nWin;                                 // Ӯ
            stRepPlayer.nLoss = soloPlayer.nLoss;                               // ��
            stRepPlayer.nStandOff = soloPlayer.nStandOff;                       // ��
            stRepPlayer.nBout = soloPlayer.nBout;                               // �غ�
            stRepPlayer.nTimeCost = soloPlayer.nTimeCost;                       // ��ʱ

            //һ�����������
            if (pTable->m_ptrPlayers[i] && pTable->m_ptrPlayers[i]->m_nUserID > 0)
            {
                YQW_PLAYER yqwPlayer;
                ZeroMemory(&yqwPlayer, sizeof(yqwPlayer));

                if (m_pServer->YQW_LookupPlayer(pTable->m_ptrPlayers[i]->m_nUserID, yqwPlayer))
                {

                    memcpy(&(stRepPlayer.yqwPlayerInfo), &yqwPlayer, sizeof(yqwPlayer));
                    //stRepPlayer.yqwPlayerInfo.nScore = ((CMJTable*)pTable)->m_pReplayModel->m_nReplayYQWScore[i];
                }
            }

            //((CMJTable*)pTable)->m_pReplayModel->m_ReplayRecord.PushHead(&stRepPlayer, sizeof(REP_YQWPLAYER));
        }
    }
}

//���ƺ��齫ʵ�ַ�����̫һ�� ��������
void CMJReplayDelegate::FillupReplayInitialData(CTable* pTable)
{
    CMJTable* pMJTable = dynamic_cast<CMJTable*>(pTable);
    REP_STEP RspStep;
    memset(&RspStep, 0, sizeof(RspStep));
    RspStep.dwTickCount = 0;
    //RspStep.nSize = pMJTable->m_pReplayModel->GetReplayInitalDataSize(pMJTable->m_nTotalChairs);
    RspStep.nRequestID = GR_GAME_REPLAY_INIT;

    //pMJTable->m_pReplayModel->m_ReplayRecord.PushInitStep(&RspStep, sizeof(RspStep));

    for (int i = 0; i < pMJTable->m_nTotalChairs; i++)
    {
        int nCards[CHAIR_CARDS];
        XygInitChairCards(nCards, CHAIR_CARDS);
        pMJTable->GetChairCards(i, nCards, CHAIR_CARDS);

        //pMJTable->m_pReplayModel->m_ReplayRecord.PushData(nCards, sizeof(nCards));
    }
}