#pragma once

//KPI 
#define MAX_GAME_CODE_LEN 16
#define MAX_CUID_LEN 36
namespace KPI
{
    typedef struct _tagKPIMBHardInfo{
        TCHAR  ImeiId[MAX_HARDID_LEN];           // imei,15位数字,machineid
        TCHAR  WifiId[MAX_HARDID_LEN];			 // wifi网卡,hardid
        TCHAR  ImsiId[MAX_HARDID_LEN];           // imsi,从SIM卡读取
        TCHAR  SimSerialNo[MAX_HARDID_LEN];      // sim卡序列号,从SIM卡读取
        TCHAR  SystemId[MAX_HARDID_LEN];	     // 系统ID,volumeid
        int   nReserved[32];
    }KPIMBHardInfo, *LPKPIMBHardInfo;

    typedef struct _tagKPI_CLIENT_DATA{
        int   UserId;
        int	  GameId; // 123
        TCHAR GameCode[MAX_GAME_CODE_LEN];        // 游戏缩写 xxxx
        int   ExeMajorVer;   // GameVers string
        int   ExeMinorVer;   // GameVers string
        int   ExeBuildno;    // GameVers string

        // 推荐
        int   RecomGameId;   // 123
        TCHAR RecomGameCode[MAX_GAME_CODE_LEN];   // 游戏缩写 xxxx
        int   RecomExeMajorVer;   // GameVers string
        int   RecomExeMinorVer;   // GameVers string
        int   RecomExeBuildno;    // GameVers string
        int   GroupId;
        int   Channel;
        TCHAR HardId[MAX_HARDID_LEN];
        KPIMBHardInfo MobileHardInfo;
        int   PkgType;		 // 包体类型 [100	移动游戏单包 200	移动电玩城单包 1000 游戏合集包, 300	微信小游戏, 0	pc]
        TCHAR CUID[MAX_CUID_LEN];
        int   nReserved[23];
        DWORD dwRecordTime;
    }KPI_CLIENT_DATA, *LPKPI_CLIENT_DATA;

	static CString GetHttpKPiJson(KPI::LPKPI_CLIENT_DATA pData)
	{
		CString strKpiJson;
		CString clientVersion;
		CString recomGameVers;
		clientVersion.Format("%d.%d.%d", pData->ExeMajorVer, pData->ExeMinorVer, pData->ExeBuildno);
		recomGameVers.Format("%d.%d.%d", pData->RecomExeMajorVer, pData->RecomExeMinorVer, pData->RecomExeBuildno);
		strKpiJson.Format("{\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":\"%s\",\"%s\":{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":\"%s\"},\"%s\":%d,\"%s\":\"%s\"}",
			"GameId", pData->GameId,				// 客户端游戏id
			"GameCode", pData->GameCode,			// 客户端游戏缩写
			"GameVers", clientVersion,				// 客户端游戏版本
			"RecomGameId", pData->RecomGameId,		// 推荐客户端游戏id
			"RecomGameCode", pData->RecomGameCode,	// 推荐客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
			"RecomGameVers", recomGameVers,			// 推荐客户端游戏版本
			"GroupId", pData->GroupId,              // 客户端大厅组号
			"Channel", pData->Channel,				// 客户端渠道号
			"HardId", pData->HardId,				// 客户端设备号
			"MobileHardInfo",
			"ImeiId", pData->MobileHardInfo.ImeiId,             //
			"WifiId", pData->MobileHardInfo.WifiId,             //
			"ImsiId", pData->MobileHardInfo.ImsiId,             //
			"SimSerialNo", pData->MobileHardInfo.SimSerialNo,   //
			"SystemId", pData->MobileHardInfo.SystemId,         //
			"PkgType", pData->PkgType,                //客户端包体类型(100:移动游戏单包\110:移动游戏平台包\200:移动电玩城单包\1000:游戏合集包\300:微信小游戏\0:pc)
            "CUID", pData->CUID                //cuid
			);

		UwlLogFile(_T("--->%s"), strKpiJson);
		return strKpiJson;
	}

    static CString GetKPiJson(KPI::LPKPI_CLIENT_DATA pData)
    {
        CString strKpiJson;
        CString clientVersion;
        CString recomGameVers;
        clientVersion.Format("%d.%d.%d", pData->ExeMajorVer, pData->ExeMinorVer, pData->ExeBuildno);
        recomGameVers.Format("%d.%d.%d", pData->RecomExeMajorVer, pData->RecomExeMinorVer, pData->RecomExeBuildno);
        strKpiJson.Format("{\\\"%s\\\":%d,\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":%d,\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":%d,\\\"%s\\\":%d,\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":{\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\",\\\"%s\\\":\\\"%s\\\"},\\\"%s\\\":%d,\\\"%s\\\":\\\"%s\\\"}",
            "GameId", pData->GameId,				// 客户端游戏id
            "GameCode", pData->GameCode,			// 客户端游戏缩写
            "GameVers", clientVersion,				// 客户端游戏版本
            "RecomGameId", pData->RecomGameId,		// 推荐客户端游戏id
            "RecomGameCode", pData->RecomGameCode,	// 推荐客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
            "RecomGameVers", recomGameVers,			// 推荐客户端游戏版本
            "GroupId", pData->GroupId,              // 客户端大厅组号
            "Channel", pData->Channel,				// 客户端渠道号
            "HardId", pData->HardId,				// 客户端设备号
            "MobileHardInfo",
            "ImeiId", pData->MobileHardInfo.ImeiId,             //
            "WifiId", pData->MobileHardInfo.WifiId,             //
            "ImsiId", pData->MobileHardInfo.ImsiId,             //
            "SimSerialNo", pData->MobileHardInfo.SimSerialNo,   //
            "SystemId", pData->MobileHardInfo.SystemId,         //
            "PkgType", pData->PkgType,                //客户端包体类型(100:移动游戏单包\110:移动游戏平台包\200:移动电玩城单包\1000:游戏合集包\300:微信小游戏\0:pc)
            "CUID", pData->CUID                //cuid
            );

        UwlLogFile(_T("--->%s"), strKpiJson);
        return strKpiJson;
    }
}