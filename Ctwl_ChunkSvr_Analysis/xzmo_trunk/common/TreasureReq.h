#pragma once
#include <vector>

#define TREASURE_ERR_TRANSMIT        _T("������������ϣ������ʱ������ԡ�")
#define TREASURE_ERR_CHUNKERR        _T("��������ѯ�쳣�������ʱ������ԡ�")

// ��Ϣ�� �Ϳͻ��˽�����
#define GR_QUERY_TREASURE_INFO          (GAME_REQ_INDIVIDUAL + 2200)  // ������������Ϣ
#define GR_TAKE_TREASURE_AWARD          (GAME_REQ_INDIVIDUAL + 2201)  // �����콱

// �����֮�佻��������
#define GR_TREASURE_UPDATE_TASK_DATA    (GAME_REQ_INDIVIDUAL + 2202)  // �޸ı����������
#define TREASURE_AWARD_ALL_CHANCE       100000

// chunk��assist����ֵ
#define UR_OPERATE_CLOSE        (UR_REQ_BASE + 10101)       // ��Ѿ��ر���
#define UR_OPERATE_RE_ARWARD    (UR_OPERATE_CLOSE + 1)      // �ظ��콱
#define UR_OPERATE_NOT_READY    (UR_OPERATE_RE_ARWARD + 1)  // δ�ﵽ�콱����

#define TREASURE_MID_MAX_LEN            12
#define TREASURE_TASKS_MAX_LEN          12

enum
{
    TREASURE_COLOR_GREEN = 1,
    TREASURE_COLOR_BLUE,
    TREASURE_COLOR_PURPLE,
    TREASURE_COLOE_ORANGE
};

// �ͻ��˽����ṹ�嶨�� **************************
// �ͻ����콱����ṹ��
typedef struct _reqTreasureAwardPrize
{
    int nUserID;
    int nRoomID;
} REQTREASUREAWARDPRIZE, *LPREQTREASUREAWARDPRIZE;

// trunk����assist�콱�ṹ��
typedef struct rspTreasureAwardPrize
{
    int userid;
    int roomid;
    int boutcount;
    int next_goal;      // ��һ�ֵĴ��� 0 ����û����
    int prize_count;    // ��������
    int last_count;     // ��һ���콱ʱ�ĶԾ���
    int type;           // 0����,1�һ�ȯ
    int MgId;           // ������Id
    char MId[TREASURE_MID_MAX_LEN];     // ����Id
} RSPTREASUREAWARDPRIZE, *LPRSPTREASUREAWARDPRIZE;

// �ͻ����콱rsp�ṹ��
typedef struct RspAwardPrize
{
    int ret;            // 1 OK, ���� error
    int prize_count;    // ��������
    int type;           // 0����,1�һ�ȯ
    int next_goal;      // ��һ�ֵĴ��� 0 ����û����
    int last_count;     // ��һ���콱ʱ�ĶԾ���
} RSPAWARDPRIZE, *LPRSPAWARDPRIZE;

// �ͻ���������������ṹ��
typedef struct ReqTreasureInfo
{
    int nUserID;
    int nRoomID;
} REQTREASUREINFO, *LPREQTREASUREINFO;

// �ͻ�����������rsp�ṹ��
typedef struct _rspTreasureInfo
{
    int enable;
    int color;      // 0 - ��, 1 �C ��, 2 - ��, 3 �C ��
    int goal;       // ���goal ��0��˵�����������Ѿ���ȡ����ˣ����ղ�������ȡ�ˡ�
    int progress;   // ��ǰ����
    int last_count; // ��һ���콱�ĶԾ�����
} RSPTREASUREINFO, *LPRSPTREASUREINFO;
// *****************************************************


// �ڲ�����ά��
typedef struct _tagTreasureConfig
{
    int taskeid;    //����齱��ID
    int begin_time; //��ʼʱ��
    int end_time;   //����ʱ��
} TREASURERE_CONFIG, *LPTREASURERE_CONFIG;

// ������Ϣinfo���� *********************************
typedef struct _tagTreasureRewardItem
{
    int id;         //  json�е�id
    int count;      //  ��Ʒ����
    int type;       //  ��Ʒ����; 0 ����;1 �һ�ȯ
    std::string webid;  //  ��Ʒ����
} TREASUREREWARDITEM;

// �������������ӽṹ��
typedef struct _tagTreasureRewardInfo
{
    std::string webid;
    int type;   //�������� 0 ����; 1 �һ�ȯ
    int reward_count;
    float rate;
} TREASUREREWARDINFO, *LPTREASUREREWARDINFO;

// ��������������ýṹ��
typedef struct _tagTreasureTaskInfo
{
    int task_goal;
    std::vector< TREASUREREWARDINFO > rewards;
} TREASURETASKINFO, *LPTREASURETASKINFO;

// �����������ýṹ��
typedef struct TreasureRoomInfo
{
    int roomid;
    int color;
    std::vector< TREASURETASKINFO > tasks;
} TREASUREROOMINFO, *LPTREASUREROOMINFO;
/***************************************************/


/* ����˽����ӿ� *****************************************/
// ����˻�ȡ������Ƚṹ��
typedef struct reqTreasureTaskData
{
    int userid;
    int roomid;
} REQTREASURETASKDATA, *LPREQTREASURETASKDATA;


// �����������Ӵ���
typedef struct reqAddTreasureTaskData
{
    int userid;
    int roomid;
    int count;   // ��Ӵ���
} REQADDTREASURETASKDATA, *LPREQADDTREASURETASKDATA;

// �������Ӵ����Ļظ�
typedef struct rspAddTreasureTaskData
{
    int ret;
} RSPADDTREASURETASKDATA, *LPRSPADDTREASURETASKDATA;
/********************************************************/


//////////////////////////////////////////////////////////////////////////
// ��ṹ��
struct tbl_TreasureTaskData
{
    int roomid;
    int userid;
    int count;
    int last_reward_count;
    int task_reward_round;
};
//////////////////////////////////////////////////////////////////////
// ���ṹ��
typedef struct _logTreasureAward
{
    int nUserID;
    int nRoomID;
    int nBoutCount;
    int nPrizeType;
    int nPrizeCount;
    int nAwardSuccess;
} LOGTREASUREAWARD, *LPLOGTREASUREAWARD;