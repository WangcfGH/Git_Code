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

    std::string             name_;          //��Ҫ���ĸ�logerrule��д��־
    RecordFunction          data_;          //д��־�ıհ�

    _tagLogerRecord(const std::string& name, RecordFunction data) :
        name_(name), data_(data) {}
} DataLogerRecord;

template <typename T, typename CT = int>
struct DataLogerRecordParser
{
    template <typename... Args>
    static DataLogerRecord::Ptr Parse(const std::string& name, Args&& ... args)
    {
        static_assert(0, "�ػ�ʵ���Լ��ķ���");
        return nullptr;
    }

    static std::string ToCommitKey(CT& ct)
    {
        static_assert(0, "�ػ��Լ���ʵ��");
        return std::string();
    }

};


struct DataLogerRule
{
    typedef std::shared_ptr<DataLogerRule>          Ptr;
    typedef std::list<DataLogerRecord::Ptr>         RecordList;
    typedef std::map<std::string, RecordList>       CommitRecordMap;

    CString                     inifile_;       //�����ļ�
    bool                        enable_;        //�Ƿ���
    std::string                 fe_;            //�ļ���չ����
    std::string                 file_;          //�ļ���ȫ·����
    RecordFunction              header_;        //����ͷ
    std::fstream                fs_;            //д����ļ�
    time_t                      timestamp_;     //��־ʱ���
    RecordList                  recordList_;    //Ҫд�����־
    CommitRecordMap             commitRecordMap_;//��Ҫд���commit��־Ⱥ
    std::ios_base::_Openmode    mode_;          //�ļ���д�뷽ʽ
public:
    std::string                 name_;          //rule������

    //Ŀǰ��дģʽֻ��app��out����
    DataLogerRule(CString inifile, std::string& name, const std::string& fe, RecordFunction header, std::ios_base::_Openmode mode = std::ios_base::app);

    std::string Dir();

    struct tm ToTM(time_t t);
    // �����ļ�����дͷ
    bool Init();

    // ������һ���ļ�����дͷ
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
        TIMER_FRESH_LOGER_FILE = 0,     //ˢ����־�ļ����ֵĶ�ʱ��,1min���
        TIMER_WRITE_RECORD,
        TIMER_FRESHH_LOGGER_RULE,
        TIMER_CUSTOM,
    };

    DataLogerModule(CString striNiFile);

    // ������Ҫ��start֮�����Ч
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

    // ˢ����־�ļ����ƵĶ�ʱ��
    virtual BOOL OnTimerFreshFile(UINT id);

    // ����д��־�Ķ�ʱ�� [ʱ���������þ���]
    BOOL OnTimerWriteRecord(UINT id);

    // ˢ����־������
    virtual BOOL OnTimerFreshRule(UINT id);

    typedef std::map<std::string, DataLogerRule::Ptr>               LogerRuleMap;
    LogerRuleMap        m_logerRule;

private:
    CString             m_szIniFile;
};


// ֻ��һ����־ά��
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