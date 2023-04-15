#include "StdAfx.h"
#include "siphash.h"
#define  UNIQUEID_KEY_NAME "xzmo_game_server"

std::string getConfigNameByRoomID(char* sConfig, int nRoomID)
{
    std::string configName = sConfig;
    configName.append(to_string(nRoomID));
    return configName;
}

CMyGameTable::CMyGameTable(int roomid, int tableno, int score_mult,
    int totalchairs, DWORD gameflags, DWORD gameflags2,
    DWORD huflags, DWORD huflags2,
    int max_asks,
    int totalcards,
    int totalpacks, int chaircards, int bottomcards,
    int layoutnum, int layoutmod, int layoutnumex,
    int abtpairs[],
    int throwwait, int autothrow, int entrustwait,
    int max_auction, int min_auction, int def_auction,
    int pgchwait, int max_banker_hold)
    : CMJTable(roomid, tableno, score_mult,
          totalchairs, gameflags, gameflags2, max_asks,
          totalcards,
          totalpacks, chaircards, bottomcards,
          layoutnum, layoutmod, layoutnumex,
          abtpairs,
          throwwait, autothrow, entrustwait,
          max_auction, min_auction, def_auction,
          pgchwait, max_banker_hold,
          huflags, huflags2)
{
}

void CMyGameTable::ResetMembers(BOOL bResetAll)
{
    __super::ResetMembers(bResetAll);

    if (bResetAll)
    {
        // 动态信息，跟局数无关
        m_nextAskNewTable = FALSE;
        m_HuMinLimit = 0;
        m_HuMaxLimit = 20;
    }

    // 动态信息，跟局数相关
    m_dwLastClockStop = 0;
    memset(m_nChairThrowCount, 0, sizeof(m_nChairThrowCount));
    memset(m_nFeedChair, -1, sizeof(m_nFeedChair));
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        m_nPeng3duiChairNO[i] = -1;
        m_nPeng4duiChairNO[i] = -1;
        m_nPengNum[i] = 0;
        m_nDingQueCardType[i] = -1;
        m_nGiveUpChair[i] = -1;
        m_bShowGiveUp[i] = FALSE;
        m_nLatestedGetMJIndex[i] = -1;
        m_vecHuItems[i].clear();
        m_HuMJID[i] = -1;
        m_bLastHuChairs[i] = FALSE;
    }

    nAfterChiPengStatus = -1;
    m_nLastPeng3dui4dui = -1;

    ReadLeastBout();

    m_nPengWait = -1;
    m_dwDingQueStartTime = 0;
    m_bPlayerRecharge = FALSE;
    m_dwGiveUpStartTime = 0;
    m_bNewRuleOpen = FALSE;
    m_bCallTransfer = FALSE;
    m_nEndGameFlag = 0;
    m_dwLastClockStop = 0;
    m_bOpenSaveResultLog = FALSE;
    m_nLatestThrowNO = -1;
    m_bIsXueLiuRoom = FALSE;
    m_bNeedUpdate = FALSE;
    m_bLastGang = FALSE;
    m_dwGangAfterCatch = 0;
    ZeroMemory(m_nDepositWinLimit, sizeof(m_nDepositWinLimit));
    m_vecPnGnCards.clear();

    memset(m_nExchangeCards, INVALID_OBJECT_ID, sizeof(m_nExchangeCards));
    memset(m_bExchangeCards, 0, sizeof(m_bExchangeCards));
    memset(m_HuReady, 0, sizeof(m_HuReady));
    memset(m_nMultiple, 0, sizeof(m_nMultiple));
    memset(m_SafeDeposits, 0, sizeof(m_SafeDeposits));
    memset(m_nTimeCost, 0, sizeof(m_nTimeCost));
    memset(m_nTotalGameCount, 0, sizeof(m_nTotalGameCount));
    memset(m_nXZTotalGameCount, 0, sizeof(m_nXZTotalGameCount));
    memset(m_nXLTotalGameCount, 0, sizeof(m_nXLTotalGameCount));
    memset(m_nNewPlayer, 0, sizeof(m_nNewPlayer));
    memset(m_bIsMakeCard, 0, sizeof(m_nNewPlayer));
    memset(m_nWinOrder, 0, sizeof(m_nWinOrder));
    memset(m_nWinOrder, 0, sizeof(m_nWinOrder));
    memset(m_nCoutInitialDeposits, 0, sizeof(m_nCoutInitialDeposits));
    memset(m_nHuTimes, 0, sizeof(m_nHuTimes));
    memset(m_nInitDeposit, 0, sizeof(m_nInitDeposit));
    memset(m_nRoomFees, 0, sizeof(m_nRoomFees));
    memset(m_stMakeCardInfo, 0, sizeof(m_stMakeCardInfo));
    memset(m_stCheckInfo, 0, sizeof(m_stCheckInfo));
    memset(m_stPreSaveInfo, 0, sizeof(m_stPreSaveInfo));
    memset(m_HuPoint, 0, sizeof(m_HuPoint));
    memset(&m_stAbortPlayerInfo, 0, sizeof(m_stAbortPlayerInfo));
    memset(&m_stGameStartPlayerInfo, 0, sizeof(m_stGameStartPlayerInfo));
    memset(&m_stEndGameCheckInfo, 0, sizeof(m_stEndGameCheckInfo));
    memset(&m_stMakeCardConfig, 0, sizeof(m_stMakeCardConfig));
    memset(&m_stHuMultiInfo, 0, sizeof(m_stHuMultiInfo));
    memset(&m_bIsRobot, 0, sizeof(m_bIsRobot));

    ResetAIOpe();
}

void CMyGameTable::FillupGameTableInfo(void* pData, int nLen, int chairno, BOOL lookon)
{
    ZeroMemory(pData, nLen);

    FillupStartData(pData, nLen);
    FillupPlayData((PBYTE)pData + sizeof(MJ_START_DATA), nLen - sizeof(MJ_START_DATA));

    LPGAME_TABLE_INFO pTableInfo = LPGAME_TABLE_INFO(pData);
    pTableInfo->PlayData.nReserved[0] = GetAutoThrowCardID(chairno);

    //游戏状态
    pTableInfo->dwGameFlags = m_dwGameFlags;

    if (IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        if (GetCurrentChair() == chairno && !IS_BIT_SET(m_dwStatus, TS_AFTER_PENG))
        {
            LPMJ_START_DATA pStartData = (LPMJ_START_DATA)pData;
            if (CalcHu_Zimo(GetCurrentChair(), GetFirstCardOfChair(GetCurrentChair())))
            {
                pStartData->dwCurrentFlags = MJ_HU;
            }
        }
        else
        {
            if ((IS_BIT_SET(m_dwStatus, MJ_TS_GANG_PN)) && IS_BIT_SET(m_stPreGangOK.dwResults[chairno], MJ_HU))
            {
                pTableInfo->dwPregGangFlags = m_stPreGangOK.dwFlags;    // 解决抢杠胡问题
                pTableInfo->nPreGangCardID = m_stPreGangOK.nCardID;
            }
        }
    }

    for (int k = 0; k < m_nTotalChairs; k++)
    {
        pTableInfo->dwPGCHFlags[k] = m_dwPGCHFlags[k] | m_dwGuoFlags[k];
    }

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        pTableInfo->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
    }
    XygInitChairCards(pTableInfo->nChairCards, CHAIR_CARDS);

    if (!lookon && (!IsVariableChairRoom() || m_ptrPlayers[chairno]->m_nUserID == m_PlayersBackup[chairno].nUserID)) // 不是旁观者，是玩家
    {
        GetChairCards(chairno, pTableInfo->nChairCards, CHAIR_CARDS); // 填充牌的ID方阵
    }

    pTableInfo->nGangKaiCount = m_nGangKaiCount;    //杠开个数
    memcpy(pTableInfo->nAskExit, m_nAskExit, sizeof(pTableInfo->nAskExit));
    memcpy(pTableInfo->nResultDiff, m_nResultDiff, sizeof(m_nResultDiff));
    memcpy(pTableInfo->nTotalResult, m_nTotalResult, sizeof(m_nTotalResult));
    memcpy(pTableInfo->nHuReady, m_HuReady, sizeof(m_HuReady));
    memcpy(pTableInfo->nHuMJID, m_HuMJID, sizeof(m_HuMJID)); //断线续玩显示不正确

    //定缺结束
    pTableInfo->nDingQueWait = m_nDingQueWait;
    memcpy(pTableInfo->nDingQueCardType, m_nDingQueCardType, sizeof(m_nDingQueCardType));

    if (IS_BIT_SET(m_dwStatus, TS_WAITING_EXCHANGE3CARDS))
    {
        pTableInfo->nExchange3CardsWait = m_nDingQueWait - ((GetTickCount() - m_dwDingQueStartTime)) / 1000 + FAPAITIME * m_nTotalChairs; //目测少个扔色子的时间
        memcpy(pTableInfo->nExchange3Cards, m_nExchangeCards[chairno], sizeof(m_nExchangeCards[chairno]));
    }
    else if (IS_BIT_SET(m_dwStatus, TS_WAITING_AUCTION))
    {
        pTableInfo->nDingQueWait = m_nDingQueWait - ((GetTickCount() - m_dwDingQueStartTime)) / 1000 + FAPAITIME * m_nTotalChairs;
    }
    else if (IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_PN))
        {
            pTableInfo->nDingQueWait = m_nPGCHWait - (GetTickCount() - m_dwDingQueStartTime) / 1000;
        }
        else
        {
            pTableInfo->nDingQueWait = m_nThrowWait - (GetTickCount() - m_dwActionStart) / 1000;
        }
    }
    else if (IS_BIT_SET(m_dwStatus, TS_WAITING_GIVEUP))
    {
        int nWaitTime = m_bPlayerRecharge ? m_nRechargeTime : m_nGiveUpTime;
        pTableInfo->nDingQueWait = nWaitTime - ((GetTickCount() - m_dwGiveUpStartTime)) / 1000;
    }
    else
    {
        pTableInfo->nDingQueWait = m_nPGCHWait - (GetTickCount() - m_dwActionStart) / 1000;
    }

    pTableInfo->nShowTask = m_nShowTask;
    pTableInfo->nLastThrowNO = m_nLatestThrowNO;
    pTableInfo->nGiveupWait = m_nGiveUpTime;
}

void CMyGameTable::FillupGameStart(void* pData, int nLen, int chairno, BOOL lookon)
{
    __super::FillupGameStart(pData, nLen, chairno, lookon);

    LPGAME_START_INFO pStartInfo = LPGAME_START_INFO(pData);

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        pStartInfo->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
    }
    XygInitChairCards(pStartInfo->nChairCards, CHAIR_CARDS);
    if (!lookon)
    {
        // 不是旁观者，是玩家
        GetChairCards(chairno, pStartInfo->nChairCards, CHAIR_CARDS); // 填充牌的ID方阵
    }

    //游戏状态
    //pStartInfo->dwGameFlags = m_dwGameFlags;
    //游戏状态2
    /*pStartInfo->dwGameFlags2 = m_dwGameFlags2;*/
    if (IsTingPaiActive())
    {
        PBYTE ptr_tingDetail = (PBYTE)pStartInfo + sizeof(GAME_START_INFO);
        if (IS_BIT_SET(m_dwGameFlags, MJ_GF_16_CARDS))
        {
            if (chairno == m_nBanker)
            {
                CalcTingCard_17(m_nBanker);
            }
            else
            {
                ZeroMemory(&m_CardTingDetail_16, sizeof(CARD_TING_DETAIL_16));
            }
            memcpy(ptr_tingDetail, &m_CardTingDetail_16, sizeof(CARD_TING_DETAIL_16));
        }
        else
        {
            if (chairno == m_nBanker)
            {
                CalcTingCard(m_nBanker);
            }
            else
            {
                ZeroMemory(&m_CardTingDetail, sizeof(CARD_TING_DETAIL));
            }
            memcpy(ptr_tingDetail, &m_CardTingDetail, sizeof(CARD_TING_DETAIL));
        }
    }

    pStartInfo->nDingQueWait = m_nDingQueWait;
    pStartInfo->nGiveupWait = m_nGiveUpTime;
    pStartInfo->nShowTask = m_nShowTask;
}

int CMyGameTable::GetGameStartSize()
{
    if (IsTingPaiActive())
    {
        return sizeof(GAME_START_INFO) + (IS_BIT_SET(m_dwGameFlags, MJ_GF_16_CARDS) ? sizeof(CARD_TING_DETAIL_16) : sizeof(CARD_TING_DETAIL));
    }
    else
    {
        return sizeof(GAME_START_INFO);
    }
}

//add by zhuhl
int  CMyGameTable::GetGameStartSize4Looker()
{
    return sizeof(LOOKER_GAME_START_INFO);
}

void CMyGameTable::FillupGameStart4Looker(void* pData, int nLen, CPlayer* pLooker)
{
    ZeroMemory(pData, nLen);

    FillupStartData(pData, nLen);

    LPLOOKER_GAME_START_INFO pStartInfo = LPLOOKER_GAME_START_INFO(pData);

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        XygInitChairCards(pStartInfo->nChairCards[i], CHAIR_CARDS);
        pStartInfo->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
        if (pLooker->HasAllowLook(i))
        {
            GetChairCards(i, pStartInfo->nChairCards[i], CHAIR_CARDS);
        }
    }

    //游戏状态
    pStartInfo->dwGameFlags = m_dwGameFlags;
}

int  CMyGameTable::GetGameTableLookerInfoSize()
{
    return sizeof(LOOKER_TABLE_INFO);
}

void CMyGameTable::FillupGameTableLookerInfo(void* pData, int nLen, CPlayer* pLooker)
{
    LPLOOKER_TABLE_INFO pLookerTableInfo = (LPLOOKER_TABLE_INFO)pData;
    ZeroMemory(pData, nLen);
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        XygInitChairCards(pLookerTableInfo->nChairCards[i], CHAIR_CARDS);
        pLookerTableInfo->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
        if (pLooker->HasAllowLook(i))
        {
            GetChairCards(i, pLookerTableInfo->nChairCards[i], CHAIR_CARDS);
        }
        if (m_ptrPlayers[i])
        {
            pLookerTableInfo->bRefuse[i] = m_ptrPlayers[i]->m_bRefuse;
        }
        pLookerTableInfo->bAllowd[i] = pLooker->HasAllowLook(i);
    }
}

BOOL CMyGameTable::LeaveAsBreak(int least_bout, int least_round)
{
    if (!IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME)
        && m_nBoutCount > 0 && m_nBoutCount < m_nLeastBout)
    {
        return IsBreakChairNotAllow();
    }

    return __super::LeaveAsBreak(least_bout, least_round);
}

BOOL CMyGameTable::IsGameOver()
{
    if (IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME))
    {
        return FALSE;
    }
    else if (m_nBoutCount > 0 && m_nBoutCount < m_nLeastBout)
    {
        BOOL bNotAllow = IsBreakChairNotAllow();
        return !bNotAllow;
    }
    return TRUE;
}

int CMyGameTable::TellBreakChair(int leavechair, DWORD waitsecs)
{
    if (leavechair == GetCurrentChair())  // 轮到你出，你要离开，扣你的分
    {
        return leavechair;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME) &&
        m_nBoutCount > 0 && m_nBoutCount < m_nLeastBout)
    {
        return leavechair;
    }

    DWORD dwNow = GetTickCount();

    if (dwNow - m_dwActionBegin > waitsecs * 1000)
    {
        return GetCurrentChair(); // 时间超出
    }
    else
    {
        return leavechair;
    }
}

BOOL CMyGameTable::IsBreakChairNotAllow()
{
    int i = 0;
    if (m_bNeedDeposit)
    {
        if (!IS_BIT_SET(m_dwGameFlags, GF_DEPOSIT_MANUAL))
        {
            for (i = 0; i < m_nTotalChairs; i++)
            {
                if (NULL == m_ptrPlayers[i])
                {
                    return TRUE;
                }
                if (m_ptrPlayers[i]->m_nDeposit < m_nDepositMin)
                {
                    return FALSE;
                }
            }
        }
    }
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (NULL == m_ptrPlayers[i])
        {
            return FALSE;
        }
        if (m_ptrPlayers[i]->m_nScore < m_nScoreMin)
        {
            return FALSE;
        }
        if (m_ptrPlayers[i]->m_nScore > m_nScoreMax)
        {
            return FALSE;
        }
        if (m_ptrPlayers[i]->m_nBout > m_nMaxUserBout)
        {
            return FALSE;
        }
    }

    return TRUE;
}



//记录抓到的宝.

int CMyGameTable::GetChairCards(int chairno, int nCardIDs[], int nCardsLen)
{
    int nCount = __super::GetChairCards(chairno, nCardIDs, nCardsLen);
    int nBigIndex = -1;
    int nBigCardID = -1;
    //在吃碰后时,index最大的放最后一张牌
    if (nAfterChiPengStatus > 0)
    {
        for (int i = 0; i < nCardsLen; i++)
        {
            if (MyGetSortValueByMJID(nCardIDs[i]) > nBigIndex)
            {
                nBigIndex = MyGetSortValueByMJID(nCardIDs[i]);
                nBigCardID = nCardIDs[i];
            }
        }
    }
    if (nBigIndex > 0)
    {
        for (int i = 0; i < nCardsLen; i++)
        {
            if (nCardIDs[i] == nBigCardID)
            {
                nCardIDs[i] = nCardIDs[nCount - 1];
                nCardIDs[nCount - 1] = nBigCardID;
                break;
            }
        }
    }

    //确保最后一张牌是当前抓到的牌
    if (IsValidCard(m_nCurrentCard) && nAfterChiPengStatus == -1)
    {
        for (int i = 0; i < nCardsLen; i++)
        {
            if (nCardIDs[i] == m_nCurrentCard)
            {
                nCardIDs[i] = nCardIDs[nCount - 1];
                nCardIDs[nCount - 1] = m_nCurrentCard;
                break;
            }
        }
    }

    return nCount;
}

int CMyGameTable::OnCatchCardFail(int chairno)
{
    if (m_nHeadTaken + m_nTailTaken >= m_nTotalCards)  // 没牌抓了啦！
    {
        return 1;
    }
    return 0;
}

BOOL CMyGameTable::ThrowCards(int chairno, int nCardIDs[])
{
    if (!IsCardIDsInHand(chairno, nCardIDs))
    {
        LOG_ERROR(_T("ThrowCards is not InHand %d"), nCardIDs);
        return FALSE;
    }

    ResetAIOpe();

    memset(&m_stPreGangOK, 0, sizeof(m_stPreGangOK));//add by 20131101
    m_nPengWait = -1;
    int temp = m_nGangKaiCount;
    int clearRobotFlag = 0;
    m_nChairThrowCount[chairno]++;
    m_nGangKaiCount = 0;
    memset(&m_stPreGangOK, 0, sizeof(m_stPreGangOK));//add by 20131101
    m_nPengWait = -1;
    CancelSituationOfGang();

    if (temp)
    {
        m_bLastGang = true;
    }
    {
        for (int i = 0; i < MAX_CARDS_PER_CHAIR; i++)
        {
            if (INVALID_OBJECT_ID == nCardIDs[i])
            {
                continue;
            }

            int cardno = GetCardNO(nCardIDs[i]);
            m_aryCard[cardno].nStatus = CS_OUT;

            int shape = m_aryCard[cardno].nShape;
            int value = m_aryCard[cardno].nValue;
            m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]--;
        }
        m_dwLatestThrow = GetTickCount();
    }

    int cardid = nCardIDs[0];
    m_nOutCards[chairno].Add(cardid);
    if (IsJoker(cardid))
    {
        OnJokerThrow(chairno, cardid);
    }
    else
    {
        OnNotJokerThrow(chairno, cardid);
    }

    //当前操作的牌
    m_nCurrentOpeCard = cardid;
    //最近一次出牌玩家ChairNO
    m_nLatestThrowNO = chairno;

    int robotHuReady = 0;
    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            m_dwPGCHFlags[i] = 0;
            m_dwGuoFlags[i] = 0;
            continue;    //出牌者本身不用算
        }

        if (IsHuReady(i))
        {
            continue;
        }

        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(huDetails));
        DWORD flags = MJ_PENG | MJ_GANG | MJ_HU;

        if (IsXueLiuRoom() && m_HuReady[i])
        {
            flags = MJ_HU | MJ_GANG;
        }

        if (GangCardFail(i)) // 没有牌可以杠
        {
            flags &= ~MJ_GANG;
        }

        if (i == GetNextChair(chairno)) // i是出牌者的下家
        {
            flags |= MJ_CHI;    // 只有下家可以吃
        }

        if (IsXueLiuRoom())
        {
            m_dwPGCHFlags[i] = CalcPGCH(i, cardid, huDetails, flags);
        }
        else
        {
            if (IsRoboter(i) && m_nAIOperateID != -1 && !IsLastFourCard())
            {
                //确保只有一个机器人有操作
            }
            else
            {
                m_dwPGCHFlags[i] = CalcPGCH(i, cardid, huDetails, flags);
            }
        }

        // 剩四必胡
        if (IsLastFourCard())
        {
            if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
            {
                m_dwPGCHFlags[i] &= ~MJ_GANG;
                m_dwPGCHFlags[i] &= ~MJ_PENG;
            }
        }

        if (m_dwPGCHFlags[i] != 0)
        {
            //可碰可杠时只碰，再杠，不收刮风下雨的钱
            if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_PENG) && IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG))
            {
                int cardIndex = m_pCalclator->MJ_CalcIndexByID(cardid, 0);
                m_vecPnGnCards.push_back(cardIndex);
            }

            if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG))
            {
                if (IsXueLiuRoom() && m_HuReady[i])
                {
                    vector<int> v1, v2;
                    HU_DETAILS huDetails;
                    memset(&huDetails, 0, sizeof(HU_DETAILS));
                    //判断听牌是否一致
                    int cardindex = m_pCalclator->MJ_CalcIndexByID(cardid, 0);
                    int gain = CalcTingEx(i, huDetails, &v1);
                    m_nCardsLayIn[i][cardindex] -= 3;
                    gain = CalcTingEx(i, huDetails, &v2);
                    m_nCardsLayIn[i][cardindex] += 3;

                    if (v1.size() == v2.size())
                    {
                        for (int k = 0; k < v1.size(); k++)
                        {
                            if (v1[k] != v2[k])
                            {
                                m_dwPGCHFlags[i] &= ~MJ_GANG;
                            }
                        }
                    }
                    else
                    {
                        m_dwPGCHFlags[i] &= ~MJ_GANG;
                    }
                }

                if (!IsRoboter(i))
                {
                    if (IsOffline(i)) //20131102 delete TODO
                    {
                        if (IsXueLiuRoom())
                        {
                            if (!IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
                            {
                                m_dwPGCHFlags[i] = 0;
                            }
                        }
                        else
                        {
                            m_dwPGCHFlags[i] = 0;
                        }
                    }
                }
            }
        }
        LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@7777777777777777777i:%d, %ld, %ld", i, m_dwPGCHFlags[i], m_HuReady[i]);
        if (IsRoboter(i) && m_nAIOperateID == -1)
        {
            LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@3333333333333333333i:%d", i);
            if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
            {
                LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@888888888888888888888i:%d", i);
                m_nAIOperateID = LOCAL_GAME_MSG_HU;
            }
            else if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG))
            {
                LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@99999999999999999999999i:%d", i);
                m_nAIOperateID = LOCAL_GAME_MSG_MN_GANG;
            }
            else if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_PENG))
            {
                LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@101010101010101010101010i:%d", i);
                m_nAIOperateID = LOCAL_GAME_MSG_PENG;
            }
            if (m_dwPGCHFlags[i] != 0)
            {
                LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@121212121212121212121212i:%d", i);
                m_nAIOperateChairNO = i;
                m_nAIOperateCardID = cardid;
                m_nAIOperateCardChairNO = chairno;
            }
        }

        int index = m_pCalclator->MJ_CalcIndexByID(cardid, 0);
        m_nLastThrowCard[i][index]++;

        if (ValidateGuo(i, chairno))
        {
            // 可以过牌
            m_dwGuoFlags[i] |= MJ_GUO;
        }
    }
    int huReadyIndex = -1;
    for (int k = 0; k < m_nTotalChairs; k++)
    {
        if (IS_BIT_SET(m_dwPGCHFlags[k], MJ_HU) && IsRoboter(k) && m_HuReady[k] && m_HuReady[k] != MJ_GIVE_UP)
        {
            m_nAIOperateID = LOCAL_GAME_MSG_HU;
            huReadyIndex = k;
        }
    }
    if (huReadyIndex != -1)
    {
        for (int n = 0; n < m_nTotalChairs; n++)
        {
            if (IsRoboter(n) && m_HuReady[n] && m_HuReady[n] != MJ_GIVE_UP)
            {
                ;
            }
            else
            {
                m_dwPGCHFlags[n] = 0;
            }
        }
    }
    else
    {
        if (m_nAIOperateID != -1)
        {
            for (int m = 0; m < m_nTotalChairs; m++)
            {
                if (IsRoboter(m) && (m_nAIOperateChairNO != m))
                {
                    m_dwPGCHFlags[m] = 0;
                }
            }
        }
    }
    //if (huReadyIndex == -1)
    //{

    //  if (IS_BIT_SET(m_dwPGCHFlags[k], MJ_HU))
    //  {
    //      LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@1111111111111111111111k:%d", k);
    //  }
    //  if (IsRoboter(k))
    //  {
    //      LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2222222222222222222k:%d", k);
    //      if (IS_BIT_SET(m_dwPGCHFlags[k], MJ_HU) && m_HuReady[k] && m_HuReady[k] != MJ_GIVE_UP)
    //      {
    //          LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@44444444444444444k:%d", k);
    //      }
    //      else
    //      {
    //          LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@5555555555555555555k:%d", k);
    //          if (IS_BIT_SET(m_dwPGCHFlags[k], MJ_HU) && !IsLastFourCard())
    //          {
    //              LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@666666666666666666666k:%d", k);
    //              if (k != m_nAIOperateChairNO)
    //              {
    //
    //              }
    //          }
    //      }
    //  }
    //}

    for (int j = 0; j < m_nTotalChairs; j++)
    {
        if (!IsRoboter(j) && m_dwPGCHFlags[j] != 0 && !IsLastFourCard()/* && !IS_BIT_SET(m_dwPGCHFlags[j], MJ_HU)*/)
        {
            clearRobotFlag = 1;
        }
    }
    if (clearRobotFlag == 1)
    {
        for (int l = 0; l < m_nTotalChairs; l++)
        {
            if (IsRoboter(l))
            {
                m_dwPGCHFlags[l] = 0;
                m_dwGuoFlags[l] = 0;
            }
        }
    }
    m_nLastThrowChair = chairno;

    //摸牌的时候刷新跟牌记录
    memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));

    ResetWaitOpe();
    return TRUE;
}

BOOL CMyGameTable::ValidateAutoThrow(int chairno)
{
    int diff = GetTickCount() - m_dwActionStart;
    if ((diff <= 1000 * (m_nThrowWait + THROW_WAIT_EXT)) && !IsOffline(chairno))
    {
        return FALSE;
    }

    return TRUE;
}

int CMyGameTable::OnPeng(LPPENG_CARD pPengCard)
{
    ResetAIOpe();
    ReSetThrowStutas(pPengCard->nCardChair, pPengCard->nChairNO);
    __super::OnPeng(pPengCard);
    int nChairNO = pPengCard->nChairNO;
    int nCardIDs[MAX_CARDS_PER_CHAIR];
    XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
    int nCardCount = GetChairCards(nChairNO, nCardIDs, MAX_CARDS_PER_CHAIR);
    if (nCardCount > 0)
    {
        m_nLatestedGetMJIndex[nChairNO] = GetCardNO(nCardIDs[0]);
    }

    OnAfterPeng(nChairNO);

    nAfterChiPengStatus = 2;
    return 0;
}

int CMyGameTable::OnMnGang(LPGANG_CARD pGangCard)
{
    ResetAIOpe();
    ReSetThrowStutas(pGangCard->nCardChair, pGangCard->nChairNO);

    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    m_nGangKaiCount++;

    CancelSituationOfGang();
    CancelSituationInCard();

    for (int i = 0; i < MJ_UNIT_LEN - 1; i++)
    {
        if (INVALID_OBJECT_ID == baseids[i])
        {
            continue;
        }
        SetStatusOfCard(baseids[i], MJ_STAT_GANG_OUT);
    }
    SetStatusOfCard(cardid, MJ_STAT_GANG_IN);

    CARDS_UNIT cards_unit = { 0 };
    MJ_InitializeCardsUnit(cards_unit);

    cards_unit.nCardIDs[0] = baseids[0];
    cards_unit.nCardIDs[1] = baseids[1];
    cards_unit.nCardIDs[2] = baseids[2];
    cards_unit.nCardIDs[3] = cardid;
    cards_unit.nCardChair = cardchair;

    m_MnGangCards[chairno].Add(cards_unit);

    int idx = FindCardID(m_nOutCards[cardchair], cardid);
    m_nOutCards[cardchair].RemoveAt(idx);

    LoseCard(chairno, baseids[0]);
    LoseCard(chairno, baseids[1]);
    LoseCard(chairno, baseids[2]);

    SetStatusOnGang(chairno);
    SetCurrentChairOnGang(chairno);

    CalcMnGangGains(pGangCard);
    m_nQghFlag = 0;
    m_nQghID = -1;
    m_nQghChair = -1;

    int nChairNO = pGangCard->nChairNO;
    OnAfterPeng(nChairNO);

    return 0;
}

int CMyGameTable::CalcPreGangOK(LPPREGANG_CARD pPreGangCard, PREGANG_OK& pregang_ok)
{
    int nCount = 0;
    int cardid = pPreGangCard->nCardID;
    int cardchair = pPreGangCard->nCardChair;
    int chairno = pPreGangCard->nChairNO;
    DWORD flags = pPreGangCard->dwFlags;

    int i = 0;
    if ((chairno == cardchair) && IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_PN_ROB) && !IS_BIT_SET(pPreGangCard->dwFlags, MJ_GANG_AN))
    {
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (!IsXueLiuRoom())
            {
                //add 20130911 begin 上一玩家胡牌后，该玩家立刻碰杠，有问题
                if (m_HuReady[i])
                {
                    continue;
                }
                //add 20130911 end
            }

            if (i == cardchair || i == chairno)
            {
                continue;
            }
            HU_DETAILS huDetails;
            memset(&huDetails, 0, sizeof(huDetails));

            DWORD dwTmpFlags = MJ_HU_QGNG;
            DWORD dwResult = CalcHu_Various(i, cardid, huDetails, dwTmpFlags);
            if (IS_BIT_SET(dwResult, MJ_HU))
            {
                if (!IsRoboter(i))
                {
                    m_dwPGCHFlags[i] |= MJ_HU;
                    m_dwGuoFlags[i] |= MJ_GUO;
                    pregang_ok.dwResults[i] = dwResult;
                    m_nQghFlag = pPreGangCard->dwFlags;
                    m_nQghID = cardid;
                    m_nQghChair = chairno;

                    nCount++;
                }
            }
        }
    }

    if ((chairno != cardchair) && IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_MN_ROB))
    {
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (i == chairno)
            {
                continue;
            }
            HU_DETAILS huDetails;
            memset(&huDetails, 0, sizeof(huDetails));

            DWORD dwTmpFlags = MJ_HU_QGNG;
            DWORD dwResult = CalcHu_Various(i, cardid, huDetails, dwTmpFlags);
            if (IS_BIT_SET(dwResult, MJ_HU))
            {
                if (!IsRoboter(i))
                {
                    m_dwPGCHFlags[i] |= MJ_HU;
                    m_dwGuoFlags[i] |= MJ_GUO;
                    pregang_ok.dwResults[i] = dwResult;
                    nCount++;

                    m_nQghFlag = pPreGangCard->dwFlags;
                    m_nQghID = cardid;
                    m_nQghChair = cardchair;
                }
            }
        }
    }

    pregang_ok.nChairNO = pPreGangCard->nChairNO;
    pregang_ok.nCardChair = pPreGangCard->nCardChair;
    pregang_ok.nCardID = pPreGangCard->nCardID;
    pregang_ok.dwFlags = pPreGangCard->dwFlags;

    memset(&m_stPreGangOK, 0, sizeof(m_stPreGangOK));//add 20131101
    memcpy(&m_stPreGangOK, &pregang_ok, sizeof(m_stPreGangOK));//add 20131101
    m_dwDingQueStartTime = GetTickCount();

    if (pregang_ok.dwFlags != MJ_GANG_MN)
    {
        m_nCurrentOpeCard = pPreGangCard->nCardID;
    }

    BOOL bHaveSomeCanHu = FALSE;
    for (int j = 0; j < m_nTotalChairs; j++)
    {
        if (IS_BIT_SET(m_dwPGCHFlags[j], MJ_HU))
        {
            bHaveSomeCanHu = TRUE;
            break;
        }
    }
    if (!bHaveSomeCanHu)
    {
        CancelSituationOfGang();
    }
    return nCount;
}

// 返回值: 胡牌人数
int CMyGameTable::OnHuQgng_Mn(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;
    m_nResults[chairno] = CanHu(chairno, cardid, m_huDetails[chairno], MJ_HU_QGNG);
    if (m_nResults[chairno] > 0)
    {
        m_HuReady[chairno] = MJ_HU_QGNG;
        m_HuMJID[chairno] = cardid;

        hu_count++;
        m_nHuCount++;

        // 胡牌成功
        m_nLoseChair = m_nGangChair;        // 被抢杠者位置
        m_nHuCount = hu_count;          // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID
        m_nHuChair = chairno;
    }
    return hu_count;
}

// 返回值: 胡牌人数
int CMyGameTable::OnHuQgng_Pn(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;
    m_nResults[chairno] = CanHu(chairno, cardid, m_huDetails[chairno], MJ_HU_QGNG);
    if (m_nResults[chairno] > 0)
    {
        m_HuReady[chairno] = MJ_HU_QGNG;
        m_HuMJID[chairno] = cardid;

        hu_count++;
        m_nHuCount++;

        // 胡牌成功
        m_nLoseChair = m_nGangChair;        // 被抢杠者位置
        m_nHuCount = hu_count;          // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID
        m_nHuChair = chairno;
    }
    return hu_count;
}

int CMyGameTable::CalcHuGains(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{

    if (IsHuaZhu(chairno))//花猪不能胡
    {
        return 0;
    }

    if (chairno == -1)
    {
        return 0;
    }

    m_bCallTransfer = FALSE;

    BOOL bFeiPiHu = FALSE; //结果框中显示屁胡
    huDetails.nHuGains[HU_GAIN_BASE] += g_nHuGains[HU_GAIN_BASE];
    int gains = g_nHuGains[HU_GAIN_BASE]; //默认一番，计算结果的时候减去

    //换三张房间天胡，地胡不算番
    if (!IS_BIT_SET(m_dwRoomOption[0], ROOM_TYPE_EXCHANGE3CARDS))
    {
        if (Hu_Tian(chairno, nCardID, huDetails, dwFlags))
        {
            gains += g_nHuGains[HU_GAIN_TIAN];
            huDetails.nHuGains[HU_GAIN_TIAN] += g_nHuGains[HU_GAIN_TIAN];
            bFeiPiHu = TRUE;
        }

        if (Hu_Di(chairno, nCardID, huDetails, dwFlags))
        {
            gains += g_nHuGains[HU_GAIN_DI];
            huDetails.nHuGains[HU_GAIN_DI] += g_nHuGains[HU_GAIN_DI];
            bFeiPiHu = TRUE;
        }
    }

    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_7DUI)) // 七对
    {
        int num = CalcGangUnitNum(huDetails);
        if (num > 0) //龙七对
        {
            gains += g_nHuGains[HU_GAIN_L7DUI];
            huDetails.nHuGains[HU_GAIN_L7DUI] += g_nHuGains[HU_GAIN_L7DUI];
        }
        else //小七对
        {
            gains += g_nHuGains[HU_GAIN_7DUI];
            huDetails.nHuGains[HU_GAIN_7DUI] += g_nHuGains[HU_GAIN_7DUI];
        }
        bFeiPiHu = TRUE;
    }
    else if (Hu_PnPn(chairno, nCardID, huDetails, dwFlags))
    {
        if (HU_258JIANG(chairno, nCardID, huDetails, dwFlags))
        {
            gains += g_nHuGains[HU_GAIN_258];
            huDetails.nHuGains[HU_GAIN_258] += g_nHuGains[HU_GAIN_258];
        }
        else
        {
            gains += g_nHuGains[HU_GAIN_PNPN];
            huDetails.nHuGains[HU_GAIN_PNPN] += g_nHuGains[HU_GAIN_PNPN];
        }
        bFeiPiHu = TRUE;
    }

    if (HU_19(chairno, nCardID, huDetails, dwFlags))
    {
        gains += g_nHuGains[HU_GAIN_19];
        huDetails.nHuGains[HU_GAIN_19] += g_nHuGains[HU_GAIN_19];
        bFeiPiHu = TRUE;
    }

    if (Hu_1Clr(chairno, nCardID, huDetails, dwFlags))
    {
        gains += g_nHuGains[HU_GAIN_1CLR];
        huDetails.nHuGains[HU_GAIN_1CLR] += g_nHuGains[HU_GAIN_1CLR];
        bFeiPiHu = TRUE;
    }

    if (Hu_GKai(chairno, nCardID, huDetails, dwFlags))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_GKAI;
        huDetails.nHuGains[HU_GAIN_GKAI] += g_nHuGains[HU_GAIN_GKAI];
        gains += g_nHuGains[HU_GAIN_GKAI];
        bFeiPiHu = TRUE;
    }

    if (Hu_GPao(chairno, nCardID, huDetails, dwFlags))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_GPAO;
        huDetails.nHuGains[HU_GAIN_GPAO] += g_nHuGains[HU_GAIN_GPAO];
        gains += g_nHuGains[HU_GAIN_GPAO];
        bFeiPiHu = TRUE;
        if (m_bNewRuleOpen)
        {
            m_bCallTransfer = TRUE;
        }
    }

    if (HU_ShouBaYi(chairno, nCardID, huDetails, dwFlags))
    {
        huDetails.nHuGains[HU_GAIN_SOUBAYI] += g_nHuGains[HU_GAIN_SOUBAYI];
        gains += g_nHuGains[HU_GAIN_SOUBAYI];
        bFeiPiHu = TRUE;
    }

    if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_QGNG;
        huDetails.nHuGains[HU_GAIN_QGNG] += g_nHuGains[HU_GAIN_QGNG];
        gains += g_nHuGains[HU_GAIN_QGNG];
        bFeiPiHu = TRUE;
    }

    //自摸加一番
    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        //海底捞月加两番（不计算自摸）
        if (m_bNewRuleOpen && m_nHeadTaken + m_nTailTaken >= m_nTotalCards) // 没牌抓了
        {
            huDetails.dwHuFlags[0] |= MJ_HU_HDLY;
            huDetails.nHuGains[HU_GAIN_SEABED] += g_nHuGains[HU_GAIN_SEABED];
            gains += g_nHuGains[HU_GAIN_SEABED];
            bFeiPiHu = TRUE;
        }
        else
        {
            huDetails.dwHuFlags[0] |= MJ_HU_ZIMO;
            gains += g_nHuGains[HU_GAIN_BASE];
        }
    }

    int gen = HU_Gen(chairno, nCardID, huDetails, dwFlags);
    if (huDetails.nHuGains[HU_GAIN_L7DUI] != 0)
    {
        gen--;    //去掉龙7对的根
    }
    huDetails.nHuGains[HU_GAIN_GEN] += g_nHuGains[HU_GAIN_GEN] * gen;
    gains += g_nHuGains[HU_GAIN_GEN] * gen;

    huDetails.nHuGains[HU_GAIN_GANG] += CalcGangByPgl(chairno, nCardID, huDetails, dwFlags) * g_nHuGains[HU_GAIN_GANG];
    gains += CalcGangByPgl(chairno, nCardID, huDetails, dwFlags) * g_nHuGains[HU_GAIN_GANG];

    //结果框中显示屁胡
    if (bFeiPiHu)
    {
        huDetails.nHuGains[HU_GAIN_BASE] -= g_nHuGains[HU_GAIN_BASE];
    }

    if (gains < m_HuMinLimit)
    {
        return 0;
    }

    if (gains > m_HuMaxLimit)
    {
        return m_HuMaxLimit;
    }

    return gains;
}

int CMyGameTable::ReadLeastBout()
{
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    sprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    int least_bout = GetPrivateProfileInt(_T("leasttablebout"), szRoomID, 0, GetINIFileName());
    m_nMaxUserBout = GetPrivateProfileInt(_T("maxuserbout"), szRoomID, 0, GetINIFileName());

    m_nLeastBout = least_bout;

    return least_bout;
}

// 跟庄逻辑不同
int CMyGameTable::CalcFirstCatchAfter(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    return pGameWin->nNextBanker;
}

// 从哪里开始抓
int CMyGameTable::CalcCatchFrom()
{
    int result = 0;

    int nTotal = m_nDices[0] + m_nDices[1];
    int nSide = nTotal % m_nTotalChairs;
    int nChair = 0;
    switch (nSide)
    {
    case 1://自己这一边
        nChair = m_nBanker;
        break;
    case 2://余二下家摸牌
        nChair = (m_nBanker + (m_nTotalChairs - 1)) % m_nTotalChairs;
        break;
    case 3://对家
        nChair = m_nBanker;//对家也自己这边
        break;
    case 0://上家
        nChair = (m_nBanker + 1) % m_nTotalChairs;
        break;
    }
    nTotal = m_nDices[0] + m_nDices[1];
    int nCardsPerSide = m_nTotalCards / m_nTotalChairs;
    switch (nChair)
    {
    case 0:
        result = nCardsPerSide * 3 + nTotal * 2;//68
        break;
    case 3:
        result = nCardsPerSide * 2 + nTotal * 2;
        break;
    case 2:
        result = nCardsPerSide + nTotal * 2;//34
        break;
    case 1:
        result = 0 + nTotal * 2;
        break;
    }
    if ((result % 2) == 1)
    {
        result++;
    }
    result = result % m_nTotalCards;
#ifdef _MAKECARD
    CreateIntFromFile(_T("BeginNO"), result);
#endif
    return result;
}

DWORD CMyGameTable::CalcPGCH(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD flags)
{
    DWORD dwReturn = 0;

    if (CalcIsDingQue(chairno, nCardID))
    {
        LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@eeeeeeeeeeeeeeeeeeeeeeeeee:%d", chairno);
        return 0;
    }
    LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ggggggggggggggggggggk:%d", chairno);
    if (IS_BIT_SET(flags, MJ_PENG))
    {
        if (IS_BIT_SET(GAME_FLAGS2EX, PGL_MJGF_PENFIRST))
        {
            int index = m_pCalclator->MJ_CalcIndexByID(nCardID, 0);
            if (!m_nLastThrowCard[chairno][index])//一轮之间，不能跟碰
            {
                dwReturn |= CalcPeng(chairno, nCardID);
            }
        }
        else
        {
            dwReturn |= CalcPeng(chairno, nCardID);
        }
    }
    if (IS_BIT_SET(flags, MJ_GANG))
    {
        dwReturn |= CalcGang(chairno, nCardID, MJ_GANG_MN);
    }

    if (IS_BIT_SET(flags, MJ_HU) && CalcHasNoDingQue(chairno))
    {
        LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ttttttttttttttttttttttk:%d", chairno);
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_FANG_FORBIDDEN))
        {
            // 可以放冲
            DWORD flags = MJ_HU_FANG;
            if (IS_BIT_SET(GAME_FLAGS2EX, PGL_MJGF_HUFIRST))
            {
                int index = m_pCalclator->MJ_CalcIndexByID(nCardID, 0);
                if (!m_nLastThrowCard[chairno][index] || IsXueLiuRoom())//一轮之间，不能跟胡
                {
                    LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@huhuhuhuhuhuhuk:%d", chairno);
                    dwReturn |= CalcHu(chairno, nCardID, huDetails, flags, TRUE);
                }
            }
            else
            {
                dwReturn |= CalcHu(chairno, nCardID, huDetails, flags, TRUE);
            }
        }
    }
    return dwReturn;
}

// 根据手里的牌加上这张牌，判断能否胡(放冲或自摸),预判断用。
DWORD CMyGameTable::CalcHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic /*= FALSE*/)
{
    return CalcHu_Various(chairno, nCardID, huDetails, dwFlags, bNorMalArithmetic);
}


DWORD CMyGameTable::CalcHu_Various(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic /*= FALSE*/)
{
    assert(nCardID >= 0 && nCardID < m_nTotalCards);

    //有定缺的牌不能胡
    if (!CalcHasNoDingQue(chairno))
    {
        return 0;
    }

    DWORD dwOut = GetOutOfChair(chairno);

    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }

    //七对
    if (m_pCalclator->MJ_CanHu_7Dui(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], huDetails, dwFlags))
        if (CalcHuGains(chairno, nCardID, huDetails, dwFlags))
        {
            return MJ_HU;
        }

    //普通胡牌
    if (IsNewTingPaiActive())
    {

        if (CalcHuFast(chairno, nCardID, lay, MAX_CARDS_LAYOUT_NUM))
        {
            return MJ_HU;
        }
        return 0;
    }
    else
    {
        // 普通胡牌
        if (MJ_CanHu_PerFect(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], huDetails, dwFlags, chairno, bNorMalArithmetic))
        {
            return MJ_HU;
        }
        return 0;
    }
}

DWORD CMyGameTable::CalcHu_Most(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic)
{
    assert((nCardID >= 0) && (nCardID < m_nTotalCards));

    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && (lay[cardidx] > 0))
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }

    huDetails.dwHuFlags[0] = 0;
    if (IS_BIT_SET(dwFlags, MJ_HU_FANG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_FANG;
    }

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        if (m_bNewRuleOpen && m_nHeadTaken + m_nTailTaken >= m_nTotalCards)
        {
            huDetails.dwHuFlags[0] |= MJ_HU_HDLY;
        }
        else
        {
            huDetails.dwHuFlags[0] |= MJ_HU_ZIMO;
        }
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_QGNG;
    }

    int nHuGains = 0;

    //***************************
    HU_DETAILS hu_details_out;
    memset(&hu_details_out, 0, sizeof(hu_details_out));
    HU_DETAILS hu_details_run;
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    //*****************************

    //特殊牌型
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_7Dui(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        m_pCalclator->MJ_MixupHuDetailsEx(hu_details_run, huDetails); //不混合nHuGains，只记录每次当前胡的信息
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }


    //普通牌型
    memset(&hu_details_run, 0, sizeof(hu_details_run));

    if (MJ_CanHu_PerFect(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags, chairno, bNorMalArithmetic))
    {
        m_pCalclator->MJ_MixupHuDetailsEx(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }

    if (nHuGains)// && m_gameStart)//如非正式开始，不拷贝数据，针对天胡判断。
    {
        memcpy(&huDetails, &hu_details_out, sizeof(huDetails));
    }
    return nHuGains;
}

void CMyGameTable::CopyHuDetailsSmall(int chairno, HU_DETAILS_EX& huDetailsSmall, HU_DETAILS& huDetails)
{

    int nBaoGain[MJ_CHAIR_COUNT] = { 0 };
    int nGangGain[MJ_CHAIR_COUNT] = { 0 };

    ZeroMemory(nGangGain, sizeof(nGangGain));
    ZeroMemory(nBaoGain, sizeof(nBaoGain));

    CalcTotalGangGains(nGangGain);

    memset(&huDetailsSmall, 0, sizeof(huDetailsSmall));
    huDetailsSmall.nChairNO = chairno;
    huDetailsSmall.dwHuFlags[0] = huDetails.dwHuFlags[0];       // 胡牌标志
    huDetailsSmall.dwHuFlags[1] = huDetails.dwHuFlags[1];

    // 胡牌标志
    for (int i = 0; i < HU_MAX; i++)
    {
        huDetailsSmall.nHuGains[i] = huDetails.nHuGains[i];
    }
    if (IsYQWTable())
    {
        huDetailsSmall.nTotalGains = YQW_TotalGain(huDetails, HU_MAX);// 胡牌番数
    }
    else
    {
        huDetailsSmall.nTotalGains = GetTotalGain(huDetails, HU_MAX);// 胡牌番数
    }

    huDetailsSmall.nGangGains = nGangGain[chairno];

    huDetailsSmall.nHasGang = m_MnGangCards[chairno].GetSize() + m_PnGangCards[chairno].GetSize() + m_AnGangCards[chairno].GetSize();

    huDetailsSmall.nFourBao = nBaoGain[chairno];

    huDetailsSmall.nFeiBao = m_nJokersThrown[chairno];
    huDetailsSmall.nBankerHold = m_nBankerHold;
}

BOOL CMyGameTable::CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    memcpy(nWinPoints, m_HuPoint, sizeof(m_HuPoint));

    for (int s = 0; s < m_nTotalChairs; s++)
    {
        m_stPreSaveInfo[s].nPreSaveAllFan += m_HuPoint[s];
    }

    if (IS_BIT_SET(m_dwWinFlags, GW_STANDOFF))
    {
        //流局查花猪，大叫
    }

    CalcBankerPoints(pData, nLen, chairno, nWinPoints);

    // 计算承包
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_FEED_UNDERTAKE)) // 吃碰要承包
    {
        CalcUnderTake(pData, nLen, chairno, nWinPoints);
    }

    /////////////////////////////////////////////////////
    int total = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        total += nWinPoints[i];
    }

    if (total != 0)
    {
        UwlLogFile("错误的记分错误，记分总和不为0!");
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            nWinPoints[i] = 0;
        }
    }
    //////////////////////////////////////////////////////

    return FALSE;
}

int CMyGameTable::GetTotalGain(HU_DETAILS& huDetails, int HuMax)
{
    int gains = 0;
    for (int i = 0; i < HuMax; i++)
    {
        if (huDetails.nHuGains[i] > 0)
        {
            gains += huDetails.nHuGains[i];
        }
        else if (huDetails.nHuGains[i] < 0)
        {
            gains += abs(huDetails.nHuGains[i]);
        }
    }

    if (gains == 0)
    {
        return gains;
    }
    //加底番
    gains += (m_nHuChair == m_nBanker ? XZMO_BASE_BANKER : XZMO_BASE_BONUS);
    //庄家胡追加底番
    if (m_nHuChair == m_nBanker)
    {
        gains += (m_nBankerHold - 1) * BANKER_BONUS;
    }
    return gains;
}


int CMyGameTable::CalcUnderTake(void* pData, int nLen, int chairno, int nWinPoints[])
{
    LPGAME_WIN_RESULT pGameWinRes = (LPGAME_WIN_RESULT)pData;
    int undertake_chair = INVALID_OBJECT_ID;
    BOOL bUndertake[TOTAL_CHAIRS] = { FALSE, FALSE, FALSE, FALSE };

    if (IS_BIT_SET(m_dwWinFlags, MJ_GW_QGNG))
    {
        undertake_chair = m_nLoseChair;
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (i == undertake_chair)
            {
                continue;
            }
            else if (nWinPoints[i] < 0)
            {
                nWinPoints[undertake_chair] += nWinPoints[i];
                nWinPoints[i] = 0;
            }
        }
    }
    else
    {
        if (m_nHuCount)
        {
            int undertake_num = 0;
            for (int j = 0; j < m_nTotalChairs; j++)
            {
                if (m_PengCards[j].GetSize() + m_MnGangCards[j].GetSize() == 4)
                {
                    if (j != m_nHuChair)
                    {
                        undertake_chair = j;
                        bUndertake[j] = TRUE;
                        undertake_num++;
                    }
                }
            }

            if (undertake_num == 0)
            {
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (m_PengCards[j].GetSize() + m_MnGangCards[j].GetSize() == 3)
                    {
                        if (j != m_nHuChair)
                        {
                            undertake_chair = j;
                            bUndertake[j] = TRUE;
                            undertake_num++;
                        }
                    }
                }
            }

            if (INVALID_OBJECT_ID != undertake_chair)
            {
                // 有一人承包
                if (undertake_num == 1)
                {
                    for (int i = 0; i < m_nTotalChairs; i++)
                    {
                        if (i == undertake_chair)
                        {
                            continue;
                        }
                        else if (nWinPoints[i] < 0)
                        {
                            nWinPoints[undertake_chair] += nWinPoints[i];
                            nWinPoints[i] = 0;
                        }
                    }
                }
                else
                {
                    // 多人承包，平均分担银子
                    int deposit = undertake_num > 0 ? nWinPoints[m_nHuChair] / undertake_num : 0;
                    int rest_deposit = undertake_num > 0 ? nWinPoints[m_nHuChair] % undertake_num : 0;
                    for (int i = 0; i < m_nTotalChairs; i++)
                    {
                        if (i == m_nHuChair)
                        {
                            continue;
                        }
                        if (nWinPoints[i] < 0)
                        {
                            nWinPoints[i] = 0;
                            if (bUndertake[i])
                            {
                                nWinPoints[i] -= deposit;
                            }
                        }
                    }
                    nWinPoints[undertake_chair] -= rest_deposit;
                }
            }
        }
        if (INVALID_OBJECT_ID != undertake_chair)
        {
        }
    }

    return undertake_chair;
}

int CMyGameTable::CalcPengGains(LPPENG_CARD pPengCard)
{
    int chairno = pPengCard->nChairNO;
    int i = 0;
    for (i = 0; i < 4; i++)
    {
        if (m_nFeedChair[chairno][i] == -1)
        {
            break;
        }
    }

    UwlTrace(_T("m_nFeedChair[%d] %d"), chairno, i);
    if (i < 4)
    {
        m_nFeedChair[chairno][i] = pPengCard->nCardChair;
    }
    return 0;
}

int CMyGameTable::CalcMnGangGains(LPGANG_CARD pGangCard)
{
    memset(m_GangPoint, 0, sizeof(m_GangPoint));
    m_nGangFeedCount[pGangCard->nChairNO][pGangCard->nCardChair] += 2;

    m_HuPoint[pGangCard->nChairNO] += 2;
    m_HuPoint[pGangCard->nCardChair] -= 2;

    m_GangPoint[pGangCard->nChairNO] = 2;
    m_GangPoint[pGangCard->nCardChair] = -2;

    AddNewGangItem(pGangCard, MJ_HU_MNGANG);

    return 0;
}

int CMyGameTable::CalcAnGangGains(LPGANG_CARD pGangCard)
{
    memset(m_GangPoint, 0, sizeof(m_GangPoint));
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == pGangCard->nChairNO)
        {
            continue;
        }
        if (IsHuReady(i))
        {
            continue;
        }
        if (NULL == m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
        {
            continue;
        }

        m_nGangFeedCount[pGangCard->nChairNO][i] += 2; //退税用
        m_GangPoint[i] = -2;
        m_GangPoint[pGangCard->nChairNO] += 2; //发给客户端显示数值
        m_HuPoint[i] -= 2;
        m_HuPoint[pGangCard->nChairNO] += 2; //结算用
    }

    AddNewGangItem(pGangCard, MJ_HU_ANGANG);

    return 0;
}

int CMyGameTable::CalcPnGangGains(LPGANG_CARD pGangCard)
{
    memset(m_GangPoint, 0, sizeof(m_GangPoint));

    //可碰可杠时只碰，下一圈杠，不收刮风下雨的钱
    BOOL bAlreadyPeng = FALSE;
    int cardIndex = m_pCalclator->MJ_CalcIndexByID(pGangCard->nCardID, 0);
    int i = 0;
    for (i = 0; i < m_vecPnGnCards.size(); i++)
    {
        if (cardIndex == m_vecPnGnCards.at(i))
        {
            bAlreadyPeng = TRUE;
            break;
        }
    }

    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (i == pGangCard->nChairNO)
        {
            continue;
        }
        if (IsHuReady(i))
        {
            continue;
        }
        if (NULL == m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
        {
            continue;
        }

        if (!bAlreadyPeng)
        {
            m_HuPoint[i] -= 1;
            m_HuPoint[pGangCard->nChairNO] += 1;
            m_GangPoint[i] = -1;
            m_GangPoint[pGangCard->nChairNO] += 1;
            m_nGangFeedCount[pGangCard->nChairNO][i] += 1;
        }
    }

    AddNewGangItem(pGangCard, MJ_HU_PNGANG);

    return 0;
}

DWORD CMyGameTable::CalcHu_TingCard(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    assert((nCardID >= 0) && (nCardID < m_nTotalCards));

    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && m_pCalclator->MJ_IsJokerEx(nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags))
    {
        return 0;
    }

    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && (lay[cardidx] > 0))
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }

    huDetails.dwHuFlags[0] = 0;

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_ZIMO;
    }

    //***************************
    HU_DETAILS hu_details_run;
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    //*****************************

    if (m_pCalclator->MJ_CanHu_7Dui(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        return MJ_HU;
    }

    memset(&hu_details_run, 0, sizeof(hu_details_run));

    if (MJ_CanHu_13BK_EX(lay, nCardID, m_dwGameFlags, hu_details_run, dwFlags, chairno))
    {
        return MJ_HU;
    }

    //普通牌型
    memset(&hu_details_run, 0, sizeof(hu_details_run));

    if (MJ_CanHu_PerFect(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0],
            hu_details_run, dwFlags, chairno))
    {
        return MJ_HU;
    }

    return 0;
}

int CMyGameTable::GetNextBoutBanker()
{
    return m_nHuChair;
}

DWORD CMyGameTable::Hu_MQng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    //七对子和十三不靠不算门清嘴数 六安特有
    if ((IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_13BK)) || (IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_7DUI)))
    {
        return 0;
    }

    return __super::Hu_MQng(chairno, nCardID, huDetails, dwFlags);
}

int CMyGameTable::CalcGangEtcPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    return CalcTotalGangGains(nWinPoints);
}

//2016/03/19添加,13幺只能宝还原
DWORD CMyGameTable::MJ_CanHu_13BK_EX(int nCardsLay[], int nCardID, DWORD gameflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno)
{
    if (IS_BIT_SET(gameflags, MJ_GF_FANG_FORBIDDEN))  // 不能放冲
    {
        if (IS_BIT_SET(dwFlags, MJ_HU_FANG))
        {
            return 0;
        }
    }

    if (IS_BIT_SET(gameflags, MJ_GF_QGNG_FORBIDDEN))  // 不能抢杠
    {
        if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
        {
            return 0;
        }
    }

    if (0 != m_PengCards[chairno].GetSize()
        || 0 != m_ChiCards[chairno].GetSize()
        || 0 != m_MnGangCards[chairno].GetSize()
        || 0 != m_PnGangCards[chairno].GetSize()
        || 0 != m_AnGangCards[chairno].GetSize())
    {
        return 0;  //吃碰杠不能胡
    }

    int ncardIndex = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);
    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };
    memcpy(lay, nCardsLay, sizeof(lay));

    int jokerindex = m_pCalclator->MJ_CalcIndexByID(m_nJokerID, m_dwGameFlags);
    lay[jokerindex] = 0;
    if (ncardIndex != jokerindex)
    {
        lay[ncardIndex] += 1;
    }
    int i = 0;
    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (lay[i] >= 2)
        {
            if (jokerindex == i)
            {

            }
            else
            {
                return 0;
            }
        }
    }

    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)  //
    {
        if (0 == lay[i])
        {
            continue;
        }
        if (m_pCalclator->MJ_IsFeng(i, m_nJokerID, m_nJokerID2, m_dwGameFlags))
        {
            continue;
        }
        // 不是字牌
        if (lay[i] > 0)
        {
            int nHua = i / MJ_LAYOUT_MOD;

            int nHua1 = (i + 1) / MJ_LAYOUT_MOD;

            int nHua2 = (i + 2) / MJ_LAYOUT_MOD;

            if (i + 1 < MAX_CARDS_LAYOUT_NUM && lay[i + 1] > 0)
            {
                if (nHua == nHua1)
                {
                    return 0;
                }
            }
            if (i + 2 < MAX_CARDS_LAYOUT_NUM && lay[i + 2] > 0)
            {
                if (nHua == nHua2)
                {
                    return 0;
                }
            }
        }
    }
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = MJ_CT_13BK;
    huDetails.dwHuFlags[0] |= MJ_HU_13BK;

    return MJ_HU;
}

DWORD CMyGameTable::MJ_CanHu_PerFect(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno,
    BOOL bNorMalArithmetic)
{
    if (IS_BIT_SET(gameflags, MJ_GF_FANG_FORBIDDEN))  // 不能放冲
    {
        if (IS_BIT_SET(dwFlags, MJ_HU_FANG))
        {
            return 0;
        }
    }
    if (IS_BIT_SET(gameflags, MJ_GF_QGNG_FORBIDDEN))  // 不能抢杠
    {
        if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
        {
            return 0;
        }
    }

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };  //
    memcpy(lay, nCardsLay, sizeof(lay));
    jokernum = m_pCalclator->MJ_GetJokerNum(lay, nJokerID, nJokerID2, gameflags, jokernum2);

    int jokeridex = 0;
    int jokeridx2 = 0;
    m_pCalclator->MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridex, jokeridx2);
    //加入财神
    jokernum = m_pCalclator->MJ_JoinCard(lay, nCardID, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);

    HU_DETAILS huDetails_run;//运行记录
    memset(&huDetails_run, 0, sizeof(huDetails_run));
    int gains_max = 0;//记录当前最大胡数

    int gains_limit = m_HuMaxLimit;
    int deepth = 0;

    return MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridex, jokeridx2, addpos, gameflags
            , huflags, huDetails, gains_max, FALSE, chairno, nCardID, huDetails_run, dwFlags, gains_limit, deepth, bNorMalArithmetic);
}

int CMyGameTable::OnAfterPeng(int nChairNO)
{
    if (nChairNO >= 0 && nChairNO <= m_nTotalChairs)
    {
        //这个人碰了
        m_nPengNum[nChairNO]++;
        int nTotalPengCount = m_nPengNum[nChairNO];
        if (nTotalPengCount == 3)
        {
            m_nLastPeng3dui4dui = nChairNO;
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (m_nPeng3duiChairNO[i] == -1)
                {
                    m_nPeng3duiChairNO[i] = nChairNO;
                    return 0;
                }
            }
        }
        else if (nTotalPengCount == 4)
        {
            m_nLastPeng3dui4dui = nChairNO;
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (m_nPeng4duiChairNO[i] == -1)
                {
                    m_nPeng4duiChairNO[i] = nChairNO;
                    return 0;
                }
            }
        }
    }
    return 0;
}

int CMyGameTable::MyGetSortValueByMJID(int nCardID)
{
    if (!IsValidCard(nCardID))
    {
        return -1;
    }
    int jokerindex = m_pCalclator->MJ_CalcIndexByID(m_nJokerID, 0);
    int cardindex = m_pCalclator->MJ_CalcIndexByID(nCardID, 0);
    if (cardindex == jokerindex)
    {
        return 0;
    }
    //六安特有规则红中代替宝牌
    if (cardindex == MJ_INDEX_HONGZHONG)
    {
        cardindex = jokerindex;
    }
    return cardindex;
}

int CMyGameTable::CalcTotalGangGains(int nGanggains[])
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        int j = 0;
        for (j = 0; j < m_AnGangCards[i].GetSize(); j++)//暗杠
        {
            nGanggains[i] += 8;
            for (int k = 0; k < m_nTotalChairs; k++)
            {
                nGanggains[k] -= 2;
            }
        }
        for (j = 0; j < m_MnGangCards[i].GetSize(); j++)//明杠
        {
            nGanggains[i] += 4;
            for (int k = 0; k < m_nTotalChairs; k++)
            {
                nGanggains[k] -= 1;
            }
        }

        for (j = 0; j < m_PnGangCards[i].GetSize(); j++)//碰杠
        {
            nGanggains[i] += 4;
            for (int k = 0; k < m_nTotalChairs; k++)
            {
                nGanggains[k] -= 1;
            }
        }
    }
    return 1;
}

void CMyGameTable::FillupStartData(void* pData, int nLen)
{
    LPMJ_START_DATA pStartData = (LPMJ_START_DATA)pData;

    memcpy(pStartData->szSerialNO, m_szSerialNO, sizeof(m_szSerialNO));
    pStartData->nBoutCount = m_nBoutCount;                     // 第几局
    pStartData->nBaseScore = m_nBaseScore;                     // 本局基本积分
    pStartData->nBaseDeposit = m_nBaseDeposit;                   // 本局基本银子
    pStartData->nBanker = m_nBanker;                        // 庄家位置
    pStartData->nBankerHold = m_nBankerHold;                    // 连续坐庄局数
    pStartData->dwStatus = m_dwStatus;                       // 状态
    pStartData->nCurrentChair = GetCurrentChair();                // 当前活动位置
    pStartData->nFirstCatch = m_nFirstCatch;                    // 第一个摸牌
    pStartData->nFirstThrow = m_nFirstThrow;                    // 第一个出牌

    pStartData->nThrowWait = m_nThrowWait;                     // 出牌等待时间(秒)
    pStartData->nMaxAutoThrow = m_nMaxAutoThrow;                  // 允许自动出牌的最大次数
    pStartData->nEntrustWait = m_nEntrustWait;                   // 托管等待时间(秒)

    pStartData->bNeedDeposit = m_bNeedDeposit;                   // 是否需要银子
    pStartData->bForbidDesert = m_bForbidDesert;                  // 是否禁止强退

    memcpy(pStartData->nDices, m_nDices, sizeof(m_nDices));         // 骰子大小
    pStartData->bQuickCatch = m_bQuickCatch;                    // 快速抓牌
    pStartData->bAllowChi = !IS_BIT_SET(m_dwGameFlags, MJ_GF_CHI_FORBIDDEN);  // 允许吃
    pStartData->bAnGangShow = IS_BIT_SET(m_dwGameFlags, MJ_GF_ANGANG_SHOW);     // 暗杠的牌能否显示

    pStartData->bJokerSortIn = IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_SORTIN);    // 财神牌不固定放头上
    pStartData->bBaibanNoSort = IS_BIT_SET(m_dwGameFlags, MJ_GF_BAIBAN_NOSORT);   // 替代财神牌不排序放

    pStartData->nBeginNO = m_nCatchFrom;                     // 开始摸牌位置
    pStartData->nJokerNO = m_nJokerNO;                       // 财神位置
    pStartData->nJokerID = m_nJokerID;                       // 财神牌ID
    pStartData->nJokerID2 = m_nJokerID2;                      // 财神牌ID2
    if (m_nJokerNO >= 0)
    {
        pStartData->nFanID = m_aryCard[m_nJokerNO].nID;        // 翻牌ID
    }
    else
    {
        pStartData->nFanID = INVALID_OBJECT_ID;                // 翻牌ID
    }
    pStartData->nTailTaken = m_nTailTaken;                     // 尾上被抓牌张数
    pStartData->nCurrentCatch = m_nCurrentCatch;                  // 当前抓牌位置
    pStartData->nPGCHWait = m_nPGCHWait;                      // 碰杠吃胡等待时间(秒)
    pStartData->nPGCHWaitEx = MJ_PGCH_WAIT_EXT;                 // 碰杠吃胡等待时间(追加)(秒)

    //定缺后计算天胡
    /*if(IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME))
    {
    if (m_nHuCount==0&&CalcHu_Zimo(m_nBanker,GetFirstCardOfChair(m_nBanker))) // 庄家能否天胡
    {
    pStartData->dwCurrentFlags = MJ_HU;
    }
    }*/
}

void CMyGameTable::FillupEnterGameInfo(void* pData, int nLen, int chairno, BOOL lookon /*= FALSE*/)
{
    __super::FillupEnterGameInfo(pData, nLen, chairno, lookon);

    GAME_ENTER_INFO* pEnterGame = (GAME_ENTER_INFO*)pData;

    //底注
    TCHAR szRoomID[32];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%d"), m_nRoomID);
    pEnterGame->nReserve[0] = GetPrivateProfileInt(_T("FixBaseSilver"), szRoomID, 0, GetINIFileName());
}

void CMyGameTable::FillupEndSaveGameResults(void* pData, int nLen, GAME_RESULT_EX GameResults[])
{
    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

    int nCount = 0;
    for (int i = 0; i < m_nTotalChairs; i++) //
    {
        if (!m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
        {
            continue;
        }
        CPlayer* ptrP = m_ptrPlayers[i];
        GameResults[nCount].nUserID = ptrP->m_nUserID;              // 用户ID
        GameResults[nCount].nTableNO = m_nTableNO;                   // 桌号
        GameResults[nCount].nChairNO = i;                            // 位置
        GameResults[nCount].nBaseScore = m_nBaseScore;                 // 基本积分
        GameResults[nCount].nBaseDeposit = m_nBaseDeposit;               // 基本银子
        GameResults[nCount].nOldScore = pGameWin->nOldScores[i];      // 旧积分
        GameResults[nCount].nOldDeposit = pGameWin->nOldDeposits[i];    // 旧银子
        GameResults[nCount].nScoreDiff = pGameWin->nScoreDiffs[i];     // 积分增减
        GameResults[nCount].nDepositDiff = pGameWin->nDepositDiffs[i];   // 银子输赢
        GameResults[nCount].nLevelID = pGameWin->nLevelIDs[i];       // 级别ID
        GameResults[nCount].nBout = 1;                            // 总回合
        GameResults[nCount].nBreakOff = 0;                            // 断线次数
        GameResults[nCount].nFee = pGameWin->nWinFees[i];        // 茶水费
        lstrcpy(GameResults[nCount].szLevelName, pGameWin->szLevelNames[i]);    // 级别名称

        // 耗时(秒)   经验值(分钟)
        CalcTimeCost(GameResults[nCount].nTimeCost, GameResults[nCount].nExperience);

        /*if(pGameWin->nScoreDiffs[i] > 0){
        GameResults[nCount].nWin            = 1;                            // 赢(次数)
        }else if(pGameWin->nScoreDiffs[i] == 0){
        GameResults[nCount].nStandOff   = 1;                            // 和(次数)
        }else{
        GameResults[nCount].nLoss       = 1;                            // 输(次数)
        }*/

        int nPreSaveAllDeposit = m_stPreSaveInfo[i].nPreSaveAllDeposit;
        if (nPreSaveAllDeposit > 0)  //这里根据总输赢计算
        {
            GameResults[nCount].nWin = 1;
        }
        else if (nPreSaveAllDeposit == 0)
        {
            GameResults[nCount].nStandOff = 1;
        }
        else
        {
            GameResults[nCount].nLoss = 1;
        }

        nCount++;
    }
}
int CMyGameTable::FillupGameWin(void* pData, int nLen, int chairno)
{
    LPGAME_WIN_RESULT pGameWinResult = (LPGAME_WIN_RESULT)pData;

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        pGameWinResult->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
        XygInitChairCards(pGameWinResult->nChairCards[i], CHAIR_CARDS);
        GetChairCards(i, pGameWinResult->nChairCards[i], CHAIR_CARDS); // 填充牌的ID方阵
    }

    for (i = 0; i < m_nTotalChairs; i++)
    {
        for (int j = 0; j < 4; ++j)
        {
            XygInitChairCards(pGameWinResult->nOutCards[i][j].nCardIDs, MJ_UNIT_LEN);
            memset(pGameWinResult->nOutCards[i][j].nReserved, -1, sizeof(pGameWinResult->nOutCards[i][j].nReserved));
        }
        pGameWinResult->nOutCount[i] = GetChairOutCards(i, pGameWinResult->nOutCards[i], MJ_GANG | MJ_PENG);
    }

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    CString strIniFile = GetINIFileName();
    int nPromptDeposit = GetPrivateProfileInt(_T("PromptDeposit"), szRoomID, 0, strIniFile);
    pGameWinResult->nReserved[0] = nPromptDeposit;

    for (i = 0; i < m_nTotalChairs; i++)
    {
        pGameWinResult->gamewin.nTingChairs[i] = m_HuReady[i];
    }

    pGameWinResult->gamewin.nDetailCount = m_nTotalChairs;
    memcpy(pGameWinResult->nFees, m_nRoomFees, sizeof(m_nRoomFees));

    //mjtable
    {
        LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

        int i = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            pGameWin->nMnGangs[i] = m_MnGangCards[i].GetSize();
            pGameWin->nAnGangs[i] = m_AnGangCards[i].GetSize();
            pGameWin->nPnGangs[i] = m_PnGangCards[i].GetSize();
            pGameWin->nHuaCount[i] = m_nHuaCards[i].GetSize();
        }
        memcpy(pGameWin->nResults, m_nResults, sizeof(m_nResults));

        for (i = 0; i < MJ_CHAIR_COUNT; i++)
        {
            pGameWin->nHuChairs[i] = 0;
        }
        int hu_count = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                pGameWin->nHuChairs[i] = 1;
                hu_count++;
            }
        }
        pGameWin->nLoseChair = m_nLoseChair;
        pGameWin->nHuChair = m_nHuChair;
        pGameWin->nHuCount = m_nHuCount;
        pGameWin->nHuCard = m_nHuCard;
        pGameWin->nBankerHold = m_nBankerHold;
        pGameWin->nNextBanker = CalcNextBanker(pData, nLen);
    }

    //ctable 去掉了茶水费计算，茶水费在开局时扣除，因此不支持赢家扣茶水费模式
    {
        LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

        pGameWin->dwWinFlags = m_dwWinFlags;

        pGameWin->nTotalChairs = m_nTotalChairs;
        pGameWin->nBoutCount = m_nBoutCount;
        pGameWin->nBanker = m_nBanker;

        memcpy(pGameWin->nPartnerGroup, m_nPartnerGroup, sizeof(m_nPartnerGroup));

        pGameWin->nBaseScore = m_nBaseScore;
        pGameWin->nBaseDeposit = m_nBaseDeposit;

        //填充pGameWin->nOldScores和pGameWin->nOldDeposits，参与玩家之前的积分和银两
        FillupOldScoreDeposit(pData, nLen);

        CalcWinPoints(pData, nLen, chairno, pGameWin->nWinPoints);
        pGameWin->bBankWin = IsBankWin(pData, nLen, chairno);
        CalcResultDiffs(pData, nLen, pGameWin->nScoreDiffs, pGameWin->nDepositDiffs);       //输赢银子
        CalcResultDiffsEx(pData, nLen, pGameWin->nScoreDiffs, pGameWin->nDepositDiffs);     //输赢积分

        if (m_bNeedDeposit && m_nBaseDeposit) // 玩银子
        {
            assert(0 == CalcSurplus(pGameWin->nDepositDiffs));

            //XL GameWin的时候不需要计算茶水费
            int totalfee = 0;

            //矫正输赢
            CompensateDepositsEx(pGameWin->nOldDeposits, pGameWin->nDepositDiffs);

            //验证输赢
            CheckDepositResults(pGameWin->nDepositDiffs, pGameWin->nWinFees, totalfee);
        }
        CalcLevelIDs(pGameWin->nOldScores, pGameWin->nScoreDiffs, pGameWin->nLevelIDs);

        pGameWin->dwNextFlags |= IsNextBoutNoLeave(pData, nLen);
        pGameWin->dwNextFlags |= IsNextBoutBankerReset(pData, nLen);

        //Add on 20130503
        //是否是还未结算的非Idle玩家，给个状态
        //低位0～7位表示各个玩家状态，1为IdlePlayer，已经结算的空闲玩家，或者后来进入的空闲玩家
        FillPlayerStatus(pData, nLen);
        //Add end
    }

    //发给客户端的总输赢
    for (i = 0; i < TOTAL_CHAIRS; i++)
    {
        pGameWinResult->nTotalDepositDiff[i] = m_stPreSaveInfo[i].nPreSaveAllDeposit;
    }

    //实际输赢值需要在矫正后
    /*LPHU_DETAILS_SMALL ptr_huDetailsSmall = LPHU_DETAILS_SMALL((PBYTE)pGameWin + sizeof(GAME_WIN_RESULT));
    for(i=0;i<TOTAL_CHAIRS;i++)
    {
    CopyHuDetailsSmall(i, *ptr_huDetailsSmall, m_huDetails[i]);
    *ptr_huDetailsSmall++;
    }*/

    return 1;
}

int CMyGameTable::GetGameWinSize()
{
    return sizeof(GAME_WIN_RESULT);
}

int CMyGameTable::CompensateDeposits(int nOldDeposits[], int nDepositDiffs[])
{
    int totalwin = 0;
    int totalLose = 0;
    int loseCount = 0;
    double dblDeposits[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(dblDeposits, sizeof(dblDeposits));

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        dblDeposits[i] = nDepositDiffs[i];
        if (nDepositDiffs[i] > 0)
        {
            totalwin += nDepositDiffs[i];
        }
        else if (nDepositDiffs[i] < 0)
        {
            totalLose += nDepositDiffs[i];
            loseCount++;
        }
    }

    if (IS_BIT_SET(m_dwGameFlags, GF_LEVERAGE_ALLOWED)) // 允许以小博大
    {
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int depositDiff = nDepositDiffs[i];
            int depositOld = nOldDeposits[i];
            if (depositDiff < 0) // 输家
            {
                if (depositOld + depositDiff < 0) // 银子不够输
                {
                    nDepositDiffs[i] = -depositOld; // 输光已有银子
                    for (int j = 0; j < m_nTotalChairs; j++)
                    {
                        if (dblDeposits[j] > 0)
                        {
                            double dblReturn = (-depositDiff - depositOld);
                            nDepositDiffs[j] -= ceil(dblReturn / totalwin * dblDeposits[j]);
                            if (nDepositDiffs[j] < 0)
                            {
                                nDepositDiffs[j] = 0;
                            }
                        }
                    }
                }
            }
        }
    }
    else   // 不允许以小博大
    {
        //先检查有没有多赢
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int maxWinDeposit = min(max(nOldDeposits[i] * loseCount, m_nInitDeposit[i] * loseCount), nDepositDiffs[i]);
            if (nDepositDiffs[i] > 0 && maxWinDeposit < nDepositDiffs[i])
            {
                nDepositDiffs[i] = maxWinDeposit;
                double dblReturn = dblDeposits[i] - nDepositDiffs[i];
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (dblDeposits[j] < 0)
                    {
                        int nLessLose = floor(dblReturn * dblDeposits[j] / totalLose);
                        nDepositDiffs[j] += nLessLose;
                        if (nDepositDiffs[j] > 0)
                        {
                            nDepositDiffs[j] = 0;
                        }
                    }
                }
                //以小博大系统提示
                m_nDepositWinLimit[i] = maxWinDeposit;
            }
        }

        //重新计算
        totalwin = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            dblDeposits[i] = nDepositDiffs[i];
            if (nDepositDiffs[i] > 0)
            {
                totalwin += nDepositDiffs[i];
            }
        }

        //在检查是否不够输
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int depositDiff = nDepositDiffs[i];
            int depositOld = nOldDeposits[i];
            if (depositDiff < 0) // 输家
            {
                if (depositOld + depositDiff < 0) // 银子不够输
                {
                    nDepositDiffs[i] = -depositOld; // 输光已有银子
                    for (int j = 0; j < m_nTotalChairs; j++)
                    {
                        if (dblDeposits[j] > 0)
                        {
                            double dblReturn = (-depositDiff - depositOld);
                            int nMoreWin = ceil(dblReturn / totalwin * dblDeposits[j]);

                            nDepositDiffs[j] -= nMoreWin;
                            if (nDepositDiffs[j] < 0)
                            {
                                nDepositDiffs[j] = 0;
                            }
                        }
                    }
                }
            }
        }
    }

    return CalcSurplus(nDepositDiffs);
}

int CMyGameTable::CompensateDeposits2(int nOldDeposits[], int nDepositDiffs[], int nCheckType)
{
    int totalwin = 0;
    int totalLose = 0;
    int loseCount = 0;
    double dblDeposits[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(dblDeposits, sizeof(dblDeposits));

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        dblDeposits[i] = nDepositDiffs[i];
        if (nDepositDiffs[i] > 0)
        {
            totalwin += nDepositDiffs[i];
        }
        else if (nDepositDiffs[i] < 0)
        {
            totalLose += nDepositDiffs[i];
            loseCount++;
        }
    }

    if (IS_BIT_SET(m_dwGameFlags, GF_LEVERAGE_ALLOWED)) // 允许以小博大
    {
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int depositDiff = nDepositDiffs[i];
            int depositOld = nOldDeposits[i];
            if (depositDiff < 0) // 输家
            {
                if (depositOld + depositDiff < 0) // 银子不够输
                {
                    nDepositDiffs[i] = -depositOld; // 输光已有银子
                    for (int j = 0; j < m_nTotalChairs; j++)
                    {
                        if (dblDeposits[j] > 0)
                        {
                            double dblReturn = (-depositDiff - depositOld);
                            nDepositDiffs[j] -= ceil(dblReturn / totalwin * dblDeposits[j]);
                            if (nDepositDiffs[j] < 0)
                            {
                                nDepositDiffs[j] = 0;
                            }
                        }
                    }
                }
            }
        }
    }
    else   // 不允许以小博大
    {
        //先检查有没有多赢
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int maxWinDeposit = min(max(nOldDeposits[i] * loseCount, m_nInitDeposit[i] * loseCount), nDepositDiffs[i]);
            if (nDepositDiffs[i] > 0 && maxWinDeposit < nDepositDiffs[i])
            {
                nDepositDiffs[i] = maxWinDeposit;
                double dblReturn = dblDeposits[i] - nDepositDiffs[i];
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (dblDeposits[j] < 0)
                    {
                        int nLessLose = floor(dblReturn * dblDeposits[j] / totalLose);
                        nDepositDiffs[j] += nLessLose;
                        if (nDepositDiffs[j] > 0)
                        {
                            nDepositDiffs[j] = 0;
                        }

                        if (MJ_HU_HUAZHU == nCheckType)
                        {
                            m_stCheckInfo[j].nHuaZhuDeposit[i] += nLessLose;
                            if (m_stCheckInfo[j].nHuaZhuDeposit[i] > 0)
                            {
                                m_stCheckInfo[j].nHuaZhuDeposit[i] = 0;
                            }
                            m_stCheckInfo[i].nHuaZhuDeposit[j] -= nLessLose;
                            if (m_stCheckInfo[i].nHuaZhuDeposit[j] < 0)
                            {
                                m_stCheckInfo[i].nHuaZhuDeposit[j] = 0;
                            }
                        }

                        if (MJ_HU_TING == nCheckType)
                        {
                            m_stCheckInfo[j].nDaJiaoDeposit[i] += nLessLose;
                            if (m_stCheckInfo[j].nDaJiaoDeposit[i] > 0)
                            {
                                m_stCheckInfo[j].nDaJiaoDeposit[i] = 0;
                            }
                            m_stCheckInfo[i].nDaJiaoDeposit[j] -= nLessLose;
                            if (m_stCheckInfo[i].nDaJiaoDeposit[j] < 0)
                            {
                                m_stCheckInfo[i].nDaJiaoDeposit[j] = 0;
                            }
                        }
                    }
                }

                //以小博大系统提示
                m_nDepositWinLimit[i] = maxWinDeposit;
            }
        }

        //重新计算
        totalwin = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            dblDeposits[i] = nDepositDiffs[i];
            if (nDepositDiffs[i] > 0)
            {
                totalwin += nDepositDiffs[i];
            }
        }

        //在检查是否不够输
        for (i = 0; i < m_nTotalChairs; i++)
        {
            int depositDiff = nDepositDiffs[i];
            int depositOld = nOldDeposits[i];
            if (depositDiff < 0) // 输家
            {
                if (depositOld + depositDiff < 0) // 银子不够输
                {
                    nDepositDiffs[i] = -depositOld; // 输光已有银子
                    for (int j = 0; j < m_nTotalChairs; j++)
                    {
                        if (dblDeposits[j] > 0)
                        {
                            double dblReturn = (-depositDiff - depositOld);
                            int nMoreWin = ceil(dblReturn / totalwin * dblDeposits[j]);

                            nDepositDiffs[j] -= nMoreWin;
                            if (nDepositDiffs[j] < 0)
                            {
                                nDepositDiffs[j] = 0;
                            }

                            if (MJ_HU_HUAZHU == nCheckType)
                            {
                                m_stCheckInfo[j].nHuaZhuDeposit[i] -= nMoreWin;
                                if (m_stCheckInfo[j].nHuaZhuDeposit[i] < 0)
                                {
                                    m_stCheckInfo[j].nHuaZhuDeposit[i] = 0;
                                }
                                m_stCheckInfo[i].nHuaZhuDeposit[j] += nMoreWin;
                                if (m_stCheckInfo[i].nHuaZhuDeposit[j] > 0)
                                {
                                    m_stCheckInfo[i].nHuaZhuDeposit[j] = 0;
                                }
                            }

                            if (MJ_HU_TING == nCheckType)
                            {
                                m_stCheckInfo[j].nDaJiaoDeposit[i] -= nMoreWin;
                                if (m_stCheckInfo[j].nDaJiaoDeposit[i] < 0)
                                {
                                    m_stCheckInfo[j].nDaJiaoDeposit[i] = 0;
                                }
                                m_stCheckInfo[i].nDaJiaoDeposit[j] += nMoreWin;
                                if (m_stCheckInfo[i].nDaJiaoDeposit[j] > 0)
                                {
                                    m_stCheckInfo[i].nDaJiaoDeposit[j] = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return CalcSurplus(nDepositDiffs);
}

int CMyGameTable::CompensateDepositsEx(int nOldDeposits[], int nDepositDiffs[])
{
    if (IS_BIT_SET(m_dwGameFlags, GF_LEVERAGE_ALLOWED)) // 允许以小博大
    {

    }
    else
    {
        //预存nOldDeposits
        int nOldDepositsEx[TOTAL_CHAIRS];
        memcpy(nOldDepositsEx, nOldDeposits, sizeof(int)*TOTAL_CHAIRS);

        BOOL bNeedTransfer = FALSE;
        //矫正胡
        CompensateDeposits(nOldDepositsEx, nDepositDiffs);

        int i = 0;
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (nDepositDiffs[i] > 0)
            {
                UpdateHuItemDeposit(i, nDepositDiffs, m_stHuMultiInfo.nHuCount);
                if (m_huDetails[i].nHuGains[HU_GAIN_GPAO] > 0)
                {
                    bNeedTransfer = TRUE;
                }
            }
        }
        m_bNeedUpdate = FALSE;

        //呼叫转移-------------------------------------------zjl
        int nDepositDiffs0[TOTAL_CHAIRS];
        ZeroMemory(nDepositDiffs0, sizeof(nDepositDiffs0));
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            //胡牌输赢
            m_stEndGameCheckInfo.nHuDeposit[i] = nDepositDiffs[i];
            if (nDepositDiffs[i] < 0)
            {
                m_stEndGameCheckInfo.nHuPoint[i] = -1;
            }
            else if (nDepositDiffs[i] > 0)
            {
                m_stEndGameCheckInfo.nHuPoint[i] = 1;
            }

            nOldDepositsEx[i] += nDepositDiffs[i];
        }
        if (bNeedTransfer)
        {
            GameWinCallTransferDeposit(nOldDepositsEx, nDepositDiffs, nDepositDiffs0);
            m_bCallTransfer = FALSE;
        }

        //矫正花猪
        int nDepositDiffs1[TOTAL_CHAIRS];
        ZeroMemory(nDepositDiffs1, sizeof(nDepositDiffs1));

        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            nOldDepositsEx[i] += nDepositDiffs0[i];
            m_stPreSaveInfo[i].nPreSaveDeposit = nDepositDiffs[i]; //当前胡的(胡了未走，再收到游戏结束被清0了)

            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                int IgetJ = m_stCheckInfo[i].nHuaZhuPoint[j] * m_nBaseDeposit;
                m_stCheckInfo[i].nHuaZhuDeposit[j] = IgetJ;
                nDepositDiffs1[i] += IgetJ;
                m_stPreSaveInfo[i].nPreSaveAllFan += m_stCheckInfo[i].nHuaZhuPoint[j];
                if (m_stCheckInfo[i].nHuaZhuPoint[j] < 0)
                {
                    m_nEndGameFlag |= MJ_HU_HUAZHU;
                }
            }
        }

        CompensateDeposits2(nOldDepositsEx, nDepositDiffs1, MJ_HU_HUAZHU);

        //矫正大叫
        int nDepositDiffs2[TOTAL_CHAIRS];
        ZeroMemory(nDepositDiffs2, sizeof(nDepositDiffs2));

        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            //记录花猪输赢
            m_stEndGameCheckInfo.nHuaZhuDePosit[i] = nDepositDiffs1[i];
            if (nDepositDiffs1[i] < 0)
            {
                m_stEndGameCheckInfo.nHuaZhuPoint[i] = -1;
            }
            else if (nDepositDiffs1[i] > 0)
            {
                m_stEndGameCheckInfo.nHuaZhuPoint[i] = 1;
            }

            nOldDepositsEx[i] += nDepositDiffs1[i];

            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                int IgetJ = m_stCheckInfo[i].nDaJiaoPoint[j] * m_nBaseDeposit;
                m_stCheckInfo[i].nDaJiaoDeposit[j] = IgetJ;
                nDepositDiffs2[i] += IgetJ;
                m_stPreSaveInfo[i].nPreSaveAllFan += m_stCheckInfo[i].nDaJiaoPoint[j];

                if (m_stCheckInfo[i].nDaJiaoPoint[j] < 0)
                {
                    m_nEndGameFlag |= MJ_HU_TING;
                }
            }
        }

        CompensateDeposits2(nOldDepositsEx, nDepositDiffs2, MJ_HU_TING);

        //退税-----------------------------------------zjl
        int nDepositDiffs3[TOTAL_CHAIRS];
        ZeroMemory(nDepositDiffs3, sizeof(nDepositDiffs3));
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            nOldDepositsEx[i] += nDepositDiffs2[i];
            //记查大叫输赢
            m_stEndGameCheckInfo.nDajiaoDePosit[i] = nDepositDiffs2[i];
            if (nDepositDiffs2[i] < 0)
            {
                m_stEndGameCheckInfo.nDajiaoPoint[i] = -1;
            }
            else if (nDepositDiffs2[i] > 0)
            {
                m_stEndGameCheckInfo.nDajiaoPoint[i] = 1;
            }
        }
        //计算退税的钱
        if (m_bNewRuleOpen)
        {
            calcDrawBack(nOldDepositsEx, nDepositDiffs3);
        }
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            //记退税输赢
            m_stEndGameCheckInfo.nDrawBackDeposit[i] = nDepositDiffs3[i];
            if (nDepositDiffs3[i] < 0)
            {
                m_stEndGameCheckInfo.nDrawBackPoint[i] = -1;
            }
            else if (nDepositDiffs3[i] > 0)
            {
                m_stEndGameCheckInfo.nDrawBackPoint[i] = 1;
            }
        }


        AddNewCheckItem();

        //最后结果 胡+花猪+大叫+查大叫+呼叫转移
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            nDepositDiffs[i] = nDepositDiffs[i] + nDepositDiffs1[i] + nDepositDiffs2[i] + nDepositDiffs3[i] + nDepositDiffs0[i];
            m_stPreSaveInfo[i].nPreSaveAllDeposit += nDepositDiffs[i];
        }
    }

    return CalcSurplus(nDepositDiffs);
}

int CMyGameTable::CalcBaseDeposit(int nDeposits[], int tableno)
{
    int nBase = 0;

    int mindeposit = nDeposits[0];
    for (int i = 1; i < m_nTotalChairs; i++)
    {
        if (nDeposits[i] < mindeposit)
        {
            mindeposit = nDeposits[i];
        }
    }

    CString szIniFile = GetINIFileName();
    TCHAR szValue[64];
    memset(szValue, 0, sizeof(szValue));

    //这里还没计算过血流标志
    BOOL bXueLiu = XygGetOptionOneTrue(m_dwRoomOption, m_nTotalChairs, ROOM_TYPE_XUELIU);
    if (bXueLiu)
    {
        GetPrivateProfileString(_T("BaseSilverParams"), _T("XLParam1"), _T("250"), szValue, sizeof(szValue), szIniFile);
    }
    else
    {
        GetPrivateProfileString(_T("BaseSilverParams"), _T("Param1"), _T("250"), szValue, sizeof(szValue), szIniFile);
    }

    int param1 = atoi(szValue);
    if (mindeposit <= param1)
    {
        mindeposit = param1;
    }
    mindeposit /= param1;
    mindeposit = UwlLog2(mindeposit);

    nBase = UwlPow2(mindeposit);

    memset(szValue, 0, sizeof(szValue));

    if (bXueLiu)
    {
        GetPrivateProfileString(_T("BaseSilverParams"), _T("XLParam2"), _T("12.5"), szValue, sizeof(szValue), szIniFile);
    }
    else
    {
        GetPrivateProfileString(_T("BaseSilverParams"), _T("Param2"), _T("12.5"), szValue, sizeof(szValue), szIniFile);
    }

    double param2 = atof(szValue);
    nBase = ceil(param2 * nBase);
    return nBase;
}

int CMyGameTable::GetBaseDeposit(int deposit_mult /*= 1*/)
{
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    int fixBaseSilver = GetPrivateProfileInt(
            _T("FixBaseSilver"),    // section name
            szRoomID,           // key name
            0,              // default int
            GetINIFileName()                // initialization file name
        );
    if (fixBaseSilver)
    {
        return fixBaseSilver;
    }

    // 计算这一局的基本银子
    int deposits[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(deposits, sizeof(deposits));
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_ptrPlayers[i])
        {
            deposits[i] = m_ptrPlayers[i]->m_nDeposit;
        }
    }
    int tableno = (m_bTableEqual) ? 0 : m_nTableNO;
    return CalcBaseDeposit(deposits, tableno) * deposit_mult;
}

int CMyGameTable::GetRandomValue()
{
    srand(GetTickCount());
    return getRandomBetweenEx(1, 100);
}

void CMyGameTable::CalcPrompt3Cards(int chairno, int nCardIDs[], int nCardsLen)
{
    ZeroMemory(nCardIDs, nCardsLen);
    if (IS_BIT_SET(m_dwRoomOption[0], ROOM_TYPE_EXCHANGE3CARDS))
    {
        int nShapeCardsCount[EXCHANGE3CARDS_COUNT];
        ZeroMemory(nShapeCardsCount, sizeof(nShapeCardsCount));
        int nShapeCardsKindCount[EXCHANGE3CARDS_COUNT];
        ZeroMemory(nShapeCardsKindCount, sizeof(nShapeCardsKindCount));

        //clac per shape count
        int i = 0;
        for (i = 0; i < MAX_CARDS_LAYOUT_NUM; ++i)
        {
            int j = i / m_nLayoutMod;
            if (j >= 3)
            {
                break;
            }
            if (m_nCardsLayIn[chairno][i] <= 0)
            {
                continue;
            }

            nShapeCardsCount[j] += m_nCardsLayIn[chairno][i];
            nShapeCardsKindCount[j]++;
        }

        //sort ShapeCardsCount
        int nShapesIndex[EXCHANGE3CARDS_COUNT];
        for (i = 0; i < EXCHANGE3CARDS_COUNT; ++i)
        {
            nShapesIndex[i] = i;
        }
        for (i = 0; i < EXCHANGE3CARDS_COUNT; ++i)
        {
            for (int j = i + 1; j < EXCHANGE3CARDS_COUNT; ++j)
            {
                if (nShapeCardsCount[i] > nShapeCardsCount[j])
                {
                    int nTemp = nShapeCardsCount[i];
                    nShapeCardsCount[i] = nShapeCardsCount[j];
                    nShapeCardsCount[j] = nTemp;
                    nTemp = nShapeCardsKindCount[i];
                    nShapeCardsKindCount[i] = nShapeCardsKindCount[j];
                    nShapeCardsKindCount[j] = nTemp;
                    nTemp = nShapesIndex[i];
                    nShapesIndex[i] = nShapesIndex[j];
                    nShapesIndex[j] = nTemp;
                }
            }
        }

        //select 3 cards
        int nCount = 0;
        int nShape = -1;
        for (i = 0; i < EXCHANGE3CARDS_COUNT; ++i)
        {
            if (nShapeCardsCount[i] < EXCHANGE3CARDS_COUNT)
            {
                continue;
            }

            //select min ShapeCardsCount
            if (i == EXCHANGE3CARDS_COUNT - 1 || nShapeCardsCount[i] < nShapeCardsCount[i + 1])
            {
                nShape = nShapesIndex[i];
            }
            //no min
            else if (nShapeCardsCount[i] == nShapeCardsCount[i + 1])
            {
                //select min cardKind count
                if (nShapeCardsKindCount[i] < nShapeCardsKindCount[i + 1])
                {
                    nShape = nShapesIndex[i];
                }
                else
                {
                    nShape = (nShapesIndex[i] < nShapesIndex[i + 1]) ? nShapesIndex[i] : nShapesIndex[i + 1];
                }
            }
            //
            if (nShape < 0 || nShape >= EXCHANGE3CARDS_COUNT)
            {
                return;
            }
            for (int j = nShape * m_nLayoutMod; j < (nShape + 1) * m_nLayoutMod; ++j)
            {
                if (m_nCardsLayIn[chairno][j] <= 0)
                {
                    continue;
                }
                for (int z = 0; z < m_nCardsLayIn[chairno][j]; ++z)
                {
                    for (int x = 0; x < MAX_CARDSID; ++x)
                    {
                        if (chairno != m_aryCard[x].nChairNO)
                        {
                            continue;
                        }
                        int nCardID = m_aryCard[x].nID;
                        //judge is exsit
                        bool bExsit = false;
                        for (int y = 0; y < nCount; ++y)
                        {
                            if (nCardIDs[y] == nCardID)
                            {
                                bExsit = true;
                                break;
                            }
                        }
                        if (bExsit)
                        {
                            continue;
                        }
                        //get it
                        if (j == m_pCalclator->MJ_CalcIndexByID(nCardID, 0))
                        {
                            nCardIDs[nCount++] = nCardID;
                            if (nCount >= EXCHANGE3CARDS_COUNT)
                            {
                                return;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
}

BOOL CMyGameTable::OnAutoExchangeCards(LPEXCHANGE3CARDS pExchange3Cards)
{
    pExchange3Cards->nExchange3CardsCount = EXCHANGE3CARDS_COUNT;
    CalcPrompt3Cards(pExchange3Cards->nChairNO, pExchange3Cards->nExchange3Cards[0], pExchange3Cards->nExchange3CardsCount);
    return TRUE;
}

BOOL CMyGameTable::OnExchangeCards(LPEXCHANGE3CARDS pExchange3Cards)
{
    int chairno = pExchange3Cards->nChairNO;
    m_bExchangeCards[chairno] = true;
    if (FALSE == CheckExchange(pExchange3Cards))
    {
        OnAutoExchangeCards(pExchange3Cards);
    }
    memcpy(m_nExchangeCards[chairno], pExchange3Cards->nExchange3Cards[0], sizeof(m_nExchangeCards[chairno]));

    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (!m_bExchangeCards[i])
        {
            return FALSE;
        }
    }

    ExchangeCards(pExchange3Cards);

    RemoveStatus(TS_WAITING_EXCHANGE3CARDS);
    AddStatus(TS_WAITING_AUCTION);
    return TRUE;
}

BOOL CMyGameTable::ExchangeCards(LPEXCHANGE3CARDS pExchange3Cards)
{
    int nTemp[TOTAL_CHAIRS][EXCHANGE3CARDS_COUNT];
    memcpy(nTemp, m_nExchangeCards, sizeof(nTemp));

    //int nDir = GetRandomDirection();
    int nDir = GetExchangeDirection();
    for (int i = 0; i < TOTAL_CHAIRS; ++i)
    {
        int nSrcChairNo = GetExchangeChairNO(i, nDir);
        if (nSrcChairNo < 0 || nSrcChairNo >= TOTAL_CHAIRS)
        {
            continue;
        }
        memcpy(m_nExchangeCards[i], nTemp[nSrcChairNo], sizeof(m_nExchangeCards[i]));
    }

    pExchange3Cards->nExchangeDirection = nDir;
    UpdateHandCards(nDir);

    return TRUE;
}

BOOL CMyGameTable::CheckExchange(LPEXCHANGE3CARDS pExchange3Cards)
{
    if (pExchange3Cards->nExchange3CardsCount != EXCHANGE3CARDS_COUNT)
    {
        return FALSE;
    }

    for (int i = 0; i < EXCHANGE3CARDS_COUNT; ++i)
    {
        if (pExchange3Cards->nExchange3Cards[0][i] < 0 || pExchange3Cards->nExchange3Cards[0][i] >= MAX_CARDSID)
        {
            return FALSE;
        }
    }
    return TRUE;
}

BOOL CMyGameTable::UpdateHandCards(int nDir)
{
    for (int i = 0; i < TOTAL_CHAIRS; ++i)
    {
        int nSrcChairNo = GetExchangeChairNO(i, nDir);
        if (nSrcChairNo < 0 || nSrcChairNo >= TOTAL_CHAIRS)
        {
            continue;
        }
        for (int j = 0; j < EXCHANGE3CARDS_COUNT; ++j)
        {
            for (int z = 0; z < TOTAL_CARDS; ++z)
            {
                if (m_aryCard[z].nID == m_nExchangeCards[i][j])
                {
                    m_aryCard[z].nChairNO = i;
                    int shape = m_aryCard[z].nShape;
                    int value = m_aryCard[z].nValue;
                    m_nCardsLayIn[nSrcChairNo][shape * m_nLayoutMod + value]--;
                    m_nCardsLayIn[i][shape * m_nLayoutMod + value]++;
                    break;
                }
            }
        }
    }

    return TRUE;
}

int CMyGameTable::GetRandomDirection()
{
    srand(GetTickCount());
    return rand() % Dir_Max;
}

int CMyGameTable::GetExchangeChairNO(int nChairNo, int nDir)
{
    int nSrcChairNo = -1;
    switch (nDir)
    {
    case Dir_Clockwise:
    {
        nSrcChairNo = (TOTAL_CHAIRS + nChairNo - 1) % TOTAL_CHAIRS;
    }
    break;
    case Dir_AntiClockwise:
    {
        nSrcChairNo = (TOTAL_CHAIRS + nChairNo + 1) % TOTAL_CHAIRS;
    }
    break;
    case Dir_Opposite:
    {
        nSrcChairNo = (TOTAL_CHAIRS + nChairNo + 2) % TOTAL_CHAIRS;
    }
    break;
    }

    return nSrcChairNo;
}

int CMyGameTable::GetExchangeDirection()
{
    int nDir = GetRandomDirection();
    int nExchangeScore = GetExchangeCardsScore(nDir);
    m_stMakeCardInfo[0].nMakeExchange = nExchangeScore * 10;
    if (nExchangeScore >= 4)
    {
        return nDir;
    }

    if (0 == m_stMakeCardConfig.nExchangeOpen)
    {
        return nDir;
    }

    TCHAR szPercent[16];
    memset(szPercent, 0, sizeof(szPercent));
    sprintf_s(szPercent, "PrScore%d", nExchangeScore);
    int nFixPercent = GetPrivateProfileInt(_T("ExchangePercent"), szPercent, 0, GetINIFileName());
    if (nFixPercent <= 0)
    {
        return nDir;
    }

    int nRandValue = GetRandomValue();
    if (nRandValue > nFixPercent)
    {
        return nDir;
    }

    for (int i = 0; i < 3; i++)
    {
        if (i != nDir)
        {
            int nScore = GetExchangeCardsScore(i);
            if (nScore > nExchangeScore)
            {
                m_stMakeCardInfo[0].nMakeExchange += nScore;
                nDir = i;
                break;
            }
        }
    }

    return nDir;
}

int CMyGameTable::GetExchangeCardsScore(int nDir)
{
    int nExchangeScore = 0;
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        int nSrcChairNo = GetExchangeChairNO(i, nDir);
        if (nSrcChairNo < 0 || nSrcChairNo >= TOTAL_CHAIRS)
        {
            continue;
        }

        int nShape = m_pCalclator->MJ_CalculateCardShape(m_nExchangeCards[i][0], 0);
        int nSrcShape = m_pCalclator->MJ_CalculateCardShape(m_nExchangeCards[nSrcChairNo][0], 0);
        if (nShape != nSrcShape)
        {
            nExchangeScore++;
        }
    }

    return nExchangeScore;
}

DWORD CMyGameTable::SetStatusOnStart()
{
    m_dwWaitOperateTick = m_nDingQueWait + 3000;
    m_dwDingQueStartTime = GetTickCount();

    if (TRUE == IS_BIT_SET(m_dwRoomOption[0], ROOM_TYPE_EXCHANGE3CARDS))
    {
        return AddStatus(TS_PLAYING_GAME | TS_WAITING_EXCHANGE3CARDS);
    }

    return AddStatus(TS_PLAYING_GAME | TS_WAITING_AUCTION);
}

void CMyGameTable::StartDeal()
{
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    m_nDingQueWait = GetPrivateProfileInt(
            _T("dingquewait"),      // section name
            szRoomID,               // key name
            DINGQUE_WAIT,           // default int
            GetINIFilePath()        // initialization file name
        );

    m_nShowTask = GetPrivateProfileInt(
            _T("TaskInGame"),       // section name
            "Enable",               // key name
            FALSE,                  // default int
            GetINIFilePath()        // initialization file name
        );

    m_nTakeFeeTime = GetPrivateProfileInt(
            _T("TakeFeeTime"),      // section name
            "Time",                 // key name
            0,                      // default int
            GetINIFilePath()        // initialization file name
        );
    m_nGiveUpTime = GetPrivateProfileInt(
            _T("MyParams"),
            _T("GiveUpWaitTime"),
            10,
            GetINIFilePath()
        );

    m_nRechargeTime = GetPrivateProfileInt(
            _T("MyParams"),
            _T("RechargeWaitTime"),
            20,
            GetINIFilePath()
        );
    m_bNewRuleOpen = GetPrivateProfileInt(_T("GameVersion"), _T("newRuleOPen"), FALSE, GetINIFilePath());
    m_bCallTransfer = FALSE;
    m_nEndGameFlag = 0;
    memset(&m_stEndGameCheckInfo, 0, sizeof(m_stEndGameCheckInfo));
    m_nextAskNewTable = FALSE;
    m_bOpenSaveResultLog = GetPrivateProfileInt(_T("TransmitGameResultLog"), szRoomID, FALSE, GetINIFilePath());

    resetTask();
    //新手任务
    resetNewbieTask();
    ZeroMemory(m_nDepositWinLimit, sizeof(m_nDepositWinLimit));

    __super::StartDeal();

}

void CMyGameTable::resetTask()
{
    //std::map<int, PLAYERTASKINFO>::iterator it = m_mapPlayerTaskInfo.begin();
    //while (it != m_mapPlayerTaskInfo.end())
    //{
    //    for (int i = 0; i < MAX_TYPE_COUNT; i++)
    //    {
    //        it->second.taskDataEx[i].nCompleteNum = 0;
    //        it->second.taskDataEx[i].nReserved[0] = 0;
    //    }

    //    it++;
    //}
}

void CMyGameTable::resetNewbieTask()
{
    //PLAYERNEWBIETASKINFOMAP::iterator it = m_mapPlayerNewbieTaskInfo.begin();
    //while (it != m_mapPlayerNewbieTaskInfo.end())
    //{
    //    it->second.nCompleteNum = 0;
    //    it->second.nReserved[0] = 0;
    //    it++;
    //}
}

int CMyGameTable::GetPlayingNeedDeposit()
{
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);
    int nNeedDeposit = GetPrivateProfileInt(_T("MyParams"), szRoomID, 0, GetINIFileName());
    if (0 == nNeedDeposit)
    {
        int minDeposit = m_nInitDeposit[0] + m_nRoomFees[0];
        for (int i = 1; i < m_nTotalChairs; ++i)
        {
            if ((m_nInitDeposit[i] + m_nRoomFees[i]) < minDeposit)
            {
                minDeposit = m_nInitDeposit[i] + m_nRoomFees[i];
            }
        }
        nNeedDeposit = minDeposit;
    }
    return nNeedDeposit;
    /*int mode = GetPrivateProfileInt(_T("MyParams"), _T("NeedDepositMode"), 1, GetINIFileName());
    if (mode == 0)
    {
    int minDeposit = m_nInitDeposit[0];
    for (int i = 1; i < m_nTotalChairs; ++i)
    {
    if (m_nInitDeposit[i] < minDeposit)
    {
    minDeposit = m_nInitDeposit[i];
    }
    }

    return minDeposit;
    }

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf(szRoomID, _T("%ld"), m_nRoomID);
    int nNeedDeposit = GetPrivateProfileInt(_T("MyParams"),szRoomID,1000,GetINIFileName());
    return nNeedDeposit;*/
}

BOOL CMyGameTable::IsAllPlayerGiveUp()
{
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (m_nGiveUpChair[i] != INVALID_OBJECT_ID)
        {
            return FALSE;
        }
    }

    return TRUE;
}

BOOL CMyGameTable::IsPlayerFitGiveUp(int chairno)
{
    //改为<=0放弃
    return m_ptrPlayers[chairno]
        && !m_ptrPlayers[chairno]->m_bIdlePlayer
        && m_ptrPlayers[chairno]->m_nDeposit <= 0;
}

BOOL CMyGameTable::OnPlayeRecharge(int chairno)
{
    m_bPlayerRecharge = TRUE;
    m_bShowGiveUp[chairno] = FALSE;
    m_dwGiveUpStartTime = GetTickCount();

    return TRUE;
}

BOOL CMyGameTable::OnPlayerGiveUp(int chairno)
{
    if (INVALID_OBJECT_ID != m_nGiveUpChair[chairno])
    {
        m_HuReady[chairno] = MJ_GIVE_UP;
        m_nGiveUpChair[chairno] = INVALID_OBJECT_ID;
        m_bShowGiveUp[chairno] = FALSE;

        if (chairno == GetCurrentChair())
        {
            //当前玩家转移到下一个位置
            int next = GetNextChair(chairno);
            if (next >= 0)
            {
                SetCurrentChair(next);
            }
        }

        return TRUE;
    }

    return FALSE;
}

BOOL CMyGameTable::OnPlayerNotGiveUp(int chairno)
{
    if (INVALID_OBJECT_ID != m_nGiveUpChair[chairno])
    {
        m_nGiveUpChair[chairno] = INVALID_OBJECT_ID;
        m_bShowGiveUp[chairno] = FALSE;

        return TRUE;
    }

    return FALSE;
}

DWORD CMyGameTable::SetStatusOnGiveUp()
{
    m_dwGiveUpStartTime = GetTickCount();
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_THROW;
    m_dwStatus &= ~TS_WAITING_CATCH;
    m_dwStatus |= TS_WAITING_GIVEUP;
    return m_dwStatus;
}

DWORD CMyGameTable::RemoveStatusOnGiveUp()
{
    m_bPlayerRecharge = FALSE;
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_GIVEUP;
    m_dwStatus |= TS_WAITING_CATCH;
    return m_dwStatus;
}

void CMyGameTable::saveAbortPlayerInfo(SOLO_PLAYER soloPlayer)
{
    if (soloPlayer.nChairNO < TOTAL_CHAIRS && TOTAL_CHAIRS >= 0)
    {
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nUserID = soloPlayer.nUserID;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nTableNO = soloPlayer.nTableNO;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nChairNO = soloPlayer.nChairNO;
        strcpy_s(m_stAbortPlayerInfo[soloPlayer.nChairNO].szUsername, soloPlayer.szUsername);
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nDeposit = soloPlayer.nDeposit;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nNickSex = soloPlayer.nNickSex;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nPortrait = soloPlayer.nPortrait;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nWin = soloPlayer.nWin;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nLoss = soloPlayer.nLoss;
        m_stAbortPlayerInfo[soloPlayer.nChairNO].nStandOff = soloPlayer.nStandOff;
    }
}

void CMyGameTable::saveGameStartPlayerInfo(SOLO_PLAYER soloPlayer)
{
    if (soloPlayer.nChairNO < TOTAL_CHAIRS && TOTAL_CHAIRS >= 0)
    {
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nUserID = soloPlayer.nUserID;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nTableNO = soloPlayer.nTableNO;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nChairNO = soloPlayer.nChairNO;
        strcpy_s(m_stGameStartPlayerInfo[soloPlayer.nChairNO].szUsername, soloPlayer.szUsername);
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nDeposit = soloPlayer.nDeposit;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nNickSex = soloPlayer.nNickSex;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nPortrait = soloPlayer.nPortrait;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nWin = soloPlayer.nWin;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nLoss = soloPlayer.nLoss;
        m_stGameStartPlayerInfo[soloPlayer.nChairNO].nStandOff = soloPlayer.nStandOff;
    }
}

void CMyGameTable::FillupGameStartPlayerInfo(void* pData, int offsetLen)
{
    LPABORTPLAYER_INFO pGamePlayerInfo = LPABORTPLAYER_INFO((PBYTE)pData + offsetLen);
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        ABORTPLAYER_INFO stGamePlayerInfo = m_stGameStartPlayerInfo[i];
        memcpy(pGamePlayerInfo, &stGamePlayerInfo, sizeof(ABORTPLAYER_INFO));
        pGamePlayerInfo++;
    }
}

int CMyGameTable::getTotalAbortPlayerCount()
{
    int i = 0;
    int nAbortPlayerCount = 0;
    for (i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (m_stAbortPlayerInfo[i].nUserID > 0)
        {
            nAbortPlayerCount++;
        }
    }

    return nAbortPlayerCount;
}

BOOL CMyGameTable::IsXueLiuRoom()
{
    return m_bIsXueLiuRoom;
}

void CMyGameTable::ConstructGameData()
{
    //计算是否血流房间
    m_bIsXueLiuRoom = XygGetOptionOneTrue(m_dwRoomOption, m_nTotalChairs, ROOM_TYPE_XUELIU);

    CString initName = GetINIFileName();
    TCHAR szRoomID[32];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%d"), m_nRoomID);
    m_feeRatioToBaseDeposit = GetPrivateProfileInt(_T("FeeRatioToBaseDeposit"), szRoomID, 0, initName);

    TCHAR szSection[32];
    memset(szSection, 0, sizeof(szSection));
    sprintf_s(szSection, "TableFee%d", m_nRoomID);
    int nCount = GetPrivateProfileInt(szSection, _T("Count"), 0, initName);
    if (nCount <= 0 || nCount > 32)
    {
        return;
    }

    CString sTmp;
    for (int i = 0; i < nCount; i++)
    {
        TCHAR szValue[64];
        memset(szValue, 0, sizeof(szValue));
        sTmp.Format(_T("%d"), i);
        GetPrivateProfileString(szSection, sTmp, _T(""), szValue, sizeof(szValue), initName);
        if (szValue[0] == 0)
        {
            return;
        }
        TCHAR* fields[8];
        memset(fields, 0, sizeof(fields));
        TCHAR* p1, *p2;
        p1 = szValue;
        int nFields = Svr_RetrieveFields(p1, fields, 8, &p2);
        if (nFields < 3)
        {
            return;
        }

        int nTableNO1 = atoi(fields[0]);
        int nTableNO2 = atoi(fields[1]);
        int feeRatio = atoi(fields[2]);
        if (m_nTableNO >= nTableNO1 && m_nTableNO <= nTableNO2)
        {
            m_feeRatioToBaseDeposit = feeRatio;
            return;
        }
    }
}

int CMyGameTable::GetHuItemCount(int chairno)
{
    int nHuCount = 0;

    try
    {
        std::vector<HU_ITEM_INFO>::iterator it;
        for (it = m_vecHuItems[chairno].begin(); it != m_vecHuItems[chairno].end(); ++it)
        {
            if (it->bWin)
            {
                int flag = it->nHuFlag;
                if (flag != MJ_HU_MNGANG && flag != MJ_HU_ANGANG && flag != MJ_HU_PNGANG && flag != MJ_HU_HUAZHU && flag != MJ_HU_TING)
                {
                    nHuCount++;
                }
            }
        }
    }
    catch (...)
    {
        UwlLogFile(_T("GetHuItemCount Exception"));
    }

    return nHuCount;
}

int CMyGameTable::GetHuItemIDs(int chairno, int nCardID[])
{
    int nHuCount = 0;

    try
    {
        std::vector<HU_ITEM_INFO>::iterator it;
        for (it = m_vecHuItems[chairno].begin(); it != m_vecHuItems[chairno].end(); ++it)
        {
            if (it->bWin)
            {
                int flag = it->nHuFlag;
                if (flag != MJ_HU_MNGANG && flag != MJ_HU_ANGANG && flag != MJ_HU_PNGANG && flag != MJ_HU_HUAZHU && flag != MJ_HU_TING && flag != MJ_HU_CALLTRANSFER && flag != MJ_HU_DRAWBACK)
                {
                    nCardID[nHuCount] = it->nHuID;
                    nHuCount++;

                    if (nHuCount >= MAX_CARDS_PER_CHAIR / 2)
                    {
                        break;
                    }
                }
            }
        }
    }
    catch (...)
    {
        UwlLogFile(_T("GetHuItemIDs Exception"));
    }

    return nHuCount;
}

int CMyGameTable::GetTotalItemCount(int chairno)
{
    return m_vecHuItems[chairno].size();
}

int CMyGameTable::GetNoSendItemCount(int chairno)
{
    int nNoSendCount = 0;

    std::vector<HU_ITEM_INFO>::iterator it;
    for (it = m_vecHuItems[chairno].begin(); it != m_vecHuItems[chairno].end(); ++it)
    {
        if (it->bSend == FALSE)
        {
            nNoSendCount++;
        }
    }

    return nNoSendCount;
}

void CMyGameTable::FinishHu(int cardchair, int chairno, int cardid)
{
    int nAlreadyHu = 0;
    int nLastChair = chairno;
    int nBeginChair = cardchair;
    int nCurHuCount = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_HuMJID[nBeginChair] == cardid)  //多人胡同一张牌
        {
            nLastChair = nBeginChair;
            nCurHuCount++;
        }
        else if (m_HuMJID[nBeginChair] > -1)
        {
            nAlreadyHu++;
        }

        nBeginChair = CTable::GetNextChair(nBeginChair);
    }

    if ((nCurHuCount > 1) && (nAlreadyHu < 1)) //首胡为一炮多响时，则下一局由放炮玩家坐庄
    {
        m_nLoseChair = cardchair;
    }

    if (m_HuReady[chairno] == MJ_HU_QGNG) //被抢杠，去掉这张牌
    {
        LoseCard(cardchair, cardid);
        SetStatusOfCard(cardid, CS_OUT);
        //SetChairOfCard(cardid, chairno);
    }

    if (IsXueLiuRoom())
    {
        if (m_HuReady[chairno] == MJ_HU_ZIMO || m_HuReady[chairno] == MJ_HU_HDLY) //自摸，去掉这张牌
        {
            LoseCard(chairno, cardid);
            SetStatusOfCard(cardid, CS_OUT);
        }
    }

    //胡牌成功
    CancelSituationOfGang();
    CancelSituationInCard();

    //当前玩家转移到下一个位置
    int next = GetNextChair(nLastChair);
    if (next >= 0)
    {
        SetCurrentChair(next);
    }

    //等待下家摸牌
    RemoveStatus(TS_WAITING_THROW);
    AddStatus(TS_WAITING_CATCH);
    //胡后的时候刷新跟牌记录
    memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));

    // 计算得分
    //memset(m_WaitOPE, 0, sizeof(m_WaitOPE));

    if (-1 == m_nLatestThrowNO)
    {
        m_nLatestThrowNO = nLastChair;
    }
}

void CMyGameTable::FillupHuItem(void* pData, int nLen, int chairno, int count)
{
    if (count <= 0)
    {
        return;
    }

    int nHuCount = m_vecHuItems[chairno].size();
    if (nHuCount < count)
    {
        return;
    }

    LPHU_ITEM_INFO pHuItem = LPHU_ITEM_INFO((PBYTE)pData + sizeof(HU_ITEM_HEAD));
    for (int i = 0; i < count; i++)
    {
        HU_ITEM_INFO& stHuItem = m_vecHuItems[chairno].at(nHuCount - 1 - i);
        stHuItem.bSend = TRUE;
        memcpy(pHuItem, &stHuItem, sizeof(HU_ITEM_INFO));
        pHuItem++;
    }
}

void CMyGameTable::FillupAllHuItems(void* pData, int offsetLen, int chairno, int count)
{
    HU_ITEM_HEAD itemHead;
    ZeroMemory(&itemHead, sizeof(itemHead));
    itemHead.nChairNO = chairno;
    itemHead.nCount = count;
    itemHead.nPreSaveAllDeposit = m_stPreSaveInfo[chairno].nPreSaveAllDeposit;
    LPHU_ITEM_HEAD pItemHead = LPHU_ITEM_HEAD((PBYTE)pData + offsetLen);
    memcpy(pItemHead, &itemHead, sizeof(HU_ITEM_HEAD));
    FillupHuItem(pItemHead, offsetLen, chairno, count);
}

void CMyGameTable::FillupAllPCHuItems(void* pData, int offsetLen, int count[])
{
    HU_ITEM_HEAD_PC itemHeadPC;
    ZeroMemory(&itemHeadPC, sizeof(itemHeadPC));
    memcpy(itemHeadPC.nItemCount, count, sizeof(itemHeadPC.nItemCount));
    LPHU_ITEM_HEAD_PC pItemHeadPC = LPHU_ITEM_HEAD_PC((PBYTE)pData + offsetLen);
    memcpy(pItemHeadPC, &itemHeadPC, sizeof(HU_ITEM_HEAD_PC));

    LPHU_ITEM_INFO pHuItem = LPHU_ITEM_INFO((PBYTE)pItemHeadPC + sizeof(HU_ITEM_HEAD_PC));
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        int nHuCount = m_vecHuItems[i].size();
        if (nHuCount == 0)
        {
            continue;
        }

        for (int j = 0; j < nHuCount; j++)
        {
            HU_ITEM_INFO& stHuItem = m_vecHuItems[i].at(nHuCount - 1 - j);
            stHuItem.bSend = TRUE;
            memcpy(pHuItem, &stHuItem, sizeof(HU_ITEM_INFO));
            pHuItem++;
        }
    }
}

void CMyGameTable::FillupPlayerHu(void* pData, int nLen, int chairno)
{
    //这里使用LPGAME_WIN_RESULT是因为客户端的结果界面用的该结构体

    LPGAME_WIN_RESULT pGameWinResult = (LPGAME_WIN_RESULT)pData;

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    CString strIniFile = GetINIFileName();
    int nPromptDeposit = GetPrivateProfileInt(_T("PromptDeposit"), szRoomID, 0, strIniFile);
    pGameWinResult->nReserved[0] = nPromptDeposit;

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        pGameWinResult->gamewin.nTingChairs[i] = m_HuReady[i];
    }

    for (i = 0; i < m_nTotalChairs; i++)
    {
        pGameWinResult->nCardsCount[i] = XygCardRemains(m_nCardsLayIn[i]);  // 每个玩家手里的牌的张数
        XygInitChairCards(pGameWinResult->nChairCards[i], CHAIR_CARDS);
        if (i == chairno)
        {
            GetChairCards(i, pGameWinResult->nChairCards[i], CHAIR_CARDS); // 填充牌的ID方阵
        }
    }

    for (i = 0; i < m_nTotalChairs; i++)
    {
        for (int j = 0; j < 4; ++j)
        {
            XygInitChairCards(pGameWinResult->nOutCards[i][j].nCardIDs, MJ_UNIT_LEN);
            memset(pGameWinResult->nOutCards[i][j].nReserved, -1, sizeof(pGameWinResult->nOutCards[i][j].nReserved));
        }

        if (m_nResults[i] > 0 || IS_BIT_SET(m_HuReady[i], MJ_GIVE_UP))
        {
            pGameWinResult->nOutCount[i] = GetChairOutCards(i, pGameWinResult->nOutCards[i], MJ_GANG | MJ_PENG | MJ_CHI);
        }
    }

    pGameWinResult->gamewin.nDetailCount = m_nTotalChairs;
    memcpy(pGameWinResult->nFees, m_nRoomFees, sizeof(m_nRoomFees));

    {
        LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

        int i = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            pGameWin->nMnGangs[i] = m_MnGangCards[i].GetSize();
            pGameWin->nAnGangs[i] = m_AnGangCards[i].GetSize();
            pGameWin->nPnGangs[i] = m_PnGangCards[i].GetSize();
            pGameWin->nHuaCount[i] = m_nHuaCards[i].GetSize();
        }
        memcpy(pGameWin->nResults, m_nResults, sizeof(m_nResults));

        for (i = 0; i < MJ_CHAIR_COUNT; i++)
        {
            pGameWin->nHuChairs[i] = 0;
        }
        int hu_count = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                pGameWin->nHuChairs[i] = 1;
                hu_count++;
            }
        }
        pGameWin->nLoseChair = m_nLoseChair;
        pGameWin->nHuChair = m_nHuChair;
        pGameWin->nHuCount = m_nHuCount;
        pGameWin->nHuCard = m_nHuCard;
        //pGameWin->nBankerHold = m_nBankerHold;
        //pGameWin->nNextBanker = CalcNextBanker(pData, nLen);
    }

    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

    pGameWin->dwWinFlags = m_dwWinFlags;

    pGameWin->nTotalChairs = m_nTotalChairs;
    pGameWin->nBoutCount = m_nBoutCount;
    pGameWin->nBanker = m_nBanker;

    memcpy(pGameWin->nPartnerGroup, m_nPartnerGroup, sizeof(m_nPartnerGroup));

    pGameWin->nBaseScore = m_nBaseScore;
    pGameWin->nBaseDeposit = m_nBaseDeposit;

    pGameWin->bBankWin = IsBankWin(pData, nLen, chairno);
    if (m_bNeedDeposit && m_nBaseDeposit) // 玩银子
    {

        for (int i = 0; i < m_nTotalChairs; ++i)
        {
            const CPLAYER_INFO& playerInfo = m_PlayersBackup[i];
            if (playerInfo.nUserID != 0)
            {
                pGameWinResult->nTotalDepositDiff[i] = m_stPreSaveInfo[i].nPreSaveAllDeposit;
            }
        }
    }
    CalcLevelIDs(pGameWin->nOldScores, pGameWin->nScoreDiffs, pGameWin->nLevelIDs);
}

int CMyGameTable::GetAutoThrowCardID(int chairno)
{
    int nIndex = m_nLatestedGetMJIndex[chairno];
    if (nIndex < 0)
    {
        return INVALID_OBJECT_ID;
    }
    if (chairno == m_aryCard[nIndex].nChairNO)
    {
        return m_aryCard[nIndex].nID;
    }
    return INVALID_OBJECT_ID;
}

void CMyGameTable::OnAuctionBanker()
{

    if (INVALID_OBJECT_ID != m_nCurrentChair && m_dwActionStart)
    {
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            m_dwCostTime[i] += (GetTickCount() - m_dwActionStart);
        }
    }
    m_nCurrentChair = m_nBanker;
    m_dwActionBegin = GetTickCount();
    m_dwActionStart = GetTickCount();

}

void CMyGameTable::ResetPlayerGiveUpInfo()
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        m_nGiveUpChair[i] = INVALID_OBJECT_ID;
        m_bShowGiveUp[i] = FALSE;
    }
}

BOOL CMyGameTable::OnAuctionDingQue(LPAUCTION_DINGQUE pAuctionDingQue)
{
    int chairno = pAuctionDingQue->nChairNO;
    m_nDingQueCardType[chairno] = pAuctionDingQue->nDingQueCardType[chairno];

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (-1 == m_nDingQueCardType[i])
        {
            return FALSE;
        }
    }

    //定缺后计算庄家能否天胡
    if (CalcHu_Zimo(m_nBanker, GetFirstCardOfChair(m_nBanker)))
    {
        pAuctionDingQue->dPGCH[m_nBanker] = MJ_HU;
    }

    RemoveStatus(TS_WAITING_AUCTION);
    AddStatus(TS_WAITING_THROW);

    return TRUE;
}

//是否含有定缺的牌
//返回值：FALSE：含有定缺的牌或者有错误
//返回值：TRUE： 不含有定缺的牌
BOOL CMyGameTable::CalcHasNoDingQue(int chairno)
{
    if ((m_nDingQueCardType[chairno] < 0) || (m_nDingQueCardType[chairno] >= CARD_TYPE_COUNT))
    {
        return FALSE;
    }

    for (int i = 0; i < LAYOUT_NUM; i++)
    {
        if (m_nCardsLayIn[chairno][i])
        {
            int shape = GetCardShape(i, 0);
            if (shape == m_nDingQueCardType[chairno])
            {
                return FALSE;
            }
        }
    }

    return TRUE;
}

BOOL CMyGameTable::CalcIsDingQue(int chairno, int nCardID)
{
    if ((m_nDingQueCardType[chairno] < 0) || (m_nDingQueCardType[chairno] >= CARD_TYPE_COUNT))
    {
        return FALSE;
    }

    int shape = CalculateCardShape(nCardID);
    if (shape == m_nDingQueCardType[chairno])
    {
        return TRUE;
    }

    return FALSE;
}

BOOL CMyGameTable::ConstructMyPreSaveResult(int roomid, int gameid, LPREFRESH_RESULT_EX lpRefreshResult, GAME_RESULT_EX GameResults[], CPlayerLevelMap& mapPlayerLevel, int chairno, int flag)
{
    int depositDiff[TOTAL_CHAIRS];
    int oldDeposit[TOTAL_CHAIRS];
    ZeroMemory(depositDiff, sizeof(depositDiff));
    ZeroMemory(oldDeposit, sizeof(oldDeposit));
    int i = 0;
    for (i = 0; i < m_nTotalChairs; ++i)
    {
        if (m_ptrPlayers[i] && !m_ptrPlayers[i]->m_bIdlePlayer)
        {
            oldDeposit[i] = m_ptrPlayers[i]->m_nDeposit;
            depositDiff[i] = m_nBaseDeposit * m_HuPoint[i];
        }
    }

    if (flag == ResultByFee)
    {
        ZeroMemory(m_nRoomFees, sizeof(m_nRoomFees));
        if (IsUseCustomFeeMode())
        {
            CalcCustomFees(m_nRoomFees);
        }
        else
        {
            if (FEE_MODE_SERVICE_FIXED == m_nFeeMode
                || FEE_MODE_SERVICE_MINDEPOSIT == m_nFeeMode
                || FEE_MODE_SERVICE_SELFDEPOSIT == m_nFeeMode)
            {
                int nOldDeposits[MAX_CHAIRS_PER_TABLE];                     // 旧银子
                memset(nOldDeposits, 0, sizeof(nOldDeposits));
                //计算茶水费以及去掉茶水费后的原有银两
                CalcWinFeesEx(oldDeposit, nOldDeposits, depositDiff, m_nRoomFees);
            }
            else
            {
                CalcWinFees(depositDiff, m_nRoomFees);
            }
        }

        for (i = 0; i < m_nTotalChairs; ++i)
        {
            if (!m_ptrPlayers[i])
            {
                continue;
            }

            GameResults[i].nRoomID = m_nRoomID;
            GameResults[i].nGameID = gameid;
            GameResults[i].nTableNO = m_nTableNO;
            GameResults[i].nUserID = m_ptrPlayers[i]->m_nUserID;
            GameResults[i].nChairNO = m_ptrPlayers[i]->m_nChairNO;
            GameResults[i].nBaseDeposit = m_nBaseDeposit;
            GameResults[i].nBaseScore = m_nBaseScore;
            GameResults[i].nOldDeposit = oldDeposit[i];
            GameResults[i].nDepositDiff = -m_nRoomFees[i];
            GameResults[i].nFee = m_nRoomFees[i];

            if (m_bNeedDeposit && m_nBaseDeposit) // 玩银子
            {
                m_ptrPlayers[i]->m_nDeposit = GameResults[i].nOldDeposit + GameResults[i].nDepositDiff; // 银子
                m_PlayersBackup[i].nDeposit = GameResults[i].nOldDeposit + GameResults[i].nDepositDiff;
                if (m_ptrPlayers[i]->m_nDeposit < 0)
                {
                    m_ptrPlayers[i]->m_nDeposit = 0;    // 校正
                }
                if (m_PlayersBackup[i].nDeposit < 0)
                {
                    m_PlayersBackup[i].nDeposit = 0;    // 校正
                }

                //初始化
                setInitDeposit(i, m_ptrPlayers[i]->m_nDeposit);
            }
        }

        lpRefreshResult->nResultCount = m_nTotalChairs;
        lpRefreshResult->nRoomID = m_nRoomID;
        lpRefreshResult->nGameID = gameid;
        lpRefreshResult->dwStartTime = m_dwGameStart;
    }
    else
    {
        BOOL isPlayerGiveup = (flag == ResultByGiveUp);
        BOOL isPlayerHu = (flag == ResultByHu && chairno != INVALID_OBJECT_ID);

        //矫正输赢
        CompensateDeposits(oldDeposit, depositDiff);

        //构建GameResults
        int count = 0;
        for (i = 0; i < m_nTotalChairs; ++i)
        {
            if (!m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
            {
                continue;
            }

            //放弃的人提交结果 || 输赢提交
            if ((isPlayerGiveup && i == chairno) || m_HuPoint[i] != 0)
            {
                GameResults[count].nRoomID = m_nRoomID;
                GameResults[count].nGameID = gameid;
                GameResults[count].nTableNO = m_nTableNO;
                GameResults[count].nUserID = m_ptrPlayers[i]->m_nUserID;
                GameResults[count].nChairNO = m_ptrPlayers[i]->m_nChairNO;
                GameResults[count].nBaseDeposit = m_nBaseDeposit;
                GameResults[count].nBaseScore = m_nBaseScore;
                GameResults[count].nOldScore = m_ptrPlayers[i]->m_nScore;
                GameResults[count].nOldDeposit = m_ptrPlayers[i]->m_nDeposit;
                GameResults[count].nScoreDiff = m_nBaseScore * m_HuPoint[i];
                GameResults[count].nDepositDiff = depositDiff[i];

                m_ptrPlayers[i]->m_nScore = GameResults[count].nOldScore + GameResults[count].nScoreDiff; // 积分
                GameResults[count].nLevelID = CalcLevelOnScore(GameResults[count].nOldScore + GameResults[count].nScoreDiff, m_nScoreMult);
                GameResults[count].nLevelID = m_ptrPlayers[i]->m_nLevelID;
                LookupPlayerLevel(mapPlayerLevel, GameResults[count].nLevelID, GameResults[count].szLevelName);

                if (chairno == i)  //放弃和胡（chairno != -1）
                {
                    if (isPlayerGiveup)
                    {
                        CalcTimeCost(GameResults[count].nTimeCost, GameResults[count].nExperience);
                        GameResults[count].nBout = 1;
                        GameResults[count].nLoss = 1;
                    }
                    else if (isPlayerHu)
                    {
                        if (!IsXueLiuRoom()) //XL 血战游戏结束
                        {
                            CalcTimeCost(GameResults[count].nTimeCost, GameResults[count].nExperience);
                            GameResults[count].nBout = 1;

                            int nPreSaveAllDeposit = m_stPreSaveInfo[i].nPreSaveAllDeposit + GameResults[count].nDepositDiff;
                            if (nPreSaveAllDeposit > 0)  //这里根据总输赢计算
                            {
                                GameResults[count].nWin = 1;
                            }
                            else if (nPreSaveAllDeposit == 0)
                            {
                                GameResults[count].nStandOff = 1;
                            }
                            else
                            {
                                GameResults[count].nLoss = 1;
                            }
                        }
                    }
                }

                if (m_bNeedDeposit && m_nBaseDeposit) // 玩银子
                {
                    m_ptrPlayers[i]->m_nDeposit = GameResults[count].nOldDeposit + GameResults[count].nDepositDiff; // 银子
                    m_PlayersBackup[i].nDeposit = GameResults[count].nOldDeposit + GameResults[count].nDepositDiff;
                    if (m_ptrPlayers[i]->m_nDeposit < 0)
                    {
                        m_ptrPlayers[i]->m_nDeposit = 0;    // 校正
                    }
                    if (m_PlayersBackup[i].nDeposit < 0)
                    {
                        m_PlayersBackup[i].nDeposit = 0;    // 校正
                    }
                }

                m_stPreSaveInfo[i].nPreSaveDeposit = GameResults[count].nDepositDiff;
                m_stPreSaveInfo[i].nPreSaveAllDeposit += GameResults[count].nDepositDiff;
                m_stPreSaveInfo[i].nPreSaveAllFan += m_HuPoint[i];
                RefreshOnePlayerData(&GameResults[count]);
                count++;
                m_HuPoint[i] = 0;
            }
        }

        if (!isPlayerGiveup)
        {
            if (!isPlayerHu)
            {
                //算出累计的杠的diff
                for (i = 0; i < m_nTotalChairs; ++i)
                {
                    if (depositDiff[i] > 0)
                    {
                        UpdateGangItemDeposit(i, depositDiff);
                    }
                }

                m_bNeedUpdate = FALSE;
            }
            else
            {
                //算出每次胡的diff
                for (i = 0; i < m_nTotalChairs; ++i)
                {
                    if (depositDiff[i] > 0)
                    {
                        UpdateHuItemDeposit(i, depositDiff, m_stHuMultiInfo.nHuCount);
                    }
                }

                m_bNeedUpdate = FALSE;
            }
        }

        lpRefreshResult->nResultCount = count;
        lpRefreshResult->nRoomID = m_nRoomID;
        lpRefreshResult->nGameID = gameid;
        lpRefreshResult->dwStartTime = m_dwGameStart;
    }

    return TRUE;
}

void CMyGameTable::UpdateHuItemDeposit(int chairno, int depositDiff[], int huCount)
{
    try
    {
        if (m_bNeedUpdate == FALSE)
        {
            return;
        }
        if (!ValidateChair(chairno))
        {
            return;
        }

        int nHuCount = m_vecHuItems[chairno].size();
        if (nHuCount <= 0)
        {
            return;
        }

        HU_ITEM_INFO& stHuItem = m_vecHuItems[chairno].at(nHuCount - 1);
        if (stHuItem.nHuFan <= 0)
        {
            return;
        }

        //更新胡的玩家
        stHuItem.nHuDeposits = depositDiff[chairno];

        //更新被胡的玩家
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (stHuItem.nRelateChair[i] != INVALID_OBJECT_ID)
            {
                int nHuCount = m_vecHuItems[i].size();
                if (nHuCount <= 0)
                {
                    return;
                }

                if (huCount > 1)
                {
                    for (int j = 0; j < huCount; j++)
                    {
                        HU_ITEM_INFO& stLossItem = m_vecHuItems[i].at(nHuCount - 1 - j);
                        if (stLossItem.nHuFan >= 0)
                        {
                            continue;
                        }

                        for (int k = 0; k < m_nTotalChairs; k++)
                        {
                            if (stLossItem.nRelateChair[k] == chairno)
                            {
                                stLossItem.nHuDeposits = -depositDiff[chairno]; //一炮多响输的钱分开给赢的人
                                break;
                            }
                        }
                    }
                }
                else
                {
                    HU_ITEM_INFO& stLossItem = m_vecHuItems[i].at(nHuCount - 1);
                    if (stLossItem.nHuFan >= 0)
                    {
                        return;
                    }
                    stLossItem.nHuDeposits = depositDiff[i];
                }
            }
        }
    }
    catch (...)
    {
        UwlLogFile(_T("UpdateHuItemDeposit Exception"));
    }
}

void CMyGameTable::UpdateGangItemDeposit(int chairno, int depositDiff[])
{
    try
    {
        if (m_bNeedUpdate == FALSE)
        {
            return;
        }

        int nHuCount = m_vecHuItems[chairno].size();
        if (nHuCount <= 0)
        {
            return;
        }

        HU_ITEM_INFO& stHuItem = m_vecHuItems[chairno].at(nHuCount - 1);
        if (stHuItem.nHuFan <= 0)
        {
            return;
        }

        //更新胡的玩家
        stHuItem.nHuDeposits = depositDiff[chairno];

        //更新被胡的玩家
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (stHuItem.nRelateChair[i] != INVALID_OBJECT_ID)
            {
                int nHuCount = m_vecHuItems[i].size();
                if (nHuCount <= 0)
                {
                    return;
                }

                HU_ITEM_INFO& stLossItem = m_vecHuItems[i].at(nHuCount - 1);
                if (stLossItem.nHuFan >= 0)
                {
                    return;
                }

                stLossItem.nHuDeposits = depositDiff[i];
            }
        }
    }
    catch (...)
    {
        UwlLogFile(_T("UpdatehGangItemDeposit Exception"));
    }
}

void CMyGameTable::setInitDeposit(int chairno, int deposit)
{
    m_nInitDeposit[chairno] = deposit;
}

void CMyGameTable::resetDepositWinLimit()
{
    ZeroMemory(m_nDepositWinLimit, sizeof(m_nDepositWinLimit));
}

void CMyGameTable::CalcCustomFees(int fees[])
{
    int fee = ceil((double)m_feeRatioToBaseDeposit / 1000.0 * m_nBaseDeposit);
    for (int i = 0; i < m_nTotalChairs; ++i)
    {
        fees[i] = fee;
    }
}

BOOL CMyGameTable::PresaveResultCallTransferDeposit(GAME_RESULT_EX GameResults[], int CallTransferDepositResults[])
{
    int nOldDeposits[TOTAL_CHAIRS];
    ZeroMemory(nOldDeposits, sizeof(nOldDeposits));
    int nHuDepositDiffs[TOTAL_CHAIRS];
    ZeroMemory(nHuDepositDiffs, sizeof(nHuDepositDiffs));

    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (GameResults[i].nUserID != 0)
        {
            nOldDeposits[GameResults[i].nChairNO] = GameResults[i].nOldDeposit + GameResults[i].nDepositDiff;
            nHuDepositDiffs[GameResults[i].nChairNO] = GameResults[i].nDepositDiff;
        }
    }
    return GameWinCallTransferDeposit(nOldDeposits, nHuDepositDiffs, CallTransferDepositResults, TRUE);
}


BOOL CMyGameTable::GameWinCallTransferDeposit(int nOldDeposits[], int nHuDepositDiffs[], int nDepositDiffs[], BOOL bPreSave)
{
    if (!m_bNewRuleOpen)
    {
        return FALSE;
    }

    int nTransferCount = 0;
    int beTransferChairNo = INVALID_OBJECT_ID;          //被呼叫转移chairno
    int nTransferDeposit = 0;
    BOOL nNeedTransfer[MAX_CHAIR_COUNT];
    memset(&nNeedTransfer, 0, sizeof(nNeedTransfer));

    int i = 0;
    int j = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (NULL == m_ptrPlayers[i])
        {
            continue;
        }
        if (nHuDepositDiffs[i] > 0)
        {
            nNeedTransfer[i] = TRUE;
            nTransferCount++;
        }
        else if (nHuDepositDiffs[i] < 0)
        {
            beTransferChairNo = i;
        }
    }
    if (INVALID_OBJECT_ID == beTransferChairNo || nOldDeposits[beTransferChairNo] <= 0)
    {
        return FALSE;
    }

    //查找杠牌的银子数
    std::vector<HU_ITEM_INFO> vecHuItems = m_vecHuItems[beTransferChairNo];
    std::vector<HU_ITEM_INFO>::reverse_iterator reIter = vecHuItems.rbegin();
    for (reIter; reIter != vecHuItems.rend(); ++reIter)
    {
        HU_ITEM_INFO itemInfo = *reIter;
        if (IS_BIT_SET(itemInfo.nHuFlag, MJ_HU_MNGANG) || IS_BIT_SET(itemInfo.nHuFlag, MJ_HU_PNGANG) || IS_BIT_SET(itemInfo.nHuFlag, MJ_HU_ANGANG))
        {
            nTransferDeposit = itemInfo.nHuDeposits;
            break;
        }
    }

    if (nOldDeposits[beTransferChairNo] < nTransferDeposit)
    {
        nTransferDeposit = nOldDeposits[beTransferChairNo];
    }
    nDepositDiffs[beTransferChairNo] = nTransferDeposit * (-1);
    if (!bPreSave)
    {
        if (nTransferDeposit > 0)
        {
            m_nEndGameFlag |= MJ_HU_CALLTRANSFER;
        }

        m_stEndGameCheckInfo.nTransferDeposit[beTransferChairNo] = nDepositDiffs[beTransferChairNo];
        m_stEndGameCheckInfo.nTransferPoint[beTransferChairNo] = -1;
    }
    else
    {
        m_stPreSaveInfo[beTransferChairNo].nPreSaveAllDeposit += nDepositDiffs[beTransferChairNo];
    }
    //分钱
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (beTransferChairNo == i)
        {
            continue;
        }

        if (nNeedTransfer[i])
        {
            //优化---------------------------------
            nDepositDiffs[i] = floor(nTransferDeposit / nTransferCount);
            //增加呼叫转移玩家记录
            HU_ITEM_INFO stHuItem;
            ZeroMemory(&stHuItem, sizeof(stHuItem));
            stHuItem.bWin = TRUE;
            stHuItem.nHuFlag = MJ_HU_CALLTRANSFER;
            stHuItem.nHuID = INVALID_OBJECT_ID;
            stHuItem.nHuFan = 0;
            stHuItem.nHuDeposits = nDepositDiffs[i];    // 校正后更新
            for (j = 0; j < m_nTotalChairs; j++)
            {
                if (beTransferChairNo == j)
                {
                    stHuItem.nRelateChair[j] = j;
                }
                else
                {
                    stHuItem.nRelateChair[j] = INVALID_OBJECT_ID;
                }
            }
            m_vecHuItems[i].push_back(stHuItem);

            //增加被呼叫转移玩家记录
            HU_ITEM_INFO stLossItem;
            ZeroMemory(&stLossItem, sizeof(stLossItem));
            stLossItem.bWin = FALSE;
            stLossItem.nHuFlag = MJ_HU_CALLTRANSFER;
            stLossItem.nHuID = INVALID_OBJECT_ID;
            stLossItem.nHuFan = 0;
            stLossItem.nHuDeposits = stHuItem.nHuDeposits * (-1);
            for (j = 0; j < m_nTotalChairs; j++)
            {
                if (j == i)
                {
                    stLossItem.nRelateChair[j] = j;
                }
                else
                {
                    stLossItem.nRelateChair[j] = INVALID_OBJECT_ID;
                }
            }

            m_vecHuItems[beTransferChairNo].push_back(stLossItem);

            if (!bPreSave)
            {
                m_stEndGameCheckInfo.nTransferDeposit[i] = nDepositDiffs[i];
                m_stEndGameCheckInfo.nTransferPoint[i] = 1;
            }
            else
            {
                m_stPreSaveInfo[i].nPreSaveAllDeposit += nDepositDiffs[i];
            }
        }
    }
    return TRUE;
}

void CMyGameTable::updateDepositAfterTransfer(int CallTransferDepositResults[])
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (CallTransferDepositResults[i] != 0 && NULL != m_ptrPlayers[i])
        {
            m_ptrPlayers[i]->m_nDeposit = m_ptrPlayers[i]->m_nDeposit + CallTransferDepositResults[i]; // 银子
            m_PlayersBackup[i].nDeposit = m_ptrPlayers[i]->m_nDeposit;
            if (m_ptrPlayers[i]->m_nDeposit < 0)
            {
                m_ptrPlayers[i]->m_nDeposit = 0;    // 校正
            }
            if (m_PlayersBackup[i].nDeposit < 0)
            {
                m_PlayersBackup[i].nDeposit = 0;    // 校正
            }

            //初始化
            //setInitDeposit(i, m_ptrPlayers[i]->m_nDeposit);
        }
    }
}

int CMyGameTable::GetTotalPengCount(int chairno)
{
    return m_PengCards[chairno].GetSize();
}

int CMyGameTable::GetTotalGangCount(int chairno)
{
    return (m_AnGangCards[chairno].GetSize() + m_MnGangCards[chairno].GetSize() + m_PnGangCards[chairno].GetSize());
}

BOOL CMyGameTable::ValidateMultiHu(LPHU_CARD pHuCard)
{
    if (m_stHuMultiInfo.nHuCount > 1)
    {
        if (m_stHuMultiInfo.nHuCard == pHuCard->nCardID && m_stHuMultiInfo.nHuChair[pHuCard->nChairNO] != -1)
        {
            return FALSE;
        }
    }

    return TRUE;
}

BOOL CMyGameTable::ShouldHuCardWait(LPHU_CARD pHuCard)
{
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;
    int cardid = pHuCard->nCardID;
    m_dwPGCHFlags[chairno] = 0;

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return FALSE;
    }
    if (IS_BIT_SET(pHuCard->dwFlags, MJ_HU_ZIMO)) //自摸不需要等待
    {
        return FALSE;
    }
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_ONE_THROW_MULTIHU))//不支持一炮多响直接胡
    {
        return FALSE;
    }

    for (int chair = 0; chair < m_nTotalChairs; chair++)
    {
        m_dwPGCHFlags[chair] &= ~MJ_CHI;
        m_dwPGCHFlags[chair] &= ~MJ_PENG;
        m_dwPGCHFlags[chair] &= ~MJ_GANG;
    }

    BOOL bHighOpe = 0;
    BOOL bWait = 0;
    BOOL bSomeoneHu = FALSE;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            LOG_DEBUG("ShouldHuCardWait11111111111111111");
            bWait = 1;
        }
    }

    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        LOG_DEBUG("ShouldHuCardWait22222222222222222");
        bHighOpe = 1;
        bSomeoneHu = TRUE;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        LOG_DEBUG("ShouldHuCardWait3333333333333333");
        m_dwWaitOpeFlag = MJ_HU;
        m_nWaitOpeMsgID = GR_RECONS_FANGPAO;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pHuCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        LOG_DEBUG("ShouldHuCardWait4444444444444444444");
        return 1;
    }

    if (bSomeoneHu)
    {
        if (GetTickCount() - m_dwLatestThrow < (m_nPGCHWait - 1) * 1000)
        {
            //胡了就重置吧
            if (IsXueLiuRoom())
            {
                memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));
            }

            return TRUE;
        }
    }

    return FALSE;
}

void CMyGameTable::ResetMultiHuInfo()
{
    m_stHuMultiInfo.nHuFlag = 0;
    m_stHuMultiInfo.nHuCard = -1;
    m_stHuMultiInfo.nHuCount = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        m_stHuMultiInfo.nHuChair[i] = -1;
        m_stHuMultiInfo.nLossChair[i] = -1;
    }
}

BOOL CMyGameTable::OverTimeMultiHu(int cardchair)
{
    int huCount = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair)
        {
            continue;
        }
        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU) && (m_HuReady[i] && m_HuReady[i] != MJ_GIVE_UP))
        {
            huCount++;
        }
    }

    if (huCount > 1)
    {
        if (GetTickCount() - m_dwLatestThrow < (m_nPGCHWait - 1) * 1000)
        {
        }
        else
        {
            return TRUE;
        }
    }

    return FALSE;
}

void CMyGameTable::OnHuAfterWait(LPHU_CARD pHuCard, int nCount)
{
    int hu_count = 0;
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;
    int cardid = pHuCard->nCardID;
    DWORD flags = pHuCard->dwFlags;

    if (nCount > 0)
    {
        if (!IS_BIT_SET(flags, MJ_HU_ZIMO))
        {
            if (m_nHuCount >= hu_count)
            {
                ReSetThrowStatus(cardchair, chairno);

                //断线续玩的玩家显示有问题
                int idx = FindCardID(m_nOutCards[cardchair], cardid);
                if (idx >= 0)
                {
                    m_nOutCards[cardchair].RemoveAt(idx);
                }
            }
        }
    }

    if (IsXueLiuRoom())
    {
        memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));
    }

    return;
}

void CMyGameTable::ReSetThrowStatus(int first, int last)
{
    if (first == -1 || last == -1)
    {
        return;
    }

    if ((first >= TOTAL_CHAIRS) || (last >= TOTAL_CHAIRS))
    {
        return;
    }

    int chairno = GetNextChair(first);
    while (chairno != last && chairno != -1)
    {
        //摸牌的时候刷新跟牌记录
        memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));
        chairno = CTable::GetNextChair(chairno);
    }
}

void CMyGameTable::CalcHuPoints(int chairno, int cardchair, int cardid)
{
    int nLoseNum = 0;
    if (m_HuReady[chairno] == MJ_HU_ZIMO || m_HuReady[chairno] == MJ_HU_HDLY)
    {
        int score = pow(2, m_nResults[chairno] - 1);
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (i == chairno)
            {
                continue;
            }
            if (IsHuReady(i))
            {
                continue;
            }
            if (NULL == m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
            {
                continue;
            }

            nLoseNum++;
            m_HuPoint[i] -= score;
            m_HuPoint[chairno] += score;
        }
    }
    else
    {
        nLoseNum = 1;
        int score = pow(2, m_nResults[chairno] - 1);
        m_HuPoint[cardchair] -= score;
        m_HuPoint[chairno] += score;
    }

    AddNewHuItem(chairno, cardchair, cardid, nLoseNum);
}

BOOL CMyGameTable::IsHuReady(int chairno)
{
    BOOL bHuReady = FALSE;

    if (IsXueLiuRoom())
    {
        if (m_HuReady[chairno] == MJ_GIVE_UP)
        {
            bHuReady = TRUE;
        }
    }
    else
    {
        if (m_HuReady[chairno])
        {
            bHuReady = TRUE;
        }
    }

    return bHuReady;
}

void CMyGameTable::AddNewHuItem(int chairno, int cardchair, int cardid, int losenum)
{
    if (!ValidateChair(chairno))
    {
        return;
    }

    m_bNeedUpdate = TRUE;

    //当前胡信息
    m_stHuMultiInfo.nHuCount++;
    m_stHuMultiInfo.nHuCard = cardid;
    m_stHuMultiInfo.nHuFlag = m_HuReady[chairno];
    m_stHuMultiInfo.nHuChair[chairno] = chairno;

    //填充胡玩家的item
    HU_ITEM_INFO stHuItem;
    ZeroMemory(&stHuItem, sizeof(stHuItem));
    stHuItem.bWin = TRUE;
    stHuItem.nHuFlag = m_HuReady[chairno];
    stHuItem.nHuID = cardid;
    stHuItem.nHuFan = pow(2, m_nResults[chairno] - 1)/**losenum*/;
    //stHuItem.nHuDeposits 留待结算后填充
    memcpy(stHuItem.nHuGains, m_huDetails[chairno].nHuGains, sizeof(stHuItem.nHuGains));

    if (m_HuReady[chairno] == MJ_HU_ZIMO || m_HuReady[chairno] == MJ_HU_HDLY)
    {
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuPoint[j] < 0)
            {
                stHuItem.nRelateChair[j] = j;
                m_stHuMultiInfo.nLossChair[j] = j;
            }
            else
            {
                stHuItem.nRelateChair[j] = INVALID_OBJECT_ID;
            }
        }
    }
    else
    {
        m_stHuMultiInfo.nLossChair[cardchair] = cardchair;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (j == cardchair)
            {
                stHuItem.nRelateChair[j] = j;
            }
            else
            {
                stHuItem.nRelateChair[j] = INVALID_OBJECT_ID;
            }
        }
    }

    m_vecHuItems[chairno].push_back(stHuItem);

    //填充被胡玩家的item
    if (m_HuReady[chairno] == MJ_HU_ZIMO || m_HuReady[chairno] == MJ_HU_HDLY)
    {
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (stHuItem.nRelateChair[i] != -1)
            {
                HU_ITEM_INFO stLossItem;
                ZeroMemory(&stLossItem, sizeof(stLossItem));
                stHuItem.bWin = FALSE;
                stLossItem.nHuFlag = m_HuReady[chairno];
                stLossItem.nHuID = cardid;
                stLossItem.nHuFan = -pow(2, m_nResults[chairno] - 1);
                memcpy(stLossItem.nHuGains, m_huDetails[chairno].nHuGains, sizeof(stLossItem.nHuGains));

                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (j == chairno)
                    {
                        stLossItem.nRelateChair[j] = j;
                    }
                    else
                    {
                        stLossItem.nRelateChair[j] = INVALID_OBJECT_ID;
                    }
                }

                m_vecHuItems[i].push_back(stLossItem);
            }
        }
    }
    else
    {
        if (!ValidateChair(cardchair))
        {
            return;
        }

        HU_ITEM_INFO stLossItem;
        ZeroMemory(&stLossItem, sizeof(stLossItem));
        stHuItem.bWin = FALSE;
        stLossItem.nHuFlag = m_HuReady[chairno];
        stLossItem.nHuID = cardid;
        stLossItem.nHuFan = -pow(2, m_nResults[chairno] - 1);
        memcpy(stLossItem.nHuGains, m_huDetails[chairno].nHuGains, sizeof(stLossItem.nHuGains));

        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (j == chairno)
            {
                stLossItem.nRelateChair[j] = j;
            }
            else
            {
                stLossItem.nRelateChair[j] = INVALID_OBJECT_ID;
            }
        }

        m_vecHuItems[cardchair].push_back(stLossItem);
    }
}

int CMyGameTable::GetNextChair(int chairno)
{
    //XL 血流有人放弃后提前退出
    if (IsXueLiuRoom())
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j] == MJ_GIVE_UP)
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            return -1;
        }

        int i = (chairno + m_nTotalChairs - 1) % m_nTotalChairs;

        int nWhileCount = 0;
        while (m_HuReady[i] == MJ_GIVE_UP && (nWhileCount <= m_nTotalChairs))
        {
            i = (i + m_nTotalChairs - 1) % m_nTotalChairs;
            nWhileCount++;
        }
        if (nWhileCount == m_nTotalChairs)
        {
            UwlLogFile(" Exception CGameTable::GetNextChair 四家胡!");
        }

        return i;
    }
    else
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j])
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            return -1;
        }

        int i = (chairno + m_nTotalChairs - 1) % m_nTotalChairs;

        int nWhileCount = 0;
        while (m_HuReady[i] && (nWhileCount <= m_nTotalChairs))
        {
            i = (i + m_nTotalChairs - 1) % m_nTotalChairs;
            nWhileCount++;
        }
        if (nWhileCount == m_nTotalChairs)
        {
            UwlLogFile(" Exception CGameTable::GetNextChair 四家胡!");
        }

        return i;
    }
}

int CMyGameTable::GetPrevChair(int chairno)
{
    //XL 血流有人放弃后提前退出
    if (IsXueLiuRoom())
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j] == MJ_GIVE_UP)
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            return -1;
        }

        int i = (chairno + 1) % m_nTotalChairs;

        int nWhileCount = 0;
        while (m_HuReady[i] == MJ_GIVE_UP && (nWhileCount <= m_nTotalChairs))
        {
            i = (i + 1) % m_nTotalChairs;
            nWhileCount++;
        }
        if (nWhileCount == m_nTotalChairs)
        {
            UwlLogFile(" Exception CGameTable::GetPrevChair 四家胡!");
        }

        return i;
    }
    else
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j])
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            return -1;
        }

        int i = (chairno + 1) % m_nTotalChairs;

        int nWhileCount = 0;
        while (m_HuReady[i] && (nWhileCount <= m_nTotalChairs))
        {
            i = (i + 1) % m_nTotalChairs;
            nWhileCount++;
        }
        if (nWhileCount == m_nTotalChairs)
        {
            UwlLogFile(" Exception CGameTable::GetPrevChair 四家胡!");
        }

        return i;
    }
}

int CMyGameTable::CalcTing(int chairno, HU_DETAILS& hu_detials_out)
{
    DWORD dwTickCount = GetTickCount();

    HU_DETAILS huDetails;
    int gains = 0;
    int card[27] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 36, 37, 38, 39, 40, 41, 42, 43, 44, 72, 73, 74, 75, 76, 77, 78, 79, 80 };

    for (int i = 0; i < 27; i++)
    {
        if (m_nDingQueCardType[chairno] == m_pCalclator->MJ_CalculateCardShape(card[i], 0))
        {
            continue;
        }

        memset(&huDetails, 0, sizeof(HU_DETAILS));
        int temp_gains = CalcHu_Most(chairno, card[i], huDetails, MJ_HU_FANG);
        if (temp_gains > gains)
        {
            gains = temp_gains;
            memcpy(&hu_detials_out, &huDetails, sizeof(HU_DETAILS));
        }
    }

    gains = pow(2, gains - 1);

    return gains;
}

int CMyGameTable::CalcTing2(int chairno, HU_DETAILS& hu_detials_out, int nMaxBei)
{
    DWORD dwTickCount = GetTickCount();

    HU_DETAILS huDetails;
    int gains = 0;
    int card[27] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 36, 37, 38, 39, 40, 41, 42, 43, 44, 72, 73, 74, 75, 76, 77, 78, 79, 80 };

    for (int i = 0; i < 27; i++)
    {
        if (m_nDingQueCardType[chairno] == m_pCalclator->MJ_CalculateCardShape(card[i], 0))
        {
            continue;
        }

        memset(&huDetails, 0, sizeof(HU_DETAILS));
        int temp_gains = CalcHu_Most(chairno, card[i], huDetails, MJ_HU_FANG);
        if (temp_gains > 0)
        {
            gains = 1; //听牌
            temp_gains = pow(2, temp_gains - 1);
            if (temp_gains >= nMaxBei)
            {
                gains = temp_gains; //听牌且达到倍数
                memcpy(&hu_detials_out, &huDetails, sizeof(HU_DETAILS));
                break;
            }
        }
    }

    return gains;
}

int CMyGameTable::CalcTingEx(int chairno, HU_DETAILS& hu_detials_out, vector<int>* v, DWORD dwExtraFlag)
{
    HU_DETAILS huDetails;
    int gains = 0;
    int card[27] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 36, 37, 38, 39, 40, 41, 42, 43, 44, 72, 73, 74, 75, 76, 77, 78, 79, 80 };

    for (int i = 0; i < 27; i++)
    {
        if (m_nDingQueCardType[chairno] == m_pCalclator->MJ_CalculateCardShape(card[i], 0))
        {
            continue;
        }

        memset(&huDetails, 0, sizeof(HU_DETAILS));
        int temp_gains = CalcHu_Most(chairno, card[i], huDetails, MJ_HU_FANG | MJ_HU_TING | dwExtraFlag, TRUE);
        if (temp_gains > gains)
        {
            gains = temp_gains;
            memcpy(&hu_detials_out, &huDetails, sizeof(HU_DETAILS));
        }
        if (temp_gains > 0 && v != NULL)
        {
            v->push_back(card[i]);
        }
    }

    gains = (int)(pow(2, gains - 1) + 0.1);
    return gains;
}

int CMyGameTable::ValidateCatch(int chairno)
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }

    //血流胡一次后遇胡必胡
    if (IsXueLiuRoom())
    {
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (chairno == i)
            {
                continue;
            }

            if (m_HuReady[i] && m_HuReady[i] != MJ_GIVE_UP)
            {
                if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
                {
                    //UwlLogFile("血流胡一次后遇胡必胡");
                    return 0;
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (chairno == i)
            {
                continue;
            }

            if (m_HuReady[i] && m_HuReady[i] != MJ_GIVE_UP)
            {
                if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
                {
                    //UwlLogFile("血战点过胡后必胡");
                    return 0;
                }
            }
        }
    }

    return __super::ValidateCatch(chairno);
}

BOOL CMyGameTable::IsHuaZhu(int chairno)
{
    return !CalcHasNoDingQue(chairno);
}

DWORD CMyGameTable::Hu_Tian(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int num = 0;
    BOOL bSomeOneHu = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_HuReady[i]) //胡了再胡
        {
            bSomeOneHu = TRUE;
            break;
        }
        num += m_PengCards[i].GetSize()
            + m_ChiCards[i].GetSize()
            + m_PnGangCards[i].GetSize()
            + m_nOutCards[i].GetSize()
            + m_MnGangCards[i].GetSize()
            + m_AnGangCards[i].GetSize();
    }
    if (bSomeOneHu)
    {
        return 0;
    }

    if (num == 0 && chairno == m_nBanker && m_nHuaCards[chairno].GetSize() == 0)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_TIAN;
        return MJ_HU_TIAN;
    }
    return 0;
}

int CMyGameTable::CalcGangUnitNum(HU_DETAILS& hu_details)
{
    int num = 0;
    for (int i = 0; (i < hu_details.nUnitsCount) && (i < MJ_MAX_UNITS); i++)
    {
        if (hu_details.HuUnits[i].dwType == MJ_CT_GANG)
        {
            num++;
        }
    }

    return num;
}

DWORD CMyGameTable::HU_258JIANG(int chairno, int nCardID, HU_DETAILS& huDetails_RUN, DWORD dwFlags)
{
    HU_DETAILS huDetails;
    memcpy(&huDetails, &huDetails_RUN, sizeof(HU_DETAILS));
    GetAllHuUnite(chairno, huDetails, MJ_CHI | MJ_GANG | MJ_PENG);

    for (int i = 0; (i < huDetails.nUnitsCount) && (i < MJ_MAX_UNITS); i++)
    {
        if (huDetails.HuUnits[i].dwType == MJ_CT_SHUN)
        {
            return 0;
        }

        if (huDetails.HuUnits[i].aryIndexes[0] > 30)
        {
            return 0;
        }
        int shape = huDetails.HuUnits[i].aryIndexes[0] % 10;
        if (shape != 2 && shape != 5 && shape != 8)
        {
            return 0;
        }
    }
    return MJ_HU;
}

void CMyGameTable::GetAllHuUnite(int chairno, HU_DETAILS& huDetails, DWORD type /*= MJ_GANG | MJ_PENG | MJ_CHI*/)
{
    DWORD status = 0;
    if (IS_BIT_SET(type, MJ_GANG))
    {
        int i = 0;
        for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
        {
            huDetails.HuUnits[huDetails.nUnitsCount].dwType = MJ_CT_KEZI;
            for (int j = 0; j < 3; j++)
            {
                int index = m_pCalclator->MJ_CalcIndexByID(m_AnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                huDetails.HuUnits[huDetails.nUnitsCount].aryIndexes[j] = index;
            }
            huDetails.nUnitsCount++;
        }

        for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
        {
            huDetails.HuUnits[huDetails.nUnitsCount].dwType = MJ_CT_KEZI;
            for (int j = 0; j < 3; j++)
            {
                int index = m_pCalclator->MJ_CalcIndexByID(m_MnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                huDetails.HuUnits[huDetails.nUnitsCount].aryIndexes[j] = index;
            }
            huDetails.nUnitsCount++;
        }

        for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
        {
            huDetails.HuUnits[huDetails.nUnitsCount].dwType = MJ_CT_KEZI;
            for (int j = 0; j < 3; j++)
            {
                int index = m_pCalclator->MJ_CalcIndexByID(m_PnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                huDetails.HuUnits[huDetails.nUnitsCount].aryIndexes[j] = index;
            }
            huDetails.nUnitsCount++;
        }
    }

    if (IS_BIT_SET(type, MJ_PENG))
    {
        for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
        {
            status = GetStatusOfCard(m_PengCards[chairno][i].nCardIDs[0]);
            if (status != MJ_STAT_PENG_OUT && status != MJ_STAT_PENG_IN)
            {
                continue;    //已升级为碰杠
            }

            huDetails.HuUnits[huDetails.nUnitsCount].dwType = MJ_CT_KEZI;
            for (int j = 0; j < 3; j++)
            {
                int index = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                huDetails.HuUnits[huDetails.nUnitsCount].aryIndexes[j] = index;
            }
            huDetails.nUnitsCount++;
        }
    }
}

void CMyGameTable::GetAllCardHad(int chairno, int cards[], DWORD type /*= MJ_GANG | MJ_PENG | MJ_CHI*/)
{
    //数组长度必须为MAX_CARDS_LAYOUT_NUM

    memcpy(cards, m_nCardsLayIn[chairno], sizeof(m_nCardsLayIn[chairno]));

    int cardidx;
    DWORD status = 0;
    if (IS_BIT_SET(type, MJ_PENG))
    {
        for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
        {
            for (int j = 0; j < 3; j++)
            {
                status = GetStatusOfCard(m_PengCards[chairno][i].nCardIDs[j]);
                if (status != MJ_STAT_PENG_OUT && status != MJ_STAT_PENG_IN)
                {
                    break;    //已升级为碰杠
                }
                cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                if (cardidx > 0)
                {
                    cards[cardidx]++;
                }
            }
        }
    }

    if (IS_BIT_SET(type, MJ_GANG))
    {
        int i = 0;
        for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
        {
            for (int j = 0; j < 4; j++)
            {
                cardidx = m_pCalclator->MJ_CalcIndexByID(m_MnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                if (cardidx > 0)
                {
                    cards[cardidx]++;
                }
            }
        }
        for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
        {
            for (int j = 0; j < 4; j++)
            {
                cardidx = m_pCalclator->MJ_CalcIndexByID(m_AnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                if (cardidx > 0)
                {
                    cards[cardidx]++;
                }
            }
        }
        for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
        {
            for (int j = 0; j < 4; j++)
            {
                cardidx = m_pCalclator->MJ_CalcIndexByID(m_PnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                if (cardidx > 0)
                {
                    cards[cardidx]++;
                }
            }
        }
    }

    if (IS_BIT_SET(type, MJ_CHI))
    {
        for (int i = 0; i < m_ChiCards[chairno].GetSize(); i++)
            for (int j = 0; j < 3; j++)
            {
                cardidx = m_pCalclator->MJ_CalcIndexByID(m_ChiCards[chairno][i].nCardIDs[j], m_dwGameFlags);
                if (cardidx > 0)
                {
                    cards[cardidx]++;
                }
            }
    }
}

DWORD CMyGameTable::HU_19(int chairno, int nCardID, HU_DETAILS& huDetails_RUN, DWORD dwFlags)
{
    HU_DETAILS huDetails;
    memcpy(&huDetails, &huDetails_RUN, sizeof(HU_DETAILS));
    GetAllHuUnite(chairno, huDetails, MJ_CHI | MJ_GANG | MJ_PENG);

    for (int i = 0; (i < huDetails.nUnitsCount) && (i < MJ_MAX_UNITS); i++)
    {
        if (huDetails.HuUnits[i].dwType == MJ_CT_SHUN)
        {
            if (huDetails.HuUnits[0].aryIndexes[0] > 30)
            {
                return 0;
            }
            if (huDetails.HuUnits[i].aryIndexes[0] % 10 != 9 && huDetails.HuUnits[i].aryIndexes[0] % 10 != 1)
                if (huDetails.HuUnits[i].aryIndexes[1] % 10 != 9 && huDetails.HuUnits[i].aryIndexes[1] % 10 != 1)
                    if (huDetails.HuUnits[i].aryIndexes[2] % 10 != 9 && huDetails.HuUnits[i].aryIndexes[2] % 10 != 1)
                    {
                        return 0;
                    }
        }
        else if (huDetails.HuUnits[i].dwType == MJ_CT_DUIZI)
        {
            if (huDetails.HuUnits[i].aryIndexes[0] % 10 != 9 && huDetails.HuUnits[i].aryIndexes[0] % 10 != 1)
            {
                return 0;
            }
        }
        else if (huDetails.HuUnits[i].dwType == MJ_CT_KEZI)
        {
            if (huDetails.HuUnits[i].aryIndexes[0] % 10 != 9 && huDetails.HuUnits[i].aryIndexes[0] % 10 != 1)
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }

    return MJ_HU;
}

DWORD CMyGameTable::Hu_GPao(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (m_bLastGang && IS_BIT_SET(dwFlags, MJ_HU_FANG))
    {
        return MJ_HU;
    }
    else
    {
        return 0;
    }
}

DWORD CMyGameTable::HU_ShouBaYi(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int count = m_PengCards[chairno].GetSize()
        + m_MnGangCards[chairno].GetSize()
        + m_AnGangCards[chairno].GetSize();

    if (count >= 4)
    {
        return MJ_HU;
    }
    return 0;
}

DWORD CMyGameTable::HU_Gen(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    GetAllCardHad(chairno, lay, MJ_CHI | MJ_PENG);
    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        lay[m_pCalclator->MJ_CalcIndexByID(nCardID, 0)]++;
    }

    int num = 0;
    for (int i = 0; i < LAYOUT_NUM; i++)
        if (lay[i] >= 4)
        {
            num++;
        }

    return num;
}

int CMyGameTable::CalcGangByPgl(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    return m_MnGangCards[chairno].GetSize() + m_AnGangCards[chairno].GetSize() + m_PnGangCards[chairno].GetSize();
}

BOOL CMyGameTable::ValidatePeng(LPPENG_CARD pPengCard)
{
    //add 20310905 begin
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_HuMJID[i] == pPengCard->nCardID)//打算碰的这张牌已经是别人的胡张
        {
            return FALSE;
        }
    }
    //add 2013905 end

    return __super::ValidatePeng(pPengCard);
}

BOOL CMyGameTable::ValidateMnGang(LPGANG_CARD pGangCard)
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_HuMJID[i] == pGangCard->nCardID) //打算杠的这张牌已经是别人的胡张
        {
            return FALSE;
        }
    }
    return __super::ValidateMnGang(pGangCard);
}

BOOL CMyGameTable::ValidatePnGang(LPGANG_CARD pGangCard)
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_HuMJID[i] == pGangCard->nCardID) //打算碰的这张牌已经是别人的胡张
        {
            return FALSE;
        }
    }
    return __super::ValidatePnGang(pGangCard);
}

BOOL CMyGameTable::ValidateAnGang(LPGANG_CARD pGangCard)
{
    BOOL ret = __super::ValidateAnGang(pGangCard);
    if (ret == 0)
    {
        return ret;
    }
    if (!ValidateGangAfterHu(pGangCard->nChairNO, pGangCard->nCardID))  //血流胡后杠前后听牌不一致
    {
        return 0;
    }
    return TRUE;
}
BOOL CMyGameTable::ValidateGangAfterHu(int chairno, int nCardID)
{
    if (IsXueLiuRoom() && m_HuReady[chairno])
    {
        vector<int> v1, v2;
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(HU_DETAILS));

        //判断听牌是否一致
        int cardindex = m_pCalclator->MJ_CalcIndexByID(nCardID, 0);
        m_nCardsLayIn[chairno][cardindex] -= 1;
        int gain = CalcTingEx(chairno, huDetails, &v1);
        m_nCardsLayIn[chairno][cardindex] -= 3;
        gain = CalcTingEx(chairno, huDetails, &v2);
        m_nCardsLayIn[chairno][cardindex] += 4;

        if (v1.size() == v2.size())
        {
            for (int k = 0; k < v1.size(); k++)
            {
                if (v1[k] != v2[k])
                {
                    return 0;
                }
            }
        }
        else
        {
            return 0;
        }
    }

    return TRUE;
}

DWORD CMyGameTable::CalcWinOnGiveUp(int chairno, BOOL bTimeOut /*= FALSE*/)
{
    return CalcWinOnHu(chairno);
}

DWORD CMyGameTable::CalcWinOnStandOff(int chairno)
{
    m_bLastGang = FALSE;

    //查花猫
    int nHuCount = 0;
    int score[TOTAL_CHAIRS];
    memset(score, 0, sizeof(score));
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(HU_DETAILS));

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (!m_HuReady[i])
        {
            if (IsHuaZhu(i))//是花猪
            {
                m_HuReady[i] = MJ_HU_HUAZHU;
            }
            else
            {
                score[i] = CalcTing(i, huDetails);
                if (score[i])
                {
                    m_HuReady[i] = MJ_HU_TING;
                }
                else
                {
                    m_stEndGameCheckInfo.nDajiaoPoint[i] = -1;
                }
            }
        }
        else
        {
            //未听牌玩家赔付给已经胡过牌或者听牌玩家
            if (IsXueLiuRoom())
            {
                score[i] = CalcTing(i, huDetails);
                //if (!score[i])
                //{
                //m_stEndGameCheckInfo.nDajiaoPoint[i] = -1;
                //}
            }
            nHuCount++;
        }
    }

    if (IsXueLiuRoom())
    {
        //花猪给（不是花猪的、无论胡没胡，无论听没听）
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_HuReady[i] == MJ_HU_HUAZHU)
            {
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }
                    if (m_HuReady[j] == MJ_HU_HUAZHU || m_HuReady[j] == MJ_GIVE_UP)
                    {
                        continue;
                    }

                    m_stCheckInfo[i].nHuaZhuPoint[j] = -16;
                    m_stCheckInfo[j].nHuaZhuPoint[i] = 16;
                }
            }
        }

        //（没听的，不是花猪的）给（无论胡没胡的，听牌的）听的最大倍数
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_HuReady[i] == 0)
            {
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }
                    if (m_HuReady[j] == 0)
                    {
                        continue;
                    }
                    if (m_HuReady[j] == MJ_HU_HUAZHU || m_HuReady[j] == MJ_GIVE_UP ||
                        m_HuReady[j] == MJ_HU_FANG || m_HuReady[j] == MJ_HU_ZIMO ||
                        m_HuReady[j] == MJ_HU_QGNG || m_HuReady[j] == MJ_HU_HDLY ||
                        m_HuReady[j] == MJ_HU_GKAI || m_HuReady[j] == MJ_HU_7DUI ||
                        m_HuReady[j] == MJ_HU_TIAN || m_HuReady[j] == MJ_HU_DI ||
                        m_HuReady[j] == MJ_HU_PNPN || m_HuReady[j] == MJ_HU_1CLR)
                    {
                        continue;
                    }

                    m_stCheckInfo[i].nDaJiaoPoint[j] = -score[j];
                    m_stCheckInfo[j].nDaJiaoPoint[i] = score[j];
                }
            }
        }
    }
    else
    {
        //花猪给（不是花猪的、没胡的，无论听没听）
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_HuReady[i] == MJ_HU_HUAZHU)
            {
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }
                    if (m_HuReady[j] && m_HuReady[j] != MJ_HU_TING)
                    {
                        continue;
                    }

                    m_stCheckInfo[i].nHuaZhuPoint[j] = -16;
                    m_stCheckInfo[j].nHuaZhuPoint[i] = 16;
                }
            }
        }

        //（没听的，不是花猪的）给（没胡的，听牌的）听的最大倍数付给听牌玩家
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (m_HuReady[i] == 0)
            {
                for (int j = 0; j < m_nTotalChairs; j++)
                {
                    if (i == j)
                    {
                        continue;
                    }
                    if (m_HuReady[j] == MJ_HU_TING)
                    {
                        m_stCheckInfo[i].nDaJiaoPoint[j] = -score[j];
                        m_stCheckInfo[j].nDaJiaoPoint[i] = score[j];
                    }
                }
            }
        }
    }

    if (nHuCount < (TOTAL_CHAIRS - 1))
    {
        m_dwWinFlags = GW_STANDOFF;
    }

    if (IsXueLiuRoom())
    {
        if (m_nHeadTaken + m_nTailTaken >= m_nTotalCards) // 没牌抓了啦
        {
            m_dwWinFlags = GW_NORMAL;
        }
    }

    return m_dwWinFlags;
}

DWORD CMyGameTable::CalcWinOnHu(int chairno)
{
    m_dwWinFlags = 0;

    //XL 血流三人以上放弃了或者抓到没牌了才结束
    if (IsXueLiuRoom())
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j] == MJ_GIVE_UP)
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            m_dwWinFlags = GW_NORMAL;
        }
        else
        {
            if (m_nHeadTaken + m_nTailTaken >= m_nTotalCards) // 没牌抓了啦
            {
                m_dwWinFlags = GW_NORMAL;
            }
            else
            {
                return 0;
            }
        }
    }
    else
    {
        int num = 0;
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (m_HuReady[j])
            {
                num++;
            }
        }

        if (num >= m_nTotalChairs - 1)
        {
            m_dwWinFlags = GW_NORMAL;
        }
        else
        {
            return 0;
        }
    }

    return m_dwWinFlags;
}

int CMyGameTable::GetGangCard(int chairno, BOOL& bBuHua)
{
    if (GangCardFail(chairno))
    {
        // 没有牌可以杠
        return INVALID_OBJECT_ID;
    }

    if (CS_BLACK != m_aryCard[m_nCurrentCatch].nStatus) //牌已被摸
    {
        m_nCurrentCatch = (m_nCurrentCatch + 1) % m_nTotalCards;
    }

    int id = m_aryCard[m_nCurrentCatch].nID;
    int status = m_aryCard[m_nCurrentCatch].nStatus;
    if (id >= 0 && status == 0) //此牌可抓
    {
        //UwlLogFile("Table:%d Chair:%d Gang Card, Catchno:%d ID:%d \n", m_nTableNO, chairno, m_nCurrentCatch, id);

        /////////////////////////////////////////////////////
        MakeCardForCatch(chairno, m_nCurrentCatch);

        /////////////////////////////////////////////////////

        m_aryCard[m_nCurrentCatch].nStatus = CS_CAUGHT;
        m_aryCard[m_nCurrentCatch].nChairNO = chairno;
        int shape = m_aryCard[m_nCurrentCatch].nShape;
        int value = m_aryCard[m_nCurrentCatch].nValue;
        m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
        m_nHeadTaken++;
        m_nLatestedGetMJIndex[chairno] = m_nCurrentCatch;
        int current_catch = m_nCurrentCatch;
        m_nCurrentCatch = (m_nCurrentCatch + 1) % m_nTotalCards;
        m_nCatchCount[chairno]++;

        m_nLastGangNO = m_nCurrentCatch;
        // 增加的部分
        m_nCurrentCard = m_aryCard[current_catch].nID;
        m_nCurrentOpeCard = m_aryCard[current_catch].nID;
        return m_nCurrentCard;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMyGameTable::GetGangCardEx(int chairno)
{
    if (GangCardFail(chairno)) //没有牌可以杠
    {
        return INVALID_OBJECT_ID;
    }

    int nCurCatch = m_nCurrentCatch;
    if (0 != m_aryCard[nCurCatch].nStatus) //牌已被摸
    {
        nCurCatch = (nCurCatch + 1) % m_nTotalCards;
    }

    int id = m_aryCard[nCurCatch].nID;
    int status = m_aryCard[nCurCatch].nStatus;
    if (id >= 0 && status == 0) //此牌可抓
    {
        return id;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMyGameTable::CalcNextBanker(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    int nBanker = -1;
    if (IS_BIT_SET(m_dwWinFlags, GW_STANDOFF)) // 黄庄(和局)
    {
        nBanker = m_nBanker;
    }
    else
    {
        if (m_nLoseChair >= 0)
        {
            nBanker = m_nLoseChair;
        }
        else
        {
            nBanker = m_nHuChair;
        }
    }

    if (-1 != nBanker)
    {
        return nBanker;
    }
    else
    {
        return XygGetRandomBetween(m_nTotalChairs);
    }
}

void CMyGameTable::AddNewGangItem(LPGANG_CARD pGangCard, int flag)
{
    m_bNeedUpdate = TRUE;

    if (flag == MJ_HU_MNGANG)
    {
        //当前胡信息
        m_stHuMultiInfo.nHuCount++;
        m_stHuMultiInfo.nHuFlag = flag;
        m_stHuMultiInfo.nHuChair[pGangCard->nChairNO] = pGangCard->nChairNO;

        //填充杠玩家的item
        HU_ITEM_INFO stHuItem;
        ZeroMemory(&stHuItem, sizeof(stHuItem));
        stHuItem.bWin = TRUE;
        stHuItem.nHuFlag = flag;
        stHuItem.nHuID = pGangCard->nCardID;
        stHuItem.nHuFan = 2;
        //stHuItem.nHuDeposits 留待结算后填充

        int i = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (i == pGangCard->nCardChair)
            {
                stHuItem.nRelateChair[i] = i;
            }
            else
            {
                stHuItem.nRelateChair[i] = INVALID_OBJECT_ID;
            }
        }

        m_vecHuItems[pGangCard->nChairNO].push_back(stHuItem);

        //填充被杠玩家的item
        HU_ITEM_INFO stLossItem;
        ZeroMemory(&stLossItem, sizeof(stLossItem));
        stHuItem.bWin = FALSE;
        stLossItem.nHuFlag = flag;
        stLossItem.nHuID = pGangCard->nCardID;
        stLossItem.nHuFan = -2;
        m_stHuMultiInfo.nLossChair[pGangCard->nCardChair] = pGangCard->nCardChair;

        for (int j = 0; j < m_nTotalChairs; j++)
        {
            if (j == pGangCard->nChairNO)
            {
                stLossItem.nRelateChair[j] = j;
            }
            else
            {
                stLossItem.nRelateChair[j] = INVALID_OBJECT_ID;
            }
        }

        m_vecHuItems[pGangCard->nCardChair].push_back(stLossItem);
    }
    else
    {
        //当前胡信息
        m_stHuMultiInfo.nHuCount++;
        m_stHuMultiInfo.nHuFlag = flag;
        m_stHuMultiInfo.nHuChair[pGangCard->nChairNO] = pGangCard->nChairNO;

        int nFan = (flag == MJ_HU_ANGANG) ? 2 : 1;
        HU_ITEM_INFO stHuItem;
        ZeroMemory(&stHuItem, sizeof(stHuItem));
        stHuItem.bWin = TRUE;
        stHuItem.nHuFlag = flag;
        stHuItem.nHuID = pGangCard->nCardID;

        int i = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            stHuItem.nRelateChair[i] = INVALID_OBJECT_ID;
        }

        int nPlayerCount = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (i == pGangCard->nChairNO)
            {
                continue;
            }
            if (IsHuReady(i))
            {
                continue;
            }
            if (NULL == m_ptrPlayers[i] || m_ptrPlayers[i]->m_bIdlePlayer)
            {
                continue;
            }

            nPlayerCount++;
            HU_ITEM_INFO stLossItem;
            ZeroMemory(&stLossItem, sizeof(stLossItem));
            stLossItem.bWin = FALSE;
            stLossItem.nHuFlag = flag;
            stLossItem.nHuID = pGangCard->nCardID;
            stLossItem.nHuFan = -nFan;
            m_stHuMultiInfo.nLossChair[i] = i;

            for (int j = 0; j < m_nTotalChairs; j++)
            {
                if (j == pGangCard->nChairNO)
                {
                    stLossItem.nRelateChair[j] = j;
                }
                else
                {
                    stLossItem.nRelateChair[j] = INVALID_OBJECT_ID;
                }
            }

            m_vecHuItems[i].push_back(stLossItem);

            stHuItem.nRelateChair[i] = i;
        }

        stHuItem.nHuFan = nFan/**nPlayerCount*/;
        m_vecHuItems[pGangCard->nChairNO].push_back(stHuItem);
    }
}

void CMyGameTable::DealCards()
{
    {
        int startno = m_nCatchFrom;
        int chairno = m_nFirstCatch;
        int t = 0;
        for (t = 0; t < 3; t++)  // 每人抓3次
        {
            chairno = m_nFirstCatch;
            for (int a = 0; a < m_nTotalChairs; a++)  // 4个人
            {
                for (int b = 0; b < 4; b++)  // 每次抓4张
                {
                    int x = (startno++) % m_nTotalCards;
                    m_aryCard[x].nStatus = CS_CAUGHT;
                    m_aryCard[x].nChairNO = chairno;
                    int shape = m_aryCard[x].nShape;
                    int value = m_aryCard[x].nValue;
                    m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
                }
                chairno = GetNextChair(chairno);
            }
        }
        chairno = m_nFirstCatch; // 庄家补抓2张
        for (t = 0; t < 2; t++)
        {
            int x = (startno++) % m_nTotalCards;
            m_aryCard[x].nStatus = CS_CAUGHT;
            m_aryCard[x].nChairNO = chairno;
            int shape = m_aryCard[x].nShape;
            int value = m_aryCard[x].nValue;
            m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
        }
        chairno = GetNextChair(m_nFirstCatch); // 闲家补抓1张
        for (int a = 0; a < m_nTotalChairs - 1; a++)  // 3个人
        {
            int x = (startno++) % m_nTotalCards;
            m_aryCard[x].nStatus = CS_CAUGHT;
            m_aryCard[x].nChairNO = chairno;
            int shape = m_aryCard[x].nShape;
            int value = m_aryCard[x].nValue;
            m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
            chairno = GetNextChair(chairno);
        }

    }

    //new
    {
        //UwlLogFile("**************************Table:%d Game Begin \n", m_nTableNO);

        ReadMakeCardConfig();
        MakeCardForDeal();
    }

}

void CMyGameTable::ReadMakeCardConfig()
{
    CString szIniFile = GetINIFileName();

    TCHAR szRoomID[32];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);
    int nMake = GetPrivateProfileInt(_T("MakeCard"), szRoomID, 0, szIniFile);
    if (nMake <= 0)
    {
        m_stMakeCardConfig.nDealOpen = 0;
        m_stMakeCardConfig.nCatchOpen = 0;
        m_stMakeCardConfig.nExchangeOpen = 0;
        return;
    }

    //做牌开关
    m_stMakeCardConfig.nDealOpen = GetPrivateProfileInt(_T("MakeCardParams"), _T("DealOpen"), 0, szIniFile);
    m_stMakeCardConfig.nExchangeOpen = GetPrivateProfileInt(_T("MakeCardParams"), _T("ExchangeOpen"), 0, szIniFile);
    m_stMakeCardConfig.nCatchOpen = GetPrivateProfileInt(_T("MakeCardParams"), _T("CatchOpen"), 0, szIniFile);

    //牌型分值
    if (m_stMakeCardConfig.nDealOpen || m_stMakeCardConfig.nCatchOpen)
    {
        m_stMakeCardConfig.nGangScore = GetPrivateProfileInt(_T("CardTypeScore"), _T("GangScore"), 0, szIniFile);
        m_stMakeCardConfig.nPengScore = GetPrivateProfileInt(_T("CardTypeScore"), _T("PengScore"), 0, szIniFile);
        m_stMakeCardConfig.nDuizScore = GetPrivateProfileInt(_T("CardTypeScore"), _T("DuizScore"), 0, szIniFile);
        m_stMakeCardConfig.nShunScore = GetPrivateProfileInt(_T("CardTypeScore"), _T("ShunScore"), 0, szIniFile);
    }

    m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("makecardNewLevel"), _T("bout1"), 0, szIniFile);
    m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("makecardNewLevel"), _T("winbout1"), 0, szIniFile);
    m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("makecardNewLevel"), _T("bout2"), 0, szIniFile);
    m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("makecardNewLevel"), _T("winbout2"), 0, szIniFile);
    //发牌参数
    if (m_stMakeCardConfig.nDealOpen)
    {
        m_stMakeCardConfig.nDealPercent[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewPercent1_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDShapeScore[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewShapeScore1_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDTypeScore[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewTypeScore1_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDealPercent[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewPercent2_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDShapeScore[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewShapeScore2_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDTypeScore[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("NewTypeScore2_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDealPercent[PLAYER_BASE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("BasePercent", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDShapeScore[PLAYER_BASE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("BaseShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDTypeScore[PLAYER_BASE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("BaseTypeScore", m_nRoomID).c_str()), 0, szIniFile);

        m_stMakeCardConfig.nDealPercent[PLAYER_ROBOT] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotPercent", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDShapeScore[PLAYER_ROBOT] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDTypeScore[PLAYER_ROBOT] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotTypeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDealPercent[PLAYER_ROBOT_USER] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotWithUserPercent", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDShapeScore[PLAYER_ROBOT_USER] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotWithUserShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nDTypeScore[PLAYER_ROBOT_USER] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("RobotWithUserTypeScore", m_nRoomID).c_str()), 0, szIniFile);

        //m_stMakeCardConfig.nDealPercent[PLAYER_LOSS] = GetPrivateProfileInt(_T("MakeCardParams"), _T("LossPercent"), 0, szIniFile);
        //m_stMakeCardConfig.nDealPercent[PLAYER_JUMP] = GetPrivateProfileInt(_T("MakeCardParams"), _T("JumpPercent"), 0, szIniFile);
        //m_stMakeCardConfig.nDealPercent[PLAYER_PAY] = GetPrivateProfileInt(_T("MakeCardParams"), _T("PayPercent"), 0, szIniFile);
        //m_stMakeCardConfig.nDShapeScore[PLAYER_LOSS] = GetPrivateProfileInt(_T("MakeCardParams"), _T("LossShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nDShapeScore[PLAYER_JUMP] = GetPrivateProfileInt(_T("MakeCardParams"), _T("JumpShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nDShapeScore[PLAYER_PAY] = GetPrivateProfileInt(_T("MakeCardParams"), _T("PayShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nDTypeScore[PLAYER_LOSS] = GetPrivateProfileInt(_T("MakeCardParams"), _T("LossTypeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nDTypeScore[PLAYER_JUMP] = GetPrivateProfileInt(_T("MakeCardParams"), _T("JumpTypeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nDTypeScore[PLAYER_PAY] = GetPrivateProfileInt(_T("MakeCardParams"), _T("PayTypeScore"), 0, szIniFile);
    }

    //摸牌参数
    if (m_stMakeCardConfig.nCatchOpen)
    {
        m_stMakeCardConfig.nCatchPercent = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CatchPercent", m_nRoomID).c_str()), 0, szIniFile);

        m_stMakeCardConfig.nCGPDPercent[0] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CTypeGangPercent"), 0, szIniFile);
        m_stMakeCardConfig.nCGPDPercent[1] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CTypePengPercent"), 0, szIniFile);
        m_stMakeCardConfig.nCGPDPercent[2] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CTypeDuizPercent"), 0, szIniFile);

        m_stMakeCardConfig.nCShapeScore[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CNewShapeScore1_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCTypeScore[PLAYER_NEW_LEVEL_ONE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CNewTypeScore1_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCShapeScore[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CNewShapeScore2_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCTypeScore[PLAYER_NEW_LEVEL_TWO] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CNewTypeScore2_", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCShapeScore[PLAYER_BASE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CBaseShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCTypeScore[PLAYER_BASE] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CBaseTypeScore", m_nRoomID).c_str()), 0, szIniFile);

        m_stMakeCardConfig.nCShapeScore[PLAYER_ROBOT] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CRobotShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCTypeScore[PLAYER_ROBOT] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CRobotTypeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCShapeScore[PLAYER_ROBOT_USER] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CRobotWithUserShapeScore", m_nRoomID).c_str()), 0, szIniFile);
        m_stMakeCardConfig.nCTypeScore[PLAYER_ROBOT_USER] = GetPrivateProfileInt(_T("MakeCardParams"), _T(getConfigNameByRoomID("CRobotWithUserTypeScore", m_nRoomID).c_str()), 0, szIniFile);

        //m_stMakeCardConfig.nCShapeScore[PLAYER_LOSS] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CLossShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nCTypeScore[PLAYER_LOSS] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CLossTypeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nCShapeScore[PLAYER_JUMP] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CJumpShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nCTypeScore[PLAYER_JUMP] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CJumpTypeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nCShapeScore[PLAYER_PAY] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CPayShapeScore"), 0, szIniFile);
        //m_stMakeCardConfig.nCTypeScore[PLAYER_PAY] = GetPrivateProfileInt(_T("MakeCardParams"), _T("CPayTypeScore"), 0, szIniFile);
    }
}

void CMyGameTable::MakeCardForDeal()
{
    if (0 == m_stMakeCardConfig.nDealOpen)
    {
        return;
    }

    BOOL bRobotBout = FALSE;
    for (int j = 0; j < TOTAL_CHAIRS; j++)
    {
        if (IsRoboter(j))
        {
            bRobotBout = True;
        }
    }

    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (m_ptrPlayers[i])
        {
            if (bRobotBout)
            {
                if (IsRoboter(i))
                {
                    MakeCardByPlayerTypeForDeal(i, PLAYER_ROBOT);
                }
                else
                {
                    MakeCardByPlayerTypeForDeal(i, PLAYER_ROBOT_USER);
                }
            }
            else
            {
                //等级1的新手
                if (m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_ONE] > 0 && m_ptrPlayers[i]->m_nBout <= m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_ONE]
                    && m_stMakeCardInfo[i].nWinBout <= m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_ONE])
                {
                    MakeCardByPlayerTypeForDeal(i, PLAYER_NEW_LEVEL_ONE);
                }
                else if (m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_TWO] > 0 && m_ptrPlayers[i]->m_nBout <= m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_TWO]
                    && m_stMakeCardInfo[i].nWinBout <= m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_TWO])
                {
                    MakeCardByPlayerTypeForDeal(i, PLAYER_NEW_LEVEL_TWO);
                }
                //else if (m_stMakeCardInfo[i].nLossCount >= 2)
                //{
                //    MakeCardByPlayerType(i, PLAYER_LOSS);
                //}
                //else if (m_stMakeCardInfo[i].nPayCount > 0 && m_stMakeCardInfo[i].nPayCount <= 3)
                //{
                //    MakeCardByPlayerType(i, PLAYER_PAY);
                //}
                //else if (m_stMakeCardInfo[i].nJumpCount > 0 && m_stMakeCardInfo[i].nJumpCount <= 2)
                //{
                //    MakeCardByPlayerType(i, PLAYER_JUMP);
                //}
                else
                {
                    MakeCardByPlayerTypeForDeal(i, PLAYER_BASE);
                }
            }
        }
    }
}

void CMyGameTable::MakeCardForCatch(int chairno, int catchno)
{
    if (0 == m_stMakeCardConfig.nCatchOpen)
    {
        return;
    }

    BOOL bRobotBout = FALSE;
    for (int j = 0; j < TOTAL_CHAIRS; j++)
    {
        if (IsRoboter(j))
        {
            bRobotBout = True;
        }
    }

    if (m_ptrPlayers[chairno])
    {
        if (bRobotBout)
        {
            if (IsRoboter(chairno))
            {
                MakeCardByPlayerTypeEx(chairno, PLAYER_ROBOT, catchno);
            }
            else
            {
                MakeCardByPlayerTypeEx(chairno, PLAYER_ROBOT_USER, catchno);
            }
        }
        else
        {
            //新手玩家前3局
            if (m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_ONE] > 0 && m_ptrPlayers[chairno]->m_nBout <= m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_ONE]
                && m_stMakeCardInfo[chairno].nWinBout <= m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_ONE])
            {
                MakeCardByPlayerTypeEx(chairno, PLAYER_NEW_LEVEL_ONE, catchno);
            }
            else if (m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_TWO] > 0 && m_ptrPlayers[chairno]->m_nBout <= m_stMakeCardConfig.nTotalBount[PLAYER_NEW_LEVEL_TWO]
                && m_stMakeCardInfo[chairno].nWinBout <= m_stMakeCardConfig.nWinBount[PLAYER_NEW_LEVEL_TWO])
            {
                MakeCardByPlayerTypeEx(chairno, PLAYER_NEW_LEVEL_TWO, catchno);
            }
            //else if (m_stMakeCardInfo[chairno].nLossCount >= 2)
            //{
            //    MakeCardByPlayerTypeEx(chairno, PLAYER_LOSS, catchno);
            //}
            //else if (m_stMakeCardInfo[chairno].nPayCount > 0 && m_stMakeCardInfo[chairno].nPayCount <= 3)
            //{
            //    MakeCardByPlayerTypeEx(chairno, PLAYER_PAY, catchno);
            //}
            //else if (m_stMakeCardInfo[chairno].nJumpCount > 0 && m_stMakeCardInfo[chairno].nJumpCount <= 2)
            //{
            //    MakeCardByPlayerTypeEx(chairno, PLAYER_JUMP, catchno);
            //}
            else
            {
                MakeCardByPlayerTypeEx(chairno, PLAYER_BASE, catchno);
            }
        }
    }
}

void CMyGameTable::MakeCardByPlayerType(int chairno, PLAYER_TYPE enPlayerType)
{

    int nShapeIndex = 0;
    int nMinShapeIndex = 0;
    int nMinShapeCount = 0;
    int nShapeScore = GetHandShapeScore(chairno, nShapeIndex, nMinShapeIndex, nMinShapeCount);

    int nLayIn[LAYOUT_XZMO];
    ZeroMemory(nLayIn, sizeof(nLayIn));

    int nKeziCount = 0;
    int nKeziLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nKeziLayIn, sizeof(nKeziLayIn));

    int nDuiziCount = 0;
    int nDuiziLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nDuiziLayIn, sizeof(nDuiziLayIn));

    int nTypeScore = GetHandTypeScore(chairno, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
    if (nShapeScore >= nTypeScore)
    {
        m_stMakeCardInfo[chairno].nHandScore = nShapeScore;
    }
    else
    {
        m_stMakeCardInfo[chairno].nHandScore = nTypeScore;
    }

    m_stMakeCardInfo[chairno].nMakeDeal = 0;

    int nPercent = m_stMakeCardConfig.nDealPercent[enPlayerType];
    int nRandValue = GetRandomValue();
    if (nRandValue <= nPercent)
    {
        if (nShapeScore >= nTypeScore)
        {
            int nMaxSocre = m_stMakeCardConfig.nDShapeScore[enPlayerType];
            if (nShapeScore < nMaxSocre)
            {
                MakeCardByShape(chairno, nShapeScore, nShapeIndex, nMaxSocre, nMinShapeCount, nMinShapeIndex);
            }
        }
        else
        {
            int nMaxScore = m_stMakeCardConfig.nDTypeScore[enPlayerType];
            if (nTypeScore < nMaxScore)
            {
                MakeCardByType(chairno, nTypeScore, nMaxScore, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
            }
        }
    }
}

//发牌做牌, 牌花和牌型都做的那种
void CMyGameTable::MakeCardByPlayerTypeForDeal(int chairno, PLAYER_TYPE enPlayerType)
{
    int nShapeIndex = 0;
    int nMinShapeIndex = 0;
    int nMinShapeCount = 0;
    m_bIsMakeCard[chairno] = TRUE;
    m_nNewPlayer[chairno] = enPlayerType;
    int nShapeScore = GetHandShapeScore(chairno, nShapeIndex, nMinShapeIndex, nMinShapeCount);

    int nLayIn[LAYOUT_XZMO];
    ZeroMemory(nLayIn, sizeof(nLayIn));

    int nKeziCount = 0;
    int nKeziLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nKeziLayIn, sizeof(nKeziLayIn));

    int nDuiziCount = 0;
    int nDuiziLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nDuiziLayIn, sizeof(nDuiziLayIn));

    m_stMakeCardInfo[chairno].nHandScore = nShapeScore;
    m_stMakeCardInfo[chairno].nMakeDeal = 0;
    // 先做牌花分
    int nMaxSocre = m_stMakeCardConfig.nDShapeScore[enPlayerType];
    if (nShapeScore < nMaxSocre)
    {
        MakeCardByShape(chairno, nShapeScore, nShapeIndex, nMaxSocre, nMinShapeCount, nMinShapeIndex);
    }

    // 再做牌型分
    int nTypeScore = GetHandTypeScoreEx3(chairno, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn, nShapeIndex);
    m_stMakeCardInfo[chairno].nHandScore = nTypeScore;
    int nMaxScore = m_stMakeCardConfig.nDTypeScore[enPlayerType];
    if (nTypeScore < nMaxScore)
    {
        MakeCardByType(chairno, nTypeScore, nMaxScore, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
    }
}

void CMyGameTable::MakeCardByPlayerTypeEx(int chairno, PLAYER_TYPE enPlayerType, int nCatchNO)
{
    int nRandValue = GetRandomValue();
    if (nRandValue > m_stMakeCardConfig.nCatchPercent)
    {
        return;
    }

    LOG_DEBUG("Table:%d Chair:%d MakeCardByPlayerTypeEx Catch Card, Catchno:%d ID:%d \n", m_nTableNO, chairno, nCatchNO, m_aryCard[nCatchNO].nID);

    if (0 == m_stMakeCardInfo[chairno].nMakeCatch)
    {
        int nShapeIndex = 0;
        int nShapeScore = GetHandShapeScoreEx(chairno, nShapeIndex);
        int nTypeScore = GetHandTypeScoreEx2(chairno);
        m_stMakeCardInfo[chairno].nMakeCatch = nShapeScore >= nTypeScore ? 1 : 2;
        LOG_DEBUG("[MakeCardByPlayerTypeEx]----nShapeScore: %d, nTypeScore: %d\n", nShapeScore, nTypeScore);
    }

    if (1 == m_stMakeCardInfo[chairno].nMakeCatch)
    {
        if (0 == m_stMakeCardConfig.nCShapeScore[enPlayerType])
        {
            return;
        }

        int nShapeIndex = 0;
        int nShapeScore = GetHandShapeScoreEx(chairno, nShapeIndex);
        if (nShapeScore < m_stMakeCardConfig.nCShapeScore[enPlayerType])
        {
            int nCatchShape = m_pCalclator->MJ_CalculateCardShape(m_aryCard[nCatchNO].nID, m_dwGameFlags);
            if (nCatchShape != nShapeIndex)
            {
                MakeCardByShapeEx(chairno, nShapeIndex, nCatchNO);
            }
        }
        //else
        //{
        //    if (MakeCardAfterTing(chairno))
        //    {
        //        MakeCardByShapeEx(chairno, nShapeIndex, nCatchNO);
        //    }
        //}
    }
    else if (2 == m_stMakeCardInfo[chairno].nMakeCatch)
    {
        if (0 == m_stMakeCardConfig.nCTypeScore[enPlayerType])
        {
            return;
        }

        int nLayIn[LAYOUT_XZMO];
        ZeroMemory(nLayIn, sizeof(nLayIn));

        int nKeziCount = 0;
        int nKeziLayIn[MJ_FIRST_CATCH_13];
        ZeroMemory(nKeziLayIn, sizeof(nKeziLayIn));

        int nDuiziCount = 0;
        int nDuiziLayIn[MJ_FIRST_CATCH_13];
        ZeroMemory(nDuiziLayIn, sizeof(nDuiziLayIn));

        int nTypeScore = GetHandTypeScoreEx(chairno, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
        if (nTypeScore < m_stMakeCardConfig.nCTypeScore[enPlayerType])
        {
            int nCatchShape = m_pCalclator->MJ_CalculateCardShape(m_aryCard[nCatchNO].nID, m_dwGameFlags);
            if (nCatchShape == m_nDingQueCardType[chairno])
            {
                MakeCardByTypeEx(chairno, nCatchNO, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
            }
            else
            {
                int cardidx = m_pCalclator->MJ_CalcIndexByID(m_aryCard[nCatchNO].nID, m_dwGameFlags);
                if (cardidx > 0 && m_nCardsLayIn[chairno][cardidx] == 0) //手里没有相同牌(不包含摸进来的牌)
                {
                    MakeCardByTypeEx(chairno, nCatchNO, nKeziCount, nKeziLayIn, nDuiziCount, nDuiziLayIn, nLayIn);
                }
                //else
                //UwlLogFile("Table:%d Chair:%d MakeCardByTypeEx Have SameCard\n", m_nTableNO, chairno);
            }
        }
    }
}

void CMyGameTable::MakeCardByShape(int chairno, int nShapeScore, int nShapeIndex, int nMaxScore, int nMinShapeCount, int nMinShapeIndex)
{
    DWORD dwTickCount = GetTickCount();

    m_stMakeCardInfo[chairno].nMakeDeal = 1;
    int nChangeCount = nMaxScore - nShapeScore;
    int i = 0;
    int nLeftNum = 0;
    int nLeftLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nLeftLayIn, sizeof(nLeftLayIn));

    //优先拿最少的牌
    for (i = nMinShapeIndex * m_nLayoutMod; i < nMinShapeIndex * m_nLayoutMod + m_nLayoutMod; i++)
    {
        if (m_nCardsLayIn[chairno][i] > 0)
        {
            nLeftLayIn[nLeftNum++] = i;
        }
    }

    //牌不够换, 从另外一个花色随机几张出来
    if (nChangeCount > nMinShapeCount)
    {
        int nTmpLeftLayIn[MJ_FIRST_CATCH_13];
        ZeroMemory(nTmpLeftLayIn, sizeof(nTmpLeftLayIn));
        int nTmpLeftNum = 0;
        for (i = 0; i < LAYOUT_XZMO; i++)
        {
            int nShape = i / m_nLayoutMod;
            if (nShape != nShapeIndex && nShape != nMinShapeIndex && m_nCardsLayIn[chairno][i] > 0)
            {
                nTmpLeftLayIn[nTmpLeftNum++] = i;
            }
        }
        m_pCalclator->xyRandomSort(nTmpLeftLayIn, nTmpLeftNum, GetTickCount() + m_ptrPlayers[chairno]->m_lTokenID * 10 + m_ptrPlayers[chairno]->m_hSocket);

        for (i = 0; i < nChangeCount - nMinShapeCount; i++)
        {
            nLeftLayIn[nLeftNum++] = nTmpLeftLayIn[i];
        }
    }
    else
    {
        //剩余牌随机排序
        m_pCalclator->xyRandomSort(nLeftLayIn, nLeftNum, GetTickCount() + m_ptrPlayers[chairno]->m_lTokenID * 10 + m_ptrPlayers[chairno]->m_hSocket);
    }

    if (nLeftNum <= 0)
    {
        return;
    }

    //交换
    for (i = 0; i < nChangeCount && i < nLeftNum; i++)
    {
        int tochangeno = GetWallCardnoByShape(nShapeIndex);
        if (tochangeno != INVALID_OBJECT_ID)
        {
            int changeno = GetHandCardnoByLayIndex(chairno, nLeftLayIn[i]);
            if (changeno != INVALID_OBJECT_ID)
            {
                ExchangeHandAndWallCard(chairno, changeno, tochangeno);
            }
        }
        else
        {
            return;
        }
    }

    LOG_DEBUG("Table:%d Chair:%d MakeCardByShape end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);
}

void CMyGameTable::MakeCardByShapeEx(int chairno, int nShapeIndex, int nCatchNO)
{
    DWORD dwTickCount = GetTickCount();

    //交换
    int tochangeno = GetWallCardnoByShape(nShapeIndex);
    if (tochangeno != INVALID_OBJECT_ID)
    {
        int changeno = nCatchNO;
        if (changeno != INVALID_OBJECT_ID)
        {
            ExchangeCatchAndWallCard(chairno, changeno, tochangeno);
        }
    }
}

void CMyGameTable::MakeCardByType(int chairno, int nTypeScore, int nMaxScore, int nKeziCount, int nKeziLayIn[], int nDuiziCount, int nDuiziLayIn[], int nLayIn[])
{
    DWORD dwTickCount = GetTickCount();

    m_stMakeCardInfo[chairno].nMakeDeal = 2;

    int i = 0;
    int nLeftNum = 0;
    int nLeftLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nLeftLayIn, sizeof(nLeftLayIn));
    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (nLayIn[i] > 0)
        {
            nLeftLayIn[nLeftNum++] = i;
        }
    }

    if (nLeftNum <= 0)
    {
        return;
    }

    //剩余牌随机排序
    m_pCalclator->xyRandomSort(nLeftLayIn, nLeftNum, GetTickCount() + m_ptrPlayers[chairno]->m_lTokenID * 10 + m_ptrPlayers[chairno]->m_hSocket);

    //找刻子凑杠
    for (i = 0; i < nKeziCount; i++)
    {
        int tochangeno = GetWallCardnoByLayIndex(nKeziLayIn[i]);
        if (tochangeno != INVALID_OBJECT_ID)
        {
            if (nLeftNum > 0 && nLeftLayIn[nLeftNum - 1] > 0)
            {
                int changeno = GetHandCardnoByLayIndex(chairno, nLeftLayIn[nLeftNum - 1]);
                if (changeno != INVALID_OBJECT_ID)
                {
                    ExchangeHandAndWallCard(chairno, changeno, tochangeno);

                    nLeftLayIn[nLeftNum - 1] = 0;
                    if (--nLeftNum <= 0)
                    {
                        return;
                    }

                    if (++nTypeScore >= nMaxScore)
                    {
                        return;
                    }
                }
            }
            else
            {
                return;
            }
        }
    }

    //找对子凑刻子
    for (i = 0; i < nDuiziCount; i++)
    {
        int tochangeno = GetWallCardnoByLayIndex(nDuiziLayIn[i]);
        if (tochangeno != INVALID_OBJECT_ID)
        {
            if (nLeftNum > 0 && nLeftLayIn[nLeftNum - 1] > 0)
            {
                int changeno = GetHandCardnoByLayIndex(chairno, nLeftLayIn[nLeftNum - 1]);
                if (changeno != INVALID_OBJECT_ID)
                {
                    ExchangeHandAndWallCard(chairno, changeno, tochangeno);

                    nLeftLayIn[nLeftNum - 1] = 0;
                    if (--nLeftNum <= 0)
                    {
                        return;
                    }

                    if (++nTypeScore >= nMaxScore)
                    {
                        return;
                    }
                }
            }
            else
            {
                return;
            }
        }
    }

    //找单张凑对子
    if (nLeftNum >= 2) //至少两张单牌
    {
        for (i = 0; i < floor(nLeftNum / 2); i++)
        {
            int tochangeno = GetWallCardnoByLayIndex(nLeftLayIn[i]);
            if (tochangeno != INVALID_OBJECT_ID)
            {
                int changeno = GetHandCardnoByLayIndex(chairno, nLeftLayIn[nLeftNum - 1 - i]);
                if (changeno != INVALID_OBJECT_ID)
                {
                    ExchangeHandAndWallCard(chairno, changeno, tochangeno);

                    if (++nTypeScore >= nMaxScore)
                    {
                        return;
                    }
                }
            }
        }
    }
}

void CMyGameTable::MakeCardByTypeEx(int chairno, int nCatchNO, int nKeziCount, int nKeziLayIn[], int nDuiziCount, int nDuiziLayIn[], int nLayIn[])
{
    DWORD dwTickCount = GetTickCount();

    //找单张
    int i = 0;
    int nSingleCount = 0;
    int nSingleLayIn[MJ_FIRST_CATCH_13];
    ZeroMemory(nSingleLayIn, sizeof(nSingleLayIn));
    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (nLayIn[i] > 0)
        {
            nSingleLayIn[nSingleCount++] = i;
        }
    }

    //组装
    int nTypeLayIn[3][MJ_FIRST_CATCH_13];
    ZeroMemory(nTypeLayIn, sizeof(nTypeLayIn));
    memcpy(nTypeLayIn[0], nKeziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);
    memcpy(nTypeLayIn[1], nDuiziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);
    memcpy(nTypeLayIn[2], nSingleLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    int nTypeCount[3];
    nTypeCount[0] = nKeziCount;
    nTypeCount[1] = nDuiziCount;
    nTypeCount[2] = nSingleCount;

    int nBeginIndex = 0;
    int nTotalPercent = 0;
    int nRandValue = GetRandomValue();
    for (i = 0; i < 3; i++)
    {
        if (nRandValue <= m_stMakeCardConfig.nCGPDPercent[i] + nTotalPercent)
        {
            nBeginIndex = i;
            break;
        }
        else
        {
            nTotalPercent += m_stMakeCardConfig.nCGPDPercent[i];
        }
    }


    //按优先级配置找刻子, 对子，单张凑杠
    for (i = nBeginIndex; i < 3; i++)
    {
        for (int j = 0; j < nTypeCount[i]; j++)
        {
            int tochangeno = GetWallCardnoByLayIndex(nTypeLayIn[i][j]);
            if (tochangeno != INVALID_OBJECT_ID)
            {
                int changeno = nCatchNO;
                if (changeno != INVALID_OBJECT_ID)
                {
                    ExchangeCatchAndWallCard(chairno, changeno, tochangeno);
                    return;
                }
            }
        }
    }
}

void CMyGameTable::ExchangeHandAndWallCard(int chairno, int changeno, int tochangeno)
{
    int shape = m_aryCard[changeno].nShape;
    int value = m_aryCard[changeno].nValue;;
    int toshape = m_aryCard[tochangeno].nShape;
    int tovalue = m_aryCard[tochangeno].nValue;

    LOG_DEBUG("Table:%d Chair:%d ExchangeHandAndWallCard, Changeno:%d, ID:%d, Stauts:%d, Chair:%d; ToChangeno:%d, ID:%d, Stauts:%d, Chair:%d\n",
        m_nTableNO, chairno, changeno, m_aryCard[changeno].nID, m_aryCard[changeno].nStatus, m_aryCard[changeno].nChairNO, tochangeno, m_aryCard[tochangeno].nID, m_aryCard[tochangeno].nStatus,
        m_aryCard[tochangeno].nChairNO);

    //m_aryCard交换
    m_aryCard[tochangeno].nStatus = CS_CAUGHT;
    m_aryCard[tochangeno].nChairNO = chairno;

    m_aryCard[changeno].nStatus = 0;
    m_aryCard[changeno].nChairNO = INVALID_OBJECT_ID;

    CARD temp = m_aryCard[changeno];
    m_aryCard[changeno] = m_aryCard[tochangeno];
    m_aryCard[tochangeno] = temp;

    //m_nCardsLayIn交换
    m_nCardsLayIn[chairno][toshape * m_nLayoutMod + tovalue]++;
    m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]--;
}

void CMyGameTable::ExchangeCatchAndWallCard(int chairno, int changeno, int tochangeno)
{
    int shape = m_aryCard[changeno].nShape;
    int value = m_aryCard[changeno].nValue;;
    int toshape = m_aryCard[tochangeno].nShape;
    int tovalue = m_aryCard[tochangeno].nValue;

    LOG_DEBUG("Table:%d Chair:%d ExchangeHandAndWallCard, Changeno:%d, ID:%d, Stauts:%d, Chair:%d; ToChangeno:%d, ID:%d, Stauts:%d, Chair:%d\n",
        m_nTableNO, chairno, changeno, m_aryCard[changeno].nID, m_aryCard[changeno].nStatus, m_aryCard[changeno].nChairNO, tochangeno
        , m_aryCard[tochangeno].nID, m_aryCard[tochangeno].nStatus, m_aryCard[tochangeno].nChairNO);

    CARD temp = m_aryCard[changeno];
    m_aryCard[changeno] = m_aryCard[tochangeno];
    m_aryCard[tochangeno] = temp;

    LOG_DEBUG("ExchangeCatchAndWallCard: changeno: cardid: %d, shape: %d, value: %d", m_aryCard[changeno].nID, m_aryCard[changeno].nShape, m_aryCard[changeno].nValue);
    LOG_DEBUG("ExchangeCatchAndWallCard: tochangeno: cardid: %d, shape: %d, value: %d", m_aryCard[tochangeno].nID, m_aryCard[tochangeno].nShape, m_aryCard[tochangeno].nValue);
}

BOOL CMyGameTable::MakeCardAfterTing(int chairno)
{
    if (!CalcHasNoDingQue(chairno))
    {
        return FALSE;
    }

    int nMaxBei = IsXueLiuRoom() ? m_stMakeCardConfig.nCXLExpectBei : m_stMakeCardConfig.nCXZExpectBei;
    if (nMaxBei > 0)
    {
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(HU_DETAILS));
        if (1 == CalcTing2(chairno, huDetails, nMaxBei))
        {
            return TRUE;
        }
    }

    return FALSE;
}

// 未定缺时, 计算牌的牌型牌力值(不会重复计算顺子和刻子)
int CMyGameTable::GetHandTypeScore(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[])
{
    DWORD dwTickCount = GetTickCount();

    int i = 0;
    int nTypeScore = 0;
    memcpy(nLayIn, m_nCardsLayIn[chairno], sizeof(int)*LAYOUT_XZMO);

    nKeziCount = 0;
    ZeroMemory(nKeziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    nDuiziCount = 0;
    ZeroMemory(nDuiziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (4 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nGangScore;
        }
        if (3 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nPengScore;
            nKeziLayIn[nKeziCount++] = i;
        }
        if (2 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nDuizScore;
            nDuiziLayIn[nDuiziCount++] = i;
        }
    }

    for (i = 0; i < SHAPE_COUNT; i++)
    {
        for (int j = 1; j < m_nLayoutMod; j++)
        {
            if (nLayIn[i * m_nLayoutMod + j] > 0 && nLayIn[i * m_nLayoutMod + j + 1] > 0 && nLayIn[i * m_nLayoutMod + j + 2] > 0)
            {
                nLayIn[i * m_nLayoutMod + j] = 0;
                nLayIn[i * m_nLayoutMod + j + 1] = 0;
                nLayIn[i * m_nLayoutMod + j + 2] = 0;
                nTypeScore += m_stMakeCardConfig.nShunScore;
                j += 2;
            }
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandTypeScore end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nTypeScore;
}

// 计算非定缺牌的牌型牌力值, 不重复计算(计算过顺子的牌就不计算刻子)
int CMyGameTable::GetHandTypeScoreEx(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[])
{
    DWORD dwTickCount = GetTickCount();

    int i = 0;
    int nTypeScore = 0;
    memcpy(nLayIn, m_nCardsLayIn[chairno], sizeof(int)*LAYOUT_XZMO);

    nKeziCount = 0;
    ZeroMemory(nKeziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    nDuiziCount = 0;
    ZeroMemory(nDuiziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (0 == nLayIn[i])
        {
            continue;
        }

        int nShape = i / m_nLayoutMod;
        if (nShape == m_nDingQueCardType[chairno]) //定缺
        {
            nLayIn[i] = 0;
            continue;
        }

        if (4 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nGangScore;
        }
        if (3 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nPengScore;
            nKeziLayIn[nKeziCount++] = i;
        }
        if (2 == nLayIn[i])
        {
            nLayIn[i] = 0;
            nTypeScore += m_stMakeCardConfig.nDuizScore;
            nDuiziLayIn[nDuiziCount++] = i;
        }
    }

    for (i = 0; i < SHAPE_COUNT; i++)
    {
        if (i == m_nDingQueCardType[chairno]) //非定缺
        {
            continue;
        }

        for (int j = 1; j < m_nLayoutMod; j++)
        {
            if (nLayIn[i * m_nLayoutMod + j] > 0 && nLayIn[i * m_nLayoutMod + j + 1] > 0 && nLayIn[i * m_nLayoutMod + j + 2] > 0)
            {
                nLayIn[i * m_nLayoutMod + j] = 0;
                nLayIn[i * m_nLayoutMod + j + 1] = 0;
                nLayIn[i * m_nLayoutMod + j + 2] = 0;
                nTypeScore += m_stMakeCardConfig.nShunScore;
                j += 2;
            }
        }
    }

    //吃碰杠的牌
    int nGangScore = (m_MnGangCards[chairno].GetSize() + m_AnGangCards[chairno].GetSize() + m_PnGangCards[chairno].GetSize()) * m_stMakeCardConfig.nGangScore;
    nTypeScore += nGangScore;

    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            BOOL bPn = FALSE;
            for (int j = 0; j < m_PnGangCards[chairno].GetSize(); j++)
            {
                CARDS_UNIT cards_unit = m_PnGangCards[chairno][j];
                if (cardidx == m_pCalclator->MJ_CalcIndexByID(cards_unit.nCardIDs[0], m_dwGameFlags))
                {
                    bPn = TRUE;
                    break;
                }
            }

            if (!bPn)
            {
                nTypeScore += m_stMakeCardConfig.nPengScore;
            }
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandTypeScoreEx end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nTypeScore;
}

// 计算玩家类型牌力值(顺子,对子等会重复计算)
int CMyGameTable::GetHandTypeScoreEx2(int chairno)
{
    DWORD dwTickCount = GetTickCount();

    int i = 0;
    int nTypeScore = 0;
    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (0 == m_nCardsLayIn[chairno][i])
        {
            continue;
        }

        int nShape = i / m_nLayoutMod;
        if (nShape == m_nDingQueCardType[chairno]) //定缺
        {
            continue;
        }

        if (4 == m_nCardsLayIn[chairno][i])
        {
            nTypeScore += m_stMakeCardConfig.nGangScore;
        }
        if (3 == m_nCardsLayIn[chairno][i])
        {
            nTypeScore += m_stMakeCardConfig.nPengScore;
        }
        if (2 == m_nCardsLayIn[chairno][i])
        {
            nTypeScore += m_stMakeCardConfig.nDuizScore;
        }
    }

    for (i = 0; i < SHAPE_COUNT; i++)
    {
        if (i == m_nDingQueCardType[chairno]) //非定缺
        {
            continue;
        }

        for (int j = 1; j < m_nLayoutMod; j++)
        {
            if (m_nCardsLayIn[chairno][i * m_nLayoutMod + j] > 0 && m_nCardsLayIn[chairno][i * m_nLayoutMod + j + 1] > 0 && m_nCardsLayIn[chairno][i * m_nLayoutMod + j + 2] > 0)
            {
                nTypeScore += m_stMakeCardConfig.nShunScore;
                j += 2;
            }
        }
    }

    //吃碰杠的牌
    int nGangScore = (m_MnGangCards[chairno].GetSize() + m_AnGangCards[chairno].GetSize() + m_PnGangCards[chairno].GetSize()) * m_stMakeCardConfig.nGangScore;
    nTypeScore += nGangScore;

    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            BOOL bPn = FALSE;
            for (int j = 0; j < m_PnGangCards[chairno].GetSize(); j++)
            {
                CARDS_UNIT cards_unit = m_PnGangCards[chairno][j];
                if (cardidx == m_pCalclator->MJ_CalcIndexByID(cards_unit.nCardIDs[0], m_dwGameFlags))
                {
                    bPn = TRUE;
                    break;
                }
            }

            if (!bPn)
            {
                nTypeScore += m_stMakeCardConfig.nPengScore;
            }
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandTypeScoreEx2 end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nTypeScore;
}

// 未定缺时, 计算某个花色牌的牌型牌力值(不会重复计算顺子和刻子)
int CMyGameTable::GetHandTypeScoreEx3(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[], int shape)
{
    DWORD dwTickCount = GetTickCount();

    int i = 0;
    int nTypeScore = 0;
    memcpy(nLayIn, m_nCardsLayIn[chairno], sizeof(int)*LAYOUT_XZMO);

    nKeziCount = 0;
    ZeroMemory(nKeziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    nDuiziCount = 0;
    ZeroMemory(nDuiziLayIn, sizeof(int)*MJ_FIRST_CATCH_13);

    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (i >= shape * m_nLayoutMod && i < shape * m_nLayoutMod + m_nLayoutMod)
        {
            if (4 == nLayIn[i])
            {
                nLayIn[i] = 0;
                nTypeScore += m_stMakeCardConfig.nGangScore;
            }
            if (3 == nLayIn[i])
            {
                nLayIn[i] = 0;
                nTypeScore += m_stMakeCardConfig.nPengScore;
                nKeziLayIn[nKeziCount++] = i;
            }
            if (2 == nLayIn[i])
            {
                nLayIn[i] = 0;
                nTypeScore += m_stMakeCardConfig.nDuizScore;
                nDuiziLayIn[nDuiziCount++] = i;
            }
        }
        else
        {
            nLayIn[i] = 0;
        }

    }

    for (int j = 1; j < m_nLayoutMod; j++)
    {
        if (nLayIn[shape * m_nLayoutMod + j] > 0 && nLayIn[shape * m_nLayoutMod + j + 1] > 0 && nLayIn[shape * m_nLayoutMod + j + 2] > 0)
        {
            nLayIn[shape * m_nLayoutMod + j] = 0;
            nLayIn[shape * m_nLayoutMod + j + 1] = 0;
            nLayIn[shape * m_nLayoutMod + j + 2] = 0;
            nTypeScore += m_stMakeCardConfig.nShunScore;
            j += 2;
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandTypeScore end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nTypeScore;
}

int CMyGameTable::GetHandShapeScore(int chairno, int& nMaxShapeIndex, int& nMinShapeIndex, int& nMinShapeCount)
{
    DWORD dwTickCount = GetTickCount();

    //计算所有花色数目
    int i = 0;
    int nShapeCount[SHAPE_COUNT];
    ZeroMemory(nShapeCount, sizeof(nShapeCount));
    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (m_nCardsLayIn[chairno][i])
        {
            int nShape = i / m_nLayoutMod;
            nShapeCount[nShape] += m_nCardsLayIn[chairno][i];
        }
    }

    //计算最大花色数目
    nMaxShapeIndex = 0;
    int nMaxShapeCount = nShapeCount[0];
    nMinShapeCount = nShapeCount[0];
    for (i = 1; i < SHAPE_COUNT; i++)
    {
        if (nMaxShapeCount < nShapeCount[i])
        {
            nMaxShapeIndex = i;
            nMaxShapeCount = nShapeCount[i];
        }
        if (nMinShapeCount > nShapeCount[i])
        {
            nMinShapeIndex = i;
            nMinShapeCount = nShapeCount[i];
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandShapeScore end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nMaxShapeCount;
}

// 获得到玩家最多花色数
int CMyGameTable::GetHandShapeScoreEx(int chairno, int& nMaxShapeIndex)
{
    DWORD dwTickCount = GetTickCount();

    //计算所有花色数目(非定缺)
    int i = 0;
    int nShapeCount[SHAPE_COUNT];
    ZeroMemory(nShapeCount, sizeof(nShapeCount));
    for (i = 0; i < LAYOUT_XZMO; i++)
    {
        if (m_nCardsLayIn[chairno][i])
        {
            int nShape = i / m_nLayoutMod;
            if (nShape != m_nDingQueCardType[chairno])
            {
                nShapeCount[nShape] += m_nCardsLayIn[chairno][i];
            }
        }
    }

    //吃碰杠的牌
    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            BOOL bPn = FALSE;
            for (int j = 0; j < m_PnGangCards[chairno].GetSize(); j++)
            {
                CARDS_UNIT cards_unit = m_PnGangCards[chairno][j];
                if (cardidx == m_pCalclator->MJ_CalcIndexByID(cards_unit.nCardIDs[0], m_dwGameFlags))
                {
                    bPn = TRUE;
                    break;
                }
            }

            if (!bPn)
            {
                int shape = cardidx / m_nLayoutMod;
                nShapeCount[shape] += 3;
            }
        }
    }
    for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_MnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = cardidx / m_nLayoutMod;
            nShapeCount[shape] += 3;
        }
    }
    for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_AnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = cardidx / m_nLayoutMod;
            nShapeCount[shape] += 3;
        }
    }
    //
    for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = cardidx / m_nLayoutMod;
            nShapeCount[shape] += 3;
        }
    }

    //计算最大花色数目
    nMaxShapeIndex = 0;
    int nMaxShapeCount = nShapeCount[0];
    for (i = 1; i < SHAPE_COUNT; i++)
    {
        if (nMaxShapeCount < nShapeCount[i])
        {
            nMaxShapeIndex = i;
            nMaxShapeCount = nShapeCount[i];
        }
    }

    LOG_DEBUG("Table:%d Chair:%d GetHandShapeScoreEx end, Begin:%ld, End:%ld, Time cost %ld\n", m_nTableNO, chairno, dwTickCount, GetTickCount(), GetTickCount() - dwTickCount);

    return nMaxShapeCount;
}

int CMyGameTable::GetWallCardnoByShape(int nShape)
{
    for (int i = 0; i < TOTAL_CARDS; i++)
    {
        int id = m_aryCard[i].nID;
        int status = m_aryCard[i].nStatus;
        int shape = m_aryCard[i].nShape;
        if (id >= 0 && status == 0 && shape == nShape)
        {
            return i;
        }
    }

    return INVALID_OBJECT_ID;
}

int CMyGameTable::GetWallCardnoByLayIndex(int nLayIndex)
{
    for (int i = 0; i < TOTAL_CARDS; i++)
    {
        int id = m_aryCard[i].nID;
        int status = m_aryCard[i].nStatus;
        int shape = m_aryCard[i].nShape;
        int value = m_aryCard[i].nValue;
        if (id >= 0 && status == 0 && (shape * m_nLayoutMod + value) == nLayIndex)
        {
            return i;
        }
    }

    return INVALID_OBJECT_ID;
}

int CMyGameTable::GetHandCardnoByLayIndex(int chairno, int nLayIndex)
{
    int startno = m_nCatchFrom;
    int lastno = startno + MJ_FIRST_CATCH_13 * TOTAL_CHAIRS + 1;
    for (int i = startno; i < lastno; i++)
    {
        int cardno = i % TOTAL_CARDS;
        int shape = m_aryCard[cardno].nShape;
        int value = m_aryCard[cardno].nValue;
        if (((shape * m_nLayoutMod + value) == nLayIndex) && (chairno == m_aryCard[cardno].nChairNO))
        {
            return cardno;
        }
    }

    return INVALID_OBJECT_ID;
}

int CMyGameTable::CalcBreakDeposit(int breakchair, int breakdouble, int& cut)
{
    int deposit_diff = 0;
    CPlayer* pPlayer = m_ptrPlayers[breakchair];

    if (NULL == pPlayer)
    {
        return deposit_diff;
    }

    if (m_HuPoint[breakchair] < 0)
    {
        breakdouble -= abs(m_HuPoint[breakchair]);
    }

    if (pPlayer->m_nDeposit < -breakdouble * m_nBaseDeposit) // 银子不够扣
    {
        deposit_diff = -pPlayer->m_nDeposit;
    }
    else
    {
        deposit_diff = breakdouble * m_nBaseDeposit;
    }
    if (m_nMaxTrans) // 有输赢限制
    {
        if (-deposit_diff > m_nMaxTrans)
        {
            deposit_diff = -m_nMaxTrans;
        }
    }
    cut = -deposit_diff * m_nCutRatio / 100;
    return deposit_diff;
}

BOOL CMyGameTable::ValidateHu(LPHU_CARD pHuCard)
{
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;
    int cardid = pHuCard->nCardID;

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }

    if (m_HuReady[chairno] == MJ_GIVE_UP)
    {
        return FALSE;
    }

    //同一张牌不能胡超过两次
    std::vector<HU_ITEM_INFO>::iterator it;
    for (it = m_vecHuItems[chairno].begin(); it != m_vecHuItems[chairno].end(); ++it)
    {
        if (it->nHuID == cardid)
        {
            if (m_ptrPlayers[chairno])
            {
                UwlLogFile(_T("ValidateHu same card second roomid:%d userid:%d cardid:%d nReserved:%d dwFlag:%d"), pHuCard->nRoomID, m_ptrPlayers[chairno]->m_nUserID, cardid, pHuCard->nReserved[0], pHuCard->dwFlags);
            }
            return FALSE;
        }
    }

    if (!IsXueLiuRoom())
    {
        if (GetHuItemCount(chairno) > 0)
        {
            return FALSE;    //已经胡牌
        }
    }

    DWORD flags = pHuCard->dwFlags;
    DWORD subflags = pHuCard->dwSubFlags;

    BOOL bn;
    if (IS_BIT_SET(flags, MJ_HU_QGNG))
    {
        // 抢杠
        if (IS_BIT_SET(subflags, MJ_GANG_MN))
        {
            // 抢明杠
            bn = ValidateHuQgng_Mn(chairno, cardchair, cardid);
            if (!bn)
            {
                bn = ValidateHuFang(chairno, cardchair, cardid);
                if (bn)//不能明杠但是可以防冲
                {
                    pHuCard->dwFlags = MJ_HU_FANG;
                }

                return bn;
            }
        }
        else if (IS_BIT_SET(subflags, MJ_GANG_PN))
        {
            // 抢碰杠
            return ValidateHuQgng_Pn(chairno, cardchair, cardid);
        }
    }
    else if (IS_BIT_SET(flags, MJ_HU_FANG)) // 放冲
    {
        return ValidateHuFang(chairno, cardchair, cardid);
    }
    else if (IS_BIT_SET(flags, MJ_HU_ZIMO))  // 自摸
    {
        return ValidateHuZimo(chairno, cardchair, cardid);
    }
    else {}
    return 0;
}

void CMyGameTable::ReSetThrowStutas(int first, int last)
{
    if (first == -1 || last == -1)
    {
        return;
    }

    if ((first >= TOTAL_CHAIRS) || (last >= TOTAL_CHAIRS))
    {
        return;
    }

    int chairno = GetNextChair(first);
    while (chairno != last && chairno != -1)
    {
        //摸牌的时候刷新跟牌记录
        memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));
        chairno = CTable::GetNextChair(chairno);
    }
}

int CMyGameTable::OnHu(LPHU_CARD pHuCard)
{
    ResetAIOpe();
    if (IsHuReady(pHuCard->nChairNO))
    {
        return 0;
    }

    //可以多次胡，后面填充结算结构
    //memset(m_nResults, 0, sizeof(m_nResults));            // 胡牌返回

    // 备份胡牌前分数信息
    HU_DETAILS huDetails[MJ_CHAIR_COUNT];       // 胡牌详细
    memcpy(huDetails, m_huDetails, sizeof(huDetails));  // 胡牌详细(包含胡牌前分数信息)

    int hu_count = 0;
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;
    int cardid = pHuCard->nCardID;

    DWORD flags = pHuCard->dwFlags;
    DWORD subflags = pHuCard->dwSubFlags;

    if (IS_BIT_SET(flags, MJ_HU_QGNG))
    {
        // 抢杠
        if (IS_BIT_SET(subflags, MJ_GANG_MN))
        {
            // 抢明杠
            hu_count = OnHuQgng_Mn(chairno, cardchair, cardid);
        }
        else if (IS_BIT_SET(subflags, MJ_GANG_PN))
        {
            // 抢碰杠
            hu_count = OnHuQgng_Pn(chairno, cardchair, cardid);
        }
        else if (IS_BIT_SET(subflags, MJ_GANG_AN))
        {
            // 抢暗杠
            hu_count = OnHuQgng_An(chairno, cardchair, cardid);
        }
    }
    else if (IS_BIT_SET(flags, MJ_HU_FANG))
    {
        // 放冲
        hu_count = OnHuFang(chairno, cardchair, cardid);
    }
    else if (IS_BIT_SET(flags, MJ_HU_ZIMO))
    {
        // 自摸
        hu_count = OnHuZimo(chairno, cardchair, cardid);
    }
    else {}

    if (hu_count > 0)
    {
        // 胡牌成功
        //CancelSituationOfGang();
        //CancelSituationInCard();
    }
    else
    {
        // 还原胡牌前分数信息
        memcpy(m_huDetails, huDetails, sizeof(m_huDetails));    // 胡牌详细(包含胡牌前分数信息)
    }
    return hu_count;
}

int CMyGameTable::OnHuFang(int chairno, int cardchair, int cardid)
{
    ResetAIOpe();
    int hu_count = 0;
    m_nResults[chairno] = CanHu(chairno, cardid, m_huDetails[chairno], MJ_HU_FANG);
    if (m_nResults[chairno] > 0)
    {
        LOG_DEBUG("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@7777777777777777777chairno:%d, %ld", chairno, m_HuReady[chairno]);
        m_HuReady[chairno] = MJ_HU_FANG;
        m_HuMJID[chairno] = cardid;

        hu_count++;
        m_nHuCount++;

        // 胡牌成功
        m_nLoseChair = cardchair;       // 放冲者位置
        m_nHuCount = hu_count;      // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID
        m_nHuChair = chairno;
    }
    return hu_count;
}

int CMyGameTable::OnHuZimo(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;
    m_nResults[chairno] = CanHu(chairno, cardid, m_huDetails[chairno], MJ_HU_ZIMO);
    if (m_nResults[chairno] > 0)
    {
        m_HuReady[chairno] = MJ_HU_ZIMO;
        if (m_bNewRuleOpen && (m_nHeadTaken + m_nTailTaken) >= m_nTotalCards)
        {
            m_HuReady[chairno] = MJ_HU_HDLY;
            m_nEndGameFlag |= MJ_HU_HDLY;
        }
        m_HuMJID[chairno] = cardid;

        hu_count++;
        m_nHuCount++;
        m_nHuChair = chairno;
        m_nHuCard = cardid;             // 胡牌ID
    }
    return hu_count;
}

BOOL CMyGameTable::ReplaceAutoThrow(LPTHROW_CARDS pThrowCards)
{
    XygInitChairCards(pThrowCards->nCardIDs, MAX_CARDS_PER_CHAIR);          // 打出的牌(ID)

    pThrowCards->nCardsCount = 1; // 牌张数
    pThrowCards->dwCardsType = 1; // 牌型

    //保证出牌不会花
    int cardid = INVALID_OBJECT_ID;
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nChairNO == pThrowCards->nChairNO)
        {
            if (CS_CAUGHT == m_aryCard[i].nStatus
                && !m_pCalclator->MJ_IsHuaEx(m_aryCard[i].nID, m_nJokerID, m_nJokerID2, m_dwGameFlags))
            {
                cardid = m_aryCard[i].nID;
                break;
            }
        }
    }
    if (cardid < 0)
    {
        pThrowCards->nCardIDs[0] = GetFirstCardOfChair(pThrowCards->nChairNO);
    }
    else
    {
        pThrowCards->nCardIDs[0] = cardid;
    }

    return TRUE;
}

int CMyGameTable::CancelSituationOfGang()
{
    __super::CancelSituationOfGang();
    m_bLastGang = FALSE;
    return 1;
}

BOOL CMyGameTable::calcDrawBack(int nOldDeposits[], int nDepositDiffs[])
{
    BOOL bNeedDrawBack[TOTAL_CHAIRS];                   //是否需要退税
    ZeroMemory(bNeedDrawBack, sizeof(bNeedDrawBack));
    BOOL bIdlePlayer[TOTAL_CHAIRS];                     //是否空闲玩家
    ZeroMemory(bIdlePlayer, sizeof(bIdlePlayer));
    int nMutilDeposits[TOTAL_CHAIRS][TOTAL_CHAIRS];     //退税玩家对应需要给其它玩家退多少银子
    ZeroMemory(nMutilDeposits, sizeof(nMutilDeposits));
    int nMutilFanshu[TOTAL_CHAIRS][TOTAL_CHAIRS];       //番数
    ZeroMemory(nMutilFanshu, sizeof(nMutilFanshu));
    int nDrawbackCount = 0;
    int nHuTingCount = 0;                               //胡听牌玩家数

    int i = 0;
    //未听牌玩家
    /*int score[TOTAL_CHAIRS];
    memset(score, 0, sizeof(score));
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(HU_DETAILS));
    for (i = 0; i < m_nTotalChairs; i++)
    {
    score[i] = CalcTing(i, huDetails);
    }*/


    //查找需要退税的玩家
    for (i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (NULL == m_ptrPlayers[i])
        {
            bIdlePlayer[i] = TRUE;
        }
        else if (m_ptrPlayers[i]->m_bIdlePlayer)
        {
            bIdlePlayer[i] = TRUE;
        }
        if (m_HuReady[i] == MJ_HU_TING)
        {
            nHuTingCount++;
        }
        for (int j = 0; j < TOTAL_CHAIRS; j++)
        {
            if (m_stCheckInfo[i].nDaJiaoPoint[j] < 0 || m_stCheckInfo[i].nHuaZhuPoint[j] < 0 || m_stEndGameCheckInfo.nDajiaoPoint[i] < 0)
            {
                bNeedDrawBack[i] = TRUE;
                nDrawbackCount++;
                break;
            }
        }
    }
    if (nDrawbackCount <= 0 || nDrawbackCount >= m_nTotalChairs)    //不需要退税
    {
        return FALSE;
    }

    //计算退税的钱
    for (i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (bIdlePlayer[i] || bNeedDrawBack[i])
        {
            continue;
        }
        std::vector<HU_ITEM_INFO>::iterator  iter = m_vecHuItems[i].begin();
        for (; iter != m_vecHuItems[i].end(); ++iter)
        {
            HU_ITEM_INFO info = *iter;
            if (info.nHuDeposits < 0 && (info.nHuFlag == MJ_HU_MNGANG || info.nHuFlag == MJ_HU_ANGANG || info.nHuFlag == MJ_HU_PNGANG))
            {
                for (int j = 0; j < TOTAL_CHAIRS; j++)
                {
                    if (bIdlePlayer[j] || i == j)
                    {
                        continue;
                    }
                    if (info.nRelateChair[j] != INVALID_OBJECT_ID && bNeedDrawBack[j] && nOldDeposits[j] > 0)
                    {
                        nMutilDeposits[j][i] += info.nHuDeposits;   //未听牌或花猪玩家应退税银子
                        nMutilFanshu[j][i] += info.nHuFan;
                        nDepositDiffs[j] += info.nHuDeposits;       //未听牌或花猪玩家应退税银子
                    }
                }
            }
        }
    }

    //校正银子
    for (i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (!bNeedDrawBack[i] || nOldDeposits[i] <= 0 || nDepositDiffs[i] == 0)
        {
            continue;
        }

        m_nEndGameFlag |= MJ_HU_DRAWBACK;
        if ((nOldDeposits[i] + nDepositDiffs[i]) < 0)       //银子不足
        {
            for (int j = 0; j < TOTAL_CHAIRS; j++)      //i需要给j退税
            {
                if (i == j || nMutilDeposits[i][j] == 0)
                {
                    continue;
                }
                nMutilDeposits[i][j] = floor(nOldDeposits[i] * nMutilDeposits[i][j] * (-1) / nDepositDiffs[i]);
                m_stCheckInfo[i].nDrawbackPoint[j] = -1;
                m_stCheckInfo[i].nDrawbackDeposit[j] = nMutilDeposits[i][j];
                m_stCheckInfo[j].nDrawbackPoint[i] = 1;
                m_stCheckInfo[j].nDrawbackDeposit[i] = nMutilDeposits[i][j] * (-1);
                nDepositDiffs[j] += nMutilDeposits[i][j] * (-1);
                //添加获得退税记录
                HU_ITEM_INFO infoAdd;
                memset(&infoAdd, 0, sizeof(infoAdd));
                int chairNo = 0;
                for (chairNo = 0; chairNo < TOTAL_CHAIRS; chairNo++)
                {
                    infoAdd.nRelateChair[chairNo] = INVALID_OBJECT_ID;
                }
                infoAdd.nHuDeposits = nMutilDeposits[i][j] * (-1);
                infoAdd.bWin = TRUE;
                infoAdd.bSend = FALSE;
                infoAdd.nHuFlag = MJ_HU_DRAWBACK;
                infoAdd.nHuFan = nMutilFanshu[i][j] * (-1);
                infoAdd.nRelateChair[i] = i;
                m_vecHuItems[j].push_back(infoAdd);

                //添加退税记录
                HU_ITEM_INFO HuInfo;
                memset(&HuInfo, 0, sizeof(HuInfo));
                for (chairNo = 0; chairNo < TOTAL_CHAIRS; chairNo++)
                {
                    HuInfo.nRelateChair[chairNo] = INVALID_OBJECT_ID;
                }
                HuInfo.nHuDeposits = nMutilDeposits[i][j];
                HuInfo.bWin = FALSE;
                infoAdd.bSend = FALSE;
                HuInfo.nHuFlag = MJ_HU_DRAWBACK;
                HuInfo.nHuFan = nMutilFanshu[i][j];
                HuInfo.nRelateChair[j] = j;
                m_vecHuItems[i].push_back(HuInfo);
            }
            nDepositDiffs[i] = nOldDeposits[i] * (-1);
        }
        else
        {
            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                if (i == j || nMutilDeposits[i][j] == 0)
                {
                    continue;
                }
                m_stCheckInfo[i].nDrawbackPoint[j] = -1;
                m_stCheckInfo[i].nDrawbackDeposit[j] = nMutilDeposits[i][j];
                m_stCheckInfo[j].nDrawbackPoint[i] = 1;
                m_stCheckInfo[j].nDrawbackDeposit[i] = nMutilDeposits[i][j] * (-1);
                nDepositDiffs[j] += nMutilDeposits[i][j] * (-1);
                //添加获得退税记录
                HU_ITEM_INFO infoAdd;
                memset(&infoAdd, 0, sizeof(infoAdd));
                int chairNo = 0;
                for (chairNo = 0; chairNo < TOTAL_CHAIRS; chairNo++)
                {
                    infoAdd.nRelateChair[chairNo] = INVALID_OBJECT_ID;
                }
                infoAdd.nHuDeposits = nMutilDeposits[i][j] * (-1);
                infoAdd.bWin = TRUE;
                infoAdd.bSend = FALSE;
                infoAdd.nHuFlag = MJ_HU_DRAWBACK;
                infoAdd.nHuFan = nMutilFanshu[i][j] * (-1);
                infoAdd.nRelateChair[i] = i;
                m_vecHuItems[j].push_back(infoAdd);

                //添加退税记录
                HU_ITEM_INFO HuInfo;
                memset(&HuInfo, 0, sizeof(HuInfo));
                for (chairNo = 0; chairNo < TOTAL_CHAIRS; chairNo++)
                {
                    HuInfo.nRelateChair[chairNo] = INVALID_OBJECT_ID;
                }
                HuInfo.nHuDeposits = nMutilDeposits[i][j];
                HuInfo.bWin = FALSE;
                infoAdd.bSend = FALSE;
                HuInfo.nHuFlag = MJ_HU_DRAWBACK;
                HuInfo.nHuFan = nMutilFanshu[i][j];
                HuInfo.nRelateChair[j] = j;
                m_vecHuItems[i].push_back(HuInfo);
            }
        }
    }
    return TRUE;
}

void CMyGameTable::AddNewCheckItem()
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        for (int j = 0; j < m_nTotalChairs; j++)
        {
            //花猪
            if (m_stCheckInfo[i].nHuaZhuPoint[j] != 0)
            {
                HU_ITEM_INFO stHuItem;
                ZeroMemory(&stHuItem, sizeof(stHuItem));
                stHuItem.nHuFlag = MJ_HU_HUAZHU;
                stHuItem.nHuFan = m_stCheckInfo[i].nHuaZhuPoint[j];
                stHuItem.nHuDeposits = m_stCheckInfo[i].nHuaZhuDeposit[j];
                stHuItem.bWin = stHuItem.nHuFan > 0 ? TRUE : FALSE;

                for (int k = 0; k < m_nTotalChairs; k++)
                {
                    if (k == j)
                    {
                        stHuItem.nRelateChair[k] = j;
                    }
                    else
                    {
                        stHuItem.nRelateChair[k] = INVALID_OBJECT_ID;
                    }
                }

                m_vecHuItems[i].push_back(stHuItem);
            }

            //大叫
            if (m_stCheckInfo[i].nDaJiaoPoint[j] != 0)
            {
                HU_ITEM_INFO stHuItem;
                ZeroMemory(&stHuItem, sizeof(stHuItem));
                stHuItem.nHuFlag = MJ_HU_TING;
                stHuItem.nHuFan = m_stCheckInfo[i].nDaJiaoPoint[j];
                stHuItem.nHuDeposits = m_stCheckInfo[i].nDaJiaoDeposit[j];
                stHuItem.bWin = stHuItem.nHuFan > 0 ? TRUE : FALSE;

                for (int k = 0; k < m_nTotalChairs; k++)
                {
                    if (k == j)
                    {
                        stHuItem.nRelateChair[k] = j;
                    }
                    else
                    {
                        stHuItem.nRelateChair[k] = INVALID_OBJECT_ID;
                    }
                }

                m_vecHuItems[i].push_back(stHuItem);
            }
        }
    }
}

void CMyGameTable::FillUpGameWinCheckInfos(void* pData, int nLen, int chairNo)
{
    GAMEEND_CHECK_INFO info;
    memset(&info, 0, sizeof(info));
    //addEndGameCheckInfos();
    m_stEndGameCheckInfo.nFlag = m_nEndGameFlag;
    if (m_bNewRuleOpen)
    {
        memcpy(&info, &m_stEndGameCheckInfo, sizeof(info));
    }
    LPGAMEEND_CHECK_INFO pInfo = LPGAMEEND_CHECK_INFO((PBYTE)pData + nLen);
    memcpy(pInfo, &info, sizeof(GAMEEND_CHECK_INFO));
}

void CMyGameTable::FillupGameWinStartGamePlayerInfo(void* pData, int nLen)
{

}

int CMyGameTable::ShouldReConsPengWait(LPPENG_CARD pPengCard)
{
    m_nPengWait = pPengCard->nChairNO;

    return __super::ShouldReConsPengWait(pPengCard);
}

int CMyGameTable::CatchCard(int chairno, BOOL& bBuHua)
{
    if (chairno < 0 || chairno >= m_nTotalChairs)
    {
        return INVALID_OBJECT_ID;
    }
    ResetAIOpe();
    m_bLastGang = FALSE;
    m_nLastGangNO = -1;
    if (IS_BIT_SET(m_dwGangAfterCatch, MJ_GANG_PN))
    {
        m_dwGangAfterCatch = 0;
    }
    else
    {
        m_nGangKaiCount = 0;
    }

    CancelSituationOfGang();
    CancelSituationInCard();

    if (OnCatchCardFail(chairno))
    {
        // 没牌抓了啦！
        return INVALID_OBJECT_ID;
    }
    else if (m_nCurrentCatch == m_nJokerNO)
    {
        // 抓到翻出的财神
        m_nCatchCount[chairno]++;
        return m_nJokerNO;
    }
    if (0 != m_aryCard[m_nCurrentCatch].nStatus)
    {
        // 牌已被摸
        m_nCurrentCatch = (m_nCurrentCatch + 1) % m_nTotalCards;
    }
    int id = m_aryCard[m_nCurrentCatch].nID;
    int status = m_aryCard[m_nCurrentCatch].nStatus;
    if (id >= 0 && status == 0)
    {

        MakeCardForCatch(chairno, m_nCurrentCatch);

        // 此牌可抓
        m_aryCard[m_nCurrentCatch].nStatus = CS_CAUGHT;
        m_aryCard[m_nCurrentCatch].nChairNO = chairno;
        int shape = m_aryCard[m_nCurrentCatch].nShape;
        int value = m_aryCard[m_nCurrentCatch].nValue;
        m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
        m_nHeadTaken++;
        int current_catch = m_nCurrentCatch;
        m_nCurrentCatch = (m_nCurrentCatch + 1) % m_nTotalCards;
        m_nCatchCount[chairno]++;

        m_nCurrentCard = m_aryCard[current_catch].nID;
        m_nCurrentOpeCard = m_aryCard[current_catch].nID;

        if (IsHua(m_nCurrentCard))
        {
            if (IS_BIT_SET(m_dwGameFlags2, MJ_AUTO_BUHUA))
            {
                bBuHua = TRUE;
                HUA_CARD huaCard;
                memset(&huaCard, -1, sizeof(HUA_CARD));
                huaCard.nCardID = m_nCurrentCard;
                huaCard.nChairNO = chairno;
                OnHua(&huaCard);
                SetStatusOnThrow();
                int nCardID = GetGangCard(chairno, bBuHua);
                return GetCardNO(nCardID);
            }
        }

        //xueliu add begin
        m_nLatestedGetMJIndex[chairno] = current_catch;
        //xueliu add end

        return current_catch;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMyGameTable::OnPnGang(LPGANG_CARD pGangCard)
{
    ResetAIOpe();
    m_dwGangAfterCatch = MJ_GANG_PN;
    return __super::OnPnGang(pGangCard);
}


int CMyGameTable::ValidateThrow(int chairno, int nCardsOut[], int nOutCount, DWORD dwCardsType, int nValidIDs[])
{
    if (IsXueLiuRoom() && (m_HuReady[chairno] > 0 && m_HuReady[chairno] != MJ_GIVE_UP))
    {
        // 出牌强验证，血流半托管模式只能出抓到的牌
        if (m_nCurrentCard != nCardsOut[0])
        {
            UwlLogFile(_T("ValidateThrow() return 0.  baoting judge error"));
            return 0;
        }
    }
    return __super::ValidateThrow(chairno, nCardsOut, nOutCount, dwCardsType, nValidIDs);
}

int CMyGameTable::Restart(int& errchair, int deposit_mult, int deposit_min,
    int fee_ratio, int max_trans, int cut_ratio, int deposit_logdb,
    int fee_mode, int fee_value, int base_silver, int max_bouttime,
    int base_score, int score_min, int score_max,
    int max_user_bout, int max_table_bout,
    int min_player_count/*可变桌椅最低要求玩家数*/,
    int fee_tenthousandth/*新茶水费收取万分比*/, int fee_minimum/*新茶水费起征点*/)
{
    int error = __super::Restart(errchair, deposit_mult, deposit_min, fee_ratio,
            max_trans, cut_ratio, deposit_logdb,
            fee_mode, fee_value, base_silver, max_bouttime,
            base_score, score_min, score_max,
            max_user_bout, max_table_bout,
            min_player_count, fee_tenthousandth, fee_minimum);

    RecordRobotOnStart();       //记录开始游戏时，玩家是否是机器人
    return error;
}

//重载 川麻可变桌椅，加个校验保险
BOOL CMyGameTable::IsRoboter(int chairno)
{
    CPlayer* pPlayer = m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return FALSE;
    }

    return IS_BIT_SET(pPlayer->m_nUserType, USER_TYPE_ROBOT);
}

void CMyGameTable::RecordRobotOnStart()
{
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (IsRoboter(i))
        {
            m_bIsRobot[i] = TRUE;
        }
    }
}


//robot operate
void CMyGameTable::ResetAIOpe()
{
    m_nAIOperateID = -1;
    m_nAIOperateCardID = -1;
    m_nAIOperateChairNO = -1;
    m_nAIOperateCardChairNO = -1;
    memset(m_nAIOperateBaseCards, -1, sizeof(m_nAIOperateBaseCards));
}

void CMyGameTable::GetAIBaseCardsID()
{
    int handCardIDs[CHAIR_CARDS] = { -1 };
    int nCardsLayIn[MAX_CARDS_PER_CHAIR] = { 0 };
    XygInitChairCards(handCardIDs, CHAIR_CARDS);
    GetChairCards(m_nAIOperateChairNO, handCardIDs, CHAIR_CARDS);
    int index = GetCardIndex(m_nAIOperateCardID);
    int tempindex = 0;
    int cardCount = 0;
    for (int i = 0; i < CHAIR_CARDS; i++)
    {
        if (INVALID_OBJECT_ID == handCardIDs[i])
        {
            continue;
        }

        tempindex = GetCardIndex(handCardIDs[i]);
        nCardsLayIn[tempindex]++;
        cardCount++;
    }

    if (m_nAIOperateID == LOCAL_GAME_MSG_PENG)
    {
        if (nCardsLayIn[index] >= 2)
        {
            int count = 0;
            for (int i = 0; i < cardCount; i++)
            {
                if (handCardIDs[i] > -1)
                {
                    int shape = CalculateCardShape(handCardIDs[i]);
                    int value = CalculateCardValue(handCardIDs[i]);
                    if ((shape * MJ_LAYOUT_MOD + value) == index)
                    {
                        m_nAIOperateBaseCards[count++] = handCardIDs[i];
                    }
                }
            }
        }
        else
        {
            m_nAIOperateID = -1;
        }
    }

    if (m_nAIOperateID == LOCAL_GAME_MSG_MN_GANG || m_nAIOperateID == LOCAL_GAME_MSG_AN_GANG)
    {
        if (nCardsLayIn[index] >= 3)
        {
            int count = 0;
            for (int i = 0; i < cardCount; i++)
            {
                if (handCardIDs[i] > -1)
                {
                    int shape = CalculateCardShape(handCardIDs[i]);
                    int value = CalculateCardValue(handCardIDs[i]);
                    if ((shape * MJ_LAYOUT_MOD + value) == index)
                    {
                        m_nAIOperateBaseCards[count++] = handCardIDs[i];
                    }
                }
            }
        }
        else
        {
            m_nAIOperateID = -1;
        }
    }

    if (m_nAIOperateID == LOCAL_GAME_MSG_PN_GANG)
    {
        for (int i = 0; i < m_PengCards[m_nAIOperateChairNO].GetSize(); i++)
        {
            CARDS_UNIT cards_unit = m_PengCards[m_nAIOperateChairNO][i];
            int cardid = cards_unit.nCardIDs[0];
            int shape = CalculateCardShape(cardid);
            int value = CalculateCardValue(cardid);
            if ((shape * MJ_LAYOUT_MOD + value) == index)
            {
                m_nAIOperateBaseCards[0] = cards_unit.nCardIDs[0];
                m_nAIOperateBaseCards[1] = cards_unit.nCardIDs[1];
                m_nAIOperateBaseCards[2] = cards_unit.nCardIDs[2];
            }
        }
        if (m_nAIOperateBaseCards[0] == -1)
        {
            m_nAIOperateID = -1;
        }
    }
}
BOOL CMyGameTable::IsGameTimerValid(LPGAME_TIMER pGameTimer)
{
    LOG_DEBUG("IsGameTimerValid44444444444444444");
    int nChairNO = pGameTimer->nChairNO;
    if (nChairNO != GetCurrentChair())
    {
        return FALSE;
    }
    LOG_DEBUG("IsGameTimerValid55555555555555555");
    if (!ValidateChair(nChairNO))
    {
        LOG_DEBUG("IsGameTimerValid111111111111111111");
        UwlTrace("Is GameTimerValid return false, nChairNO = %d", nChairNO);
        return FALSE;
    }

    if (!IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME))//游戏已经结束
    {
        LOG_DEBUG("IsGameTimerValid2222222222222");
        UwlTrace("Is GameTimerValid return false, game timer status=%x", pGameTimer->dwStatus);
        return FALSE;
    }

    if (!IS_BIT_SET(m_dwStatus, pGameTimer->dwStatus))//游戏状态不匹配
    {
        LOG_DEBUG("IsGameTimerValid3333333333333");
        UwlTrace("Is GameTimerValid return false, table status=%x,  game timer status=%x", m_dwStatus, pGameTimer->dwStatus);
        return FALSE;
    }

    return TRUE;
}

void CMyGameTable::writeLog()
{
    for (int i = 0; i < 4; i++)
    {
        int nChairCards[32] = {-1};

        GetChairCards(i, nChairCards, CHAIR_CARDS); // 填充牌的ID方阵
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_STARTHANDCARDS***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardids:%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s"), m_nRoomID, m_nTableNO,
            i, m_ptrPlayers[i]->m_nUserID, RobotBoutLog(nChairCards[0]), RobotBoutLog(nChairCards[1]), RobotBoutLog(nChairCards[2]), RobotBoutLog(nChairCards[3]),
            RobotBoutLog(nChairCards[4]), RobotBoutLog(nChairCards[5]), RobotBoutLog(nChairCards[6]), RobotBoutLog(nChairCards[7]), RobotBoutLog(nChairCards[8]), RobotBoutLog(nChairCards[9]),
            RobotBoutLog(nChairCards[10]), RobotBoutLog(nChairCards[11]), RobotBoutLog(nChairCards[12]), RobotBoutLog(nChairCards[13]));
    }
}

BOOL CMyGameTable::IsOperateTimeOver()
{
    if (GetTickCount() - m_dwActionStart >= m_dwWaitOperateTick)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}


void CMyGameTable::CreateUniqueID()
{
    m_nUniqueID = siphash::siphash((uint8_t*)m_szSerialNO, MAX_SERIALNO_LEN, (uint8_t*)UNIQUEID_KEY_NAME);
}

int CMyGameTable::GetUniqueID()
{
    return m_nUniqueID;
}

std::string getMakeCardPlayBoutStrNameByRoomID(char* sConfig, int nIndex, int nRoomId)
{
    std::string configName = "remainCount";
    configName.append(to_string(nIndex));
    configName.append("_");
    configName.append(to_string(nRoomId));

    return configName;
}
void CMyGameTable::ReadMakeCardProb()
{
    if (!MakeCardIntervene())
    {
        return;
    }

    CString szIniFile = GetMyINIMakeCardName();
    PROB tmpProp;
    int tmpPlayBoutRemainCount = -1;
    // 做牌干预概率配置最多 五条
    for (int i = 0; i < 5; i++)
    {
        int tmpIndex = i + 1;

        // 做牌干预 普通牌局
        // 要支持配房间号
        memset(&tmpProp, -1, sizeof(PROB));

        tmpPlayBoutRemainCount = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getMakeCardPlayBoutStrNameByRoomID("remainCount", tmpIndex, m_nRoomID).c_str()), -1, szIniFile);
        if (tmpPlayBoutRemainCount != -1)
        {
            tmpProp.nRemainCout = tmpPlayBoutRemainCount;
            tmpProp.nNotDingQueCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getMakeCardPlayBoutStrNameByRoomID("notDingQueCardProb", tmpIndex, m_nRoomID).c_str()), -1, szIniFile);
            m_stMakeCardProb.vPlayBoutCatch.push_back(tmpProp);
        }

        //做牌干预 机器人牌局 用户未上听
        memset(&tmpProp, -1, sizeof(PROB));
        tmpPlayBoutRemainCount = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("robotRemainCount", tmpIndex).c_str()), -1, szIniFile);
        if (tmpPlayBoutRemainCount != -1)
        {
            tmpProp.nRemainCout = tmpPlayBoutRemainCount;
            tmpProp.nGangCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("RobotGang", tmpIndex).c_str()), -1, szIniFile);
            tmpProp.nPengCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("RobotPeng", tmpIndex).c_str()), -1, szIniFile);
            tmpProp.nNotDingQueCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("robotNotDingQueCardProb", tmpIndex).c_str()), -1, szIniFile);
            m_stMakeCardProb.vRobotBoutCatch.push_back(tmpProp);
        }
        //做牌干预 机器人牌局 用户上听
        tmpPlayBoutRemainCount = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("tingRemainCount", tmpIndex).c_str()), -1, szIniFile);
        if (tmpPlayBoutRemainCount != -1)
        {
            tmpProp.nRemainCout = tmpPlayBoutRemainCount;
            tmpProp.nNotDingQueCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("tingNotDingQueCardProb", tmpIndex).c_str()), -1, szIniFile);
            tmpProp.nHuCardProb = GetPrivateProfileInt(_T("PlayBoutCatch"), _T(getConfigNameByRoomID("tingHuProb", tmpIndex).c_str()), -1, szIniFile);
            m_stMakeCardProb.vRobotBoutTingCatch.push_back(tmpProp);
        }
        //机器人出牌 用户未上听
        tmpPlayBoutRemainCount = GetPrivateProfileInt(_T("RobotBoutThrow"), _T(getConfigNameByRoomID("remainCount", tmpIndex).c_str()), -1, szIniFile);
        if (tmpPlayBoutRemainCount != -1)
        {
            tmpProp.nRemainCout = tmpPlayBoutRemainCount;
            tmpProp.nGangCardProb = GetPrivateProfileInt(_T("RobotBoutThrow"), _T(getConfigNameByRoomID("gangProb", tmpIndex).c_str()), -1, szIniFile);
            tmpProp.nPengCardProb = GetPrivateProfileInt(_T("RobotBoutThrow"), _T(getConfigNameByRoomID("pengProb", tmpIndex).c_str()), -1, szIniFile);
            m_stMakeCardProb.vRobotBoutThrow.push_back(tmpProp);
        }

        tmpPlayBoutRemainCount = GetPrivateProfileInt(_T("RobotBoutThrow"), _T(getConfigNameByRoomID("tingRemainCount", tmpIndex).c_str()), -1, szIniFile);
        if (tmpPlayBoutRemainCount != -1)
        {
            tmpProp.nRemainCout = tmpPlayBoutRemainCount;
            tmpProp.nHuCardProb = GetPrivateProfileInt(_T("RobotBoutThrow"), _T(getConfigNameByRoomID("tingHuProb", tmpIndex).c_str()), -1, szIniFile);
            m_stMakeCardProb.vRobotBoutTingThrow.push_back(tmpProp);
        }
    }
}

CString CMyGameTable::GetMyINIMakeCardName()
{
    CString str = _T("");

    // get exefile fullpath
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    // get test file fullpath
    TCHAR szTstFile[MAX_PATH];
    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szTstFile);
    lstrcat(szTstFile, "makecard.ini");

    str.Format(_T("%s"), szTstFile);
    return str;
}

BOOL CMyGameTable::IsRobotBout()
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (IsRoboter(i))
        {
            return TRUE;
        }
    }
    return FALSE;
}


int CMyGameTable::GetRobotNumer()
{
    int nRobotNum = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (IsRoboter(i))
        {
            nRobotNum++;
        }
    }
    return nRobotNum;
}

int CMyGameTable::GetRobotBoutPlayerNo()
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (!IsRoboter(i))
        {
            return i;
        }
    }
    return -1;
}

int CMyGameTable::GetShuffleRandomValue(int nMaxNum)
{
    nMaxNum = nMaxNum + 1;
    std::vector<int> v;
    for (int i = 0; i < nMaxNum; ++i)
    {
        v.push_back(i);
    }
    std::default_random_engine e(std::random_device{}());
    std::shuffle(v.begin(), v.end(), e);  //使用随机生成器g对元素[first, last)可行交换的容器内部元素进行随机排列

    LOG_DEBUG("GetShuffleRandomValue value[%d]", v[1]);
    return v[1];
}

void CMyGameTable::MakeCardForCatchIntervene(int chairno, int catchno)
{
    // 新的做牌干预 开关未开 则return
    if (!MakeCardIntervene())
    {
        return;
    }

    // 老的做牌干预生效,则跳过新的做牌干预
    if (m_stMakeCardInfo[chairno].nMakeCatch > 0)
    {
        LOG_DEBUG("old makecard active MakeCardForCatchIntervene return");
        return;
    }

    LOG_DEBUG("MakeCardForCatchIntervene come in");
    BOOL bRobotBout = IsRobotBout();
    PROB tmpProb;
    memset(&tmpProb, -1, sizeof(tmpProb));

    if (m_ptrPlayers[chairno])
    {
        if (bRobotBout && m_bvalidRobotBout)
        {
            if (!IsRoboter(chairno))
            {
                if (m_vRobotBoutPlayerCardIDs.size() > 0)   // 玩家上听
                {
                    tmpProb = GetRemainCoutInterveneProb(INTERVENE_CATCH_ROBOTTING, m_stMakeCardProb.vRobotBoutTingCatch);
                    MakeCardForRobotCatch(chairno, catchno, INTERVENE_CATCH_ROBOTTING, tmpProb);
                }
                else
                {
                    tmpProb = GetRemainCoutInterveneProb(INTERVENE_CATCH_ROBOT, m_stMakeCardProb.vRobotBoutCatch);
                    MakeCardForRobotCatch(chairno, catchno, INTERVENE_CATCH_ROBOT, tmpProb);
                }
            }
        }
        else
        {
            tmpProb = GetRemainCoutInterveneProb(INTERVENE_CATCH_BASE, m_stMakeCardProb.vPlayBoutCatch);
            int nCatchProp = tmpProb.nNotDingQueCardProb;
            int nRandomValue = GetShuffleRandomValue(100);
            if (nRandomValue < nCatchProp)
            {
                int nToChangeno = -1;
                int nDingQueShape = m_nDingQueCardType[chairno];
                int nMakeCardShape = -1;
                int nRandom = -1;
                while (nMakeCardShape == -1)
                {
                    nRandom = GetShuffleRandomValue(2);
                    if (nRandom != nDingQueShape)
                    {
                        nMakeCardShape = nRandom;
                    }
                }

                //交换
                nToChangeno = GetWallCardnoByShape(nMakeCardShape);

                LOG_DEBUG("MakeCardForCatchIntervene shape chairno[%d] catchno[%d] nShape[%d] nToChangeno[%d]", chairno, catchno, nMakeCardShape, nToChangeno);
                // 若随机到的非定缺的花色 数量为0  找另外一种花色
                for (int nShape = 0; nShape < SHAPE_COUNT; nShape++)
                {
                    if (nToChangeno != -1)
                    {
                        break;
                    }

                    if (nShape != nMakeCardShape && nShape != nDingQueShape)
                    {
                        nToChangeno = GetWallCardnoByShape(nShape);
                        LOG_DEBUG("MakeCardForCatchIntervene playerbout else shape chairno[%d] catchno[%d] nShape[%d] nToChangeno[%d]", chairno, catchno, nMakeCardShape, nToChangeno);
                    }
                }
                if (nToChangeno != -1 && catchno != -1)
                {
                    ExchangeCatchAndWallCard(chairno, catchno, nToChangeno);
                    LOG_DEBUG("MakeCardForCatchIntervene chairno[%d] catchno[%d] nToChangeno[%d]", chairno, catchno, nToChangeno);
                }
            }
        }
    }
}

void CMyGameTable::MakeCardForRobotCatch(int chairno, int catchno, INTERVENE_TYPE enInterveneType, PROB prob)
{
    int nRandomValue = GetShuffleRandomValue(100);
    LOG_DEBUG("MakeCardForRoBotCatch come in chairno[%d]", chairno);
    int nToChangeno = -1;
    int nDingQueShape = m_nDingQueCardType[chairno];
    if (enInterveneType == INTERVENE_CATCH_ROBOT)
    {
        if (nRandomValue <= prob.nGangCardProb)
        {
            // 先找杠的牌
            for (int i = 0; i < LAYOUT_XZMO; i++)
            {
                if (nToChangeno != -1)
                {
                    break;
                }
                int nTmpShape = m_pCalclator->MJ_CalculateCardShapeByIndex(i, 0);
                if (m_nCardsLayIn[chairno][i] == 3 && nTmpShape != nDingQueShape)
                {
                    nToChangeno = GetWallCardnoByLayIndex(i);
                    LOG_DEBUG("MakeCardForRoBotCatch gangcard chairno[%d] nToChangeno[%d]", chairno, nToChangeno);
                }
            }
        }

        if (nRandomValue <= prob.nPengCardProb)
        {
            // 再找碰的牌
            for (int i = 0; i < LAYOUT_XZMO; i++)
            {
                if (nToChangeno != -1)
                {
                    break;
                }
                int nTmpShape = m_pCalclator->MJ_CalculateCardShapeByIndex(i, 0);
                if (m_nCardsLayIn[chairno][i] == 2 && nTmpShape != nDingQueShape)
                {
                    nToChangeno = GetWallCardnoByLayIndex(i);
                    LOG_DEBUG("MakeCardForRoBotCatch pengcard chairno[%d] nToChangeno[%d]", chairno, nToChangeno);
                }
            }
        }

        if (nRandomValue <= prob.nNotDingQueCardProb)
        {
            // 再找定缺的牌
            if (nToChangeno == -1)
            {
                int nMakeCardShape = -1;
                int nRandom = -1;
                while (nMakeCardShape == -1)
                {
                    nRandom = GetShuffleRandomValue(2);
                    if (nRandom != nDingQueShape)
                    {
                        nMakeCardShape = nRandom;
                    }
                }

                //交换
                nToChangeno = GetWallCardnoByShape(nMakeCardShape);
                LOG_DEBUG("MakeCardForRoBotCatch dingquecard chairno[%d] nToChangeno[%d] nMakeCardShape[%d]", chairno, nToChangeno, nMakeCardShape);
                // 若随机到的非定缺的花色 数量为0  找另外一种花色
                for (int nShape = 0; nShape < SHAPE_COUNT; nShape++)
                {
                    if (nToChangeno != -1)
                    {
                        break;
                    }

                    if (nShape != nMakeCardShape && nShape != nDingQueShape)
                    {
                        nToChangeno = GetWallCardnoByShape(nShape);
                        LOG_DEBUG("MakeCardForRoBotCatch else shape dingquecard chairno[%d] nToChangeno[%d] nShape[%d]", chairno, nToChangeno, nShape);
                    }
                }

            }
        }
    }
    else if (enInterveneType == INTERVENE_CATCH_ROBOTTING) //用户上听
    {
        // 先抓可胡的牌
        if (nRandomValue <= prob.nHuCardProb)
        {
            for (int i = 0; i < m_vRobotBoutPlayerCardIDs.size(); i++)
            {
                for (int j = 0; j < TOTAL_CARDS; j++)
                {
                    if (nToChangeno != -1)
                    {
                        LOG_DEBUG("MakeCardForRoBotCatch hucard chairno[%d] nToChangeno[%d]", chairno, nToChangeno);
                        break;
                    }
                    nToChangeno = GetWallCardnoByLayIndex(GetCardIndex(m_vRobotBoutPlayerCardIDs[i]));
                }
                if (nToChangeno != -1)
                {
                    LOG_DEBUG("MakeCardForRoBotCatch hucard chairno[%d] nToChangeno[%d]", chairno, nToChangeno);
                    break;
                }
            }
        }
        // 再抓定缺牌
        if (nRandomValue <= prob.nNotDingQueCardProb)
        {

            // 再找定缺的牌
            if (nToChangeno == -1)
            {
                int nDingQueShape = m_nDingQueCardType[chairno];
                int nMakeCardShape = -1;
                int nRandom = -1;
                while (nMakeCardShape == -1)
                {
                    nRandom = GetShuffleRandomValue(2);
                    if (nRandom != nDingQueShape)
                    {
                        nMakeCardShape = nRandom;
                    }
                }

                //交换
                nToChangeno = GetWallCardnoByShape(nMakeCardShape);
                LOG_DEBUG("MakeCardForRoBotCatchTing dingque chairno[%d] nToChangeno[%d]", chairno, nToChangeno);

                for (int nShape = 0; nShape < SHAPE_COUNT; nShape++)
                {
                    if (nToChangeno != -1)
                    {
                        break;
                    }

                    if (nShape != nMakeCardShape && nShape != nDingQueShape)
                    {
                        nToChangeno = GetWallCardnoByShape(nShape);
                        LOG_DEBUG("MakeCardForRoBotCatchTing else shape dingquecard chairno[%d] nToChangeno[%d] nShape[%d]", chairno, nToChangeno, nShape);
                    }
                }
            }
        }
    }

    if (nToChangeno != -1 && catchno != -1)
    {
        LOG_DEBUG("MakeCardForRoBotCatch chairno[%d] catchno[%d] nToChangeno[%d]", chairno, catchno, nToChangeno);
        ExchangeCatchAndWallCard(chairno, catchno, nToChangeno);
    }
}

int CMyGameTable::MakeCardForThrowIntervene(int chairno)
{
    if (!MakeCardIntervene() || !IsRobotBout() || !IsRoboter(chairno) || !m_bvalidRobotBout)
    {
        return INVALID_OBJECT_ID;
    }
    // 血流场 机器人胡过 直接抓啥打啥
    if (IsXueLiuRoom() && m_HuReady[chairno] && m_HuReady[chairno] != MJ_GIVE_UP)
    {
        return INVALID_OBJECT_ID;
    }

    LOG_DEBUG("MakeCardForThrowIntervene come in");
    PROB tmpProb;
    memset(&tmpProb, -1, sizeof(tmpProb));

    if (m_vRobotBoutPlayerCardIDs.size() > 0)
    {
        tmpProb = GetRemainCoutInterveneProb(INTERVENE_THROW_TING, m_stMakeCardProb.vRobotBoutTingThrow);
        return MakeCardForRobotThrow(chairno, INTERVENE_THROW_TING, tmpProb);
    }
    else    //用户未上听
    {
        tmpProb = GetRemainCoutInterveneProb(INTERVENE_THROW_ROBOT, m_stMakeCardProb.vRobotBoutThrow);
        return MakeCardForRobotThrow(chairno, INTERVENE_THROW_ROBOT, tmpProb);
    }

}

int CMyGameTable::MakeCardForRobotThrow(int chairno, INTERVENE_TYPE enInterveneType, PROB prob)
{
    int nPlayerNo = GetRobotBoutPlayerNo();
    // int nPlayerNoCardIDs[MJ_GF_14_HANDCARDS];
    int nRobotNoCardsIDs[MJ_GF_14_HANDCARDS];
    // memset(&nPlayerNoCardIDs, -1, sizeof(int) *MJ_GF_14_HANDCARDS);
    memset(&nRobotNoCardsIDs, -1, sizeof(int) *MJ_GF_14_HANDCARDS);

    // GetChairCards(nPlayerNo, nPlayerNoCardIDs, MJ_GF_14_HANDCARDS);
    GetChairCards(chairno, nRobotNoCardsIDs, MJ_GF_14_HANDCARDS);

    int nRandomValue = GetShuffleRandomValue(100);
    int nCardID = -1;
    if (enInterveneType == INTERVENE_THROW_ROBOT)
    {
        //先出 玩家可杠的牌
        if (nRandomValue <= prob.nGangCardProb)
        {
            LOG_DEBUG("MakeCardForRoBotThrow throw gangcard chairno[%d]", chairno);
            // 先找杠的牌
            for (int i = 0; i < LAYOUT_XZMO; i++)
            {
                if (m_nCardsLayIn[nPlayerNo][i] == 3)
                {
                    for (int j = 0; j < MJ_GF_14_HANDCARDS; j++)
                    {
                        if (!IsValidCard(nRobotNoCardsIDs[j]))
                        {
                            break;
                        }

                        if (i == GetCardIndex(nRobotNoCardsIDs[j]))
                        {
                            LOG_DEBUG("MakeCardForRoBotThrow throw gangcard chairno[%d], cardid[%d]", chairno, nRobotNoCardsIDs[j]);
                            return nRobotNoCardsIDs[j];
                        }
                    }
                }
            }
        }
        // 再出玩家可以碰的牌
        if (nRandomValue <= prob.nPengCardProb)
        {
            LOG_DEBUG("MakeCardForRoBotThrow throw pengcard chairno[%d]", chairno);
            for (int i = 0; i < LAYOUT_XZMO; i++)
            {
                if (m_nCardsLayIn[nPlayerNo][i] == 2)
                {
                    for (int j = 0; j < MJ_GF_14_HANDCARDS; j++)
                    {
                        if (!IsValidCard(nRobotNoCardsIDs[j]))
                        {
                            break;
                        }

                        if (i == GetCardIndex(nRobotNoCardsIDs[j]))
                        {
                            LOG_DEBUG("MakeCardForRoBotThrow throw pengcard chairno[%d] cardid[%d]", chairno, nRobotNoCardsIDs[j]);
                            return nRobotNoCardsIDs[j];
                        }
                    }
                }
            }
        }

        // 在出未定缺的牌
        //         if (nRandomValue <= prob.nNotDingQueCardProb)
        //         {
        //             LOG_DEBUG("MakeCardForRoBotThrow throw dingquecard chairno[%d]", chairno);
        //             int nDingQueShape = m_nDingQueCardType[nPlayerNo];
        //
        //             //先出定缺的牌
        //             for (int i = 0; i < MJ_GF_14_HANDCARDS; i++)
        //             {
        //                 if (m_pCalclator->MJ_CalculateCardShape(nRobotNoCardsIDs[i], 0) != nDingQueShape)
        //                 {
        //                     LOG_DEBUG("MakeCardForRoBotThrow throw dingquecard chairno[%d] cardid[%d]", chairno, nRobotNoCardsIDs[i]);
        //                     return nRobotNoCardsIDs[i];
        //                 }
        //             }
        //         }
    }

    if (enInterveneType == INTERVENE_THROW_TING)
    {
        // 用户上听后
        //先出用户 可胡的牌
        if (nRandomValue <= prob.nHuCardProb)
        {
            LOG_DEBUG("MakeCardForRoBotThrow throw hucard chairno[%d]", chairno);
            for (int i = 0; i < m_vRobotBoutPlayerCardIDs.size(); i++)
            {
                for (int j = 0; j < MJ_GF_14_HANDCARDS; j++)
                {
                    if (!IsValidCard(nRobotNoCardsIDs[j]))
                    {
                        break;
                    }
                    if (GetCardIndex(m_vRobotBoutPlayerCardIDs[i]) == GetCardIndex(nRobotNoCardsIDs[j]))
                    {
                        LOG_DEBUG("MakeCardForRoBotThrow throw hucard chairno[%d] cardid[%d]", chairno, nRobotNoCardsIDs[j]);
                        return nRobotNoCardsIDs[j];
                    }
                }
            }
        }
        // 再出用户非定缺的牌
        //         if (nRandomValue <= prob.nNotDingQueCardProb)
        //         {
        //             LOG_DEBUG("MakeCardForRoBotThrow throw notdingquecard chairno[%d]", chairno);
        //             int nDingQueShape = m_nDingQueCardType[nPlayerNo];
        //
        //             for (int i = 0; i < MJ_GF_14_HANDCARDS; i++)
        //             {
        //                 if (m_pCalclator->MJ_CalculateCardShape(nRobotNoCardsIDs[i], 0) != nDingQueShape)
        //                 {
        //                     LOG_DEBUG("MakeCardForRoBotThrow throw notdingquecard chairno[%d] cardid[%d]", chairno, nRobotNoCardsIDs[i]);
        //                     return nRobotNoCardsIDs[i];
        //                 }
        //             }
        //         }
    }

    return INVALID_OBJECT_ID;
}

PROB CMyGameTable::GetRemainCoutInterveneProb(INTERVENE_TYPE enInterveneType, vector<PROB>& v)
{
    int nRemainCout = CalLastCounts();
    PROB tmpProb;
    memset(&tmpProb, -1, sizeof(PROB));

    int nCount = v.size();
    if (nCount <= 0)
    {
        return tmpProb;
    }
    for (int i = 0; i < nCount; i++)
    {
        if (i == 0 && nRemainCout <= v[i].nRemainCout)
        {
            tmpProb = v[i];
            continue;
        }

        if (i + 1 == nCount)
        {
            break;
        }

        if (nRemainCout > v[i].nRemainCout && nRemainCout <= v[i + 1].nRemainCout)
        {
            tmpProb = v[i + 1];
        }
    }
    return tmpProb;

}

void CMyGameTable::CalcTingByRobotBoutPlayer(DWORD dwExtraFlag /*= 0*/)
{
    LOG_DEBUG("CalcTingByRobotBoutPlayer comein");
    if (!MakeCardIntervene())
    {
        return;
    }

    if (!m_bvalidRobotBout)
    {
        return;
    }

    int nPlayerNo = GetRobotBoutPlayerNo();
    if (nPlayerNo < 0)
    {
        return;
    }

    m_vRobotBoutPlayerCardIDs.clear();
    HU_DETAILS huDetails;
    int nCards[27] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 36, 37, 38, 39, 40, 41, 42, 43, 44, 72, 73, 74, 75, 76, 77, 78, 79, 80 };
    memset(&huDetails, 0, sizeof(HU_DETAILS));

    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };
    memcpy(lay, m_nCardsLayIn[nPlayerNo], sizeof(lay));

    for (int i = 0; i < 27; i++)
    {
        if (m_nDingQueCardType[nPlayerNo] == m_pCalclator->MJ_CalculateCardShape(nCards[i], 0))
        {
            continue;
        }

        int cardidx = m_pCalclator->MJ_CalcIndexByID(nCards[i], m_dwGameFlags);
        lay[cardidx]++;

        if (imCanHuFast(lay, MAX_CARDS_LAYOUT_NUM))
        {
            LOG_DEBUG("CalcTingByRobotBoutPlayer canting cardid = %d,", nCards[i]);
            m_vRobotBoutPlayerCardIDs.push_back(nCards[i]);
        }

        // 每次计算完 lay[cardindex]--
        lay[cardidx]--;
    }
    LOG_DEBUG("CalcTingByRobotBoutPlayer end");
}