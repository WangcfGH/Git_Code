#pragma once

//KPI 
#define MAX_GAME_CODE_LEN 16
#define MAX_CUID_LEN 36
namespace KPI
{
    typedef struct _tagKPIMBHardInfo{
        TCHAR  ImeiId[MAX_HARDID_LEN];           // imei,15λ����,machineid
        TCHAR  WifiId[MAX_HARDID_LEN];			 // wifi����,hardid
        TCHAR  ImsiId[MAX_HARDID_LEN];           // imsi,��SIM����ȡ
        TCHAR  SimSerialNo[MAX_HARDID_LEN];      // sim�����к�,��SIM����ȡ
        TCHAR  SystemId[MAX_HARDID_LEN];	     // ϵͳID,volumeid
        int   nReserved[32];
    }KPIMBHardInfo, *LPKPIMBHardInfo;

    typedef struct _tagKPI_CLIENT_DATA{
        int   UserId;
        int	  GameId; // 123
        TCHAR GameCode[MAX_GAME_CODE_LEN];        // ��Ϸ��д xxxx
        int   ExeMajorVer;   // GameVers string
        int   ExeMinorVer;   // GameVers string
        int   ExeBuildno;    // GameVers string

        // �Ƽ�
        int   RecomGameId;   // 123
        TCHAR RecomGameCode[MAX_GAME_CODE_LEN];   // ��Ϸ��д xxxx
        int   RecomExeMajorVer;   // GameVers string
        int   RecomExeMinorVer;   // GameVers string
        int   RecomExeBuildno;    // GameVers string
        int   GroupId;
        int   Channel;
        TCHAR HardId[MAX_HARDID_LEN];
        KPIMBHardInfo MobileHardInfo;
        int   PkgType;		 // �������� [100	�ƶ���Ϸ���� 200	�ƶ�����ǵ��� 1000 ��Ϸ�ϼ���, 300	΢��С��Ϸ, 0	pc]
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
			"GameId", pData->GameId,				// �ͻ�����Ϸid
			"GameCode", pData->GameCode,			// �ͻ�����Ϸ��д
			"GameVers", clientVersion,				// �ͻ�����Ϸ�汾
			"RecomGameId", pData->RecomGameId,		// �Ƽ��ͻ�����Ϸid
			"RecomGameCode", pData->RecomGameCode,	// �Ƽ��ͻ�����Ϸ��д(������Ϸ����˵���д��Ҫ��ʵ�ͻ��˵���д��
			"RecomGameVers", recomGameVers,			// �Ƽ��ͻ�����Ϸ�汾
			"GroupId", pData->GroupId,              // �ͻ��˴������
			"Channel", pData->Channel,				// �ͻ���������
			"HardId", pData->HardId,				// �ͻ����豸��
			"MobileHardInfo",
			"ImeiId", pData->MobileHardInfo.ImeiId,             //
			"WifiId", pData->MobileHardInfo.WifiId,             //
			"ImsiId", pData->MobileHardInfo.ImsiId,             //
			"SimSerialNo", pData->MobileHardInfo.SimSerialNo,   //
			"SystemId", pData->MobileHardInfo.SystemId,         //
			"PkgType", pData->PkgType,                //�ͻ��˰�������(100:�ƶ���Ϸ����\110:�ƶ���Ϸƽ̨��\200:�ƶ�����ǵ���\1000:��Ϸ�ϼ���\300:΢��С��Ϸ\0:pc)
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
            "GameId", pData->GameId,				// �ͻ�����Ϸid
            "GameCode", pData->GameCode,			// �ͻ�����Ϸ��д
            "GameVers", clientVersion,				// �ͻ�����Ϸ�汾
            "RecomGameId", pData->RecomGameId,		// �Ƽ��ͻ�����Ϸid
            "RecomGameCode", pData->RecomGameCode,	// �Ƽ��ͻ�����Ϸ��д(������Ϸ����˵���д��Ҫ��ʵ�ͻ��˵���д��
            "RecomGameVers", recomGameVers,			// �Ƽ��ͻ�����Ϸ�汾
            "GroupId", pData->GroupId,              // �ͻ��˴������
            "Channel", pData->Channel,				// �ͻ���������
            "HardId", pData->HardId,				// �ͻ����豸��
            "MobileHardInfo",
            "ImeiId", pData->MobileHardInfo.ImeiId,             //
            "WifiId", pData->MobileHardInfo.WifiId,             //
            "ImsiId", pData->MobileHardInfo.ImsiId,             //
            "SimSerialNo", pData->MobileHardInfo.SimSerialNo,   //
            "SystemId", pData->MobileHardInfo.SystemId,         //
            "PkgType", pData->PkgType,                //�ͻ��˰�������(100:�ƶ���Ϸ����\110:�ƶ���Ϸƽ̨��\200:�ƶ�����ǵ���\1000:��Ϸ�ϼ���\300:΢��С��Ϸ\0:pc)
            "CUID", pData->CUID                //cuid
            );

        UwlLogFile(_T("--->%s"), strKpiJson);
        return strKpiJson;
    }
}