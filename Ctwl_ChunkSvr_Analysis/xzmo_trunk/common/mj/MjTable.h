#pragma once
class CMJTable : public CCommonBaseTable
{
public:
    CMJTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1,
        int totalchairs = MJ_CHAIR_COUNT, DWORD gameflags = MJ_GAME_FIAGS,
        DWORD gameflags2 = 0,
        int max_asks = MAX_ASK_REPLYS,
        int totalcards = MJ_TOTAL_CARDS,
        int totalpacks = MJ_TOTAL_PACKS, int chaircards = MJ_CHAIR_CARDS, int bottomcards = 0,
        int layoutnum = MJ_LAYOUT_NUM, int layoutmod = MJ_LAYOUT_MOD, int layoutnumex = 0,
        int abtpairs[] = NULL,
        int throwwait = MJ_THROW_WAIT, int maxautothrow = MJ_MAX_AUTO,
        int entrustwait = DEF_ENTRUST_WAIT,
        int max_auction = MAX_AUCTION_GAINS, int min_auction = MIN_AUCTION_GAINS,
        int def_auction = DEF_AUCTION_GAINS, int pgchwait = MJ_PGCH_WAIT,
        int max_banker_hold = MJ_MAX_BANKER_HOLD,
        DWORD huflags = 0, DWORD huflags2 = 0);

public:
    //From CTable
    int m_nDices[MAX_DICE_NUM];         // 骰子大小
    //From CCardTable
    int m_nTotalCards;                  // 牌张数
    int m_nTotalPacks;                  // 几副牌
    int m_nChairCards;                  // 每人最多牌张数
    int m_nBottomCards;                 // 底牌张数
    int m_nLayoutNum;                   // 牌的方阵长度
    int m_nLayoutMod;                   // 牌阵模数长度
    int m_nLayoutNumEx;                 // 牌的方阵长度(扩展)
    int m_nThrowWait;                   // 出牌等待时间(秒)
    int m_nEntrustWait;                 // 托管等待时间(秒)
    int m_nMaxAutoThrow;                // 允许自动出牌的最大次数
    int m_nMaxAuction;                  // 允许最大叫分
    int m_nMinAuction;                  // 允许最小叫分
    int m_nDefAuction;                  // 默认叫分

    // 固定信息，跟局数无关
    int m_nPGCHWait;        // 碰杠吃胡等待时间(秒)
    int m_nMaxBankerHold;   // 最大连续坐庄局数
    DWORD m_dwHuFlags[MJ_HU_FLAGS_ARYSIZE];       // 胡牌种类标志数组
    // 动态信息，跟上局相关
    int m_nFirstCatch;                          // 第一个摸牌
    int m_nFirstThrow;                          // 第一个出牌
    int m_nBankerHold;      // 连续坐庄局数

    // 动态信息，跟局数相关
    CCardAry m_aryCard;                      // 所有牌的信息
    int      m_nCardsLayIn[MAX_CHAIRS_PER_TABLE][MAX_CARDS_LAYOUT_NUM];  // 每个人手里的牌
    int      m_nBottomIDs[MAX_BOTTOM_CARDS]; // 底牌ID
    int      m_nAuctionCount;                        // 叫庄计数
    AUCTION  m_Auctions[MAX_AUCTION_COUNT];          // 叫庄情况记录
    int      m_nObjectGains;                         // 叫分标的
    int      m_nCatchFrom;                           // 开始摸牌位置
    int      m_nJokerNO;                             // 财神位置
    int      m_nJokerID;                             // 财神牌ID
    DWORD    m_dwLatestThrow;    // 最近出牌时间(ms)
    int      m_nThrowCount;      // 出牌第几手计数
    BOOL     m_bQuickCatch;      // 快速抓牌
    int      m_nJokerID2;        // 财神牌ID2
    int      m_nHeadTaken;       // 头上被抓牌张数
    int      m_nTailTaken;       // 尾上被抓牌张数
    int      m_nCurrentCatch;    // 当前抓牌位置

    DWORD    m_dwPGCHFlags[MJ_CHAIR_COUNT];      // 出牌后碰杠吃胡状态
    DWORD    m_dwGuoFlags[MJ_CHAIR_COUNT];       // 出牌后能否过牌标志
    int      m_nGangID;          // 杠牌ID
    int      m_nGangChair;       // 杠牌位置
    int      m_nCardChair;       // 牌所属位置

    int     m_nJokersThrown[MJ_CHAIR_COUNT]; // 财神打出个数
    int     m_nCaiPiaoChair;    // 财飘位置
    int     m_nCaiPiaoCount;    // 财飘个数
    int     m_nGangKaiCount;    // 杠开计数
    DWORD   m_dwLatestPreGang;  // 准备杠牌计时开始
    int     m_nLoseChair;       // 放冲或者被抢杠者位置
    int     m_nHuChair;         // 胡牌者位置
    int     m_nHuCount;         // 胡牌人数
    int     m_nHuCard;          // 胡牌ID
    int     m_nLastGangNO;
    int     m_nCurrentCard;  //当前抓牌的cardID
    int     m_nCurrentOpeCard; //当前操作的牌
    int     m_nLastThrowChair; //上次出牌者.
    int     m_nLastThrowCard[MJ_CHAIR_COUNT][MAX_CARDS_LAYOUT_NUM];  //用于calcPGCH能否跟碰用

    DWORD     m_dwWaitOpeFlag;
    int       m_nWaitOpeMsgID;
    int       m_nWaitOpeChair;
    COMB_CARD m_WaitOpeMsgData;
    int       m_nbaoTing[MJ_CHAIR_COUNT]; //报听

    //抢杠胡标志
    int m_nQghFlag;
    int m_nQghID;
    int m_nQghChair;

    // 一起玩房间的自动托管
    int   m_nYqwAutoPlayWait;
    int   m_nYqwAutoPlay;           //yqw自动托管
    int   m_nYQWQuickThrowWait;
    int   m_nYQWQuickPGCWait;
    int   m_nYqwQuickRoom;          //yqw快速房

    CCardsUnitArray m_PengCards[MJ_CHAIR_COUNT]; // 玩家碰出的牌
    CCardsUnitArray m_ChiCards[MJ_CHAIR_COUNT]; // 玩家吃出的牌
    CCardsUnitArray m_MnGangCards[MJ_CHAIR_COUNT]; // 玩家明杠的牌
    CCardsUnitArray m_AnGangCards[MJ_CHAIR_COUNT]; // 玩家暗杠的牌
    CCardsUnitArray m_PnGangCards[MJ_CHAIR_COUNT]; // 玩家碰杠的牌
    CDWordArray m_nOutCards[MJ_CHAIR_COUNT];    // 玩家打出的牌
    CDWordArray m_nHuaCards[MJ_CHAIR_COUNT];    // 玩家补花的牌

    int     m_nPengFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT];
    int     m_nChiFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT];
    int     m_nGangFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT];
    int     m_nCatchCount[MJ_CHAIR_COUNT];  // 玩家抓到的牌数目(包括杠到的牌)

    // 胡牌信息，胡牌失败后重置(但胡牌前分数信息不动)
    int     m_nResults[MJ_CHAIR_COUNT];         // 胡牌返回
    HU_DETAILS m_huDetails[MJ_CHAIR_COUNT];     // 胡牌详细(包含胡牌前分数信息)
    //听牌提示
    CARD_TING_DETAIL    m_CardTingDetail;
    CARD_TING_DETAIL_16 m_CardTingDetail_16;
    BYTE m_nTingCardsDXXW[MJ_CHAIR_COUNT][MAX_CARDS_LAYOUT_NUM];
    //战绩榜
    int m_nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int m_nTotalResult[MAX_CHAIR_COUNT];
    //埋点
    int m_nStartHandCards[MAX_CHAIRS_PER_TABLE][MAX_CARDS_PER_CHAIR];   // 开始手牌
    int m_nFinalHandCards[MAX_CHAIRS_PER_TABLE][MAX_CARDS_PER_CHAIR];   // 结束手牌
    CARDS_UNIT m_nFinalPGCCards[MAX_CHAIRS_PER_TABLE][MJ_UNIT_LEN];
    // 算法类
    std::shared_ptr<CMJCalclator> m_pCalclator;

    virtual void ResetMembers(BOOL bResetAll = TRUE)override;
    virtual void ResetTable()override;//清除桌子游戏，局数重新开始
    virtual int Restart(int& errchair, int deposit_mult = 1,
        int deposit_min = MIN_DEPOSIT_NEED,
        int fee_ratio = 1, int max_trans = 0,
        int cut_ratio = 100, int deposit_logdb = 0,
        int fee_mode = 0, int fee_value = 0,
        int base_silver = 0, int max_bouttime = 0,
        int base_score = 0, int score_min = 0, int score_max = 0,
        int max_user_bout = 0, int max_table_bout = 0,
        int min_player_count = 0/*可变桌椅最低要求玩家数*/,
        int fee_tenthousandth = 0/*新茶水费收取万分比*/, int fee_minimum = 0/*新茶水费起征点*/)override; // 游戏重新开始，玩家未离开

    virtual void InitModel()override;
    //各种fill，需要重载
    virtual int  GetEnterGameInfoSize()override;
    virtual void FillupEnterGameInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE)override;
    virtual int  GetGameTableInfoSize()override;
    virtual void FillupGameTableInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE)override;
    virtual int  GetGameStartSize()override;
    virtual void FillupGameStart(void* pData, int nLen, int chairno, BOOL lookon = FALSE)override;
    virtual int  GetGameWinSize()override;
    virtual int  FillupGameWin(void* pData, int nLen, int chairno)override;
    virtual void FillupStartData(void* pData, int nLen);
    virtual void FillupPlayData(void* pData, int nLen);

    virtual void StartDeal()override;
    virtual void ThrowDices()override;
    virtual int  PrepareNextBout(void* pData, int nLen)override;
    virtual int  SetRoundAfter(void* pData, int nLen)override;
    virtual BOOL ReplaceAutoThrow(LPTHROW_CARDS pThrowCards);
    virtual int  SetGroupsOnAuctionFinished();
    virtual int  CalcCatchFrom();
    virtual int  CalcJokerNO();
    virtual int  CalcJokerID();
    virtual int  CalcFirstCatchBefore();
    virtual int  CalcFirstThrowBefore();
    virtual int  CalcFirstCatchAfter(void* pData, int nLen);
    virtual int  CalcFirstThrowAfter(void* pData, int nLen);
    virtual BOOL IsNextFirstHand();
    virtual int  GetNextChairRemains(int chairno);
    virtual void InitializeCards();
    virtual int  CreateRandomCards(CCardIDAry& aryCardID, int nMaxNum);
    virtual void BuildUpCards(CCardIDAry& aryCardID);
    virtual void CreateCardsFromFile(CCardIDAry& aryCardID);
    virtual int  CreateIntFromFile(LPCTSTR szKey, int& int_value);
    virtual int  GetInitChairCards();
    virtual void DealCards();
    virtual BOOL CheckCards();
    virtual int  GetCardNO(int nCardID);
    virtual int  GetCardID(int nCardNO);
    virtual int  HaveCards(int chairno);
    virtual BOOL IsCardInHand(int chairno, int nCardID);
    virtual BOOL IsCardIDsInHand(int chairno, int nCardIDs[]);
    virtual BOOL IsCardIDsInHandEx(int chairno, int nCardIDs[], int nCardsLen);
    virtual int  GetChairCards(int chairno, int nCardIDs[], int nCardsLen);
    virtual int  GetFirstCardOfChair(int chairno);
    virtual int  GetChairOfCard(int nCardID);
    virtual int  GetStatusOfCard(int nCardID);
    virtual int  SetStatusOfCard(int nCardID, int nStatus);
    virtual int  SetChairOfCard(int nCardID, int new_chair);
    virtual int  SetChairOfCardInHand(int nCardID, int new_chair);
    virtual BOOL ThrowCards(int chairno, int nCardIDs[]);
    virtual int  LoseCard(int chairno, int nCardID);
    virtual int  GainCard(int chairno, int nCardID);
    virtual int  LoseCardByNO(int chairno, int nCardNO);
    virtual int  GainCardByNO(int chairno, int nCardNO);
    virtual BOOL IsJoker(int nCardID);
    virtual int  LayCards(int nCardIDs[], int nCardsLen, int nCardsLay[]);
    virtual int  LayCardsBack(int nCardsLay[], int nCardsIn[], int nCardsLen, int nCardsOut[]);
    virtual int  LayCardsReverse(int nCardsLay[], int nCardIDs[], int chairno);
    virtual int  GetNextIDByIndex(CCardAry& aryCard, int chairno, int index);
    virtual int  ReverseIndexToID(int index);
    virtual int  GetCardIndex(int nCardID);
    virtual int  HaveDiffCards(int nCardsLay[]);
    virtual int  HaveDiffCardsEx(int nCardsLayEx[]);
    virtual int  CardRemains(int nCardsLay[]);
    virtual int  CardRemainsEx(int nCardsLayEx[]);
    virtual int  GetFirstCardIndex(int nCardsLay[]);
    virtual int  GetFirstCardIndexEx(int nCardsLayEx[]);
    virtual int  CalculateCardShape(int nID);
    virtual int  CalculateCardValue(int nID);

    virtual DWORD SetStatusOnThrow();
    virtual int   SetCurrentChairOnThrow();
    virtual BOOL  SetWaitingsOnThrow(int chairno, int nCardIDs[], int dwCardsType);
    virtual BOOL  SetWaitingsOnEnd();
    virtual DWORD SetStatusOnCatch();
    virtual int   SetCurrentChairOnCatch();
    virtual DWORD CalcWinOnThrow(int chairno, int nCardIDs[], int dwCardsType);
    virtual BOOL  OnAuctionBanker(LPAUCTION_BANKER pAuctionBanker, int& auction_finished);
    virtual BOOL  OnAuctionFinished();
    virtual int   OnNoCardRemains(int chairno);

    virtual void  ActuallizeResults(void* pData, int nLen)override;
    virtual int   BreakDoubleOfDeposit(int defdouble)override;
    virtual int   CalcNextBanker(void* pData, int nLen);

    virtual int   CalcBankerHold(void* pData, int nLen);
    virtual int   CalcBankerChairBefore()override;
    virtual int   CalcBankerChairAfter(void* pData, int nLen)override;
    virtual int   PlusJokerIDFromShown(int shownid);
    virtual int   CalcAfterDeal()override;
    virtual DWORD SetStatusOnStart()override;
    virtual int   GetJokerNumInHand(int chairno);
    virtual BOOL  IsHua(int nCardID);
    virtual int   ValidateThrow(int chairno, int nCardsOut[], int nOutCount, DWORD dwCardsType, int nValidIDs[]);
    virtual DWORD SetStatusOnPeng(int chairno);
    virtual int   SetCurrentChairOnPeng(int chairno);
    virtual DWORD SetStatusOnChi(int chairno);
    virtual int   SetCurrentChairOnChi(int chairno);
    virtual DWORD SetStatusOnGang(int chairno);
    virtual int   SetCurrentChairOnGang(int chairno);
    virtual BOOL  ValidateAutoCatch(int chairno, int& diff, bool bQuickCatch = false);
    virtual BOOL  ValidateAutoThrow(int chairno);
    virtual int   ValidateCatch(int chairno);
    virtual int   CatchCard(int chairno, BOOL& bBuHua);
    virtual int   ThrowJokerShown(int chairno);
    virtual BOOL  ValidateGuo(int chairno, int chairout);
    virtual BOOL  ValidatePrePeng(LPPREPENG_CARD pPrePengCard);
    virtual BOOL  ValidatePreGang(LPPREGANG_CARD pPreGangCard);
    virtual BOOL  ValidatePreChi(LPPRECHI_CARD pPreChiCard);
    virtual BOOL  ValidatePeng(LPPENG_CARD pPengCard);
    virtual BOOL  ValidateChi(LPCHI_CARD pChiCard);
    virtual BOOL  ValidateMnGang(LPGANG_CARD pGangCard);
    virtual BOOL  ValidateAnGang(LPGANG_CARD pGangCard);
    virtual BOOL  ValidatePnGang(LPGANG_CARD pGangCard);
    virtual BOOL  ValidateHua(LPHUA_CARD pHuaCard);
    virtual BOOL  ShouldPengWait(LPPENG_CARD pPengCard);
    virtual BOOL  ShouldChiWait(LPCHI_CARD pChiCard);
    virtual BOOL  ShouldMnGangWait(LPGANG_CARD pGangCard);
    virtual BOOL  ShouldPnGangWait(LPGANG_CARD pGangCard);
    virtual BOOL  ValidateHu(LPHU_CARD pHuCard);
    virtual int   ValidateHuQgng_Mn(int chairno, int cardchair, int cardid);
    virtual int   ValidateHuQgng_Pn(int chairno, int cardchair, int cardid);
    virtual int   ValidateHuFang(int chairno, int cardchair, int cardid);
    virtual int   ValidateHuZimo(int chairno, int cardchair, int cardid);
    virtual int   OnGuo(int chairno, int chairout);
    virtual int   OnPrePeng(LPPREPENG_CARD pPrePengCard);
    virtual int   OnPreGang(LPPREGANG_CARD pPreGangCard);
    virtual int   OnPreChi(LPPRECHI_CARD pPreChiCard);
    virtual int   OnPeng(LPPENG_CARD pPengCard);
    virtual int   OnChi(LPCHI_CARD pChiCard);
    virtual int   OnMnGang(LPGANG_CARD pGangCard);
    virtual int   OnAnGang(LPGANG_CARD pGangCard);
    virtual int   OnPnGang(LPGANG_CARD pGangCard);
    virtual int   OnHua(LPHUA_CARD pHuaCard);
    virtual int   GetGangCard(int chairno, BOOL& bBuHua);
    virtual int   GetNextHuaID(int chairno);
    virtual int   HuaCard(int chairno, int huaid);
    virtual int   CalcPengGains(LPPENG_CARD pPengCard);
    virtual int   CalcChiGains(LPCHI_CARD pChiCard);
    virtual int   CalcMnGangGains(LPGANG_CARD pGangCard);
    virtual int   CalcAnGangGains(LPGANG_CARD pGangCard);
    virtual int   CalcPnGangGains(LPGANG_CARD pGangCard);
    virtual int   CalcHuaGains(LPHUA_CARD pHuaCard);
    virtual int   OnHu(LPHU_CARD pHuCard);
    virtual int   OnHuQgng_Mn(int chairno, int cardchair, int cardid);
    virtual int   OnHuQgng_Pn(int chairno, int cardchair, int cardid);
    virtual int   OnHuFang(int chairno, int cardchair, int cardid);
    virtual int   OnHuZimo(int chairno, int cardchair, int cardid);
    //
    virtual int OnJokerThrow(int chairno, int nCardID);
    virtual int OnNotJokerThrow(int chairno, int nCardID);
    virtual int OnCatchCardFail(int chairno);
    virtual int GangCardFail(int chairno);
    virtual int OnGangCardFailed(int chairno);

    virtual DWORD CalcPGCH(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD flags);
    virtual DWORD CalcPeng(int chairno, int nCardID);     // 根据手里的牌加上这张牌，判断能否碰
    virtual BOOL  IsCardIDsPengCards(int chairno, int nCardIDs[], int nCardsLen);
    virtual BOOL  RemovePengCards(int chairno, int nCardIDs[], int nCardsLen);
    virtual BOOL  IsPengCardsGanged(int chairno, int nCardIDs[], int nCardsLen);
    virtual int   CalcPreGangOK(LPPREGANG_CARD pPreGangCard, PREGANG_OK& pregang_ok);
    virtual DWORD CalcGang(int chairno, int nCardID, DWORD dwFlags);     // 根据手里的牌加上这张牌，判断能否杠(明杠或暗杠)
    virtual DWORD CalcPnGang(int chairno, int nCardID);    // 根据碰出的牌加上这张牌，判断能否杠(碰杠)
    virtual DWORD CalcChi(int chairno, int nCardID);    // 根据手里的牌加上这张牌，判断能否吃
    virtual DWORD CalcHua(int chairno, int nCardID);    // 判断能否补花
    virtual DWORD CalcHu_Zimo(int chairno, int nCardID);
    virtual DWORD CalcHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE);     // 根据手里的牌加上这张牌，判断能否胡(放冲或自摸)
    virtual DWORD CalcHu_Various(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE);
    virtual DWORD CalcHu_Most(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE);
    virtual int   CalcHuGains(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD CalcWinOnHu(int chairno);
    virtual int   CanHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual int   GetFailedResponse(int chairno);

    virtual BOOL CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[])override;
    virtual int  CalcBankerPoints(void* pData, int nLen, int chairno, int nWinPoints[]);
    virtual int  CalcUnderTake(void* pData, int nLen, int chairno, int nWinPoints[]);
    virtual int  CalcGangEtcPoints(void* pData, int nLen, int chairno, int nWinPoints[]);

    virtual BOOL IsBankWin(void* pData, int nLen, int chairno)override;
    virtual int  CalcResultDiffs(void* pData, int nLen, int nScoreDiffs[], int nDepositDiffs[])override;

    virtual int  CancelSituationOfGang();
    virtual int  CancelSituationInCard();

    virtual int   IsSameCard(int id1, int id2);
    virtual int   FindCardID(CDWordArray& dwArray, int nCardID);

    virtual int   GetTotalShapes(int shapedCount[]);
    virtual int   GetCardShape(int cardidx, int baiban_joker);
    virtual int   GetShapedCountIn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, int baiban_joker, int shapedCount[]);
    virtual int   GetShapedCountOut(int chairno, int baiban_joker, int shapedCount[]);
    virtual int   IsOutSomething(int chairno);
    virtual int   Is258Out(int chairno);
    virtual DWORD GetOutOfChair(int chairno);
    //
    virtual DWORD Hu_Tian(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_Di(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_Bank(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_PnPn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_1Clr(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_2Clr(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_Feng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_WuDa(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_CSGW(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_3Cai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_4Cai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_GKai(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_DDCh(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_HDLY(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_CaiP(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_MQng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_QQrn(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);

    virtual BOOL IsTingPaiActive()  { return GetPrivateProfileInt(_T("TingPai"), _T("enable"), 0, GetINIFilePath()); }
    virtual BOOL IsNewTingPaiActive()  { return GetPrivateProfileInt(_T("NewTingPai"), _T("enable"), 0, GetINIFilePath()); }

    virtual DWORD CalcTingCard(int chairno);
    virtual DWORD CalcTingCard_17(int chairno);
    virtual DWORD CalcHu_TingCard(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual BOOL  IsAnGangCard(int nCardID);
    virtual BOOL  IsValidCard(int nCardID);
    virtual int   CalcCardIdByIndex(int nCardIndex);
    virtual BOOL  ShouldAnGangWait(LPGANG_CARD pGangCard);
    virtual void  SaveTingCardsForDXXW(int nThrowCardID, int nChairNO);
    virtual int   ValidateMergeCatch(int chairno);
    //吃碰杠重构
    virtual int ShouldReConsChiWait(LPCHI_CARD pChiCard);
    virtual int ShouldReConsPengWait(LPPENG_CARD pPengCard);
    virtual int ShouldReconsMnGangWait(LPGANG_CARD pGangCard);
    virtual int ShouldReconsPnGangWait(LPGANG_CARD pGangCard);
    virtual int ShouldReconsAnGangWait(LPGANG_CARD pGangCard);
    virtual int OnReconsGuo(int chairno);

    virtual int ValidateHuQgng_An(int chairno, int cardchair, int cardid);
    virtual int OnHuQgng_An(int chairno, int cardchair, int cardid);

    virtual void ResetWaitOpe();
    virtual void UseServerHuCardID(int& nCardID);
    virtual int  GetNextBoutBanker();
    virtual int  GetChairOutCards(int chairno, CARDS_UNIT nCards[], DWORD type = MJ_GANG | MJ_PENG | MJ_CHI);//取得属于自己的所有的牌
    virtual int  GetLastCatchCard(int chairno);
    virtual BOOL GetUseServerHuCardID();

    virtual void MJ_InitializeCardsUnit(CARDS_UNIT& cards_unit);
    virtual void MJ_ClearHuUnits(LPHU_DETAILS lpHuDetails);

    virtual int MJ_CalcFours(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_TotalGains(HU_DETAILS& huDetails);
    virtual int MJ_TotalSubGains(HU_DETAILS& huDetails);
    virtual int MJ_CalcJokerAsJokers(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags);

    virtual void MJ_MixupHuDetails(HU_DETAILS& huDetails1, HU_DETAILS& huDetails2);
    virtual int MJ_IsFengKG(HU_UNIT unit, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual bool IsRestCard(int cardID, int type = 0);
    virtual int CalLastCounts();
    virtual BOOL IsLastFourCard();
    virtual void GetAllCardHand(int chairno, int cards[], DWORD type = MJ_GANG | MJ_PENG | MJ_CHI);//取得属于自己的所有的牌
    virtual BOOL GetJokerInfoInUnit(const HU_UNIT& unit, int& jokernum, int& jokerpresent, int& jokerpresent2);
    virtual BOOL IsNoJokerInUnit(const HU_UNIT& unit);
    virtual int GetHongZhongCount(int chairno);
    virtual int GetBankerGains();

    virtual int GetMaxResultScore();  //获得得分最大的分数
    virtual void SetBaoTingFlag(int nChairNO);
    virtual void YQW_SetAutoPlay(int nYQWAutoPlay);
    virtual void YQW_SetQuickRoom(int nYqwQucikRoom);          //yqw快速房
    virtual int IsYQWQuickRoom();
    virtual int IsYQWAutoPlay();
    virtual int YQW_TotalGain(HU_DETAILS& huDetails, int j);
    virtual int YQW_CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[]);
    virtual int YQW_GetBankScore();
    virtual void YQW_CompensateWinPoints(int nWinPoints[]);
    int RoundDouble(double number);
    virtual BOOL  ValidateGuoRecons(int chairno, int chairout);
    // pb msg
    virtual google::protobuf::MessageLite* GetHuaData();
    CString GetINIMakeCardName();  //做牌

    virtual BOOL CalcHuFast(int chairno, int nCardID, int lay[], int count);
    virtual BOOL CalcHuPerFect(int chairno, int nCardID, int lay[], HU_DETAILS& details, int& gain, DWORD dwFlags, int count);
    CString    RobotBoutLog(int nCardID);


    //// My层下沉的算法
    virtual DWORD MJ_HuPai_PerFect(int lay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails_max, int& gains_max, BOOL bJiang,
        int chairno, int nCardID, HU_DETAILS& huDetails_run, DWORD dwFlags, int gains_limit, int deepth, BOOL bNorMalArithmetic = FALSE);

    // args:[int lay[], int count]
    ImportFunctional<bool(int[], int)> imCanHuFast;
    /* args:[
        int lay[], int count, HU_DETAILS& details,
        int& gain, int chairno, int cardid, DWORD dwFlags,
        std::function<int(int chairno, int nCardID, HU_DETAILS & huDetails, DWORD dwFlags)>& func]
    */
    ImportFunctional<bool(int[], int, HU_DETAILS&, int&, int, int, DWORD,
        std::function<int(int, int, HU_DETAILS&, DWORD)>&)> imHuPerfect;
};
