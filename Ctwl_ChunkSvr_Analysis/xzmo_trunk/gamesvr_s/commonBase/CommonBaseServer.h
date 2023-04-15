#pragma once

#include "tcycomponents/TcyMsgCenter.h"
#include "plana/plana.h"

struct CommonServerEvent
{
    TcyMsgCenter    m_msgCenter;

    EventNoMutex<BOOL&, TcyMsgCenter*>      evSvrStart;
    EventNoMutex<>                          evShutdown;
    EventNoMutex<CCommonBaseTable*>         evNewTable;

    EventNoMutex<LPCONTEXT_HEAD, LPREQUEST, BOOL, BOOL>                         evSendResponse;

    EventNoMutex<CCommonBaseTable*, void*>                                      evCPGameStarted;
    EventNoMutex<START_SOLOTABLE*, CCommonBaseTable*, void*>                    evCPStartSoloTable;
    // arg2:roomid
    EventNoMutex<LPCONTEXT_HEAD, int, CCommonBaseTable*, CPlayer*>              evOnCPPlayerEnterGame;
    // arg2:roomid
    EventNoMutex<LPCONTEXT_HEAD, int, CCommonBaseTable*, CPlayer*>              evOnCPEnterGameDXXW;
    // arg2:roomid
    EventNoMutex<LPCONTEXT_HEAD, int, CCommonBaseTable*, void*>                 evOnCPGameWin;
    // arg2:pData,arg3:nLen
    EventNoMutex<CCommonBaseTable*, void*, int>                                 evOnCPDealReplayGameWinData;
    // arg2:nUserID,arg3:to_close
    EventNoMutex<CCommonBaseTable*, int, BOOL>                                   evRemoveOneClients;
    // arg2:nRequest,arg3:pData,arg4:nLen
    EventNoMutex<CCommonBaseTable*, UINT, void*, int>                           evNotifyTableVisitors;
    // args:[CCommonBaseTable* pTable, LPCONTEXT_HEAD lpContext, LPREFRESH_RESULT_EX lpRefreshResult,
    // LPGAME_RESULT_EX lpGameResult, int nGameResultSize]
    EventNoMutex<CCommonBaseTable*, LPCONTEXT_HEAD, LPREFRESH_RESULT_EX, LPGAME_RESULT_EX, int> evTransmitGameResultEx;

    // YQW
    EventNoMutex<LPCONTEXT_HEAD, LPYQW_PLAYER_INFO, CCommonBaseTable*, CPlayer*>evYQWPlayerInfo;
    // arg2:roomid, arg3:dwAbortFlag
    EventNoMutex<CCommonBaseTable*, int, int>                                   evYQWCloseSoloTable;
    EventNoMutex<LPCONTEXT_HEAD, int, CCommonBaseTable*, void*>                 evYQWOnCPGameWin;
    // arg1:nUserID,arg2:nStatusCode
    EventNoMutex<int, int, LPEXCH_GOODS_DATA>                                   evOnCPExchGameGoods;
    EventNoMutex<CCommonBaseTable*, LPYQW_DEDUCT_HAPPYCOIN, LPYQW_HAPPYCOIN_CHANGE> evYQW_OnCPDeductHappyCoinResult;
    // arg2:chairno,arg3:flag
    EventNoMutex<CCommonBaseTable*, int, DWORD>                                 evYQW_TransmitUserLeaveE1;
};


class CCommonBaseServer : public CMainServer, public CommonServerEvent
{
public:
    CCommonBaseServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer, const int nListenPort, const int nGameID,
        DWORD flagEncrypt, DWORD flagCompress);

    virtual BOOL Initialize() override;
    virtual void Shutdown() override; // 模块类在这里释放掉，如果等待程序析构，但是UwlEndTrace和TCLOG_UNINT已经释放，会导致程序关闭的时候崩溃，详见_tmain

    virtual BOOL OnRequest(void* lpParam1, void* lpParam2) override;

    virtual CTable* OnNewTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1) override;

public:
    virtual BOOL SendUserResponse(LPCONTEXT_HEAD lpContext, LPREQUEST lpResponse, BOOL passive = FALSE, BOOL compressed = FALSE) override;
    virtual BOOL NotifyResponseSucceesd(LPCONTEXT_HEAD lpContext, void* pData = NULL, int nLen = 0);
    virtual BOOL NotifyResponseFaild(LPCONTEXT_HEAD lpContext, BOOL bPassive = FALSE);

public:
    virtual void OnCPPlayerEnterGame(LPCONTEXT_HEAD lpContext, int roomid, CTable* pTable, CPlayer* pPlayer) ;
    virtual void OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CTable* pTable, void* pData) override;
    virtual int  RemoveOneClients(CTable* pTable, int nUserID, BOOL to_close = FALSE) override;
    virtual BOOL YQW_OnPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual void YQW_OnPlayerEnterGame(LPCONTEXT_HEAD lpContext, LPYQW_PLAYER_INFO pPlayerInfo, CTable* pTable, CPlayer* pPlayer);
    virtual BOOL YQW_TransmitUserLeaveE1(CTable* pTable, int chairno, DWORD flag) override;

    virtual void OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CTable* pTable, CPlayer* pPlayer) override;
    virtual void YQW_CloseSoloTable(CTable* pTable, int roomid, DWORD dwAbortFlag) override;
    virtual void OnCPDealReplayGameWinData(CTable* pTable, void* pData, int nLen);
    virtual int  NotifyTableVisitors(CTable* pTable, UINT nRequest, void* pData, int nLen, LONG tokenExcept = 0, BOOL compressed = FALSE) override;
    virtual void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CTable* pTable, void* pData) override;
    virtual void OnCPOnGameStarted(CTable* pTable, void* pData) override;
    virtual void YQW_OnCPDeductHappyCoinResult(CTable* pTable, LPYQW_DEDUCT_HAPPYCOIN pDeductReq, LPYQW_HAPPYCOIN_CHANGE pDeductRet) override;
    virtual void YQW_OnPlayerEnterGame(LPCONTEXT_HEAD lpContext, CTable* pTable, CPlayer* pPlayer) final { return __super::YQW_OnPlayerEnterGame(lpContext, pTable, pPlayer); }
    virtual void OnCPExchGameGoods(int nUserID, int nStatusCode, LPEXCH_GOODS_DATA pData) override;   //库里在调 不能删
    virtual void YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CTable* pTable, void* pData) override;
    virtual BOOL TransmitGameResultEx(CTable* pTable, LPCONTEXT_HEAD lpContext, LPREFRESH_RESULT_EX lpRefreshResult,
        LPGAME_RESULT_EX lpGameResult, int nGameResultSize) override;

    // TODO:后续合入服务器
    virtual BOOL IsNeedWaitArrageTable(CTable* pTable, int nRoomID, int nUserID) override;
    virtual BOOL OnEnterGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual BOOL IsTrueChairAndTable(int nUserID, int nRoomID, int nTableNO, int nChairNO, SOCKET sock, LONG token);
    virtual BOOL OnSendLBSInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPromptPlayer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);

    virtual void OnServerAutoPlay(CRoom* pRoom, CTable* pTable, int chairno, bool bOnline) {};
    virtual BOOL SimulateGameMsgFromUser(int nRoomID, CPlayer* player, int nMsgID, int nDatalen, void* data, DWORD dwSpace = 0);

public:
    // 提升调用权限
    using CMainServer::GetWorkerContext;
    using CMainServer::OnStartGameEx;
    using CMainServer::m_nGameID;
    using CMainServer::OnEnterGame;
    using CMainServer::m_szIniFile;
    using CMainServer::OnGameWin;
    using CMainServer::OnTooManyAuto;
    using CMainServer::GetRoomManage;
    using CMainServer::GetRoomSvrWnd;
    using CMainServer::OnPlayerOffline;
};

