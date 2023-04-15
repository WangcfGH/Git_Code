#pragma once
#define RM_TABLEDEPOSIT 0x00000200

struct MYGameServerEvent
{
    // 提前结算 <LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno, GAME_RESULT_EX *pGameResults, int nResultCount>
    EventNoMutex<LPCONTEXT_HEAD, CMyGameTable*, int, int, int, GAME_RESULT_EX *, int> evPreResult;

    //OnGameWin 通知(LPCONTEXT_HEAD lpContext, CRoom* pRoom, CTable* pTable, int chairno, BOOL bout_invalid, int roomid);
    EventNoMutex<LPCONTEXT_HEAD, CRoom*, CTable*, int, BOOL, int > evOnGameWin;

    // 任务杠一次 <LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, DWORD type>
    EventNoMutex<LPCONTEXT_HEAD , CMyGameTable* , int , int , DWORD> evTaskGang;

    // 任务碰一次 <LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nPengCardID>
    EventNoMutex<LPCONTEXT_HEAD , CMyGameTable* , int , int , int > evTaskPeng;

    // 任务胡一次 <LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nHuType, int nHuFan>
    EventNoMutex<LPCONTEXT_HEAD , CMyGameTable* , int , int , int , int> evTaskHu;

    // 获得银两 <LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nChairNO>
    EventNoMutex<LPCONTEXT_HEAD , CMyGameTable* , int, int > evWinDeposit;

    // 微信任务胡一次 <LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO>
    EventNoMutex<LPCONTEXT_HEAD , CTable* , int> evWxTaskHu;
};

class CMyGameServer : public CMJServer, public MYGameServerEvent
{
public:
    CMyGameServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer, const int nListenPort, const int nGameID,
        DWORD flagEncrypt, DWORD flagCompress);

    virtual BOOL Initialize() override;
    virtual void Shutdown() override;
    virtual CTable* OnNewTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1) override;

    virtual BOOL OnRequest(void* lpParam1, void* lpParam2) override;
    virtual BOOL OnThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;

    //调试打日志重载用函数，寻找胡胡不了，点碰碰不了的问题
    virtual BOOL OnOperationLogEnable()
    { return (GetPrivateProfileInt(_T("OnOperationLog"), _T("Log_Enable"), TRUE, GetINIFilePath()) != 0); }; // 操作记录开关
    virtual void UWLCurrentChairCards(CMJTable* pTable, int nChairNO, int nCardID, int nRoomID, int nTableNO, int nUserID) override;
    // xo add

    virtual BOOL OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnStartGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnStartGameEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnLeaveGameEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);//等待回应
    virtual BOOL OnAskRandomTable(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnTakeSafeDepositOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqToClient, LPREQUEST lpReqFromServer) override;
    virtual BOOL OnApplyBaseWelfare(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual void OpeAfterCheckResult(CTable* pTable, void* pOpeData, int nDataLen, int nRoomID, BOOL bClearTable) override;
    virtual void CheckInGameResult(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData, int nLen, int roomid) override;

    virtual BOOL OnGameWin(LPCONTEXT_HEAD lpContext, CRoom* pRoom, CTable* pTable, int chairno, BOOL bout_invalid, int roomid) override;
    virtual BOOL OnPreGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL OnEnterGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;

    virtual BOOL ConstructEnterGameDXXW(int roomid, CTable* pTable, int chairno, int userid, BOOL lookon, LPREQUEST lpResponse) override;
    virtual int  StartSoloTable(START_SOLOTABLE* pStartSoloTable) override;
    virtual BOOL OnGameStarted(CTable* pTable, DWORD dwFlags = 0) override;
    virtual void OnServerAutoPlay(CRoom* pRoom, CTable* pTable, int chairno, bool bOnline, BOOL bClockZero);
    virtual void OnServerAutoPlay(CRoom* pRoom, CTable* pTable, int chairno, bool bOnline) override;
    virtual void OnSeverAutoPlayFangChongHu(CRoom* pRoom, CTable* pTable, int chairno, int nFangChongChair, int nFangChongCardID);
    virtual void OnSeverAutoPlayHuZiMo(CRoom* pRoom, CTable* pTable, int chairno, int nHuCardID);
    virtual void OnSeverAutoPlayHuQiangGang(CRoom* pRoom, CTable* pTable, int chairno, int ngangChair, int nHuCardID, DWORD dwGangFlags);
    void SetTableMakeCardInfo(CMyGameTable* pTable);
    virtual BOOL OnMyTakeSafeDeposit(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnExchangeCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL NotifySystemMSG(CMyGameTable* pTable, LPSYSTEMMSG pMsg, int chairno);
    virtual BOOL OnPlayerRecharge(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPlayerRechargeOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);

    // for server's notify
    virtual void NotifyServiceFee(CTable* pTable) override;//发送服务费通知

    //template fun
    virtual BOOL CanChangeTableInGame(int roomid, CPlayer* pPlayer) override;//游戏进行中能否换桌
    virtual BOOL MoveUserToChair(int nUserID, int tableno, int chairno, SOLO_PLAYER* pSoloPlayer) override;
    virtual BOOL NeedChangeBaseDeposit(CTable* pTable, CPlayer* pPlayer) override { return FALSE; };
    virtual BOOL OnCurrencyExchange(LPREQUEST lpRequest) override;
    virtual BOOL OnPayResultToGame(LPREQUEST lpRequest) override; //充值到游戏
    virtual BOOL OnGameUnableContinue(CTable* pTable, LPCTSTR szCause) override;

    BOOL OnPlayerGoSeniorRoom(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    BOOL OnGetWelfarePersent(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    BOOL OnGetWelfarePresentOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);

    void CheckGiveUp(CMyGameTable* pTable, int chairno = INVALID_OBJECT_ID);
    void PostRecordUserNetworkType(int nRoomID, int nUserID, int nNetworkType);//与RoomSvr通讯相关
    // 断线续玩，已离开玩家信息下发
    void SendAbortPlayerInfo(CMyGameTable* pTable, int nRoomID, int nTableNO, SOCKET hSocket, LONG lTokenID) ;

    // ding que
    virtual BOOL OnAuctionBanker(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override; //定缺中
    virtual BOOL OnGiveUpGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    // pre result
    void PreSaveResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno = INVALID_OBJECT_ID);
    void NotifyNextTurn(CTable* pTable, int chairno) ;
    void SetServerMakeCardInfo(CMyGameTable* pTable, int chairno);
    BOOL CheckandNotifyDepositWinLimit(CMyGameTable* pTable); /*触发以小博大*/

    virtual BOOL OnReconsPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;// 吃碰杠消息的重构
    virtual BOOL OnReconsMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;// 吃碰杠消息的重构
    virtual BOOL OnReconsAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;// 吃碰杠消息的重构
    virtual BOOL OnReconsPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;// 吃碰杠消息的重构
    virtual BOOL OnHuCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    void OnGetDepositOK(CTable* pTable, int chairno); //补银成功
    virtual void OnServerChiPengGangCard(CRoom* pRoom, CMJTable* pTable) override;

    virtual void OnCustomRoomWndMsg(IN CONST MSG* lpMsg) override;

    //-------------------机器人start----------------------------
    virtual CBaseRobot* OnNewRobotUnit(int nUserId) override;
    virtual void        OnRobotAIPlay(CRoom* pRoom, CTable* pTable, int chairno, BOOL bClockZero = FALSE);// {} // 机器人AI处理 CP自行重载
    void OnRobotStartExchangeOrFixmiss(CRoom* pRoom, CTable* pTable);
    void OnRobotGuoCard(CRoom* pRoom, CTable* pTable, int chairno);
    void CalcResultWinOrLoss(void* pData, int nLen, CTable* pTable) override;
    BOOL CreateRobotTimer(CRoom* pRoom, CTable* pTable, DWORD dwStatus, int nWait);
    BOOL RemoveRobotTimer(CTable* pTable);
    BOOL RobotOnGameTimer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    void OnRobotGiveUp(CRoom* pRoom, CTable* pTable, int chairno);
    void OnRobotXueLiuHu(CRoom* pRoom, CTable* pTable, int chairno);
    void OnGameTimer(LPGAME_TIMER pGameTimer, CMyGameTable* pTable);
    //-------------------机器人end----------------------------


    // soap
    virtual BOOL DealSoapMessage(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) override;
    BOOL DealGetWelfarePresent(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // 向后台进行请求保险箱银子数目
    virtual BOOL GetPlayerSafeBoxDeposit(CPlayer* pPlayer, CMyGameTable* pTable, int nChairNo);
    virtual BOOL OnLookSafeDepositOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqToClient, LPREQUEST lpReqFromServer) override;//服务器获取保险箱银子

};
