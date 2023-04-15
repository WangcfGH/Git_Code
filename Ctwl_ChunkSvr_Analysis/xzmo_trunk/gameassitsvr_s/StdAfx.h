#pragma once
#pragma warning(disable : 4786)
#pragma warning(disable : 4996)

// 系统、Tcy环境依赖
#include <afxinet.h >
#include <TcyCommon.h>
#include <GameDef.h>
#include <xyapi.h>
#include <TcyReq.h>
#include <tclog.h>

// 项目全局依赖
#include "..\common\CommonDef.h"
#include "..\common\CommonReq.h"
#include "..\common\HttpClient.h"
#include "..\common\ItemSysHttpTool.h"


// 本项目的公共头文件
#include "AssitDef.h"
#include "AssitReq.h"
#include "Predefine.h"

//////////////////////////////////////////////////////////////////////////
// 提高编译速度，给出需要的预编译模块
#include "tcycomponents/TcyMsgCenter.h"
#include "tcycomponents/TcySockClient.h"
#include "tcycomponents/TcySockSvr.h"
#include "plana/plana.h"