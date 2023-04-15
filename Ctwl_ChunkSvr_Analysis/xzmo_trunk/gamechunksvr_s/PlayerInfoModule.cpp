#include "stdafx.h"
#include "PlayerInfoModule.h"

void PlayerInfoModule::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_EXPLAYERINFO_QUERY, OnQueryExPlayerInfoParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_EXPLAYERINFO_CHANGE_PARAM, OnChangeExPlayerInfoParam);
    }
}

void PlayerInfoModule::OnShutDown()
{

}

BOOL PlayerInfoModule::OnQueryExPlayerInfoParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* lpExPlayerInfoReq = RequestDataParse<EXPLAYERINFOPARAMQUERY>(lpRequest);
	if (nullptr == lpExPlayerInfoReq) {
		return FALSE;
	}
	REQUEST response;
	memset(&response, 0, sizeof(response));
	response.head.nRequest = lpRequest->head.nRequest;
	response.head.nSubReq = UR_OPERATE_FAILED;
	response.head.nRepeated = 1;

	EXPLAYERINFOPARAMQUERYRSP exPlayerInfoQueryRsp;
	memset(&exPlayerInfoQueryRsp, 0, sizeof(exPlayerInfoQueryRsp));
	exPlayerInfoQueryRsp.nRoomID = lpExPlayerInfoReq->nRoomID;
	exPlayerInfoQueryRsp.nTableNo = lpExPlayerInfoReq->nTableNo;
	for (int i = 0; i < TOTAL_CHAIRS; i++){
		// CHENSHU COMMENT
		// 这里判断异常，直接return,continue是不是好一点？
		int nUserID = lpExPlayerInfoReq->nUserID[i];
		if (nUserID <= 0){
			UwlLogFile("OnQueryTaskData userid is invalid.");
			return FALSE;
		}

        int r = 0;
		auto key = toKey(nUserID);
		//查询数据库
		EXPLAYERINFOPER exPlayerInfoPer;
		memset(&exPlayerInfoPer, 0, sizeof(exPlayerInfoPer));

		r = imDBOpera(key, [&exPlayerInfoPer, nUserID](DBConnectEntry* entry){
			return GetOnePlayerEx(entry, nUserID, exPlayerInfoPer);
        }).get();
        if (r) {
			return FALSE;
		}

		exPlayerInfoQueryRsp.nUserID[i] = exPlayerInfoPer.nUserId;
		exPlayerInfoQueryRsp.nXZCount[i] = exPlayerInfoPer.nXueZhanCount;
		exPlayerInfoQueryRsp.nXLCount[i] = exPlayerInfoPer.nXueLiuCount;
	}
	std::string buffer;
	buffer.append((char*)lpRequest->pDataPtr, lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));
	buffer.append((char*)&exPlayerInfoQueryRsp, sizeof(exPlayerInfoQueryRsp));
	response.head.nSubReq = UR_FETCH_SUCCEEDED;
	response.pDataPtr = (void*)buffer.data();
	response.nDataLen = buffer.size();

	imSendOpeRequest(lpContext, response);
    return TRUE;
}

BOOL PlayerInfoModule::OnChangeExPlayerInfoParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* lpReqData = RequestDataParse<EXPLAYERINFOPARAMCHANGE>(lpRequest);
	if (nullptr == lpRequest) {
		return FALSE;
	}
	int nUserID = lpReqData->nUserID;
	//更新数据库
	//先查询
	EXPLAYERINFOPER exPlayerInfoPer;
	memset(&exPlayerInfoPer, 0, sizeof(exPlayerInfoPer));
	exPlayerInfoPer.nUserId = nUserID;

	auto key = toKey(nUserID);

	auto r = imDBOpera(key, [lpReqData, nUserID, &exPlayerInfoPer](DBConnectEntry* entry){
		int sqlerror = GetOnePlayerEx(entry, nUserID, exPlayerInfoPer);
		if (sqlerror) {
			return sqlerror;
		}
		if (EXPLAEYER_COUT_XZ == lpReqData->nType) //血战房
		{
			exPlayerInfoPer.nXueZhanCount += lpReqData->nValue;
		}
		else if (EXPLAEYER_COUT_XL == lpReqData->nType) //血流房
		{
			exPlayerInfoPer.nXueLiuCount += lpReqData->nValue;
		}
		sqlerror = UpdateOnePlayerEx(entry, exPlayerInfoPer);
		return sqlerror;
	}).get();
	if (r) {
		return FALSE;
	}

	REQUEST response;
	memset(&response, 0, sizeof(response));
	response.head.nRequest = lpRequest->head.nRequest;
	response.head.nSubReq = UR_OPERATE_FAILED;
	response.head.nRepeated = 1;

	EXPLAYERINFOPARAMCHANGERSP exPlayerInfoChangeRsp;
	memset(&exPlayerInfoChangeRsp, 0, sizeof(exPlayerInfoChangeRsp));

	exPlayerInfoChangeRsp.nUserID = nUserID;
	exPlayerInfoChangeRsp.nXZCount = exPlayerInfoPer.nXueZhanCount;
	exPlayerInfoChangeRsp.nXLCount = exPlayerInfoPer.nXueLiuCount;
	exPlayerInfoChangeRsp.nRoomID = lpReqData->nRoomID;
	exPlayerInfoChangeRsp.nTableNo = lpReqData->nTableNo;
	exPlayerInfoChangeRsp.nChairNo = lpReqData->nChairNo;

	std::string buffer;
	buffer.append((char*)lpRequest->pDataPtr, lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));
	buffer.append((char*)&exPlayerInfoChangeRsp, sizeof(exPlayerInfoChangeRsp));
	response.head.nSubReq = UR_FETCH_SUCCEEDED;
	response.pDataPtr = (void*)buffer.data();
	response.nDataLen = buffer.size();

	imSendOpeRequest(lpContext, response);
    return TRUE;
}

int PlayerInfoModule::GetOnePlayerEx(DBConnectEntry* entry, int nUserID, EXPLAYERINFOPER& playerEx)
{
	TCHAR szSql[MAX_SQL_LENGTH] = { 0 };
	sprintf_s(szSql, "call usp_query_explayer_info(%d)", nUserID);
	auto r = entry->mysql_excute(szSql, [&playerEx, nUserID](sql::ResultSet* res){
		while (res->next()) {
			playerEx.nUserId = nUserID;
			playerEx.nXueZhanCount = res->getInt("xzcount");
			playerEx.nXueLiuCount = res->getInt("xlcount");
		}
		return res->rowsCount();
	});

	return r.first;
}

int PlayerInfoModule::UpdateOnePlayerEx(DBConnectEntry* entry, EXPLAYERINFOPER& playerEx)
{
	TCHAR szSql[MAX_SQL_LENGTH] = { 0 };
	sprintf_s(szSql, "call usp_update_explayer_info(%d,%d,%d)",
		playerEx.nUserId, playerEx.nXueZhanCount, playerEx.nXueLiuCount);
	return entry->mysql_excute(szSql);
}

void PlayerInfoModule::OnInputTest(bool& ret, std::string& cmd)
{
	if (cmd == "PlayerInfoTest") {
		int nUserID = 1000;
		EXPLAYERINFOPER player = { 0 };
		player.nUserId = nUserID;
		player.nXueLiuCount = 100;
		player.nXueZhanCount = 200;
		auto key = toKey(nUserID);

		auto r = imDBOpera(key, [&player, nUserID](DBConnectEntry* entry){
			return UpdateOnePlayerEx(entry, player);
		}).get();

		ZeroMemory(&player, sizeof(player));
		r = imDBOpera(key, [&player, nUserID](DBConnectEntry* entry){
			int sqlerr = GetOnePlayerEx(entry, nUserID, player);
			return sqlerr;
		}).get();
		std::cout << r << std::endl;
	}
}

std::string PlayerInfoModule::toKey(int nUserID)
{
	std::stringstream ss;
	ss << typeid(*this).name() << "_" << nUserID;
	return ss.str();
}
