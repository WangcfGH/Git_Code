#include "stdafx.h"
#include "DataLoger.h"
#include <cassert>


DataLogerModule::DataLogerModule(CString striNiFile) : m_szIniFile(striNiFile)
{

}


void DataLogerModule::SetLoger(const std::string& name, DataLogerRule::Ptr rule)
{
    auto self = shared_from_this();
    auto f = [rule, self, this]()
    {
        auto it = m_logerRule.find(rule->name_);
        if (it != m_logerRule.end())
        {
            // 不能重复的设置
            return;
        }
        m_logerRule.insert(std::make_pair(rule->name_, rule));
        rule->Init();
        rule->Fresh();
    };
    THIS_POST_CHECK(f);
}


void DataLogerModule::EraseLoger(const std::string& name)
{
    auto self = shared_from_this();
    auto f = [name, self, this]()
    {
        m_logerRule.erase(name);
    };
    THIS_POST_CHECK(f);
}

void DataLogerModule::PushRecord(DataLogerRecord::Ptr record)
{
    auto self = shared_from_this();
    auto f = [self, this, record]()
    {
        auto it = m_logerRule.find(record->name_);
        if (it != m_logerRule.end())
        {
            it->second->PushRecord(record);
        }
    };
    THIS_POST_CHECK(f);
}

void DataLogerModule::PrePushRecord(const std::string& ctname, DataLogerRecord::Ptr record)
{
    auto self = shared_from_this();
    auto f = [self, this, record, ctname]()
    {
        auto it = m_logerRule.find(record->name_);
        if (it != m_logerRule.end())
        {
            it->second->PrePushRecord(ctname, record);
        }
    };
    THIS_POST_CHECK(f);
}

void DataLogerModule::CommitRecord(const std::string& name, const std::string& ctname)
{
    auto self = shared_from_this();
    auto f = [name, ctname, self, this]()
    {
        auto it = m_logerRule.find(name);
        if (it != m_logerRule.end())
        {
            it->second->CommitRecord(ctname);
        }
    };
    THIS_POST_CHECK(f);
}

BOOL DataLogerModule::_OnInit()
{
    //WORKER_SET_TIMER_WITH_FUNC(TIMER_FRESH_LOGER_FILE, 60 * 1000, &DataLogerModule::OnTimerFreshFile);

    int interval = GetPrivateProfileInt(_T("LogerTimer"), _T("Interval"), 15, m_szIniFile);
    WORKER_SET_TIMER_WITH_FUNC(TIMER_WRITE_RECORD, interval * 1000, &DataLogerModule::OnTimerWriteRecord);

    interval = GetPrivateProfileInt(_T("LogerTimer"), _T("FreshRule"), 15, m_szIniFile);
    WORKER_SET_TIMER_WITH_FUNC(TIMER_FRESHH_LOGGER_RULE, interval * 1000, &DataLogerModule::OnTimerFreshRule);

    return TRUE;
}

VOID DataLogerModule::_OnDestroy()
{
    OnTimerWriteRecord(0);
    m_logerRule.clear();
}

BOOL DataLogerModule::OnTimerFreshFile(UINT id)
{
    auto f = [this]()
    {
        for (auto i : m_logerRule)
        {
            i.second->Next();
        }
    };
    THIS_POST_CHECK(f);
    return TRUE;
}

BOOL DataLogerModule::OnTimerWriteRecord(UINT id)
{
    int interval = GetPrivateProfileInt(_T("LogerTimer"), _T("Interval"), 15, m_szIniFile);
    WORKER_SET_TIMER_WITH_FUNC(TIMER_WRITE_RECORD, interval * 1000, &DataLogerModule::OnTimerWriteRecord);

    for (auto i : m_logerRule)
    {
        i.second->WriteAllRecord();
        i.second->ClearAllRecord();
    }
    return TRUE;
}

BOOL DataLogerModule::OnTimerFreshRule(UINT id)
{
    int interval = GetPrivateProfileInt(_T("LogerTimer"), _T("FreshRule"), 15, m_szIniFile);
    WORKER_SET_TIMER_WITH_FUNC(TIMER_FRESHH_LOGGER_RULE, interval * 1000, &DataLogerModule::OnTimerFreshRule);

    for (auto i : m_logerRule)
    {
        i.second->Fresh();
    }
    return TRUE;
}

DataLogerRule::DataLogerRule(CString inifile, std::string& name, const std::string& fe, RecordFunction header, std::ios_base::_Openmode mode)
    : inifile_(inifile), name_(name), fe_(fe), header_(header), mode_(mode)
{

}

std::string DataLogerRule::Dir()
{
    char szFilePath[MAX_PATH] = { 0 };
    GetModuleFileName(NULL, szFilePath, MAX_PATH);
    *strrchr(szFilePath, '\\') = 0;
    return std::string(szFilePath);
}

struct tm DataLogerRule::ToTM(time_t t)
{
    tm tm_;
    localtime_s(&tm_, &t);
    return std::move(tm_);
}

bool DataLogerRule::Init()
{
    assert(!fs_.is_open()); //不能重复打开文件
    timestamp_ = time(nullptr);
    tm t = ToTM(timestamp_);

    std::stringstream ss;
    //ss << Dir() << "\\" << name_ << std::put_time(&t, "%Y%m%d_%H") << fe_;
    ss << Dir() << "\\" << name_ << std::put_time(&t, "%Y%m%d") << fe_;
    file_ = ss.str();

    fs_.open(ss.str().c_str(), mode_);
    assert(fs_.is_open());
    assert(header_);
    fs_.seekg(0, std::ios::end);
    if (0 == fs_.tellp())
    {
        fs_ << header_();
        fs_ << std::flush;
    }
    return fs_.is_open();
}

bool DataLogerRule::isExpired()
{
    auto now = time(nullptr);
    tm tn = ToTM(now);
    tm tm = ToTM(timestamp_);

    //just fot test
    //if ((tn.tm_year > tm.tm_year) || (tn.tm_yday > tm.tm_yday) || (tn.tm_hour > tm.tm_hour))
    if ((tn.tm_year > tm.tm_year) || (tn.tm_yday > tm.tm_yday))
    {
        return true;
    }
    return false;
}

void DataLogerRule::Next()
{
    auto now = time(nullptr);
    tm tn = ToTM(now);
    tm tm = ToTM(timestamp_);

    //just fot test
    //if ((tn.tm_year > tm.tm_year) || (tn.tm_yday > tm.tm_yday) || (tn.tm_hour > tm.tm_hour))
    if ((tn.tm_year > tm.tm_year) || (tn.tm_yday > tm.tm_yday))
    {
        timestamp_ = now;

        //刷新文件
        std::stringstream ss;
        //ss << Dir() << "\\" << name_ << std::put_time(&tn, "%Y%m%d_%H") << fe_;
        ss << Dir() << "\\" << name_ << std::put_time(&tn, "%Y%m%d") << fe_;
        fs_.close();
        fs_.open(ss.str().c_str(), mode_);
        file_ = ss.str();
        assert(fs_.is_open());
        fs_ << header_();
        fs_ << std::flush;
    }
}

void DataLogerRule::Fresh()
{
    enable_ = GetPrivateProfileInt(name_.c_str(), _T("Enable"), 0, inifile_) != 0;
}

void DataLogerRule::PushRecord(DataLogerRecord::Ptr record)
{
    if (enable_)
    {
        recordList_.push_back(record);
    }
}

void DataLogerRule::WriteAllRecord()
{
    if (mode_ == std::ios_base::out)
    {
        return;//覆写模式不能定时刷数据
    }

    for (auto i : recordList_)
    {
        assert(i->name_ == name_);
        assert(i->data_);
        assert(fs_.is_open());

        fs_ << i->data_() << std::flush;
    }
}

void DataLogerRule::ClearAllRecord()
{
    recordList_.clear();
}

void DataLogerRule::PrePushRecord(const std::string& name, DataLogerRecord::Ptr record)
{
    if (enable_)
    {
        commitRecordMap_[name].push_back(record);
    }
}

void DataLogerRule::CommitRecord(const std::string& ctname)
{
    auto it = commitRecordMap_.find(ctname);
    if (it == commitRecordMap_.end())
    {
        return;
    }

    if (mode_ == std::ios_base::out)
    {
        fs_.close();
        fs_.open(file_, std::ios_base::out | std::ios_base::trunc);
        fs_.seekg(std::ios::beg);
        fs_ << header_();
        fs_ << std::flush;
    }

    for (auto i : it->second)
    {
        assert(i->name_ == name_);
        assert(i->data_);
        assert(fs_.is_open());

        fs_ << i->data_() << std::flush;
    }
    commitRecordMap_.erase(it);
}

DataLogerOwn::DataLogerOwn(CString strIniFile):
    DataLogerModule(strIniFile)
{

}

void DataLogerOwn::SetLoger(const std::string& name, DataLogerRule::Ptr rule)
{
    g_logername = name;
    __super::SetLoger(name, rule);
}

std::string DataLogerOwn::g_logername;

