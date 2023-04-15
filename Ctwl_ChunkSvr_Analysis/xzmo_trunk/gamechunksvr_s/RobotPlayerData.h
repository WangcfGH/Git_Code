#pragma once
#include "..\common\RobotReq.h"
#include "plana/plana.h"
#include <boost/any.hpp>
using namespace plana::threadpools;

class TcyMsgCenter;
class RobotPlayerData : public PlanaStaff
{
public:
    void OnServerStart(BOOL &, TcyMsgCenter *);
    void OnShutDown();

    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;

    // DB操作
	ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) > imDBOpera;

    //获取配置int信息
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
	ImportFunctional<void(LPCONTEXT_HEAD, BOOL, REQUEST&) > imSendOpeResponse;
    
    // 获取房间服务的socket
	ImportFunctional<void(SOCKET&, LONG&)> imGetRoomSvrSock;

protected:
	BOOL OnUpdateRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnQueryRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    int Redis_QueryRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData);
    int Redis_UpdateRobotData(DBConnectEntry* entry, int nDate, int nUserID, LPROBOT_UPDATE_PLAYERDATA reqPlayerData, ROBOT_PLAYER_DATA& robotData);
    int Redis_InitRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData);

	void OnFreshTimer();
    int GetCurDate();

    // 获取db key
    std::string toKey(int userid);
    // 返回消息

private:
    stdtimerPtr m_timerFresh;

    int m_nCurrentDate;
};


