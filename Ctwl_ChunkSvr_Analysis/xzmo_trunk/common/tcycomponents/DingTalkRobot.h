#if   !defined(_TC_DING_TALK_ROOT_H_)
#define   _TC_DING_TALK_ROOT_H_

#if   _MSC_VER   >   1000
    #pragma   once
#endif   //   _MSC_VER   >   1000
#include   "wininet.h"
#include   "afxinet.h"
#include "plana.h"

#define DINGTALK_ROBOT_BASE_URL "https://oapi.dingtalk.com/robot/send?access_token="

typedef struct _tagDINGTALKROBOT_ACTIONCARD_BTNS
{
    CString szTitle;
    CString szActionURL;
} DINGTALKROBOT_ACTIONCARD_BTNS, *LPDINGTALKROBOT_ACTIONCARD_BTNS;

typedef struct _tagDINGTALKROBOT_FEEDCARD_LINKS
{
    CString szTitle;
    CString szMessageURL;
    CString szPicURL;
} DINGTALKROBOT_FEEDCARD_LINKS, *LPDINGTALKROBOT_FEEDCARD_LINKS;


struct MsgToDingRobot
{
    std::string strToken;
    std::string strContext;
    bool isAtAll;
    std::vector<CString> vecAtMobile;
};

class CDingTalkRobot : public plana::threadpools::PlanaStaff
{
public:
    CDingTalkRobot();
    CDingTalkRobot(const char* szToken);
    virtual     ~CDingTalkRobot();

public:
    // 设置向哪个钉钉群发
    void InitToken(const char* szToken);

    //五种机器人消息;

    /**
    * 发送文本消息到钉钉机器人
    * strContext: 文本内容
    * isAtAll: 是否@所有人
    * vecAtMobile: 被@人的手机号(在text内容里要有@手机号)
    */
    void NoticeTextToDingTalkRobot(const char* strContext, bool isAtAll, std::vector<CString>& vecAtMobile);
    void evNoticeTextToDingTalkRobot(MsgToDingRobot& msg);

    void NoticeLinkToDingTalkRobot(const char* strContext, const char* strTitle, const char* messageUrl, const char* picUrl = "");
    void NoticeMarkDownToDingTalkRobot(const char* strContext, const char* strTitle, bool isAtAll = false, std::vector<CString> vecAtMobile = {});
    void NoticeActionCardToDingTalkRobot(const char* strContext, const char* strTitle, const char* singleTitle, const char* singleURL, int btnOrientation = 0, int hideAvatar = 0);
    void NoticeActionCardToDingTalkRobot(const char* strContext, const char* strTitle, std::vector<DINGTALKROBOT_ACTIONCARD_BTNS> vecBtns = {}, int btnOrientation = 0, int hideAvatar = 0);
    void NoticeFeedCardToDingTalkRobot(std::vector<DINGTALKROBOT_FEEDCARD_LINKS> vecLinks = {});

private:
    void        releaseHeaders();
    void        addHeaders(CString name, CString value);
    void        setBodyJson(CString strJSON);
    CString     doPost(CString href);
    CString     GBKToUtf8(LPCTSTR szAnsi);
    BOOL DingDingRootPostHttp(const char* strJson);
private:
    CString     m_szUrlContent;
    CStringList m_listUrlHeaders;
    CString m_szToken;
};

#endif   //   !defined(_TC_DING_TALK_ROOT_H_)   
