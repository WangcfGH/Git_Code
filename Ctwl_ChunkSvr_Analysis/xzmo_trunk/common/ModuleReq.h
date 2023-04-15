#pragma once

enum MODULEGAMEMSGEX
{
    //游戏消息
    MODULE_GAMEMSGEX_BEGIN = 20000000 + 1,
    //分享模块
    MODULE_MSG_SHARE,
    //签到模块
    MODULE_MSG_CHECKIN,
    MODULE_MSG_FRESH_CHECKIN,

    MODULE_MSG_VOICE,

    MODULE_GAMEMSGEX_END
};
//分享模块
#define MODULE_NAME_SHARE       "module_share"
//签到模块
#define MODULE_NAME_CHECKIN     "module_checkin"
//任务模块
#define MODULE_NAME_TASK        "module_task"
//二维码模块
#define MODULE_NAME_ERWEIMA     "module_erweima"
//语音模块
#define MODULE_NAME_VOICE       "module_voice"

//////////////////////////check in module start//////////
#define TOTAL_DAYS  5
#define HALL_NAME   "XXXX"

typedef struct _tagUSER_CHECK_IN
{
    BOOL            bEnable;                //活动有效

    int             nStartTime;
    int             nEndTime;
    int             nNowTime;
    int             nCheckTime;
    int             nCheckCount;            //连续次数
    int             nAwardSocre;            //奖励分数

    int             nScoreOneDay[TOTAL_DAYS];

    int             nReserved;
} USER_CHECK_IN, *LPUSER_CHECK_IN;
//////////////////////////check in module end//////////

///////////////////////////ErWeiMa begin/////////////////////
typedef struct tagPhoneURL_t
{
    int nQRCodeURLLen;                  // 长度
    TCHAR szQRCodeURL[MAX_URL_LEN];     // 二维码下载地址
    int nOfficialURLLen;                // 长度
    TCHAR szOfficialURL[MAX_URL_LEN];   // 官网地址
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