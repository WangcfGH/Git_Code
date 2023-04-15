#pragma once
#include "plana.h"
#include "TcyMsgCenter.h"

// ͬ���οͻ�������
// create ��������Զ�̵�ַ
class TcySockClient : public CDefIocpClient, public plana::threadpools::PlanaStaff
{
public:
    enum CONFIG
    {
        FRESH_TIMER_DIFF = 5, // 5���Ӽ��
        PULSE_TIMER_DIFF = 60, // 60��
        RECONNECT_TIME_DIFF = 3, // 3��
    };

    TcySockClient(
        int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : CDefIocpClient(nKeyType, flagEncrypt, flagCompress)
    {
        ZeroMemory(&m_ChunkSvrPulseInfo, sizeof(m_ChunkSvrPulseInfo));

    }


    TcySockClient(const BYTE key[] = 0, const ULONG key_len = 0,
        DWORD flagEncrypt = 0, DWORD flagCompress = 0,
        BOOL bUseCRC32 = FALSE, int packet_size = DEF_PACKET_SIZE)
        : CDefIocpClient(key, key_len, flagEncrypt, flagCompress, bUseCRC32, packet_size)
    {
        ZeroMemory(&m_ChunkSvrPulseInfo, sizeof(m_ChunkSvrPulseInfo));
    }

    ~TcySockClient();

    // event
    EventNoMutex<> evConnectOK;
    EventNoMutex<> evClose;
    EventNoMutex<TcyMsgCenter*> evClientStart;
    ImportFunctional<int() > imGetGameID;
	ImportFunctional<int()> imGetClientID;

	// ��Ϣ�ַ�
	TcyMsgCenter m_msgCenter;


    void setIpAndPort(const std::string& ip, int nPort)
    {
        m_szIp = ip;
        m_nPort = nPort;
    }
    void setIniFile(const std::string& file)
    {
        m_iniFile = file;
    }

    virtual BOOL Initialize();
    virtual void Shutdown()  override;

    // ������Ϣ, data����copy�ķ�ʽ��������������, ԭ�����Ѿ��ɲ���
    void DoSendMsg(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // ������Ϣ, data����move�ķ�ʽ��������������,ԭ���ݽ��᲻����
    void DoSendMsgByMoveData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // ������Ϣ,�ȴ��ظ�
    void DoSendMsgWaitRsp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, LPREQUEST lpResponse, int nTimeOut);
protected:
	// �ж��Ƿ�ʱ
	BOOL OnTimerPulse();
	// ������������
	virtual void OnReconnect();
	// ˢ�¶�ʱ�� ִ��sendpulse
	BOOL OnTimerFresh();
	// ������
	void OnSendPulseData();
	// ÿ������6������buffer
	int DoTimingWork();
	
	void SendMsgByAddContexthead(std::shared_ptr<TcyMsgHead> tcyMsgHead);
protected:
    virtual BOOL OnRequest(void* lpParam1, void* lpParam2) override;

    virtual BOOL OnConnectClose(LPREQUEST, LPCONTEXT_HEAD);
    virtual BOOL OnServerPulse(LPREQUEST, LPCONTEXT_HEAD);

    virtual BOOL ValidateClientEx();
    virtual BOOL ValidateClientInfo();
    void setClientType(int type);
protected:
    std::string m_szIp;
    int m_nPort;
    std::string m_iniFile;
    SERVERPULSE_INFO m_ChunkSvrPulseInfo;
    int m_nClientType;

    plana::threadpools::stdtimerPtr m_timerPulse;
    plana::threadpools::stdtimerPtr m_timerFresh;
    plana::threadpools::stdtimerPtr m_timerDoClear;

	plana::threadpools::stdtimerPtr m_timerReconnect;

	////////////////////////////////////////////////////////////
	// �п�����assist sendRequest ����FALSE
	std::vector<std::shared_ptr<TcyMsgHead> > m_faildRequests;
};

