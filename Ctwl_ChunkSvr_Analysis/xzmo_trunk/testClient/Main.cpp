// AssitSvr.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "plana.h"
#include "Predefine.h"
#include "tcycomponents/DumpUnhandleException.h"
#include "TestSockClient.h"
#include "SocketClientManager.h"
#include "TestTask.h"
#include "TestMsgRsp.h"
#include "CaseVsUOMap.h"
#include <string>
using namespace std;
/////////////////////////////////////////////////////////////////////////////
// The one and only application object
CWinApp theApp;

using namespace plana::entitys;
using namespace plana::events;

SingleEventNoMutex<const std::string&> testEvent;

void initComponent()
{
	//////////////////////////////////////////////////////////////////////////
	// 设置异常处理回调
	GetEntity().assign<DumpUnhandleException>();

	// 注册全局的配置信息
	std::weak_ptr<CPredefine> wpreDefine = GetEntity().share_assign<CPredefine>();
	auto spreDefine = wpreDefine.lock();
	spreDefine->init();

    int ret = TRUE;
    // 创建测试manager
    auto clientManager = GetEntity().assign<SocketClientManager>();
    clientManager->evGetIniInt += delegate(wpreDefine, &CPredefine::getInitDataInt);

    // 创建任务测试模块
    auto test_task = GetEntity().assign<TestTask>();
    test_task->evDoSendMsg += delegate(clientManager, &SocketClientManager::SendMsg);
    test_task->evSendMsgRandom += delegate(clientManager, &SocketClientManager::SendMsgRandom);
    testEvent += delegate(test_task, &TestTask::OnTest);
    clientManager->evSvrStart += delegate(test_task, &TestTask::OnServerStart);

	auto test_other_thread = GetEntity().assign<TestMsgRsp>();
	test_other_thread->evSendMsgRandom += delegate(clientManager, &SocketClientManager::SendMsgRandom);
	testEvent += delegate(test_other_thread, &TestMsgRsp::OnTest);
	clientManager->evSvrStart += delegate(test_other_thread, &TestMsgRsp::OnServerStart);

	auto caseVsUomap = GetEntity().assign<CaseVsUOMap>();
	testEvent += delegate(caseVsUomap, &CaseVsUOMap::OnTest);

    clientManager->Initialize();
}

int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
    DWORD dwTraceMode = UWL_TRACE_DATETIME | UWL_TRACE_FILELINE | UWL_TRACE_NOTFULLPATH
        | UWL_TRACE_FORCERETURN | UWL_TRACE_CONSOLE;
    //UwlBeginTrace(PRODUCT_NAME, dwTraceMode);
    if (!XygInitNoRes(PRODUCT_NAME, dwTraceMode))
    {
        return 0;
    }
	plana::threadpools::EventPools::Init();
    initComponent();

    UwlTrace("Type 'q' when you want to exit. ");
    std::string cmd;
    do
    {
        cmd.clear();
        std::getline(std::cin, cmd);
        if (!cmd.empty()) {
            testEvent.notify(cmd);
        }
    } while (cmd != "quit");

    auto test = GetEntity().component<SocketClientManager>();
    test->Shutdown();

    XygTermNoRes();
    //UwlEndTrace();
	plana::threadpools::EventPools::Uinit();
	plana::entitys::Uinit();
    return 1;
}

HINSTANCE XygInit(LPCTSTR lpszAppTitle, DWORD dwTraceMode, BOOL bNoResDll)
{
    // 初始化 MFC 并在失败时显示错误
    if (!AfxWinInit(::GetModuleHandle(NULL), NULL, ::GetCommandLine(), 0))
    {
        // TODO: 更改错误代码以符合您的需要
        MessageBox(NULL, _T("Fatal error: MFC initialization failed!\n"), lpszAppTitle, MB_ICONSTOP);
        return NULL;
    }
    if (!UwlInit())
    {
        // TODO: 更改错误代码以符合您的需要
        MessageBox(NULL, _T("Fatal error: UWL initialization failed!\n"), lpszAppTitle, MB_ICONSTOP);
        return NULL;
    }
    UwlBeginTrace((TCHAR*)AfxGetAppName(), dwTraceMode);
    UwlBeginLog((TCHAR*)AfxGetAppName());

    if (!AfxSocketInit())
    {
        MessageBox(NULL, _T("Fatal error: Failed to initialize sockets!\n"), lpszAppTitle, MB_ICONSTOP);
        return NULL;
    }
    if (!bNoResDll)
    {
        TCHAR szResDllName[MAX_PATH];
        lstrcpy(szResDllName, lpszAppTitle);
        lstrcat(szResDllName, RESOURCE_DLL_EXT);

        HINSTANCE hResDll = AfxLoadLibrary(szResDllName);
        if (!hResDll)
        {
            MessageBox(NULL, _T("Fatal error: Can not load resource dll!\n"), lpszAppTitle, MB_ICONSTOP);
            return NULL;
        }
        AfxSetResourceHandle(hResDll);
        return hResDll;
    }
    else
    {
        return (HINSTANCE)1;
    }
}

void XygTerm(HINSTANCE hResDll, BOOL bNoResDll)
{
    if (!bNoResDll)
    {
        if (hResDll)
        {
            AfxFreeLibrary(hResDll);
        }
    }
    UwlEndLog();
    UwlEndTrace();
    UwlTerm();
}

int XygInitNoRes(LPCTSTR lpszAppTitle, DWORD dwTraceMode)
{
    return (int)XygInit(lpszAppTitle, dwTraceMode, TRUE);
}

void XygTermNoRes()
{
    XygTerm(NULL, TRUE);
}

const DWORD dwWaitFinished = 5000; // time to wait for threads to finish up

CAssitService::CAssitService(const TCHAR* szServiceName, const TCHAR* szDisplayName,
    const int iMajorVersion, const int iMinorVersion,
    const TCHAR* szLicenseFile,
    const TCHAR* szProductName,
    const TCHAR* szProductVer,
    const int nListenPort, const int nGameID,
    DWORD flagEncrypt, DWORD flagCompress)
    : CNTService(szServiceName, szDisplayName, iMajorVersion, iMinorVersion)
{
    m_iStartParam = 0;
    m_iIncParam = 1;
    m_iState = m_iStartParam;

    lstrcpy(m_szLicenseFile, szLicenseFile);
    lstrcpy(m_szProductName, szProductName);
    lstrcpy(m_szProductVer, szProductVer);
    m_nListenPort = nListenPort;
    m_nGameID = nGameID;
    m_flagEncrypt = flagEncrypt;
    m_flagCompress = flagCompress;
}

CAssitService::~CAssitService()
{

}

BOOL CAssitService::OnInit()
{
    // Read the registry parameters
    // Try opening the registry key:
    // HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<AppName>\Parameters
    HKEY hkey;
    TCHAR szKey[1024];
    _tcscpy(szKey, _T("SYSTEM\\CurrentControlSet\\Services\\"));
    _tcscat(szKey, m_szServiceName);
    _tcscat(szKey, _T("\\Parameters"));
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,
            szKey,
            0,
            KEY_QUERY_VALUE,
            &hkey) == ERROR_SUCCESS)
    {
        // Yes we are installed
        DWORD dwType = 0;
        DWORD dwSize = sizeof(m_iStartParam);
        RegQueryValueEx(hkey,
            _T("Start"),
            NULL,
            &dwType,
            (BYTE*)&m_iStartParam,
            &dwSize);
        dwSize = sizeof(m_iIncParam);
        RegQueryValueEx(hkey,
            _T("Inc"),
            NULL,
            &dwType,
            (BYTE*)&m_iIncParam,
            &dwSize);
        RegCloseKey(hkey);
    }

    // Set the initial state
    m_iState = m_iStartParam;

    return TRUE;
}

void CAssitService::Run()
{
    //m_dwThreadId = GetCurrentThreadId();

    //m_pMainServer = OnNewServer();
    //if (FALSE == m_pMainServer->Initialize())
    //{
    //    UwlTrace(_T("server initialize failed!"));
    //    PostQuitMessage(0);
    //}

    //MSG msg;
    //while (GetMessage(&msg, 0, 0, 0))
    //{
    //    DispatchMessage(&msg);
    //}

    //m_pMainServer->Shutdown();

    //SAFE_DELETE(m_pMainServer);

    //// Sleep for a while
    //UwlTrace(_T("service is sleeping to finish(%lu)..."), m_iState);
    //Sleep(dwWaitFinished); //wait for any threads to finish

    //// Update the current state
    //m_iState += m_iIncParam;

}

// Called when the service control manager wants to stop the service
void CAssitService::OnStop()
{
    UwlTrace(_T("CAssitService::OnStop()"));

    PostThreadMessage(m_dwThreadId, WM_QUIT, 0, 0);
}

// Process user control requests
BOOL CAssitService::OnUserControl(DWORD dwOpcode)
{
    switch (dwOpcode)
    {
    case SERVICE_CONTROL_USER + 0:

        // Save the current status in the registry
        SaveStatus();
        return TRUE;

    default:
        break;
    }
    return FALSE; // say not handled
}

// Save the current status in the registry
void CAssitService::SaveStatus()
{
    UwlTrace(_T("Saving current status"));
    // Try opening the registry key:
    // HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<AppName>\...
    HKEY hkey = NULL;
    TCHAR szKey[1024];
    _tcscpy(szKey, _T("SYSTEM\\CurrentControlSet\\Services\\"));
    _tcscat(szKey, m_szServiceName);
    _tcscat(szKey, _T("\\Status"));
    DWORD dwDisp;
    DWORD dwErr;
    UwlTrace(_T("Creating key: %s"), szKey);
    dwErr = RegCreateKeyEx(HKEY_LOCAL_MACHINE,
            szKey,
            0,
            _T(""),
            REG_OPTION_NON_VOLATILE,
            KEY_WRITE,
            NULL,
            &hkey,
            &dwDisp);
    if (dwErr != ERROR_SUCCESS)
    {
        UwlTrace(_T("Failed to create Status key (%lu)"), dwErr);
        return;
    }

    // Set the registry values
    UwlTrace(_T("Saving 'Current' as %ld"), m_iState);
    RegSetValueEx(hkey,
        _T("Current"),
        0,
        REG_DWORD,
        (BYTE*)&m_iState,
        sizeof(m_iState));


    // Finished with key
    RegCloseKey(hkey);
}

//CAssitServer* CAssitService::OnNewServer()
//{
//    CAssitServer* pMainServer = new CAssitServer(m_szLicenseFile, m_szProductName, m_szProductVer,
//        m_nListenPort, m_nGameID,
//        m_flagEncrypt, m_flagCompress);
//    return pMainServer;
//}


