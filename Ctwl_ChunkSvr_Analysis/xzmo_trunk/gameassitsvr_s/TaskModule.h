#pragma once

#define SOAP_INDEX_OF_TASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define TASK_ERR_TRANSMIT        _T("������������ϣ������ʱ������ԡ�")
#define TASK_ERR_CHUNKERR        _T("��������ѯ�쳣�������ʱ������ԡ�")
class TcyMsgCenter;
struct MsgToDingRobot;
class TaskModule
{
public:
    TaskModule(int gameid) {
        m_gameid = gameid;
    }
    // ��assist��, �˺���ע��app�˹�������Ϣ(assist��Ϊ�����)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

    void OnShutdown();

    // ��assist��, �˺���ע��chunk��������Ϣ(assist��Ϊ�ͻ���)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    //������Ϣ��chunk
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
    // ������Ϣ���û�
	ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int)> imNotifyOneWithParseContext;

    // ���ʹ���֪ͨ���û�
	ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, LPCTSTR)> imNotifyOneUserErrorInfo;
    // ִ��soap�̲߳���
	ImportFunctional<void(int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr & pSoapClient)>)> imDoSoap;

    // �����ı�������������
	ImportFunctional<void(MsgToDingRobot&)> imNoticeTextToDingTalkRobot;

    //��ȡ����string��Ϣ
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
    //��ȡ����int��Ϣ
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
