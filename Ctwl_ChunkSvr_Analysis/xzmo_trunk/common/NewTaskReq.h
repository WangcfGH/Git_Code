/**********************************************************************************************************/
#define GR_TASK_GET_DATA_FOR_JSON_EX        (GAME_REQ_INDIVIDUAL + 2135)    // ��ȡ���ݿ��������� 	(��������, 0������)
#define GR_TASK_QUERY_PARAM_EX              (GAME_REQ_INDIVIDUAL + 2134)    // ��ѯ��������	   	(��������)
#define GR_TASK_CHANGE_PARAM_EX             (GAME_REQ_INDIVIDUAL + 2133)    // �ı�����������	   	(��������)
#define GR_TASK_AWARD_PRIZE_EX              (GAME_REQ_INDIVIDUAL + 2132)    // ��ȡ������		(��������)
#define GR_TASK_GET_TASK_COMPLETE_COUNT     (GAME_REQ_INDIVIDUAL + 2130)    // ��ȡ����������   	(��������, 0������, ���ʱ����)
/**********************************************************************************************************/
#define GR_TASK_GET_LOGON_MSG            (GAME_REQ_INDIVIDUAL + 2131)    // ֪ͨAssist, ���������������ɵ�¼���� 
enum
{
    NEW_TASKDATA_FLAG_DOING = 0,     // �������ڽ�����
    NEW_TASKDATA_FLAG_CANGET_REWARD, // �������ȡ
    NEW_TASKDATA_FLAG_FINISHED,      // ���������
};

enum
{
    NEW_TASK_TYPE_ACTIVITY = 0,                 // ��Ծ��
    NEW_TASK_TYPE_CHECKIN = 1,                  // ǩ��
    NEW_TASK_TYPE_RECHARGE = 3,                 // ��ֵ
    NEW_TASK_TYPE_LOGON_START = 10,             // ��¼����
    NEW_TASK_TYPE_LOGON_ONE= 11,                // ��һʱ��ε�¼
    NEW_TASK_TYPE_LOGON_TWO = 12,               // �ڶ�ʱ��ε�¼
    NEW_TASK_TYPE_LOGON_MAX = 19,               // ��¼�������ֵ
    NEW_TASK_TYPE_GAME_BOUT = 100,              // ����Ծ�����
    NEW_TASK_TYPE_GAME_WIN = 101,               // ����Ӯ������
    NEW_TASK_TYPE_GAME_WIN_DEPOSIT = 102,       // �ۼ�ӮǮ����
    NEW_TASK_TYPE_GAME_GANG_GUA_FENG = 103,     // �η�����(����, ����)
    NEW_TASK_TYPE_GAME_GANG_XIA_YU = 104,       // ��������(����)
    NEW_TASK_TYPE_GAME_PENG = 105,              // ������
    NEW_TASK_TYPE_GAME_HU_DADANDIAO = 106,      // ���󵥵�
    NEW_TASK_TYPE_GAME_HU_QIDUI = 107,          // ���߶�
    NEW_TASK_TYPE_GAME_HU_QINGYISE = 108,       // ����һɫ
    NEW_TASK_TYPE_GAME_HU_PENGPENGHU = 109,     // ��������
    NEW_TASK_TYPE_GAME_HU_DAIYAOJIU = 110,      // ����ô��
    NEW_TASK_TYPE_GAME_HU_JIANGDUI = 111,       // ������
    NEW_TASK_TYPE_GAME_HU_ZIMO = 112            // ����
};

enum
{
    NEW_TASK_OPE_SUCCESS = 0,   // �����ɹ�
    NEW_TASK_DATE_ERROR = 1,    // ʱ�����
    NEW_TASK_DEPOSIT_LIMIT = 2, // Я����������
    NEW_TASK_NOT_FINISHED = 3,  // ����δ���
    NEW_TASK_ALLREADY_FINISHED = 4  // ���������
};

struct TaskInfo
{
    int nTaskID;			// ����ID
    int nCurProgress;		// ��ǰ����
    int nRewardStatus;		// �콱״̬
};

struct RewardInfo
{
    int nRewardID;		// ����ID
    int nRewardCount;	// ��������
    int nSuccess;		// �����Ƿ�ɹ�
};

//1. ��ȡ��������
typedef struct ReqTaskQueryConfig
{
    int nUserID;		// �û�ID
    int nDate;
}REQTASKQUERYCONFIG, *LPREQTASKQUERYCONFIG;

typedef struct RspTaskQueryConfig
{
    int nDate;
    int nUserID;
    char Data[0];   // json��ʽ��config
}RSPTASKQUERYCONFIG, *LPRSPTASKQUERYCONFIG;

//2. ��ȡ�������:
typedef struct ReqTaskGetCompleteCount
{
    int nUserID;	// �û�ID
    int nDate;		// ������ʱ��
}REQTASKGETCOMPLETECOUNT, *LPREQTASKGETCOMPLETECOUNT;

typedef struct RspTaskGetCompleteCount
{
    int nUserID;	// ��������ʱ,��Ҫ֪�����͸��ĸ����
    int nDate;
    int nCount;		// �����������
}RSPTASKGETCOMPLETECOUNT, *LPRSPTASKGETCOMPLETECOUNT;

//3. ��ȡ����������
typedef struct ReqTaskQueryParams
{
    int nUserID;	// �û�ID
    int nDate;		// ������ʱ��
    int nTaskID;	// ����id, ��д0�����ȡȫ���������
}REQTASKQUERYPARAMS, *LPREQTASKQUERYPARAMS;

typedef struct RspTaskQueryParams
{
    int nDate;
    int nUserID;
    int nTaskCount;		// ��������
    struct TaskInfo sTaskInfo[0];
}RSPTASKQUERYPARAMS, *LPRSPTASKQUERYPARAMS;

//4. �ı�����������:
typedef struct ReqTaskChangeParams
{
    int nUserID;
    int nDate;		// ������ʱ��
    int nTypeID;	// ����id
    int nCount;		// �ӻ��߼�������
}REQTASKCHANGEPARAMS, *LPREQTASKCHANGEPARAMS;

typedef struct RspTaskChangeParams
{
    int nDate;
    int nUserID;
    int nTypeID;		// ����ID
    int nCurProgress;	// ��ǰ����
}RSPTASKCHANGEPARAMS, *LPRSPTASKCHANGEPARAMS;

//5. �콱
typedef struct ReqTaskAwardPrize
{
    int nUserID;	 // �û�ID
    int nDate;		 // ����ʱ��
    int nTaskID;	 // ����ID
    int nCurDeposit; // ��ǰ���� 
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
}REQTASKAWARDPRIZE, *LPREQTASKAWARDPRIZE;

typedef struct RspTaskAwardPrize
{
    struct TaskInfo sTaskInfo;		// ��ǰ������Ϣ
    int nRet;                       // ����ֵ
    int nActive;					// ��ǰ��Ծ��
    int nUserID;
    int nRewardCount;				// ������������
    struct RewardInfo sRewardInfo[0];	// �����б�
}RSPTASKAWARDPRIZE, *LPRSPTASKAWARDPRIZE;

//��.������֮�佻������:
typedef struct rewardInfoForAssist
{
    int nRewardID;
    int nRewardCount;	// ��������
    char webID[32];		// ������webid
}REWARDINFOFORASSIST, *LPREWARDINFOFORASSIST;

//1. �콱 chunk->assist
typedef struct TaskRewardInfo
{
    struct TaskInfo sTaskInfo; 	// ��ǰ������Ϣ
    int nRet;                   // ����ֵ
    int nActive;				// ��ǰ��Ծ��
    int nUserID;				// �û�ID
    int nRewardCount;
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
    REWARDINFOFORASSIST rewardInfo[0];
}TASKREWARDINFO, *LPTASKREWARDINFO;
