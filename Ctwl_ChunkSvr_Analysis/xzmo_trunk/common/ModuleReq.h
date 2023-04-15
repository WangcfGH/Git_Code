#pragma once

enum MODULEGAMEMSGEX
{
    //��Ϸ��Ϣ
    MODULE_GAMEMSGEX_BEGIN = 20000000 + 1,
    //����ģ��
    MODULE_MSG_SHARE,
    //ǩ��ģ��
    MODULE_MSG_CHECKIN,
    MODULE_MSG_FRESH_CHECKIN,

    MODULE_MSG_VOICE,

    MODULE_GAMEMSGEX_END
};
//����ģ��
#define MODULE_NAME_SHARE       "module_share"
//ǩ��ģ��
#define MODULE_NAME_CHECKIN     "module_checkin"
//����ģ��
#define MODULE_NAME_TASK        "module_task"
//��ά��ģ��
#define MODULE_NAME_ERWEIMA     "module_erweima"
//����ģ��
#define MODULE_NAME_VOICE       "module_voice"

//////////////////////////check in module start//////////
#define TOTAL_DAYS  5
#define HALL_NAME   "XXXX"

typedef struct _tagUSER_CHECK_IN
{
    BOOL            bEnable;                //���Ч

    int             nStartTime;
    int             nEndTime;
    int             nNowTime;
    int             nCheckTime;
    int             nCheckCount;            //��������
    int             nAwardSocre;            //��������

    int             nScoreOneDay[TOTAL_DAYS];

    int             nReserved;
} USER_CHECK_IN, *LPUSER_CHECK_IN;
//////////////////////////check in module end//////////

///////////////////////////ErWeiMa begin/////////////////////
typedef struct tagPhoneURL_t
{
    int nQRCodeURLLen;                  // ����
    TCHAR szQRCodeURL[MAX_URL_LEN];     // ��ά�����ص�ַ
    int nOfficialURLLen;                // ����
    TCHAR szOfficialURL[MAX_URL_LEN];   // ������ַ
    int nReserved[8];
} PhoneURL_t, *LPPhoneURL_t;
///////////////////////////ErWeiMa end/////////////////////


//////////////////////////voice module start//////////
typedef struct _tagSOUND_INDEX
{
    int nChairNO;
    int nIndex;
} SOUND_INDEX;

//////////////////////////voice module end//////////