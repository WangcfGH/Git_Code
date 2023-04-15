#pragma once

#pragma warning(once:4996)

#define GR_DATARECORD_LOG_USERBEHAVIOR  (GAME_REQ_INDIVIDUAL+4120)      // 川麻13.9 用户点击埋点

#define GR_DATARECORD_APP_UPLOAD        (GAME_REQ_INDIVIDUAL+4102)      // 客户端上传数据
#define GR_DATARECORD_NEW_APP_UPLOAD    (GAME_REQ_INDIVIDUAL+4104)      // 客户端上传数据的新协议
#define GR_DATARECORD_LOG_FUNC_USED     (GAME_REQ_INDIVIDUAL+4110)      // 用户功能使用率上传数据

#define DR_TIMESTR_SIZE         20
#define DR_MAX_VERSION_SIZE     16

typedef struct _tagUserBehavior
{
    int     nUserID;
    int     nBehaviorID;
    TCHAR   szGameVersion[DR_MAX_VERSION_SIZE];
    TCHAR   szPlatformVersion[DR_MAX_VERSION_SIZE];
    TCHAR   szChannelID[DR_MAX_VERSION_SIZE];
    //TCHAR   szRecordTime[DR_TIMESTR_SIZE];
} USERBEHAVIOR, *LPUSERBEHAVIOR;