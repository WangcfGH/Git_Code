#pragma once
// TODO: gamesvr不能操作redis；未来需要将redis操作改造至chunksvr

// 简单改造一下，当一个例子

#include "tcycomponents/TcyMsgCenter.h"
#include "plana/plana.h"

class CGoodLuckDelegate : public plana::threadpools::PlanaStaff
{
public:
	// args3:timeout,如果调用结束值为0，则代表timeout了！
	ImportFunctional<REQUEST(LPCONTEXT_HEAD, LPREQUEST,int&)> imMsg2ChunkWait;
	// args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
	ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;
	// args:[roomid,tableno,bCreateIfNotExist=FALSE,nScoreMult=0]
	ImportFunctional < CGetTableResult(int,int, BOOL,int)> imGetTablePtr;
	// args:[table,nRequest,pData,nLen,tokenExcept=0,compressed=FALSE]
	ImportFunctional<int((CTable*, UINT, void*, int, LONG, BOOL))>  imNotifyTablePlayers;
	// args:[table,nRequest,pData,nLen,tokenExcept=0,compressed=FALSE]
	ImportFunctional<int((CTable*, UINT, void*, int, LONG, BOOL))>  imNotifyTableVisitors;
	// args:[app,key,value]
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
	// args:[int roomid, int tableno, CYQWGameData& game_data]
	ImportFunctional<BOOL(int,int,CYQWGameData&)> imYQW_LookupGameData;
	// args:[int userid, USER_DATA & user_data]
	ImportFunctional<int((int,USER_DATA&))> imLookupUserData;

	CGoodLuckDelegate();

	void OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter);
	void OnShutdown();
public:
	// server event
	void OnNewTable(CCommonBaseTable* table);
	void YQW_CloseSoloTable(CCommonBaseTable* table, int roomid, DWORD dwAbortFlag);
	void OnCPGameStarted(CCommonBaseTable* table, void* pData);
	void YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData);
	void OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CCommonBaseTable* pTable, CPlayer* pPlayer);
	void OnCPExchGameGoods(int nUserID, int nStatusCode, LPEXCH_GOODS_DATA pData);
public:
	// table event
	void OnRestAll(CCommonBaseTable* table);
public:
	// msg
	virtual BOOL OnBuyGoodLuckProp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    
public:
	// api
    virtual BOOL OnShowGoodLuckProp(CCommonBaseTable* pTable);
    virtual BOOL OnSendGoodLuckPropStateWhenGameWin(CCommonBaseTable* pTable);
    virtual BOOL OnSendGoodLuckPropStateByPlayer(CCommonBaseTable* pTable, CPlayer* pPlayer);
    virtual void YQW_OnCPDeductHappyCoinResult(CCommonBaseTable* pTable, LPYQW_DEDUCT_HAPPYCOIN pDeductReq, LPYQW_HAPPYCOIN_CHANGE pDeductRet);
    virtual void BuyGoodLuckProp(CCommonBaseTable* pTable, int userid, int nHappyCoin, EXCH_GAME_GOODS goods);
    virtual void AddGoodLuckPropFreeCount(int userid, int count = 1);
    virtual void WriteGoodLuckLog(int userid, int roomNo, int result);
    virtual void NextPlayerBuyGood(CCommonBaseTable* pTable);
    


    virtual void OnHourTriggered();

protected:
	plana::threadpools::stdtimerPtr m_timerPtr;	// 1 hour per round
    // 好运来当前日期
    int m_nCurrentGoodLuckDate;
};

