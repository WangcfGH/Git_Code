#pragma once
#include <iostream>
#include <unordered_map>
#include <set>
#include <cassert>
#include <array>
#include <cstdint>

// 如果要定制，需要特化如下的数据
// Config 传入了 手牌数量 HAND_CARDS_COUNT
// Config 传入了 Layout的index数量
// Config 传入了 Joker财神的数量
struct MJTableConfigDefault
{
    static const int C_HAND_CARDS_COUNT = 14;//默认14张手牌胡
    static const int C_LAYOUT_NUM = 64;// 默认最大64个方阵数量... 其实根本用不到
    static const int C_JOKER_NUM = 4;   //Joker数量

    static const int C_COLOR_COUNT = 4; //万、条、筒、风字
    static const int C_COLOR_TABLE = 9 | (9 << 4) | (9 << 8) | (7 << 12);
    static const int C_COLOR_BIT = 4;
    static const int C_COLOR_FLAG = 0x0f;
};


template <typename Config>
class MJHuUnitMake
{
public:
    typedef Config  Strategy;
    /*
    每一个 int 代表了组合的数目 32bit如下
    30 - 31: 这两位没有使用
    27 - 29: 这三位值代表 joker宝牌的数目
    24 - 26: 这三位代表  9[万,条,筒]的数目
    21 - 23: 这三位代表  8[万,条,筒]的数目
    。。。。
    0 - 2  : 这三位代表  1[万,条,筒]的数目

    使用一个int整型，表示一个可以胡的牌型[无法区分花色]

    */
    typedef std::uint64_t   Key;
    enum
    {
        // 每种牌最大index数量  比如9万；9条；9筒；风和字 最大值是7
        EM_CARD_INDEX_TOTAL = 9,
        // 每种牌只能自己相互组合所以只有9个index； 最后多一位放joker数量
        EM_CARD_INDEX_TOTAL_WITH_JOKER = EM_CARD_INDEX_TOTAL + 1,
        // 每种index对应3个bit 因为每个牌最多4张，所以3个bit能表示
        EM_BIT_VAL_NUM = 3,
        // 用于值范围的设定
        EM_BIT_VAL_FLAG = 0x07,
        // 每张牌最多4个
        EM_SINGLE_CARD_MAX_COUNT = 4,

        //////////////////////////////////////////////////////////////////////////
        EM_HAND_CARD_COUNT = Config::C_HAND_CARDS_COUNT,

        EM_UNITS_MAX_COUNT = (EM_HAND_CARD_COUNT - 2) / 3 + 1,

        EM_JOKER_COUNT = Config::C_JOKER_NUM,

        EM_LAYOUT_NUM = Config::C_LAYOUT_NUM,

        EM_LAYOUT_MOD = 10, //默认mod都是10

        EM_CARD_COLOR_COUNT = Config::C_COLOR_COUNT,
    };

    typedef unsigned char uchar;
    typedef std::array<uchar, EM_CARD_INDEX_TOTAL_WITH_JOKER>   LayIndexType;   // 用于牌型的可读的数量; 可装换为int


    // 一个可以胡的不带花色的组合
    struct HuUnits
    {
        int v[EM_UNITS_MAX_COUNT];      // 每一个int是一个牌型组合
        int units_count;
        char v_t[EM_UNITS_MAX_COUNT];       // 每个组合是个什么东西~~~ 1 顺子 2 刻字 4 对子
        char v_i[EM_UNITS_MAX_COUNT][5];    // 该组合的全部index是个啥

        HuUnits() { memset(this, 0, sizeof(*this)); }
        HuUnits(const HuUnits& other) { memcpy(this, &other, sizeof(*this)); }
        HuUnits& add_key(int key)
        {
            if (this->units_count >= EM_UNITS_MAX_COUNT)
            {
                assert(false);
            }
            v[units_count] = key;
            int count = 0;
            getArrayIndexByKey(key, v_i[units_count], v_i[units_count][5]);
            v_t[units_count] = getUnitTypeByIndex(key);
            units_count++;
            return *this;
        }
        void sort() { std::sort(v, v + units_count); }
        void delete_joker()
        {
            for (int i = 0; i < units_count; ++i)
            {
                v[i] = keyRemoveJoker(v[i]);
            }
        }
        int total_key() const
        {
            int key = 0;
            for (int i = 0; i < units_count; ++i)
            {
                key += v[i];
            }
            return key;
        }
        bool is_jiang() const
        {
            int num = getNumByKey(total_key());
            if (((num - 2) % 3) == 0)
            {
                return true;
            }
            return false;
        }
        int convert_lay(std::vector<LayIndexType>& lays, int& joker_use)
        {
            joker_use = get_total_joker_conut();
            lays.resize(units_count);
            for (int i = 0; i < units_count; ++i)
            {
                getLayIndexByKey(v[i], lays[i]);
            }
            return 0;
        }
        int get_total_joker_conut() const
        {
            int num = 0;
            for (int i = 0; i < units_count; ++i)
            {
                num += getJokerCount(v[i]);
            }
            return num;
        }
        bool operator < (const HuUnits& other) const
        {
            auto r = memcmp(this, &other, sizeof(*this));
            return r < 0;
        }
    };

    // first代表可以胡的牌型组合[无组合]; second 代表该胡牌牌型的组合
    struct RestultHunits
    {
        std::set<HuUnits>   units;
        int min_joker_use = 0;
    };
    typedef std::unordered_map<int, RestultHunits>              AllHuUnitMap;
    typedef std::array < AllHuUnitMap, EM_HAND_CARD_COUNT + 1 >    ArrayAllHuUnitMap;


    //////////////////////////////////////////////////////////////////////////
    // export api

    // 生成所有可以胡的牌型组合数据
    void genAllHuUnits()
    {
        genSingleAndJiangUnit();

        genComb(m_singleUnits, m_allHuUnits);

        genComb(m_singleFZUnits, m_allHuFzUnits);

        genCombJiang(m_jiangUnits, m_allHuUnits);

        genCombJiang(m_jiangFZUnits, m_allHuFzUnits);
    }

    // 判断某个牌型组合是否可以胡
    // lay 的mod是 10
    bool checkCanHu(int lay[], int count, int jokerIndex = -1);

    struct HuResult
    {
        enum
        {
            COUNT = EM_CARD_COLOR_COUNT
        };
        HuUnits hus[EM_CARD_COLOR_COUNT];   // COLOR_COUNT 个数，参与胡牌的每个花色的可能组合
        int valid[EM_CARD_COLOR_COUNT];
        int joker_left = 0;

        HuResult()
        {
            memset(this, 0, sizeof(*this));
        }
    };

    bool checkCanHuEx(int lay[], int count, HuResult& result, int jokerCount = 0);

    // 获取可以的所有组合 不要放财神
    int getHuUnits(int color, LayIndexType& lay, RestultHunits*& res);
protected:
    void genSingleAndJiangUnit();
    void genComb(std::set<int>& card_units, ArrayAllHuUnitMap& huUnits);
    void genCombTravel(std::vector<int>::iterator iter_start, std::vector<int>::iterator iter_end,
        ArrayAllHuUnitMap& huUnits, HuUnits& preKeys, int left);

    void genCombJiang(std::set<int>& jiangs, ArrayAllHuUnitMap& huUnits);

    void addUnitToHu(HuUnits& key_unit, ArrayAllHuUnitMap& huUnits);

    bool checkCanHuSingle(int color, LayIndexType& lay, HuUnits& unit, int joker_num);
public:
    static int getKeyByIndexWithJoker(LayIndexType& byIndex);
    static int getKeyByIndexNoJoker(LayIndexType& byIndex);
    static bool isValidKey(int key);
    static int getNumByKey(int key);
    static int getLayIndexByKey(int key, LayIndexType& byIndex);
    static int getArrayIndexByKey(int key, char indexs[4], char& count);
    static int keyRemoveJoker(int key);
    static int keyAddJoker(int key, int joker_num);
    static int getJokerCount(int key);
    static int getUnitTypeByIndex(int key);
private:
    // 这里的int 代表一个胡牌的牌型组合
    std::set<int> m_singleUnits;        // 不考虑将牌的组合
    std::set<int> m_singleFZUnits;      // 风和中发白的组合 只可能是刻字了
    std::set<int> m_jiangUnits;         // 将牌的组合
    std::set<int> m_jiangFZUnits;       // 将牌的风和中发白的组合
    // 普通9种的胡牌牌型组合
    ArrayAllHuUnitMap m_allHuUnits;
    // 风和字的胡牌牌型组合
    ArrayAllHuUnitMap m_allHuFzUnits;
};

template <typename Config>
int MJHuUnitMake<Config>::getUnitTypeByIndex(int key)
{
    char indexs[4];
    char count = 0;
    int joker_count = getArrayIndexByKey(key, indexs, count);
    if (count == 2)
    {
        return 4;   //对
    }

    if (joker_count == 0)
    {
        if (indexs[0] == indexs[1] && indexs[1] == indexs[2])
        {
            return 2;   // 刻字
        }
        else
        {
            return 1;   // 顺子
        }
    }
    else if (joker_count == 1)
    {
        if (indexs[0] == indexs[1])
        {
            return 2;   // 刻字
        }
        else
        {
            return 1;   // 顺子
        }
    }
    else if (joker_count == 2)
    {
        return 2;
    }

    assert(false);// 绝不可能走到这里
    return 4;
}

template <typename Config>
int MJHuUnitMake<Config>::getArrayIndexByKey(int key, char indexs[4], char& count)
{
    count = 0;
    int i = 0;
    for (i = 0; i < EM_CARD_INDEX_TOTAL; ++i)
    {
        int n = ((key >> (EM_BIT_VAL_NUM * i))&EM_BIT_VAL_FLAG);
        for (int j = 0; j < n; ++j)
        {
            indexs[count++] = i + 1;
        }
    }
    int n = ((key >> (EM_BIT_VAL_NUM * i))&EM_BIT_VAL_FLAG);
    for (int j = 0; j < n; ++j)
    {
        indexs[count++] = -1;
    }
    return n;
}

template <typename Config>
int MJHuUnitMake<Config>::getLayIndexByKey(int key, LayIndexType& byIndex)
{
    int num = 0;
    for (int i = 0; i < EM_CARD_INDEX_TOTAL_WITH_JOKER; ++i)
    {
        byIndex[i] = ((key >> (EM_BIT_VAL_NUM * i))&EM_BIT_VAL_FLAG);
        num += byIndex[i];
    }
    return num;
}

template <typename Config>
bool MJHuUnitMake<Config>::checkCanHuEx(int lay[], int count, HuResult& result, int joker_count)
{
    if (joker_count > EM_JOKER_COUNT)
    {
        return false;
    }

    int jiangNum = 0;
    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        int nMax = (Config::C_COLOR_TABLE >> i *  Config::C_COLOR_BIT) & Config::C_COLOR_FLAG;
        int safe_count = (count - EM_LAYOUT_MOD * i) < nMax ? (count - EM_LAYOUT_MOD * i) : nMax;
        nMax = std::min<int>(nMax, safe_count);

        int nCardAll = 0;
        for (int n = 1; n <= nMax; ++n)
        {
            nCardAll += lay[EM_LAYOUT_MOD * i + n];
        }
        if (nCardAll == 0)
        {
            continue;
        }

        LayIndexType layTmp;
        memset(&layTmp[0], 0, layTmp.size());
        for (int m = 1; m < safe_count; ++m)
        {
            layTmp[m - 1] = (lay + EM_LAYOUT_MOD * i)[m];
        }

        HuUnits unit;
        if (!checkCanHuSingle(i, layTmp, unit, joker_count))
        {
            return false;
        }
        result.hus[i] = unit;
        result.valid[i] = 1;

        joker_count -= unit.get_total_joker_conut();
        jiangNum += ((nCardAll + unit.get_total_joker_conut()) % 3 == 2);
        if (jiangNum > joker_count + 1)
        {
            // 如果出现多个将 除第一个将之外，其他的必须有财神匹配为刻
            return false;
        }
    }
    result.joker_left = joker_count;
    return jiangNum > 0 || joker_count >= 2;
}

template <typename Config>
int MJHuUnitMake<Config>::getHuUnits(int color, LayIndexType& lay, RestultHunits*& res)
{
    auto key = getKeyByIndexNoJoker(lay);
    auto num = getNumByKey(key);
    if (color == 3)
    {
        key &= 0x1FFFFF;    // 风字只有7位
        auto it = m_allHuFzUnits[num].find(key);
        if (it != m_allHuFzUnits[num].end())
        {
            res = &it->second;
            return res->units.size();
        }
    }
    else
    {
        auto it = m_allHuUnits[num].find(key);
        if (it != m_allHuUnits[num].end())
        {
            res = &it->second;
            return res->units.size();
        }
    }
    return 0;
}

template <typename Config>
bool MJHuUnitMake<Config>::checkCanHuSingle(int color, LayIndexType& lay, HuUnits& unit, int joker_num)
{
    auto key = getKeyByIndexNoJoker(lay);
    auto num = getNumByKey(key);
    if (color == 3)
    {

        key &= 0x1FFFFF;    // 风字只有7位
        auto it = m_allHuFzUnits[num].find(key);
        if (it != m_allHuFzUnits[num].end())
        {

            if (it->second.min_joker_use <= joker_num)
            {
                auto ith = it->second.units.begin();
                for (auto& ith : it->second.units)
                {
                    if (ith.get_total_joker_conut() == it->second.min_joker_use)
                    {
                        unit = ith;
                        return true;
                    }
                }
            }
        }
    }
    else
    {
        auto it = m_allHuUnits[num].find(key);
        if (it != m_allHuUnits[num].end())
        {
            if (it->second.min_joker_use <= joker_num)
            {
                auto ith = it->second.units.begin();
                for (auto& ith : it->second.units)
                {
                    if (ith.get_total_joker_conut() == it->second.min_joker_use)
                    {
                        unit = ith;
                        return true;
                    }
                }
            }
        }
    }

    return false;
}

template <typename Config>
bool MJHuUnitMake<Config>::checkCanHu(int lay[], int count, int jokerIndex /*= -1*/)
{
    int joker_count = 0;
    if (jokerIndex >= 0 && jokerIndex < EM_LAYOUT_NUM)
    {
        joker_count = lay[jokerIndex];
        lay[jokerIndex] = 0;
    }

    if (joker_count > EM_JOKER_COUNT)
    {
        return false;
    }

    int jiangNum = 0;
    int jokerTry[EM_CARD_COLOR_COUNT] = { 0 };
    for (int i = 0; i < EM_CARD_COLOR_COUNT; ++i)
    {
        int nMax = (Config::C_COLOR_TABLE >> i *  Config::C_COLOR_BIT) & Config::C_COLOR_FLAG;
        int safe_count = (count - EM_LAYOUT_MOD * i) < nMax ? (count - EM_LAYOUT_MOD * i) : nMax;
        nMax = std::min<int>(nMax, safe_count);

        int nCardAll = 0;
        for (int n = 0; n < nMax; ++n)
        {
            nCardAll += lay[EM_LAYOUT_MOD * i + n];
        }
        if (nCardAll == 0)
        {
            continue;
        }

        LayIndexType layTmp;
        memset(&layTmp[0], 0, layTmp.size());
        for (int m = 1; m < safe_count; ++m)
        {
            layTmp[m - 1] = (lay + EM_LAYOUT_MOD * i)[m];
        }
        HuUnits unit;
        if (!checkCanHuSingle(i, layTmp, unit, joker_count))
        {
            return false;
        }

        joker_count -= unit.get_total_joker_conut();
        jiangNum += ((nCardAll + unit.get_total_joker_conut()) % 3 == 2);
        if (jiangNum > joker_count + 1)
        {
            // 如果出现多个将 除第一个将之外，其他的必须有财神匹配为刻
            return false;
        }
    }

    return jiangNum > 0 || joker_count >= 2;
}

template <typename Config>
void MJHuUnitMake<Config>::genCombJiang(std::set<int>& jiangs, ArrayAllHuUnitMap& huUnits)
{
    ArrayAllHuUnitMap tmp = huUnits;
    std::vector<int> jiangArray(jiangs.begin(), jiangs.end());
    for (auto it = jiangArray.begin(); it != jiangArray.end(); ++it)
    {
        HuUnits unit;
        unit.add_key(*it);
        if (!isValidKey(unit.total_key()))
        {
            continue;
        }
        addUnitToHu(unit, huUnits);

        for (int m = 0; m < EM_HAND_CARD_COUNT + 1; ++m)
        {
            auto& hus = tmp[m];
            for (auto it2 = hus.begin(); it2 != hus.end(); ++it2)
            {
                for (auto& unit : it2->second.units)
                {
                    if (unit.units_count > EM_HAND_CARD_COUNT / 3)
                    {
                        continue;
                    }
                    HuUnits unit2(unit);
                    unit2.add_key(*it);
                    unit2.sort();
                    if (isValidKey(unit2.total_key()))
                    {
                        addUnitToHu(unit2, huUnits);
                    }
                }
            }
        }
    }
}

template <typename Config>
void MJHuUnitMake<Config>::addUnitToHu(HuUnits& key_unit, ArrayAllHuUnitMap& huUnits)
{
    int key = key_unit.total_key();
    int jokernum = getJokerCount(key);
    int num = getNumByKey(key);
    key = keyRemoveJoker(key);

    HuUnits tmpUnit(key_unit);
    auto& res = huUnits[num][key];
    res.min_joker_use = std::min<int>(res.min_joker_use, tmpUnit.get_total_joker_conut());
    res.units.emplace(std::move(key_unit));
    if (res.units.size() == 1)
    {
        res.min_joker_use = tmpUnit.get_total_joker_conut();
    }
}

template <typename Config>
void MJHuUnitMake<Config>::genCombTravel(std::vector<int>::iterator iter_start, std::vector<int>::iterator iter_end, ArrayAllHuUnitMap& huUnits, HuUnits& preKeys, int left)
{
    if (left <= 0)
    {
        return;
    }
    left -= 3;

    for (; iter_start != iter_end; ++iter_start)
    {
        HuUnits pre_unit_key(preKeys);
        //pre_unit_key.delete_joker();
        int key = pre_unit_key.total_key() + *iter_start;
        //if (pre_unit_key.units_count == 3) {
        //  if (pre_unit_key.v[0] == 73 && pre_unit_key.v[1] == 73 && )
        //}
        if (!isValidKey(key))
        {
            continue;
        }

        pre_unit_key.add_key(*iter_start);
        pre_unit_key.sort();
        addUnitToHu(pre_unit_key, huUnits);

        genCombTravel(iter_start, iter_end, huUnits, pre_unit_key, left);
    }

    return;
}

template <typename Config>
void MJHuUnitMake<Config>::genComb(std::set<int>& card_units, ArrayAllHuUnitMap& huUnits)
{
    std::vector<int> nCardKeys(card_units.begin(), card_units.end());

    HuUnits units;
    genCombTravel(nCardKeys.begin(), nCardKeys.end(), huUnits, units, EM_HAND_CARD_COUNT - 2);
}

template <typename Config>
void MJHuUnitMake<Config>::genSingleAndJiangUnit()
{
    //////////////////////////////////////////////////////////////////////////
    // 单一的组合

    LayIndexType layIndexTmp;
    layIndexTmp[9] = 3;// 三张财神 实际上就是财神的刻字
    m_singleUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
    m_singleFZUnits.insert(getKeyByIndexWithJoker(layIndexTmp));

    // 刻子组合
    for (int i = 0; i < EM_CARD_INDEX_TOTAL; ++i)
    {
        memset(&layIndexTmp[0], 0, layIndexTmp.size());
        // 遍历财神参与组合
        for (int j = 0; j < 3 && j <= EM_JOKER_COUNT; ++j)
        {
            layIndexTmp[i] = 3 - j;
            layIndexTmp[9] = j;
            m_singleUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
            if (i < 7)   //风、字牌最多7张
            {
                m_singleFZUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
            }
        }
    }

    // 顺子
    for (int i = 0; i < EM_CARD_INDEX_TOTAL - 2 /*到7之后就没有连了*/; ++i)
    {
        memset(&layIndexTmp[0], 0, layIndexTmp.size());
        layIndexTmp[i] = 1;
        layIndexTmp[i + 1] = 1;
        layIndexTmp[i + 2] = 1;
        m_singleUnits.insert(getKeyByIndexWithJoker(layIndexTmp));

        //带一个赖子
        for (int n = 0; n < 3 && n <= EM_JOKER_COUNT; ++n)
        {
            memset(&layIndexTmp[0], 0, layIndexTmp.size());
            layIndexTmp[i] = 1;
            layIndexTmp[i + 1] = 1;
            layIndexTmp[i + 2] = 1;
            layIndexTmp[i + n] = 0;
            layIndexTmp[9] = 1;
            m_singleUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
        }

        //带两个赖子【原来的算法这里忽略了；实际上还是需要的，我们要计算胡番最大的结算
        for (int n = 0; n < 3 && n <= EM_JOKER_COUNT; ++n)
        {
            memset(&layIndexTmp[0], 0, layIndexTmp.size());
            layIndexTmp[9] = 2;
            layIndexTmp[i + n] = 1;
            m_singleUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
        }
    }

    //////////////////////////////////////////////////////////////////////////
    // 将牌
    memset(&layIndexTmp[0], 0, layIndexTmp.size());
    layIndexTmp[9] = 2;
    m_jiangUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
    m_jiangFZUnits.insert(getKeyByIndexWithJoker(layIndexTmp));

    for (int i = 0; i < EM_CARD_INDEX_TOTAL; ++i)
    {
        memset(&layIndexTmp[0], 0, layIndexTmp.size());
        for (int j = 0; j < 2 && j <= EM_JOKER_COUNT; ++j)
        {
            layIndexTmp[i] = 2 - j;
            layIndexTmp[9] = j;
            m_jiangUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
            if (i < 7)  //风、字牌最多7张
            {
                m_jiangFZUnits.insert(getKeyByIndexWithJoker(layIndexTmp));
            }
        }
    }
}

template <typename Config>
int MJHuUnitMake<Config>::getJokerCount(int key)
{
    return (key >> (EM_BIT_VAL_NUM * 9)) & EM_BIT_VAL_FLAG;
}

template <typename Config>
int MJHuUnitMake<Config>::keyAddJoker(int key, int joker_num)
{
    int joker_num_bits = (joker_num & EM_BIT_VAL_FLAG) << 27;
    key += joker_num_bits;
    return key;
}

template <typename Config>
int MJHuUnitMake<Config>::keyRemoveJoker(int key)
{
    return key & 0x7FFFFFF; // 28,29,30是Joker的数量,&0x7FFFFFF会把Joker的数量抹平
}

template <typename Config>
int MJHuUnitMake<Config>::getNumByKey(int key)
{
    int num = 0;
    for (int i = 0; i < EM_CARD_INDEX_TOTAL; ++i)
    {
        num += (key >> (EM_BIT_VAL_NUM * i))&EM_BIT_VAL_FLAG;
    }
    return num;
}

template <typename Config>
bool MJHuUnitMake<Config>::isValidKey(int key)
{
    LayIndexType layIndex;
    int num = 0;
    for (std::size_t i = 0; i < layIndex.size(); ++i)
    {
        layIndex[i] = (key >> (EM_BIT_VAL_NUM * i))&EM_BIT_VAL_FLAG;
        num += layIndex[i];
        if (layIndex[i] > EM_SINGLE_CARD_MAX_COUNT || num > EM_HAND_CARD_COUNT)
        {
            return false;
        }
    }
    if (layIndex[9] > EM_JOKER_COUNT)
    {
        // 超出了财神上限
        return false;
    }
    return num > 0;
}

template <typename Config>
int MJHuUnitMake<Config>::getKeyByIndexNoJoker(LayIndexType& byIndex)
{
    int key = 0;
    int sz = std::min<int>(byIndex.size(), EM_CARD_INDEX_TOTAL);
    for (int i = 0; i < sz; ++i)
    {
        // 每一个index的牌最大只能是4张  3个bit
        int n = byIndex.at(i) & EM_BIT_VAL_FLAG;
        n = n << (EM_BIT_VAL_NUM * i);
        key |= n;
    }
    return key;
}

template <typename Config>
int MJHuUnitMake<Config>::getKeyByIndexWithJoker(LayIndexType& byIndex)
{
    int key = 0;
    for (std::size_t i = 0; i < byIndex.size(); ++i)
    {
        // 每一个index的牌最大只能是4张  3个bit
        int n = byIndex.at(i) & EM_BIT_VAL_FLAG;
        n = n << (EM_BIT_VAL_NUM * i);
        key |= n;
    }
    return key;
}

