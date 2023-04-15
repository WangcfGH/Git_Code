#pragma once

struct MJServerEvent
{
    // 可以定义麻将消息处理的事件，例如:吃，碰，杠操作的时候，分发事件，给其他模块用
    // 事件分发的位置在 【操作之后】，【新事件和网络分发之前】

    // arg4:int auction_finished
    EventNoMutex<CCommonBaseTable*, AUCTION_BANKER*, int>   evMJAuctionBanker;
    EventNoMutex<CCommonBaseTable*, CATCH_CARD*, CARD_CAUGHT*>  evMJCatch;
    EventNoMutex<CCommonBaseTable*, THROW_CARDS*>   evMJThrow;
    EventNoMutex<CCommonBaseTable*, CHI_CARD*>  evMJChi;
    EventNoMutex<CCommonBaseTable*, PENG_CARD*> evMJPeng;
    EventNoMutex<CCommonBaseTable*, GANG_CARD*, CARD_GANG*> evMJMnGang;
    EventNoMutex<CCommonBaseTable*, GANG_CARD*, CARD_GANG*> evMJAnGang;
    EventNoMutex<CCommonBaseTable*, GANG_CARD*, CARD_GANG*> evMJPnGang;
    EventNoMutex<CCommonBaseTable*, GUO_CARD*>  evMJGuo;
    EventNoMutex<CCommonBaseTable*, HU_CARD*, int>  evMJHu;
    EventNoMutex<CCommonBaseTable*, HUA_CARD*, CARD_HUA*>   evMJHua;
};

class CMJServer : public CCommonBaseServer, public MJServerEvent
{
public:
    CMJServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer,
        const int nListenPort, const int nGameID, DWORD flagEncrypt, DWORD flagCompress);
    virtual CTable* OnNewTable(int roomid = INVALID_OBJECT_ID, int tableno = INVALID_OBJECT_ID, int score_mult = 1) override;
    virtual BOOL OnRequest(void* lpParam1, void* lpParam2) override;

    virtual BOOL ConstructEnterGameDXXW(int roomid, CTable* pTable, int chairno, int userid, BOOL lookon, LPREQUEST lpResponse) override;
    virtual BOOL OnCPHandCardInfoToLooker(int roomid, CPlayer* pPlayer, CPlayer* pLooker, CTable* pTable) override;

    // for client's request
    virtual BOOL OnAuctionBanker(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnCatchCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual void ResponseThrowCardSucceed(REQUEST response, LPCONTEXT_HEAD lpContext, CMJTable* pTable, LPTHROW_CARDS pThrowCards, BOOL bPassive);
    virtual BOOL OnPreChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPrePengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPreGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnGuoCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnHuCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL onMergeThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnReconsChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnReconsPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnReconsMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnReconsAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnReconsPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnReconsGuoCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);// 吃碰杠消息的重构
    virtual BOOL OnHuaCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL onThrowHuTingCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt);
    virtual BOOL OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override; // TODO:在尾部追加听牌提示结构

    // for notify client
    virtual void NotifyAuctionBanker(CMJTable* pTable, LPAUCTION_BANKER pAuctionBanker, LONG tokenExcept = 0);
    virtual void NotifyAuctionFinished(CMJTable* pTable, LPAUCTION_BANKER pAuctionBanker, LONG tokenExcept = 0);
    virtual void NotifyInvalidThrow(CMJTable* pTable, LPTHROW_CARDS pThrowCards, LONG tokenExcept = 0);
    virtual BOOL ResponseThrowAgain(LPCONTEXT_HEAD lpContext, int nCardIDs[], BOOL bPassive = FALSE);
    virtual void NotifyCardsThrow(CMJTable* pTable, LPTHROW_CARDS pThrowCards, UINT nRequest, LONG tokenExcept = 0);
    virtual void NotifyCardCaught(CMJTable* pTable, LPCARD_CAUGHT pCardCaught, LONG tokenExcept = 0);
    virtual void NotifyCardPreChi(CMJTable* pTable, LPPRECHI_CARD pPreChiCard, LONG tokenExcept = 0);
    virtual void NotifyCardChi(CMJTable* pTable, LPCHI_CARD pChiCard, LONG tokenExcept = 0);
    virtual void NotifyCardPrePeng(CMJTable* pTable, LPPREPENG_CARD pPrePengCard, LONG tokenExcept = 0);
    virtual void NotifyCardPeng(CMJTable* pTable, LPPENG_CARD pPengCard, LONG tokenExcept = 0);
    virtual void NotifyPreGangOK(CMJTable* pTable, LPPREGANG_OK pPreGangOK, LONG tokenExcept = 0);
    virtual void NotifyCardMnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept = 0);
    virtual void NotifyCardAnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept = 0);
    virtual void NotifyCardPnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept = 0);
    virtual void NotifyCardHua(CMJTable* pTable, LPHUA_CARD pHuaCard, int card_got, int card_no, LONG tokenExcept = 0);
    virtual BOOL NotifyTableMsg(CTable* pTable, int nDest, int nMsgID, int datalen = 0, void* data = NULL, LONG tokenExcept = 0);
    virtual BOOL NotifyPlayerMsgAndResponse(LPCONTEXT_HEAD lpContext, CTable* pTable, int nDest, DWORD dwFlags, DWORD datalen = 0, void* data = NULL);
    virtual void NotifyMergeCardsThrow(CMJTable* pTable, LPMERGE_THROWCARDS pMergeThrowCards, UINT nRequest, LONG tokenExcept = 0);
    virtual int OnNoCardRemains(CMJTable* pTable, int chairno) { return 1; }
    virtual int OnNoCardLeft(CMJTable* pTable, int chairno) { return 1; }
    virtual int OnJokerShownCaught(CMJTable* pTable, int chairno, BOOL& bBuHua);
    virtual int OnCardCaught(CMJTable* pTable, int chairno);
    virtual BOOL NotifySomeOneBuHua(CMJTable* pTable, LONG tokenExcept = 0);
public:
    virtual BOOL IsServerAutoCatch() { return GetPrivateProfileInt(_T("ServerAutoPlay"), _T("enable"), 1, GetINIFilePath()); }// 服务器自动抓牌开关

    virtual void OnServerChiPengGangCard(CRoom* pRoom, CMJTable* pTable) ;
    virtual BOOL JudgeGuoCanAutoPlay(int totalChairs, DWORD dwPGCHFlags[]) ;
    virtual void UWLCurrentChairCards(CMJTable* pTable, int nChairNO, int nCardID, int nRoomID, int nTableNO, int nUserID) = 0;

public:

    virtual BOOL YQW_OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt) override;
    virtual void YQW_SetGameData(int roomid, int tableno, CYQWGameData& game_data) override;
};