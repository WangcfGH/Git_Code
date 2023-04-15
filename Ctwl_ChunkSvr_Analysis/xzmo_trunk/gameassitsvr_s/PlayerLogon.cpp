#include "stdafx.h"
#include "PlayerLogon.h"
#include "CommonReq.h"

void PlayerLogon::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_NTF_MYPLAYERLOGON, OnNTFLogon);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, UR_SOCKET_CLOSE, OnCloseSocket);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, UR_SOCKET_ERROR, OnCloseSocket);
    }
}

void PlayerLogon::OnShutDown()
{
    
}

void PlayerLogon::NotifyAllLogin(int requestid, void* data, int size)
{
	std::vector<std::pair<int, NtfServerLogon>> userLogons;
	async<void>([&userLogons, this](){
		std::copy(m_user2sock.begin(), m_user2sock.end(), std::back_inserter(userLogons));
	}).get();
	for (auto& it : userLogons)
	{
		imNotifyOneUser(it.second.sock, it.second.lToken, requestid, data, size);
	}
}

void PlayerLogon::OnNTFLogon(LPCONTEXT_HEAD lpContext, LPREQUEST pRequest)
{
    SOCKET sock = lpContext->hSocket;
    LONG   token = lpContext->lTokenID;

	NtfServerLogon* pLogin = RequestDataParse<NtfServerLogon>(pRequest, false);
	NtfServerLogon login = { 0 };
	login.nUserID = pLogin->nUserID;
	login.nGameID = pLogin->nGameID;
	if (login.nUserID > 0) {
		login.lToken = lpContext->lTokenID;
		login.sock = lpContext->hSocket;
		login.nStatus = pLogin->nStatus;
		async<void>([this, &login, lpContext](){
			m_user2sock[login.nUserID] = login;
			m_token2user[login.lToken] = login.nUserID;
		}).get();

		evUserLogin(login);
	}
}

void PlayerLogon::OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST)
{
	auto token = lpContext->lTokenID;
	auto sock = lpContext->hSocket;
	strand().dispatch([this,token, sock](){
		auto it = m_token2user.find(token);
		if (it != m_token2user.end()) {
			m_user2sock.erase(it->second);
			m_token2user.erase(it);
		}
	});
}
