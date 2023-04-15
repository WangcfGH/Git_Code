class CMyGameTable : public CMJTable
{
public:
    CMyGameTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1,
        int totalchairs = TOTAL_CHAIRS, DWORD gameflags = GAME_FLAGSEX,
        DWORD gameflags2 = 0,
        DWORD huflags = HU_FLAGS_0EX, DWORD huflags2 = HU_FLAGS_1EX,
        int max_asks = MAX_ASK_REPLYS,
        int totalcards = TOTAL_CARDS,
        int totalpacks = TOTAL_PACKS, int chaircards = CHAIR_CARDS, int bottomcards = 0,
        int layoutnum = LAYOUT_NUM, int layoutmod = LAYOUT_MOD, int layoutnumex = LAYOUT_NUM_EX,
        int abtpairs[] = NULL,
        int throwwait = THROW_WAIT, int maxautothrow = MJ_MAX_AUTO,
        int entrustwait = DEF_ENTRUST_WAIT,
        int max_auction = MAX_AUCTION_GAINS, int min_auction = MIN_AUCTION_GAINS,
        int def_auction = DEF_AUCTION_GAINS, int pgchwait = PGCH_WAIT,
        int max_banker_hold = MAX_BANKER_HOLD);

    int m_nChairThrowCount[TOTAL_CHAIRS];
    int m_nFeedChair[TOTAL_CHAIRS][4];  //每个人最多吃碰4个组合
    int nAfterChiPengStatus;
    int m_nLeastBout;
    int m_nMaxUserBout;
    int m_nLastPeng3dui4dui;
    int m_nPeng3duiChairNO[TOTAL_CHAIRS];//除去暗杠  为了最后计算承包用
    int m_nPeng4duiChairNO[TOTAL_CHAIRS];
    int m_nPengNum[TOTAL_CHAIRS];
    DWORD m_dwGangAfterCatch;   // 为了解决川麻特有的杠上开花规则加的变量
    //倍数
    int m_nMultipleScore;

    virtual void ResetMembers(BOOL bResetAll = TRUE) override;
    virtual void FillupGameTableInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual void FillupGameStart(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual int GetGameStartSize() override;
    virtual int  GetGameStartSize4Looker() override;
    virtual void FillupGameStart4Looker(void* pData, int nLen, CPlayer* pLooker) override;
    virtual int  GetGameTableLookerInfoSize() override;//新旁观(且后台返回)
    virtual void FillupGameTableLookerInfo(void* pData, int nLen, CPlayer* pLooker) override;
    virtual BOOL LeaveAsBreak(int least_bout = 0, int least_round = 0) override;
    virtual BOOL IsGameOver() override;
    virtual int  TellBreakChair(int leavechair, DWORD waitsecs) override;
    BOOL IsBreakChairNotAllow();

    virtual int   GetChairCards(int chairno, int nCardIDs[], int nCardsLen) override;
    virtual int   OnCatchCardFail(int chairno) override;
    virtual BOOL  ThrowCards(int chairno, int nCardIDs[]) override;
    virtual BOOL  ValidateAutoThrow(int chairno) override;
    virtual int   OnPeng(LPPENG_CARD pPengCard) override;
    virtual int   OnMnGang(LPGANG_CARD pGangCard) override;
    virtual int   CalcPreGangOK(LPPREGANG_CARD pPreGangCard, PREGANG_OK& pregang_ok) override;
    virtual int   OnHuQgng_Mn(int chairno, int cardchair, int cardid) override;
    virtual int   OnHuQgng_Pn(int chairno, int cardchair, int cardid) override;
    virtual int   CalcHuGains(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags) override;

    virtual int   ReadLeastBout();
    virtual int   CalcFirstCatchAfter(void* pData, int nLen) override;//决定下一局谁先抓牌，返回庄家，由CCardTable的prepairNextBout调用
    virtual int   CalcCatchFrom() override;
    virtual DWORD CalcPGCH(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD flags) override;
    virtual DWORD CalcHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual DWORD CalcHu_Various(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual DWORD CalcHu_Most(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual void  CopyHuDetailsSmall(int chairno, HU_DETAILS_EX& huDetailsSmall, HU_DETAILS& huDetails) /*override*/;
    virtual BOOL  CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual int   GetTotalGain(HU_DETAILS& huDetails, int HuMax) /*override*/;//HuMax表示番数
    virtual int   CalcUnderTake(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual int   CalcPengGains(LPPENG_CARD pPengCard) override;
    virtual int   CalcMnGangGains(LPGANG_CARD pGangCard) override;
    virtual int   CalcAnGangGains(LPGANG_CARD pGangCard) override;
    virtual int   CalcPnGangGains(LPGANG_CARD pGangCard) override;
    virtual DWORD CalcHu_TingCard(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags) override;//听牌功能添加
    virtual int   GetNextBoutBanker() override;

    virtual DWORD Hu_MQng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags) override;//门清
    virtual int CalcGangEtcPoints(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual DWORD MJ_CanHu_13BK_EX(int nCardsLay[], int nCardID, DWORD gameflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno);
    virtual DWORD MJ_CanHu_PerFect(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno,
        BOOL bNorMalArithmetic = FALSE);

    int   OnAfterPeng(int nChairNO);

    int   MyGetSortValueByMJID(int nCardID) ;//吃碰后切后台回来,第一张手牌位置改变了
    int   CalcTotalGangGains(int nGanggains[]);
    BOOL  isUseServerHuCardID() { return GetPrivateProfileInt(_T("UseServerHuCardID"), _T("enable"), 0, GetINIFileName()); }

    // xo add
    MAKECARD_CONFIG m_stMakeCardConfig;
    MAKECARD_INFO   m_stMakeCardInfo[TOTAL_CHAIRS];
    int     m_nTakeFeeTime;
    int     m_nDingQueWait; //定缺等待时间
    int     m_nDingQueCardType[TOTAL_CHAIRS]; //定缺的牌 add 20130916
    DWORD   m_dwDingQueStartTime;
    int     m_nShowTask;
    int     m_nRechargeTime;
    int     m_nGiveUpTime;
    int     m_nGiveUpChair[TOTAL_CHAIRS];
    BOOL    m_bShowGiveUp[TOTAL_CHAIRS]; //客户端是否显示放弃框
    BOOL    m_bPlayerRecharge;
    DWORD   m_dwGiveUpStartTime;
    BOOL    m_bNewRuleOpen;                         //呼叫转移、海底捞月和退税新规则是否开启
    BOOL    m_bCallTransfer;                        //是否需要呼叫转移
    int     m_nEndGameFlag;                         //结束时需要播放的动画
    BOOL    m_nextAskNewTable;
    GAMEEND_CHECK_INFO m_stEndGameCheckInfo;
    BOOL    m_bOpenSaveResultLog;                   //保存游戏结果日志开关
    int     m_nDepositWinLimit[TOTAL_CHAIRS];

    int     m_HuMinLimit;                       //最小胡番
    int     m_HuMaxLimit;                       //最大胡番
    int     m_nPengWait;
    int     m_nLatestThrowNO;                   //最近一次出牌玩家
    int     m_feeRatioToBaseDeposit;            //相对基础银计算出对应的茶水费，按照该比例算，千分比

    int     m_nRoomFees[TOTAL_CHAIRS];
    int     m_nInitDeposit[TOTAL_CHAIRS];
    int     m_nLatestedGetMJIndex[TOTAL_CHAIRS];
    DWORD   m_HuReady[TOTAL_CHAIRS];            //是否已胡牌

    int m_nMultiple[TOTAL_CHAIRS];//胡牌番数
    int m_nTimeCost[TOTAL_CHAIRS];//对局耗时
    int m_nTotalGameCount[TOTAL_CHAIRS];//桌上每个玩家的对局总局数
    int m_nXZTotalGameCount[TOTAL_CHAIRS];//血战对局总数
    int m_nXLTotalGameCount[TOTAL_CHAIRS];//血流对局总数
    BOOL m_nNewPlayer[TOTAL_CHAIRS];//玩家类型
    int  m_nWinOrder[TOTAL_CHAIRS];//胡牌顺序，0代表没胡牌
    int m_nCoutInitialDeposits[TOTAL_CHAIRS];// 对局时初始银子
    int m_nHuTimes[TOTAL_CHAIRS];//胡牌次数
    BOOL m_bIsMakeCard[TOTAL_CHAIRS]; // 是否做牌
    SAFE_DEPOSIT_EX m_SafeDeposits[TOTAL_CHAIRS];//保险箱银子

    bool    m_bExchangeCards[TOTAL_CHAIRS];
    int     m_nExchangeCards[TOTAL_CHAIRS][EXCHANGE3CARDS_COUNT];
    ABORTPLAYER_INFO    m_stAbortPlayerInfo[TOTAL_CHAIRS];
    ABORTPLAYER_INFO    m_stGameStartPlayerInfo[TOTAL_CHAIRS];   // 记录游戏开始时的玩家信息,结算时用,川麻支持提前离桌
    PRESAVE_INFO    m_stPreSaveInfo[TOTAL_CHAIRS];
    int     m_bIsXueLiuRoom;
    std::vector<int> m_vecPnGnCards;
    std::vector<HU_ITEM_INFO> m_vecHuItems[TOTAL_CHAIRS];
    int     m_HuMJID[TOTAL_CHAIRS];
    PREGANG_OK m_stPreGangOK;
    // pre result
    BOOL m_bNeedUpdate;                      //是否需要更新huitem的输赢银两
    HU_MULTI_INFO m_stHuMultiInfo;            //记录一炮多响胡的玩家
    int m_HuPoint[TOTAL_CHAIRS];
    // offline
    BOOL m_bLastGang;                        //杠上炮开关

    int m_GangPoint[TOTAL_CHAIRS];
    // calculator
    CHECK_INFO m_stCheckInfo[TOTAL_CHAIRS];

    virtual void FillupStartData(void* pData, int nLen) override;
    virtual void FillupEnterGameInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual void FillupEndSaveGameResults(void* pData, int nLen, GAME_RESULT_EX GameResults[]) override;
    virtual int  FillupGameWin(void* pData, int nLen, int chairno) override;
    virtual int  GetGameWinSize() override;

    virtual int  CompensateDeposits(int nOldDeposits[], int nDepositDiffs[])
    override; //一输一赢，一输多赢，多输一赢，两输两赢(同一人同倍数)，适用杠，胡，查花猪，查大叫
    virtual int  CompensateDeposits2(int nOldDeposits[], int nDepositDiffs[], int nCheckType);
    virtual int  CompensateDepositsEx(int nOldDeposits[], int nDepositDiffs[]);
    virtual int  CalcBaseDeposit(int nDeposits[], int tableno) override;
    virtual int  GetBaseDeposit(int deposit_mult = 1) override;

    int     GetRandomValue();
    void    CalcPrompt3Cards(int chairno, int nCardIDs[], int nCardsLen);
    BOOL    OnAutoExchangeCards(LPEXCHANGE3CARDS pExchange3Cards);
    BOOL    OnExchangeCards(LPEXCHANGE3CARDS pExchange3Cards);
    BOOL    ExchangeCards(LPEXCHANGE3CARDS pExchange3Cards);
    BOOL    CheckExchange(LPEXCHANGE3CARDS pExchange3Cards);
    BOOL    UpdateHandCards(int nDir);
    int     GetRandomDirection();
    int     GetExchangeChairNO(int nChairNo, int nDir);
    int     GetExchangeDirection();
    int     GetExchangeCardsScore(int nDir);

    virtual DWORD SetStatusOnStart() override;
    virtual void StartDeal() override;

    void    resetTask();
    void    resetNewbieTask();
    int     GetPlayingNeedDeposit();

    BOOL    IsAllPlayerGiveUp();
    BOOL    IsPlayerFitGiveUp(int chairno);
    BOOL    OnPlayeRecharge(int chairno);
    BOOL    OnPlayerGiveUp(int chairno);
    BOOL    OnPlayerNotGiveUp(int chairno);
    DWORD   SetStatusOnGiveUp();
    DWORD   RemoveStatusOnGiveUp();

    // 血战玩家离开，存储该玩家的abort和enter结构体，断线重连使用
    void saveAbortPlayerInfo(SOLO_PLAYER soloPlayer);
    // 开局缓存玩家信息 供13.8视听觉优化  结算界面使用
    void saveGameStartPlayerInfo(SOLO_PLAYER soloPlayer);
    void FillupGameStartPlayerInfo(void* pData, int offsetLen);
    int getTotalAbortPlayerCount();
    BOOL IsXueLiuRoom();
    virtual void ConstructGameData()override;//创建游戏数据，在游戏开始前构建
    int     GetHuItemCount(int chairno);
    int     GetHuItemIDs(int chairno, int nCardID[]);
    int     GetTotalItemCount(int chairno);
    int     GetNoSendItemCount(int chairno);
    void    FinishHu(int cardchair, int chairno, int cardid);
    void    FillupHuItem(void* pData, int nLen, int chairno, int count);
    void    FillupAllHuItems(void* pData, int offsetLen, int chairno, int count);
    void    FillupAllPCHuItems(void* pData, int offsetLen, int count[]);
    void    FillupPlayerHu(void* pData, int nLen, int chairno); //先胡牌游戏未结算游戏信息填充
    void    ResetPlayerGiveUpInfo();
    // auto play
    int     GetAutoThrowCardID(int chairno);
    // ding que
    virtual void  OnAuctionBanker();
    BOOL    OnAuctionDingQue(LPAUCTION_DINGQUE pAuctionDingQue);
    BOOL    CalcHasNoDingQue(int chairno);
    BOOL    CalcIsDingQue(int chairno, int nCardID);
    // pre result
    BOOL ConstructMyPreSaveResult(int roomid, int gameid, LPREFRESH_RESULT_EX lpRefreshResult, GAME_RESULT_EX GameResults[], CPlayerLevelMap& mapPlayerLevel, int chairno,
        int flag); //用于中途结算，类似ConstructGameResults
    void UpdateHuItemDeposit(int chairno, int depositDiff[], int huCount);
    void UpdateGangItemDeposit(int chairno, int depositDiff[]);
    void setInitDeposit(int chairno, int deposit);
    BOOL IsUseCustomFeeMode() const { return m_feeRatioToBaseDeposit > 0; }
    void resetDepositWinLimit();
    void CalcCustomFees(int fees[]);
    BOOL PresaveResultCallTransferDeposit(GAME_RESULT_EX GameResults[], int CallTransferDepositResults[]);           //计算呼叫转移玩家分钱
    BOOL GameWinCallTransferDeposit(int nOldDeposits[], int nHuDepositDiffs[], int nDepositDiffs[], BOOL bPreSave = FALSE);
    void updateDepositAfterTransfer(int CallTransferDepositResults[]);
    int GetTotalPengCount(int chairno);
    int GetTotalGangCount(int chairno);
    // offline
    virtual BOOL ShouldHuCardWait(LPHU_CARD pHuCard);
    BOOL ValidateMultiHu(LPHU_CARD pHuCard);
    void ResetMultiHuInfo();
    BOOL OverTimeMultiHu(int cardchair);
    void OnHuAfterWait(LPHU_CARD pHuCard, int nCount);
    void ReSetThrowStatus(int first, int last);
    void CalcHuPoints(int chairno, int cardchair, int cardid);
    BOOL IsHuReady(int chairno);
    void AddNewHuItem(int chairno, int cardchair, int cardid, int losenum);

    virtual int  GetNextChair(int chairno)override;
    virtual int  GetPrevChair(int chairno)override;
    // ting
    int CalcTing(int chairno, HU_DETAILS& hu_detials_out);
    int CalcTing2(int chairno, HU_DETAILS& hu_detials_out, int nMaxBei);
    int CalcTingEx(int chairno, HU_DETAILS& hu_detials, vector<int>* v = NULL, DWORD dwExtraFlag = 0);
    // normal flow
    virtual int ValidateCatch(int chairno)override;
    BOOL IsHuaZhu(int chairno);
    virtual DWORD Hu_Tian(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags)override;
    int CalcGangUnitNum(HU_DETAILS& hu_details);//统计手上牌里四个一样的数量
    virtual DWORD HU_258JIANG(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    void GetAllHuUnite(int chairno, HU_DETAILS& huDetails, DWORD type = MJ_GANG | MJ_PENG | MJ_CHI); //取得所有的牌组合，仅在平胡下成立
    void GetAllCardHad(int chairno, int cards[], DWORD type = MJ_GANG | MJ_PENG | MJ_CHI); //取得属于自己的所有的牌
    virtual DWORD HU_19(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_GPao(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD HU_ShouBaYi(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD HU_Gen(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    int CalcGangByPgl(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);//计算杠牌的获取
    virtual BOOL  ValidatePeng(LPPENG_CARD pPengCard)override;
    virtual BOOL  ValidateMnGang(LPGANG_CARD pGangCard)override;
    virtual BOOL  ValidatePnGang(LPGANG_CARD pGangCard)override;
    virtual BOOL  ValidateAnGang(LPGANG_CARD pGangCard)override;
    BOOL ValidateGangAfterHu(int chairno, int nCardID);

    // calculate points
    virtual DWORD CalcWinOnGiveUp(int chairno, BOOL bTimeOut = FALSE)override;
    virtual DWORD CalcWinOnStandOff(int chairno)override;
    virtual DWORD CalcWinOnHu(int chairno)override;

    virtual int GetGangCard(int chairno, BOOL& bBuHua)override;
    virtual int GetGangCardEx(int chairno);
    virtual int CalcNextBanker(void* pData, int nLen)override;
    void AddNewGangItem(LPGANG_CARD pGangCard, int flag);

    // make card
    virtual void DealCards()override;
    void    ReadMakeCardConfig();
    void    MakeCardForDeal();
    void    MakeCardForCatch(int chairno, int catchno);
    void    MakeCardByPlayerType(int chairno, PLAYER_TYPE enPlayerType);
    void    MakeCardByPlayerTypeEx(int chairno, PLAYER_TYPE enPlayerType, int nCatchNO);
    void    MakeCardByPlayerTypeForDeal(int chairno, PLAYER_TYPE enPlayerType);
    void    MakeCardByShape(int chairno, int nShapeScore, int nShapeIndex, int nMaxScore, int nMinShapeCount, int nMinShapeIndex);
    void    MakeCardByShapeEx(int chairno, int nShapeIndex, int nCatchNO);
    void    MakeCardByType(int chairno, int nTypeScore, int nMaxScore, int nKeziCount, int nKeziLayIn[], int nDuiziCount, int nDuiziLayIn[], int nLayIn[]);
    void    MakeCardByTypeEx(int chairno, int nCatchNO, int nKeziCount, int nKeziLayIn[], int nDuiziCount, int nDuiziLayIn[], int nLayIn[]);
    void    ExchangeHandAndWallCard(int chairno, int changeno, int tochangeno);
    void    ExchangeCatchAndWallCard(int chairno, int changeno, int tochangeno);
    BOOL    MakeCardAfterTing(int chairno);
    int     GetHandTypeScore(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[]);
    int     GetHandTypeScoreEx(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[]);
    int     GetHandTypeScoreEx2(int chairno); //无出参
    int     GetHandTypeScoreEx3(int chairno, int& nKeziCount, int nKeziLayIn[], int& nDuiziCount, int nDuiziLayIn[], int nLayIn[], int shape);
    int     GetHandShapeScore(int chairno, int& nMaxShapeIndex, int& nMinShapeIndex, int& nMinShapeCount);
    int     GetHandShapeScoreEx(int chairno, int& nMaxShapeIndex);
    int     GetWallCardnoByShape(int nShape);
    int     GetWallCardnoByLayIndex(int nLayIndex);
    int     GetHandCardnoByLayIndex(int chairno, int nLayIndex);
    virtual int CalcBreakDeposit(int breakchair, int breakdouble, int& cut)override;
    virtual BOOL ValidateHu(LPHU_CARD pHuCard)override;
    void    ReSetThrowStutas(int first, int last);
    virtual int OnHu(LPHU_CARD pHuCard)override;
    virtual int OnHuFang(int chairno, int cardchair, int cardid)override;
    virtual int OnHuZimo(int chairno, int cardchair, int cardid)override;
    virtual BOOL ReplaceAutoThrow(LPTHROW_CARDS pThrowCards)override;
    virtual int CancelSituationOfGang()override;
    BOOL calcDrawBack(int nOldDeposits[], int nDepositDiffs[]);              //退税
    void AddNewCheckItem();
    void FillUpGameWinCheckInfos(void* pData, int nLen, int chairNo);
    void FillupGameWinStartGamePlayerInfo(void* pData, int nLen);
    virtual int ShouldReConsPengWait(LPPENG_CARD pPengCard)override;
    virtual int CatchCard(int chairno, BOOL& bBuHua)override;
    virtual int OnPnGang(LPGANG_CARD pGangCard)override;

    virtual int ValidateThrow(int chairno, int nCardsOut[], int nOutCount, DWORD dwCardsType, int nValidIDs[])override;
    BOOL m_bLastHuChairs[TOTAL_CHAIRS];

    //机器人 begin
    BOOL m_bIsRobot[TOTAL_CHAIRS];


    BOOL IsRoboter(int chairno) override;

    int        m_nAIOperateID;
    int        m_nAIOperateCardID;
    int        m_nAIOperateChairNO;
    int        m_nAIOperateCardChairNO;
    int        m_nAIOperateBaseCards[4];
    int        m_nAIOperateTime;
    void       ResetAIOpe();
    void       GetAIBaseCardsID();
    BOOL       IsGameTimerValid(LPGAME_TIMER pGameTimer);
    void writeLog();
    BOOL IsOperateTimeOver()override;
    virtual BOOL GetAIPengRand() { return GetPrivateProfileInt(_T("RobotOperateRand"), _T("peng"), 0, GetMyINIMakeCardName()); }
    virtual BOOL GetAIGangRand() { return GetPrivateProfileInt(_T("RobotOperateRand"), _T("gang"), 0, GetMyINIMakeCardName()); }
    virtual BOOL GetAIHuRand() { return GetPrivateProfileInt(_T("RobotOperateRand"), _T("hu"), 0, GetMyINIMakeCardName()); }

    virtual BOOL GetRobotWinRate() { return GetPrivateProfileInt(_T("RobotRate"), _T("win"), 50, GetMyINIMakeCardName()); }
    virtual BOOL GetRobotLossRate() { return GetPrivateProfileInt(_T("RobotRate"), _T("loss"), 40, GetMyINIMakeCardName()); }
    virtual BOOL GetRobotStandoffRate() { return GetPrivateProfileInt(_T("RobotRate"), _T("standoff"), 10, GetMyINIMakeCardName()); }

    virtual BOOL GetRobotOperateTimeRate() { return GetPrivateProfileInt(_T("RobotRate"), _T("operatetime"), 4, GetMyINIMakeCardName()); }
    void CreateUniqueID();
    int GetUniqueID();

    void RecordRobotOnStart();
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

    int m_nUniqueID;  // 每局游戏的标志ID;

    //做牌干预
    MAKECARD_PROB m_stMakeCardProb;

    BOOL m_bvalidRobotBout; //该局若只存在一个机器人,则被视为有效机器人局
    vector<int> m_vRobotBoutPlayerCardIDs;

    BOOL MakeCardIntervene() { return GetPrivateProfileInt(_T("MakeCardIntervene"), _T("enable"), 0, GetMyINIMakeCardName()); } //做牌干预总开关
    void ReadMakeCardProb();
    CString GetMyINIMakeCardName();
    BOOL IsRobotBout(); //判断该桌存不存在机器人
    int GetRobotNumer(); //获得该桌机器人数量
    int GetRobotBoutPlayerNo(); //获得机器人对局中的玩家的chairno

    int GetShuffleRandomValue(int nMaxNum);  // 获取一个真随机的值
    void MakeCardForCatchIntervene(int chairno, int catchno);
    void MakeCardForRobotCatch(int chairno, int catchno, INTERVENE_TYPE enInterveneType, PROB prob);
    int MakeCardForThrowIntervene(int chairno);
    int MakeCardForRobotThrow(int chairno, INTERVENE_TYPE enInterveneType, PROB prob);
    PROB GetRemainCoutInterveneProb(INTERVENE_TYPE enInterveneType, vector<PROB>& v); // 是否满足 干预条件
    void CalcTingByRobotBoutPlayer(DWORD dwExtraFlag = 0);
};

inline int getRandomBetweenEx(int nMin, int nMax)
{
    if (nMax == nMin)
    {
        return nMax;
    }

    return  nMin + (rand() % (nMax - nMin + 1));
}

inline int Svr_RetrieveFields(TCHAR* buf, TCHAR** fields, int maxfields, TCHAR** buf2)
{
    if (buf == NULL)
    {
        return 0;
    }

    TCHAR* p;
    p = buf;
    int count = 0;

    try
    {
        while (1)
        {
            fields[count++] = p;
            while (*p != '|' && *p != '\0')
            {
                p++;
            }
            if (*p == '\0' || count >= maxfields)
            {
                break;
            }
            *p = '\0';
            p++;
        }
    }
    catch (...)
    {
        buf2 = NULL;
        return 0;
    }

    if (*p == '\0')
    {
        *buf2 = NULL;
    }
    else
    {
        *buf2 = p + 1;
    }
    *p = '\0';

    return count;
}