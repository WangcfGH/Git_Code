#pragma once
#include <memory>
#include <fstream>
#include <chrono>
#include <ctime>
#include <sstream>
#include <iomanip>
#include <list>
#include "../tool/WorkThread.h"

typedef std::function<std::string()>    RecordFunction;

typedef struct _tagLogerRecord
{
    typedef std::shared_ptr<_tagLogerRecord>            Ptr;

    std::string             name_;          //想要往哪个logerrule中写日志
    RecordFunction          data_;          //写日志的闭包

    _tagLogerRecord(const std::string& name, RecordFunction data) :
        name_(name), data_(data) {}
} DataLogerRecord;

template <typename T, typename CT = int>
struct DataLogerRecordParser
{
    template <typename... Args>
    static DataLogerRecord::Ptr Parse(const std::string& name, Args&& ... args)
    {
        static_assert(0, "特化实现自己的方法");
        return nullptr;
    }

    static std::string ToCommitKey(CT& ct)
    {
        static_assert(0, "特化自己的实现");
        return std::string();
    }

};


struct DataLogerRule
{
    typedef std::shared_ptr<DataLogerRule>          Ptr;
    typedef std::list<DataLogerRecord::Ptr>         RecordList;
    typedef std::map<std::string, RecordList>       CommitRecordMap;

    CString                     inifile_;       //配置文件
    bool                        enable_;        //是否开启
    std::string                 fe_;            //文件扩展名称
    std::string                 file_;          //文件的全路径名
    RecordFunction              header_;        //生成头
    std::fstream                fs_;            //写入的文件
    time_t                      timestamp_;     //日志时间戳
    RecordList                  recordList_;    //要写入的日志
    CommitRecordMap             commitRecordMap_;//需要写入的commit日志群
    std::ios_base::_Openmode    mode_;          //文件的写入方式
public:
    std::string                 name_;          //rule的名称

    //目前读写模式只有app和out两种
    DataLogerRule(CString inifile, std::string& name, const std::string& fe, RecordFunction header, std::ios_base::_Openmode mode = std::ios_base::app);

    std::string Dir();

    struct tm ToTM(time_t t);
    // 创建文件，并写头
    bool Init();

    // 创建下一个文件，并写头
    void Next();

    bool isExpired();

    // fresh enable
    void Fresh();

    void PushRecord(DataLogerRecord::Ptr record);

    void WriteAllRecord();

    void ClearAllRecord();

    void PrePushRecord(const std::string& ctname, DataLogerRecord::Ptr record);

    void CommitRecord(const std::string& ctname);
};


class DataLogerModule : public WorkThread, public std::enable_shared_from_this<DataLogerModule>
{
public:
    enum
    {
        TIMER_FRESH_LOGER_FILE = 0,     //刷新日志文件名字的定时器,1min间隔
        TIMER_WRITE_RECORD,
        TIMER_FRESHH_LOGGER_RULE,
        TIMER_CUSTOM,
    };

    DataLogerModule(CString striNiFile);

    // 操作都要在start之后才生效
    virtual void SetLoger(const std::string& name, DataLogerRule::Ptr rule);
    virtual void EraseLoger(const std::string& name);

    virtual void PushRecord(DataLogerRecord::Ptr record);
    virtual void PrePushRecord(const std::string& ctname, DataLogerRecord::Ptr record);

    template <typename T, typename...Args>
    void PushT(const std::string& name, Args&& ... args)
    {
        auto ptr = DataLogerRecordParser<T>::Parse(name, std::forward<Args>(args)...);
        PushRecord(ptr);
    }

    template <typename T, typename CT, typename...Args>
    void PrePushT(const std::string& name, CT& commitargs, Args&& ...args)
    {
        auto ctname = DataLogerRecordParser<T, CT>::ToCommitKey(commitargs);
        auto ptr = DataLogerRecordParser<T, CT>::Parse(name, std::forward<Args>(args)...);
        PrePushRecord(ctname, ptr);
    }

    virtual void CommitRecord(const std::string& name, const std::string& ctname);

    template <typename T, typename CT>
    void CommitRecordT(const std::string& name, CT& commitargs)
    {
        auto ctname = DataLogerRecordParser<T, CT>::ToCommitKey(commitargs);
        CommitRecord(name, ctname);
    }

protected:
    virtual BOOL _OnInit() override;
    virtual VOID _OnDestroy() override;

    // 刷新日志文件名称的定时器
    virtual BOOL OnTimerFreshFile(UINT id);

    // 进行写日志的定时器 [时间间隔由配置决定]
    BOOL OnTimerWriteRecord(UINT id);

    // 刷新日志的配置
    virtual BOOL OnTimerFreshRule(UINT id);

    typedef std::map<std::string, DataLogerRule::Ptr>               LogerRuleMap;
    LogerRuleMap        m_logerRule;

private:
    CString             m_szIniFile;
};


// 只有一个日志维护
class DataLogerOwn : public DataLogerModule
{
public:
    DataLogerOwn(CString strIniFile);

    virtual void SetLoger(const std::string& name, DataLogerRule::Ptr rule) override;

    template <typename T, typename...Args>
    void PushT(Args&& ... args)
    {
        auto ptr = DataLogerRecordParser<T>::Parse(g_logername, std::forward<Args>(args)...);
        PushRecord(ptr);
    }
protected:
    static std::string      g_logername;
};
//////////////////////////////////////////////////////////////////////////