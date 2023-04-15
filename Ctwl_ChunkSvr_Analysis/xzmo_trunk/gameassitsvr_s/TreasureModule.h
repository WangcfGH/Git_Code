#pragma once
#include "plana.h"

class TcyMsgCenter;
// ±¦Ïä¹¦ÄÜ
class TreasureModule
{
public:
	TreasureModule();

    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
    ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int)> imNotifyOneWithParseContext;
	ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunkLog;
	ImportFunctional<void(std::function<void(CHttpClient&)>)> imDoHttp;

    BOOL OnQueryTreasureInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnTakeTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    BOOL OnQueryTreasureInfoRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnTakeTreasureAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
	int ParseAwardResult(CString result);

private:
	std::string m_strAddr;
};