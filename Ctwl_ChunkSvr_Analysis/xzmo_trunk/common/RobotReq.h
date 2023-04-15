#pragma once

//#include "json.h"

#define ROBOT_ERR_TRANSMIT        _T("������������ϣ������ʱ������ԡ�")
#define ROBOT_ERR_CHUNKERR        _T("��������ѯ�쳣�������ʱ������ԡ�")

#define GR_QUERY_ROBOT_INFO         (GAME_REQ_INDIVIDUAL + 2300)    // ��������˷�������
#define GR_UPDATE_ROBOT_INFO        (GAME_REQ_INDIVIDUAL + 2301)    // ���»���������

// �ͻ��˽����ṹ�嶨�� **************************
// �ͻ��˻�������������
typedef struct _reqRobotInfoQuery
{
    int nUserID;
    char sDeviceID[32];
    int nBout;      // ����ܶԾ���(ʤ��ƽ���, �����ж��Ƿ������������)
} REQROBOTINFOQUERY, *LPREQROBOTINFOQUERY;

typedef struct _rspRobtInfoQuery
{
    int nUserID;
    int bCanJoinRobot; // ֻ��Ҫ�ظ��ܲ��ܽ������˳�
} RSPROBOTINFOQUERY, *LPRSPROBOTINFOQUERY;


typedef struct _reqRobotInfoUpdate
{
    int nUserID;
    char sDeviceID[32];
    int nIsLose;
    int bIsRobot;
    int nBout;      // ����ܶԾ���(ʤ��ƽ���, �����ж��Ƿ������������)
} REQROBOTINFOUPDATE, *LPRREQROBOTINFOUPDATE;

typedef struct _rspRobotInfoUpdate
{
    int nUserID;
    int bCanJoinRobot; // ֻ��Ҫ�ظ��ܲ��ܽ������˳�
} RSPROBOTINFOUPDATE, *LPRSPROBOTINFOUPDATE;
//*************************************************

typedef struct _robotConfig
{
    int nTotalLimitBout;        // ��������, ����֮��������
    int nRobotLimitBount;       // �����˷����Դ򼸾�
    int nDeviceLimitBount;      // �豸����
    int nDailyLimitBount;       // ÿ����N�ֿɽ������˷�
    int nLoseCondition;         // ����N����
} ROBOT_CONFIG;

typedef struct _dataUserRobotInfo
{
    int nUserID;
    int nRobotBout;        // �����˳��Ծ���
    int nDailyBout;        // ÿ�նԾ���
    int nLoseBout;         // ������
} data_userRobotInfo;

typedef struct _robotUpdatePlayerData
{
    int nUserID;            //�û�ID
    int nTotalBouts;        //�ܾ���
    int nWin;               //�� -1 Ӯ 1 ƽ 0
    int bSpecialRobot;      //�Ƿ������ֻ����˶Ծ�
} ROBOT_UPDATE_PLAYERDATA, *LPROBOT_UPDATE_PLAYERDATA;

typedef struct _robotPlayerData
{
    int nUserID;
    int nTodayCount;  //���վ���
    int nLoseCount;   //����
    int nRobotCountGot;  //������ƥ������˴���
    int nContainRobot;  //�����˷����ˣ���Ҫ��������
} ROBOT_PLAYER_DATA, *LPROBOT_PLAYER_DATA;

typedef struct _tagQueryUserRobotData
{
    int         nUserID;                        //�û�ID
} ROBOT_QUERY_USERDATA, *LPROBOT_QUERY_USERDATA;


typedef struct _tagRemoveUserRobotData
{
    int         nUserID;                        //�û�ID
} ROBOT_REMOVE_USERDATA, *LPROBOT_REMOVE_USERDATA;