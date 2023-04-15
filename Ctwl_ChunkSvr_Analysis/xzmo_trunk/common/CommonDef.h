#pragma once
#include "..\common\ProjectDef.h"

#define CONNECT_CHUNKSVR_WAIT   10          // waittime(seconds)
#define CHUNKSVR_RESPONSE_WAIT  10000       // waittime(millisec)
#define CONNECTS_TO_CHUNKSVR    1           // connects
#define CLIENT_INITIAL_RECVS    10          // recvs
#define DEF_SERVERPULSE_INTERVAL 60         //seconds 定时检查Svr发过来的脉搏(发送间隔默认10秒)
#define DEF_TIMER_INTERVAL      5           // minitues
#define MIN_TIMER_INTERVAL      1           // minitues
#define DEF_KICKOFF_MODE        2           // clock mode
#define DEF_KICKOFF_TIMING      6           // AM 6:00 clock at morning
#define DEF_KICKOFF_ELAPSE      (DEF_TIMER_INTERVAL * 12) // minitues

#define MAX_DB_CATALOG_LEN 32
#define MAX_CHUNKDB_SOURCE_LEN  128

#define NAME_CHUNKDB_MAIN           _T("MAIN")
#define NAME_CHUNKDB_GAME           _T("GAME")
#define NAME_CHUNKDB_LOG            _T("LOG")

#define CR_LOCAL_IP                 "127.0.0.1"

enum
{

    TYPE_CHUNKDB_MAIN = 0,
    TYPE_CHUNKDB_GAME,
    TYPE_CHUNKDB_LOG,
    TYPE_CHUNKDB_MAX
};

enum FUNC_TYPE
{
    FUNC_TYPE_BEGIN = 0,
    FUNC_TYPE_LOTTERY,
    FUNC_TYPE_SWITCH_CHAIR,
    FUNC_TYPE_SURRENDER,
    FUNC_TYPE_MAX
};

#define MAX_MAP_SIZE  100000

typedef struct _tagCHUNK_DB
{
    int nID;
    int nType;
    TCHAR szName[MAX_SERVERNAME_LEN];
    TCHAR szSource[MAX_CHUNKDB_SOURCE_LEN];
    TCHAR szCatalog[MAX_DB_CATALOG_LEN];
    TCHAR szUserName[MAX_USERNAME_LEN];
    TCHAR szPassword[MAX_PASSWORD_LEN];
    int nSecurityMode;
    int nReserved[4];
} CHUNK_DB, *LPCHUNK_DB;



typedef CList<int, int&>         CIntList;
typedef CMap<LONG, LONG, SOCKET, SOCKET> CTokenSockMap;
typedef CMap<int, int, LONG, LONG> CClientTokenMap;
typedef CMap<CString, LPCTSTR, LONG, LONG&>  CStringLONGMap;
typedef CMap<int, int, CClientTokenMap*, CClientTokenMap*&> CGameSvrTokenMap;
typedef CMap<CString, LPCTSTR, int, int&>  CStringINTMap;

/************************************************************************/
/*  define of string res : AssitSvr/GameSvr Strings
/************************************************************************/
#define ASS_USERID_MISMATCH         _T("用户ID不匹配")
#define ASS_HARDID_MISMACCH         _T("硬件ID不匹配")
#define ASS_PARAM_NOTVERIFY         _T("AssitSvr:参数验证失败")
#define ASS_USER_NOTLOGON           _T("AssitSvr:用户未登录")
#define ASS_GETPROP_FAIL            _T("获取道具信息失败")
#define ASS_LUCKYCARD_ZERO          _T("手气卡用完了!")
#define ASS_USECARD_FAIL            _T("使用手气卡失败!")



#include <MAP>
#include <VECTOR>

template <typename K, typename V>
class SynMap
{
    typedef std::map<K, V> KVMap;
public:
    SynMap& insert(const K& k, V& v)
    {
        CAutoLock lock(&m_csLock);
        m_data[k] = v;
        return *this;
    }
    bool GetValue(const K& k, V& v)
    {
        CAutoLock lock(&m_csLock);
        if (m_data.count(k))
        {
            v = m_data[k];
            return true;
        }
        return false;
    }
    bool SwapValue(const K& k, V& v, V& ov)
    {
        CAutoLock lock(&m_csLock);
        if (m_data.count(k))
        {
            ov = m_data[k];
            m_data[k] = v;
            return true;
        }
        m_data[k] = v;
        return false;
    }
    int Size()
    {
        CAutoLock lock(&m_csLock);
        return m_data.size();
    }

    void Clear()
    {
        CAutoLock lock(&m_csLock);
        m_data.swap(KVMap());
    }

    V& operator [](const K& k)
    {
        CAutoLock lock(&m_csLock);
        return m_data[k];
    }
private:
    CCritSec        m_csLock;
    KVMap           m_data;
};

template <typename T>
class SynVector
{
public:
    void PushBack()
    {
        CAutoLock lock(&m_csLock);
        m_data.push_back(t);
    }

    template <typename FUNC, typename D>
    bool GetOneForFunc(FUNC f, D& d, T& t)
    {
        CAutoLock lock(&m_csLock);
        std::vector<T>::iterator it = m_data.begin();
        for (; it != m_data.end(); ++it)
        {
            if (f(*it, d))
            {
                t = *it;
                return true;
            }
        }
        return false;
    }

    bool GetAllData(std::vector<T>& data)
    {
        CAutoLock lock(&m_csLock);
        data = m_data;
        return !data.empty();
    }
    void UpdateData(std::vector<T>& data)
    {
        CAutoLock lock(&m_csLock);
        m_data = data;
    }

    template <typename FUNC>
    void UpdateData(FUNC f, T& t)
    {
        CAutoLock lock(&m_csLock);
        f(m_data, t);
    }

    void Clear()
    {
        CAutoLock lock(&m_csLock);
        m_data.clear();
    }
private:
    CCritSec        m_csLock;
    std::vector<T>  m_data;
};

template <typename K, typename L>
class SynMapVector
{
    typedef std::vector<L>                  TVector;
    typedef std::map<K, std::vector<L> >    TMapVector;
public:
    bool GetList(const K& k, std::vector<L>& v)
    {
        CAutoLock lock(&m_csLock);
        if (m_data.count(k))
        {
            v = m_data[k];
            return !v.empty();
        }
        return false;
    }
    void InsertValue(const K& k, L& l)
    {
        CAutoLock lock(&m_csLock);
        m_data[k].push_back(l);
    }
    void UpdateValue(const K& k, std::vector<L>& v)
    {
        CAutoLock lock(&m_csLock);
        m_data[k] = v;
    }
    template <typename FUNC, typename D>
    void UpdateValue(const K& k, FUNC f, D& d)
    {
        CAutoLock lock(&m_csLock);
        if (m_data.count(k))
        {
            TVector& v = m_data[k];
            f(v, d);
        }
    }
    void Clear()
    {
        CAutoLock lock(&m_csLock);
        m_data.swap(TMapVector());
    }

    template <typename FUNC, typename D>
    bool GetOneForFunc(const K& k, FUNC f, const D& d, L& l)
    {
        CAutoLock lock(&m_csLock);
        if (m_data.count(k))
        {
            TVector& v = m_data[k];
            TVector::iterator i = v.begin();
            for (; i != v.end(); ++i)
            {
                if (f(*i, d))
                {
                    l = *i;
                    return true;
                }
            }
        }
        return false;
    }
private:
    CCritSec m_csLock;
    TMapVector m_data;
};