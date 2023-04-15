#pragma once
#include "tcycomponents/TcySockSvr.h"
#include "dbconnectpool/TcyMySqlConnect.h"
#include <mutex>

#define	MAX_PROCESSORS_SUPPORT	4

class MainServer : public TcySockSvr
{
public:
    MainServer(const BYTE key[] = 0, const ULONG key_len = 0, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(key, key_len, flagEncrypt, flagCompress){
		m_nPort = -1;
		ZeroMemory(m_chunkdb, sizeof(m_chunkdb));
		ZeroMemory(&m_AssistSvrClient, sizeof(m_AssistSvrClient));
		ZeroMemory(&m_RoomSvrClient, sizeof(m_RoomSvrClient));
		ZeroMemory(&m_GameSvrClient, sizeof(m_GameSvrClient));
	}

    MainServer(int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(nKeyType, flagEncrypt, flagCompress){
		m_nPort = -1;
		ZeroMemory(m_chunkdb, sizeof(m_chunkdb));
		ZeroMemory(&m_AssistSvrClient, sizeof(m_AssistSvrClient));
		ZeroMemory(&m_RoomSvrClient, sizeof(m_RoomSvrClient));
		ZeroMemory(&m_GameSvrClient, sizeof(m_GameSvrClient));
	}


	~MainServer();

    ImportFunctional<std::string()> imGetIniFile;
	ImportFunctional<int()> imGetGameID;

	virtual BOOL Initialize() override;

    void SendOpeRequestForModule(LPCONTEXT_HEAD lpContext, REQUEST& response);
    void SendOpeReqOnlyCxtForModule(LPCONTEXT_HEAD lpContext, UINT nRepeatHead, void* pData, REQUEST& response);
    void SendOpeResponseForModule(LPCONTEXT_HEAD lpContext, BOOL bNeedEcho, REQUEST& response);

	int DB_ValidateClientEx(MysqlSession* entry, const LPVALIDATE_CLIENT_EX lpValidateClientEx, UINT& nResponse);
    void GetRoomSvrSocket(SOCKET &nSock, LONG& token);
    void GetAssistSvrSocket(SOCKET &nSock, LONG& token);
	void GetGameSvrSocket(SOCKET &sock, LONG& token);
protected:
	int ReadChunkDBConfig();
	void FillDBAccount();

	BOOL InitStart();
	BOOL InitChunkDB(int nConnCount);
    
    void OnConnectSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    
	BOOL OnValidateClient(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnValidateClientEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnValidateGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
private:

	std::string			m_dbaFile;
	int					m_nChunkDb = 0;
	CHUNK_DB			m_chunkdb[MAX_TOTALDB_COUNT];
	MysqlSession		m_mainDbCon;
	std::mutex			m_dbLock;

    CONTEXT_HEAD        m_RoomSvrClient;
    CONTEXT_HEAD        m_AssistSvrClient;
	CONTEXT_HEAD		m_GameSvrClient;
	int					m_nClientID = 0;
};
