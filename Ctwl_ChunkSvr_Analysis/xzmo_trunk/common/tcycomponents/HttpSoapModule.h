#pragma once
#include "plana.h"
#include <vector>
#include <map>

using plana::threadpools::ThreadEntryBase;

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

/*
    0 ÈÎÎñ
    1 ³é½±
*/

class TcyMsgCenter;
class SoapThread;
class HttpSoapModule
{
public:
    virtual ~HttpSoapModule() {}
    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutdown();

    void OnDealSoapMessage(int soapIndex, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient)> op);
    void OnHttpDeal(std::function<void(CHttpClient&)> op);
protected:

protected:
    TCHAR           m_szIniFile[MAX_PATH];
    SOAP_SERVICE    m_SoapService[MAX_SOAPSERVICE_COUNT];

    std::vector<std::shared_ptr<SoapThread>> m_eventPools;
    plana::threadpools::EventPools::Ptr     m_eventHttp;
};