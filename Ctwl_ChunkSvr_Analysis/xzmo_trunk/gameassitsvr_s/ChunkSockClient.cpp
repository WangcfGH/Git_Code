#include "StdAfx.h"
#include "ChunkSockClient.h"
#include "tcycomponents/TcyMsgCenter.h"

void ChunkSockClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		std::string iniFile = imGetIniFile();
		setIniFile(iniFile);

        std::string ip;
        imGetIniString("chunkserver", "name", ip);
        setIpAndPort(ip, PORT_OF_CHUNKSVR);
        setClientType(CLIENT_TYPE_ASSIT);
		ret = Create(m_szIp.c_str(), m_nPort, 10, TRUE, GetHelloData(), GetHelloLength() + 1, 1, 10);
		if (ret) {
			ret = Initialize();
            
        }
        else {
            UwlTrace(_T("ChunkSockClient Create Failed."));
            UwlLogFile(_T("ChunkSockClient Create Failed."));
        }
	}
}

void ChunkSockClient::OnShutdown()
{
	Shutdown();
}

BOOL ChunkSockClient::ValidateClientEx()
{
	REQUEST request;
	memset(&request, 0, sizeof(request));
	REQUEST response;
	memset(&response, 0, sizeof(response));
	
	CONTEXT_HEAD context;
	context.hSocket = GetSocket();
	context.lSession = 0;
	context.bNeedEcho = TRUE;
	
	VALIDATE_CLIENT_EX vce;
	ZeroMemory(&vce, sizeof(vce));
	vce.nClientType = m_nClientType; //
	imGetGameID(vce.nClientID);
	xyGetHardID(vce.szHardID);
	xyGetVolumeID(vce.szVolumeID);
	xyGetMachineID(vce.szMachineID);
	request.head.nRequest = GR_VALIDATE_CLIENT_EX;
	request.nDataLen = sizeof(vce);
	request.pDataPtr = &vce;
	
	BOOL bTimeout = FALSE;
	BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout, 10000);
	if (!bSendOK || UR_FETCH_SUCCEEDED != response.head.nRequest)
	{
	    UwlLogFile(_T("ValidateClientEx() failed!"));
	    UwlClearRequest(&response);
	    return FALSE;
	}
	
	UwlClearRequest(&response);
	UwlLogFile(_T("ValidateClientEx() OK!"));
	return TRUE;
}

BOOL ChunkSockClient::ValidateClientInfo()
{
	REQUEST request;
	memset(&request, 0, sizeof(request));
	REQUEST response;
	memset(&response, 0, sizeof(response));
	
	CONTEXT_HEAD context;
	memset(&context, 0, sizeof(context));
	context.hSocket = GetSocket();
	
	VALIDATE_CLIENT vc;
	ZeroMemory(&vc, sizeof(vc));
	imGetClientID(vc.nClientID);
	vc.nClientType = m_nClientType; //
	
	request.head.nRequest = GR_VALIDATE_CLIENT;
	request.nDataLen = sizeof(vc);
	request.pDataPtr = &vc;
	
	BOOL bTimeout = FALSE;
	BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout);
	return bSendOK;
}
