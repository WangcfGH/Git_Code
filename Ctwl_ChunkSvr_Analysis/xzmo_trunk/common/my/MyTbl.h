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
    int m_nFeedChair[TOTAL_CHAIRS][4];  //ÿ����������4�����
    int nAfterChiPengStatus;
    int m_nLeastBout;
    int m_nMaxUserBout;
    int m_nLastPeng3dui4dui;
    int m_nPeng3duiChairNO[TOTAL_CHAIRS];//��ȥ����  Ϊ��������а���
    int m_nPeng4duiChairNO[TOTAL_CHAIRS];
    int m_nPengNum[TOTAL_CHAIRS];
    DWORD m_dwGangAfterCatch;   // Ϊ�˽���������еĸ��Ͽ�������ӵı���
    //����
    int m_nMultipleScore;

    virtual void ResetMembers(BOOL bResetAll = TRUE) override;
    virtual void FillupGameTableInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual void FillupGameStart(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual int GetGameStartSize() override;
    virtual int  GetGameStartSize4Looker() override;
    virtual void FillupGameStart4Looker(void* pData, int nLen, CPlayer* pLooker) override;
    virtual int  GetGameTableLookerInfoSize() override;//���Թ�(�Һ�̨����)
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
    virtual int   CalcFirstCatchAfter(void* pData, int nLen) override;//������һ��˭��ץ�ƣ�����ׯ�ң���CCardTable��prepairNextBout����
    virtual int   CalcCatchFrom() override;
    virtual DWORD CalcPGCH(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD flags) override;
    virtual DWORD CalcHu(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual DWORD CalcHu_Various(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual DWORD CalcHu_Most(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags, BOOL bNorMalArithmetic = FALSE) override;
    virtual void  CopyHuDetailsSmall(int chairno, HU_DETAILS_EX& huDetailsSmall, HU_DETAILS& huDetails) /*override*/;
    virtual BOOL  CalcWinPoints(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual int   GetTotalGain(HU_DETAILS& huDetails, int HuMax) /*override*/;//HuMax��ʾ����
    virtual int   CalcUnderTake(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual int   CalcPengGains(LPPENG_CARD pPengCard) override;
    virtual int   CalcMnGangGains(LPGANG_CARD pGangCard) override;
    virtual int   CalcAnGangGains(LPGANG_CARD pGangCard) override;
    virtual int   CalcPnGangGains(LPGANG_CARD pGangCard) override;
    virtual DWORD CalcHu_TingCard(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags) override;//���ƹ������
    virtual int   GetNextBoutBanker() override;

    virtual DWORD Hu_MQng(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags) override;//����
    virtual int CalcGangEtcPoints(void* pData, int nLen, int chairno, int nWinPoints[]) override;
    virtual DWORD MJ_CanHu_13BK_EX(int nCardsLay[], int nCardID, DWORD gameflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno);
    virtual DWORD MJ_CanHu_PerFect(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, int chairno,
        BOOL bNorMalArithmetic = FALSE);

    int   OnAfterPeng(int nChairNO);

    int   MyGetSortValueByMJID(int nCardID) ;//�������к�̨����,��һ������λ�øı���
    int   CalcTotalGangGains(int nGanggains[]);
    BOOL  isUseServerHuCardID() { return GetPrivateProfileInt(_T("UseServerHuCardID"), _T("enable"), 0, GetINIFileName()); }

    // xo add
    MAKECARD_CONFIG m_stMakeCardConfig;
    MAKECARD_INFO   m_stMakeCardInfo[TOTAL_CHAIRS];
    int     m_nTakeFeeTime;
    int     m_nDingQueWait; //��ȱ�ȴ�ʱ��
    int     m_nDingQueCardType[TOTAL_CHAIRS]; //��ȱ���� add 20130916
    DWORD   m_dwDingQueStartTime;
    int     m_nShowTask;
    int     m_nRechargeTime;
    int     m_nGiveUpTime;
    int     m_nGiveUpChair[TOTAL_CHAIRS];
    BOOL    m_bShowGiveUp[TOTAL_CHAIRS]; //�ͻ����Ƿ���ʾ������
    BOOL    m_bPlayerRecharge;
    DWORD   m_dwGiveUpStartTime;
    BOOL    m_bNewRuleOpen;                         //����ת�ơ��������º���˰�¹����Ƿ���
    BOOL    m_bCallTransfer;                        //�Ƿ���Ҫ����ת��
    int     m_nEndGameFlag;                         //����ʱ��Ҫ���ŵĶ���
    BOOL    m_nextAskNewTable;
    GAMEEND_CHECK_INFO m_stEndGameCheckInfo;
    BOOL    m_bOpenSaveResultLog;                   //������Ϸ�����־����
    int     m_nDepositWinLimit[TOTAL_CHAIRS];

    int     m_HuMinLimit;                       //��С����
    int     m_HuMaxLimit;                       //������
    int     m_nPengWait;
    int     m_nLatestThrowNO;                   //���һ�γ������
    int     m_feeRatioToBaseDeposit;            //��Ի������������Ӧ�Ĳ�ˮ�ѣ����ոñ����㣬ǧ�ֱ�

    int     m_nRoomFees[TOTAL_CHAIRS];
    int     m_nInitDeposit[TOTAL_CHAIRS];
    int     m_nLatestedGetMJIndex[TOTAL_CHAIRS];
    DWORD   m_HuReady[TOTAL_CHAIRS];            //�Ƿ��Ѻ���

    int m_nMultiple[TOTAL_CHAIRS];//���Ʒ���
    int m_nTimeCost[TOTAL_CHAIRS];//�Ծֺ�ʱ
    int m_nTotalGameCount[TOTAL_CHAIRS];//����ÿ����ҵĶԾ��ܾ���
    int m_nXZTotalGameCount[TOTAL_CHAIRS];//Ѫս�Ծ�����
    int m_nXLTotalGameCount[TOTAL_CHAIRS];//Ѫ���Ծ�����
    BOOL m_nNewPlayer[TOTAL_CHAIRS];//�������
    int  m_nWinOrder[TOTAL_CHAIRS];//����˳��0����û����
    int m_nCoutInitialDeposits[TOTAL_CHAIRS];// �Ծ�ʱ��ʼ����
    int m_nHuTimes[TOTAL_CHAIRS];//���ƴ���
    BOOL m_bIsMakeCard[TOTAL_CHAIRS]; // �Ƿ�����
    SAFE_DEPOSIT_EX m_SafeDeposits[TOTAL_CHAIRS];//����������

    bool    m_bExchangeCards[TOTAL_CHAIRS];
    int     m_nExchangeCards[TOTAL_CHAIRS][EXCHANGE3CARDS_COUNT];
    ABORTPLAYER_INFO    m_stAbortPlayerInfo[TOTAL_CHAIRS];
    ABORTPLAYER_INFO    m_stGameStartPlayerInfo[TOTAL_CHAIRS];   // ��¼��Ϸ��ʼʱ�������Ϣ,����ʱ��,����֧����ǰ����
    PRESAVE_INFO    m_stPreSaveInfo[TOTAL_CHAIRS];
    int     m_bIsXueLiuRoom;
    std::vector<int> m_vecPnGnCards;
    std::vector<HU_ITEM_INFO> m_vecHuItems[TOTAL_CHAIRS];
    int     m_HuMJID[TOTAL_CHAIRS];
    PREGANG_OK m_stPreGangOK;
    // pre result
    BOOL m_bNeedUpdate;                      //�Ƿ���Ҫ����huitem����Ӯ����
    HU_MULTI_INFO m_stHuMultiInfo;            //��¼һ�ڶ���������
    int m_HuPoint[TOTAL_CHAIRS];
    // offline
    BOOL m_bLastGang;                        //�����ڿ���

    int m_GangPoint[TOTAL_CHAIRS];
    // calculator
    CHECK_INFO m_stCheckInfo[TOTAL_CHAIRS];

    virtual void FillupStartData(void* pData, int nLen) override;
    virtual void FillupEnterGameInfo(void* pData, int nLen, int chairno, BOOL lookon = FALSE) override;
    virtual void FillupEndSaveGameResults(void* pData, int nLen, GAME_RESULT_EX GameResults[]) override;
    virtual int  FillupGameWin(void* pData, int nLen, int chairno) override;
    virtual int  GetGameWinSize() override;

    virtual int  CompensateDeposits(int nOldDeposits[], int nDepositDiffs[])
    override; //һ��һӮ��һ���Ӯ������һӮ��������Ӯ(ͬһ��ͬ����)�����øܣ������黨������
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

    // Ѫս����뿪���洢����ҵ�abort��enter�ṹ�壬��������ʹ��
    void saveAbortPlayerInfo(SOLO_PLAYER soloPlayer);
    // ���ֻ��������Ϣ ��13.8�������Ż�  �������ʹ��
    void saveGameStartPlayerInfo(SOLO_PLAYER soloPlayer);
    void FillupGameStartPlayerInfo(void* pData, int offsetLen);
    int getTotalAbortPlayerCount();
    BOOL IsXueLiuRoom();
    virtual void ConstructGameData()override;//������Ϸ���ݣ�����Ϸ��ʼǰ����
    int     GetHuItemCount(int chairno);
    int     GetHuItemIDs(int chairno, int nCardID[]);
    int     GetTotalItemCount(int chairno);
    int     GetNoSendItemCount(int chairno);
    void    FinishHu(int cardchair, int chairno, int cardid);
    void    FillupHuItem(void* pData, int nLen, int chairno, int count);
    void    FillupAllHuItems(void* pData, int offsetLen, int chairno, int count);
    void    FillupAllPCHuItems(void* pData, int offsetLen, int count[]);
    void    FillupPlayerHu(void* pData, int nLen, int chairno); //�Ⱥ�����Ϸδ������Ϸ��Ϣ���
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
        int flag); //������;���㣬����ConstructGameResults
    void UpdateHuItemDeposit(int chairno, int depositDiff[], int huCount);
    void UpdateGangItemDeposit(int chairno, int depositDiff[]);
    void setInitDeposit(int chairno, int deposit);
    BOOL IsUseCustomFeeMode() const { return m_feeRatioToBaseDeposit > 0; }
    void resetDepositWinLimit();
    void CalcCustomFees(int fees[]);
    BOOL PresaveResultCallTransferDeposit(GAME_RESULT_EX GameResults[], int CallTransferDepositResults[]);           //�������ת����ҷ�Ǯ
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
    int CalcGangUnitNum(HU_DETAILS& hu_details);//ͳ�����������ĸ�һ��������
    virtual DWORD HU_258JIANG(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    void GetAllHuUnite(int chairno, HU_DETAILS& huDetails, DWORD type = MJ_GANG | MJ_PENG | MJ_CHI); //ȡ�����е�����ϣ�����ƽ���³���
    void GetAllCardHad(int chairno, int cards[], DWORD type = MJ_GANG | MJ_PENG | MJ_CHI); //ȡ�������Լ������е���
    virtual DWORD HU_19(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD Hu_GPao(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD HU_ShouBaYi(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD HU_Gen(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);
    int CalcGangByPgl(int chairno, int nCardID, HU_DETAILS& huDetails, DWORD dwFlags);//������ƵĻ�ȡ
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
    int     GetHandTypeScoreEx2(int chairno); //�޳���
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
    BOOL calcDrawBack(int nOldDeposits[], int nDepositDiffs[]);              //��˰
    void AddNewCheckItem();
    void FillUpGameWinCheckInfos(void* pData, int nLen, int chairNo);
    void FillupGameWinStartGamePlayerInfo(void* pData, int nLen);
    virtual int ShouldReConsPengWait(LPPENG_CARD pPengCard)override;
    virtual int CatchCard(int chairno, BOOL& bBuHua)override;
    virtual int OnPnGang(LPGANG_CARD pGangCard)override;

    virtual int ValidateThrow(int chairno, int nCardsOut[], int nOutCount, DWORD dwCardsType, int nValidIDs[])override;
    BOOL m_bLastHuChairs[TOTAL_CHAIRS];

    //������ begin
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
        int min_player_count = 0/*�ɱ��������Ҫ�������*/,
        int fee_tenthousandth = 0/*�²�ˮ����ȡ��ֱ�*/, int fee_minimum = 0/*�²�ˮ��������*/)override; // ��Ϸ���¿�ʼ�����δ�뿪

    int m_nUniqueID;  // ÿ����Ϸ�ı�־ID;

    //���Ƹ�Ԥ
    MAKECARD_PROB m_stMakeCardProb;

    BOOL m_bvalidRobotBout; //�þ���ֻ����һ��������,����Ϊ��Ч�����˾�
    vector<int> m_vRobotBoutPlayerCardIDs;

    BOOL MakeCardIntervene() { return GetPrivateProfileInt(_T("MakeCardIntervene"), _T("enable"), 0, GetMyINIMakeCardName()); } //���Ƹ�Ԥ�ܿ���
    void ReadMakeCardProb();
    CString GetMyINIMakeCardName();
    BOOL IsRobotBout(); //�жϸ����治���ڻ�����
    int GetRobotNumer(); //��ø�������������
    int GetRobotBoutPlayerNo(); //��û����˶Ծ��е���ҵ�chairno

    int GetShuffleRandomValue(int nMaxNum);  // ��ȡһ���������ֵ
    void MakeCardForCatchIntervene(int chairno, int catchno);
    void MakeCardForRobotCatch(int chairno, int catchno, INTERVENE_TYPE enInterveneType, PROB prob);
    int MakeCardForThrowIntervene(int chairno);
    int MakeCardForRobotThrow(int chairno, INTERVENE_TYPE enInterveneType, PROB prob);
    PROB GetRemainCoutInterveneProb(INTERVENE_TYPE enInterveneType, vector<PROB>& v); // �Ƿ����� ��Ԥ����
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