#pragma once
#define SOAP_INDEX_OF_WXTASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;
#define WXTASK_ERR_CHUNKERR        _T("服务器查询异常，请过段时间后再试。")

class TcyMsgCenter;
class WxTaskModule
{
public:
    // 在assist中, 此函数注册app端过来的信息(assist作为服务端)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutdown();
    // 在assist中, 此函数注册chunk过来的信息(assist作为客户端)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    // 发送消息到chunk
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
    // 发送消息到用户
    ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int)> imNotifyOneWithParseContext;
    // 发送错误通知到用户
    ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, LPCTSTR)> imNotifyOneUserErrorInfo;
    // 执行soap线程操作
    ImportFunctional<void(int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr & pSoapClient)>)> imDoSoap;
    //获取配置string信息
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
    //获取配置int信息
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;

protected:
    // 直接转发来自客户端的消息
    BOOL OnTransmitRequest(LPCONTEXT_HEAD, LPREQUEST);
    // 直接转发来自chunk的消息
    BOOL OnTransmitRequestFromChunk(LPCONTEXT_HEAD, LPREQUEST);
    //**********************从ChunkSvr发来的消息处理***************************
    // onRequest领奖
    BOOL OnAwardWxTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnChangeWxTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    //*************************************************************************
    CString complete(int nTaskActionID, LPWXTASKRESULT pData, IXYSoapClientPtr& pSoapClient);
    // soap领奖处理
    BOOL DoWorkGetWxTaskPrize(LPSOAP_SERVICE , IXYSoapClientPtr& , LPCONTEXT_HEAD , LPREQUEST );
};

