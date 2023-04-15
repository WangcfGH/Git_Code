#pragma once
#include "plana.h"
#include "TcyMsgCenter.h"

// 同城游客户端连接
// create 进行连接远程地址
class TcySockClient : public CDefIocpClient, public plana::threadpools::PlanaStaff
{
public:
    enum CONFIG
    {
        FRESH_TIMER_DIFF = 5, // 5分钟间隔
        PULSE_TIMER_DIFF = 60, // 60秒
        RECONNECT_TIME_DIFF = 3, // 3秒
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

	// 消息分发
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

    // 发送消息, data利用copy的方式来保护生命周期, 原数据已经可操作
    void DoSendMsg(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // 发送消息, data利用move的方式来保护生命周期,原数据将会不存在
    void DoSendMsgByMoveData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // 发送消息,等待回复
    void DoSendMsgWaitRsp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, LPREQUEST lpResponse, int nTimeOut);
protected:
	// 判断是否超时
	BOOL OnTimerPulse();
	// 进行重连操作
	virtual void OnReconnect();
	// 刷新定时器 执行sendpulse
	BOOL OnTimerFresh();
	// 发心跳
	void OnSendPulseData();
	// 每天早上6点清理buffer
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
	// 有可能是assist sendRequest 反馈FALSE
	std::vector<std::shared_ptr<TcyMsgHead> > m_faildRequests;
};

