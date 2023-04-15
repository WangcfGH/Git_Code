#pragma once

#pragma warning(disable:4786)

#include <map>
#include <set>
#include <sstream>

enum
{
    MSGRECORD_MODE_DAY = 0,
    MSGRECORD_MODE_HOUR = 1,
    MSGRECORD_MODE_HOUR2 = 2,
};

class CMsgRecorder
{
protected:
    struct MSG_RECORD
    {
        int request_id, user_id, game_id, session_id, response_id;
    };

    typedef std::map<SOCKET, std::pair<ULONGLONG, MSG_RECORD> > recorder_map;
    typedef std::set<std::pair<ULONGLONG, SOCKET> > recorder_set;
    typedef recorder_map::iterator recorder_map_itor;
    typedef recorder_set::iterator recorder_set_itor;

    recorder_map _map;
    recorder_map _printMap;
    recorder_set _set;
    unsigned int _limit;
    int          _mode;
    CCritSec     _mutex;
    HANDLE  m_hThreadMsgRecorder;
    UINT    m_uiThreadMsgRecorder;

    virtual void OnWriteLog(const char* log, int theardId);
    virtual ULONGLONG GetCurrentTimestamp();
    virtual std::string GetFormatDataTime(ULONGLONG ts);
    virtual ULONGLONG GetData(ULONGLONG ts);
public:
    CMsgRecorder(unsigned int _l, int _m = MSGRECORD_MODE_DAY);
    ~CMsgRecorder();

    typedef struct _tagMSG_RECORDER
    {
        SOCKET  hSocket;
        int     response_id;
        int     session_id;
        int     nThread_id;
        int     nListCount;
    } MSG_RECORDER, *LPMSG_RECORDER;

    virtual BOOL CreateMsgRecorderThread();
    unsigned MsgRecorderThreadProc();
    static unsigned __stdcall MsgRecorderThreadFunc(LPVOID lpVoid);
    virtual void OnClientRequest(SOCKET sock, int request_id, int user_id, int game_id, int session_id);
    virtual void OnServerResponse(SOCKET sock, int response_id, int session_id, int nTheardId, int nListCount);
    virtual BOOL MsgServerResponse(LPMSG_RECORDER pRecorder);
    virtual int getInterval();
    virtual void setInterval(int model);
    virtual void setEnable(BOOL enable);
    virtual void OnHourTriggered(int wHour); //每小时触发一次
    int m_nModel;
    BOOL m_bEnable;
};

