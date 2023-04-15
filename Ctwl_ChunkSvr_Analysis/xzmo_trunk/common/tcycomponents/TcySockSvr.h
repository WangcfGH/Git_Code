#pragma once
#include "plana.h"
#include "TcyMsgCenter.h"
#include <map>

// ͬ���μ���������

class TcySockSvr : public CDefIocpServer, public plana::threadpools::PlanaStaff
{
public:
    enum  CONFIG
    {
        PULSE_TIMER_DIFF = 5, // 5���Ӽ��
    };

    TcySockSvr(const BYTE key[] = 0, const ULONG key_len = 0, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : CDefIocpServer(key, key_len, flagEncrypt, flagCompress)
    {
        m_nPort = -1;
    }

    TcySockSvr(int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : CDefIocpServer(nKeyType, flagEncrypt, flagCompress) {}

    ~TcySockSvr();

    void setIPAndPort(const char* szIP, int port)
    {
        m_strServerIP = szIP;
        m_nPort = port;
    }
    void setIniFile(const std::string& file)
    {
        m_iniFile = file;
    }

    // main�е���; DEBUG��������;releases ��Service����
    virtual BOOL Initialize();
    virtual void Shutdown() override;

    BOOL SendOpeResponse(LPCONTEXT_HEAD lpContext, BOOL bNeedEcho, REQUEST& response);//�л�Ӧ������
    BOOL SendOpeRequest(LPCONTEXT_HEAD lpContext, REQUEST& response);                 //�޻�Ӧ������
    BOOL SendOpeRequest(LPCONTEXT_HEAD lpContext, void* pData, int nLen, REQUEST& response);  //�޻�Ӧ������
    BOOL SendOpeReqOnlyCxt(LPCONTEXT_HEAD lpContext, UINT nRepeatHead, void* pData, REQUEST& response); //�޻�Ӧ������,ֻ�ر���ͷ


protected:
    virtual BOOL OnRequest(void* lpParam1, void* lpParam2) override;
    void OnPulseTimer();
    BOOL OnClientPulse(LPREQUEST, LPCONTEXT_HEAD);

public:
    // event����
    EventNoMutex<BOOL&, TcyMsgCenter*> evSvrStart;
    EventNoMutex<>      evShutdown;

    // �÷������Ϣ�ַ�
    TcyMsgCenter m_msgCenter;

protected:
    std::string m_iniFile;
    int m_nPort;
    std::string m_strServerIP;
};

