#pragma once

#define SOAP_INDEX_OF_TASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define TASK_ERR_TRANSMIT        _T("������������ϣ������ʱ������ԡ�")
#define TASK_ERR_CHUNKERR        _T("��������ѯ�쳣�������ʱ������ԡ�")
class TcyMsgCenter;
struct MsgToDingRobot;
class CTaskModule
{
public:
    CTaskModule(int gameid) {
        m_gameid = gameid;
    }
    // ��assist��, �˺���ע��app�˹�������Ϣ(assist��Ϊ�����)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

    void OnShutdown();

    // ��assist��, �˺���ע��chunk��������Ϣ(assist��Ϊ�ͻ���)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    //������Ϣ��chunk
    SingleEventNoMutex<LPCONTEXT_HEAD, LPREQUEST> evMsgToChunk;
    // ������Ϣ���û�
	SingleEventNoMutex<LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int> evNotifyOneWithParseContext;
	SingleEventNoMutex<SOCKET, LONG, UINT, void*, int> evNotifyOneUser;

    // ���ʹ���֪ͨ���û�
	SingleEventNoMutex<LPREQUEST, LPCONTEXT_HEAD, LPCTSTR> evNotifyOneUserErrorInfo;
    // ִ��soap�̲߳���
	SingleEventNoMutex<int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient)>> evDoSoap;

    // �����ı�������������
    EventNoMutex<MsgToDingRobot&> evNoticeTextToDingTalkRobot;

    //��ȡ������Ϣ
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
