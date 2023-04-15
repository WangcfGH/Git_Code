#include "stdafx.h"
#include "GameToChunkClient.h"

#define     CLIENT_TYPE_GAME            4       // ÓÎÏ··þÎñÆ÷
void GameToChunkClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        std::string iniFile;
        imGetIniFile(iniFile);
        setIniFile(iniFile);

        std::string ip;
        imGetIniString("chunkserver", "name", ip);
        setIpAndPort(ip, PORT_OF_CHUNKSVR);
        setClientType(CLIENT_TYPE_GAME);
        int tmpRet = Create(m_szIp.c_str(), m_nPort, 10, TRUE, GetHelloData(), GetHelloLength() + 1, 1, 10);
        if (tmpRet)
        {
            tmpRet = Initialize();
            if (tmpRet) {
                UwlTrace(_T("ChunkSockClient Initialize Success. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
                UwlLogFile(_T("ChunkSockClient Initialize Success. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
            }
            else {
                UwlTrace(_T("ChunkSockClient Initialize Failed. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
                UwlLogFile(_T("ChunkSockClient Initialize Failed. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
            }
            
        }
        else
        {
            UwlTrace(_T("ChunkSockClient Create Failed. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
            UwlLogFile(_T("ChunkSockClient Create Failed. ip[%s:%d]"), m_szIp.c_str(), m_nPort);
        }
    }
}

void GameToChunkClient::OnShutdown()
{
    Shutdown();
}

BOOL GameToChunkClient::ValidateClientInfo()
{
    TCHAR szYxpdsvr[MAX_PATH];
    memset(szYxpdsvr, 0, sizeof(szYxpdsvr));
    GetSystemDirectory(szYxpdsvr, MAX_PATH);
    lstrcat(szYxpdsvr, _T("\\yxpdsvr.ini"));

    REQUEST request;
    memset(&request, 0, sizeof(request));
    REQUEST response;
    memset(&response, 0, sizeof(response));

    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    context.hSocket = GetSocket();

    VALIDATE_GAMESVR vg;
    memset(&vg, 0, sizeof(vg));

    vg.nClientID = GetPrivateProfileInt(_T("HOST"), _T("ID"), 0, szYxpdsvr); //
    vg.nClientType = CLIENT_TYPE_GAME_EX; //
    int gameid = 0;
    imGetGameID(gameid);
    vg.nGameID = gameid;
    vg.nGamePort = PORT_OF_GAMESVR;

    request.head.nRequest = GR_VALIDATE_GAMESVR_EX;
    request.nDataLen = sizeof(vg);
    request.pDataPtr = &vg;

    BOOL bTimeout = FALSE;
    BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout);
    return bSendOK;
}
