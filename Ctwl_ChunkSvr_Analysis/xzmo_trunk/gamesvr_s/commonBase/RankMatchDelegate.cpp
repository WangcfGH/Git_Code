#include "stdafx.h"


void CRankMatchDelegate::ChangeRankMatchParam(LPCONTEXT_HEAD lpContext, int userID, int paramValue, BOOL needUpdateName)
{
    if (userID <= 0 || paramValue == 0)
    {
        return;
    }

    UPDATE_MATCH_DATA paramChange;
    memset(&paramChange, 0, sizeof(paramChange));
    paramChange.nUserID = userID;
    paramChange.nMatchValue = paramValue;
    paramChange.needUpdateName = needUpdateName;  //该变量标识表示实时更新名字 （默认yqw为true，活动为经典场的自行决定）

    YQW_PLAYER yqwPlayer;
    ZeroMemory(&yqwPlayer, sizeof(yqwPlayer));
    if (imYQW_LookupPlayer.notify(userID, yqwPlayer))
    {
        if (0 != strcmp(yqwPlayer.szNickName, "")) //有昵称取昵称
        {
            memcpy(paramChange.szUserName, yqwPlayer.szNickName, sizeof(paramChange.szUserName));
            paramChange.needUpdateName = TRUE;
        }

        memcpy(paramChange.szPortrait, yqwPlayer.szPortrait, sizeof(paramChange.szPortrait));
    }

    SOLO_PLAYER sp;
    ZeroMemory(&sp, sizeof(sp));

    if ((0 == strcmp(paramChange.szUserName, "")) && (imLookupSoloPlayer.notify(userID, sp)) && IS_BIT_SET(sp.nUserType, UT_HANDPHONE)) //移动端用户
    {
        //request chunkSvr
        if (0 != strcmp(sp.szNickName, "")) //有昵称取昵称
        {
            memcpy(paramChange.szUserName, sp.szNickName, sizeof(sp.szNickName));
        }
        else
        {
            memcpy(paramChange.szUserName, sp.szUsername, sizeof(sp.szUsername));
        }
    }

    REQUEST Request;
    memset(&Request, 0, sizeof(Request));
    Request.head.nRequest = GR_RANK_MATCH_CHANGE_DATA;
    Request.pDataPtr = &paramChange;
    Request.nDataLen = sizeof(paramChange);
    Request.head.nRepeated = 0;
    imMsg2Chunk.notify(lpContext, &Request);
}

void CRankMatchDelegate::YQW_CloseSoloTable(CCommonBaseTable* pTable, int roomid, DWORD dwAbortFlag)
{
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    YQW_AddRankMatchScore(&context, pTable);
}

void CRankMatchDelegate::YQW_AddRankMatchScore(LPCONTEXT_HEAD lpContext, CTable* pTable)
{
    if (!imIsYQWRoom.notify(pTable->m_nRoomID))     //一起玩房间才算数据;
    {
        return;
    }
    if (pTable->m_nYqwHistoryBoutCount <= 0 || (pTable->m_nYqwHistoryBoutCount - 1) % pTable->m_nYqwBoutPerRound < 4)  //一轮完成5局以上有效;
    {
        return;
    }
    int nMaxScore = 0;
    int nMinScore = 0;
    BOOL bAddMax = TRUE;
    BOOL bAddMin = TRUE;
    for (int i = 0; i < pTable->m_nTotalChairs; ++i)
    {
        CPlayer* ptrPlayer = pTable->m_ptrPlayers[i];
        if (ptrPlayer)
        {
            if (pTable->m_nYqwScores[i] > nMaxScore)
            {
                nMaxScore = pTable->m_nYqwScores[i];
                bAddMax = TRUE;
            }
            else if (pTable->m_nYqwScores[i] == nMaxScore && nMaxScore > 0)
            {
                bAddMax = FALSE;
            }
            if (pTable->m_nYqwScores[i] < nMinScore)
            {
                nMinScore = pTable->m_nYqwScores[i];
                bAddMin = TRUE;
            }
            else if (pTable->m_nYqwScores[i] == nMinScore && nMinScore < 0)
            {
                bAddMin = FALSE;
            }
        }
    }
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* ptrPlayer = pTable->m_ptrPlayers[i];
        if (ptrPlayer)
        {
            if (pTable->m_nYqwScores[i] == nMaxScore && pTable->m_nYqwScores[i] > 0 && bAddMax)
            {
                ChangeRankMatchParam(lpContext, ptrPlayer->m_nUserID, 4);
            }
            else if (pTable->m_nYqwScores[i] > 0)
            {
                ChangeRankMatchParam(lpContext, ptrPlayer->m_nUserID, 2);
            }
            else if (pTable->m_nYqwScores[i] < 0 && pTable->m_nYqwScores[i] == nMinScore && bAddMin)
            {
                ChangeRankMatchParam(lpContext, ptrPlayer->m_nUserID, -4);
            }
            else if (pTable->m_nYqwScores[i] < 0)
            {
                ChangeRankMatchParam(lpContext, ptrPlayer->m_nUserID, -2);
            }
        }
    }
}
