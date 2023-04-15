#pragma once

#define     GR_SHARE_SUCCESS           (GAME_REQ_INDIVIDUAL + 3100)  // ����ɹ�֪ͨ������

#define     GR_LOTTERY_SHOW            (GAME_REQ_INDIVIDUAL + 3105)  // ��ѯ��ǰ�汾�齱�Ƿ������ʾ
#define     GR_LOTTERY_HARVEST         (GAME_REQ_INDIVIDUAL + 3105)  // ͨ�����ֶ���(����������...)�ջ�齱����
#define     GR_LOTTERY_QUERY           (GAME_REQ_INDIVIDUAL + 3106)  // ��ѯ�齱��Ϣ
#define     GR_LOTTERY_DO              (GAME_REQ_INDIVIDUAL + 3107)  // ִ�г齱����
#define     GR_LOTTERY_AWARD           (GAME_REQ_INDIVIDUAL + 3108)  // ���ų齱��Ʒ
#define     GR_LOTTERY_CONTINUE        (GAME_REQ_INDIVIDUAL + 3109)  // �����ϴ�δ��ķ�������
#define     GR_SOAP_LOTTERY            (GAME_REQ_INDIVIDUAL + 3110)  // soap�齱��Ϣ
#define     GR_SOAP_GET_PRIZE          (GAME_REQ_INDIVIDUAL + 3111)  // soap������Ϣ
//����齱start
#define     GR_LOTTERY_ALL_TASKINFO_REQ     (GAME_REQ_INDIVIDUAL + 3112)    //��ȡ��������齱����
#define     GR_LOTTERY_FINISHTASK_REQ       (GAME_REQ_INDIVIDUAL + 3113)    //�ύ�����������
#define     GR_LOTTERY_UPDATE_TASKJSON      (GAME_REQ_INDIVIDUAL + 3114)    //ͨ���汾�Ÿ�������json
#define     GR_LOTTERY_UPDATE_TASKPROCESS   (GAME_REQ_INDIVIDUAL + 3115)    //�����������
#define     GR_LOTTERY_NTF_PROCESS_UPDATE   (GAME_REQ_INDIVIDUAL + 3116)    //֪ͨ�ͻ�����������и���(��δʹ�ã�
//����齱end

//�齱��� ���ݿ�ṹ
#define MAX_LOTTERY_KIND  5  // �齱����֧��������Ŀǰģ����5�֣���������
#define MAX_GAME_CODE_LEN 16
enum
{
    tLotteryKindBegin,
    tLotteryBout = tLotteryKindBegin,     // �����齱(�����)
    tLotteryShare,                        // ����齱
    tLooteryTask,                         // ����齱
    tLooteryYQW,                          // ����ģʽ�����齱
    tLooteryTQWFk,                        // ����ģʽ�����齱
    // ... �����齱������������

    tLotteryKindEnd,
};

enum
{
    tLotteryStatusNormal,           // ��ѯ����״̬
    tLotteryStatusClose,            // ��ѹر�
    tLotteryStatusSaturation,       // ���ճ齱�����Ѿ�����
    tLotteryStatusUnable,           // �����������ܳ齱
};

enum
{
    tLotteryResultStatusSuccess,     // �齱�������������
    tLotteryResultStatusDelay,       // �齱������ӳٵ��ˣ����绰��
    tLotteryResultStatusFailed,      // �齱�����ʧ��
};

enum
{
    tLotteryPrizeTypeSilver = 1,
    tLotteryPrizeTypeHF,
    tLotteryPrizeTypeCloth,
    tLotteryPrizeTypeGoods,
    tLotteryPrizeTypeScore  = 6,
    tLotteryPrizeTypeTicket = 8,
};

enum
{
    LOTTERY_TASKSTATUS_DOING,                   //��������ȡ, ����������
    LOTTERY_TASKSTATUS_FINISH,                  //��������ɣ���δ��ȡ����������齱���������Ķ��ǳ齱����������redis�У����̷��ţ����Բ����ڸ�״̬��
    LOTTERY_TASKSTATUS_OVER,                    //����ȡ�������������
};

enum
{
    LOTTERYTASK_REFRESH_DAILY,                  //ÿ��24������
    LOTTERYTASK_REFRESH_WEEKEND,                //ÿ����24������
    LOTTERYTASK_REFRESH_APPOINT                 //ָ��ʱ��ˢ��
};


// ��������
enum
{
    /*****************ͨ�ò���*****************/
    LOTTERYTASK_GAME_RESULT_WIN = 1,       // 1 - Ӯ�ľ���
    LOTTERYTASK_GAME_RESULT_LOSE,          // 2 - ��ľ���
    LOTTERYTASK_GAME_RESULT_DRAW,          // 3 - ƽ�ľ���
    LOTTERYTASK_GAME_CUR_WIN_STREAK,       // 4 - ��ǰ��ʤ
    LOTTERYTASK_GAME_MAX_WIN_STREAK,       // 5 - �����ʤ
    /*****************��Ϸ����*****************/
    LOTTERYTASK_GAME_GANG,                 //6 -  ����
    LOTTERYTASK_GAME_RESULT_SDB,           //7 -  ˫����

    LOTTERYTASK_GAME_ZIMO_COUNT,           //8 - ��������
    LOTTERYTASK_GAME_CREATE_BOUT,          //9 - �����������
    LOTTERYTASK_GAME_7FENQ_COUNT,          //10 - 13���߷�ȫ��ȱ����
    LOTTERYTASK_GAME_ROUND_COUNT,          //11 - һ����ľ�������
    LOTTERYTASK_GAME_13LAN_COUNT,          //12 - 13��
    LOTTERYTASK_GAME_CREATEFINISH_BOUT,    //13 - �������䲢�����ȫ���Ծ�
    /******************�ͻ���******************/
    LOTTERYTASK_PARAM_FROM_CLIENT = 20,
    LOTTERYTASK_GAME_SHARE_COUNT,          // 21- �������
};

typedef struct _tagLotteryHarvest
{
    int nUserID;                      // userid
    int nTypeID;                      // �齱����
    int nCount;                       // Ҫ���ӵĴ���
    int nReserved[4];
} LOTTERYHARVEST, *LPLOTTERYHARVEST;

// ����齱(����齱��Ϣ��������ִ�г齱����)
typedef struct _tagLotteryQuery
{
    int  nUserID;                       // userid
    char szHardID[MAX_HARDID_LEN];      // Ӳ����
    int nDate;                          // ������������

    int  nReserved[4];
} LOTTERYQUERY, *LPLOTTERYQUERY;

// �齱��Ϣ
typedef struct _tagLotteryInfo
{
    int nUserID;                                // userid
    char szHardID[MAX_HARDID_LEN];              // Ӳ����
    int nDate;                                  // ���ص���Ϣ������

    int nMaxCountEveryday[MAX_LOTTERY_KIND];    // ���ֳ齱���ʹ���
    int nEveryCountEveryKind[MAX_LOTTERY_KIND]; // ���ٴ���һ�θ����͵ĳ齱����
    int nCurrentCount[MAX_LOTTERY_KIND];        // ���ֳ齱�����ۼƵĴ���
    int nLotteryToday;                          // �����ۼƳ齱����
    int nLotteryHF;                             // �����ۼ��л��ѵĴ���
    int nLotteryHFHardID;                       // ��Ӳ������ճ��л��ѵĴ���
    int nLotteryRelease;                        // Ŀǰʣ��ɳ����
    int nStatus;                                // ��ǰ�״̬

    int nBeginDate;                             // ���ʼʱ��
    int nEndDate;                               // �����ʱ��

    int  nReserved[4];
} LOTTERYINFO, *LPLOTTERYINFO;

// �齱���
typedef struct _tagLotteryResult
{
    int nUserID;                                // userid
    char szHardID[MAX_HARDID_LEN];              // Ӳ����
    int nDate;                                  // �ó齱��������

    int nPrizeCount;                            // ��Ʒ����
    int nPrizeType;                             // ��Ʒ����
    int nStatus;                                // �齱���
    char szPhone[32];                           // �ֻ���
} LOTTERYRESULT, *LPLOTTERYRESULT;

typedef struct _tagTempLotteryResult
{
    SOCKET hSocket;
    LONG   lTokenID;
    int    nActivityID;
    LOTTERYRESULT lotteryResult;
} TempLotteryResult, *LPTempLotteryResult;

// ���Ż�����Ҫ����Ϣ
typedef struct _tagLotteryAward
{
    int nUserID;                        // userid
    char szHardID[MAX_HARDID_LEN];      // Ӳ����

    char szPhone[16];                   // �ֻ���

    int nReserved[4];
} LOTTERYAWARD, *LPLOTTERYAWARD;

///////////////////////////////////////////////////////////////////////////////////
//����齱��ʼ�� 2018,04,04

//����������Ϣ������ṹ��
typedef struct _tagLOTTERY_ALL_TASKINFO_REQ
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nReserved[8];
} LOTTERY_ALL_TASKINFO_REQ, *LPLOTTERY_ALL_TASKINFO_REQ;

//������Ϣ��Ӧ
typedef struct _tagLOTTERY_ALL_TASKINFO_RESP
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nReserved[8];
    //nTaskCount;
    //LOTTERY_TASKINFO * nTaskCount;
    //nProcessTypeCount;
    //LOTTERY_TASKPROCESS * nProcessTypeCount;
    //nLotteryTypeCount;
    //LOTTERY_INFO * nLotteryTypeCount;
} LOTTERY_ALL_TASKINFO_RESP, *LPLOTTERY_ALL_TASKINFO_RESP;

//�齱������Ϣ�ṹ��
typedef struct _tagLOTTERY_TASKINFO
{
    int nTaskID;        //����id
    int nTaskGroupID;   //������ţ����磬ͬ���ǿ�������������ô������ͬһ�飬�ͻ���ͨ������ʾ���������бȽϵͼ�������
    int nTaskStatus;    //����״̬(δ��� ����� ����ȡ��
    int nAbortTime;     //����ʧЧʱ��
    int nReserved[4];
} LOTTERY_TASKINFO, *LPLOTTERY_TASKINFO;

//�齱������Ƚṹ��
typedef struct _tagLOTTERY_TASKPROCESS
{
    int nProcessType;       //��������id�����磬�����������ݿ�����������һ�Σ�����������Ϳ�������ɶ�������������
    int nProcessCount;  //�������count
    int nAbortTime;     //���ȹ����ʱ��
    int nReserved[4];
} LOTTERY_TASKPROCESS, *LPLOTTERY_TASKPROCESS;

//�ɳ齱�����Լ������ṹ��
typedef struct _tagLOTTERY_INFO
{
    int nLotteryType;   //�齱���ͣ�����߼��齱���ͼ��齱��
    int nLotteryCount;  //�齱����
    int nAbortTime;     //�齱��������ʱ��
    int nReserved[4];
} LOTTERY_INFO, *LPLOTTERY_INFO;

//�����ȡ��������Ŀǰֻ�г齱�����Ľ�����
typedef struct _tagLOTTERY_FINISHTASK_REQ
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nTaskID;        //����id
    int nReserved[4];
} LOTTERY_FINISHTASK_REQ, *LPLOTTERY_FINISHTASK_REQ;

typedef struct _tagLOTTERY_FINISHTASK_RESP
{
    int nUserID;
    LOTTERY_TASKINFO stTaskInfo;        //����ɵ�����ṹ��
    int nReserved[8];
    //nProcessTypeCount;
    //nProcessTypeCount*LOTTERY_TASKPROCESS;    //�����ٵ��������
    //nLotteryTypeCount;
    //nLotteryTypeCount*LOTTERY_INFO;       //�޸ĵĳ齱���ͼ�����
} LOTTERY_FINISHTASK_RESP, *LPLOTTERY_FINISHTASK_RESP;

//�������µĳ齱����json�ļ��Ľṹ��
typedef struct _tagLOTTERY_UPDATE_TASKJSON_REQ
{
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nVersionCode;
    //int nMajorVer;                        //�����ļ���汾��  ����ֻ�ܻ�ȡ����汾����ͬ�������ļ�����汾�Ų�ͬ�϶�Ϊ�����ݣ����������汾�����ö�������һ�ݣ�
    //int nMinorVer;                        //�����ļ�С�汾��  ���ڴ�汾����ͬ��С�汾�Ų�ͬ���ļ��򼴿̴�������
    //int nBuildNO;                     //�����ļ�buildno   ���ڴ�汾����ͬС�汾����ͬ��buildno��ͬ�������ļ��򼴿ɴ�������
    int nReserved[8];
} LOTTERY_UPDATE_TASKJSON_REQ, *LPLOTTERY_UPDATE_TASKJSON_REQ;

typedef struct _tagLOTTERY_TASKJSON_RESP
{
    int nVersionCode;
    //int nLen;
    //taskjson;
} LOTTERY_TASKJSON_RESP, *LPLOTTERY_TASKJSON_RESP;

typedef struct _tagLOTTERY_TASKPROCESS_CHANGE
{
    int nUserID;
    LOTTERY_TASKPROCESS stTaskProcess;
    int nReserved[8];
} LOTTERY_TASKPROCESS_CHANGE, *LPLOTTERY_TASKPROCESS_CHANGE;

typedef struct _tagLOTTERY_NTF_PROCESS_UPDATE
{
    int nUserID;
    int nReserved[8];
    //nProcessTypeCount;
    //nProcessTypeCount * LOTTERY_TASKPROCESS;
} LOTTERY_NTF_PROCESS_UPDATE, *LPLOTTERY_NTF_PROCESS_UPDATE;
//����齱����
///////////////////////////////////////////////////////////////////////////////////