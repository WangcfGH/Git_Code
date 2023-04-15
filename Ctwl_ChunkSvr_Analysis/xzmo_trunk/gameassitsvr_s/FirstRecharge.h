#pragma once
#include "plana/event/Event.h"

#define SOAP_INDEX_OF_FIRST_RECHARGE	0
#define GR_GET_FIRSTRECHARGE_AWARD     402191   // Ê×³åÁìÈ¡½±Àø

class TcyMsgCenter;
class FirstRecharge
{
public:
    FirstRecharge(int gameid) {
        m_gameid = gameid;
    }

    void OnAsisstStart(BOOL& ret, TcyMsgCenter* msgCenter);

	void OnFirstRechargeAward(LPCONTEXT_HEAD, LPREQUEST);

    CString complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient);

	ImportFunctional<void(int, std::function<void(LPSOAP_SERVICE, IXYSoapClientPtr&)>)> imDoSoap;
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
	ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> imNotifyOneUser;

private:
    int m_gameid;
};