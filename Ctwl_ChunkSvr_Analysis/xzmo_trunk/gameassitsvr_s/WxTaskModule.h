#pragma once
#define SOAP_INDEX_OF_WXTASK		0
#include "plana.h"

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;
#define WXTASK_ERR_CHUNKERR        _T("��������ѯ�쳣�������ʱ������ԡ�")

class TcyMsgCenter;
class WxTaskModule
{
public:
    // ��assist��, �˺���ע��app�˹�������Ϣ(assist��Ϊ�����)
    void OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutdown();
    // ��assist��, �˺���ע��chunk��������Ϣ(assist��Ϊ�ͻ���)
    void OnChunkClientStart(TcyMsgCenter* msgCenter);

    // ������Ϣ��chunk
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
    // ������Ϣ���û�
    ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, UINT, void*, int)> imNotifyOneWithParseContext;
    // ���ʹ���֪ͨ���û�
    ImportFunctional<void(LPREQUEST, LPCONTEXT_HEAD, LPCTSTR)> imNotifyOneUserErrorInfo;
    // ִ��soap�̲߳���
    ImportFunctional<void(int, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr & pSoapClient)>)> imDoSoap;
    //��ȡ����string��Ϣ
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
    //��ȡ����int��Ϣ
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;

protected:
    // ֱ��ת�����Կͻ��˵���Ϣ
    BOOL OnTransmitRequest(LPCONTEXT_HEAD, LPREQUEST);
    // ֱ��ת������chunk����Ϣ
    BOOL OnTransmitRequestFromChunk(LPCONTEXT_HEAD, LPREQUEST);
    //**********************��ChunkSvr��������Ϣ����***************************
    // onRequest�콱
    BOOL OnAwardWxTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    BOOL OnChangeWxTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr);
    //*************************************************************************
    CString complete(int nTaskActionID, LPWXTASKRESULT pData, IXYSoapClientPtr& pSoapClient);
    // soap�콱����
    BOOL DoWorkGetWxTaskPrize(LPSOAP_SERVICE , IXYSoapClientPtr& , LPCONTEXT_HEAD , LPREQUEST );
};

