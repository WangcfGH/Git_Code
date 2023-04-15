// AssitSvr.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "Main.h"
#include "MainServer.h"
#include "plana.h"
#include "tcycomponents/DumpUnhandleException.h"
#include "tcycomponents/MySvrInOut.h"
#include "TaskModule.h"
#include "WxTaskModule.h"
#include "TreasureModule.h"
#include "PlayerInfoModule.h"
#include "GameDBConnectPool.h"
#include "tcycomponents/TcyInputTest.h"
#include "SimpleSubClient.h"
#include "PlayerLogon.h"
#include "RobotPlayerData.h"
#include "dbconnectpool/TcySqlSvrConnect.h"
#include "BroadToMobile.h"
#include "TestPbModule.h"

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// The one and only application object
CWinApp theApp;
void initComponent(MainServer* mainSvr)
{
	using namespace plana::entitys;
	using namespace plana::events;
	//////////////////////////////////////////////////////////////////////////
	// 设置异常处理回调
	GetEntity().assign<DumpUnhandleException>();

	// 注册全局的配置信息
	std::weak_ptr<CPredefine> wpreDefine = GetEntity().share_assign<CPredefine>();
	auto spreDefine = wpreDefine.lock();
	spreDefine->init();

	auto* tcyInputTest = GetEntity().assign<TcyInputTest>();

	GetEntity().assign<MainServer*>(mainSvr);
	mainSvr->imGetIniFile = make_function_wrapper(spreDefine, &CPredefine::getIniFile);
	mainSvr->imGetGameID = make_function_wrapper(wpreDefine, &CPredefine::getGameID);

    // GameDB
	auto gameDbPool =  GetEntity().share_assign<GameDBConnectPool>(8);
    std::weak_ptr<GameDBConnectPool> wGameDbPool = gameDbPool;
    mainSvr->evSvrStart += delegate(wGameDbPool, &GameDBConnectPool::OnServerStart);
    mainSvr->evShutdown += delegate(wGameDbPool, &GameDBConnectPool::OnServerStop);
	gameDbPool->imIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
	gameDbPool->imIniStr = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);

    // onlie 客户端，监听移动端玩家的登陆情况
    auto onlineClient = GetEntity().assign<OnlineClient>(KEY_HALL, ENCRYPT_AES, 0);
    mainSvr->evSvrStart += delegate(onlineClient, &OnlineClient::OnServerStart);
    mainSvr->evShutdown += delegate(onlineClient, &OnlineClient::Shutdown);
    onlineClient->imGetGameID = make_function_wrapper(wpreDefine, &CPredefine::getGameID);
    onlineClient->imGetClientID = make_function_wrapper(wpreDefine, &CPredefine::getClientID);
    onlineClient->imGetConfigInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
    onlineClient->imGetConfigStr = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);


#if (_MSC_VER >= 1800)
	std::string iniFile = spreDefine->getIniFile();
    auto* svrInOut = GetEntity().assign<CMySvrInOut>(iniFile, mainSvr);
    mainSvr->evSvrStart += delegate(svrInOut, &CMySvrInOut::OnServerStart);
#endif

    // 注册任务模块
    auto taskModule = GetEntity().assign<TaskModule>();
    mainSvr->evSvrStart += delegate(taskModule, &TaskModule::OnServerStart);
    taskModule->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
    taskModule->imSendOpeReqOnlyCxt = make_function_wrapper(mainSvr, &MainServer::SendOpeReqOnlyCxtForModule);
    taskModule->imDBOpera = make_function_wrapper(wGameDbPool, &GameDBConnectPool::dbInvokeByStrand<int, DBConnectEntry>);
    tcyInputTest->evInput += delegate(taskModule, &TaskModule::OnTest);
    taskModule->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);

    // 注册微信任务模块
    auto wxTaskModule = GetEntity().assign<WxTaskModule>();
    mainSvr->evSvrStart += delegate(wxTaskModule, &WxTaskModule::OnServerStart);
    wxTaskModule->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
    wxTaskModule->imSendOpeReqOnlyCxt = make_function_wrapper(mainSvr, &MainServer::SendOpeReqOnlyCxtForModule);
	wxTaskModule->imDBOpera = make_function_wrapper(wGameDbPool, &GameDBConnectPool::dbInvokeByStrand<int, DBConnectEntry>);
    wxTaskModule->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
   
    // 注册宝箱模块
    auto treasureModule = GetEntity().assign<TreasureModule>();
    mainSvr->evSvrStart += delegate(treasureModule, &TreasureModule::OnServerStart);
    treasureModule->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
    treasureModule->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
	treasureModule->imDBOpera = make_function_wrapper(wGameDbPool, &GameDBConnectPool::dbInvokeByStrand<void, DBConnectEntry>);
	tcyInputTest->evInput += delegate(treasureModule, &TreasureModule::OnInputTest);


    // 注册用户信息模块
    auto personalInfo = GetEntity().assign<PlayerInfoModule>();
    mainSvr->evSvrStart += delegate(personalInfo, &PlayerInfoModule::OnServerStart);
    personalInfo->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
	personalInfo->imDBOpera = make_function_wrapper(wGameDbPool, &GameDBConnectPool::dbInvokeByStrand<int, DBConnectEntry>);
	tcyInputTest->evInput += delegate(personalInfo, &PlayerInfoModule::OnInputTest);

    // 用户登录以及广播
    auto playerLogon = GetEntity().assign<PlayerLogon>();
    mainSvr->evSvrStart += delegate(playerLogon, &PlayerLogon::OnServerStart);
    playerLogon->imGetAssistSvrSocket = make_function_wrapper(mainSvr, &MainServer::GetAssistSvrSocket);
    playerLogon->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
    onlineClient->evPlayerLogin += delegate(playerLogon, &PlayerLogon::OnNTFPlayerLogon);
    onlineClient->evPlayerLogoff += delegate(playerLogon, &PlayerLogon::OnNTFPlayerLogoff);
	
    auto robotPlayerData = GetEntity().assign<RobotPlayerData>();
    mainSvr->evSvrStart += delegate(robotPlayerData, &RobotPlayerData::OnServerStart);
    robotPlayerData->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
    robotPlayerData->imSendOpeResponse = make_function_wrapper(mainSvr, &MainServer::SendOpeResponseForModule);
	robotPlayerData->imDBOpera = make_function_wrapper(wGameDbPool, &DBConnectPool::dbInvokeByStrand<int, DBConnectEntry>);
    robotPlayerData->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
    robotPlayerData->imGetRoomSvrSock = make_function_wrapper(mainSvr, &MainServer::GetRoomSvrSocket);


	// 从其他服务发的广播转assist到游戏移动端
	auto broadToMobile = GetEntity().assign<BroadToMobile>();
	mainSvr->evSvrStart += delegate(broadToMobile, &BroadToMobile::OnServerStart);
	broadToMobile->imGetAssistSvrSocket = make_function_wrapper(mainSvr, &MainServer::GetAssistSvrSocket);
	broadToMobile->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);


	auto testPbModule = GetEntity().assign<TestPbModule>();
	mainSvr->evSvrStart += delegate(testPbModule, &TestPbModule::OnServerStart);
	testPbModule->imSendOpeRequest = make_function_wrapper(mainSvr, &MainServer::SendOpeRequestForModule);
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
	MysqlConnector::init();
	plana::threadpools::EventPools::Init();
    TCLOG_INIT();
#ifdef UWL_SERVICE
    CString sDisplayName;
    BOOL bChinese = (GetUserDefaultLangID() == 0x804);
    sDisplayName = (bChinese ? STR_DISPLAY_NAME : STR_DISPLAY_NAME_ENU);

    CAssitService MainService(STR_SERVICE_NAME, sDisplayName, 2, 0,
        PRODUCT_LICENSE, PRODUCT_NAME, PRODUCT_VERSION,
        PORT_OF_ASSITSVR, GAME_ID, ENCRYPT_AES, 0);

    if (!MainService.ParseStandardArgs(argc, argv))
    {
        // Didn't find any standard args so start the service
        // Uncomment the DebugBreak line below to enter the debugger when the service is started.
        //DebugBreak();
        MainService.StartService();
    }
    // When we get here, the service has been stopped
    int nRetCode = MainService.m_Status.dwWin32ExitCode;
#else
    MainServer mainServer(KEY_HALL, ENCRYPT_AES, 0);

    initComponent(&mainServer);

    if (FALSE == mainServer.Initialize())
    {
        UwlTrace(_T("server initialize failed!"));
    }
	
    UwlTrace("Type 'q' when you want to exit. ");
	
	auto* tcyInputTest = plana::entitys::GetEntity().component<TcyInputTest>();
	tcyInputTest->WatchInput();
    mainServer.Shutdown();

#endif

	
    XygTermNoRes();
    //UwlEndTrace();
	plana::threadpools::EventPools::Uinit();
	plana::entitys::Uinit();
    TCLOG_UNINT();
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
	m_pMainServer = nullptr;
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
    m_dwThreadId = GetCurrentThreadId();

    m_pMainServer = OnNewServer();
	initComponent(m_pMainServer);
    if (FALSE == m_pMainServer->Initialize())
    {
        UwlTrace(_T("server initialize failed!"));
        PostQuitMessage(0);
    }

    MSG msg;
    while (GetMessage(&msg, 0, 0, 0))
    {
        DispatchMessage(&msg);
    }

    m_pMainServer->Shutdown();

    SAFE_DELETE(m_pMainServer);

    // Sleep for a while
    UwlTrace(_T("service is sleeping to finish(%lu)..."), m_iState);
    Sleep(dwWaitFinished); //wait for any threads to finish

    // Update the current state
    m_iState += m_iIncParam;

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

MainServer* CAssitService::OnNewServer()
{
    MainServer* pMainServer = new MainServer(KEY_HALL, m_flagEncrypt, m_flagCompress);
	return pMainServer;
}


