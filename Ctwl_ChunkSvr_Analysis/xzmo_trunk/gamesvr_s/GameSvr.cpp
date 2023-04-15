//  limkSvr.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "gameSvr.h"
#include "plana.h"
#include "tcycomponents/DumpUnhandleException.h"
#include "tcycomponents/TcyInputTest.h"
#include "GameToChunkClient.h"
#include "GameToChunklogClient.h"
#include "siphash.h"
#include "my/MyPlayerInfoDelegate.h"
#include "my/MyTaskDelegate.h"
#include "my/MyWxTaskDelegate.h"
#include "commonBase/RobotPlayerDataDelegate.h"
#include "GameLogData.h"
#include "commonbase\TreasureDelegate.h"
#include "my/ResultRestore.h"
#include "DataRecord.h"
#include "my\MyWxTaskDelegate.h"
#include "..\common\mj\GameHuUnitsMaker.h"

#ifdef _DEBUG
    #define new DEBUG_NEW
    //#undef THIS_FILE
    //static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// The one and only application object

CWinApp theApp;

using namespace std;

void initComponent(CMyGameServer* mainSvr)
{
    using namespace plana::events;
    using namespace plana::entitys;

    // 设置异常dump模块
    GetEntity().assign<DumpUnhandleException>();

    // 设置test模块
    auto tcyInputTest = GetEntity().assign<TcyInputTest>();

    // 注册GameServer
    GetEntity().assign<CMyGameServer*>(mainSvr);

    // 注册全局的配置信息
    auto preDefine = GetEntity().assign<CPredefine>();
    preDefine->init();

    auto gameToChunkClient = GetEntity().assign<GameToChunkClient>(KEY_HALL, ENCRYPT_AES, 0);
    mainSvr->evSvrStart += delegate(gameToChunkClient, &GameToChunkClient::OnServerStart);
    mainSvr->evShutdown += delegate(gameToChunkClient, &GameToChunkClient::OnShutdown);
    gameToChunkClient->imGetGameID += delegate(preDefine, &CPredefine::evGetGameID);
    gameToChunkClient->imGetIniFile += delegate(preDefine, &CPredefine::evGetIniFile);
    gameToChunkClient->imGetIniString += delegate(preDefine, &CPredefine::getInitDataString);

    auto gameToChunklogClient = GetEntity().assign<GameToChunklogClient>(KEY_HALL, ENCRYPT_AES, 0);
    mainSvr->evSvrStart += delegate(gameToChunklogClient, &GameToChunklogClient::OnServerStart);
    mainSvr->evShutdown += delegate(gameToChunklogClient, &GameToChunklogClient::OnShutdown);
    gameToChunklogClient->imGetGameID += delegate(preDefine, &CPredefine::evGetGameID);
    gameToChunklogClient->imGetIniFile += delegate(preDefine, &CPredefine::evGetIniFile);
    gameToChunklogClient->imGetIniString += delegate(preDefine, &CPredefine::getInitDataString);

    // 消息分发模块
    auto sysMsgToServer = GetEntity().assign<MySysMsgToServer>(mainSvr);
    mainSvr->evSvrStart += delegate(sysMsgToServer, &MySysMsgToServer::OnServerStart);

    typedef CGetTableResult(CMyGameServer::* t_getTablePtr)(int, int, BOOL, int);

    // PlayerInfo 记录玩家血战和血流对局数量
    auto playerInfoData = GetEntity().assign<CMyExPlayerInfoDelegate>();
    gameToChunkClient->evClientStart += delegate(playerInfoData, &CMyExPlayerInfoDelegate::OnChunkClient);
    playerInfoData->imGetTablePtr = make_function_wrapper(mainSvr, (t_getTablePtr)&CMyGameServer::GetTablePtr);
    playerInfoData->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    playerInfoData->imNotifyResponseFaild = make_function_wrapper(mainSvr, &CMyGameServer::NotifyResponseFaild);
    mainSvr->evCPGameStarted += delegate(playerInfoData, &CMyExPlayerInfoDelegate::OnCPGameStarted);
    mainSvr->evCPStartSoloTable += delegate(playerInfoData, &CMyExPlayerInfoDelegate::OnCPStartSoloTable);

    // 任务模块
    auto taskModule = GetEntity().assign<CMyExTaskDelegate>();
    taskModule->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    mainSvr->evCPGameStarted += delegate(taskModule, &CMyExTaskDelegate::OnCPOnGameStarted);
    mainSvr->evCPStartSoloTable += delegate(taskModule, &CMyExTaskDelegate::OnCPStartSoloTable);
    mainSvr->evTaskGang += delegate(taskModule, &CMyExTaskDelegate::OnTaskGang);
    mainSvr->evTaskHu += delegate(taskModule, &CMyExTaskDelegate::OnTaskHu);
    mainSvr->evTaskPeng += delegate(taskModule, &CMyExTaskDelegate::OnTaskPeng);
    mainSvr->evWinDeposit += delegate(taskModule, &CMyExTaskDelegate::OnTaskWinDeposit);
    tcyInputTest->evInput += delegate(taskModule, &CMyExTaskDelegate::onTest);

    // 微信任务模块
    auto wxTaskModule = GetEntity().assign<CMyExWxTaskDelegate>();
    wxTaskModule->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    wxTaskModule->imGetKPIClientData = make_function_wrapper(mainSvr, &CMyGameServer::GetKPIClientData);
    mainSvr->evCPGameStarted += delegate(wxTaskModule, &CMyExWxTaskDelegate::OnCPOnGameStarted);
    mainSvr->evCPStartSoloTable += delegate(wxTaskModule, &CMyExWxTaskDelegate::OnCPStartSoloTable);
    mainSvr->evWinDeposit += delegate(wxTaskModule, &CMyExWxTaskDelegate::OnWxTaskWinDeposit);
    mainSvr->evWxTaskHu += delegate(wxTaskModule, &CMyExWxTaskDelegate::OnWxTaskHu);

    // 埋点模块
    std::string iniFile;
    preDefine->evGetIniFile(iniFile);
    auto gameLogData = GetEntity().share_assign<GameLogData>(iniFile.c_str(), mainSvr);
    mainSvr->evSvrStart += delegate(gameLogData, &GameLogData::OnServerStart);
    mainSvr->evShutdown += delegate(gameLogData, &GameLogData::OnShutDown);
    mainSvr->evNewTable += delegate(gameLogData, &GameLogData::OnNewTable);
    mainSvr->evOnCPGameWin += delegate(gameLogData, &GameLogData::OnCPGameWin);
	mainSvr->evCPGameStarted += delegate(gameLogData, &GameLogData::OnGameStarted);
	mainSvr->evCPStartSoloTable += delegate(gameLogData, &GameLogData::OnStartSoloTable);
	gameLogData->imGetKPIClientData = make_function_wrapper(mainSvr, &CMyGameServer::GetKPIClientData);

    // 胡牌算法模块
    auto maker = GetEntity().assign<GameHuUnitsMaker>();
    mainSvr->evSvrStart += delegate(maker, &GameHuUnitsMaker::OnServerStart);
    mainSvr->evNewTable += delegate(maker, &GameHuUnitsMaker::OnNewTable);

    // 玩家机器人数据模块
    auto robotPlayerData = GetEntity().assign<CRobotPlayerDataDelegate>();
    robotPlayerData->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    mainSvr->evOnCPGameWin += delegate(robotPlayerData, &CRobotPlayerDataDelegate::OnCPGameWin);
    mainSvr->evPreResult += delegate(robotPlayerData, &CRobotPlayerDataDelegate::OnPreResult);

    // 宝箱模块
    auto treasureModule = GetEntity().assign<CTreasureDelegate>();
    treasureModule->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    treasureModule->imNotifyOneUser = make_function_wrapper(mainSvr, &CMyGameServer::NotifyOneUser);
    gameToChunkClient->evClientStart += delegate(treasureModule, &CTreasureDelegate::OnChunkClient);
    mainSvr->evCPGameStarted += delegate(treasureModule, &CTreasureDelegate::OnCPGameStarted);
    mainSvr->evCPStartSoloTable += delegate(treasureModule, &CTreasureDelegate::OnCPStartSoloTable);

    // 结算免赔模块
    auto resultRestoreModule = GetEntity().assign<CResultRestore>();
    resultRestoreModule->imMsg2Chunk = make_function_wrapper(gameToChunkClient, &GameToChunkClient::DoSendMsg);
    mainSvr->evPreResult += delegate(resultRestoreModule, &CResultRestore::OnPreResult);
    mainSvr->evOnGameWin += delegate(resultRestoreModule, &CResultRestore::OnGameWin);

    auto dataRecord = GetEntity().assign<DataRecord>(iniFile.c_str(), mainSvr);
    mainSvr->evSvrStart += delegate(dataRecord, &DataRecord::OnServerStart);
    mainSvr->evOnCPGameWin += delegate(dataRecord, &DataRecord::OnCPGameWin);
    mainSvr->evTransmitGameResultEx += delegate(dataRecord, &DataRecord::OnTransmitGameResultEx);
    mainSvr->evShutdown += delegate(dataRecord, &DataRecord::OnShutDown);
}


int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
    DWORD dwTraceMode = UWL_TRACE_DATETIME | UWL_TRACE_FILELINE | UWL_TRACE_NOTFULLPATH
        | UWL_TRACE_FORCERETURN | UWL_TRACE_DUMPFILE | UWL_TRACE_CONSOLE;
    //UwlBeginTrace(PRODUCT_NAME, dwTraceMode);
    if (!XygInitNoRes(PRODUCT_NAME, dwTraceMode))
    {
        return 0;
    }

    TCLOG_INIT();
    plana::threadpools::EventPools::Init();
    // 如需上传日志则调用此函数
    //TCLOG_SET_SOCKETLOGGER(_T("127.0.0.1"), 30808);
#ifdef UWL_SERVICE
    CString sDisplayName;
    BOOL bChinese = (GetUserDefaultLangID() == 0x804);
    sDisplayName = (bChinese ? STR_DISPLAY_NAME : STR_DISPLAY_NAME_ENU);
    CGameService MainService(STR_SERVICE_NAME, sDisplayName, 2, 0,
        PRODUCT_LICENSE, PRODUCT_NAME, PRODUCT_VERSION,
        PORT_OF_GAMESVR, GAME_ID, ENCRYPT_AES, 0);

    if (!MainService.ParseStandardArgs(argc, argv))
    {
        // Didn't find any standard args so start the service
        // Uncomment the DebugBreak line below to enter the debugger when the service is started.
        //DebugBreak();
        MainService.StartService();
    }
    // When we get here, the service has been stopped
    //int nRetCode = MainService.m_Status.dwWin32ExitCode;
#else
    CMyGameServer mainServer(PRODUCT_LICENSE, PRODUCT_NAME, PRODUCT_VERSION,
        PORT_OF_GAMESVR, GAME_ID, ENCRYPT_AES, 0);
    initComponent(&mainServer);

    if (FALSE == mainServer.Initialize())
    {
        UwlTrace(_T("server initialize failed!"));
    }

    auto tcyInputTest = plana::entitys::GetEntity().component<TcyInputTest>();
    tcyInputTest->WatchInput();
    UwlTrace("Type 'q' when you want to exit. ");
    mainServer.Shutdown();

#endif

    XygTermNoRes();

    UwlEndTrace();
    TCLOG_UNINT();
    return 1;
}


