#pragma once

#define SOAP_INDEX_OF_TASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define TASK_ERR_TRANSMIT        _T("服务器网络故障，请过段时间后再试。")
#define TASK_ERR_CHUNKERR        _T("服务器查询异常，请过段时间后再试。")
class TcyMsgCenter;
struct MsgToDingRobot;
class TaskModule
{
public:
    TaskModule(int gameid) {
        m_gameid = gameid;
    }
    // 在assist中, 此函数注册app端过来的信息(assist作为服务端)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

    void OnShutdown();

    // 在assist中, 此函数注册chunk过来的信息(assist作为客户端)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    //发送消息到chunk
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
    // 发送消息到用户
	ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int)> imNotifyOneWithParseContext;

    // 发送错误通知到用户
	ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, LPCTSTR)> imNotifyOneUserErrorInfo;
    // 执行soap线程操作
	ImportFunctional<void(int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr & pSoapClient)>)> imDoSoap;

    // 发送文本到钉钉机器人
	ImportFunctional<void(MsgToDingRobot&)> imNoticeTextToDingTalkRobot;

    //获取配置string信息
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
    //获取配置int信息
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
protected:
    int             m_gameid;
/*********************************************************************************************************************************/

public:
    BOOL OnTransmitRequest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnTransmitRequestFromChunk(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    /************************* from chunk ****************************/
    BOOL OnChangeTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnAwardTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskChangeParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnReqLTaskAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    /***********************************************************/

    BOOL DoWorkGetLTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL DoWorkGetTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void NoticeToDingTalkRobot(CString text);
    typedef std::shared_ptr<TaskModule> Ptr;


    //////////////////////////////////////////////////////////////////////////
    CString complete(int nTaskActionID, LPTASKRESULT pData, IXYSoapClientPtr& pSoapClient);
    CString TaskModule::complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient);
};
