#pragma once
#include "xygdata2.h"

typedef struct _tagCARD_ROBOT_TING
{
    int     nCardID;
    int     nThrowTingTotal;
    int     nThrowGainMost;
} CARD_ROBOT_TING, *LPCARD_ROBOT;

class CMyRobot :
    public CBaseRobot
{
public:
    CMyRobot(int userid);
    ~CMyRobot();
};

#define     WM_RTG_ROBOT_INFO           (WM_GTR_RTG_CUSTOM_START+1)     //通知GameSvr机器人性格等信息
#define     WM_RTG_ROBOT_LEAVE          (WM_GTR_RTG_CUSTOM_START+2)     //通知GameSvr机器人需要离开

