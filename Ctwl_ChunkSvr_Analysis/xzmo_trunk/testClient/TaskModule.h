#pragma once

#define SOAP_INDEX_OF_TASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define TASK_ERR_TRANSMIT        _T("服务器网络故障，请过段时间后再试。")
#define TASK_ERR_CHUNKERR        _T("服务器查询异常，请过段时间后再试。")
class TcyMsgCenter;
struct MsgToDingRobot;
class CTaskModule
{
public:
    CTaskModule(int gameid) {
        m_gameid = gameid;
    }
    // 在assist中, 此函数注册app端过来的信息(assist作为服务端)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

    void OnShutdown();

    // 在assist中, 此函数注册chunk过来的信息(assist作为客户端)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    //发送消息到chunk
    SingleEventNoMutex<LPCONTEXT_HEAD, LPREQUEST> evMsgToChunk;
    // 发送消息到用户
	SingleEventNoMutex<LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int> evNotifyOneWithParseContext;
	SingleEventNoMutex<SOCKET, LONG, UINT, void*, int> evNotifyOneUser;

    // 发送错误通知到用户
	SingleEventNoMutex<LPREQUEST, LPCONTEXT_HEAD, LPCTSTR> evNotifyOneUserErrorInfo;
    // 执行soap线程操作
	SingleEventNoMutex<int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient)>> evDoSoap;

    // 发送文本到钉钉机器人
    EventNoMutex<MsgToDingRobot&> evNoticeTextToDingTalkRobot;

    //获取配置信息
    EventNoMutex<const char*, const char*, std::string&> evGetIniString;

protected:
    TCHAR           m_szIniFile[MAX_PATH];
    int             m_gameid;
/*********************************************************************************************************************************/

public:
    //******************** from app ****************************
    BOOL OnChangeTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnAwardTaskPrize(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqTaskInfoData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskChangeParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqGetTaskJsonConfig(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    /***********************************************************/

    /************************* from chunk ****************************/
    BOOL OnChangeTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnQueryTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnQueryTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnAwardTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqTaskInfoDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskChangeParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqGetTaskJsonConfigRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    /***********************************************************/

    BOOL DoWorkGetLTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL DoWorkGetTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void NoticeToDingTalkRobot(CString text);
    typedef std::shared_ptr<CTaskModule> Ptr;


    //////////////////////////////////////////////////////////////////////////
    CString complete(int nTaskActionID, LPTASKRESULT pData, IXYSoapClientPtr& pSoapClient);
    CString CTaskModule::complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient);
};
