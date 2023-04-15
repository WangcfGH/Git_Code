// AssitSvr.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "Main.h"
#include "MainServer.h"
#include "ChunkSockClient.h"
#include "tcycomponents/HttpSoapModule.h"
#include "plana.h"
#include "tcycomponents/DumpUnhandleException.h"
#include "FirstRecharge.h"
#include "TreasureModule.h"
#include "tcycomponents/DingTalkRobot.h"
#include "ChunkLogSockClient.h"
#include "UserRecordData.h"
#include "TaskModule.h"
#include <SvrInOut.h>
#include "WxTaskModule.h"
#include "PlayerLogon.h"
#include "BroadcastModule.h"
#include "tcycomponents/TcyInputTest.h"
#include "LimitConfig.h"
#include "TestPbModule.h"
using namespace std;
/////////////////////////////////////////////////////////////////////////////
// The one and only application object
CWinApp theApp;

class TestOtherThreadRsp
{
public:
	ImportFunctional <void(int, std::function<void(LPSOAP_SERVICE, IXYSoapClientPtr&)>)  >
		evSoap;
	ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> evNotifyOneUser;
	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter) {
		if (ret) {
			AUTO_REGISTER_MSG_OPERATOR(msgCenter, 1010105, OnTest);
		}
	}
	void OnTest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
		auto tcyMsg = MoveTcyMsgHead(lpRequest, lpContext);
		evSoap(0, [this, tcyMsg](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
			evNotifyOneUser(tcyMsg->context.hSocket, tcyMsg->context.lTokenID, tcyMsg->requst.head.nRequest,
				tcyMsg->requst.pDataPtr, tcyMsg->requst.nDataLen);
		});
	}
};

class TestOtherThreadRsp_o
{
public:
	ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> evNotifyOneUser;
	
	UINT m_threadID;
	HANDLE m_hThread;

	static unsigned __stdcall OnThreadWait(LPVOID lpVoid)
	{
		TestOtherThreadRsp_o* p = (TestOtherThreadRsp_o*)(lpVoid);
		MSG msg;
		memset(&msg, 0, sizeof(msg));
		while (GetMessage(&msg, 0, 0, 0))
		{
			if (UM_DATA_TOSEND == msg.message)
			{
				LPCONTEXT_HEAD pContext = LPCONTEXT_HEAD(msg.wParam);
				LPREQUEST pRequest = LPREQUEST(msg.lParam);
				p->evNotifyOneUser(pContext->hSocket, pContext->lTokenID, pRequest->head.nRequest,
					pRequest->pDataPtr, pRequest->nDataLen);
				UwlClearRequest(pRequest);
				SAFE_DELETE(pContext);
				SAFE_DELETE(pRequest);
			}
			else
			{
				DispatchMessage(&msg);
			}
		}

		return 0;
	}

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter) {
		if (ret) {
			AUTO_REGISTER_MSG_OPERATOR(msgCenter, 1010106, OnTest);
			m_hThread = (HANDLE)_beginthreadex(NULL,       // Security
				0,                              // Stack size - use default
				OnThreadWait,                 // Thread fn entry point
				(void*)this,      // Param for thread
				0,                              // Init flag
				&m_threadID);
		}
	}
	void PostSoapReqeust(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
		LPREQUEST pRequest = new REQUEST;
		memcpy(pRequest, lpRequest, sizeof(REQUEST));

		int nDataLen = lpRequest->nDataLen;

		pRequest->pDataPtr = new BYTE[nDataLen];
		memset(pRequest->pDataPtr, 0, nDataLen);
		pRequest->nDataLen = nDataLen;
		memcpy(pRequest->pDataPtr, lpRequest->pDataPtr, lpRequest->nDataLen);

		LPCONTEXT_HEAD pContext = new CONTEXT_HEAD;
		memcpy(pContext, lpContext, sizeof(CONTEXT_HEAD));

		if (!PostThreadMessage(m_threadID, UM_DATA_TOSEND, (WPARAM)pContext, (LPARAM)pRequest))
		{
			UwlClearRequest(pRequest);
			SAFE_DELETE(pRequest);
			SAFE_DELETE(pContext);
			return ;
		}
		else
		{
			return ;
		}
	}
	void OnTest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
		PostSoapReqeust(lpContext, lpRequest);
	}
};

void initComponent(MainServer* mainSvr)
{
	using namespace plana::entitys;
	using namespace plana::events;
	//////////////////////////////////////////////////////////////////////////
	// 设置异常处理回调
	GetEntity().assign<DumpUnhandleException>();

	auto test_input = GetEntity().assign<TcyInputTest>();

	// 注册全局的配置信息
	std::weak_ptr<CPredefine> wpreDefine = GetEntity().share_assign<CPredefine>();
	auto spreDefine = wpreDefine.lock();
	spreDefine->init();

#if (_MSC_VER >= 1800)
	std::string iniFile = spreDefine->getIniFile();
	auto* svrInOut = GetEntity().assign<CSvrInOut>();
	//4表示的assistsvr  现在SvrInOut.h还没有assistsvr的定义  后面在换
	auto ret = svrInOut->Init(iniFile.c_str(), mainSvr, PORT_OF_ASSITSVR, PRODUCT_NAME, 4);
#endif

	// 注册Assist服务器实例
	GetEntity().assign<MainServer*>(mainSvr);
	mainSvr->imGetIniFile = make_function_wrapper(wpreDefine, &CPredefine::getIniFile);

	// 注册soap和http操作的实例
	std::weak_ptr<HttpSoapModule> soap = GetEntity().share_assign<HttpSoapModule>();
	mainSvr->evSvrStart += delegate(soap, &HttpSoapModule::OnServerStart);
	mainSvr->evShutdown += delegate(soap, &HttpSoapModule::OnShutdown);

	// 注册连接chunksvr的client实例
    auto chunkSock = GetEntity().assign<ChunkSockClient>(KEY_HALL, ENCRYPT_AES, 0);
    mainSvr->evSvrStart += delegate(chunkSock, &ChunkSockClient::OnServerStart);
    mainSvr->evShutdown += delegate(chunkSock, &ChunkSockClient::OnShutdown);
	chunkSock->imGetIniFile = make_function_wrapper(wpreDefine, &CPredefine::getIniFile);
    chunkSock->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
    chunkSock->imGetGameID = make_function_wrapper(wpreDefine, &CPredefine::evGetGameID);
    chunkSock->imGetClientID = make_function_wrapper(wpreDefine, &CPredefine::evGetClientID);

    //注册链接chunklog的client实例
    auto chunkLogSock = GetEntity().assign<ChunkLogSockClient>(KEY_HALL, ENCRYPT_AES, 0);
    mainSvr->evSvrStart += delegate(chunkLogSock, &ChunkLogSockClient::OnServerStart);
    mainSvr->evShutdown += delegate(chunkLogSock, &ChunkLogSockClient::OnShutdown);
    chunkLogSock->imGetIniFile = make_function_wrapper(wpreDefine, &CPredefine::getIniFile);
    chunkLogSock->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
    chunkLogSock->imGetGameID = make_function_wrapper(wpreDefine, &CPredefine::evGetGameID);
    chunkLogSock->imGetClientID = make_function_wrapper(wpreDefine, &CPredefine::evGetClientID);

    // 创建钉钉机器人
    auto dingTalkRobot = GetEntity().assign<CDingTalkRobot>();

	// 注册任务活动模块
	auto taskModule = GetEntity().assign<TaskModule>(spreDefine->getGameID());
    mainSvr->evSvrStart += delegate(taskModule, &TaskModule::OnAssistServerStart);
    mainSvr->evShutdown += delegate(taskModule, &TaskModule::OnShutdown);
    chunkSock->evClientStart += delegate(taskModule, &TaskModule::OnChunkClientStart);
	taskModule->imMsgToChunk = make_function_wrapper(chunkSock, &ChunkSockClient::DoSendMsg);
    taskModule->imNotifyOneWithParseContext = make_function_wrapper(mainSvr, &MainServer::NotifyOneWithParseContext);
    taskModule->imNotifyOneUserErrorInfo = make_function_wrapper(mainSvr, &MainServer::NotifyOneUserErrorInfo);
    taskModule->imDoSoap = make_function_wrapper(soap, &HttpSoapModule::OnDealSoapMessage);
    taskModule->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
    taskModule->imNoticeTextToDingTalkRobot = make_function_wrapper(dingTalkRobot, &CDingTalkRobot::evNoticeTextToDingTalkRobot);
    taskModule->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);

    // 注册微信任务活动模块
    auto wxTaskModule = GetEntity().assign<WxTaskModule>();
    mainSvr->evSvrStart += delegate(wxTaskModule, &WxTaskModule::OnAssistServerStart);
    mainSvr->evShutdown += delegate(wxTaskModule, &WxTaskModule::OnShutdown);
    chunkSock->evClientStart += delegate(wxTaskModule, &WxTaskModule::OnChunkClientStart);
	wxTaskModule->imMsgToChunk = make_function_wrapper(chunkSock, &ChunkSockClient::DoSendMsg);
    wxTaskModule->imNotifyOneWithParseContext = make_function_wrapper(mainSvr, &MainServer::NotifyOneWithParseContext);
    wxTaskModule->imNotifyOneUserErrorInfo = make_function_wrapper(mainSvr, &MainServer::NotifyOneUserErrorInfo);
    wxTaskModule->imDoSoap = make_function_wrapper(soap, &HttpSoapModule::OnDealSoapMessage);
    wxTaskModule->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
    wxTaskModule->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);

    // 首充模块
    auto firstRecharge = GetEntity().assign<FirstRecharge>(spreDefine->getGameID());
    mainSvr->evSvrStart += delegate(firstRecharge, &FirstRecharge::OnAsisstStart);
    firstRecharge->imDoSoap = make_function_wrapper(soap, &HttpSoapModule::OnDealSoapMessage);
    firstRecharge->imGetIniInt = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
    firstRecharge->imNotifyOneUser = make_function_wrapper(mainSvr, &MainServer::NotifyOneUser);

    // 宝箱模块
    auto treasureModule = GetEntity().assign<TreasureModule>();
    mainSvr->evSvrStart += delegate(treasureModule, &TreasureModule::OnAssistServerStart);
    chunkSock->evClientStart += delegate(treasureModule, &TreasureModule::OnChunkClientStart);
	treasureModule->imMsgToChunk = make_function_wrapper(chunkSock, &ChunkSockClient::DoSendMsg);
    treasureModule->imDoHttp = make_function_wrapper(soap, &HttpSoapModule::OnHttpDeal);
	treasureModule->imMsgToChunkLog = make_function_wrapper(chunkLogSock, &TcySockClient::DoSendMsg);
    treasureModule->imNotifyOneWithParseContext = make_function_wrapper(mainSvr, &MainServer::NotifyOneWithParseContext);

    // 移动端数据写入chunklog转发功能
    auto userRecordData = GetEntity().assign<UserRecordData>();
    mainSvr->evSvrStart += delegate(userRecordData, &UserRecordData::OnServerStart);
	userRecordData->imToChunkLog = make_function_wrapper(chunkLogSock, &TcySockClient::DoSendMsg);

	// 玩家登陆的时候会立刻发送一下请求信息
	auto playerLogon = GetEntity().assign<PlayerLogon>();
	mainSvr->evSvrStart += delegate(playerLogon, &PlayerLogon::OnServerStart);
	mainSvr->evShutdown += delegate(playerLogon, &PlayerLogon::OnShutDown);
	playerLogon->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);;
	playerLogon->imNotifyOneUser = make_function_wrapper(mainSvr, &MainServer::NotifyOneUser);

	// 广播模块
	auto broadcastModule = GetEntity().assign<BroadcastModule>();
	mainSvr->evSvrStart += delegate(broadcastModule, &BroadcastModule::OnServerStart);
	mainSvr->evShutdown += delegate(broadcastModule, &BroadcastModule::OnShutdown);
	chunkSock->evClientStart += delegate(broadcastModule, &BroadcastModule::OnChunkClient);
	broadcastModule->imGetIniNumber = make_function_wrapper(wpreDefine, &CPredefine::getInitDataInt);
	broadcastModule->imGetIniStr = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
	broadcastModule->imNotifyOneUser = make_function_wrapper(mainSvr, &MainServer::NotifyOneUser);
	broadcastModule->imNotifyAllMobile = make_function_wrapper(playerLogon, &PlayerLogon::NotifyAllLogin);
	test_input->evInput += delegate(broadcastModule, &BroadcastModule::OnTest);

	// 低保配置获取模块 【游戏不需要的话，可以干掉】
	auto limitConfig = GetEntity().assign<LimitConfig>();
	mainSvr->evSvrStart += delegate(limitConfig, &LimitConfig::OnServerStart);
	mainSvr->evShutdown += delegate(limitConfig, &LimitConfig::OnServerStop);
	limitConfig->imGetIniString = make_function_wrapper(wpreDefine, &CPredefine::getInitDataString);
	limitConfig->imNotifyOneUser = make_function_wrapper(mainSvr, &MainServer::NotifyOneUser);
	playerLogon->evUserLogin += delegate(limitConfig, &LimitConfig::OnUserLogin);

	auto testPbModule = GetEntity().assign<TestPbModule>();
	mainSvr->evSvrStart += delegate(testPbModule, &TestPbModule::OnServerStart);
	testPbModule->imMsgToChunk = make_function_wrapper(chunkSock, &ChunkSockClient::DoSendMsg);
	testPbModule->imSimulatorMsgToLoacl = make_function_wrapper(mainSvr, &MainServer::SimulatorMsgToLoacl);
	chunkSock->evClientStart += delegate(testPbModule, &TestPbModule::OnChunkClient);
	test_input->evInput += delegate(testPbModule, &TestPbModule::OnTest);
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
    MainServer mainServer(KEY_GAMESVR_2_0, ENCRYPT_AES, 0);

    initComponent(&mainServer);

    if (FALSE == mainServer.Initialize())
    {
        UwlTrace(_T("server initialize failed!"));
    }
	
    UwlTrace("Type 'q' when you want to exit. ");
	auto inputTest = plana::entitys::GetEntity().component<TcyInputTest>();
	inputTest->WatchInput();

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
	MainServer* pMainServer = new MainServer(KEY_GAMESVR_2_0, m_flagEncrypt, m_flagCompress);
	return pMainServer;
}


