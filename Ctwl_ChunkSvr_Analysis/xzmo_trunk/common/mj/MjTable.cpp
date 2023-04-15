#include "StdAfx.h"
#include<random>
#include <functional>
#include <memory>

//
CMJTable::CMJTable(int roomid, int tableno, int score_mult,
    int totalchairs, DWORD gameflags, DWORD gameflags2, int max_asks,
    int totalcards,
    int totalpacks, int chaircards, int bottomcards,
    int layoutnum, int layoutmod, int layoutnumex,
    int abtpairs[],
    int throwwait, int maxautothrow, int entrustwait,
    int max_auction, int min_auction, int def_auction,
    int pgchwait, int max_banker_hold,
    DWORD huflags, DWORD huflags2)
    : CCommonBaseTable(roomid, tableno, score_mult,
          totalchairs, gameflags, gameflags2, max_asks)
{
    if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))
    {
        // 不使用财神
        if (IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT) // 财神可以还原
            || IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
        {
            // 白板可代替财神
            assert(0);
        }
    }

    m_nTotalCards = totalcards;                 // 牌张数
    m_nTotalPacks = totalpacks;                 // 几副牌
    m_nChairCards = chaircards;                 // 每人最多牌张数
    m_nBottomCards = bottomcards;               // 底牌张数
    m_nLayoutNum = layoutnum;                   // 牌的方阵长度
    m_nLayoutMod = layoutmod;                   // 牌阵模数长度
    m_nLayoutNumEx = layoutnumex;               // 牌的方阵长度(扩展)
    m_nThrowWait = throwwait;                   // 出牌等待时间(秒)
    m_nMaxAutoThrow = maxautothrow;             // 允许自动出牌的最大次数
    m_nEntrustWait = entrustwait;               // 托管等待时间(秒)
    m_nMaxAuction = max_auction;                // 允许最大叫分
    m_nMinAuction = min_auction;                // 允许最小叫分
    m_nDefAuction = def_auction;                // 默认叫分
    m_nPGCHWait = pgchwait;                     // 碰杠吃胡等待时间(秒)
    m_nMaxBankerHold = max_banker_hold;         // 最大连续坐庄局数
    memset(m_dwHuFlags, 0, sizeof(m_dwHuFlags));
    m_dwHuFlags[0] = huflags;                   // 胡牌种类标志
    m_dwHuFlags[1] = huflags2;                  // 胡牌种类标志2
}

void CMJTable::ResetMembers(BOOL bResetAll)
{
    __super::ResetMembers(bResetAll);

    if (bResetAll)
    {
        // 动态信息，跟局数无关
        m_bQuickCatch = FALSE; // 快速抓牌

        // 动态信息，跟上局相关
        m_nBankerHold = 1;  // 连续坐庄局数

        m_nFirstCatch = INVALID_OBJECT_ID;          // 第一个摸牌
        m_nFirstThrow = INVALID_OBJECT_ID;          // 第一个出牌

        memset(m_nResultDiff, 0, sizeof(m_nResultDiff));
        memset(m_nTotalResult, 0, sizeof(m_nTotalResult));

        m_nYqwAutoPlayWait = 0;
        m_nYQWQuickThrowWait = YQW_YQWQUICK_WAIT;
        m_nYQWQuickPGCWait = YQW_YQWQUICK_WAIT;
    }
    // 动态信息，跟局数相关
    ZeroMemory(m_nDices, sizeof(m_nDices));
    ZeroMemory(m_nCardsLayIn, sizeof(m_nCardsLayIn));   // 每个人手里的牌
    ZeroMemory(m_nBottomIDs, sizeof(m_nBottomIDs));     // 底牌ID
    ZeroMemory(m_Auctions, sizeof(m_Auctions));         // 叫庄情况记录
    ZeroMemory(m_dwPGCHFlags, sizeof(m_dwPGCHFlags));   // 出牌后碰杠吃胡状态
    ZeroMemory(m_dwGuoFlags, sizeof(m_dwGuoFlags));     // 出牌后能否过牌标志
    ZeroMemory(m_nJokersThrown, sizeof(m_nJokersThrown)); // 财神打出个数
    ZeroMemory(m_nbaoTing, sizeof(m_nbaoTing));     // 报听标志

    m_aryCard.RemoveAll();                          // 所有牌的信息
    m_nAuctionCount = 0;                            // 叫庄计数
    m_nObjectGains = m_nDefAuction;                 // 叫分标的
    m_nCatchFrom = 0;                               // 开始摸牌位置
    m_nJokerNO = INVALID_OBJECT_ID;                 // 财神位置
    m_nJokerID = INVALID_OBJECT_ID;                 // 财神牌ID
    m_dwLatestThrow = 0;                            // 最近出牌时间(ms)
    m_nThrowCount = 0;                              // 出牌第几手计数
    m_nJokerID2 = INVALID_OBJECT_ID;                // 财神牌ID2
    m_nHeadTaken = 0;           // 头上被抓牌张数
    m_nTailTaken = 0;           // 尾上被抓牌张数
    m_nCurrentCatch = 0;        // 当前抓牌位置

    m_nGangID = INVALID_OBJECT_ID;  // 杠牌ID
    m_nGangChair = INVALID_OBJECT_ID;   // 杠牌位置
    m_nCardChair = INVALID_OBJECT_ID;   // 牌所属位置

    m_nCaiPiaoChair = INVALID_OBJECT_ID;    // 财飘位置
    m_nCaiPiaoCount = 0;                    // 财飘个数

    m_nGangKaiCount = 0;    // 杠开计数
    m_dwLatestPreGang = 0;  // 准备杠牌计时开始

    for (int i = 0; i < MJ_CHAIR_COUNT; i++)
    {
        m_PengCards[i].RemoveAll();
        m_ChiCards[i].RemoveAll();
        m_MnGangCards[i].RemoveAll();
        m_AnGangCards[i].RemoveAll();
        m_PnGangCards[i].RemoveAll();
        m_nOutCards[i].RemoveAll();
        m_nHuaCards[i].RemoveAll();
        memset(m_nTingCardsDXXW[i], 0, sizeof(m_nTingCardsDXXW[i]));
        memset(m_nLastThrowCard[i], 0, sizeof(m_nLastThrowCard[i]));
    }
    memset(m_nPengFeedCount, 0, sizeof(m_nPengFeedCount));
    memset(m_nChiFeedCount, 0, sizeof(m_nChiFeedCount));
    memset(m_nGangFeedCount, 0, sizeof(m_nGangFeedCount));
    memset(m_nCatchCount, 0, sizeof(m_nCatchCount));    // 玩家抓到的牌数目(包括杠到的牌)
    memset(m_nResults, 0, sizeof(m_nResults));          // 胡牌返回
    memset(m_huDetails, 0, sizeof(m_huDetails));        // 胡牌详细

    m_nLoseChair = INVALID_OBJECT_ID;   // 放冲或者被抢杠者位置
    m_nHuChair = INVALID_OBJECT_ID; // 胡牌者位置
    m_nHuCount = 0;                 // 胡牌人数
    m_nHuCard = INVALID_OBJECT_ID;  // 胡牌ID

    m_dwStatus &= ~TS_AFTER_CHI;
    m_dwStatus &= ~TS_AFTER_PENG;
    m_dwStatus &= ~TS_AFTER_GANG;

    memset(&m_CardTingDetail, 0, sizeof(CARD_TING_DETAIL));
    XygInitChairCards(m_CardTingDetail.nThrowCardsTing, MJ_GF_14_HANDCARDS);
    memset(&m_CardTingDetail_16, 0, sizeof(CARD_TING_DETAIL_16));
    XygInitChairCards(m_CardTingDetail_16.nThrowCardsTing, MJ_GF_17_HANDCARDS);

    m_nCurrentCard = INVALID_OBJECT_ID;
    m_nCurrentOpeCard = INVALID_OBJECT_ID;
    m_nLastGangNO = INVALID_OBJECT_ID;

    m_nQghFlag = 0;
    m_nQghID = INVALID_OBJECT_ID;
    m_nQghChair = INVALID_OBJECT_ID;

    ResetWaitOpe();
}

void CMJTable::ResetTable()
{
    __super::ResetTable();

    m_bQuickCatch = FALSE; // 快速抓牌
    m_nBankerHold = 1;  // 连续坐庄局数
    m_nFirstCatch = INVALID_OBJECT_ID;          // 第一个摸牌
    m_nFirstThrow = INVALID_OBJECT_ID;          // 第一个出牌
    memset(m_nResultDiff, 0, sizeof(m_nResultDiff));
    memset(m_nTotalResult, 0, sizeof(m_nTotalResult));
}

int CMJTable::Restart(int& errchair, int deposit_mult, int deposit_min,
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
    m_bQuickCatch = XygGetOptionOneTrue(m_dwUserConfig, m_nTotalChairs, MJ_UC_QUICK_CATCH);

    return error;
}


void CMJTable::InitModel()
{
    __super::InitModel();
    m_pCalclator = std::make_shared<CMJCalclator>();
}

int CMJTable::GetEnterGameInfoSize()
{
    return sizeof(GAME_ENTER_INFO);
}

void CMJTable::FillupEnterGameInfo(void* pData, int nLen, int chairno, BOOL lookon)
{
    __super::FillupEnterGameInfo(pData, nLen, chairno, lookon);

    GAME_ENTER_INFO* pEnterGame = (GAME_ENTER_INFO*)pData;
    memcpy(pEnterGame->nResultDiff, m_nResultDiff, sizeof(m_nResultDiff));
    memcpy(pEnterGame->nTotalResult, m_nTotalResult, sizeof(m_nTotalResult));
}

int CMJTable::GetGameTableInfoSize()
{
    return sizeof(TABLE_INFO_MJ);
}

void CMJTable::FillupGameTableInfo(void* pData, int nLen, int chairno, BOOL lookon)
{
    ZeroMemory(pData, nLen);

    //LPTABLE_INFO
    //////////////////////////////////////////////////////////////////////////
    LPTABLE_INFO_MJ pTableInfo = (LPTABLE_INFO_MJ)pData;
    pTableInfo->nTableNO = m_nTableNO;                      // 桌号
    pTableInfo->nScoreMult = m_nScoreMult;                      // 积分放大
    pTableInfo->nTotalChairs = m_nTotalChairs;                  // 椅子数目
    pTableInfo->dwGameFlags = m_dwGameFlags;                    // 游戏特征选项
    pTableInfo->dwStatus = m_dwStatus;                      // 状态
    pTableInfo->nCurrentChair = GetCurrentChair();              // 当前活动位置
    pTableInfo->bTableEqual = m_bTableEqual;                    // 是否桌子相同
    pTableInfo->bNeedDeposit = m_bNeedDeposit;                  // 是否需要银子
    pTableInfo->bForbidDesert = m_bForbidDesert;                    // 是否禁止强退
    pTableInfo->nBaseScore = m_nBaseScore;                      // 本局基本积分
    pTableInfo->nBaseDeposit = m_nBaseDeposit;                  // 本局基本银子
    pTableInfo->nDepositMult = m_nDepositMult;                  // 银子加倍
    pTableInfo->nDepositMin = m_nDepositMin;                    // 最少银子
    pTableInfo->nFeeRatio = m_nFeeRatio;                        // 手续费百分比
    pTableInfo->nMaxTrans = m_nMaxTrans;                        // 最大输赢
    pTableInfo->nCutRatio = m_nCutRatio;                        // 逃跑扣银百分比

    memcpy(pTableInfo->nAutoCount, m_nAutoCount, sizeof(m_nAutoCount));     // 自动出牌计数
    memcpy(pTableInfo->nBreakCount, m_nBreakCount, sizeof(m_nBreakCount));  // 断线续玩计数
    pTableInfo->nRoundCount = m_nRoundCount;                    // 第几轮
    pTableInfo->nBoutCount = m_nBoutCount;                      // 第几局
    pTableInfo->nBanker = m_nBanker;                        // 庄家位置
    memcpy(pTableInfo->dwUserStatus, m_dwUserStatus, sizeof(m_dwUserStatus));   // 用户状态
    memcpy(pTableInfo->dwUserConfig, m_dwUserConfig, sizeof(m_dwUserConfig));   // 用户设置
    memcpy(pTableInfo->dwRoomOption, m_dwRoomOption, sizeof(m_dwRoomOption));   // 房间设置
    pTableInfo->dwRoomConfigs = GetRoomConfig();    // 房间设置-扩展
    memcpy(pTableInfo->nDices, m_nDices, sizeof(m_nDices));                 // 骰子大小
    pTableInfo->dwWinFlags = m_dwWinFlags;                              // 输赢标志

    if (!lookon)
    {
        // 不是旁观者，是玩家
    }
    memcpy(pTableInfo->nPartnerGroup, m_nPartnerGroup, sizeof(m_nPartnerGroup));// 每人所属组

    memcpy(pTableInfo->dwCostTime, m_dwCostTime, sizeof(m_dwCostTime)); // 总共耗费时间

    if (INVALID_OBJECT_ID != m_nCurrentChair && m_dwActionStart)
    {
        pTableInfo->dwIntermitTime = GetTickCount() - m_dwActionStart;
    }
    pTableInfo->dwBoutFlags = m_dwBoutFlags;    // 本局相关标志(与上局NextFlags等值)

    //LPTABLE_INFO_KD
    //////////////////////////////////////////////////////////////////////////
    pTableInfo->nTotalCards = m_nTotalCards;                    // 牌数目
    pTableInfo->nTotalPacks = m_nTotalPacks;                    // 几副牌
    pTableInfo->nChairCards = m_nChairCards;                    // 每人最多牌张数
    pTableInfo->nBottomCards = m_nBottomCards;                  // 底牌张数
    pTableInfo->nLayoutNum = m_nLayoutNum;                      // 牌的方阵长度
    pTableInfo->nLayoutMod = m_nLayoutMod;                      // 牌阵模数长度
    pTableInfo->nLayoutNumEx = m_nLayoutNumEx;                  // 牌的方阵长度(扩展)
    pTableInfo->nThrowWait = m_nThrowWait;                      // 出牌等待时间(秒)
    pTableInfo->nMaxAutoThrow = m_nMaxAutoThrow;                    // 允许自动出牌的最大次数
    pTableInfo->nEntrustWait = m_nEntrustWait;                  // 托管等待时间(秒)
    pTableInfo->nMaxAuction = m_nMaxAuction;                    // 允许最大叫分
    pTableInfo->nMinAuction = m_nMinAuction;                    // 允许最小叫分
    pTableInfo->nDefAuction = m_nDefAuction;                    // 默认叫分

    pTableInfo->nFirstCatch = m_nFirstCatch;                    // 第一个摸牌
    pTableInfo->nFirstThrow = m_nFirstThrow;                    // 第一个出牌

    pTableInfo->nAuctionCount = m_nAuctionCount;                    // 叫庄计数
    memcpy(pTableInfo->Auctions, m_Auctions, sizeof(m_Auctions));   // 叫庄情况记录
    pTableInfo->nObjectGains = m_nObjectGains;                  // 叫分标的

    pTableInfo->nCatchFrom = m_nCatchFrom;                      // 开始摸牌位置
    pTableInfo->nJokerNO = m_nJokerNO;                      // 财神位置
    pTableInfo->nJokerID = m_nJokerID;                      // 财神牌ID

    XygInitBottomCards(pTableInfo->nBottomIDs, MAX_BOTTOM_CARDS);
    if (chairno == m_nBanker)
    {
        memcpy(pTableInfo->nBottomIDs, m_nBottomIDs, sizeof(m_nBottomIDs));
    }
    //
    int i, j = 0;
    for (i = 0; i < MAX_CHAIRS_PER_TABLE; i++)
    {
        // 初始化牌的ID方阵
        XygInitChairCards(pTableInfo->nIDMatrix[i], MAX_CARDS_PER_CHAIR);
    }
    if (!lookon)
    {
        // 不是旁观者，是玩家
        GetChairCards(chairno, pTableInfo->nIDMatrix[chairno], MAX_CARDS_PER_CHAIR); // 填充牌的ID方阵
    }
    //

    pTableInfo->nThrowCount = m_nThrowCount;        // 出牌第几手计数

    //LPTABLE_INFO_MJ
    //////////////////////////////////////////////////////////////////////////
    pTableInfo->nPGCHWait = m_nPGCHWait;        //  碰杠吃胡等待时间(秒)
    pTableInfo->nMaxBankerHold = m_nMaxBankerHold;  // 最大连续坐庄局数
    CopyMemory(pTableInfo->dwHuFlags, m_dwHuFlags, sizeof(m_dwHuFlags));    // 胡牌种类标志数组

    pTableInfo->bQuickCatch = m_bQuickCatch;    // 快速抓牌
    pTableInfo->nBankerHold = m_nBankerHold;    // 连续坐庄局数
    pTableInfo->nJokerID2 = m_nJokerID2;        // 财神牌ID2
    pTableInfo->nHeadTaken = m_nHeadTaken;      // 头上被抓牌张数
    pTableInfo->nTailTaken = m_nTailTaken;      // 尾上被抓牌张数
    pTableInfo->nCurrentCatch = m_nCurrentCatch;    // 当前抓牌位置

    CopyMemory(pTableInfo->dwPGCHFlags, m_dwPGCHFlags, sizeof(m_dwPGCHFlags));  // 出牌后碰杠吃胡状态
    CopyMemory(pTableInfo->dwGuoFlags, m_dwGuoFlags, sizeof(m_dwGuoFlags));     // 出牌后能否过牌标志

    pTableInfo->nGangID = m_nGangID;        // 杠牌ID
    pTableInfo->nGangChair = m_nGangChair;      // 杠牌位置
    pTableInfo->nCardChair = m_nCardChair;      // 牌所属位置

    CopyMemory(pTableInfo->nJokersThrown, m_nJokersThrown, sizeof(m_nJokersThrown)); // 财神打出个数
    pTableInfo->nCaiPiaoChair = m_nCaiPiaoChair;    // 财飘位置
    pTableInfo->nCaiPiaoCount = m_nCaiPiaoCount;    // 财飘个数

    pTableInfo->nGangKaiCount = m_nGangKaiCount;    // 杠开计数

    for (i = 0; i < MJ_CHAIR_COUNT; i++)
    {
        pTableInfo->nPengCount[i] = 0;
        pTableInfo->nChiCount[i] = 0;
        pTableInfo->nMnGangCount[i] = 0;
        pTableInfo->nAnGangCount[i] = 0;
        pTableInfo->nPnGangCount[i] = 0;
        pTableInfo->nOutCount[i] = 0;
        pTableInfo->nHuaCount[i] = 0;

        for (j = 0; j < MJ_MAX_PENG; j++)
        {
            XygInitChairCards(pTableInfo->PengCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pTableInfo->PengCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        for (j = 0; j < MJ_MAX_CHI; j++)
        {
            XygInitChairCards(pTableInfo->ChiCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pTableInfo->ChiCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        for (j = 0; j < MJ_MAX_GANG; j++)
        {
            XygInitChairCards(pTableInfo->MnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pTableInfo->MnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
            XygInitChairCards(pTableInfo->AnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pTableInfo->AnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
            XygInitChairCards(pTableInfo->PnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pTableInfo->PnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        XygInitChairCards(pTableInfo->nOutCards[i], MJ_MAX_OUT);
        XygInitChairCards(pTableInfo->nHuaCards[i], MJ_MAX_HUA);
    }
    for (i = 0; i < m_nTotalChairs; i++)
    {
        for (j = 0; j < m_PengCards[i].GetSize(); j++)
        {
            pTableInfo->PengCards[i][j] = m_PengCards[i][j];
        }
        pTableInfo->nPengCount[i] = m_PengCards[i].GetSize();
        //
        for (j = 0; j < m_ChiCards[i].GetSize(); j++)
        {
            pTableInfo->ChiCards[i][j] = m_ChiCards[i][j];
        }
        pTableInfo->nChiCount[i] = m_ChiCards[i].GetSize();
        //
        for (j = 0; j < m_MnGangCards[i].GetSize(); j++)
        {
            pTableInfo->MnGangCards[i][j] = m_MnGangCards[i][j];
        }
        pTableInfo->nMnGangCount[i] = m_MnGangCards[i].GetSize();
        //
        for (j = 0; j < m_AnGangCards[i].GetSize(); j++)
        {
            pTableInfo->AnGangCards[i][j] = m_AnGangCards[i][j];
        }
        pTableInfo->nAnGangCount[i] = m_AnGangCards[i].GetSize();
        //
        for (j = 0; j < m_PnGangCards[i].GetSize(); j++)
        {
            pTableInfo->PnGangCards[i][j] = m_PnGangCards[i][j];
        }
        pTableInfo->nPnGangCount[i] = m_PnGangCards[i].GetSize();
        //
        for (j = 0; j < m_nHuaCards[i].GetSize(); j++)
        {
            pTableInfo->nHuaCards[i][j] = m_nHuaCards[i][j];
        }
        pTableInfo->nHuaCount[i] = m_nHuaCards[i].GetSize();
        //
        for (j = 0; j < m_nOutCards[i].GetSize(); j++)
        {
            pTableInfo->nOutCards[i][j] = m_nOutCards[i][j];
        }
        pTableInfo->nOutCount[i] = m_nOutCards[i].GetSize();
    }
    CopyMemory(pTableInfo->nPengFeedCount, m_nPengFeedCount, sizeof(m_nPengFeedCount)); //
    CopyMemory(pTableInfo->nChiFeedCount, m_nChiFeedCount, sizeof(m_nChiFeedCount)); //
    CopyMemory(pTableInfo->nGangFeedCount, m_nGangFeedCount, sizeof(m_nGangFeedCount)); //

    memcpy(pTableInfo->nResultDiff, m_nResultDiff, sizeof(m_nResultDiff));
    memcpy(pTableInfo->nTotalResult, m_nTotalResult, sizeof(m_nTotalResult));
}
//todo 填入自己的GameStart结构体
int CMJTable::GetGameStartSize()
{
    if (IsTingPaiActive())
    {
        return sizeof(MJ_START_DATA) + (IS_BIT_SET(m_dwGameFlags, MJ_GF_16_CARDS) ? sizeof(CARD_TING_DETAIL_16) : sizeof(CARD_TING_DETAIL));
    }
    else
    {
        return sizeof(MJ_START_DATA);
    }
}

void CMJTable::FillupGameStart(void* pData, int nLen, int chairno, BOOL lookon)
{
    ZeroMemory(pData, nLen);
    FillupStartData(pData, nLen);
}

int CMJTable::GetGameWinSize()
{
    return sizeof(GAME_WIN_MJ);
}

int CMJTable::FillupGameWin(void* pData, int nLen, int chairno)
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

    return __super::FillupGameWin(pData, nLen, chairno);
}

void CMJTable::FillupStartData(void* pData, int nLen)
{
    LPMJ_START_DATA pStartData = (LPMJ_START_DATA)pData;

    memcpy(pStartData->szSerialNO, m_szSerialNO, sizeof(m_szSerialNO));
    pStartData->nBoutCount = m_nBoutCount;                      // 第几局
    pStartData->nBaseScore = m_nBaseScore;                      // 本局基本积分
    pStartData->nBaseDeposit = m_nBaseDeposit;                  // 本局基本银子
    pStartData->nBanker = m_nBanker;                        // 庄家位置
    pStartData->nBankerHold = m_nBankerHold;                    // 连续坐庄局数
    pStartData->dwStatus = m_dwStatus;                      // 状态
    pStartData->nCurrentChair = GetCurrentChair();              // 当前活动位置
    pStartData->nFirstCatch = m_nFirstCatch;                    // 第一个摸牌
    pStartData->nFirstThrow = m_nFirstThrow;                    // 第一个出牌

    pStartData->nThrowWait = m_nThrowWait;                      // 出牌等待时间(秒)
    pStartData->nMaxAutoThrow = m_nMaxAutoThrow;                    // 允许自动出牌的最大次数
    pStartData->nEntrustWait = m_nEntrustWait;                  // 托管等待时间(秒)

    pStartData->bNeedDeposit = m_bNeedDeposit;                  // 是否需要银子
    pStartData->bForbidDesert = m_bForbidDesert;                    // 是否禁止强退

    memcpy(pStartData->nDices, m_nDices, sizeof(m_nDices));         // 骰子大小
    pStartData->bQuickCatch = m_bQuickCatch;                    // 快速抓牌
    pStartData->bAllowChi = !IS_BIT_SET(m_dwGameFlags, MJ_GF_CHI_FORBIDDEN);    // 允许吃
    pStartData->bAnGangShow = IS_BIT_SET(m_dwGameFlags, MJ_GF_ANGANG_SHOW);     // 暗杠的牌能否显示

    pStartData->bJokerSortIn = IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_SORTIN);   // 财神牌不固定放头上
    pStartData->bBaibanNoSort = IS_BIT_SET(m_dwGameFlags, MJ_GF_BAIBAN_NOSORT); // 替代财神牌不排序放

    pStartData->nBeginNO = m_nCatchFrom;                        // 开始摸牌位置
    pStartData->nJokerNO = m_nJokerNO;                      // 财神位置
    pStartData->nJokerID = m_nJokerID;                      // 财神牌ID
    pStartData->nJokerID2 = m_nJokerID2;                        // 财神牌ID2
    if (m_nJokerNO >= 0)
    {
        pStartData->nFanID = m_aryCard[m_nJokerNO].nID;     // 翻牌ID
    }
    else
    {
        pStartData->nFanID = INVALID_OBJECT_ID;             // 翻牌ID
    }
    pStartData->nTailTaken = m_nTailTaken;                      // 尾上被抓牌张数
    pStartData->nCurrentCatch = m_nCurrentCatch;                    // 当前抓牌位置
    pStartData->nPGCHWait = m_nPGCHWait;                        // 碰杠吃胡等待时间(秒)
    pStartData->nPGCHWaitEx = MJ_PGCH_WAIT_EXT;                 // 碰杠吃胡等待时间(追加)(秒)

    if (IS_BIT_SET(m_dwStatus, TS_PLAYING_GAME))
    {
        if (CalcHu_Zimo(m_nBanker, GetFirstCardOfChair(m_nBanker)))
        {
            // 庄家能否天胡
            pStartData->dwCurrentFlags = MJ_HU;
        }
    }
}

void CMJTable::FillupPlayData(void* pData, int nLen)
{
    LPMJ_PLAY_DATA pPlayData = (LPMJ_PLAY_DATA)pData;
    int i, j = 0;
    for (i = 0; i < MJ_CHAIR_COUNT; i++)
    {
        pPlayData->nPengCount[i] = 0;
        pPlayData->nChiCount[i] = 0;
        pPlayData->nMnGangCount[i] = 0;
        pPlayData->nAnGangCount[i] = 0;
        pPlayData->nPnGangCount[i] = 0;
        pPlayData->nOutCount[i] = 0;
        pPlayData->nHuaCount[i] = 0;
        for (j = 0; j < MJ_MAX_PENG; j++)
        {
            XygInitChairCards(pPlayData->PengCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pPlayData->PengCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        for (j = 0; j < MJ_MAX_CHI; j++)
        {
            XygInitChairCards(pPlayData->ChiCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pPlayData->ChiCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        for (j = 0; j < MJ_MAX_GANG; j++)
        {
            XygInitChairCards(pPlayData->MnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pPlayData->MnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
            XygInitChairCards(pPlayData->AnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pPlayData->AnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
            XygInitChairCards(pPlayData->PnGangCards[i][j].nCardIDs, MJ_UNIT_LEN);
            pPlayData->PnGangCards[i][j].nCardChair = INVALID_OBJECT_ID;
        }
        XygInitChairCards(pPlayData->nOutCards[i], MJ_MAX_OUT);
        XygInitChairCards(pPlayData->nHuaCards[i], MJ_MAX_HUA);
    }
    for (i = 0; i < m_nTotalChairs; i++)
    {
        for (j = 0; j < m_PengCards[i].GetSize(); j++)
        {
            pPlayData->PengCards[i][j] = m_PengCards[i][j];
        }
        pPlayData->nPengCount[i] = m_PengCards[i].GetSize();
        //
        for (j = 0; j < m_ChiCards[i].GetSize(); j++)
        {
            pPlayData->ChiCards[i][j] = m_ChiCards[i][j];
        }
        pPlayData->nChiCount[i] = m_ChiCards[i].GetSize();
        //
        for (j = 0; j < m_MnGangCards[i].GetSize(); j++)
        {
            pPlayData->MnGangCards[i][j] = m_MnGangCards[i][j];
        }
        pPlayData->nMnGangCount[i] = m_MnGangCards[i].GetSize();
        //
        for (j = 0; j < m_AnGangCards[i].GetSize(); j++)
        {
            pPlayData->AnGangCards[i][j] = m_AnGangCards[i][j];
        }
        pPlayData->nAnGangCount[i] = m_AnGangCards[i].GetSize();
        //
        for (j = 0; j < m_PnGangCards[i].GetSize(); j++)
        {
            pPlayData->PnGangCards[i][j] = m_PnGangCards[i][j];
        }
        pPlayData->nPnGangCount[i] = m_PnGangCards[i].GetSize();
        //
        for (j = 0; j < m_nHuaCards[i].GetSize(); j++)
        {
            pPlayData->nHuaCards[i][j] = m_nHuaCards[i][j];
        }
        pPlayData->nHuaCount[i] = m_nHuaCards[i].GetSize();
        //
        for (j = 0; j < m_nOutCards[i].GetSize(); j++)
        {
            pPlayData->nOutCards[i][j] = m_nOutCards[i][j];
        }
        pPlayData->nOutCount[i] = m_nOutCards[i].GetSize();
    }
}

void CMJTable::StartDeal()
{
    __super::StartDeal();
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), m_nRoomID);

    m_nThrowWait = GetPrivateProfileInt(
            _T("throwwait"),    // section name
            szRoomID,           // key name
            MJ_THROW_WAIT,         // default int
            GetINIFilePath()    // initialization file name
        );

    m_nPGCHWait = GetPrivateProfileInt(
            _T("pgchwait"),     // section name
            szRoomID,           // key name
            MJ_PGCH_WAIT,          // default int
            GetINIFilePath()         // initialization file name
        );

    InitializeCards();

    m_nBanker = CalcBankerChairBefore(); // 决定庄家
    m_nCatchFrom = CalcCatchFrom();         // 开始摸牌位置
    m_nFirstCatch = CalcFirstCatchBefore(); // 谁先摸

    DealCards();  // 发牌
    assert(CheckCards());
    m_nJokerNO = CalcJokerNO(); // 决定财神
    m_nJokerID = CalcJokerID();
    m_nFirstThrow = CalcFirstThrowBefore(); // 谁先出

    if (IsYQWTable())
    {
        m_nYqwAutoPlayWait = GetPrivateProfileInt(
                _T("yqwautoplaywait"),// section name
                _T("time"),       // key name
                YQW_AUTOPLAY_WAIT,      // default int
                GetINIFilePath()   // initialization file name
            );

        m_nYQWQuickThrowWait = GetPrivateProfileInt(
                _T("yqwquickroom"),// section name
                _T("throwtime"),       // key name
                YQW_YQWQUICK_WAIT,      // default int
                GetINIFilePath()   // initialization file name
            );

        m_nYQWQuickPGCWait = GetPrivateProfileInt(
                _T("yqwquickroom"),// section name
                _T("pgctime"),       // key name
                YQW_YQWQUICK_WAIT,      // default int
                GetINIFilePath()   // initialization file name
            );

        if (IsYQWQuickRoom())
        {
            m_nPGCHWait = m_nYQWQuickPGCWait;
            m_nThrowWait = m_nYQWQuickThrowWait;
        }
    }
}

void CMJTable::ThrowDices()
{
    XygInitializeDice(m_nDices[0], m_nDices[1]);

    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_DICES_TWICE))
    {
        XygInitializeDice(m_nDices[2], m_nDices[3], 1);        // 骰子要掷两次
    }
    else
    {
        m_nDices[2] = 0;
        m_nDices[3] = 0;
    }
}

int CMJTable::PrepareNextBout(void* pData, int nLen)
{
    m_nFirstCatch = CalcFirstCatchAfter(pData, nLen);   // 谁先摸
    m_nFirstThrow = CalcFirstThrowAfter(pData, nLen);   // 谁先出

    return __super::PrepareNextBout(pData, nLen);
}

int CMJTable::SetRoundAfter(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    if (pGameWin->nNewRound)
    {
        // 新的一轮开始了
        m_nRoundCount += pGameWin->nNewRound;
    }
    return m_nRoundCount;
}

int CMJTable::ReplaceAutoThrow(LPTHROW_CARDS pThrowCards)
{
    XygInitChairCards(pThrowCards->nCardIDs, MAX_CARDS_PER_CHAIR);          // 打出的牌(ID)

    pThrowCards->nCardsCount = 1;                       // 牌张数
    pThrowCards->nCardIDs[0] = GetFirstCardOfChair(pThrowCards->nChairNO);
    pThrowCards->dwCardsType = 1;// 牌型

    return TRUE;
}

int CMJTable::SetGroupsOnAuctionFinished()
{
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == m_nBanker)
        {
            m_nPartnerGroup[i] = 0;
        }
        else
        {
            m_nPartnerGroup[i] = 1;
        }
    }
    return TRUE;
}

int CMJTable::CalcCatchFrom()
{
    int nBeginNO = 0;
    int nTotal = m_nDices[0] + m_nDices[1];
    int nSide = nTotal % m_nTotalChairs;
    int nCardsPerSide = m_nTotalCards / m_nTotalChairs;
    int nRowsPerSide = 2;

    nBeginNO = (m_nTotalChairs - nSide) * nCardsPerSide + nTotal * nRowsPerSide;
    nBeginNO += m_nBanker * nCardsPerSide;
    nBeginNO = nBeginNO % m_nTotalCards;

#ifdef _MAKECARD
    CreateIntFromFile(_T("BeginNO"), nBeginNO);
#endif
    return nBeginNO;
}

int CMJTable::CalcJokerNO()
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER))
    {
        // 没有财神
        return INVALID_OBJECT_ID;
    }
    int nJokerNO = 0;
    int nRowsPerSide = 2;

    nJokerNO = m_nCatchFrom - (m_nDices[0] + m_nDices[1]) * nRowsPerSide;
    nJokerNO += m_nTotalCards;
    nJokerNO %= m_nTotalCards;

#ifdef _MAKECARD
    DWORD dwMade = GetPrivateProfileInt(_T("Card"), _T("Made"), 0, GetINIMakeCardName());
    if (dwMade)
    {
        nJokerNO = GetPrivateProfileInt(_T("Card"), _T("joker"), nJokerNO, GetINIMakeCardName());
    }
#endif

    return nJokerNO;
}

int CMJTable::CalcJokerID()
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER))
    {
        // 没有财神
        return INVALID_OBJECT_ID;
    }
    if (m_nJokerNO >= 0)
    {
        if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_PLUS1))
        {
            // 翻牌加1是财神
            return PlusJokerIDFromShown(m_aryCard[m_nJokerNO].nID);
        }
        else
        {
            // 翻牌即是财神
            return m_aryCard[m_nJokerNO].nID;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::CalcFirstCatchBefore()
{
    return m_nBanker;
}

int CMJTable::CalcFirstThrowBefore()
{
    return m_nBanker;
}

int CMJTable::CalcFirstCatchAfter(void* pData, int nLen)
{
    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

    return XygGetRandomBetween(m_nTotalChairs);
}

int CMJTable::CalcFirstThrowAfter(void* pData, int nLen)
{
    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

    return m_nBanker;
}

BOOL CMJTable::IsNextFirstHand()
{
    return IS_BIT_SET(m_dwStatus, TS_WAITING_BIGGER) ? FALSE : TRUE;
}

// 找到下一个手里有牌的玩家，自己除外
int CMJTable::GetNextChairRemains(int chairno)
{
    int chair_remains = chairno;
    do
    {
        chair_remains = GetNextChair(chair_remains);
        if (chair_remains == chairno)
        {
            chair_remains = INVALID_OBJECT_ID;
            break;
        }
        else if (HaveCards(chair_remains))
        {
            break;
        }
    } while (TRUE);
    return chair_remains;
}

void CMJTable::InitializeCards()
{
    CCardIDAry aryCardID;

    CPlayer* ptrP = m_ptrPlayers[0];
    CreateRandomCards(aryCardID, m_nTotalCards);

#ifdef _MAKECARD
    CreateCardsFromFile(aryCardID);
#endif

    BuildUpCards(aryCardID);
}

int CMJTable::CreateRandomCards(CCardIDAry& aryCardID, int nMaxNum)
{
    std::vector<int> v;
    for (int i = 0; i < nMaxNum; ++i)
    {
        v.push_back(i);
    }
    std::default_random_engine e(std::random_device{}());
    std::shuffle(v.begin(), v.end(), e);
    for (int i = 0; i < nMaxNum; i++)
    {
        aryCardID.InsertAt(i, v[i]);
    }
    return 1;
}

void CMJTable::BuildUpCards(CCardIDAry& aryCardID)
{
    assert(m_nTotalCards == aryCardID.GetSize());

    for (int i = 0; i < aryCardID.GetSize(); i++)
    {
        CARD card;
        ZeroMemory(&card, sizeof(card));
        card.nID = aryCardID[i];
        card.nShape = CalculateCardShape(aryCardID[i]);
        card.nValue = CalculateCardValue(aryCardID[i]);
        card.nStatus = 0;
        card.nChairNO = INVALID_OBJECT_ID;
        card.nChairNO2 = INVALID_OBJECT_ID;
        m_aryCard.Add(card);
    }
}

void CMJTable::CreateCardsFromFile(CCardIDAry& aryCardID)
{
    DWORD dwMade = GetPrivateProfileInt(_T("Card"), _T("Made"), 0, GetINIMakeCardName());

    if (dwMade > 0)
    {
        TCHAR szCardStr[MAX_CARDS_PER_CHAIR * MAX_CHAIR_COUNT * 8];
        memset(szCardStr, 0, sizeof(szCardStr));

        GetPrivateProfileString(
            _T("Card"),          // section name
            _T("Total"),         // key name
            _T(""),              // default string
            szCardStr,           // destination buffer
            sizeof(szCardStr),   // size of destination buffer
            GetINIMakeCardName() // initialization file name
        );
        TCHAR* fields[MAX_CARDS_PER_CHAIR * MAX_CHAIR_COUNT + 2];
        memset(fields, 0, sizeof(fields));
        TCHAR* p1, *p2;
        p1 = szCardStr;
        int nCount = UwlRetrieveFields(p1, fields, MAX_CARDS_PER_CHAIR * MAX_CHAIR_COUNT + 2, &p2);
        for (int i = 0; i < m_nTotalCards; i++)
        {
            if (fields[i] == 0)
            {
                break;
            }
            aryCardID[i] = atoi(fields[i]);
        }
    }
    else
    {
        CString sCard, sTmp;
        for (int i = 0; i < m_nTotalCards; i++)
        {
            sTmp.Format(_T("%d|"), aryCardID[i]);
            sCard = sCard + sTmp;
        }
        WritePrivateProfileString(_T("Card"), _T("Total"), sCard, GetINIMakeCardName());
    }
}

int CMJTable::CreateIntFromFile(LPCTSTR szKey, int& int_value)
{
    DWORD dwMade = GetPrivateProfileInt(_T("Card"), _T("Made"), 0, GetINIMakeCardName());

    if (dwMade > 0)
    {
        int_value = GetPrivateProfileInt(
                _T("Card"),          // section name
                szKey,               // key name
                0,                   // default value
                GetINIMakeCardName() // initialization file name
            );
    }
    else
    {
        CString sValue;
        sValue.Format(_T("%d"), int_value);
        WritePrivateProfileString(_T("Card"), szKey, sValue, GetINIMakeCardName());
    }
    return int_value;
}

int CMJTable::GetInitChairCards()
{
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_16_CARDS))
    {
        return MJ_FIRST_CATCH_16;
    }
    else
    {
        return MJ_FIRST_CATCH_13;
    }
}

void CMJTable::DealCards()
{
    int startno = m_nCatchFrom;
    int chairno = m_nFirstCatch;
    int t = 0;
    if (MJ_FIRST_CATCH_13 == GetInitChairCards())
    {
        for (t = 0; t < 3; t++)
        {
            // 每人抓3次
            chairno = m_nFirstCatch;
            for (int a = 0; a < m_nTotalChairs; a++)
            {
                // 4个人
                for (int b = 0; b < 4; b++)
                {
                    // 每次抓4张
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
            m_nCurrentOpeCard = m_aryCard[x].nID;
            m_nCurrentCard = m_aryCard[x].nID;
        }
        chairno = GetNextChair(m_nFirstCatch); // 闲家补抓1张
        for (int a = 0; a < m_nTotalChairs - 1; a++)
        {
            // 3个人
            int x = (startno++) % m_nTotalCards;
            m_aryCard[x].nStatus = CS_CAUGHT;
            m_aryCard[x].nChairNO = chairno;
            int shape = m_aryCard[x].nShape;
            int value = m_aryCard[x].nValue;
            m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
            chairno = GetNextChair(chairno);
        }
    }
    else if (MJ_FIRST_CATCH_16 == GetInitChairCards())
    {
        for (t = 0; t < 4; t++)
        {
            // 每人抓4次
            chairno = m_nFirstCatch;
            for (int a = 0; a < m_nTotalChairs; a++)
            {
                // 4个人
                for (int b = 0; b < 4; b++)
                {
                    // 每次抓4张
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
        chairno = m_nFirstCatch; // 庄家补抓1张
        int x = (startno++) % m_nTotalCards;
        m_aryCard[x].nStatus = CS_CAUGHT;
        m_aryCard[x].nChairNO = chairno;
        int shape = m_aryCard[x].nShape;
        int value = m_aryCard[x].nValue;
        m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
    }

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        GetChairCards(i, m_nStartHandCards[i], MAX_CARDS_PER_CHAIR);
    }
}

BOOL CMJTable::CheckCards()
{
    int nCardsLay[MAX_CARDS_LAYOUT_NUM];
    ZeroMemory(nCardsLay, sizeof(nCardsLay));
    int MaxIndex = m_pCalclator->MJ_CalcIndexByID(MAX_CARDSID, 0);
    int i = 0;
    for (i = 0; i < m_aryCard.GetSize(); i++)
    {
        int shape = m_aryCard[i].nShape;
        int value = m_aryCard[i].nValue;
        nCardsLay[shape * m_nLayoutMod + value]++;
    }
    for (i = 0; i < 38 && i < MaxIndex; i++)//一直到风
    {
        if (IsRestCard(i, 1))
        {
            continue;
        }
        if (i % m_nLayoutMod == 0)
        {
            continue;
        }
        if (nCardsLay[i] != m_nTotalPacks)
        {
            return FALSE;
        }
    }
    //花牌只有一张 库里函数有点问题
    for (i = 41; i < 48 && i < MaxIndex; i++)
    {
        if (nCardsLay[i] != 1)
        {
            return FALSE;
        }
    }
    return TRUE;
}

int CMJTable::GetCardNO(int nCardID)
{
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            return i;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::GetCardID(int nCardNO)
{
    assert(nCardNO >= 0 && nCardNO < m_aryCard.GetSize());
    return m_aryCard[nCardNO].nID;
}

int CMJTable::HaveCards(int chairno)
{
    return XygCardRemains(m_nCardsLayIn[chairno]);
}

BOOL CMJTable::IsCardInHand(int chairno, int nCardID)
{
    if (INVALID_OBJECT_ID == nCardID)
    {
        return FALSE;
    }

    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            if (m_aryCard[i].nChairNO == chairno)
            {
                if (CS_CAUGHT == m_aryCard[i].nStatus)
                {
                    return TRUE;
                }
            }
            return FALSE;
        }
    }
    return FALSE;
}

BOOL CMJTable::IsCardIDsInHand(int chairno, int nCardIDs[])
{
    return IsCardIDsInHandEx(chairno, nCardIDs, MAX_CARDS_PER_CHAIR);
}

BOOL CMJTable::IsCardIDsInHandEx(int chairno, int nCardIDs[], int nCardsLen)
{
    // 检查输入牌的张数，如果没有牌，返回失败
    if (XygGetCountOfCards(nCardIDs, nCardsLen) == 0)
    {
        return FALSE;
    }
    // 检查是否存在两张牌ID相同的情况
    if (!XygCardDistinct(nCardIDs, nCardsLen))
    {
        return FALSE;
    }
    for (int i = 0; i < nCardsLen; i++)
    {
        if (INVALID_OBJECT_ID == nCardIDs[i])
        {
            continue;
        }
        if (!IsCardInHand(chairno, nCardIDs[i]))
        {
            return FALSE;
        }
    }
    return TRUE;
}

int CMJTable::GetChairCards(int chairno, int nCardIDs[], int nCardsLen)
{
    int count = 0;
    XygInitChairCards(nCardIDs, nCardsLen);
    // 发现几例 手牌大于nCardsLen的地方，这里采用new一个较大的指针转存 并打错误日志
    int* nTmpCardIDs = new int[MJ_TOTAL_CARDS];
    XygInitChairCards(nTmpCardIDs, MJ_TOTAL_CARDS);

    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (INVALID_OBJECT_ID == m_aryCard[i].nID)
        {
            continue;
        }
        if (count > nCardsLen)
        {
            LOG_ERROR("GetChairCards error > nCardsLen");
        }

        if (count > MJ_TOTAL_CARDS)
        {
            LOG_ERROR("GetChairCards error > MJ_CHAIR_CARDS");
            break;
        }

        if (m_aryCard[i].nChairNO == chairno)
        {
            if (CS_CAUGHT == m_aryCard[i].nStatus)
            {
                nTmpCardIDs[count] = m_aryCard[i].nID;
                count++;
            }
        }
    }

    if (IsValidCard(m_nCurrentCard))
    {
        int nSwapNum = count > nCardsLen ? nCardsLen : count;
        for (int i = 0; i < MJ_TOTAL_CARDS; i++)
        {
            if (nTmpCardIDs[i] == m_nCurrentCard)
            {
                nTmpCardIDs[i] = nTmpCardIDs[nSwapNum - 1];
                nTmpCardIDs[nSwapNum - 1] = m_nCurrentCard;
                break;
            }
        }
    }
    memcpy(nCardIDs, nTmpCardIDs, sizeof(int) * nCardsLen);
    SAFE_DELETE_ARRAY(nTmpCardIDs);
    return count;
}

int CMJTable::GetFirstCardOfChair(int chairno)
{
    int cardid = INVALID_OBJECT_ID;

    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nChairNO == chairno)
        {
            if (CS_CAUGHT == m_aryCard[i].nStatus)
            {
                cardid = m_aryCard[i].nID;
                return cardid;
            }
        }
    }
    return cardid;
}

int CMJTable::GetChairOfCard(int nCardID)
{
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            return m_aryCard[i].nChairNO;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::GetStatusOfCard(int nCardID)
{
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            return m_aryCard[i].nStatus;
        }
    }
    return CS_UNKNOWN;
}

int CMJTable::SetStatusOfCard(int nCardID, int nStatus)
{
    int oldStatus = 0;
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            oldStatus = m_aryCard[i].nStatus;
            m_aryCard[i].nStatus = nStatus;
        }
    }
    return oldStatus;
}

int CMJTable::SetChairOfCard(int nCardID, int new_chair)
{
    int oldChair = 0;
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nID == nCardID)
        {
            oldChair = m_aryCard[i].nChairNO;
            m_aryCard[i].nChairNO = new_chair;
        }
    }
    return oldChair;
}

int CMJTable::SetChairOfCardInHand(int nCardID, int new_chair)
{
    int cardno = GetCardNO(nCardID);
    if (INVALID_OBJECT_ID == cardno)
    {
        return 0;
    }

    int status = m_aryCard[cardno].nStatus;
    int chairno = m_aryCard[cardno].nChairNO;

    if (CS_CAUGHT != status)
    {
        return 0;    // 牌不在手里
    }
    if (new_chair == chairno)
    {
        return 0;    // 位置不变
    }

    m_aryCard[cardno].nChairNO = new_chair;

    int shape = m_aryCard[cardno].nShape;
    int value = m_aryCard[cardno].nValue;
    m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]--;
    m_nCardsLayIn[new_chair][shape * m_nLayoutMod + value]++;

    return 1;
}

BOOL CMJTable::ThrowCards(int chairno, int nCardIDs[])
{
    if (!IsCardIDsInHand(chairno, nCardIDs))
    {
        LOG_ERROR(_T("ThrowCards is not InHand %d"), nCardIDs);
        return FALSE;
    }

    m_nGangKaiCount = 0;
    CancelSituationOfGang();

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
    //当前操作的牌
    m_nCurrentOpeCard = cardid;

    if (IsJoker(cardid))
    {
        OnJokerThrow(chairno, cardid);
    }
    else
    {
        OnNotJokerThrow(chairno, cardid);
    }

    //上次出牌者 和 这次出牌者之间的玩家算新一轮.
    if (m_nLastThrowChair != -1)
    {
        int next = GetNextChair(m_nLastThrowChair);
        while (next != chairno)
        {
            memset(m_nLastThrowCard[next], 0, sizeof(m_nLastThrowCard[next]));
            next = GetNextChair(next);
        }
    }

    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(huDetails));
        DWORD flags = MJ_PENG | MJ_GANG;
        if (i == GetNextChair(chairno))
        {
            // i是出牌者的下家
            flags |= MJ_CHI; // 只有下家可以吃
        }
        flags |= MJ_HU;

        // 报听玩家只能胡
        if (IS_BIT_SET(m_dwGameFlags2, MJ_HU_PRETING))
        {
            if (m_nbaoTing[i] == 1)
            {
                flags = MJ_HU;
            }
        }
        m_dwPGCHFlags[i] = CalcPGCH(i, cardid, huDetails, flags);
    }
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (ValidateGuoRecons(i, chairno))
        {
            // 可以过牌
            m_dwGuoFlags[i] |= MJ_GUO;
        }
    }

    memset(m_nLastThrowCard[chairno], 0, sizeof(m_nLastThrowCard[chairno]));
    for (i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;    //出牌者本身不用算
        }
        int index = m_pCalclator->MJ_CalcIndexByID(cardid, 0);
        m_nLastThrowCard[i][index]++;
    }
    m_nLastThrowChair = chairno;
    ResetWaitOpe();
    return TRUE;
}

int CMJTable::LoseCard(int chairno, int nCardID)
{
    int cardno = GetCardNO(nCardID);

    return LoseCardByNO(chairno, cardno);
}

int CMJTable::GainCard(int chairno, int nCardID)
{
    int cardno = GetCardNO(nCardID);

    return GainCardByNO(chairno, cardno);
}

int CMJTable::LoseCardByNO(int chairno, int nCardNO)
{
    int shape = m_aryCard[nCardNO].nShape;
    int value = m_aryCard[nCardNO].nValue;
    if (m_nCardsLayIn[chairno][shape * m_nLayoutMod + value] > 0)
    {
        m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]--;
        return 1;
    }
    else
    {
        return 0;
    }
}

int CMJTable::GainCardByNO(int chairno, int nCardNO)
{
    int shape = m_aryCard[nCardNO].nShape;
    int value = m_aryCard[nCardNO].nValue;

    m_nCardsLayIn[chairno][shape * m_nLayoutMod + value]++;
    return 1;
}

BOOL CMJTable::IsJoker(int nCardID)
{
    return m_pCalclator->MJ_IsJokerEx(nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
}

int CMJTable::LayCards(int nCardIDs[], int nCardsLen, int nCardsLay[])
{
    int count = 0;
    for (int i = 0; i < nCardsLen; i++)
    {
        if (nCardIDs[i] < 0)
        {
            continue;
        }
        int shape = CalculateCardShape(nCardIDs[i]);
        int value = CalculateCardValue(nCardIDs[i]);
        nCardsLay[shape * m_nLayoutMod + value]++;
        count++;
    }
    return count;
}

int CMJTable::LayCardsBack(int nCardsLay[], int nCardsIn[], int nCardsLen, int nCardsOut[])
{
    int count = 0;
    XygInitChairCards(nCardsOut, nCardsLen);

    for (int i = 0; i < m_nLayoutNum; i++)
    {
        if (0 == nCardsLay[i])
        {
            continue;
        }
        for (int j = 0; j < nCardsLen; j++)
        {
            int id = nCardsIn[j];
            if (id < 0)
            {
                continue;
            }
            if (GetCardIndex(id) == i)
            {
                nCardsOut[count] = id;
                count++;
            }
        }
    }
    return count;
}

int CMJTable::LayCardsReverse(int nCardsLay[], int nCardIDs[], int chairno)
{
    int count = 0;
    XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
    CCardAry aryCard;
    XygCopyCardAry(aryCard, m_aryCard);

    for (int i = 0; i < m_nLayoutNum; i++)
    {
        if (0 == nCardsLay[i])
        {
            continue;
        }
        for (int j = 0; j < nCardsLay[i]; j++)
        {
            int id = GetNextIDByIndex(aryCard, chairno, i);
            if (INVALID_OBJECT_ID != id)
            {
                nCardIDs[count] = id;
                count++;
            }
            else
            {
                break;
            }
        }
    }
    return count;
}

int CMJTable::GetNextIDByIndex(CCardAry& aryCard, int chairno, int index)
{
    int shape = index / m_nLayoutMod;
    int value = index % m_nLayoutMod;

    for (int i = 0; i < aryCard.GetSize(); i++)
    {
        int nID = aryCard[i].nID;
        int nChairNO = aryCard[i].nChairNO;
        int nShape = aryCard[i].nShape;
        int nValue = aryCard[i].nValue;
        int nStatus = aryCard[i].nStatus;
        if (INVALID_OBJECT_ID == nID)
        {
            continue;
        }
        if (chairno != nChairNO)
        {
            continue;
        }
        if (shape != nShape)
        {
            continue;
        }
        if (value != nValue)
        {
            continue;
        }
        if (CS_CAUGHT != nStatus)
        {
            continue;
        }
        aryCard[i].nStatus = CS_HIDDEN;
        return nID;
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::ReverseIndexToID(int index)
{
    int shape = index / m_nLayoutMod;
    int value = index % m_nLayoutMod;

    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        int nID = m_aryCard[i].nID;
        int nShape = m_aryCard[i].nShape;
        int nValue = m_aryCard[i].nValue;
        if (INVALID_OBJECT_ID == nID)
        {
            continue;
        }
        if (shape != nShape)
        {
            continue;
        }
        if (value != nValue)
        {
            continue;
        }
        return nID;
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::GetCardIndex(int nCardID)
{
    return CalculateCardShape(nCardID) * m_nLayoutMod + CalculateCardValue(nCardID);
}

int CMJTable::HaveDiffCards(int nCardsLay[])
{
    int count = 0;
    for (int i = 0; i < m_nLayoutNum; i++)
    {
        if (nCardsLay[i] > 0)
        {
            count++;
        }
    }
    return count;
}

int CMJTable::HaveDiffCardsEx(int nCardsLayEx[])
{
    int count = 0;
    for (int i = 0; i < m_nLayoutNumEx; i++)
    {
        if (nCardsLayEx[i] > 0)
        {
            count++;
        }
    }
    return count;
}

int CMJTable::CardRemains(int nCardsLay[])
{
    int count = 0;
    for (int i = 0; i < m_nLayoutNum; i++)
    {
        count += nCardsLay[i];
    }
    return count;
}

int CMJTable::CardRemainsEx(int nCardsLayEx[])
{
    int count = 0;
    for (int i = 0; i < m_nLayoutNumEx; i++)
    {
        count += nCardsLayEx[i];
    }
    return count;
}

int CMJTable::GetFirstCardIndex(int nCardsLay[])
{
    for (int i = 0; i < m_nLayoutNum; i++)
    {
        if (nCardsLay[i] > 0)
        {
            return i;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::GetFirstCardIndexEx(int nCardsLayEx[])
{
    for (int i = 0; i < m_nLayoutNumEx; i++)
    {
        if (nCardsLayEx[i] > 0)
        {
            return i;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::CalculateCardShape(int nID)
{
    assert(nID >= 0 && nID < m_nTotalCards);
    return m_pCalclator->MJ_CalculateCardShape(nID, m_dwGameFlags);
}

int CMJTable::CalculateCardValue(int nID)
{
    assert(nID >= 0 && nID < m_nTotalCards);
    return m_pCalclator->MJ_CalculateCardValue(nID, m_dwGameFlags);
}

DWORD CMJTable::SetStatusOnThrow()
{
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_THROW;
    m_dwStatus &= ~TS_AFTER_CHI;
    m_dwStatus &= ~TS_AFTER_PENG;
    m_dwStatus &= ~TS_AFTER_GANG;
    m_dwStatus |= TS_WAITING_CATCH;
    return m_dwStatus;
}

int CMJTable::SetCurrentChairOnThrow()
{
    SetCurrentChair(GetNextChair(GetCurrentChair()));

    return GetCurrentChair();
}

BOOL CMJTable::SetWaitingsOnThrow(int chairno, int nCardIDs[], int dwCardsType)
{
    return TRUE;
}

BOOL CMJTable::SetWaitingsOnEnd()
{
    return TRUE;
}

DWORD CMJTable::SetStatusOnCatch()
{
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_CATCH;
    m_dwStatus &= ~TS_AFTER_CHI;
    m_dwStatus &= ~TS_AFTER_PENG;
    m_dwStatus &= ~TS_AFTER_GANG;
    m_dwStatus |= TS_WAITING_THROW;
    return m_dwStatus;
}

int CMJTable::SetCurrentChairOnCatch()
{
    SetCurrentChair(GetCurrentChair());

    return GetCurrentChair();
}

DWORD CMJTable::CalcWinOnThrow(int chairno, int nCardIDs[], int dwCardsType)
{
    m_dwWinFlags = 0;
    return m_dwWinFlags;
}

BOOL CMJTable::OnAuctionBanker(LPAUCTION_BANKER pAuctionBanker, int& auction_finished)
{
    int chairno = pAuctionBanker->nChairNO;
    BOOL passed = pAuctionBanker->bPassed;
    int gains = pAuctionBanker->nGains;;

    m_nAuctionCount++;

    assert(m_nAuctionCount <= MAX_AUCTION_COUNT);

    m_Auctions[m_nAuctionCount - 1].nChairNO = chairno;
    m_Auctions[m_nAuctionCount - 1].bPassed = passed;
    m_Auctions[m_nAuctionCount - 1].nGains = gains;

    if (!IS_BIT_SET(m_dwGameFlags, GF_AUCTION_REVERSE))
    {
        if (!passed && gains >= m_nMaxAuction)
        {
            // 叫了最高分
            m_nObjectGains = gains;
            m_nBanker = chairno;
            auction_finished = 1;
        }
        else if (IS_BIT_SET(m_dwGameFlags, GF_AUCTION_ONCE)
            && m_nAuctionCount >= m_nTotalChairs)
        {
            auction_finished = 1;
            BOOL all_passed = TRUE;
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (!m_Auctions[i].bPassed)
                {
                    all_passed = FALSE;
                    if (m_Auctions[i].nGains >= m_nObjectGains)
                    {
                        m_nObjectGains = m_Auctions[i].nGains;
                        m_nBanker = m_Auctions[i].nChairNO;
                    }
                }
            }
            if (all_passed)
            {
                // 所有人都放弃
                m_nObjectGains = m_nDefAuction;
            }
        }
        else if (gains > m_nObjectGains)
        {
        }
    }
    else
    {
        // 叫分从大往小倒着叫
        if (!passed && gains <= m_nMinAuction)
        {
            // 叫了最低分
            m_nObjectGains = gains;
            m_nBanker = chairno;
            auction_finished = 1;
        }
        else if (IS_BIT_SET(m_dwGameFlags, GF_AUCTION_ONCE)
            && m_nAuctionCount >= m_nTotalChairs)
        {
            auction_finished = 1;
            BOOL all_passed = TRUE;
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (!m_Auctions[i].bPassed)
                {
                    all_passed = FALSE;
                    if (m_Auctions[i].nGains <= m_nObjectGains)
                    {
                        m_nObjectGains = m_Auctions[i].nGains;
                        m_nBanker = m_Auctions[i].nChairNO;
                    }
                }
            }
            if (all_passed)
            {
                // 所有人都放弃
                m_nObjectGains = m_nDefAuction;
            }
        }
        else if (gains < m_nObjectGains)
        {
        }
    }
    if (!auction_finished)
    {
        SetCurrentChair(GetNextChair(GetCurrentChair()));
    }
    return TRUE;
}

BOOL CMJTable::OnAuctionFinished()
{
    RemoveStatus(TS_WAITING_AUCTION);
    LOG_DEBUG("OnAuctionFinished333333333333");
    SetCurrentChair(m_nBanker);

    SetGroupsOnAuctionFinished();

    return TRUE;
}

int CMJTable::OnNoCardRemains(int chairno)
{
    return 1;
}

void CMJTable::ActuallizeResults(void* pData, int nLen)
{
    __super::ActuallizeResults(pData, nLen);

    //记录每局结果
    int nRecordIndex = (m_nBoutCount - 1) % MAX_RESULT_COUNT;
    if (m_nBoutCount > 0)
    {
        GAME_WIN* pGameWinEx = (GAME_WIN*)pData;
        if (m_nBaseDeposit)
        {
            //银子房间记录银子得失
            for (int i = 0; i < MAX_CHAIR_COUNT; i++)
            {
                m_nResultDiff[i][nRecordIndex] = pGameWinEx->nDepositDiffs[i];
                m_nTotalResult[i] += pGameWinEx->nDepositDiffs[i];
            }
        }
        else
        {
            //记录分得失
            for (int i = 0; i < MAX_CHAIR_COUNT; i++)
            {
                m_nResultDiff[i][nRecordIndex] = pGameWinEx->nScoreDiffs[i];
                m_nTotalResult[i] += pGameWinEx->nScoreDiffs[i];
            }
        }
    }

}

int CMJTable::BreakDoubleOfDeposit(int defdouble)
{
    //一起玩没有掉线赔付的概念
    if (IsYQWTable())
    {
        return 0;
    }
    return -MJ_BREAK_DOUBLE;
}

int CMJTable::CalcNextBanker(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    if (IS_BIT_SET(m_dwWinFlags, GW_STANDOFF))
    {
        // 黄庄(和局)
        return GetNextChair(m_nBanker);
    }
    else if (pGameWin->nHuCount)
    {
        return GetNextBoutBanker();
    }
    return 0;
}

int CMJTable::CalcBankerHold(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    if (pGameWin->nNextBanker == m_nBanker)
    {
        // 下局连庄
        m_nBankerHold++;
    }
    else
    {
        m_nBankerHold = 1;  // 换庄
    }
    return m_nBankerHold;
}

int CMJTable::CalcBankerChairBefore()
{
    int result = 0;
    if (1 == m_nBoutCount)
    {
        // 第一局
        result = XygGetRandomBetween(m_nTotalChairs);
    }
    else
    {
        result = m_nBanker;
    }

#ifdef _MAKECARD
    CreateIntFromFile(_T("Banker"), result);
#endif
    return result;
}

int CMJTable::CalcBankerChairAfter(void* pData, int nLen)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    CalcBankerHold(pData, nLen);
    return pGameWin->nNextBanker;
}

int CMJTable::PlusJokerIDFromShown(int shownid)
{
    switch (shownid)
    {
    case 35:
        return 0;
    case 71:
        return 36;
    case 107:
        return 72;
    case 111: //北风
    case 118:
    case 125:
    case 132:
        return 108;//东风
    case 114:
    case 121:
    case 128:
    case 135:
        return  112;//中风
    default:
        return (shownid + 1);
    }
    return 0;
}

int CMJTable::CalcAfterDeal()
{
    if (MJ_FIRST_CATCH_13 == GetInitChairCards())
    {
        m_nHeadTaken = (MJ_FIRST_CATCH_13 * m_nTotalChairs) + 1;
    }
    else if (MJ_FIRST_CATCH_16 == GetInitChairCards())
    {
        m_nHeadTaken = (MJ_FIRST_CATCH_16 * m_nTotalChairs) + 1;
    }
    m_nCurrentCatch = (m_nCatchFrom + m_nHeadTaken) % m_nTotalCards;

    int fengCount = 0;
    int i = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        int nHuaID = GetNextHuaID(i);
        while (INVALID_OBJECT_ID != nHuaID)
        {
            HuaCard(i, nHuaID);
            nHuaID = GetNextHuaID(i);
        }
    }

    // 补花重置当前可操作牌m_nCurrentOpeCard的id
    int nCardsInHand[MJ_INIT_HAND_CARDS];
    int nCount = GetChairCards(m_nBanker, nCardsInHand, MJ_INIT_HAND_CARDS);
    m_nCurrentOpeCard = nCardsInHand[nCount - 1];

    return 1;
}

DWORD CMJTable::SetStatusOnStart()
{
    m_dwStatusBegin = GetTickCount();
    m_dwStatus |= TS_PLAYING_GAME;
    m_dwStatus |= TS_WAITING_THROW;
    return m_dwStatus;
}

int CMJTable::GetJokerNumInHand(int chairno)
{
    int jokernum = 0;
    int jokernum2 = 0;

    jokernum = m_pCalclator->MJ_GetJokerNum(m_nCardsLayIn[chairno], m_nJokerID, m_nJokerID2, m_dwGameFlags, jokernum2);
    return jokernum + jokernum2;
}

BOOL CMJTable::IsHua(int nCardID)
{
    return m_pCalclator->MJ_IsHuaEx(nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
}

int CMJTable::ValidateThrow(int chairno, int nCardsOut[], int nOutCount, DWORD dwCardsType, int nValidIDs[])
{
    // 若支持报听胡牌，出的牌必定都是抓到的牌，这里做一个强验证
    if (IS_BIT_SET(m_dwGameFlags2, MJ_GR_PREHU_TINGCARD))
    {
        if (m_nCurrentCard != nCardsOut[0])
        {
            UwlLogFile(_T("ValidateThrow() return 0.  baoting judge error"));
            return 0;
        }
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_MN))
    {
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_PN))
    {
        return 0;
    }

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }

    memcpy(nValidIDs, nCardsOut, sizeof(int)* MAX_CARDS_PER_CHAIR);

    return 1;
}

DWORD CMJTable::SetStatusOnPeng(int chairno)
{
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_CATCH;
    m_dwStatus |= TS_WAITING_THROW;
    m_dwStatus |= TS_AFTER_PENG;
    return m_dwStatus;
}

int CMJTable::SetCurrentChairOnPeng(int chairno)
{
    SetCurrentChair(chairno);
    return GetCurrentChair();
}

DWORD CMJTable::SetStatusOnChi(int chairno)
{
    m_dwStatusBegin = GetTickCount();
    m_dwStatus &= ~TS_WAITING_CATCH;
    m_dwStatus |= TS_WAITING_THROW;
    m_dwStatus |= TS_AFTER_CHI;
    return m_dwStatus;
}

int CMJTable::SetCurrentChairOnChi(int chairno)
{
    SetCurrentChair(chairno);
    return GetCurrentChair();
}

DWORD CMJTable::SetStatusOnGang(int chairno)
{
    m_dwStatusBegin = GetTickCount();

    m_dwStatus &= ~TS_AFTER_CHI;
    m_dwStatus &= ~TS_AFTER_PENG;

    if (OnGangCardFailed(chairno))
    {
        m_dwStatus &= ~TS_WAITING_THROW;
        m_dwStatus |= TS_WAITING_CATCH;
    }
    else
    {
        m_dwStatus &= ~TS_WAITING_CATCH;
        m_dwStatus |= TS_WAITING_THROW;
        m_dwStatus |= TS_AFTER_GANG;
    }
    return m_dwStatus;
}

int CMJTable::SetCurrentChairOnGang(int chairno)
{
    if (OnGangCardFailed(chairno))
    {
        SetCurrentChair(GetNextChair(chairno));
    }
    else
    {
        SetCurrentChair(chairno);
    }
    return GetCurrentChair();
}

BOOL CMJTable::ValidateAutoCatch(int chairno, int& diff, bool bQuickCatch)
{
    if (chairno != GetCurrentChair())
    {
        return FALSE;
    }

    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        return FALSE;
    }

    if (IsYQWTable())
    {
        //一起玩桌子  不能受时间限制快速抓牌

        diff = GetTickCount() - m_dwActionStart;
        //一起玩自动托管模式，而且超时，则自动跳过其他人的吃碰杠状态，直接抓牌
        if (diff > 1000 * (m_nPGCHWait + MJ_PGCH_WAIT_EXT) && (IsYQWAutoPlay() || IsYQWQuickRoom()))
        {
            ZeroMemory(m_dwPGCHFlags, sizeof(m_dwPGCHFlags));
            return TRUE;
        }
        if (!bQuickCatch && !IsOffline(chairno))
        {
            return FALSE;
        }
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (!bQuickCatch && (i == chairno || i == GetPrevChair(chairno)))
            {
                continue;
            }
            if (m_dwPGCHFlags[i])
            {
                return FALSE;
            }
        }
        return TRUE;
    }
    else
    {
        diff = GetTickCount() - m_dwActionStart;
        if (diff <= 1000 * (m_nPGCHWait + MJ_PGCH_WAIT_EXT))
        {
            if (!bQuickCatch && !IsOffline(chairno))
            {
                return FALSE;
            }
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (!bQuickCatch && (i == chairno || i == GetPrevChair(chairno)))
                {
                    continue;
                }
                if (m_dwPGCHFlags[i])
                {
                    return FALSE;
                }
            }
        }
        return TRUE;
    }
}

BOOL CMJTable::ValidateAutoThrow(int chairno)
{
    int diff = GetTickCount() - m_dwActionStart;
    if ((diff <= 1000 * (m_nThrowWait + THROW_WAIT_EXT)) && !IsOffline(chairno))
    {
        return FALSE;
    }

    return TRUE;
}

int CMJTable::ValidateCatch(int chairno)
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (GetTickCount() - m_dwLatestThrow < 500 + (m_nPGCHWait - 1) * 1000 || IsYQWTable())
    {
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (i == chairno || i == GetPrevChair(chairno))
            {
                continue;
            }
            if (m_dwPGCHFlags[i])
            {
                return 0;
            }
        }
    }
    //吃碰杠消息重构 如果有人要等 则不能自动抓牌
    if (m_dwWaitOpeFlag)
    {
        return 0;
    }
    return 1;
}

int CMJTable::CatchCard(int chairno, BOOL& bBuHua)
{
    if (chairno < 0 || chairno >= m_nTotalChairs)
    {
        return INVALID_OBJECT_ID;
    }

    m_nLastGangNO = -1;
    m_nGangKaiCount = 0;

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

        return current_catch;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMJTable::ThrowJokerShown(int chairno)
{
    m_aryCard[m_nCurrentCatch].nStatus = CS_OUT;
    m_nHeadTaken++;
    m_nCurrentCatch = (m_nCurrentCatch + 1) % m_nTotalCards;
    return m_nCurrentCatch;
}

BOOL CMJTable::ValidateGuo(int chairno, int chairout)
{
    if (chairno == chairout)
    {
        // 不能过自己的牌
        return FALSE;
    }
    if (0 == m_dwPGCHFlags[chairno])
    {
        // 不能碰杠吃胡就不能过牌
        return FALSE;
    }
    // 发送者要碰杠吃胡
    //if (m_dwPGCHFlags[chairno])
    //{
    //    for (int i = 0; i < m_nTotalChairs; i++)
    //    {
    //        if (i == chairno || i == chairout)
    //        {
    //            continue;
    //        }
    //        if (m_dwPGCHFlags[i])
    //        {
    //            return FALSE;
    //        }
    //    }
    //}
    if (IS_BIT_SET(m_dwPGCHFlags[chairno], MJ_CHI))
    {
        if (chairno != GetNextChair(chairout))
        {
            return FALSE;
        }
    }
    return TRUE;
}

BOOL CMJTable::ValidatePrePeng(LPPREPENG_CARD pPrePengCard)
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidatePreGang(LPPREGANG_CARD pPreGangCard)
{
    int chairno = pPreGangCard->nChairNO;
    int cardchair = pPreGangCard->nCardChair;
    int* baseids = pPreGangCard->nBaseIDs;
    int cardid = pPreGangCard->nCardID;

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    DWORD flags = pPreGangCard->dwFlags;
    if (IS_BIT_SET(flags, MJ_GANG_MN))
    {
        // 明杠
        if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
        {
            // 不是等待抓牌状态
            return 0;
        }
        if (!IsCardIDsInHandEx(chairno, baseids, MJ_UNIT_LEN - 1))
        {
            // 手里没有待杠的牌
            return 0;
        }
        if (cardchair != GetChairOfCard(cardid))
        {
            // 打出的牌不属于打出者
            return 0;
        }
        if (CS_OUT != GetStatusOfCard(cardid))
        {
            // 牌未处于打出状态
            return 0;
        }
    }
    else if (IS_BIT_SET(flags, MJ_GANG_PN))
    {
        // 碰杠
        if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
        {
            // 不是等待出牌状态
            return 0;
        }
        if (!IsCardIDsPengCards(chairno, baseids, MJ_UNIT_LEN - 1))
        {
            // 碰出的牌里没有待杠的牌
            return 0;
        }
        if (cardchair != GetChairOfCard(cardid))
        {
            // 杠牌不属于杠牌者
            return 0;
        }
        if (CS_CAUGHT != GetStatusOfCard(cardid))
        {
            // 牌未处于摸进状态
            return 0;
        }
    }
    else if (IS_BIT_SET(flags, MJ_GANG_AN))
    {
        if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
        {
            return 0;
        }
        if (!IsCardIDsInHandEx(chairno, baseids, MJ_UNIT_LEN - 1))
        {
            // 手中的牌里没有待杠的牌
            return 0;
        }
        if (cardchair != GetChairOfCard(cardid))
        {
            // 杠牌不属于杠牌者
            return 0;
        }
        if (CS_CAUGHT != GetStatusOfCard(cardid))
        {
            // 牌未处于摸进状态
            return 0;
        }
        if (cardchair != chairno)
        {
            return 0;
        }
    }
    return TRUE;
}

BOOL CMJTable::ValidatePreChi(LPPRECHI_CARD pPreChiCard)
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidatePeng(LPPENG_CARD pPengCard)
{
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;
    int* baseids = pPengCard->nBaseIDs;
    int cardid = pPengCard->nCardID;

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        // 不是等待抓牌状态
        return 0;
    }
    if (chairno == cardchair)
    {
        return 0;
    }

    if (!IsCardIDsInHandEx(chairno, baseids, 2))
    {
        // 手里没有待碰的牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 打出的牌不属于打出者
        return 0;
    }
    if (CS_OUT != GetStatusOfCard(cardid))
    {
        // 牌未处于打出状态
        return 0;
    }
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        // 支持财飘
        if (INVALID_OBJECT_ID != m_nCaiPiaoChair && m_nCaiPiaoCount)
        {
            // 有人财飘
            return 0;
        }
    }
    if (m_nCurrentOpeCard != pPengCard->nCardID)
    {
        UwlLogFile("ValidatePeng error, m_nCurrentOpeCard[%d] != nCardID[%d]", m_nCurrentOpeCard, pPengCard->nCardID);
        return 0;
    }
    if (!CalcPeng(chairno, cardid))
    {
        // 不能碰
        return 0;
    }
    int nResultIDs[2];
    if (!m_pCalclator->MJ_CanPengEx(baseids, 2, cardid, m_nJokerID, m_nJokerID2, m_dwGameFlags, nResultIDs))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidateChi(LPCHI_CARD pChiCard)
{
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;
    int* baseids = pChiCard->nBaseIDs;
    int cardid = pChiCard->nCardID;

    if (chairno != GetCurrentChair())
    {
        // 不轮到吃牌
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        // 不是等待抓牌状态
        return 0;
    }
    if (chairno == cardchair || chairno != GetNextChair(cardchair))
    {
        return 0;    // 不是下家不能吃牌
    }

    if (!IsCardIDsInHandEx(chairno, baseids, 2))
    {
        // 手里没有待吃的牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 打出的牌不属于打出者
        return 0;
    }
    if (CS_OUT != GetStatusOfCard(cardid))
    {
        // 牌未处于打出状态
        return 0;
    }
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        // 支持财飘
        if (INVALID_OBJECT_ID != m_nCaiPiaoChair && m_nCaiPiaoCount)
        {
            // 有人财飘
            return 0;
        }
    }
    if (m_nCurrentOpeCard != pChiCard->nCardID)
    {
        UwlLogFile("ValidateChi error, m_nCurrentOpeCard[%d] != nCardID[%d]", m_nCurrentOpeCard, pChiCard->nCardID);
        return 0;
    }
    if (!CalcChi(chairno, cardid))
    {
        // 不能吃
        return 0;
    }
    int nResultIDs[2];
    if (!m_pCalclator->MJ_CanChiEx(baseids, 2, cardid, m_nJokerID, m_nJokerID2, m_dwGameFlags, nResultIDs))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidateMnGang(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        // 不是等待抓牌状态
        return 0;
    }
    if (chairno == cardchair)
    {
        return 0;
    }

    if (!IsCardIDsInHandEx(chairno, baseids, MJ_UNIT_LEN - 1))
    {
        // 手里没有待杠的牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 打出的牌不属于打出者
        return 0;
    }
    if (CS_OUT != GetStatusOfCard(cardid))
    {
        // 牌未处于打出状态
        return 0;
    }
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        // 支持财飘
        if (INVALID_OBJECT_ID != m_nCaiPiaoChair && m_nCaiPiaoCount)
        {
            // 有人财飘
            return 0;
        }
    }
    if (m_nCurrentOpeCard != pGangCard->nCardID)
    {
        UwlLogFile("ValidateMnGang error, m_nCurrentOpeCard[%d] != nCardID[%d]", m_nCurrentOpeCard, pGangCard->nCardID);
        return 0;
    }
    if (!CalcGang(chairno, cardid, MJ_GANG_MN))
    {
        // 不能杠
        return 0;
    }
    int nResultIDs[3];
    if (!m_pCalclator->MJ_CanMnGangEx(baseids, 3, cardid, m_nJokerID, m_nJokerID2, m_dwGameFlags, nResultIDs))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidateAnGang(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    if (chairno != GetCurrentChair())
    {
        // 不轮到此位置
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (chairno != cardchair)
    {
        return 0;
    }

    if (!IsCardIDsInHandEx(chairno, baseids, MJ_UNIT_LEN - 1))
    {
        // 手里没有待杠的牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 杠牌不属于自己
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (!CalcGang(chairno, cardid, MJ_GANG_AN))
    {
        // 不能杠
        return 0;
    }
    int baseids_ex[4];
    memcpy(baseids_ex, baseids, sizeof(baseids_ex));
    baseids_ex[3] = cardid;
    int nResultIDs[4];
    if (!m_pCalclator->MJ_CanAnGangEx(baseids_ex, 4, cardid, m_nJokerID, m_nJokerID2, m_dwGameFlags, nResultIDs))
    {
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidatePnGang(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    if (chairno != GetCurrentChair())
    {
        // 不轮到此位置
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (chairno != cardchair)
    {
        return 0;
    }

    if (!IsCardIDsPengCards(chairno, baseids, MJ_UNIT_LEN - 1))
    {
        // 碰出的牌里没有待杠的牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 杠牌不属于自己
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (!CalcGang(chairno, cardid, MJ_GANG_PN))
    {
        // 不能杠
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ValidateHua(LPHUA_CARD pHuaCard)
{
    int chairno = pHuaCard->nChairNO;
    int cardid = pHuaCard->nCardID;

    if (chairno != GetCurrentChair())
    {
        // 不轮到此位置
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (chairno != GetChairOfCard(cardid))
    {
        // 花牌不属于自己
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (!CalcHua(chairno, cardid))
    {
        // 不能补花
        return 0;
    }
    return TRUE;
}

BOOL CMJTable::ShouldPengWait(LPPENG_CARD pPengCard)
{
    int chairno = pPengCard->nChairNO;

    BOOL bSomeoneHu = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }
        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bSomeoneHu = TRUE;
            break;
        }
    }
    if (bSomeoneHu)
    {
        if (GetTickCount() - m_dwLatestThrow < (m_nPGCHWait - 1) * 1000)
        {
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::ShouldChiWait(LPCHI_CARD pChiCard)
{
    int chairno = pChiCard->nChairNO;

    BOOL bSomeonePGH = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }
        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_PENG)
            || IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG)
            || IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bSomeonePGH = TRUE;
            break;
        }
    }
    if (bSomeonePGH)
    {
        if (GetTickCount() - m_dwLatestThrow < (m_nPGCHWait - 1) * 1000)
        {
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::ShouldMnGangWait(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardid = pGangCard->nCardID;
    int cardchair = pGangCard->nCardChair;

    BOOL bSomeoneHu = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == chairno)
        {
            continue;
        }
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(huDetails));

        DWORD flags = MJ_HU_QGNG;
        DWORD dwResult = CalcHu_Various(i, cardid, huDetails, flags);
        if (IS_BIT_SET(dwResult, MJ_HU))
        {
            bSomeoneHu = TRUE;
            break;
        }
    }
    if (bSomeoneHu)
    {
        if (GetTickCount() - m_dwLatestThrow < (m_nPGCHWait - 1) * 1000)
        {
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::ShouldPnGangWait(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardid = pGangCard->nCardID;
    int cardchair = pGangCard->nCardChair;

    BOOL bSomeoneHu = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == chairno)
        {
            continue;
        }
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(huDetails));

        DWORD flags = MJ_HU_QGNG;
        DWORD dwResult = CalcHu_Various(i, cardid, huDetails, flags);
        if (IS_BIT_SET(dwResult, MJ_HU))
        {
            bSomeoneHu = TRUE;
            break;
        }
    }
    if (bSomeoneHu)
    {
        if (IsYQWTable())
        {
            return TRUE;
        }
        if (GetTickCount() - m_dwLatestPreGang < (m_nPGCHWait - 1) * 1000)
        {
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::ValidateHu(LPHU_CARD pHuCard)
{
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;
    int cardid = pHuCard->nCardID;

    if (GetUseServerHuCardID())
    {
        UseServerHuCardID(cardid);
    }

    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }
    DWORD flags = pHuCard->dwFlags;
    DWORD subflags = pHuCard->dwSubFlags;

    if (IS_BIT_SET(flags, MJ_HU_QGNG))
    {
        // 抢杠
        if (IS_BIT_SET(subflags, MJ_GANG_MN))
        {
            // 抢明杠
            return ValidateHuQgng_Mn(chairno, cardchair, cardid);
        }
        else if (IS_BIT_SET(subflags, MJ_GANG_PN))
        {
            // 抢碰杠
            return ValidateHuQgng_Pn(chairno, cardchair, cardid);
        }
        else if (IS_BIT_SET(subflags, MJ_GANG_AN))
        {
            return ValidateHuQgng_An(chairno, cardchair, cardid);
        }
    }
    else if (IS_BIT_SET(flags, MJ_HU_FANG))
    {
        // 放冲
        return ValidateHuFang(chairno, cardchair, cardid);
    }
    else if (IS_BIT_SET(flags, MJ_HU_ZIMO))
    {
        // 自摸
        return ValidateHuZimo(chairno, cardchair, cardid);
    }
    else {}
    return 0;
}

int CMJTable::ValidateHuQgng_Mn(int chairno, int cardchair, int cardid)
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_MN_ROB))
    {
        // 不允许抢明杠
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        // 不是等待抓牌状态
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 打出的牌不属于打出者
        return 0;
    }
    if (CS_OUT != GetStatusOfCard(cardid))
    {
        // 牌未处于打出状态
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, MJ_TS_GANG_MN))
    {
        // 不是明杠状态
        return 0;
    }
    if (m_nGangID != cardid || m_nCardChair != cardchair)
    {
        return 0;
    }
    if (m_nGangChair == chairno)
    {
        //
        return 0;
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));
    if (!CalcHu(chairno, cardid, huDetails, MJ_HU_QGNG))
    {
        return 0;
    }
    return 1;
}

int CMJTable::ValidateHuQgng_Pn(int chairno, int cardchair, int cardid)
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_PN_ROB))
    {
        // 不允许抢碰杠
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 牌不属于该玩家
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, MJ_TS_GANG_PN))
    {
        // 不是碰杠状态
        return 0;
    }
    if (m_nGangID != cardid || m_nCardChair != cardchair)
    {
        return 0;
    }
    if (m_nGangChair == chairno)
    {
        //
        return 0;
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));
    if (!CalcHu(chairno, cardid, huDetails, MJ_HU_QGNG))
    {
        return 0;
    }
    return 1;
}

int CMJTable::ValidateHuFang(int chairno, int cardchair, int cardid)
{
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_CATCH))
    {
        // 不是等待抓牌状态
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 打出的牌不属于打出者
        return 0;
    }
    if (CS_OUT != GetStatusOfCard(cardid))
    {
        // 牌未处于打出状态
        return 0;
    }
    if (cardchair == chairno)
    {
        // 不能自己放自己炮
        return 0;
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));
    if (!CalcHu(chairno, cardid, huDetails, MJ_HU_FANG))
    {
        return 0;
    }
    return 1;
}

int CMJTable::ValidateHuZimo(int chairno, int cardchair, int cardid)
{
    if (chairno != GetCurrentChair())
    {
        // 不轮到此位置
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (IS_BIT_SET(m_dwStatus, TS_AFTER_CHI)
        || IS_BIT_SET(m_dwStatus, TS_AFTER_PENG))
    {
        // 吃碰后不能胡，必须打牌
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 牌不属于该玩家
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (cardchair != chairno)
    {
        // 不能自摸别人的牌胡
        return 0;
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));
    if (!CalcHu(chairno, cardid, huDetails, MJ_HU_ZIMO))
    {
        return 0;
    }
    return 1;
}

int CMJTable::OnGuo(int chairno, int chairout)
{
    return 0;
}

int CMJTable::OnPrePeng(LPPREPENG_CARD pPrePengCard)
{
    return 0;
}

int CMJTable::OnPreGang(LPPREGANG_CARD pPreGangCard)
{
    DWORD flags = pPreGangCard->dwFlags;
    if (IS_BIT_SET(flags, MJ_GANG_MN))
    {
        // 明杠
        AddStatus(MJ_TS_GANG_MN);
        m_nGangID = pPreGangCard->nCardID;
        m_nCardChair = pPreGangCard->nCardChair;
        m_nGangChair = pPreGangCard->nChairNO;
    }
    else if (IS_BIT_SET(flags, MJ_GANG_PN))
    {
        // 碰杠
        AddStatus(MJ_TS_GANG_PN);
        m_nGangID = pPreGangCard->nCardID;
        m_nCardChair = pPreGangCard->nChairNO;
        m_nGangChair = pPreGangCard->nChairNO;
    }
    else if (IS_BIT_SET(flags, MJ_GANG_AN))
    {
        AddStatus(MJ_TS_GANG_AN);
        m_nGangID = pPreGangCard->nCardID;
        m_nCardChair = pPreGangCard->nChairNO;
        m_nCardChair = pPreGangCard->nChairNO;
    }
    m_dwLatestPreGang = GetTickCount();
    return 0;
}

int CMJTable::OnPreChi(LPPRECHI_CARD pPreChiCard)
{
    return 0;
}

int CMJTable::OnPeng(LPPENG_CARD pPengCard)
{
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;
    int* baseids = pPengCard->nBaseIDs;
    int cardid = pPengCard->nCardID;

    m_nGangKaiCount = 0;

    CancelSituationOfGang();
    CancelSituationInCard();

    for (int i = 0; i < 2; i++)
    {
        if (INVALID_OBJECT_ID == baseids[i])
        {
            continue;
        }
        SetStatusOfCard(baseids[i], MJ_STAT_PENG_OUT);
    }
    SetStatusOfCard(cardid, MJ_STAT_PENG_IN);

    CARDS_UNIT cards_unit = { 0 };
    MJ_InitializeCardsUnit(cards_unit);

    cards_unit.nCardIDs[0] = baseids[0];
    cards_unit.nCardIDs[1] = baseids[1];
    cards_unit.nCardIDs[2] = cardid;
    cards_unit.nCardChair = cardchair;

    m_PengCards[chairno].Add(cards_unit);

    int idx = FindCardID(m_nOutCards[cardchair], cardid);
    m_nOutCards[cardchair].RemoveAt(idx);

    LoseCard(chairno, baseids[0]);
    LoseCard(chairno, baseids[1]);

    SetStatusOnPeng(chairno);
    SetCurrentChairOnPeng(chairno);

    m_nPengFeedCount[cardchair][chairno]++;

    CalcPengGains(pPengCard);

    return 0;
}

int CMJTable::OnChi(LPCHI_CARD pChiCard)
{
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;
    int* baseids = pChiCard->nBaseIDs;
    int cardid = pChiCard->nCardID;

    m_nGangKaiCount = 0;

    CancelSituationOfGang();
    CancelSituationInCard();

    for (int i = 0; i < 2; i++)
    {
        if (INVALID_OBJECT_ID == baseids[i])
        {
            continue;
        }
        SetStatusOfCard(baseids[i], MJ_STAT_CHI_OUT);
    }
    SetStatusOfCard(cardid, MJ_STAT_CHI_IN);

    CARDS_UNIT cards_unit = { 0 };
    MJ_InitializeCardsUnit(cards_unit);

    cards_unit.nCardIDs[0] = baseids[0];
    cards_unit.nCardIDs[1] = baseids[1];
    cards_unit.nCardIDs[2] = cardid;
    cards_unit.nCardChair = cardchair;

    m_ChiCards[chairno].Add(cards_unit);

    int idx = FindCardID(m_nOutCards[cardchair], cardid);
    m_nOutCards[cardchair].RemoveAt(idx);

    LoseCard(chairno, baseids[0]);
    LoseCard(chairno, baseids[1]);

    SetStatusOnChi(chairno);
    SetCurrentChairOnChi(chairno);

    m_nChiFeedCount[cardchair][chairno]++;

    CalcChiGains(pChiCard);

    return 0;
}

int CMJTable::OnMnGang(LPGANG_CARD pGangCard)
{
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

    m_nGangFeedCount[cardchair][chairno]++;

    CalcMnGangGains(pGangCard);
    m_nQghFlag = 0;
    m_nQghID = -1;
    m_nQghChair = -1;

    return 0;
}

int CMJTable::OnAnGang(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    m_nGangKaiCount++;

    CancelSituationOfGang();

    for (int i = 0; i < MJ_UNIT_LEN - 1; i++)
    {
        if (INVALID_OBJECT_ID == baseids[i])
        {
            continue;
        }
        SetStatusOfCard(baseids[i], MJ_STAT_GANG_OUT);
    }
    SetStatusOfCard(cardid, MJ_STAT_GANG_OUT);

    CARDS_UNIT cards_unit = { 0 };
    MJ_InitializeCardsUnit(cards_unit);

    cards_unit.nCardIDs[0] = baseids[0];
    cards_unit.nCardIDs[1] = baseids[1];
    cards_unit.nCardIDs[2] = baseids[2];
    cards_unit.nCardIDs[3] = cardid;
    cards_unit.nCardChair = cardchair;

    m_AnGangCards[chairno].Add(cards_unit);

    LoseCard(chairno, baseids[0]);
    LoseCard(chairno, baseids[1]);
    LoseCard(chairno, baseids[2]);
    LoseCard(chairno, cardid);

    SetStatusOnGang(chairno);
    SetCurrentChairOnGang(chairno);

    CalcAnGangGains(pGangCard);

    return 0;
}

int CMJTable::OnPnGang(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    int* baseids = pGangCard->nBaseIDs;
    int cardid = pGangCard->nCardID;

    m_nGangKaiCount++;

    CancelSituationOfGang();
    CancelSituationInCard();

    if (MJ_STAT_PENG_OUT == GetStatusOfCard(baseids[0]))
    {
        SetStatusOfCard(baseids[0], MJ_STAT_GANG_OUT);
    }
    else if (MJ_STAT_PENG_IN == GetStatusOfCard(baseids[0]))
    {
        SetStatusOfCard(baseids[0], MJ_STAT_GANG_IN);
    }
    if (MJ_STAT_PENG_OUT == GetStatusOfCard(baseids[1]))
    {
        SetStatusOfCard(baseids[1], MJ_STAT_GANG_OUT);
    }
    else if (MJ_STAT_PENG_IN == GetStatusOfCard(baseids[1]))
    {
        SetStatusOfCard(baseids[1], MJ_STAT_GANG_IN);
    }
    if (MJ_STAT_PENG_OUT == GetStatusOfCard(baseids[2]))
    {
        SetStatusOfCard(baseids[2], MJ_STAT_GANG_OUT);
    }
    else if (MJ_STAT_PENG_IN == GetStatusOfCard(baseids[2]))
    {
        SetStatusOfCard(baseids[2], MJ_STAT_GANG_IN);
    }
    SetStatusOfCard(cardid, MJ_STAT_GANG_OUT);

    //RemovePengCards(chairno, baseids, MJ_UNIT_LEN-1);

    CARDS_UNIT cards_unit = { 0 };
    MJ_InitializeCardsUnit(cards_unit);

    cards_unit.nCardIDs[0] = baseids[0];
    cards_unit.nCardIDs[1] = baseids[1];
    cards_unit.nCardIDs[2] = baseids[2];
    cards_unit.nCardIDs[3] = cardid;
    cards_unit.nCardChair = cardchair;

    m_PnGangCards[chairno].Add(cards_unit);

    LoseCard(chairno, cardid);

    SetStatusOnGang(chairno);
    SetCurrentChairOnGang(chairno);

    CalcPnGangGains(pGangCard);
    m_nQghFlag = 0;
    m_nQghID = -1;
    m_nQghChair = -1;

    return 0;
}

int CMJTable::OnHua(LPHUA_CARD pHuaCard)
{
    int chairno = pHuaCard->nChairNO;
    int cardid = pHuaCard->nCardID;

    m_nGangKaiCount++;

    CancelSituationOfGang();

    SetStatusOfCard(cardid, MJ_STAT_HUA_OUT);

    m_nHuaCards[chairno].Add(cardid);

    LoseCard(chairno, cardid);

    SetStatusOnGang(chairno);
    SetCurrentChairOnGang(chairno);

    CalcHuaGains(pHuaCard);

    return 0;
}

int CMJTable::GetGangCard(int chairno, BOOL& bBuHua)
{
    if (GangCardFail(chairno))
    {
        // 没有牌可以杠
        return INVALID_OBJECT_ID;
    }
    BOOL joker_jump = FALSE;
    int gangno = m_pCalclator->MJ_GetGangNO(m_nCatchFrom, m_nJokerNO, m_nTotalCards, m_nTailTaken, joker_jump);

    if (CS_BLACK != m_aryCard[gangno].nStatus)
    {
        // 牌已被摸,跳过
        gangno++;
    }
    else if (joker_jump)
    {
        // 杠到财神,扔掉
        m_aryCard[m_nJokerNO].nStatus = CS_OUT;
        m_aryCard[m_nJokerNO].nChairNO = chairno;
    }
    GainCardByNO(chairno, gangno);
    m_aryCard[gangno].nStatus = CS_CAUGHT;
    m_aryCard[gangno].nChairNO = chairno;

    m_nCatchCount[chairno]++;
    m_nLastGangNO = gangno;

    // 增加的部分
    m_nCurrentCard = m_aryCard[m_nLastGangNO].nID;
    m_nCurrentOpeCard = m_aryCard[m_nLastGangNO].nID;

    if (IsHua(m_aryCard[gangno].nID))
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
            return GetGangCard(chairno, bBuHua);
        }
    }
    return m_aryCard[gangno].nID;
}

int CMJTable::GetNextHuaID(int chairno)
{
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        if (m_aryCard[i].nChairNO == chairno)
        {
            if (CS_CAUGHT == m_aryCard[i].nStatus)
            {
                if (m_pCalclator->MJ_IsHuaEx(m_aryCard[i].nID, m_nJokerID, m_nJokerID2, m_dwGameFlags))
                {
                    return m_aryCard[i].nID;
                }
            }
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::HuaCard(int chairno, int huaid)
{
    BOOL bBuHua = FALSE;
    int nCardID = GetGangCard(chairno, bBuHua);

    HUA_CARD HuaCard;
    memset(&HuaCard, 0, sizeof(HuaCard));

    HuaCard.nChairNO = chairno;
    HuaCard.nCardID = huaid;

    OnHua(&HuaCard);

    return nCardID;
}

int CMJTable::CalcPengGains(LPPENG_CARD pPengCard)
{
    return 0;
}

int CMJTable::CalcChiGains(LPCHI_CARD pChiCard)
{
    return 0;
}

int CMJTable::CalcMnGangGains(LPGANG_CARD pGangCard)
{
    return 0;
}

int CMJTable::CalcAnGangGains(LPGANG_CARD pGangCard)
{
    return 0;
}

int CMJTable::CalcPnGangGains(LPGANG_CARD pGangCard)
{
    return 0;
}

int CMJTable::CalcHuaGains(LPHUA_CARD pHuaCard)
{
    return 0;
}

int CMJTable::OnHu(LPHU_CARD pHuCard)
{
    memset(m_nResults, 0, sizeof(m_nResults));          // 胡牌返回

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
        CancelSituationOfGang();
        CancelSituationInCard();
    }
    else
    {
        // 还原胡牌前分数信息
        memcpy(m_huDetails, huDetails, sizeof(m_huDetails));    // 胡牌详细(包含胡牌前分数信息)
    }
    return hu_count;
}

int CMJTable::OnHuQgng_Mn(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == m_nGangChair)
        {
            continue;
        }
        m_nResults[i] = CanHu(i, cardid, m_huDetails[i], MJ_HU_QGNG);
        if (m_nResults[i] > 0)
        {
            hu_count++;
        }
    }
    if (hu_count > 1)
    {
        // 不止一个人胡牌
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_ONE_THROW_MULTIHU))
        {
            // 不支持一炮多响
            int ch = GetNextChair(cardchair);
            do
            {
                if (m_nResults[ch] > 0)
                {
                    break;
                }
                ch = GetNextChair(ch);
            } while (ch != cardchair);
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (i != ch && m_nResults[i] > 0)
                {
                    m_nResults[i] = 0;
                    hu_count--;
                }
            }
        }
    }
    if (hu_count > 0)
    {
        // 胡牌成功
        m_nLoseChair = m_nGangChair;        // 被抢杠者位置
        m_nHuCount = hu_count;          // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID

        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                m_nHuChair = i;
                break;
            }
        }
    }
    return hu_count;
}

int CMJTable::OnHuQgng_Pn(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == m_nGangChair)
        {
            continue;
        }
        m_nResults[i] = CanHu(i, cardid, m_huDetails[i], MJ_HU_QGNG);
        if (m_nResults[i] > 0)
        {
            hu_count++;
        }
    }
    if (hu_count > 1)
    {
        // 不止一个人胡牌
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_ONE_THROW_MULTIHU))
        {
            // 不支持一炮多响
            int ch = GetNextChair(cardchair);
            do
            {
                if (m_nResults[ch] > 0)
                {
                    break;
                }
                ch = GetNextChair(ch);
            } while (ch != cardchair);
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (i != ch && m_nResults[i] > 0)
                {
                    m_nResults[i] = 0;
                    hu_count--;
                }
            }
        }
    }
    if (hu_count > 0)
    {
        // 胡牌成功
        m_nLoseChair = m_nGangChair;        // 被抢杠者位置
        m_nHuCount = hu_count;          // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID

        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                m_nHuChair = i;
                break;
            }
        }
    }
    return hu_count;
}

int CMJTable::OnHuFang(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair)
        {
            continue;
        }
        m_nResults[i] = CanHu(i, cardid, m_huDetails[i], MJ_HU_FANG);
        if (m_nResults[i] > 0)
        {
            hu_count++;
        }
    }
    if (hu_count > 1)
    {
        // 不止一个人胡牌
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_ONE_THROW_MULTIHU))
        {
            // 不支持一炮多响
            // 胡牌番数大的优先胡
            if (IS_BIT_SET(m_dwGameFlags2, MJ_HU_MAXWINPOINTS))
            {
                int nMaxScore = GetMaxResultScore();
                int j = 0;
                for (j = 0; j < m_nTotalChairs; j++)
                {
                    if (nMaxScore > 0 && m_nResults[j] < nMaxScore)
                    {
                        m_nResults[j] = 0;
                        hu_count--;
                    }
                }
            }
            // 若放炮的几个人的胡番一样大 则按顺序再计算一遍
            if (hu_count > 1)
            {
                int ch = GetNextChair(cardchair);
                do
                {
                    if (m_nResults[ch] > 0)
                    {
                        break;
                    }
                    ch = GetNextChair(ch);
                } while (ch != cardchair);
                for (int i = 0; i < m_nTotalChairs; i++)
                {
                    if (i != ch && m_nResults[i] > 0)
                    {
                        m_nResults[i] = 0;
                        hu_count--;
                    }
                }
            }
        }
    }
    if (hu_count > 0)
    {
        // 胡牌成功
        m_nLoseChair = cardchair;       // 放冲者位置
        m_nHuCount = hu_count;      // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID

        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                m_nHuChair = i;
                break;
            }
        }
    }
    return hu_count;
}

int CMJTable::OnHuZimo(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;

    m_nResults[chairno] = CanHu(chairno, cardid, m_huDetails[chairno], MJ_HU_ZIMO);
    if (m_nResults[chairno] > 0)
    {
        hu_count++;
        m_nHuCount = 1;
        m_nHuChair = chairno;
        m_nHuCard = cardid;             // 胡牌ID
    }
    return hu_count;
}

int CMJTable::OnJokerThrow(int chairno, int nCardID)
{
    m_nJokersThrown[chairno]++;

    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        if (INVALID_OBJECT_ID == m_nCaiPiaoChair)
        {
            m_nCaiPiaoChair = chairno;
            m_nCaiPiaoCount = 1;
        }
        else if (chairno == m_nCaiPiaoChair)
        {
            m_nCaiPiaoCount++;
        }
        else {}
    }
    return 0;
}

int CMJTable::OnNotJokerThrow(int chairno, int nCardID)
{
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        if (INVALID_OBJECT_ID == m_nCaiPiaoChair)
        {
        }
        else if (chairno == m_nCaiPiaoChair)
        {
            m_nCaiPiaoChair = INVALID_OBJECT_ID;
            m_nCaiPiaoCount = 0;
        }
        else {}
    }
    return 0;
}

int CMJTable::OnCatchCardFail(int chairno)
{
    if (m_nHeadTaken + m_nTailTaken >= m_nTotalCards)
    {
        // 没牌抓了啦！
        return 1;
    }
    return 0;
}

int CMJTable::GangCardFail(int chairno)
{
    if (m_nHeadTaken + m_nTailTaken >= m_nTotalCards)
    {
        // 没牌杠了啦！
        return 1;
    }
    return 0;
}

int CMJTable::OnGangCardFailed(int chairno)
{
    return 0;
}

DWORD CMJTable::CalcPGCH(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD flags)
{
    DWORD dwReturn = 0;

    if (IS_BIT_SET(flags, MJ_PENG))
    {
        dwReturn |= CalcPeng(chairno, nCardID);
    }
    if (IS_BIT_SET(flags, MJ_GANG))
    {
        dwReturn |= CalcGang(chairno, nCardID, MJ_GANG_MN);
    }
    if (IS_BIT_SET(flags, MJ_CHI))
    {
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_CHI_FORBIDDEN))
        {
            // 可以吃
            dwReturn |= CalcChi(chairno, nCardID);
        }
    }
    if (IS_BIT_SET(flags, MJ_HU))
    {
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_FANG_FORBIDDEN))
        {
            // 可以放冲
            DWORD flags = MJ_HU_FANG;
            dwReturn |= CalcHu(chairno, nCardID, huDetails, flags);
        }
    }
    return dwReturn;
}

// 根据手里的牌加上这张牌，判断能否碰
DWORD CMJTable::CalcPeng(int chairno, int nCardID)
{
    return m_pCalclator->MJ_CanPeng(m_nCardsLayIn[chairno], nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
}

BOOL CMJTable::IsCardIDsPengCards(int chairno, int nCardIDs[], int nCardsLen)
{
    // 检查是否存在两张牌ID相同的情况
    if (!XygCardDistinct(nCardIDs, nCardsLen))
    {
        return FALSE;
    }

    for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        CARDS_UNIT cards_unit = m_PengCards[chairno][i];
        if (XygSameCards(cards_unit.nCardIDs, MJ_UNIT_LEN - 1, nCardIDs, nCardsLen))
        {
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::RemovePengCards(int chairno, int nCardIDs[], int nCardsLen)
{
    for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        CARDS_UNIT cards_unit = m_PengCards[chairno][i];
        if (XygSameCards(cards_unit.nCardIDs, MJ_UNIT_LEN - 1, nCardIDs, nCardsLen))
        {
            m_PengCards[chairno].RemoveAt(i);
            return TRUE;
        }
    }
    return FALSE;
}

BOOL CMJTable::IsPengCardsGanged(int chairno, int nCardIDs[], int nCardsLen)
{
    for (int i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
    {
        CARDS_UNIT cards_unit = m_PnGangCards[chairno][i];
        if (XygHaveCardsIn(cards_unit.nCardIDs, MJ_UNIT_LEN, nCardIDs, nCardsLen))
        {
            return TRUE;
        }
    }
    return FALSE;
}

int CMJTable::CalcPreGangOK(LPPREGANG_CARD pPreGangCard, PREGANG_OK& pregang_ok)
{
    int count = 0;
    int cardid = pPreGangCard->nCardID;
    int cardchair = pPreGangCard->nCardChair;
    int chairno = pPreGangCard->nChairNO;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == chairno)
        {
            continue;
        }
        HU_DETAILS huDetails;
        memset(&huDetails, 0, sizeof(huDetails));

        DWORD flags = MJ_HU_QGNG;
        DWORD dwResult = CalcHu_Various(i, cardid, huDetails, flags);
        if (IS_BIT_SET(dwResult, MJ_HU))
        {
            m_dwPGCHFlags[i] |= MJ_HU;
            m_dwGuoFlags[i] |= MJ_GUO;
            pregang_ok.dwResults[i] = dwResult;
            count++;

            m_nQghFlag = pPreGangCard->dwFlags;
            m_nQghID = cardid;
            m_nQghChair = chairno;
        }
    }
    pregang_ok.nChairNO = pPreGangCard->nChairNO;
    pregang_ok.nCardChair = pPreGangCard->nCardChair;
    pregang_ok.nCardID = pPreGangCard->nCardID;
    pregang_ok.dwFlags = pPreGangCard->dwFlags;
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
    return count;
}
// 根据手里的牌加上这张牌，判断能否杠(明杠或暗杠)
// 根据碰出的牌加上这张牌，判断能否杠(碰杠)
DWORD CMJTable::CalcGang(int chairno, int nCardID, DWORD dwFlags)
{
    if (IS_BIT_SET(dwFlags, MJ_GANG_MN))
    {
        return m_pCalclator->MJ_CanMnGang(m_nCardsLayIn[chairno], nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
    }
    else if (IS_BIT_SET(dwFlags, MJ_GANG_AN))
    {
        int index = 0;
        return m_pCalclator->MJ_CanAnGang(m_nCardsLayIn[chairno], nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, index);
    }
    else if (IS_BIT_SET(dwFlags, MJ_GANG_PN))
    {
        return CalcPnGang(chairno, nCardID);
    }
    else
    {
        return 0;
    }
}

// 根据碰出的牌加上这张牌，判断能否杠(碰杠)
DWORD CMJTable::CalcPnGang(int chairno, int nCardID)
{
    for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        CARDS_UNIT cards_unit = m_PengCards[chairno][i];
        int cardid = cards_unit.nCardIDs[0];
        if (IsSameCard(cardid, nCardID))
        {
            return MJ_GANG;
        }
    }
    return 0;
}

// 根据手里的牌加上这张牌，判断能否吃
DWORD CMJTable::CalcChi(int chairno, int nCardID)
{
    return m_pCalclator->MJ_CanChi(m_nCardsLayIn[chairno], nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
}

DWORD CMJTable::CalcHua(int chairno, int nCardID)
{
    return m_pCalclator->MJ_CanHua(m_nCardsLayIn[chairno], nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags);
}

// 返回值 >0: 可以胡牌; =0: 不能胡牌; <0: 具体错误
DWORD CMJTable::CalcHu_Zimo(int chairno, int nCardID)
{
    if (INVALID_OBJECT_ID == nCardID)
    {
        return 0;
    }

    if (IS_BIT_SET(m_dwGameFlags2, MJ_HU_PRETING))
    {
        if (m_nbaoTing[chairno] != 1)
        {
            return 0;
        }
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));

    DWORD flags = MJ_HU_ZIMO;
    return CalcHu(chairno, nCardID, huDetails, flags, TRUE);
}

// 根据手里的牌加上这张牌，判断能否胡(放冲或自摸)
DWORD CMJTable::CalcHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic /*FALSE*/)
{
    assert(nCardID >= 0 && nCardID < m_nTotalCards);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }
    return m_pCalclator->MJ_CanHu(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], huDetails, dwFlags);
}

DWORD CMJTable::CalcHu_Various(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic)
{
    assert(nCardID >= 0 && nCardID < m_nTotalCards);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }
    DWORD dwOut = GetOutOfChair(chairno);
    return m_pCalclator->MJ_CanHu_Various(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], huDetails, dwFlags, dwOut);
}

DWORD CMJTable::CalcHu_Most(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic)
{
    assert(nCardID >= 0 && nCardID < m_nTotalCards);

    DWORD dwOut = GetOutOfChair(chairno);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_FANG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_FANG;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_ZIMO;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_QGNG;
    }
    //
    int nHuGains = 0;
    HU_DETAILS hu_details_out;
    memset(&hu_details_out, 0, sizeof(hu_details_out));

    HU_DETAILS hu_details_run;

    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_BaoTou(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_Diao(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_Duid(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_Qian(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_Bian(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_Chi(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_7Dui(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_13BK(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_7Fng(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_QFng(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags, dwOut))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    if (m_pCalclator->MJ_CanHu_258(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, m_dwHuFlags[0], hu_details_run, dwFlags, dwOut))
    {
        MJ_MixupHuDetails(hu_details_run, huDetails);
        int gains = CalcHuGains(chairno, nCardID, hu_details_run, dwFlags);
        if (gains > nHuGains)
        {
            nHuGains = gains;
            memcpy(&hu_details_out, &hu_details_run, sizeof(hu_details_run));
        }
    }
    if (nHuGains)
    {
        memcpy(&huDetails, &hu_details_out, sizeof(huDetails));
    }
    return nHuGains;
}

int CMJTable::CalcHuGains(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int gains = 0;

    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_FANG))
    {
        // gains += g_nHuGains[HU_GAIN_FANG];
        // huDetails.nHuGains[HU_GAIN_FANG] += g_nHuGains[HU_GAIN_FANG];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_ZIMO))
    {
        // gains += g_nHuGains[HU_GAIN_ZIMO];
        // huDetails.nHuGains[HU_GAIN_ZIMO] += g_nHuGains[HU_GAIN_ZIMO];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_QGNG))
    {
        // gains += g_nHuGains[HU_GAIN_QGNG];
        // huDetails.nHuGains[HU_GAIN_QGNG] += g_nHuGains[HU_GAIN_QGNG];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_7DUI))
    {
        int fours = MJ_CalcFours(huDetails, m_nJokerID, m_nJokerID2, m_dwGameFlags);
        // gains += g_nHuGains[HU_GAIN_7DUI] * fours;
        // huDetails.nHuGains[HU_GAIN_7DUI] += g_nHuGains[HU_GAIN_7DUI] * fours;
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_13BK))
    {
        // gains += g_nHuGains[HU_GAIN_13BK];
        // huDetails.nHuGains[HU_GAIN_13BK] += g_nHuGains[HU_GAIN_13BK];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_7FNG))
    {
        // gains += g_nHuGains[HU_GAIN_7FNG];
        // huDetails.nHuGains[HU_GAIN_7FNG] += g_nHuGains[HU_GAIN_7FNG];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_QFNG))
    {
        // gains += g_nHuGains[HU_GAIN_QFNG];
        // huDetails.nHuGains[HU_GAIN_QFNG] += g_nHuGains[HU_GAIN_QFNG];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[0], huDetails.dwHuFlags[0], MJ_HU_258))
    {
        // gains += g_nHuGains[HU_GAIN_258];
        // huDetails.nHuGains[HU_GAIN_258] += g_nHuGains[HU_GAIN_258];
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_TIAN))
    {
        // 天胡
        if (Hu_Tian(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_TIAN];
            // huDetails.nHuGains[HU_GAIN_TIAN] += g_nHuGains[HU_GAIN_TIAN];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_DI))
    {
        // 地胡
        if (Hu_Di(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_DI];
            // huDetails.nHuGains[HU_GAIN_DI] += g_nHuGains[HU_GAIN_DI];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_BANK))
    {
        // 庄家胡
        if (Hu_Bank(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_BANK];
            // huDetails.nHuGains[HU_GAIN_BANK] += g_nHuGains[HU_GAIN_BANK];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_PNPN))
    {
        // 碰碰胡
        if (Hu_PnPn(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_PNPN];
            // huDetails.nHuGains[HU_GAIN_PNPN] += g_nHuGains[HU_GAIN_PNPN];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_1CLR))
    {
        // 清一色
        if (Hu_1Clr(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_1CLR];
            // huDetails.nHuGains[HU_GAIN_1CLR] += g_nHuGains[HU_GAIN_1CLR];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_2CLR))
    {
        // 混一色
        if (Hu_2Clr(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_2CLR];
            // huDetails.nHuGains[HU_GAIN_2CLR] += g_nHuGains[HU_GAIN_2CLR];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_FENG))
    {
        // 字一色(全风)
        if (Hu_Feng(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_FENG];
            // huDetails.nHuGains[HU_GAIN_FENG] += g_nHuGains[HU_GAIN_FENG];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_WUDA))
    {
        // 无搭
        if (Hu_WuDa(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_WUDA];
            // huDetails.nHuGains[HU_GAIN_WUDA] += g_nHuGains[HU_GAIN_WUDA];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_CSGW))
    {
        // 财神归位
        if (Hu_CSGW(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_CSGW];
            // huDetails.nHuGains[HU_GAIN_CSGW] += g_nHuGains[HU_GAIN_CSGW];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_3CAI))
    {
        // 三财
        if (Hu_3Cai(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_3CAI];
            // huDetails.nHuGains[HU_GAIN_3CAI] += g_nHuGains[HU_GAIN_3CAI];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_4CAI))
    {
        // 四财
        if (Hu_4Cai(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_4CAI];
            // huDetails.nHuGains[HU_GAIN_4CAI] += g_nHuGains[HU_GAIN_4CAI];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_GKAI))
    {
        // 杠开
        if (Hu_GKai(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_GKAI] * m_nGangKaiCount;
            // huDetails.nHuGains[HU_GAIN_GKAI] += g_nHuGains[HU_GAIN_GKAI] * m_nGangKaiCount;
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_DDCH))
    {
        // 大吊车
        if (Hu_DDCh(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_DDCH];
            // huDetails.nHuGains[HU_GAIN_DDCH] += g_nHuGains[HU_GAIN_DDCH];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_HDLY))
    {
        // 海底捞月
        if (Hu_HDLY(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_HDLY];
            // huDetails.nHuGains[HU_GAIN_HDLY] += g_nHuGains[HU_GAIN_HDLY];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_MQNG))
    {
        // 大门清
        if (Hu_MQng(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_MQNG];
            // huDetails.nHuGains[HU_GAIN_MQNG] += g_nHuGains[HU_GAIN_MQNG];
        }
    }
    if (IS_BIT_SET(m_dwHuFlags[0], MJ_HU_QQRN))
    {
        // 全求人
        if (Hu_QQrn(chairno, nCardID, huDetails, dwFlags))
        {
            // gains += g_nHuGains[HU_GAIN_QQRN];
            // huDetails.nHuGains[HU_GAIN_QQRN] += g_nHuGains[HU_GAIN_QQRN];
        }
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[1], huDetails.dwHuFlags[1], MJ_HU_BTOU))
    {
        // 爆头
        // gains += g_nHuGains[HU_GAIN_BTOU];
        // huDetails.nHuGains[HU_GAIN_BTOU] += g_nHuGains[HU_GAIN_BTOU];
        if (IS_BIT_SET(m_dwHuFlags[1], MJ_HU_CAIP))
        {
            // 财飘
            if (Hu_CaiP(chairno, nCardID, huDetails, dwFlags))
            {
                // gains += g_nHuGains[HU_GAIN_CAIP] * m_nCaiPiaoCount;
                // huDetails.nHuGains[HU_GAIN_CAIP] += g_nHuGains[HU_GAIN_CAIP] * m_nCaiPiaoCount;
            }
        }
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[1], huDetails.dwHuFlags[1], MJ_HU_DIAO))
    {
        // 单吊
        // gains += g_nHuGains[HU_GAIN_DIAO];
        // huDetails.nHuGains[HU_GAIN_DIAO] += g_nHuGains[HU_GAIN_DIAO];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[1], huDetails.dwHuFlags[1], MJ_HU_DUID))
    {
        // 对倒
        // gains += g_nHuGains[HU_GAIN_DUID];
        // huDetails.nHuGains[HU_GAIN_DUID] += g_nHuGains[HU_GAIN_DUID];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[1], huDetails.dwHuFlags[1], MJ_HU_QIAN))
    {
        // 嵌张
        // gains += g_nHuGains[HU_GAIN_QIAN];
        // huDetails.nHuGains[HU_GAIN_QIAN] += g_nHuGains[HU_GAIN_QIAN];
    }
    if (MJ_MATCH_HUFLAGS(m_dwHuFlags[1], huDetails.dwHuFlags[1], MJ_HU_BIAN))
    {
        // 边张
        // gains += g_nHuGains[HU_GAIN_BIAN];
        // huDetails.nHuGains[HU_GAIN_BIAN] += g_nHuGains[HU_GAIN_BIAN];
    }
    if (m_MnGangCards[chairno].GetSize())
    {
        // 明杠
        //gains += g_nHuGains[HU_GAIN_MGNG] * m_MnGangCards[chairno].GetSize();
        //huDetails.nHuGains[HU_GAIN_MGNG] += g_nHuGains[HU_GAIN_MGNG] * m_MnGangCards[chairno].GetSize();
    }
    if (m_PnGangCards[chairno].GetSize())
    {
        // 碰杠
        //gains += g_nHuGains[HU_GAIN_PGNG] * m_PnGangCards[chairno].GetSize();
        //huDetails.nHuGains[HU_GAIN_PGNG] += g_nHuGains[HU_GAIN_PGNG] * m_PnGangCards[chairno].GetSize();
    }
    if (m_AnGangCards[chairno].GetSize())
    {
        // 暗杠
        //gains += g_nHuGains[HU_GAIN_AGNG] * m_AnGangCards[chairno].GetSize();
        //huDetails.nHuGains[HU_GAIN_AGNG] += g_nHuGains[HU_GAIN_AGNG] * m_AnGangCards[chairno].GetSize();
    }
    return gains;
}

DWORD CMJTable::CalcWinOnHu(int chairno)
{
    m_dwWinFlags = 0;

    int hu_chair = INVALID_OBJECT_ID;
    int hu_count = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_nResults[i] > 0)
        {
            hu_count++;
            hu_chair = i;
        }
    }
    if (hu_chair < 0)
    {
        UwlLogFile(_T("CalcWinOnHu error,huchair <0"));
        return 0;

    }

    if (IS_BIT_SET(m_huDetails[hu_chair].dwHuFlags[0], MJ_HU_FANG))
    {
        m_dwWinFlags |= MJ_GW_FANG;
    }
    if (IS_BIT_SET(m_huDetails[hu_chair].dwHuFlags[0], MJ_HU_ZIMO))
    {
        m_dwWinFlags |= MJ_GW_ZIMO;
    }
    if (IS_BIT_SET(m_huDetails[hu_chair].dwHuFlags[0], MJ_HU_QGNG))
    {
        m_dwWinFlags |= MJ_GW_QGNG;
    }
    if (hu_count > 1)
    {
        m_dwWinFlags |= MJ_GW_MULTI;
    }
    return m_dwWinFlags;
}

// 返回值 >0: 可以胡牌; =0: 不能胡牌; <0: 具体错误
//
//
int CMJTable::CanHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int gains = CalcHu_Most(chairno, nCardID, huDetails, dwFlags);
    return gains;
}

int CMJTable::GetFailedResponse(int chairno)
{
    if (MJ_ERR_HU_GAINS_LESS == m_nResults[chairno])
    {
        return GR_HU_GAINS_LESS;
    }
    else if (0 == m_nResults[chairno])
    {
        return UR_OPERATE_FAILED;
    }
    else
    {
        return UR_OPERATE_FAILED;
    }
}

BOOL CMJTable::CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    if (IS_BIT_SET(m_dwWinFlags, GW_STANDOFF))
    {
        // 黄庄(和局)

    }
    else if (m_nHuCount)
    {
        // 计算每人输赢点数
        //.......................
        //
        CalcBankerPoints(pData, nLen, chairno, nWinPoints);

        // 计算承包
        if (IS_BIT_SET(m_dwGameFlags, MJ_GF_FEED_UNDERTAKE))
        {
            // 吃碰要承包
            CalcUnderTake(pData, nLen, chairno, nWinPoints);
        }
    }
    // 根据杠牌或者其它奖励得分计算每人点数
    CalcGangEtcPoints(pData, nLen, chairno, nWinPoints);

    return FALSE;
}

BOOL CMJTable::CalcBankerPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    return FALSE;
}

int CMJTable::CalcUnderTake(void* pData, int nLen, int chairno, int nWinPoints[])
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;
    int undertake_chair = -1;
    if (m_nHuCount)
    {
        int hu_chair = -1;
        hu_chair = m_nHuChair;

        // 判断是否有人承包
        int i = 0;
        for (i = GetNextChair(hu_chair); i != hu_chair; i = GetNextChair(i))
        {
            if (i == hu_chair)
            {
                continue;
            }
            if (m_nPengFeedCount[i][hu_chair]
                + m_nChiFeedCount[i][hu_chair]
                + m_nGangFeedCount[i][hu_chair] >= MJ_UNDERTAKE_LIMEN
                || m_nPengFeedCount[hu_chair][i]
                + m_nChiFeedCount[hu_chair][i]
                + m_nGangFeedCount[hu_chair][i] >= MJ_UNDERTAKE_LIMEN)
            {
                undertake_chair = i;
                break;
            }
        }
        if (INVALID_OBJECT_ID != undertake_chair)
        {
            // 有人承包
            int total_lost = 0;
            for (i = 0; i < m_nTotalChairs; i++)
            {
                if (nWinPoints[i] < 0)
                {
                    total_lost += nWinPoints[i];
                }
            }
            nWinPoints[undertake_chair] = total_lost;
            for (i = 0; i < m_nTotalChairs; i++)
            {
                if (i == hu_chair || i == undertake_chair)
                {
                    continue;
                }
                nWinPoints[i] = 0;
            }
        }
    }
    if (INVALID_OBJECT_ID != undertake_chair)
    {
        pGameWin->nChengBaoID = m_ptrPlayers[undertake_chair]->m_nUserID;
    }
    return undertake_chair;
}

int CMJTable::CalcGangEtcPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    return 1;
}

BOOL CMJTable::IsBankWin(void* pData, int nLen, int chairno)
{
    LPGAME_WIN_MJ pGameWin = (LPGAME_WIN_MJ)pData;

    if (IS_BIT_SET(m_dwWinFlags, GW_STANDOFF))
    {
        // 黄庄(和局)
        return FALSE;
    }
    else if (m_nHuCount)
    {
        if (m_nResults[m_nBanker] > 0)
        {
            // 庄家胡牌
            return TRUE;
        }
    }
    return FALSE;
}

int CMJTable::CalcResultDiffs(void* pData, int nLen, int nScoreDiffs[], int nDepositDiffs[])
{
    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;

    // 计算积分结果
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        nScoreDiffs[i] = m_nBaseScore * pGameWin->nWinPoints[i];
    }
    if (m_nBaseDeposit)
    {
        // 玩银子，计算银子结果
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            nDepositDiffs[i] = m_nBaseDeposit * pGameWin->nWinPoints[i];
        }
    }
    return 0;
}

int CMJTable::CancelSituationOfGang()
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_MN))
    {
        RemoveStatus(MJ_TS_GANG_MN);
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_PN))
    {
        RemoveStatus(MJ_TS_GANG_PN);
    }
    if (IS_BIT_SET(m_dwStatus, MJ_TS_GANG_AN))
    {
        RemoveStatus(MJ_TS_GANG_AN);
    }
    m_nGangID = INVALID_OBJECT_ID;
    m_nCardChair = INVALID_OBJECT_ID;
    m_nGangChair = INVALID_OBJECT_ID;

    m_dwLatestPreGang = 0;
    return 1;
}

int CMJTable::CancelSituationInCard()
{
    ZeroMemory(m_dwPGCHFlags, sizeof(m_dwPGCHFlags));   // 出牌后碰杠吃胡状态
    ZeroMemory(m_dwGuoFlags, sizeof(m_dwGuoFlags));     // 出牌后能否过牌标志

    return 1;
}

int CMJTable::IsSameCard(int id1, int id2)
{
    return m_pCalclator->MJ_IsSameCard(id1, id2, m_dwGameFlags);
}

int CMJTable::FindCardID(CDWordArray& dwArray, int nCardID)
{
    for (int i = 0; i < dwArray.GetSize(); i++)
    {
        if (nCardID == dwArray[i])
        {
            return i;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJTable::GetTotalShapes(int shapedCount[])
{
    int shapes = 0;
    for (int i = 0; i < MJ_CS_TOTAL; i++)
    {
        if (shapedCount[i])
        {
            shapes++;
        }
    }
    return shapes;
}

int CMJTable::GetCardShape(int cardidx, int baiban_joker)
{
    int j_index = 0;
    int j_index2 = 0;
    m_pCalclator->MJ_GetJokerIndex(m_nJokerID, m_nJokerID2, m_dwGameFlags, j_index, j_index2);
    int baiban_idx = m_pCalclator->MJ_GetBaibanEx(m_nJokerID, m_nJokerID2, m_dwGameFlags);

    int shape = -1;
    if (cardidx == baiban_idx && baiban_joker
        && IS_BIT_SET(m_dwGameFlags, MJ_GF_BAIBAN_JOKER))
    {
        // 白板可代替财神
        shape = j_index / m_nLayoutMod;
    }
    else
    {
        shape = cardidx / m_nLayoutMod;
    }
    return shape;
}

int CMJTable::GetShapedCountIn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, int baiban_joker, int shapedCount[])
{
    memset(shapedCount, 0, sizeof(int)* MJ_CS_TOTAL);

    for (int i = 0; i < huDetails.nUnitsCount; i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardidx = huDetails.HuUnits[i].aryIndexes[j];
            if (cardidx > 0)
            {
                int shape = GetCardShape(cardidx, baiban_joker);
                shapedCount[shape]++;
            }
        }
    }
    return 1;
}

int CMJTable::GetShapedCountOut(int chairno, int baiban_joker, int shapedCount[])
{
    int i = 0;
    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = GetCardShape(cardidx, baiban_joker);
            shapedCount[shape]++;
        }
    }
    //
    for (i = 0; i < m_ChiCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_ChiCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = GetCardShape(cardidx, baiban_joker);
            shapedCount[shape]++;
        }
    }
    //
    for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_MnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = GetCardShape(cardidx, baiban_joker);
            shapedCount[shape]++;
        }
    }
    //
    for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_AnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = GetCardShape(cardidx, baiban_joker);
            shapedCount[shape]++;
        }
    }
    //
    for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx > 0)
        {
            int shape = GetCardShape(cardidx, baiban_joker);
            shapedCount[shape]++;
        }
    }
    return 1;
}

int CMJTable::IsOutSomething(int chairno)
{
    if (m_PengCards[chairno].GetSize())
    {
        return 1;
    }
    if (m_ChiCards[chairno].GetSize())
    {
        return 1;
    }
    if (m_MnGangCards[chairno].GetSize())
    {
        return 1;
    }
    if (m_AnGangCards[chairno].GetSize())
    {
        return 1;
    }
    if (m_PnGangCards[chairno].GetSize())
    {
        return 1;
    }
    return 0;
}

int CMJTable::Is258Out(int chairno)
{
    if (!IsOutSomething(chairno))
    {
        return 0;
    }
    int i = 0;
    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardid = m_PengCards[chairno][i].nCardIDs[j];
            if (INVALID_OBJECT_ID == cardid)
            {
                continue;
            }
            int cardidx = m_pCalclator->MJ_CalcIndexByID(cardid, m_dwGameFlags);
            if (!m_pCalclator->MJ_Is258(cardidx))
            {
                return 0;
            }
        }
    }
    for (i = 0; i < m_ChiCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardid = m_ChiCards[chairno][i].nCardIDs[j];
            if (INVALID_OBJECT_ID == cardid)
            {
                continue;
            }
            int cardidx = m_pCalclator->MJ_CalcIndexByID(cardid, m_dwGameFlags);
            if (!m_pCalclator->MJ_Is258(cardidx))
            {
                return 0;
            }
        }
    }
    for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardid = m_MnGangCards[chairno][i].nCardIDs[j];
            if (INVALID_OBJECT_ID == cardid)
            {
                continue;
            }
            int cardidx = m_pCalclator->MJ_CalcIndexByID(cardid, m_dwGameFlags);
            if (!m_pCalclator->MJ_Is258(cardidx))
            {
                return 0;
            }
        }
    }
    for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardid = m_AnGangCards[chairno][i].nCardIDs[j];
            if (INVALID_OBJECT_ID == cardid)
            {
                continue;
            }
            int cardidx = m_pCalclator->MJ_CalcIndexByID(cardid, m_dwGameFlags);
            if (!m_pCalclator->MJ_Is258(cardidx))
            {
                return 0;
            }
        }
    }
    for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardid = m_PnGangCards[chairno][i].nCardIDs[j];
            if (INVALID_OBJECT_ID == cardid)
            {
                continue;
            }
            int cardidx = m_pCalclator->MJ_CalcIndexByID(cardid, m_dwGameFlags);
            if (!m_pCalclator->MJ_Is258(cardidx))
            {
                return 0;
            }
        }
    }
    return 1;
}

DWORD CMJTable::GetOutOfChair(int chairno)
{
    DWORD dwResult = 0;

    if (!IsOutSomething(chairno))
    {
        return 0;
    }
    int shapedCount[MJ_CS_TOTAL];
    memset(shapedCount, 0, sizeof(int)* MJ_CS_TOTAL);

    GetShapedCountOut(chairno, 0, shapedCount);
    int shapes = GetTotalShapes(shapedCount);
    if (1 == shapes && shapedCount[MJ_CS_FENG])
    {
        dwResult |= MJ_OUT_FENG;
    }
    if (Is258Out(chairno))
    {
        dwResult |= MJ_OUT_258;
    }
    if (!dwResult)
    {
        dwResult |= MJ_OUT_MIXUP;
    }
    return dwResult;
}

DWORD CMJTable::Hu_Tian(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int num = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
        num += m_PengCards[i].GetSize()
            + m_ChiCards[i].GetSize()
            + m_PnGangCards[i].GetSize()
            + m_nOutCards[i].GetSize()
            + m_MnGangCards[i].GetSize()
            + m_AnGangCards[i].GetSize();

    if (num == 0 && chairno == m_nBanker && m_nHuaCards[chairno].GetSize() == 0)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_TIAN;
        return MJ_HU_TIAN;
    }
    return 0;
}

DWORD CMJTable::Hu_Di(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (chairno == m_nBanker)
    {
        return 0;
    }
    int num = m_PengCards[chairno].GetSize()
        + m_ChiCards[chairno].GetSize()
        + m_nHuaCards[chairno].GetSize()
        + m_nOutCards[chairno].GetSize()
        + m_MnGangCards[chairno].GetSize()
        + m_AnGangCards[chairno].GetSize();

    if (num) //必须天生听牌，否则不为地胡
    {
        return 0;
    }

    if (m_nCatchCount[chairno] == 0
        && IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_FANG))//放冲
    {
        huDetails.dwHuFlags[0] |= MJ_HU_DI;
        return MJ_HU_DI;
    }
    if (m_nCatchCount[chairno] == 1
        && IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_ZIMO))//自摸
    {
        huDetails.dwHuFlags[0] |= MJ_HU_DI;
        return MJ_HU_DI;
    }
    return 0;
}

DWORD CMJTable::Hu_Bank(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (chairno == m_nBanker)
    {
        // 庄家胡
        huDetails.dwHuFlags[0] |= MJ_HU_BANK;
        return MJ_HU_BANK;
    }
    return 0;
}

DWORD CMJTable::Hu_PnPn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (m_ChiCards[chairno].GetSize())
    {
        // 吃过
        return 0;
    }
    int duizi = 0;
    for (int i = 0; i < huDetails.nUnitsCount; i++)
    {
        DWORD type = huDetails.HuUnits[i].dwType;
        if (MJ_CT_KEZI != type && MJ_CT_DUIZI != type && MJ_CT_GANG != type)
        {
            return 0;
        }
        if (MJ_CT_DUIZI == type)
        {
            duizi++;
        }
    }
    if (duizi > 1)
    {
        return 0;    //
    }

    huDetails.dwHuFlags[0] |= MJ_HU_PNPN;
    return MJ_HU_PNPN;
}

DWORD CMJTable::Hu_1Clr(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int shapedCount[MJ_CS_TOTAL];
    memset(shapedCount, 0, sizeof(int) * MJ_CS_TOTAL);

    if (!MJ_CT_REGULAR(huDetails.HuUnits[0].dwType))
    {
        return 0;
    }

    GetShapedCountIn(chairno, nCardID, huDetails, dwFlags, 1, shapedCount);
    GetShapedCountOut(chairno, 1, shapedCount);
    int shapes = GetTotalShapes(shapedCount);
    if (1 != shapes)
    {
        return 0;
    }

    if (!shapedCount[MJ_CS_WAN] && !shapedCount[MJ_CS_TIAO] && !shapedCount[MJ_CS_DONG])
    {
        return 0;
    }
    huDetails.dwHuFlags[0] |= MJ_HU_1CLR;
    return MJ_HU_1CLR;
}

DWORD CMJTable::Hu_2Clr(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int shapedCount[MJ_CS_TOTAL];
    memset(shapedCount, 0, sizeof(int) * MJ_CS_TOTAL);

    if (!MJ_CT_REGULAR(huDetails.HuUnits[0].dwType))
    {
        return 0;
    }

    GetShapedCountIn(chairno, nCardID, huDetails, dwFlags, 0, shapedCount);
    GetShapedCountOut(chairno, 0, shapedCount);
    int shapes = GetTotalShapes(shapedCount);
    if (2 != shapes)
    {
        return 0;
    }

    if (!shapedCount[MJ_CS_WAN] && !shapedCount[MJ_CS_TIAO] && !shapedCount[MJ_CS_DONG])
    {
        return 0;
    }
    if (!shapedCount[MJ_CS_FENG])
    {
        return 0;
    }

    huDetails.dwHuFlags[0] |= MJ_HU_2CLR;
    return MJ_HU_2CLR;
}

DWORD CMJTable::Hu_Feng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int shapedCount[MJ_CS_TOTAL];
    memset(shapedCount, 0, sizeof(int) * MJ_CS_TOTAL);

    if (!MJ_CT_REGULAR(huDetails.HuUnits[0].dwType))
    {
        return 0;
    }

    GetShapedCountIn(chairno, nCardID, huDetails, dwFlags, 0, shapedCount);
    GetShapedCountOut(chairno, 0, shapedCount);
    int shapes = GetTotalShapes(shapedCount);
    if (1 != shapes)
    {
        return 0;
    }

    if (!shapedCount[MJ_CS_FENG])
    {
        return 0;
    }

    huDetails.dwHuFlags[0] |= MJ_HU_FENG;
    return MJ_HU_FENG;
}

DWORD CMJTable::Hu_WuDa(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    BOOL use_joker = IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER); //
    if (!use_joker)
    {
        return 0;    // 不使用财神
    }

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }
    BOOL is_joker = m_pCalclator->MJ_IsJokerEx(nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags); // 是否财神

    int jokernum = 0;
    int jokernum2 = 0;
    jokernum = m_pCalclator->MJ_GetJokerNum(lay, m_nJokerID, m_nJokerID2, m_dwGameFlags, jokernum2);

    if (jokernum || jokernum2 || is_joker)
    {
        return 0;
    }

    huDetails.dwHuFlags[0] |= MJ_HU_WUDA;
    return MJ_HU_WUDA;
}

DWORD CMJTable::Hu_CSGW(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    BOOL use_joker = IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER); //
    if (!use_joker)
    {
        return 0;    // 不使用财神
    }

    if (Hu_WuDa(chairno, nCardID, huDetails, dwFlags))
    {
        return 0;
    }

    DWORD dwResult = 0;

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && lay[cardidx] > 0)
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }
    DWORD flg = 0;
    if (MJ_CT_13BK == huDetails.HuUnits[0].dwType)
    {
        flg |= MJ_HU_13BK;
    }
    else if (MJ_CT_7FNG == huDetails.HuUnits[0].dwType)
    {
        flg |= MJ_HU_7FNG;
    }
    else if (MJ_CT_QFNG == huDetails.HuUnits[0].dwType)
    {
        flg |= MJ_HU_QFNG;
    }
    else if (MJ_CT_258 == huDetails.HuUnits[0].dwType)
    {
        flg |= MJ_HU_258;
    }
    else
    {
    }
    if (flg)
    {
        HU_DETAILS hu;
        memset(&hu, 0, sizeof(hu));
        int jokernum = 0;
        int jokernum2 = 0;
        int addpos = 0;
        if (m_pCalclator->MJ_CanHuWithoutJoker(lay, nCardID, m_nJokerID, m_nJokerID2,
                jokernum, jokernum2, addpos,
                m_dwGameFlags, m_dwHuFlags[0], hu, flg))
        {
            dwResult = MJ_HU_CSGW;
        }
    }
    else
    {
        if (!MJ_CalcJokerAsJokers(huDetails, m_nJokerID, m_nJokerID2, m_dwGameFlags))
        {
            // 财神都归位使用了
            dwResult = MJ_HU_CSGW;
        }
        else if (m_pCalclator->MJ_CanJokerReverse(huDetails, m_nJokerID, m_nJokerID2, m_dwGameFlags))
        {
            // 财神归位使用也可
            dwResult = MJ_HU_CSGW;
        }
    }
    huDetails.dwHuFlags[0] |= dwResult;
    return dwResult;
}

DWORD CMJTable::Hu_3Cai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    BOOL use_joker = IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER); //
    if (!use_joker)
    {
        return 0;    // 不使用财神
    }

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int jokernum = 0;
    int jokernum2 = 0;
    jokernum = m_pCalclator->MJ_GetJokerNum(lay, m_nJokerID, m_nJokerID2, m_dwGameFlags, jokernum2);

    if (3 == jokernum + jokernum2)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_3CAI;
        return MJ_HU_3CAI;
    }
    else
    {
        return 0;
    }
}

DWORD CMJTable::Hu_4Cai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    BOOL use_joker = IS_BIT_SET(m_dwGameFlags, MJ_GF_USE_JOKER); //
    if (!use_joker)
    {
        return 0;    // 不使用财神
    }

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int jokernum = 0;
    int jokernum2 = 0;
    jokernum = m_pCalclator->MJ_GetJokerNum(lay, m_nJokerID, m_nJokerID2, m_dwGameFlags, jokernum2);

    if (4 == jokernum + jokernum2)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_4CAI;
        return MJ_HU_4CAI;
    }
    else
    {
        return 0;
    }
}

DWORD CMJTable::Hu_GKai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int num = m_MnGangCards[chairno].GetSize()
        + m_AnGangCards[chairno].GetSize()
        + m_PnGangCards[chairno].GetSize()
        + m_nHuaCards[chairno].GetSize();
    if (num == 0) //自己没杠过，不能杠开
    {
        return 0;
    }
    //连续杠的时候被抢杠需要注意会不会误判
    if (m_nGangKaiCount && !IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_QGNG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_GKAI;
        return MJ_HU_GKAI;
    }
    else
    {
        return 0;
    }
}

DWORD CMJTable::Hu_DDCh(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int remains = XygCardRemains(lay);
    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        remains--;
    }
    if (1 == remains)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_DDCH;
        return MJ_HU_DDCH;
    }
    else
    {
        return 0;
    }
}

DWORD CMJTable::Hu_HDLY(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        if (OnCatchCardFail(chairno))
        {
            huDetails.dwHuFlags[0] |= MJ_HU_HDLY;
            return MJ_HU_HDLY;
        }
    }
    return 0;
}

DWORD CMJTable::Hu_CaiP(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_JOKER_THROWN_PIAO))
    {
        // 支持财飘
        if (INVALID_OBJECT_ID != m_nCaiPiaoChair && m_nCaiPiaoCount)
        {
            // 有人财飘
            if (m_nCaiPiaoChair == chairno)
            {
                huDetails.dwHuFlags[1] |= MJ_HU_CAIP;
                return MJ_HU_CAIP;
            }
        }
    }
    return 0;
}

DWORD CMJTable::Hu_MQng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (0 == m_PengCards[chairno].GetSize()
        && 0 == m_ChiCards[chairno].GetSize()
        && 0 == m_MnGangCards[chairno].GetSize())
    {
        huDetails.dwHuFlags[0] |= MJ_HU_MQNG;
        return MJ_HU_MQNG;
    }
    return 0;
}

DWORD CMJTable::Hu_QQrn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    if (IS_BIT_SET(huDetails.dwHuFlags[0], MJ_HU_FANG))
    {
        // 放冲
        if (1 == XygCardRemains(lay))
        {
            if (0 == m_AnGangCards[chairno].GetSize())
            {
                huDetails.dwHuFlags[0] |= MJ_HU_QQRN;
                return MJ_HU_QQRN;
            }
        }
    }
    return 0;
}

DWORD CMJTable::CalcTingCard(int chairno)
{
    if (chairno != GetCurrentChair())
    {
        return -1;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        return -1;
    }

    memset(&m_CardTingDetail, 0, sizeof(CARD_TING_DETAIL));
    XygInitChairCards(m_CardTingDetail.nThrowCardsTing, MJ_GF_14_HANDCARDS);
    int nThrowCardsTingCount = 0;
    // 计算手牌id
    int nCardsInHand[MJ_GF_14_HANDCARDS];
    GetChairCards(chairno, nCardsInHand, MJ_GF_14_HANDCARDS);
    // 计算不可见牌张
    int nCardIndexs[MAX_CARDS_LAYOUT_NUM];
    memset(nCardIndexs, 0, sizeof(nCardIndexs));
    int lay[MAX_CARDS_LAYOUT_NUM];
    memset(lay, 0, sizeof(lay));
    DWORD dwFlag = 0;
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        int nCardIndex = GetCardIndex(m_aryCard[i].nID);
        if (m_aryCard[i].nStatus == CS_BLACK
            || (m_aryCard[i].nStatus == CS_CAUGHT && m_aryCard[i].nChairNO != chairno)
            || (m_aryCard[i].nStatus == MJ_STAT_GANG_OUT && m_aryCard[i].nChairNO != chairno && IsAnGangCard(m_aryCard[i].nID)))
        {
            int nIndex = m_pCalclator->MJ_CalcIndexByID(m_aryCard[i].nID, 0);
            nCardIndexs[nIndex]++;
        }
    }
    for (int nThrowSub = 0; nThrowSub < MJ_GF_14_HANDCARDS; nThrowSub++)
    {
        if (INVALID_OBJECT_ID == nCardsInHand[nThrowSub])
        {
            continue;
        }
        int nCardsInHandIndex = GetCardIndex(nCardsInHand[nThrowSub]);

        if (lay[nCardsInHandIndex] > 0)
        {
            int tmpThrowCardsTingCount = nThrowCardsTingCount;
            for (int i = 0; i < tmpThrowCardsTingCount; i++)
            {
                if (nCardsInHandIndex == GetCardIndex(m_CardTingDetail.nThrowCardsTing[i]))
                {
                    m_CardTingDetail.nThrowCardsTing[nThrowCardsTingCount] = nCardsInHand[nThrowSub];
                    memcpy(m_CardTingDetail.nThrowCardsTingFan[nThrowCardsTingCount], m_CardTingDetail.nThrowCardsTingFan[i], sizeof(m_CardTingDetail.nThrowCardsTingFan[i]));
                    memcpy(m_CardTingDetail.nThrowCardsTingLays[nThrowCardsTingCount], m_CardTingDetail.nThrowCardsTingLays[i], sizeof(m_CardTingDetail.nThrowCardsTingLays[i]));
                    memcpy(m_CardTingDetail.nThrowCardsTingRemain[nThrowCardsTingCount], m_CardTingDetail.nThrowCardsTingRemain[i], sizeof(m_CardTingDetail.nThrowCardsTingRemain[i]));
                    nThrowCardsTingCount++;
                    break;
                }
            }
            continue;
        }
        lay[nCardsInHandIndex]++;

        m_nCardsLayIn[chairno][nCardsInHandIndex]--;

        for (int nCardIndex = 0; nCardIndex < MAX_CARDS_LAYOUT_NUM; nCardIndex++)
        {
            if (nCardIndexs[nCardIndex] <= 0)
            {
                continue;
            }
            m_nCardsLayIn[chairno][nCardIndex]++;

            HU_DETAILS huDetails;
            int nhugains = -1;
            int nCardID = CalcCardIdByIndex(nCardIndex);
            memset(&huDetails, 0, sizeof(huDetails));
            /*nhugains = CalcHu_Most(chairno, nCardID, huDetails, MJ_HU_ZIMO);*/
            //CalcHu_TingCard(chairno, nCardID, huDetails, MJ_HU_ZIMO)
            if (CalcHu_TingCard(chairno, nCardID, huDetails, MJ_HU_ZIMO))
            {
                dwFlag |= MJ_TING;
                m_CardTingDetail.dwflags |= MJ_TING;
                m_CardTingDetail.nChairNO = chairno;
                m_CardTingDetail.nThrowCardsTingRemain[nThrowCardsTingCount][nCardIndex] = nCardIndexs[nCardIndex];
                m_CardTingDetail.nThrowCardsTingLays[nThrowCardsTingCount][nCardIndex] = 1;
                m_CardTingDetail.nThrowCardsTingFan[nThrowCardsTingCount][nCardIndex] = nhugains;
            }
            m_nCardsLayIn[chairno][nCardIndex]--;
        }
        if (IS_BIT_SET(dwFlag, MJ_TING))
        {
            m_CardTingDetail.nThrowCardsTing[nThrowCardsTingCount] = nCardsInHand[nThrowSub];
            nThrowCardsTingCount++;
            dwFlag &= ~MJ_TING;
        }
        m_nCardsLayIn[chairno][nCardsInHandIndex]++;
    }
    return m_CardTingDetail.dwflags;
}

DWORD CMJTable::CalcTingCard_17(int chairno)
{
    if (chairno != GetCurrentChair())
    {
        return -1;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        return -1;
    }

    memset(&m_CardTingDetail_16, 0, sizeof(CARD_TING_DETAIL_16));
    XygInitChairCards(m_CardTingDetail_16.nThrowCardsTing, MJ_GF_17_HANDCARDS);
    int nThrowCardsTingCount = 0;
    // 计算手牌id
    int nCardsInHand[MJ_GF_17_HANDCARDS];
    GetChairCards(chairno, nCardsInHand, MJ_GF_17_HANDCARDS);
    // 计算不可见牌张
    int nCardIndexs[MAX_CARDS_LAYOUT_NUM];
    memset(nCardIndexs, 0, sizeof(nCardIndexs));
    int lay[MAX_CARDS_LAYOUT_NUM];
    memset(lay, 0, sizeof(lay));
    DWORD dwFlag = 0;
    for (int i = 0; i < m_aryCard.GetSize(); i++)
    {
        int nCardIndex = GetCardIndex(m_aryCard[i].nID);
        if (m_aryCard[i].nStatus == CS_BLACK
            || (m_aryCard[i].nStatus == CS_CAUGHT && m_aryCard[i].nChairNO != chairno)
            || (m_aryCard[i].nStatus == MJ_STAT_GANG_OUT && m_aryCard[i].nChairNO != chairno && IsAnGangCard(m_aryCard[i].nID)))
        {
            int nIndex = m_pCalclator->MJ_CalcIndexByID(m_aryCard[i].nID, 0);
            nCardIndexs[nIndex]++;
        }
    }
    for (int nThrowSub = 0; nThrowSub < MJ_GF_17_HANDCARDS; nThrowSub++)
    {
        if (INVALID_OBJECT_ID == nCardsInHand[nThrowSub])
        {
            continue;
        }
        int nCardsInHandIndex = GetCardIndex(nCardsInHand[nThrowSub]);

        if (lay[nCardsInHandIndex] > 0)
        {
            int tmpThrowCardsTingCount = nThrowCardsTingCount;
            for (int i = 0; i < tmpThrowCardsTingCount; i++)
            {
                if (nCardsInHandIndex == GetCardIndex(m_CardTingDetail_16.nThrowCardsTing[i]))
                {
                    m_CardTingDetail_16.nThrowCardsTing[nThrowCardsTingCount] = nCardsInHand[nThrowSub];
                    memcpy(m_CardTingDetail_16.nThrowCardsTingFan[nThrowCardsTingCount], m_CardTingDetail_16.nThrowCardsTingFan[i], sizeof(m_CardTingDetail_16.nThrowCardsTingFan[i]));
                    memcpy(m_CardTingDetail_16.nThrowCardsTingLays[nThrowCardsTingCount], m_CardTingDetail_16.nThrowCardsTingLays[i], sizeof(m_CardTingDetail_16.nThrowCardsTingLays[i]));
                    memcpy(m_CardTingDetail_16.nThrowCardsTingRemain[nThrowCardsTingCount], m_CardTingDetail_16.nThrowCardsTingRemain[i], sizeof(m_CardTingDetail_16.nThrowCardsTingRemain[i]));
                    nThrowCardsTingCount++;
                    break;
                }
            }
            continue;
        }
        lay[nCardsInHandIndex]++;

        m_nCardsLayIn[chairno][nCardsInHandIndex]--;

        for (int nCardIndex = 0; nCardIndex < MAX_CARDS_LAYOUT_NUM; nCardIndex++)
        {
            if (nCardIndexs[nCardIndex] <= 0)
            {
                continue;
            }
            m_nCardsLayIn[chairno][nCardIndex]++;

            HU_DETAILS huDetails;
            int nhugains = -1;
            int nCardID = CalcCardIdByIndex(nCardIndex);
            memset(&huDetails, 0, sizeof(huDetails));
            /*nhugains = CalcHu_Most(chairno, nCardID, huDetails, MJ_HU_ZIMO);*/
            /*CalcHu_TingCard(chairno, nCardID, huDetails, MJ_HU_ZIMO)*/
            if (CalcHu_TingCard(chairno, nCardID, huDetails, MJ_HU_ZIMO))
            {
                dwFlag |= MJ_TING;
                m_CardTingDetail_16.dwflags |= MJ_TING;
                m_CardTingDetail_16.nChairNO = chairno;
                m_CardTingDetail_16.nThrowCardsTingRemain[nThrowCardsTingCount][nCardIndex] = nCardIndexs[nCardIndex];
                m_CardTingDetail_16.nThrowCardsTingLays[nThrowCardsTingCount][nCardIndex] = 1;
                m_CardTingDetail_16.nThrowCardsTingFan[nThrowCardsTingCount][nCardIndex] = nhugains;
            }
            m_nCardsLayIn[chairno][nCardIndex]--;
        }
        if (IS_BIT_SET(dwFlag, MJ_TING))
        {
            m_CardTingDetail_16.nThrowCardsTing[nThrowCardsTingCount] = nCardsInHand[nThrowSub];
            nThrowCardsTingCount++;
            dwFlag &= ~MJ_TING;
        }
        m_nCardsLayIn[chairno][nCardsInHandIndex]++;
    }
    return m_CardTingDetail_16.dwflags;
}

DWORD CMJTable::CalcHu_TingCard(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)
{
    assert((nCardID >= 0) && (nCardID < m_nTotalCards));

    int lay[MAX_CARDS_LAYOUT_NUM] = { 0 };  //
    memcpy(lay, m_nCardsLayIn[chairno], sizeof(lay));

    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && (lay[cardidx] > 0))
    {
        // 去掉已经摸到手里的最后一张牌
        lay[cardidx]--;
    }

    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO) && m_pCalclator->MJ_IsJokerEx(nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags))
    {
        return 0;
    }

    huDetails.dwHuFlags[0] = 0;

    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_ZIMO;
    }

    if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
    {
        huDetails.dwHuFlags[0] |= MJ_HU_QGNG;
    }

    //***************************
    HU_DETAILS hu_details_run;
    memset(&hu_details_run, 0, sizeof(hu_details_run));
    //*****************************

    //普通牌型
    if (m_pCalclator->MJ_CanHu(lay, nCardID, m_nJokerID, m_nJokerID2, m_dwGameFlags, dwFlags, hu_details_run, m_dwHuFlags[0]))
    {
        return MJ_HU;
    }

    return 0;
}

BOOL CMJTable::IsAnGangCard(int nCardID)
{
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_ANGANG_SHOW))
    {
        if (!IsValidCard(nCardID))
        {
            return FALSE;
        }
        int nCardIndex = GetCardIndex(nCardID);
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            for (int j = 0; j < m_AnGangCards[i].GetSize(); j++)
            {
                if (nCardIndex == GetCardIndex(m_AnGangCards[i][j].nCardIDs[0]))
                {
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}

BOOL CMJTable::IsValidCard(int nCardID)
{
    if (0 <= nCardID && nCardID < m_nTotalCards)
    {
        return TRUE;
    }
    return FALSE;
}

int CMJTable::CalcCardIdByIndex(int nCardIndex)
{
    int nCardID = -1;
    if (nCardIndex % MJ_LAYOUT_MOD)
    {
        if (nCardIndex < 38)
        {
            nCardID = nCardIndex % MJ_LAYOUT_MOD + (nCardIndex / MJ_LAYOUT_MOD) * 36 - 1;
        }
        else if (nCardIndex > 40 && nCardIndex < 49)//花牌
        {
            nCardID = nCardIndex % MJ_LAYOUT_MOD + 135;
        }
    }

    if (nCardID >= TOTAL_CARDS)
    {
        nCardID = -1;
    }

    return nCardID;
}

BOOL CMJTable::ShouldAnGangWait(LPGANG_CARD pGangCard)
{
    return FALSE;
}

void CMJTable::SaveTingCardsForDXXW(int nThrowCardID, int nChairNO)
{
    if (!IsTingPaiActive())
    {
        return;
    }

    int nCardsLen = -1;
    DWORD dwFlag = -1;
    if (IS_BIT_SET(m_dwGameFlags, MJ_GF_16_CARDS))
    {
        nCardsLen = MJ_GF_17_HANDCARDS;
        dwFlag = IS_BIT_SET(m_CardTingDetail_16.dwflags, MJ_TING);
    }
    else
    {
        nCardsLen = MJ_GF_14_HANDCARDS;
        dwFlag = IS_BIT_SET(m_CardTingDetail.dwflags, MJ_TING);
    }

    memset(m_nTingCardsDXXW[nChairNO], 0, sizeof(m_nTingCardsDXXW[nChairNO]));
    if (ValidateChair(nChairNO) && IsValidCard(nThrowCardID) && dwFlag)
    {
        for (int i = 0; i < nCardsLen; i++)
        {
            if (nThrowCardID == m_CardTingDetail.nThrowCardsTing[i] && nCardsLen == MJ_GF_14_HANDCARDS)
            {
                memcpy(m_nTingCardsDXXW[nChairNO], m_CardTingDetail.nThrowCardsTingLays[i], sizeof(m_CardTingDetail.nThrowCardsTingLays[i]));
                break;
            }
            else if (nThrowCardID == m_CardTingDetail_16.nThrowCardsTing[i] && nCardsLen == MJ_GF_17_HANDCARDS)
            {
                memcpy(m_nTingCardsDXXW[nChairNO], m_CardTingDetail_16.nThrowCardsTingLays[i], sizeof(m_CardTingDetail_16.nThrowCardsTingLays[i]));
                break;
            }
        }
    }
}

int CMJTable::ValidateMergeCatch(int chairno)
{
    if (IS_BIT_SET(m_dwStatus, MJ_TS_HU_READY))
    {
        return 0;
    }

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_dwPGCHFlags[i])
        {
            return 0;
        }
    }

    return 1;
}

int CMJTable::ShouldReConsChiWait(LPCHI_CARD pChiCard)
{
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;
    m_dwPGCHFlags[chairno] = 0;

    BOOL bWait = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno || i == cardchair)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_PENG)
            || IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG)
            || IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bWait = 1;
        }
    }

    BOOL bHighOpe = 0;
    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_PENG)
        || IS_BIT_SET(m_dwWaitOpeFlag, MJ_GANG)
        || IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        bHighOpe = 1;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        m_dwWaitOpeFlag = MJ_CHI;
        m_nWaitOpeMsgID = GR_RECONS_CHI_CARD;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pChiCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        return 1;
    }

    return 0;
}

int CMJTable::ShouldReConsPengWait(LPPENG_CARD pPengCard)
{
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;
    m_dwPGCHFlags[chairno] = 0;

    for (int chair = 0; chair < m_nTotalChairs; chair++)
    {
        m_dwPGCHFlags[chair] &= ~MJ_CHI;
    }

    BOOL bWait = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno || i == cardchair)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_GANG)
            || IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bWait = 1;
        }
    }

    BOOL bHighOpe = 0;
    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_GANG)
        || IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        bHighOpe = 1;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        m_dwWaitOpeFlag = MJ_PENG;
        m_nWaitOpeMsgID = GR_RECONS_PENG_CARD;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pPengCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        return 1;
    }

    return 0;
}

int CMJTable::ShouldReconsMnGangWait(LPGANG_CARD pGangCard)
{
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    m_dwPGCHFlags[chairno] = 0;

    for (int chair = 0; chair < m_nTotalChairs; chair++)
    {
        m_dwPGCHFlags[chair] &= ~MJ_CHI;
        m_dwPGCHFlags[chair] &= ~MJ_PENG;
    }

    BOOL bWait = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bWait = 1;
        }
    }

    BOOL bHighOpe = 0;
    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        bHighOpe = 1;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        m_dwWaitOpeFlag = MJ_GANG;
        m_nWaitOpeMsgID = GR_RECONS_MNGANG_CARD;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pGangCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        return 1;
    }

    return 0;
}

int CMJTable::ShouldReconsPnGangWait(LPGANG_CARD pGangCard)
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_PN_ROB))
    {
        return 0;
    }

    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    m_dwPGCHFlags[chairno] = 0;

    for (int chair = 0; chair < m_nTotalChairs; chair++)
    {
        m_dwPGCHFlags[chair] &= ~MJ_CHI;
        m_dwPGCHFlags[chair] &= ~MJ_PENG;
    }

    BOOL bWait = FALSE;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bWait = TRUE;
        }
    }

    BOOL bHighOpe = FALSE;
    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        bHighOpe = TRUE;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        m_dwWaitOpeFlag = MJ_GANG;
        m_nWaitOpeMsgID = GR_RECONS_PNGANG_CARD;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pGangCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        return 1;
    }

    return 0;
}

int CMJTable::ShouldReconsAnGangWait(LPGANG_CARD pGangCard)
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_AN_ROB))
    {
        return 0;
    }

    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
    m_dwPGCHFlags[chairno] = 0;

    for (int chair = 0; chair < m_nTotalChairs; chair++)
    {
        m_dwPGCHFlags[chair] &= ~MJ_CHI;
        m_dwPGCHFlags[chair] &= ~MJ_PENG;
    }

    BOOL bWait = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == chairno)
        {
            continue;
        }

        if (IS_BIT_SET(m_dwPGCHFlags[i], MJ_HU))
        {
            bWait = 1;
        }
    }

    BOOL bHighOpe = 0;
    if (IS_BIT_SET(m_dwWaitOpeFlag, MJ_HU))
    {
        bHighOpe = 1;
    }

    if (!bWait && !bHighOpe)
    {
        return 0;
    }
    else if (bWait && !bHighOpe)
    {
        m_dwWaitOpeFlag = MJ_GANG;
        m_nWaitOpeMsgID = GR_RECONS_ANGANG_CARD;
        m_nWaitOpeChair = chairno;
        memcpy(&m_WaitOpeMsgData, pGangCard, sizeof(m_WaitOpeMsgData));
        return 1;
    }
    else if (!bWait && bHighOpe)
    {
        return 2;
    }
    else if (bWait && bHighOpe)
    {
        return 1;
    }

    return 0;
}

int CMJTable::OnReconsGuo(int chairno)
{
    if (m_dwGuoFlags[chairno] == 0)
    {
        return -1;
    }

    if (m_dwPGCHFlags[chairno] != 0)
    {
        m_dwPGCHFlags[chairno] = 0;
    }

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_dwPGCHFlags[i])
        {
            return 0;
        }
    }

    if (m_nWaitOpeChair != -1)
    {
        return 2;
    }

    return 1;//全部pass
}

int CMJTable::ValidateHuQgng_An(int chairno, int cardchair, int cardid)
{
    if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_GANG_AN_ROB))
    {
        // 不允许抢暗杠
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, TS_WAITING_THROW))
    {
        // 不是等待出牌状态
        return 0;
    }
    if (cardchair != GetChairOfCard(cardid))
    {
        // 牌不属于该玩家
        return 0;
    }
    if (CS_CAUGHT != GetStatusOfCard(cardid))
    {
        // 牌未处于摸进状态
        return 0;
    }
    if (!IS_BIT_SET(m_dwStatus, MJ_TS_GANG_AN))
    {
        // 不是暗杠状态
        return 0;
    }
    if ((m_nGangID != cardid) || (m_nCardChair != cardchair))
    {
        return 0;
    }
    if (m_nGangChair == chairno)
    {
        //
        return 0;
    }
    HU_DETAILS huDetails;
    memset(&huDetails, 0, sizeof(huDetails));
    if (!CalcHu(chairno, cardid, huDetails, MJ_HU_QGNG))
    {
        return 0;
    }
    return 1;
}

int CMJTable::OnHuQgng_An(int chairno, int cardchair, int cardid)
{
    int hu_count = 0;

    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (i == cardchair || i == m_nGangChair)
        {
            continue;
        }
        m_nResults[i] = CanHu(i, cardid, m_huDetails[i], MJ_HU_QGNG);
        if (m_nResults[i] > 0)
        {
            hu_count++;
        }
    }
    if (hu_count > 1)  // 不止一个人胡牌
    {
        if (!IS_BIT_SET(m_dwGameFlags, MJ_GF_ONE_THROW_MULTIHU))  // 不支持一炮多响
        {
            int ch = GetNextChair(m_nGangChair);
            do
            {
                if (m_nResults[ch] > 0)
                {
                    break;
                }
                ch = GetNextChair(ch);
            } while (ch != m_nGangChair);
            for (int i = 0; i < m_nTotalChairs; i++)
            {
                if (i != ch && m_nResults[i] > 0)
                {
                    m_nResults[i] = 0;
                    memset(&m_huDetails[i], 0, sizeof(HU_DETAILS));
                    hu_count--;
                }
            }
        }
    }
    if (hu_count > 0)  // 胡牌成功
    {
        m_nLoseChair = m_nGangChair;        // 被抢杠者位置
        m_nHuCount = hu_count;          // 胡牌人数
        m_nHuCard = cardid;             // 胡牌ID

        for (int i = 0; i < m_nTotalChairs; i++)
        {
            if (m_nResults[i] > 0)
            {
                m_nHuChair = i;
                break;
            }
        }
    }
    return hu_count;
}

void CMJTable::ResetWaitOpe()
{
    LOG_DEBUG("ResetWaitOpe22222222222222222");
    m_dwWaitOpeFlag = 0;
    m_nWaitOpeMsgID = -1;
    m_nWaitOpeChair = -1;
    memset(&m_WaitOpeMsgData, 0, sizeof(m_WaitOpeMsgData));
}

void CMJTable::UseServerHuCardID(int& nCardID)
{
    if (nCardID != m_nCurrentCatch)
    {
        UwlLogFile("card[%d] != m_ncurrentID[%d]", nCardID, m_nCurrentCatch);
        nCardID = m_nCurrentOpeCard;
    }


    return;
}

int CMJTable::GetNextBoutBanker()
{
    if (m_nResults[m_nBanker] > 0)
    {
        // 庄家胡牌
        return m_nBanker;
    }
    else
    {
        return GetNextChair(m_nBanker);
    }
}

int CMJTable::GetChairOutCards(int chairno, CARDS_UNIT nCards[], DWORD type /*= MJ_GANG | MJ_PENG | MJ_CHI*/)
{
    int nCount = 0;
    DWORD status = 0;
    int nOutCount = 0;
    if (IS_BIT_SET(type, MJ_PENG))
    {
        for (int i = 0; i < m_PengCards[chairno].GetSize(); i++)
        {
            status = GetStatusOfCard(m_PengCards[chairno][i].nCardIDs[0]);
            if (status != MJ_STAT_PENG_OUT && status != MJ_STAT_PENG_IN)
            {
                continue;    //已升级为碰杠
            }
            if (nOutCount == 4)
            {
                break;
            }
            nCards[nOutCount] = m_PengCards[chairno][i];
            nCards[nOutCount++].nReserved[0] = MJ_TYPE_PENG;
            nCount += 3;
        }
    }

    if (IS_BIT_SET(type, MJ_GANG))
    {
        int i = 0;
        for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
        {
            if (nOutCount == 4)
            {
                break;
            }
            nCards[nOutCount] = m_MnGangCards[chairno][i];
            nCards[nOutCount++].nReserved[0] = MJ_TYPE_MNGANG;
            nCount += 4;
        }
        for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
        {
            if (nOutCount == 4)
            {
                break;
            }
            nCards[nOutCount] = m_AnGangCards[chairno][i];
            //for (int j = 0; j < 3; j++)
            //{
            //    nCards[nOutCount].nCardIDs[j] = CARD_BACK_ID;  //暗杠牌背
            //}
            nCards[nOutCount++].nReserved[0] = MJ_TYPE_ANGANG;
            nCount += 4;
        }
        for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
        {
            if (nOutCount == 4)
            {
                break;
            }
            nCards[nOutCount] = m_PnGangCards[chairno][i];
            nCards[nOutCount++].nReserved[0] = MJ_TYPE_PNGANG;
            nCount += 4;
        }
    }

    if (IS_BIT_SET(type, MJ_CHI))
    {
        for (int i = 0; i < m_ChiCards[chairno].GetSize(); i++)
        {
            if (nOutCount == 4)
            {
                break;
            }
            nCards[nOutCount] = m_ChiCards[chairno][i];
            nCards[nOutCount++].nReserved[0] = MJ_TYPE_CHI;
            nCount += 3;
        }
    }
    return nCount;
}

int CMJTable::GetLastCatchCard(int chairno)
{
    if (m_nLastGangNO >= 0 && m_nLastGangNO < TOTAL_CARDS)
    {
        if (m_aryCard[m_nLastGangNO].nChairNO == chairno)
        {
            if (CS_CAUGHT == m_aryCard[m_nLastGangNO].nStatus)
            {
                return m_aryCard[m_nLastGangNO].nID;
            }
        }
    }

    if (m_nCurrentCatch > 0 && m_nCurrentCatch < TOTAL_CARDS)
    {
        int nLastCatch = m_nCurrentCatch - 1;
        if (m_aryCard[nLastCatch].nChairNO == chairno)
        {
            if (CS_CAUGHT == m_aryCard[nLastCatch].nStatus)
            {
                return m_aryCard[nLastCatch].nID;
            }
        }
    }

    return -1;
}

BOOL CMJTable::GetUseServerHuCardID()
{
    return GetPrivateProfileInt(_T("useServerHuCardID"), _T("enable"), 0, GetINIFilePath());
}

void CMJTable::MJ_InitializeCardsUnit(CARDS_UNIT& cards_unit)
{
    XygInitChairCards(cards_unit.nCardIDs, MJ_UNIT_LEN);
}

void CMJTable::MJ_ClearHuUnits(LPHU_DETAILS lpHuDetails)
{
    lpHuDetails->nUnitsCount = 0;
    memset(lpHuDetails->HuUnits, 0, sizeof(lpHuDetails->HuUnits));
}

int CMJTable::MJ_CalcFours(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < huDetails.nUnitsCount; i++)
    {
        if (MJ_CT_GANG == huDetails.HuUnits[i].dwType)
        {
            count++;
        }
    }
    return count;
}

int CMJTable::MJ_TotalGains(HU_DETAILS& huDetails)
{
    int gains = 0;
    for (int i = 0; i < MJ_HU_GAINS_ARYSIZE; i++)
    {
        gains += huDetails.nHuGains[i];
    }
    return gains;
}

int CMJTable::MJ_TotalSubGains(HU_DETAILS& huDetails)
{
    int gains = 0;
    for (int i = 0; i < MJ_HU_GAINS_ARYSIZE; i++)
    {
        gains += huDetails.nSubGains[i];
    }
    return gains;
}

int CMJTable::MJ_CalcJokerAsJokers(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < huDetails.nUnitsCount; i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            if (huDetails.HuUnits[i].aryIndexes[j] < 0)
            {
                count++;
            }
        }
    }
    return count;
}

void CMJTable::MJ_MixupHuDetails(HU_DETAILS& huDetails1, HU_DETAILS& huDetails2)
{
    int i = 0;
    for (i = 0; i < MJ_HU_FLAGS_ARYSIZE; i++)
    {
        huDetails1.dwHuFlags[i] |= huDetails2.dwHuFlags[i];
    }
    for (i = 0; i < MJ_HU_GAINS_ARYSIZE; i++)
    {
        huDetails1.nHuGains[i] += huDetails2.nHuGains[i];
    }
    for (i = 0; i < MJ_HU_GAINS_ARYSIZE; i++)
    {
        huDetails1.nSubGains[i] += huDetails2.nSubGains[i];
    }
}

int CMJTable::MJ_IsFengKG(HU_UNIT unit, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (MJ_CT_KEZI == unit.dwType || MJ_CT_GANG == unit.dwType)
    {
        for (int i = 0; i < MJ_UNIT_LEN; i++)
        {
            if (unit.aryIndexes[i] > 0)
            {
                if (m_pCalclator->MJ_IsFeng(unit.aryIndexes[i],
                        nJokerID, nJokerID2, gameflags))
                {
                    return 1;
                }
                else if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
                {
                    // 白板可代替财神
                    int j_shape = m_pCalclator->MJ_CalculateCardShape(nJokerID, gameflags);
                    int j_value = m_pCalclator->MJ_CalculateCardValue(nJokerID, gameflags);
                    if (unit.aryIndexes[i] == m_pCalclator->MJ_CalcJokerIndex(j_shape, j_value))
                    {
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}

bool CMJTable::IsRestCard(int cardID, int type /*= 0*/)
{
    return false;
}
// mj层换用通用写法
int CMJTable::CalLastCounts()
{
    int nLastCount = m_nTotalCards - m_nHeadTaken - m_nTailTaken;
    return nLastCount;
}

BOOL CMJTable::IsLastFourCard()
{
    int nLastCount = CalLastCounts();

    if (nLastCount <= 4)  // 最后4张以内了
    {
        return TRUE;
    }
    return FALSE;
}

void CMJTable::GetAllCardHand(int chairno, int cards[], DWORD type /*= MJ_GANG | MJ_PENG | MJ_CHI*/)
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
            for (int j = 0; j < MJ_UNIT_LEN; j++)
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
            for (int j = 0; j < MJ_UNIT_LEN; j++)
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
            for (int j = 0; j < MJ_UNIT_LEN; j++)
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
        {
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
}
/*
函数描述：获得牌型单元中财神张数、代替值的信息
jokernum：牌型单元中财神张数
jokerpresent：被财神代替的牌的索引值
返回值：单元中有财神返回TRUE，否则，返回FALSE
*/
BOOL CMJTable::GetJokerInfoInUnit(const HU_UNIT& unit, int& jokernum, int& jokerpresent, int& jokerpresent2)
{
    if (IsNoJokerInUnit(unit))
    {
        return FALSE;
    }
    int num = 0;                    //jokernum = num,防止jokernum以非0值进入函数时引起的错误
    int jokerindex = m_pCalclator->MJ_CalcIndexByID(m_nJokerID, 0);

    if (unit.dwType == MJ_CT_KEZI)
    {
        if (unit.aryIndexes[1] == -jokerindex)
        {
            num++;
            jokerpresent = unit.aryIndexes[0];
        }
        if (unit.aryIndexes[2] == -jokerindex)
        {
            num++;
            jokerpresent = unit.aryIndexes[0];
        }
        jokernum = num;
        return TRUE;
    }
    if (unit.dwType == MJ_CT_SHUN)
    {
        jokernum = 1;
        if (unit.aryIndexes[0] == -jokerindex)
        {
            jokerpresent = unit.aryIndexes[1] - 1;
        }
        else if (unit.aryIndexes[1] == -jokerindex)
        {
            jokerpresent = unit.aryIndexes[0] + 1;
        }
        else if (unit.aryIndexes[2] == -jokerindex)
        {
            jokerpresent = unit.aryIndexes[0] + 2;
            jokerpresent2 = unit.aryIndexes[1] - 2;
        }
        return TRUE;
    }
    if (unit.dwType == MJ_CT_DUIZI)
    {
        if (unit.aryIndexes[0] == -jokerindex)
        {
            num++;
        }
        if (unit.aryIndexes[1] == -jokerindex)
        {
            num++;
        }
        jokernum = num;
        jokerpresent = (num == 1 ? unit.aryIndexes[0] : 0);
        return TRUE;
    }
    return FALSE;
}

BOOL CMJTable::IsNoJokerInUnit(const HU_UNIT& unit)
{
    if (unit.dwType == MJ_CT_DUIZI)
    {
        if (unit.aryIndexes[0] > 0 && unit.aryIndexes[1] > 0)
        {
            return TRUE;
        }
    }
    else if (unit.dwType == MJ_CT_KEZI || unit.dwType == MJ_CT_SHUN)
    {
        if (unit.aryIndexes[0] > 0 && unit.aryIndexes[1] > 0
            && unit.aryIndexes[2] > 0)
        {
            return TRUE;
        }
    }
    else if (unit.dwType == MJ_CT_GANG)
    {
        if (unit.aryIndexes[0] > 0 && unit.aryIndexes[1] > 0
            && unit.aryIndexes[2] > 0 && unit.aryIndexes[3] > 0)
        {
            return TRUE;
        }
    }
    return FALSE;
}

int CMJTable::GetHongZhongCount(int chairno)
{
    int hzCount = 0;
    hzCount = m_nCardsLayIn[chairno][MJ_INDEX_HONGZHONG];

    int i = 0;
    for (i = 0; i < m_PengCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PengCards[chairno][i].nCardIDs[j], m_dwGameFlags);
            if (cardidx == MJ_INDEX_HONGZHONG)
            {
                hzCount++;
            }
        }
    }

    for (i = 0; i < m_MnGangCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardidx = m_pCalclator->MJ_CalcIndexByID(m_MnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
            if (cardidx == MJ_INDEX_HONGZHONG)
            {
                hzCount++;
            }
        }
    }
    for (i = 0; i < m_AnGangCards[chairno].GetSize(); i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            int cardidx = m_pCalclator->MJ_CalcIndexByID(m_AnGangCards[chairno][i].nCardIDs[j], m_dwGameFlags);
            if (cardidx == MJ_INDEX_HONGZHONG)
            {
                hzCount++;
            }
        }
    }

    for (i = 0; i < m_PnGangCards[chairno].GetSize(); i++)
    {
        int cardidx = m_pCalclator->MJ_CalcIndexByID(m_PnGangCards[chairno][i].nCardIDs[0], m_dwGameFlags);
        if (cardidx == MJ_INDEX_HONGZHONG)
        {
            hzCount++;
        }
    }

    return hzCount;
}

int CMJTable::GetBankerGains()
{
    return 0;
}

int CMJTable::GetMaxResultScore()
{
    int nMaxScore = 0;
    for (int i = 0; i < m_nTotalChairs; i++)
    {
        if (m_nResults[i] > nMaxScore)
        {
            nMaxScore = m_nResults[i];
        }
    }
    return nMaxScore;
}

void CMJTable::SetBaoTingFlag(int nChairNO)
{
    m_nbaoTing[nChairNO] = 1;
}

void CMJTable::YQW_SetAutoPlay(int nYQWAutoPlay)
{
    m_nYqwAutoPlay = nYQWAutoPlay;
}

void CMJTable::YQW_SetQuickRoom(int nYqwQucikRoom)
{
    m_nYqwQuickRoom = nYqwQucikRoom;
}

int CMJTable::IsYQWQuickRoom()
{
    if (GetPrivateProfileInt(_T("yqwquickroom"), _T("enable"), 1, GetINIFilePath()) == 0)
    {
        return 0;
    }
    return m_nYqwQuickRoom == 1;
}

int CMJTable::IsYQWAutoPlay()
{
    if (GetPrivateProfileInt(_T("yqwautoplaywait"), _T("enable"), 1, GetINIFilePath()) == 0)
    {
        return 0;
    }

    return m_nYqwAutoPlay == 1;
}

int CMJTable::YQW_TotalGain(HU_DETAILS& huDetails, int j)
{
    return -1;
}

int CMJTable::YQW_CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[])
{
    YQW_CompensateWinPoints(nWinPoints);
    //具体myYqw层实现
    return -1;
}

int CMJTable::YQW_GetBankScore()
{
    return -1;
}

void CMJTable::YQW_CompensateWinPoints(int nWinPoints[])
{
    if (IS_BIT_SET(m_dwGameFlags2, YQW_LIMIT_WINPOINTS))
    {
        double dbTimes = 0;
        int nMaxPoints = 0;
        int i = 0;
        for (i = 0; i < m_nTotalChairs; i++)
        {
            if (nWinPoints[i] <= YQW_LIMIT_WINPOINTS_VALUE)
            {
                continue;
            }
            else
            {
                nMaxPoints = nWinPoints[i] > nMaxPoints ? nWinPoints[i] : nMaxPoints;
            }
        }
        dbTimes = nMaxPoints > 0 ? ((double)nMaxPoints / (double)YQW_LIMIT_WINPOINTS_VALUE) : 0.0;
        int nRealTimes = RoundDouble(dbTimes);

        if (nRealTimes <= 0)
        {
            return;
        }

        for (i = 0; i < m_nTotalChairs; i++)
        {
            double dbTmpWinpoint = (double)nWinPoints[i] / (double)nRealTimes;
            nWinPoints[i] = RoundDouble(dbTmpWinpoint);
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
        assert(total == 0);
        //////////////////////////////////////////////////////
    }

}

int CMJTable::RoundDouble(double number)
{
    return (number > 0.0) ? floor(number + 0.5) : ceil(number - 0.5);
}

google::protobuf::MessageLite* CMJTable::GetHuaData()
{
    game::PB_NTF_SOMEONE_BUHUA* pbGameBuHuaData = new game::PB_NTF_SOMEONE_BUHUA();

    int i, j = 0;
    for (i = 0; i < m_nTotalChairs; i++)
    {
        pbGameBuHuaData->add_nhuacount(i);
        pbGameBuHuaData->add_nhuacards();

        auto tmpChairHuaCards = pbGameBuHuaData->mutable_nhuacards(i);
        for (j = 0; j < MJ_MAX_OUT; j++)
        {
            tmpChairHuaCards->add_ncardids(-1);
        }
    }

    for (i = 0; i < m_nTotalChairs; i++)
    {
        //
        for (j = 0; j < m_nHuaCards[i].GetSize(); j++)
        {
            auto tmpChairOutCards = pbGameBuHuaData->mutable_nhuacards(i);
            int a = m_nHuaCards[i][j];
            tmpChairOutCards->set_ncardids(j, m_nHuaCards[i][j]);
        }
        pbGameBuHuaData->set_nhuacount(i, m_nHuaCards[i].GetSize());
    }
    return pbGameBuHuaData;
}

CString CMJTable::GetINIMakeCardName()
{
    CString str = _T("");

    // get exefile fullpath
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    // get test file fullpath
    TCHAR szTstFile[MAX_PATH];
    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szTstFile);
    lstrcat(szTstFile, XYG_TEST_FILE);

    str.Format(_T("%s"), szTstFile);
    return str;
}

BOOL CMJTable::ValidateGuoRecons(int chairno, int chairout)
{
    if (chairno == chairout)
    {
        // 不能过自己的牌
        return FALSE;
    }

    if (0 == m_dwPGCHFlags[chairno])
    {
        // 不能碰杠吃胡就不能过牌
        return FALSE;
    }

    if (IS_BIT_SET(m_dwPGCHFlags[chairno], MJ_CHI))
    {
        if (chairno != GetNextChair(chairout))
        {
            return FALSE;
        }
    }

    return TRUE;
}
BOOL CMJTable::CalcHuFast(int chairno, int nCardID, int lay[], int count)
{
    int cardidx = m_pCalclator->MJ_CalcIndexByID(nCardID, m_dwGameFlags);
    lay[cardidx]++;
    return imCanHuFast(lay, count);
}

BOOL CMJTable::CalcHuPerFect(int chairno, int nCardID, int lay[], HU_DETAILS& details, int& gain, DWORD dwFlags, int count)
{
    std::function<int(int, int, HU_DETAILS&, DWORD)> func = [this](int chairno, int nCardID, HU_DETAILS & huDetails, DWORD dwFlags)
    {
        return (*this).CalcHuGains(chairno, nCardID, huDetails, dwFlags);
    };
    return imHuPerfect(lay, count, details, gain, chairno, nCardID, dwFlags, func);
}

CString CMJTable::RobotBoutLog(int nCardID)
{
    char str[10] = "0";
    if (nCardID == -1)
    {
        return str;
    }
    int nShape = m_pCalclator->MJ_CalculateCardShape(nCardID, 0);
    int nValue = m_pCalclator->MJ_CalculateCardValue(nCardID, 0);
    if (nShape == 0)
    {
        switch (nValue)
        {
        case 1:
            strcpy_s(str, "一萬");
            break;
        case 2:
            strcpy_s(str, "二萬");
            break;
        case 3:
            strcpy_s(str, "三萬");
            break;
        case 4:
            strcpy_s(str, "四萬");
            break;
        case 5:
            strcpy_s(str, "五萬");
            break;
        case 6:
            strcpy_s(str, "六萬");
            break;
        case 7:
            strcpy_s(str, "七萬");
            break;
        case 8:
            strcpy_s(str, "八萬");
            break;
        case 9:
            strcpy_s(str, "九萬");
            break;
        default:
            strcpy_s(str, "error0");
            break;
        }
    }
    else if (nShape == 1)
    {
        switch (nValue)
        {
        case 1:
            strcpy_s(str, "一条");
            break;
        case 2:
            strcpy_s(str, "二条");
            break;
        case 3:
            strcpy_s(str, "三条");
            break;
        case 4:
            strcpy_s(str, "四条");
            break;
        case 5:
            strcpy_s(str, "五条");
            break;
        case 6:
            strcpy_s(str, "六条");
            break;
        case 7:
            strcpy_s(str, "七条");
            break;
        case 8:
            strcpy_s(str, "八条");
            break;
        case 9:
            strcpy_s(str, "九条");
            break;
        default:
            strcpy_s(str, "error1");
            break;
        }
    }
    else if (nShape == 2)
    {
        switch (nValue)
        {
        case 1:
            strcpy_s(str, "一筒");
            break;
        case 2:
            strcpy_s(str, "二筒");
            break;
        case 3:
            strcpy_s(str, "三筒");
            break;
        case 4:
            strcpy_s(str, "四筒");
            break;
        case 5:
            strcpy_s(str, "五筒");
            break;
        case 6:
            strcpy_s(str, "六筒");
            break;
        case 7:
            strcpy_s(str, "七筒");
            break;
        case 8:
            strcpy_s(str, "八筒");
            break;
        case 9:
            strcpy_s(str, "九筒");
            break;
        default:
            strcpy_s(str, "error2");
            break;
        }
    }
    return str;
}

DWORD CMJTable::MJ_HuPai_PerFect(int lay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails_max, int& gains_max,
    BOOL bJiang, int chairno, int nCardID, HU_DETAILS& huDetails_run, DWORD dwFlags, int gains_limit, int deepth, BOOL bNorMalArithmetic)

{
    if (IsNewTingPaiActive())
    {
        if (CalcHuPerFect(chairno, nCardID, lay, huDetails_max, gains_max, dwFlags, MAX_CARDS_LAYOUT_NUM))
        {
            return MJ_HU;
        }
        return 0;
    }
    if (deepth > MJ_MAX_DEEPTH)
    {
        LOG_ERROR(_T("MyTable_MJ_HuPai_PerFect!!! deepth too much more than MJ_MAX_DEEPTH = %d)"), deepth);
        return 0;//超过递归上限返回
    }

    if (deepth == 10)
    {
        LOG_DEBUG(_T("MyTable_MJ_HuPai_PerFect!!! BEGIN deepth too much more than MJ_MAX_DEEPTH = %d)"), deepth);
        CString str;
        for (int i = 0; i < TOTAL_CARDS; i++)
        {
            CString strTmp;
            strTmp.Format("[%d,%d,%d],", m_aryCard[i].nChairNO, m_aryCard[i].nID, m_aryCard[i].nStatus);
            str += strTmp;
        }
        LOG_ERROR(str);
        LOG_ERROR("--------------------");
        for (int i = 0; i < m_nTotalChairs; i++)
        {
            CString str;
            for (int j = 0; j < MAX_CARDS_LAYOUT_NUM; j++)
            {
                CString strTmp;
                strTmp.Format("%d,", m_nCardsLayIn[i][j]);
                str += strTmp;
            }
            LOG_ERROR("%s", str);
        }
        LOG_ERROR("--------------------");
        LOG_ERROR("%d", m_nJokerID);
        CString szMsgStr;
        szMsgStr.Format(_T("MyTable_MJ_HuPai_PerFect!!! END m_njokerID = %d,nCardID = %d,chairno = %d,jokernum = %d"), m_nJokerID, nCardID, chairno, jokernum);
        LOG_ERROR("%s", szMsgStr);
    }
    deepth++;
    HU_DETAILS huDetails;
    if (!XygCardRemains(lay))//已经没有剩余的牌
    {
        if (m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2) == 0 && bJiang)//所有财神匹配完毕
        {
            int gains = CalcHuGains(chairno, nCardID, huDetails_run, dwFlags);
            if (bNorMalArithmetic == TRUE && gains > 0)
            {
                gains_max = gains;
                memcpy(&huDetails_max, &huDetails_run, sizeof(HU_DETAILS));
                return MJ_HU;
            }
            if (gains > gains_max)
            {
                gains_max = gains;
                memcpy(&huDetails_max, &huDetails_run, sizeof(HU_DETAILS));
            }
            //清理
            for (int j = 0; j < HU_MAX; j++)
            {
                huDetails_run.nHuGains[j] = 0;
            }

            if (gains >= gains_limit)//达到胡牌上限，则不再继续递归
            {
                return MJ_HU;
            }
            else
            {
                return 0;
            }
        }
        //剩余财神大于2张!递归
        if (m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2) >= 3)//剩余财神大于3
        {
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 3);   // 财神减3

            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddJokerUnit(huDetails, MJ_CT_KEZI, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;// 如果超过胡牌上限，结束递归
            }
            else
            {
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }

        if (!bJiang && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2) >= 2)
        {
            bJiang = TRUE;                          // 设置将牌标志
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 2);   // 财神减2
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddJokerUnit(huDetails, MJ_CT_DUIZI, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;// 如果超过胡牌上限，结束递归
            }
            else
            {
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
                bJiang = FALSE;     // 清除将牌标志
            }
        }

        if (deepth == 1)
        {
            //清理
            for (int j = 0; j < HU_MAX; j++)
            {
                huDetails_max.nHuGains[j] = 0;
            }
            return gains_max;
        }
        else
        {
            return 0;//无法匹配,不能胡!
        }

    }


    if (jokernum > 0)//递归财神1
    {
        jokernum--;
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        lay[jokeridx]++;
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果超过胡牌上限，结束递归
        }
        else
        {
            lay[jokeridx]--;
            jokernum++;
        }
    }

    if (jokernum2 > 0)//递归财神2
    {
        jokernum2--;
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        lay[jokeridx2]++;
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果超过胡牌上限，结束递归
        }
        else
        {
            lay[jokeridx2]--;
            jokernum2++;
        }
    }
    int i = 0;
    for (i = 1; i < MAX_CARDS_LAYOUT_NUM && lay[i] <= 0; i++);// 找到有牌的地方，i就是当前牌位置, lay[i]是张数
    if (i == MAX_CARDS_LAYOUT_NUM)
    {
        return 0;
    }

    // 3张组合(大对: 3张一样)
    if (lay[i] >= 3)
    {
        // 如果当前牌不少于3张
        lay[i] -= 3;        // 减去3张牌
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_KEZI, i, 0, 0, jokeridx, jokeridx2, 0, 0);
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果超过胡牌上限，结束递归
        }
        else
        {
            lay[i] += 3; // 取消3张组合
        }
    }


    // 3张组合(大对: 2张一样 + 财神)
    if (lay[i] >= 2 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))
    {
        // 如果当前牌不少于2张并且有财神
        lay[i] -= 2;        // 减去2张牌
        int jn, jn2;
        m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // 财神减1
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_KEZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果剩余的牌组合成功，胡牌
        }
        else
        {
            lay[i] += 2; // 取消3张组合
            m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
        }
    }

    // 3张组合(牌X + 2张财神)
    if (lay[i] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2) >= 2)
    {
        // 如果当前牌不少于1张并且有2张以上财神
        lay[i]--;   // 牌数减1
        int jn, jn2;
        m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 2);   // 财神减2

        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_KEZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果剩余的牌组合成功，胡牌
        }
        else
        {
            lay[i]++; // 恢复牌数
            m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
        }
    }

    // 2张组合(将牌: 2张一样)
    if (!bJiang && lay[i] >= 2)
    {
        // 如果之前没有将牌，且当前牌不少于2张
        bJiang = TRUE;              // 设置将牌标志
        lay[i] -= 2;                // 减去2张牌
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, 0, 0, jokeridx, jokeridx2, 0, 0);
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;    // 如果剩余的牌组合成功，胡牌
        }
        else
        {
            lay[i] += 2;        // 取消2张组合
            bJiang = FALSE;     // 清除将牌标志
        }
    }

    // 2张组合(将牌: 1张 + 财神)
    if (!bJiang && lay[i] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))   // 如果之前没有将牌，且当前牌不少于1张并且有财神
    {
        bJiang = TRUE;          // 设置将牌标志
        lay[i]--;               // 减去1张牌
        int jn, jn2;
        m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
        memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
        m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
        if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
        {
            return MJ_HU;       // 如果剩余的牌组合成功，胡牌
        }
        else
        {
            lay[i]++;   // 取消2张组合
            m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            bJiang = FALSE;     // 清除将牌标志
        }
    }

    if (i < 30)
    {
        // 顺牌组合，注意是从前往后组合！
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 2 && i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 && // 排除数值为8和9的牌
            lay[i + 1] > 0 && lay[i + 2] > 0)   // 如果后面有连续两张牌
        {

            lay[i]--;
            lay[i + 1]--;
            lay[i + 2]--; // 各牌数减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, i, 0, 0, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[i]++;
                lay[i + 1]++;
                lay[i + 2]++; // 恢复各牌数
            }
        }
        // 顺牌组合，2张连牌 + 1张财神
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 &&    // 排除数值为9的牌
            lay[i + 1] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))   // 如果后面有连续1张牌,并且有财神
        {

            lay[i]--;
            lay[i + 1]--;   // 各牌数减1
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[i]++;
                lay[i + 1]++; // 恢复各牌数
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        // 顺牌组合，牌X + 1张财神 + 牌(X+2)
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 2 && i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 &&    // 排除数值为8和9的牌
            lay[i + 2] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))   // 如果后面有跳张,并且有财神
        {

            lay[i]--;
            lay[i + 2]--;   // 各牌数减1
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[i]++;
                lay[i + 2]++; // 恢复各牌数
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
    }
    else if (IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))  // 风板可以吃
    {
        if (lay[31] > 0 && lay[32] > 0 && lay[33] > 0)  // 东南西
        {
            lay[31]--;
            lay[32]--;
            lay[33]--;
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;
                lay[32]++;
                lay[33]++;
            }
        }
        if (lay[31] > 0 && lay[32] > 0 && lay[34] > 0)  // 东南北
        {
            lay[31]--;
            lay[32]--;
            lay[34]--;
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 2);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;
                lay[32]++;
                lay[34]++;
            }
        }
        if (lay[32] > 0 && lay[33] > 0 && lay[34] > 0)  // 南西北
        {
            lay[32]--;
            lay[33]--;
            lay[34]--;
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, 0, 0, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[32]++;
                lay[33]++;
                lay[34]++;
            }
        }
        if (lay[31] > 0 && lay[33] > 0 && lay[34] > 0)  // 东西北
        {
            lay[31]--;
            lay[33]--;
            lay[34]--;
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 1);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;
                lay[33]++;
                lay[34]++;
            }
        }
        if (lay[35] > 0 && lay[36] > 0 && lay[37] > 0)  // 中发白
        {
            lay[35]--;
            lay[36]--;
            lay[37]--;
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, 0, 0, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU; // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[35]++;
                lay[36]++;
                lay[37]++;
            }
        }
        if (lay[31] > 0 && lay[32] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 东南
        {
            lay[31]--;      // 减去1张牌
            lay[32]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;      // 加1张牌
                lay[32]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[31] > 0 && lay[33] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 东西
        {
            lay[31]--;      // 减去1张牌
            lay[33]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;      // 加1张牌
                lay[33]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[31] > 0 && lay[34] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 东北
        {
            lay[31]--;      // 减去1张牌
            lay[34]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 2);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[31]++;      // 加1张牌
                lay[34]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[32] > 0 && lay[33] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 南西
        {
            lay[32]--;      // 减去1张牌
            lay[33]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {

                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[32]++;      // 加1张牌
                lay[33]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[32] > 0 && lay[34] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 南北
        {
            lay[32]--;      // 减去1张牌
            lay[34]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[32]++;      // 加1张牌
                lay[34]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[33] > 0 && lay[34] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 西北
        {
            lay[33]--;      // 减去1张牌
            lay[34]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 33, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[33]++;      // 加1张牌
                lay[34]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[35] > 0 && lay[36] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 中发
        {
            lay[35]--;      // 减去1张牌
            lay[36]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[35]++;      // 加1张牌
                lay[36]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[35] > 0 && lay[37] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 中白
        {
            lay[35]--;      // 减去1张牌
            lay[37]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[35]++;      // 加1张牌
                lay[37]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[36] > 0 && lay[37] > 0 && m_pCalclator->MJ_TotalJokerNum(jokernum, jokernum2))  // 发白
        {
            lay[36]--;      // 减去1张牌
            lay[37]--;      // 减去1张牌
            int jn, jn2;
            m_pCalclator->MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // 财神减1
            memcpy(&huDetails, &huDetails_run, sizeof(HU_DETAILS));
            m_pCalclator->MJ_AddUnit(huDetails, MJ_CT_SHUN, 36, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
            if (MJ_HuPai_PerFect(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails_max, gains_max, bJiang, chairno, nCardID, huDetails, dwFlags, gains_limit, deepth))
            {
                return MJ_HU;       // 如果剩余的牌组合成功，胡牌
            }
            else
            {
                lay[36]++;      // 加1张牌
                lay[37]++;      // 加1张牌
                m_pCalclator->MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
    }

    // 无法全部组合，不胡！

    //递归完毕，返回最大胡数
    if (deepth == 1)
    {
        //清理
        for (int j = 0; j < HU_MAX; j++)
        {
            huDetails_max.nHuGains[j] = 0;
        }
        return gains_max;
    }
    else
    {
        return 0;
    }

    return 0;
}
