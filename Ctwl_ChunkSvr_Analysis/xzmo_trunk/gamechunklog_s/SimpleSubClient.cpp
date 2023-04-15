#include "stdafx.h"
#include "SimpleSubClient.h"

void SimpleSubClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
        std::string ip;

        imGetConfigStr("OnlineServer", "Name", ip);
        if (ip.empty()) {
            UwlLogFile("Online Ip is Empty");
            return;
        }
        int port = PORT_TRANK_SERVER;
        imGetConfigInt("OnlineServer", "port", port);

		setIpAndPort(ip, port);

        // chunklog不能订阅onlinesvr, 因此使用chunk类型
        setClientType(CLIENT_TYPE_CHUNK);

		ret = Create(m_szIp.c_str(), m_nPort, 10, TRUE, GetHelloData(), GetHelloLength() + 1, 10, 10);
		if (ret) {
			ret = Initialize() && SubcribeMsg();
			if (ret) {
				// 原来的连接代码，客户端将不再进行刷新时间了
				m_timerPulse = nullptr;
				RegesterMsgCenter();
			}
			else {
				UwlTrace("Online Initialize %s,%d", ip.c_str(), port);
                UwlLogFile("Online Initialize %s,%d", ip.c_str(), port);
			}
		}
		else {
            UwlTrace("Online Connect Error %s,%d", ip.c_str(), port);
            UwlLogFile("Online Connect Error %s,%d", ip.c_str(), port);
		}
	}
}

BOOL SimpleSubClient::ValidateClientInfo()
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

void SimpleSubClient::OnReconnect()
{
	CloseSockets();

	if (FALSE == BeginConnect(m_szIp.c_str(), m_nPort, 1, DEF_ADDRESS_FAMILY, SOCK_STREAM,
		IPPROTO_TCP,
		1000)) {
		UwlTrace(_T("Can not connect to server %s."), typeid(*this).name());
		UwlLogFile(_T("Can not connect to server %s."), typeid(*this).name());
	}
	else {
		UwlTrace(_T("connect to server %s."), typeid(*this).name());
		UwlLogFile(_T("connect to server %s."), typeid(*this).name());

		// 这里必须要重新进行一次订阅消息
		if (ValidateClientInfo() && SubcribeMsg()) {
			m_timerReconnect = nullptr;
		}
	}
}

BOOL OnlineClient::SubcribeMsg()
{
	int nClientID = 0;
	imGetClientID(nClientID);
	
	REQUEST request;
	memset(&request, 0, sizeof(request));
	REQUEST response;
	memset(&response, 0, sizeof(response));
	
	CONTEXT_HEAD context;
	context.hSocket = GetSocket();
	context.lSession = 0;
	context.bNeedEcho = 0;
	
	RSS_PLAYERLOGONOFF rpl;
	ZeroMemory(&rpl, sizeof(rpl));
	rpl.nClientID = nClientID;
	rpl.nClientType = m_nClientType;
	imGetGameID(rpl.nGameID);
	rpl.dwFlags = FLAG_PUSHLOGON_MOBILE | FLAG_PUSHLOGON_BYGAMEID;	//只订阅指定移动端游戏的用户登录信息
//	rpl.dwFlags = FLAG_PUSHLOGON_PC|FLAG_PUSHLOGON_MOBILE|FLAG_PUSHLOGON_ALLAPP; //For test 可订阅所有用户登录信息
	
	request.head.nRequest = GR_RSS_PLAYERLOGONOFF;
	request.nDataLen = sizeof(rpl);
	request.pDataPtr = &rpl;
	
	BOOL bTimeout = FALSE;
	BOOL bSendOk = SendRequest(&context, &request, &response, bTimeout);
	if (!bSendOk) {
		UwlLogFile("RSSPlayerLogOnOff error");
	}
	return bSendOk;
}

void OnlineClient::RegesterMsgCenter()
{
	auto* selfMsgCenter = &m_msgCenter;
	AUTO_REGISTER_MSG_OPERATOR(selfMsgCenter, GR_NTF_PLAYERLOGON, OnPlayerlogin);
	AUTO_REGISTER_MSG_OPERATOR(selfMsgCenter, GR_NTF_PLAYERLOGOFF, OnPlayerlogoff);
}

BOOL OnlineClient::OnPlayerlogin(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* lpNtfPlayerLogon = RequestDataParse<NTF_PLAYERLOGON>(lpRequest);
	if (lpNtfPlayerLogon) {
		evPlayerLogin(*lpNtfPlayerLogon);
	}
	return TRUE;
}

BOOL OnlineClient::OnPlayerlogoff(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* lpNtfPlayerLogoff = RequestDataParse<NTF_PLAYERLOGOFF>(lpRequest);
	if (lpNtfPlayerLogoff) {
		evPlayerLogoff(*lpNtfPlayerLogoff);
	}
	return TRUE;
}
