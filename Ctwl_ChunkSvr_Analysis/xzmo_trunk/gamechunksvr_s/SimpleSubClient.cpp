#include "stdafx.h"
#include "SimpleSubClient.h"

void SimpleSubClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		std::string ip;

		std::string server_name = GetRemoteServerName();
		imGetConfigStr(server_name.c_str(), "Name", ip);
		if (ip.empty()) {
			UwlLogFile("Online Ip is Empty");
			return;
		}
		int port = 0;
		imGetConfigInt(server_name.c_str(), "port", port);

		setIpAndPort(ip, port);
		setClientType(CLIENT_TYPE_CHUNK);

		int tmpRet = Create(m_szIp.c_str(), m_nPort, 10, TRUE, GetHelloData(), GetHelloLength() + 1, 1, 10);
		if (tmpRet) {
			tmpRet = Initialize() && SubcribeMsg();
			if (tmpRet) {
				// ԭ�������Ӵ��룬�ͻ��˽����ٽ���ˢ��ʱ����
				m_timerPulse = nullptr;
				RegisterMsgCenter();
				UwlTrace("SimpleSubClient Initialize Success %s:%d", ip.c_str(), port);
				UwlLogFile("SimpleSubClient Initialize Success %s:%d", ip.c_str(), port);
			}
			else {
				UwlTrace("SimpleSubClient Initialize Failed %s,%d", ip.c_str(), port);
				UwlLogFile("SimpleSubClient Initialize Failed %s,%d", ip.c_str(), port);
			}
		}
		else {
			UwlTrace("SimpleSubClient Connect Error %s,%d", ip.c_str(), port);
			UwlLogFile("SimpleSubClient Connect Error %s,%d", ip.c_str(), port);
		}
	}
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

		// �������Ҫ���½���һ�ζ�����Ϣ
		if (ValidateClientInfo() && SubcribeMsg()) {
			m_timerReconnect = nullptr;
		}
	}
}

BOOL OnlineClient::SubcribeMsg()
{
	int nClientID = imGetClientID();
	
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
	rpl.nGameID = imGetGameID();
	rpl.dwFlags = FLAG_PUSHLOGON_MOBILE | FLAG_PUSHLOGON_BYGAMEID;	//ֻ����ָ���ƶ�����Ϸ���û���¼��Ϣ
	//	rpl.dwFlags = FLAG_PUSHLOGON_PC|FLAG_PUSHLOGON_MOBILE|FLAG_PUSHLOGON_ALLAPP; //For test �ɶ��������û���¼��Ϣ

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

void OnlineClient::RegisterMsgCenter()
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


///////
BOOL TrankClient::SubcribeMsg()
{
	int nClientID = imGetClientID();

	REQUEST request;
	memset(&request, 0, sizeof(request));
	REQUEST response;
	memset(&response, 0, sizeof(response));

	CONTEXT_HEAD context;
	context.hSocket = GetSocket();
	context.lSession = 0;
	context.bNeedEcho = 0;

	SS_PAYEVENT sp;
	ZeroMemory(&sp, sizeof(sp));
	sp.nClientID = nClientID;
	sp.nClientType = m_nClientType;
	int nGameID = imGetGameID();
	sp.nGameID = nGameID;
	sp.dwFlags = FLAG_PUSHNOTIFY_BYGAMEID | FLAG_PUSHNOTIFY_PAY;

	request.head.nRequest = GR_SS_PAYEVENT;
	request.nDataLen = sizeof(sp);
	request.pDataPtr = &sp;

	BOOL bTimeout = FALSE;
	BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout);
	if (bSendOK) {
		LOG_INFO(_T("Subscribe pay event OK "));
	}
	return bSendOK;
}

void TrankClient::RegisterMsgCenter()
{
	auto* msgCenter = &m_msgCenter;
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_USER_PAY_RESULT, OnPayResult);
}

BOOL TrankClient::OnPayResult(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* payResult = RequestDataParse<PAY_RESULTEX>(lpRequest);
	if (payResult) {
		LOG_INFO("[TrankClient]:OnPayResult, nUserId: %d, szGameGoodsID: %s", payResult->nUserID, payResult->szGameGoodsID);
		evPayResult(*payResult);
	}
	return 0;
}
