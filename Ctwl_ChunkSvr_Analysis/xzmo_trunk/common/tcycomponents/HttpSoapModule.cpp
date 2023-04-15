#include "StdAfx.h"
#include "HttpSoapModule.h"
#include "TcyMsgCenter.h"
#include <cassert>

using namespace plana::threadpools;

struct SopaThreadEntry : public ThreadEntryBase
{
    SopaThreadEntry(LPSOAP_SERVICE pSoapService)
    {
        this->pSoapService = pSoapService;
    }
    ~SopaThreadEntry()
    {
    }
    virtual void enterThread() override
    {
        ::CoInitialize(NULL);
        if (S_OK != pSoapClient.CreateInstance(__uuidof(XYSoapClient)))
        {
            UwlTrace(_T("CreateInstance of XYSoapClient failed."));
            UwlLogFile(_T("CreateInstance of XYSoapClient failed."));
            throw std::exception("CreateInstance of XYSoapClient failed.");
        }
        try
        {
            pSoapClient->SetSoapToolkitVersion(_bstr_t(pSoapService->szSoapVersion));
            _bstr_t sWSDL = _bstr_t(pSoapService->szWsdlUrl);
            _bstr_t sEmpty = L"";
            _variant_t  var = true;
            pSoapClient->SetClientProperty(L"ServerHTTPRequest", var);
            DWORD t1 = GetTickCount();
            BOOL bRet = pSoapClient->InitService(sWSDL, sEmpty, sEmpty, sEmpty);
            DWORD t2 = GetTickCount();

            if (bRet)
            {
                UwlLogFile(_T("========InitSoap[%s] Succeed!cost time: %dms"), pSoapService->szSoapWhat, t2 - t1);
            }
            else
            {
                UwlLogFile(_T("========InitSoap[%s] Failed!cost time: %dms"), pSoapService->szSoapWhat, t2 - t1);
            }
        }
        catch (...)
        {
            UwlTrace(_T("Soap error: %s"), (LPCTSTR)(pSoapClient->GetLastError()));
            UwlLogFile(_T("Soap error: %s"), (LPCTSTR)(pSoapClient->GetLastError()));
            throw;
        }
    }
    virtual void leaveThread() override
    {
        pSoapClient.Release();
        ::CoUninitialize();
    }
    IXYSoapClientPtr pSoapClient = nullptr;
    LPSOAP_SERVICE pSoapService = nullptr;
};

class SoapThread : public plana::threadpools::EventPools
{
    friend class HttpSoapModule;
public:
    LPSOAP_SERVICE pSoapService = nullptr;
    virtual std::shared_ptr<ThreadEntryBase> createThreadEntry();
};

std::shared_ptr<ThreadEntryBase> SoapThread::createThreadEntry()
{
    try
    {
        auto entry = std::make_shared<SopaThreadEntry>(pSoapService);
        return entry;
    }
    catch (...)
    {
        return nullptr;
    }
}

static int  xyRetrieveFields_Ref(TCHAR* buf, TCHAR** fields, int maxfields, TCHAR** buf2)
{
    if (buf == NULL)
    {
        return 0;
    }

    TCHAR* p;
    p = buf;
    int count = 0;

    try
    {
        while (1)
        {
            fields[count++] = p;
            while (*p != '|' && *p != '\0')
            {
                p++;
            }
            if (*p == '\0' || count >= maxfields)
            {
                break;
            }
            *p = '\0';
            p++;
        }
    }
    catch (...)
    {
        buf2 = NULL;
        return 0;
    }

    if (*p == '\0')
    {
        *buf2 = NULL;
    }
    else
    {
        *buf2 = p + 1;
    }
    *p = '\0';

    return count;
}


void HttpSoapModule::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (!ret)
    {
        return;
    }

    // 读取本地配置
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, m_szIniFile);
    lstrcat(m_szIniFile, PRODUCT_NAME);
    lstrcat(m_szIniFile, _T(".ini"));

    TCHAR szKey[32];
    TCHAR szValue[512];
    TCHAR* p1, *p2;
    TCHAR* fields[32];
    memset(fields, 0, sizeof(fields));
    memset(szKey, 0, sizeof(szKey));
    memset(szValue, 0, sizeof(szValue));

    SOAP_SERVICE ss[MAX_SOAPSERVICE_COUNT];
    ZeroMemory(&ss, sizeof(ss));
    int nCount = GetPrivateProfileInt(_T("SoapService"), _T("count"), 0, m_szIniFile);
    for (int i = 0; i < nCount; i++)
    {
        sprintf_s(szKey, _T("SS%d"), i);
        GetPrivateProfileString(_T("SoapService"), szKey, _T(""), szValue, sizeof(szValue), m_szIniFile);

        p1 = szValue;
        xyRetrieveFields_Ref(p1, fields, 8, &p2);
        ss[i].nID = atoi(fields[0]);
        lstrcpy(ss[i].szSoapWhat, fields[1]);
        lstrcpy(ss[i].szSoapVersion, fields[2]);
        lstrcpy(ss[i].szWsdlUrl, fields[3]);
        ss[i].nActID = atoi(fields[4]);
        lstrcpy(ss[i].szAuthUser, fields[5]);
        lstrcpy(ss[i].szAuthPassword, fields[6]);
    }
    memcpy(m_SoapService, ss, sizeof(SOAP_SERVICE)*nCount);

    // 启动线程
    for (int i = 0; i < nCount; ++i)
    {
        auto one = std::make_shared<SoapThread>();
        one->pSoapService = &m_SoapService[i];
        m_eventPools.push_back(one);
        one->start(1);
    }
    m_eventHttp = std::make_shared<EventPools>();
    m_eventHttp->start(8);
}

void HttpSoapModule::OnShutdown()
{
    // 停止线程
    for (auto one : m_eventPools)
    {
        one->stop();
    }
    m_eventPools.clear();
}

void HttpSoapModule::OnDealSoapMessage(int soapIndex, std::function<void(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient)> op)
{
    assert(soapIndex >= 0 && soapIndex < m_eventPools.size());
    auto one = m_eventPools[soapIndex];
    one->ios().dispatch([op, one]()
    {
        auto* entry = one->getThreadEntryByType<SopaThreadEntry>();
        op(entry->pSoapService, entry->pSoapClient);
    });
}

void HttpSoapModule::OnHttpDeal(std::function<void(CHttpClient&)> op)
{
    m_eventHttp->ios().dispatch([op]()
    {
        CHttpClient client;
        op(client);
    });
}

