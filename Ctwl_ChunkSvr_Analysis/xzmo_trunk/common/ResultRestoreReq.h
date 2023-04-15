#define GR_RESULT_DEPOSIT_SAVE      (GAME_REQ_INDIVIDUAL + 2160)    // �޸�������¼����
#define GR_RESULT_DEPOSIT_CLEAN     (GAME_REQ_INDIVIDUAL + 2161)    // ����������¼
#define GR_RESULT_RESTORE_CONFIG    (GAME_REQ_INDIVIDUAL + 2162)    // ��ȡ��������
#define GR_RESULT_RESTORE           (GAME_REQ_INDIVIDUAL + 2163)    // ��ȡ���⽱��
#define GR_RESULT_DOUBLE            (GAME_REQ_INDIVIDUAL + 2164)    // ��ȡ��������

enum
{
    STATUS_RESULT_NULL = 0,             // �����ڼ�¼
    STATUS_RESULT_CAN_AWARD = 1,        // ����������߷���
    STATUS_RESULT_ALLREADY_AWARD = 2    // �Ѿ���������
};

// 1.�޸�������¼����
typedef struct{
    int nUserID;
    int nUniqueID;
    int nDeposit;
}ReqResultDepositSave, *LPReqResultDepositSave;

// 2. ����������¼����
typedef struct 
{
    int nUserID[TOTAL_CHAIRS];  // ���ֱض���4����
}ReqResultDepositClean, *LPReqResultDepositClean;

// 3. ��ȡ��ȡ���ú�ʣ�����req
typedef struct{
    int nUserID;
}ReqResultRestoreConfig, *LPReqResultRestoreConfig;

// ��ȡ��ȡ������ʣ������ӿ�rsp
typedef struct
{
    int nUserID;
    int nRestoreCount;
    int nDoubleCount;
}RspResultRestoreConfig, *LPRspResultRestoreConfig;

// 4. �콱�ӿ�(����ͷ���)
typedef struct{
    int nUserID;
    int nDeposit;       // ��ǰ������Ӯ�仯: -100������100, +100����Ӯ100
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
}ReqResultRestoreAward, *LPReqResultRestoreAward;

// �콱Rsp��assist
typedef struct
{
    int nUserID;
    int nDeposit;   // ��ȡ������������
    int nStatus;   // ����״̬
    int nCount;     // ���������⻹�Ƿ������������ز�ͬ���͵�ʣ������
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
}RspResultRestoreAwardForAssist, *LPRspResultRestoreAwardForAssist;

// �콱Rsp��app
typedef struct
{
    int nUserID;
    int nDeposit;   // ��ȡ������������
    int nStatus;   // ����״̬
    int nCount;     // ���������⻹�Ƿ������������ز�ͬ���͵�ʣ������
}RspResultRestoreAward, *LPRspResultRestoreAward;