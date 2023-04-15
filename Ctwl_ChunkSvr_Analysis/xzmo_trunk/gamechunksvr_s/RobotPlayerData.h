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

    // DB����
	ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) > imDBOpera;

    //��ȡ����int��Ϣ
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
	ImportFunctional<void(LPCONTEXT_HEAD, BOOL, REQUEST&) > imSendOpeResponse;
    
    // ��ȡ��������socket
	ImportFunctional<void(SOCKET&, LONG&)> imGetRoomSvrSock;

protected:
	BOOL OnUpdateRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnQueryRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    int Redis_QueryRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData);
    int Redis_UpdateRobotData(DBConnectEntry* entry, int nDate, int nUserID, LPROBOT_UPDATE_PLAYERDATA reqPlayerData, ROBOT_PLAYER_DATA& robotData);
    int Redis_InitRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData);

	void OnFreshTimer();
    int GetCurDate();

    // ��ȡdb key
    std::string toKey(int userid);
    // ������Ϣ

private:
    stdtimerPtr m_timerFresh;

    int m_nCurrentDate;
};


