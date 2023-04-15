#include "StdAfx.h"
#include   "DingTalkRobot.h"
#include   "json.h"

#ifdef  _DEBUG
    #undef  THIS_FILE
    static  char   THIS_FILE[] = __FILE__;
    #define new   DEBUG_NEW
#endif

CDingTalkRobot::CDingTalkRobot()
{
    m_szToken = "";
}

CDingTalkRobot::CDingTalkRobot(const char* szToken)
{
    InitToken(szToken);
}

CDingTalkRobot::~CDingTalkRobot()
{
}

void CDingTalkRobot::InitToken(const char* szToken)
{
    m_szToken = szToken;
}

CString CDingTalkRobot::GBKToUtf8(LPCTSTR szAnsi)
{
    CString sUtf8;

    int nUnicodeCount = MultiByteToWideChar(CP_ACP, 0, szAnsi, -1, NULL, 0);
    wchar_t* pUnicode = new wchar_t[nUnicodeCount];
    MultiByteToWideChar(CP_ACP, 0, szAnsi, -1, pUnicode, nUnicodeCount);


    int nUtf8Count = WideCharToMultiByte(CP_UTF8, 0, pUnicode, -1, NULL, 0, NULL, NULL);
    char* pUtf8 = new char[nUtf8Count];
    WideCharToMultiByte(CP_UTF8, 0, pUnicode, -1, pUtf8, nUtf8Count, NULL, NULL);

    sUtf8 = pUtf8;
    delete[] pUnicode;
    delete[] pUtf8;
    return sUtf8;
}

void CDingTalkRobot::releaseHeaders()
{
    m_listUrlHeaders.RemoveAll();
}

void CDingTalkRobot::addHeaders(CString name, CString value)
{
    m_listUrlHeaders.AddTail(name + ":" + value);
}
void CDingTalkRobot::setBodyJson(CString strJSON)
{
    m_szUrlContent = strJSON;
}

CString CDingTalkRobot::doPost(CString href)
{
    CString httpsource = "";
    CInternetSession session1;
    CHttpConnection* conn1 = NULL;
    CHttpFile* pFile = NULL;

    DWORD dwServiceType;
    CString strServerName;
    CString strObject;
    INTERNET_PORT nPort;
    AfxParseURL((LPCTSTR)href, dwServiceType, strServerName, strObject, nPort);

    DWORD retcode;
    char* outBuff = m_szUrlContent.GetBuffer(1000);
    try
    {
        conn1 = session1.GetHttpConnection(strServerName, nPort);

        pFile = conn1->OpenRequest(CHttpConnection::HTTP_VERB_POST, strObject, NULL, 1, NULL, NULL, INTERNET_FLAG_SECURE);
        pFile->AddRequestHeaders("Accept:*/*");
        POSITION pos = m_listUrlHeaders.GetHeadPosition();
        while (pos)
        {
            CString strHeader = m_listUrlHeaders.GetNext(pos);
            pFile->AddRequestHeaders(strHeader);
        }
        pFile->SendRequest(NULL, 0, outBuff, strlen(outBuff) + 1);

        pFile->QueryInfoStatusCode(retcode);
        if (retcode == HTTP_STATUS_OK)
        {
        }
    }
    catch (...)
    {
        pFile = NULL;
    };

    if (pFile)
    {
        CString text;
        for (int i = 0; pFile->ReadString(text); i++)
        {
            httpsource = httpsource + text + "\r\n";
        }
        pFile->Close();

        delete   pFile;
        delete   conn1;
        session1.Close();
    }

    return   httpsource;
}

BOOL CDingTalkRobot::DingDingRootPostHttp(const char* strJson)
{
    CString szWebhookUrl;
    if (0 == strcmp(m_szToken, ""))
    {
        return FALSE;
    }
    szWebhookUrl = DINGTALK_ROBOT_BASE_URL + m_szToken;

    CString strReq;
    strReq.Format("%s", szWebhookUrl);

    addHeaders("content-type", "application/json");

    CString strWordUtf8 = GBKToUtf8(strJson);

    setBodyJson(strWordUtf8);
    CString strRet = doPost(strReq);

    releaseHeaders();

    return TRUE;
}

void CDingTalkRobot::NoticeTextToDingTalkRobot(const char* strContext, bool isAtAll, std::vector<CString>& vecAtMobile)
{
    Json::Value rootText;
    rootText["content"] = strContext;
    Json::Value root;
    root["msgtype"] = "text";
    root["text"] = rootText;
    Json::Value rootAt;
    rootAt["isAtAll"] = isAtAll;
    Json::Value rootAtMobiles;
    for (int i = 0; i < vecAtMobile.size(); i++)
    {
        rootAtMobiles[i] = vecAtMobile[i].GetString();
    }
    rootAt["atMobiles"] = rootAtMobiles;
    root["at"] = rootAt;
    DingDingRootPostHttp(root.toStyledString().c_str());
}

void CDingTalkRobot::evNoticeTextToDingTalkRobot(MsgToDingRobot& msg)
{
    this->evp().ios().dispatch([this, msg]() mutable
    {
        InitToken(msg.strToken.c_str());
        NoticeTextToDingTalkRobot(msg.strContext.c_str(), msg.isAtAll, msg.vecAtMobile);
    });
}

void CDingTalkRobot::NoticeLinkToDingTalkRobot(const char* strContext, const char* strTitle, const char* messageUrl, const char* picUrl)
{
    Json::Value rootText;
    rootText["text"] = strContext;
    rootText["title"] = strTitle;
    rootText["messageUrl"] = messageUrl;
    rootText["picUrl"] = picUrl;
    Json::Value root;
    root["msgtype"] = "link";
    root["link"] = rootText;
    DingDingRootPostHttp(root.toStyledString().c_str());
}

void CDingTalkRobot::NoticeMarkDownToDingTalkRobot(const char* strContext, const char* strTitle, bool isAtAll, std::vector<CString> vecAtMobile)
{
    Json::Value rootText;
    rootText["title"] = strTitle;
    rootText["text"] = strContext;
    Json::Value root;
    root["msgtype"] = "markdown";
    root["markdown"] = rootText;
    Json::Value rootAt;
    rootAt["isAtAll"] = isAtAll;
    Json::Value rootAtMobiles;
    for (int i = 0; i < vecAtMobile.size(); i++)
    {
        rootAtMobiles[i] = vecAtMobile[i].GetString();
    }
    rootAt["atMobiles"] = rootAtMobiles;
    root["at"] = rootAt;
    DingDingRootPostHttp(root.toStyledString().c_str());
}

void CDingTalkRobot::NoticeActionCardToDingTalkRobot(const char* strContext, const char* strTitle, const char* singleTitle, const char* singleURL, int btnOrientation, int hideAvatar)
{
    Json::Value rootText;
    rootText["title"] = strTitle;
    rootText["text"] = strContext;
    rootText["singleTitle"] = singleTitle;
    rootText["singleURL"] = singleURL;
    rootText["btnOrientation"] = btnOrientation;
    rootText["hideAvatar"] = hideAvatar;
    Json::Value root;
    root["msgtype"] = "actionCard";
    root["actionCard"] = rootText;
    DingDingRootPostHttp(root.toStyledString().c_str());
}

void CDingTalkRobot::NoticeActionCardToDingTalkRobot(const char* strContext, const char* strTitle, std::vector<DINGTALKROBOT_ACTIONCARD_BTNS> vecBtns, int btnOrientation, int hideAvatar)
{
    Json::Value rootText;
    rootText["title"] = strTitle;
    rootText["text"] = strContext;
    rootText["btnOrientation"] = btnOrientation;
    rootText["hideAvatar"] = hideAvatar;
    Json::Value rootBtns;
    for (int i = 0; i < vecBtns.size(); i++)
    {
        rootBtns[i]["title"] = vecBtns[i].szTitle.GetString();
        rootBtns[i]["actionURL"] = vecBtns[i].szActionURL.GetString();
    }
    rootText["btns"] = rootBtns;
    Json::Value root;
    root["msgtype"] = "actionCard";
    root["actionCard"] = rootText;
    DingDingRootPostHttp(root.toStyledString().c_str());
}

void CDingTalkRobot::NoticeFeedCardToDingTalkRobot(std::vector<DINGTALKROBOT_FEEDCARD_LINKS> vecLinks)
{
    Json::Value rootText;
    Json::Value rootLinks;
    for (int i = 0; i < vecLinks.size(); i++)
    {
        rootLinks[i]["title"] = vecLinks[i].szTitle.GetString();
        rootLinks[i]["actionURL"] = vecLinks[i].szMessageURL.GetString();
        rootLinks[i]["picURL"] = vecLinks[i].szPicURL.GetString();
    }
    rootText["links"] = rootLinks;
    Json::Value root;
    root["msgtype"] = "feedCard";
    root["feedCard"] = rootText;
    DingDingRootPostHttp(root.toStyledString().c_str());
}