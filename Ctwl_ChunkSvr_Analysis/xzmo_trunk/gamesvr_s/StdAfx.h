#pragma once

#include <memory>
#include <random>
#include <tcgament2.h>
CString GetINIFilePath();
#define CASE_REQUEST_HANDLE(ReqtType,HandleFun) \
    case ReqtType:{ \
    UwlTrace(_T(#ReqtType)  _T(" requesting[%d]..."), ReqtType); \
    HandleFun(lpContext, lpRequest, pThreadCxt);} \
    break;

#include "..\common\HttpClient.h"
#include "..\common\ModuleReq.h"
#include "..\common\ItemSysHttpTool.h"
#include "..\common\CommonDef.h"
#include "..\common\CommonReq.h"
#include "..\common\MsgRecorder.h"
#include "..\common\TreasureReq.h"
#include "..\common\RobotReq.h"
#include "tclog.h"
#include "game.pb.h"

#include "..\common\commonbase\CommonBaseReq.h"
#include "commonbase\LotteryDelegate.h"
#include "commonbase\TaskDelegate.h"
#include "commonbase\RankMatchDelegate.h"
#include "commonbase\PropDelegate.h"
#include "..\common\commonbase\CommonBaseTable.h"
#include "commonbase\CommonBaseServer.h"

#include "..\common\mj\MjDef.h"
#include "..\common\mj\MjReq.h"
#include "..\common\mj\MJCalclator.h"
#include "..\common\mj\MjTable.h"
#include "mj\MjServer.h"

#include "my\MyPlayerInfoDelegate.h"
#include "..\common\my\MyDef.h"
#include "..\common\my\MyReq.h"
#include "..\common\my\MyTbl.h"
#include "..\common\ExPlayerInfoReq.h"
#include "my\MyServer.h"

#include "..\common\tool\WorkThread.h"
#include "..\common\dataloger\DataLoger.h"

#include "GameLogData.h"
#include "MyRobot.h"
#include "Service.h"
#include "Predefine.h"
#include "MySysMsgToServer.h"

#ifdef _DEBUG
    #define new DEBUG_NEW
#endif