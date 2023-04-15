#include "stdafx.h"
#include "MJCalclator.h"


CMJCalclator::CMJCalclator()
{
}


CMJCalclator::~CMJCalclator()
{
}

int CMJCalclator::MJ_CalculateCardValue(int nID, DWORD gameflags)
{
    if (nID >= 0 && nID < 108)
    {
        return nID % 9 + 1;
    }
    else if (nID >= 108 && nID < 136)
    {
        return (nID - 108) % 7 + 1;
    }
    else if (nID >= 136 && nID < 152)
    {
        return nID - 136 + 1;
    }
    else
    {
        return 0;
    }
}

int CMJCalclator::MJ_CalculateCardShape(int nID, DWORD gameflags)
{
    if (nID >= 0 && nID < 36)
    {
        return 0;  //MJ_CS_WAN;
    }
    else if (nID >= 36 && nID < 72)
    {
        return 1;  //MJ_CS_TIAO;
    }
    else if (nID >= 72 && nID < 108)
    {
        return 2;  //MJ_CS_DONG;
    }
    else if (nID >= 108 && nID < 136)
    {
        return 3;  //MJ_CS_FENG;
    }
    else if (nID >= 136 && nID < 152)
    {
        return 4;  //MJ_CS_HUA;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMJCalclator::MJ_CalculateCardShapeByIndex(int nIndex, DWORD gameflags)
{
    if (nIndex >= 1 && nIndex <= 9)
    {
        return 0;  //MJ_CS_WAN;
    }
    else if (nIndex >= 11 && nIndex <= 19)
    {
        return 1;  //MJ_CS_TIAO;
    }
    else if (nIndex >= 21 && nIndex <= 29)
    {
        return 2;  //MJ_CS_DONG;
    }
    else if (nIndex >= 31 && nIndex <= 37)
    {
        return 3;  //MJ_CS_FENG;
    }
    else if (nIndex >= 41 && nIndex <= 143)
    {
        return 4;  //MJ_CS_HUA;
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

DWORD CMJCalclator::MJ_LayCards(int nCardIDs[], int nCardsLen, int nCardsLay[], DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < nCardsLen; i++)
    {
        if (nCardIDs[i] < 0)
        {
            continue;
        }
        int shape = MJ_CalculateCardShape(nCardIDs[i], gameflags);
        int value = MJ_CalculateCardValue(nCardIDs[i], gameflags);
        nCardsLay[shape * MJ_LAYOUT_MOD + value]++;
        count++;
    }
    return count;
}

BOOL CMJCalclator::MJ_IsJoker(int index, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (index <= 0)
    {
        return FALSE;
    }

    if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER)
        || INVALID_OBJECT_ID == nJokerID)
    {
        // û�в���
        return FALSE;
    }
    int shape = index / MJ_LAYOUT_MOD;
    int value = index % MJ_LAYOUT_MOD;

    int j_shape = MJ_CalculateCardShape(nJokerID, gameflags);
    int j_value = MJ_CalculateCardValue(nJokerID, gameflags);

    int j_shape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
    int j_value2 = MJ_CalculateCardValue(nJokerID2, gameflags);

    if (nJokerID >= 0 && shape == j_shape && value == j_value)
    {
        return TRUE;
    }
    if (nJokerID2 >= 0 && shape == j_shape2 && value == j_value2)
    {
        return TRUE;
    }
    return FALSE;
}

DWORD CMJCalclator::MJ_CanAnGang(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int& index)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    index = 0;
    for (int i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (4 == lay[i])
        {
            if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER) // ��ʹ�ò���
                || IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT) // �����ܻ�ԭ
                || FALSE == MJ_IsJoker(i, nJokerID, nJokerID2, gameflags))
            {
                // ���ǲ���
                index = i;
                return MJ_GANG;
            }
        }
    }
    return 0;
}

int CMJCalclator::MJ_CalcIndexByID(int nID, DWORD gameflags)
{
    int shape = MJ_CalculateCardShape(nID, gameflags);
    int value = MJ_CalculateCardValue(nID, gameflags);

    return shape * MJ_LAYOUT_MOD + value;
}

int CMJCalclator::MJ_DrawCardsByIndex(int nCardIDs[], int nCardsLen, int index, int nResultIDs[], int nCount, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < nCardsLen; i++)
    {
        if (nCardIDs[i] < 0)
        {
            continue;
        }
        if (count >= nCount)
        {
            break;
        }
        if (index == MJ_CalcIndexByID(nCardIDs[i], gameflags))
        {
            nResultIDs[count] = nCardIDs[i];
            count++;
        }
    }
    return count;
}

DWORD CMJCalclator::MJ_CanAnGangEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    XygInitChairCards(nResultIDs, nCardsLen);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memset(lay, 0, sizeof(lay));

    MJ_LayCards(nCardIDs, nCardsLen, lay, gameflags);

    int index = 0;
    DWORD dwResult = MJ_CanAnGang(lay, nCardID, nJokerID, nJokerID2, gameflags, index);
    if (dwResult)
    {
        MJ_DrawCardsByIndex(nCardIDs, nCardsLen, index, nResultIDs, 4, gameflags);
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanGangSelfEx(int nCardIDs[], int nCardsLen, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    return MJ_CanAnGangEx(nCardIDs, nCardsLen, -1, nJokerID, nJokerID2, gameflags, nResultIDs);
}

// �з���
int CMJCalclator::MJ_IsFengZfb(int index, DWORD gameflags)
{
    if (index == MJ_INDEX_HONGZHONG
        || index == MJ_INDEX_FACAI
        || index == MJ_INDEX_BAIBAN)
    {
        return index;
    }
    return 0;
}

// ��������
int CMJCalclator::MJ_IsFengDnxb(int index, DWORD gameflags)
{
    if (index == MJ_INDEX_DONGFENG
        || index == MJ_INDEX_NANFENG
        || index == MJ_INDEX_XIFENG
        || index == MJ_INDEX_BEIFENG)
    {
        return index;
    }
    return 0;
}

int CMJCalclator::MJ_GetGangNO(int beginno, int jokerno, int totalcards, int& tail_taken, BOOL& joker_jump)
{
    joker_jump = FALSE;

    int nRet = tail_taken % 2 + beginno - 2 - 2 * (tail_taken / 2);

    if (nRet < 0)
    {
        nRet += totalcards;
    }
    if (nRet == jokerno)  // �ܵ�����
    {
        joker_jump = TRUE;
        tail_taken++;
        nRet++;
    }
    tail_taken++;
    return nRet;
}

// ����
int CMJCalclator::MJ_IsHua(int index, int nJokerID, int nJokerID2, DWORD gameflags)
{
    return (index / MJ_LAYOUT_MOD >= MJ_CS_HUA);
}

// ����
int CMJCalclator::MJ_IsHuaEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsHua(index, nJokerID, nJokerID2, gameflags);
}

BOOL CMJCalclator::MJ_IsJokerEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (nCardID < 0)
    {
        return FALSE;
    }

    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsJoker(index, nJokerID, nJokerID2, gameflags);
}

int CMJCalclator::MJ_GetBaiban(int jokeridx, int jokeridx2, DWORD gameflags)
{
    return MJ_INDEX_BAIBAN;
}

int CMJCalclator::MJ_GetBaibanEx(int nJokerID, int nJokerID2, DWORD gameflags)
{
    int j_shape = MJ_CalculateCardShape(nJokerID, gameflags);
    int j_value = MJ_CalculateCardValue(nJokerID, gameflags);

    int j_shape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
    int j_value2 = MJ_CalculateCardValue(nJokerID2, gameflags);

    int jokeridx = 0;
    if (j_shape >= 0 && j_value > 0)
    {
        jokeridx = j_shape * MJ_LAYOUT_MOD + j_value; //
    }
    int jokeridx2 = 0;
    if (j_shape2 >= 0 && j_value2 > 0)
    {
        jokeridx2 = j_shape2 * MJ_LAYOUT_MOD + j_value2; //
    }
    return MJ_GetBaiban(jokeridx, jokeridx2, gameflags);
}

// �װ�
int CMJCalclator::MJ_IsBaiban(int index, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (MJ_GetBaibanEx(nJokerID, nJokerID2, gameflags) == index)
    {
        return index;
    }
    return 0;
}

// �װ�
int CMJCalclator::MJ_IsBaibanEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsBaiban(index, nJokerID, nJokerID2, gameflags);
}

DWORD CMJCalclator::MJ_CanPeng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))  // �в���
    {
        if (MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags))
        {
            if (!IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT))  // �����ܻ�ԭ
            {
                return 0;
            }
        }
    }
    int shape = MJ_CalculateCardShape(nCardID, gameflags);
    int value = MJ_CalculateCardValue(nCardID, gameflags);

    if (nCardsLay[shape * MJ_LAYOUT_MOD + value] >= 2)
    {
        return MJ_PENG;
    }
    return 0;
}

int CMJCalclator::MJ_IsSameCard(int id1, int id2, DWORD gameflags)
{
    return (MJ_CalcIndexByID(id1, gameflags)
            == MJ_CalcIndexByID(id2, gameflags));
}

int CMJCalclator::MJ_DrawSameCards(int nCardIDs[], int nCardsLen, int nCardID, int nResultIDs[], int nCount, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < nCardsLen; i++)
    {
        if (nCardIDs[i] < 0)
        {
            continue;
        }
        if (count >= nCount)
        {
            break;
        }
        if (MJ_IsSameCard(nCardIDs[i], nCardID, gameflags))
        {
            nResultIDs[count] = nCardIDs[i];
            count++;
        }
    }
    return count;
}

DWORD CMJCalclator::MJ_CanPengEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    XygInitChairCards(nResultIDs, nCardsLen);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memset(lay, 0, sizeof(lay));

    MJ_LayCards(nCardIDs, nCardsLen, lay, gameflags);

    DWORD dwResult = MJ_CanPeng(lay, nCardID, nJokerID, nJokerID2, gameflags);
    if (dwResult)
    {
        MJ_DrawSameCards(nCardIDs, nCardsLen, nCardID, nResultIDs, 2, gameflags);
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanMnGang(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))  // �в���
    {
        if (MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags))
        {
            if (!IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT))  // �����ܻ�ԭ
            {
                return 0;
            }
        }
    }
    int shape = MJ_CalculateCardShape(nCardID, gameflags);
    int value = MJ_CalculateCardValue(nCardID, gameflags);

    if (nCardsLay[shape * MJ_LAYOUT_MOD + value] >= 3)
    {
        return MJ_GANG;
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanMnGangEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    XygInitChairCards(nResultIDs, nCardsLen);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memset(lay, 0, sizeof(lay));

    MJ_LayCards(nCardIDs, nCardsLen, lay, gameflags);

    DWORD dwResult = MJ_CanMnGang(lay, nCardID, nJokerID, nJokerID2, gameflags);
    if (dwResult)
    {
        MJ_DrawSameCards(nCardIDs, nCardsLen, nCardID, nResultIDs, 3, gameflags);
    }
    return dwResult;
}

int CMJCalclator::MJ_CalcJokerIndex(int j_shape, int j_value)
{
    if (j_shape >= 0 && j_value > 0)
    {
        return j_shape * MJ_LAYOUT_MOD + j_value;
    }
    else
    {
        return 0;
    }
}

int CMJCalclator::MJ_GetJokerIndex(int nJokerID, int nJokerID2, DWORD gameflags, int& jokeridx, int& jokeridx2)
{
    int count = 0;
    if (nJokerID >= 0)
    {
        int j_shape = MJ_CalculateCardShape(nJokerID, gameflags);
        int j_value = MJ_CalculateCardValue(nJokerID, gameflags);
        jokeridx = MJ_CalcJokerIndex(j_shape, j_value);
        count++;
    }
    if (nJokerID2 >= 0)
    {
        int j_shape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
        int j_value2 = MJ_CalculateCardValue(nJokerID2, gameflags);
        jokeridx2 = MJ_CalcJokerIndex(j_shape2, j_value2);
        count++;
    }
    return count;
}

int CMJCalclator::MJ_JoinCard(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2,
    int& addpos, DWORD gameflags, BOOL to_revert_joker, int& jokernum2)
{
    int shape = MJ_CalculateCardShape(nCardID, gameflags);
    int value = MJ_CalculateCardValue(nCardID, gameflags);

    int j_index = 0;
    int j_index2 = 0;
    (void)MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, j_index, j_index2);

    addpos = 0;
    if (INVALID_OBJECT_ID != shape && 0 != value)
    {
        nCardsLay[shape * MJ_LAYOUT_MOD + value]++;
        addpos = shape * MJ_LAYOUT_MOD + value;
    }
    int jokernum = 0;
    jokernum2 = 0;

    if (IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))  // �в���
    {
        if (!IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT) || !to_revert_joker)  // ���񲻿��Ի�ԭ�򲻻�ԭ
        {
            if (nJokerID >= 0)
            {
                jokernum += nCardsLay[j_index]; // �������
                nCardsLay[j_index] = 0;
            }
            if (nJokerID2 >= 0)
            {
                jokernum2 += nCardsLay[j_index2]; // �������
                nCardsLay[j_index2] = 0;
            }
        }
        if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))  // �װ�ɴ������
        {
            int baiban_idx = MJ_GetBaibanEx(nJokerID, nJokerID2, gameflags);
            int baiban_num = nCardsLay[baiban_idx];
            nCardsLay[j_index] = baiban_num;
            nCardsLay[baiban_idx] = 0;
        }
    }
    return jokernum;
}

DWORD CMJCalclator::MJ_CanShunAsJoined_Normal(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (addpos % MJ_LAYOUT_MOD == 1)
    {
        //
        if (nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0 && nCardsLay[addpos + 2] > 0)
        {
            return MJ_CT_SHUN;
        }
    }
    else if (addpos % MJ_LAYOUT_MOD == 2)
    {
        if (nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0)
        {
            return MJ_CT_SHUN;
        }
        else if (nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0 && nCardsLay[addpos + 2] > 0)
        {
            return MJ_CT_SHUN;
        }
    }
    else if (addpos % MJ_LAYOUT_MOD == 8)
    {
        if (nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0)
        {
            return MJ_CT_SHUN;
        }
        else if (nCardsLay[addpos - 2] > 0 && nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0)
        {
            return MJ_CT_SHUN;
        }
    }
    else if (addpos % MJ_LAYOUT_MOD == 9)
    {
        if (nCardsLay[addpos - 2] > 0 && nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0)
        {
            return MJ_CT_SHUN;
        }
    }
    else
    {
        if (nCardsLay[addpos - 2] > 0 && nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0)
        {
            return MJ_CT_SHUN;
        }
        else if (nCardsLay[addpos - 1] > 0 && nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0)
        {
            return MJ_CT_SHUN;
        }
        else if (nCardsLay[addpos] > 0 && nCardsLay[addpos + 1] > 0 && nCardsLay[addpos + 2] > 0)
        {
            return MJ_CT_SHUN;
        }
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanShunAsJoined_Feng(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))
    {
        // �����Գ�
        int lay[MAX_CARDS_LAYOUT_NUM];
        ZeroMemory(lay, sizeof(lay));
        int start = 0;
        int end = 0;
        if (addpos >= MJ_INDEX_DONGFENG && addpos <= MJ_INDEX_BEIFENG)
        {
            // ����������
            start = MJ_INDEX_DONGFENG;
            end = MJ_INDEX_BEIFENG;
        }
        else
        {
            // �з���
            start = MJ_INDEX_HONGZHONG;
            end = MJ_INDEX_BAIBAN;
        }
        for (int i = start; i <= end; i++)
        {
            if (i == addpos)
            {
                continue;
            }
            if (nCardsLay[i] > 0)
            {
                lay[i] = 1;
            }
        }
        if (XygCardRemains(lay) >= 2)
        {
            return MJ_CT_SHUN;
        }
    }
    return 0;
}

// ���
int CMJCalclator::MJ_IsFeng(int index, int nJokerID, int nJokerID2, DWORD gameflags)
{
    return MJ_IsFengDnxb(index, gameflags) || MJ_IsFengZfb(index, gameflags);
}

DWORD CMJCalclator::MJ_CanShunAsJoined(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))  // �װ�ɴ������
    {
        if (addpos == MJ_GetBaibanEx(nJokerID, nJokerID2, gameflags))
        {
            int j_shape = MJ_CalculateCardShape(nJokerID, gameflags);
            int j_value = MJ_CalculateCardValue(nJokerID, gameflags);
            addpos = MJ_CalcJokerIndex(j_shape, j_value);
        }
    }
    if (!MJ_IsFeng(addpos, nJokerID, nJokerID2, gameflags))  // ���Ƿ��
    {
        return MJ_CanShunAsJoined_Normal(nCardsLay, addpos, nJokerID, nJokerID2, gameflags);
    }
    else if (IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))  // �����Գ�
    {
        return MJ_CanShunAsJoined_Feng(nCardsLay, addpos, nJokerID, nJokerID2, gameflags);
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanChi(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (IS_BIT_SET(gameflags, MJ_GF_CHI_FORBIDDEN))  // ���ܳ�
    {
        return 0;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))  // �в���
    {
        if (MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags))
        {
            if (!IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT))  // �����ܻ�ԭ
            {
                return 0;
            }
        }
    }
    int shape = MJ_CalculateCardShape(nCardID, gameflags);
    int value = MJ_CalculateCardValue(nCardID, gameflags);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // �в���
    BOOL baiban_joker = IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER); // �װ�ɴ������
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL feng_chi = IS_BIT_SET(gameflags, MJ_GF_FENG_CHI); // �����Գ�

    int joker_num = 0;
    int joker_num2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    int dwChi = (10000 + feng_chi * 1000 | joker_revert * 100 | baiban_joker * 10 | use_joker * 1);
    if (dwChi == 10010 || dwChi == 10100 || dwChi == 10110 || dwChi == 11010
        || dwChi == 11011 || dwChi == 11100 || dwChi == 11110 || dwChi == 11111)
    {
        return 0;
    }

    joker_num = MJ_JoinCard(lay, nCardID, nJokerID, nJokerID2, addpos, gameflags, TRUE, joker_num2);
    if (MJ_CanShunAsJoined(lay, addpos, nJokerID, nJokerID2, gameflags))
    {
        return MJ_CHI;
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanChiEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    XygInitChairCards(nResultIDs, nCardsLen);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memset(lay, 0, sizeof(lay));

    MJ_LayCards(nCardIDs, nCardsLen, lay, gameflags);

    DWORD dwResult = MJ_CanChi(lay, nCardID, nJokerID, nJokerID2, gameflags);

    int count = 0;
    for (int i = 0; i < nCardsLen - 1; i++)
    {
        if (nCardIDs[i] < 0)
        {
            continue;
        }
        for (int j = i + 1; j < nCardsLen; j++)
        {
            if (nCardIDs[j] < 0)
            {
                continue;
            }
            int id1 = nCardIDs[i];
            int id2 = nCardIDs[j];
            memset(lay, 0, sizeof(lay));
            lay[MJ_CalcIndexByID(id1, gameflags)]++;
            lay[MJ_CalcIndexByID(id2, gameflags)]++;
            if (MJ_CanChi(lay, nCardID, nJokerID, nJokerID2, gameflags))
            {
                nResultIDs[count] = id1;
                count++;
                nResultIDs[count] = id2;
                count++;
            }
        }
    }
    return dwResult;
}

int CMJCalclator::MJ_GetJokerNum(int nCardsLay[], int nJokerID, int nJokerID2, DWORD gameflags, int& jokernum2)
{
    if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER)
        || INVALID_OBJECT_ID == nJokerID)
    {
        // û�в���
        return 0;
    }
    int j_shape = MJ_CalculateCardShape(nJokerID, gameflags);
    int j_value = MJ_CalculateCardValue(nJokerID, gameflags);

    int j_shape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
    int j_value2 = MJ_CalculateCardValue(nJokerID2, gameflags);

    int jokernum = 0;
    if (j_shape >= 0 && j_value > 0)
    {
        jokernum += nCardsLay[j_shape * MJ_LAYOUT_MOD + j_value]; // �������
    }
    if (j_shape2 >= 0 && j_value2 > 0)
    {
        jokernum2 += nCardsLay[j_shape2 * MJ_LAYOUT_MOD + j_value2]; // �������
    }
    return jokernum;
}

DWORD CMJCalclator::MJ_CanHu(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    //assert(nCardID >= 0);

    if (IS_BIT_SET(gameflags, MJ_GF_FANG_FORBIDDEN))
    {
        // ���ܷų�
        if (IS_BIT_SET(dwFlags, MJ_HU_FANG))
        {
            return 0;
        }
    }
    if (IS_BIT_SET(gameflags, MJ_GF_QGNG_FORBIDDEN))
    {
        // ��������
        if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
        {
            return 0;
        }
    }
    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL fang_qgng = IS_BIT_SET(dwFlags, MJ_HU_FANG)
        || IS_BIT_SET(dwFlags, MJ_HU_QGNG); // �ų��������
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));
    jokernum = MJ_GetJokerNum(lay, nJokerID, nJokerID2, gameflags, jokernum2);

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    if (!use_joker)
    {
        // ��ʹ�ò���
        MJ_JoinCard(lay, nCardID, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
        dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, addpos, gameflags, huflags, huDetails, dwFlags);
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (joker_revert && jokernum + jokernum2 > 0)
            {
                // ������Ի�ԭ�����в���
                dwResult = MJ_CanHuWithoutJoker(lay, nCardID, nJokerID, nJokerID2,
                        jokernum, jokernum2,
                        addpos, gameflags, huflags, huDetails, dwFlags);
            }
            if (!dwResult)
            {
                dwResult = MJ_CanHuWithJoker(lay, nCardID, nJokerID, nJokerID2,
                        jokernum, jokernum2,
                        addpos, gameflags, huflags, huDetails, dwFlags);
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (fang_qgng)
                {
                    // �ų��������
                    dwResult = 0;
                }
                else
                {
                    dwResult = MJ_CanHuWithJoker(lay, nCardID, nJokerID, nJokerID2,
                            jokernum, jokernum2,
                            addpos, gameflags, huflags, huDetails, dwFlags);
                }
            }
            else
            {
                // ������Ի�ԭ
                dwResult = MJ_CanHuWithoutJoker(lay, nCardID, nJokerID, nJokerID2,
                        jokernum, jokernum2,
                        addpos, gameflags, huflags, huDetails, dwFlags);
                if (!dwResult && !fang_qgng)
                {
                    // ����
                    dwResult = MJ_CanHuWithJoker(lay, nCardID, nJokerID, nJokerID2,
                            jokernum, jokernum2,
                            addpos, gameflags, huflags, huDetails, dwFlags);
                }
            }
        }
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHua(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int shape = MJ_CalculateCardShape(nCardID, gameflags);
    int value = MJ_CalculateCardValue(nCardID, gameflags);

    int cardidx = shape * MJ_LAYOUT_MOD + value;
    if (!(MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags)))
    {
        return 0;
    }

    if (nCardsLay[cardidx] > 0)
    {
        return MJ_HUA;
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanHuaEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[])
{
    XygInitChairCards(nResultIDs, nCardsLen);

    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memset(lay, 0, sizeof(lay));

    MJ_LayCards(nCardIDs, nCardsLen, lay, gameflags);

    DWORD dwResult = MJ_CanHua(lay, nCardID, nJokerID, nJokerID2, gameflags);
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Qian(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);
    int jokershape = MJ_CalculateCardShape(nJokerID, gameflags);
    int jokervalue = MJ_CalculateCardValue(nJokerID, gameflags);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);
    int cardshape = MJ_CalculateCardShape(nCardID, gameflags);
    int cardvalue = MJ_CalculateCardValue(nCardID, gameflags);

    if (!use_joker)
    {
        // ��ʹ�ò���
        if (1 == cardvalue || 9 == cardvalue
            || MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
        {
            return 0;
        }
        if (lay[cardidx - 1] <= 0 || lay[cardidx + 1] <= 0)
        {
            return 0;
        }
        lay[cardidx - 1]--;
        lay[cardidx + 1]--;
        dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
        if (dwResult)
        {
            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, 0, 0, jokeridx, jokeridx2, 0, 0);
        }
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (MJ_IsBaibanEx(nCardID, nJokerID, nJokerID2, gameflags))
            {
                // �ǰװ�
                if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
                {
                    // �װ�ɴ������
                    cardidx = jokeridx;
                    cardshape = jokershape;
                    cardvalue = jokervalue;
                }
            }
            if (1 == cardvalue || 9 == cardvalue
                || MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
            {
                return 0;
            }
            jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
            if (lay[cardidx - 1] <= 0 && lay[cardidx + 1] <= 0)
            {
                return 0;
            }
            if (lay[cardidx - 1] > 0 && lay[cardidx + 1] > 0)
            {
                lay[cardidx - 1]--;
                lay[cardidx + 1]--;
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, 0, 0, jokeridx, jokeridx2, 0, 0);
                }
            }
            else
            {
                if (IS_BIT_SET(gameflags, MJ_GF_JOKER_QIAN_ZIMO))
                {
                    // ����Ƕ�ű�������
                    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        return 0;
                    }
                }
                if (jokernum + jokernum2 <= 0)
                {
                    return 0;
                }
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                if (lay[cardidx - 1] > 0)
                {
                    lay[cardidx - 1]--;
                    dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                    }
                }
                else if (lay[cardidx + 1] > 0)
                {
                    lay[cardidx + 1]--;
                    dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                    }
                }
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                {
                    return 0;
                }
                dwResult = MJ_CanHu_Qian_Joker(lay, nCardID, nJokerID, nJokerID2,
                        gameflags, huflags, huDetails, dwFlags);
            }
            else
            {
                // ������Ի�ԭ
                if (1 == cardvalue || 9 == cardvalue
                    || MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
                {
                }
                else if (lay[cardidx - 1] <= 0 || lay[cardidx + 1] <= 0)
                {
                }
                else
                {
                    lay[cardidx - 1]--;
                    lay[cardidx + 1]--;
                    dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, 0, 0, jokeridx, jokeridx2, 0, 0);
                    }
                }
                if (!dwResult)
                {
                    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        // ����
                        dwResult = MJ_CanHu_Qian_Joker(lay, nCardID, nJokerID, nJokerID2,
                                gameflags, huflags, huDetails, dwFlags);
                    }
                }
            }
        }
    }
    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_QIAN;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Qian_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);

    for (int i = 0; i <= MJ_CS_DONG; i++)
    {
        if (dwResult)
        {
            break;
        }
        for (int j = 1; j <= 7; j++)
        {
            int idx = i * MJ_LAYOUT_MOD + j;
            if (lay[idx] > 0 && lay[idx + 2] > 0)
            {
                lay[idx]--;
                lay[idx + 2]--;
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    int ju, ju2;
                    ju = ju2 = 0;
                    MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                    MJ_AddUnit(huDetails, MJ_CT_SHUN, idx, ju, ju2, jokeridx, jokeridx2, 1, 0);
                    break;
                }
                else
                {
                    lay[idx]++;
                    lay[idx + 2]++;
                }
            }
        }
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Various(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut)
{
    if (MJ_CanHu_BaoTou(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_Diao(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_Duid(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_Qian(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_Bian(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_Chi(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_7Dui(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_13BK(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_7Fng(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_QFng(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags, dwOut))
    {
        return MJ_HU;
    }
    if (MJ_CanHu_258(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags, dwOut))
    {
        return MJ_HU;
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanHuAsJoined(int nCardsLay[], int jokernum, int jokernum2, int nJokerID, int nJokerID2,
    int addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (MJ_HuaCount(lay, nJokerID, nJokerID2, gameflags))
    {
        return 0;
    }
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    memset(&huDetails, 0, sizeof(huDetails));

    if (IS_BIT_SET(dwFlags, MJ_HU_7DUI))
    {
        // �߶���(6��)
        if (MJ_HuPai_7Dui(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
        {
            return MJ_HU;
        }
        return 0;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_13BK))
    {
        // ʮ������
        if (MJ_HuPai_13BK(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
        {
            return MJ_HU;
        }
        return 0;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_7FNG))
    {
        // ����ȫ
        if (MJ_HuPai_7Fng(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
        {
            return MJ_HU;
        }
        return 0;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_QFNG))
    {
        // ȫ���
        if (MJ_HuPai_QFng(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
        {
            return MJ_HU;
        }
        return 0;
    }
    if (IS_BIT_SET(dwFlags, MJ_HU_258))
    {
        // 258
        if (MJ_HuPai_258(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
        {
            return MJ_HU;
        }
        return 0;
    }
    // �߶���(6��)
    if (MJ_HuPai_7Dui(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    // ʮ������
    if (MJ_HuPai_13BK(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    // ����ȫ
    if (MJ_HuPai_7Fng(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    // ȫ���
    if (MJ_HuPai_QFng(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    // 258
    if (MJ_HuPai_258(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    // �����ܹ����Ƶ���������...
    int deepth = 0;
    return MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, FALSE, deepth);
}

int CMJCalclator::MJ_HuaCount(int nCardsLay[], int nJokerID, int nJokerID2, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (nCardsLay[i] <= 0)
        {
            continue;
        }
        if (MJ_IsHua(i, nJokerID, nJokerID2, gameflags))
        {
            count += nCardsLay[i];
        }
    }
    return count;
}

DWORD CMJCalclator::MJ_CanHu_Bian(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);
    int jokershape = MJ_CalculateCardShape(nJokerID, gameflags);
    int jokervalue = MJ_CalculateCardValue(nJokerID, gameflags);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);
    int cardshape = MJ_CalculateCardShape(nCardID, gameflags);
    int cardvalue = MJ_CalculateCardValue(nCardID, gameflags);

    if (!use_joker)
    {
        // ��ʹ�ò���
        if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
        {
            return 0;
        }
        if (3 == cardvalue)
        {
            if (lay[cardidx - 2] <= 0 || lay[cardidx - 1] <= 0)
            {
                return 0;
            }
            lay[cardidx - 2]--;
            lay[cardidx - 1]--;
            dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
            }
        }
        else if (7 == cardvalue)
        {
            if (lay[cardidx + 1] <= 0 || lay[cardidx + 2] <= 0)
            {
                return 0;
            }
            lay[cardidx + 1]--;
            lay[cardidx + 2]--;
            dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
            }
        }
        else
        {
            return 0;
        }
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (MJ_IsBaibanEx(nCardID, nJokerID, nJokerID2, gameflags))
            {
                // �ǰװ�
                if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
                {
                    // �װ�ɴ������
                    cardidx = jokeridx;
                    cardshape = jokershape;
                    cardvalue = jokervalue;
                }
            }
            if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
            {
                return 0;
            }
            jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
            if (3 == cardvalue
                || MJ_IsBianCardRightWithJoker(cardshape, cardvalue, nJokerID, nJokerID2, gameflags))
            {
                if (lay[cardidx - 2] <= 0 || lay[cardidx - 1] <= 0)
                {
                    return 0;
                }
                lay[cardidx - 2]--;
                lay[cardidx - 1]--;
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
                }
            }
            else if (7 == cardvalue
                || MJ_IsBianCardLeftWithJoker(cardshape, cardvalue, nJokerID, nJokerID2, gameflags))
            {
                if (lay[cardidx + 1] <= 0 || lay[cardidx + 2] <= 0)
                {
                    return 0;
                }
                lay[cardidx + 1]--;
                lay[cardidx + 2]--;
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                }
            }
            else
            {
                if (IS_BIT_SET(gameflags, MJ_GF_JOKER_BIAN_ZIMO))
                {
                    // ������ű�������
                    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        return 0;
                    }
                }
                if (jokernum + jokernum2 <= 0)
                {
                    return 0;
                }
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                if (3 == cardvalue
                    || MJ_IsBianCardRightWithJoker(cardshape, cardvalue, nJokerID, nJokerID2, gameflags))
                {
                    if (lay[cardidx - 2] > 0)
                    {
                        lay[cardidx - 2]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                        }
                    }
                    else if (lay[cardidx - 1] > 0)
                    {
                        lay[cardidx - 1]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                        }
                    }
                }
                else if (7 == cardvalue
                    || MJ_IsBianCardLeftWithJoker(cardshape, cardvalue, nJokerID, nJokerID2, gameflags))
                {
                    if (lay[cardidx + 1] > 0)
                    {
                        lay[cardidx + 1]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                        }
                    }
                    else if (lay[cardidx + 2] > 0)
                    {
                        lay[cardidx + 2]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                        }
                    }
                }
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                {
                    return 0;
                }
                dwResult = MJ_CanHu_Bian_Joker(lay, nCardID, nJokerID, nJokerID2,
                        gameflags, huflags, huDetails, dwFlags);
            }
            else
            {
                // ������Ի�ԭ
                if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags) || MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
                {
                }
                else
                {
                    if (3 == cardvalue)
                    {
                        if (lay[cardidx - 2] <= 0 || lay[cardidx - 1] <= 0)
                        {
                        }
                        else
                        {
                            lay[cardidx - 2]--;
                            lay[cardidx - 1]--;
                            dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
                            }
                        }
                    }
                    else if (7 == cardvalue)
                    {
                        if (lay[cardidx + 1] <= 0 || lay[cardidx + 2] <= 0)
                        {
                        }
                        else
                        {
                            lay[cardidx + 1]--;
                            lay[cardidx + 2]--;
                            dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx + 1, 0, 0, jokeridx, jokeridx2, 0, 0);
                            }
                        }
                    }
                }
                if (!dwResult)
                {
                    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        // ����
                        dwResult = MJ_CanHu_Bian_Joker(lay, nCardID, nJokerID, nJokerID2,
                                gameflags, huflags, huDetails, dwFlags);
                    }
                }
            }
        }
    }
    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_BIAN;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Bian_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);

    for (int i = 0; i <= MJ_CS_DONG; i++)
    {
        if (lay[i * MJ_LAYOUT_MOD + 1] > 0 && lay[i * MJ_LAYOUT_MOD + 2] > 0)
        {
            lay[i * MJ_LAYOUT_MOD + 1]--;
            lay[i * MJ_LAYOUT_MOD + 2]--;
            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                int ju, ju2;
                ju = ju2 = 0;
                MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i * MJ_LAYOUT_MOD + 1, ju, ju2, jokeridx, jokeridx2, 2, 0);
                break;
            }
            else
            {
                lay[i * MJ_LAYOUT_MOD + 1]++;
                lay[i * MJ_LAYOUT_MOD + 2]++;
            }
        }
        else if (lay[i * MJ_LAYOUT_MOD + 8] > 0 && lay[i * MJ_LAYOUT_MOD + 9] > 0)
        {
            lay[i * MJ_LAYOUT_MOD + 8]--;
            lay[i * MJ_LAYOUT_MOD + 9]--;
            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                int ju, ju2;
                ju = ju2 = 0;
                MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i * MJ_LAYOUT_MOD + 8, ju, ju2, jokeridx, jokeridx2, 0, 0);
                break;
            }
            else
            {
                lay[i * MJ_LAYOUT_MOD + 8]++;
                lay[i * MJ_LAYOUT_MOD + 9]++;
            }
        }
    }
    return dwResult;
}

DWORD MJ_CanShunFeng(int nCardsLay[], int cardidx, int jokernum, DWORD gameflags, int lay[], int& start, int& end)
{
    if (IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))
    {
        // �����Գ�
        if (cardidx >= MJ_INDEX_DONGFENG && cardidx <= MJ_INDEX_BEIFENG)
        {
            // ����������
            start = MJ_INDEX_DONGFENG;
            end = MJ_INDEX_BEIFENG;
        }
        else
        {
            // �з���
            start = MJ_INDEX_HONGZHONG;
            end = MJ_INDEX_BAIBAN;
        }
        for (int i = start; i <= end; i++)
        {
            if (i == cardidx)
            {
                continue;
            }
            if (nCardsLay[i] > 0)
            {
                lay[i] = 1;
            }
        }
        if (XygCardRemains(lay) + jokernum >= 2)
        {
            return MJ_CT_SHUN;
        }
    }
    return 0;
}

DWORD CMJCalclator::MJ_CanHu_Chi(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL fang_qgng = IS_BIT_SET(dwFlags, MJ_HU_FANG)
        || IS_BIT_SET(dwFlags, MJ_HU_QGNG); // �ų��������
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����
    BOOL feng_chi = IS_BIT_SET(gameflags, MJ_GF_FENG_CHI); // �����Գ�

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);
    int jokershape = MJ_CalculateCardShape(nJokerID, gameflags);
    int jokervalue = MJ_CalculateCardValue(nJokerID, gameflags);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);
    int cardshape = MJ_CalculateCardShape(nCardID, gameflags);
    int cardvalue = MJ_CalculateCardValue(nCardID, gameflags);

    if (!use_joker)
    {
        // ��ʹ�ò���
        if (MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
        {
            return 0;
        }
        if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags))
        {
            //
            int fengs[MAX_CARDS_LAYOUT_NUM];
            ZeroMemory(fengs, sizeof(fengs));
            int start = 0;
            int end = 0;
            if (MJ_CanShunFeng(lay, cardidx, 0, gameflags, fengs, start, end))
            {
                for (int i = start; i <= end; i++)
                {
                    if (dwResult)
                    {
                        break;
                    }
                    if (0 == fengs[i])
                    {
                        continue;
                    }
                    for (int j = i + 1; j <= end; j++)
                    {
                        if (0 == fengs[j])
                        {
                            continue;
                        }
                        lay[i]--;
                        lay[j]--;
                        dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit_Simple(huDetails, MJ_CT_SHUN, i, j, cardidx);
                            break;
                        }
                        else
                        {
                            lay[i]++;
                            lay[j]++;
                        }
                    }
                }
            }
        }
        else
        {
            if (!dwResult && cardvalue > 3)
            {
                if (lay[cardidx - 2] > 0 && lay[cardidx - 1] > 0)
                {
                    lay[cardidx - 2]--;
                    lay[cardidx - 1]--;
                    dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
                    }
                }
            }
            if (!dwResult && cardvalue < 7)
            {
                if (lay[cardidx + 1] > 0 && lay[cardidx + 2] > 0)
                {
                    lay[cardidx + 1]--;
                    lay[cardidx + 2]--;
                    dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                    }
                }
            }
        }
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (MJ_IsBaibanEx(nCardID, nJokerID, nJokerID2, gameflags))
            {
                // �ǰװ�
                if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
                {
                    // �װ�ɴ������
                    cardidx = jokeridx;
                    cardshape = jokershape;
                    cardvalue = jokervalue;
                }
            }
            if (MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
            {
                return 0;
            }
            jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);

            if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags))
            {
                //
                int fengs[MAX_CARDS_LAYOUT_NUM];
                ZeroMemory(fengs, sizeof(fengs));
                int start = 0;
                int end = 0;
                if (MJ_CanShunFeng(lay, cardidx, 0, gameflags, fengs, start, end))
                {
                    for (int i = start; i <= end; i++)
                    {
                        if (dwResult)
                        {
                            break;
                        }
                        if (0 == fengs[i])
                        {
                            continue;
                        }
                        for (int j = i + 1; j <= end; j++)
                        {
                            if (0 == fengs[j])
                            {
                                continue;
                            }
                            lay[i]--;
                            lay[j]--;
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit_Simple(huDetails, MJ_CT_SHUN, i, j, cardidx);
                                break;
                            }
                            else
                            {
                                lay[i]++;
                                lay[j]++;
                            }
                        }
                    }
                }
                else if (MJ_CanShunFeng(lay, cardidx, 1, gameflags, fengs, start, end))
                {
                    if (jokernum + jokernum2 > 0)
                    {
                        for (int i = start; i <= end; i++)
                        {
                            if (0 == fengs[i])
                            {
                                continue;
                            }
                            lay[i]--;
                            int jn = jokernum, jn2 = jokernum2;
                            int joker = MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);   // �����1
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit_Simple(huDetails, MJ_CT_SHUN, i, -joker, cardidx);
                                break;
                            }
                            else
                            {
                                lay[i]++;
                                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
                            }
                        }
                    }
                }
                else
                {
                }
            }
            else
            {
                if (!dwResult && 3 < cardvalue)
                {
                    if (lay[cardidx - 2] > 0 && lay[cardidx - 1] > 0)
                    {
                        lay[cardidx - 2]--;
                        lay[cardidx - 1]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
                        }
                    }
                }
                if (!dwResult && 7 > cardvalue)
                {
                    if (lay[cardidx + 1] > 0 && lay[cardidx + 2] > 0)
                    {
                        lay[cardidx + 1]--;
                        lay[cardidx + 2]--;
                        dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                        if (dwResult)
                        {
                            MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                        }
                    }
                }
                if (!dwResult)
                {
                    if (jokernum + jokernum2 <= 0)
                    {
                        return 0;
                    }
                    int jn, jn2;
                    MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                    if (!dwResult && 3 < cardvalue)
                    {
                        if (lay[cardidx - 2] > 0)
                        {
                            lay[cardidx - 2]--;
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                            }
                        }
                        else if (lay[cardidx - 1] > 0)
                        {
                            lay[cardidx - 1]--;
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 1, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                            }
                        }
                    }
                    if (!dwResult && 7 > cardvalue)
                    {
                        if (lay[cardidx + 1] > 0)
                        {
                            lay[cardidx + 1]--;
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                            }
                        }
                        else if (lay[cardidx + 2] > 0)
                        {
                            lay[cardidx + 2]--;
                            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                {
                    return 0;
                }
                dwResult = MJ_CanHu_Chi_Joker(lay, nCardID, nJokerID, nJokerID2,
                        gameflags, huflags, huDetails, dwFlags);
            }
            else
            {
                // ������Ի�ԭ
                if (MJ_IsHua(cardidx, nJokerID, nJokerID2, gameflags))
                {
                }
                else if (MJ_IsFeng(cardidx, nJokerID, nJokerID2, gameflags))
                {
                    //
                    int fengs[MAX_CARDS_LAYOUT_NUM];
                    ZeroMemory(fengs, sizeof(fengs));
                    int start = 0;
                    int end = 0;
                    if (MJ_CanShunFeng(lay, cardidx, 0, gameflags, fengs, start, end))
                    {
                        for (int i = start; i <= end; i++)
                        {
                            if (dwResult)
                            {
                                break;
                            }
                            if (0 == fengs[i])
                            {
                                continue;
                            }
                            for (int j = i + 1; j <= end; j++)
                            {
                                if (0 == fengs[j])
                                {
                                    continue;
                                }
                                lay[i]--;
                                lay[j]--;
                                dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                                if (dwResult)
                                {
                                    MJ_AddUnit_Simple(huDetails, MJ_CT_SHUN, i, j, cardidx);
                                    break;
                                }
                                else
                                {
                                    lay[i]++;
                                    lay[j]++;
                                }
                            }
                        }
                    }
                }
                else
                {
                    if (!dwResult && cardvalue > 3)
                    {
                        if (lay[cardidx - 2] <= 0 || lay[cardidx - 1] <= 0)
                        {
                        }
                        else
                        {
                            lay[cardidx - 2]--;
                            lay[cardidx - 1]--;
                            dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx - 2, 0, 0, jokeridx, jokeridx2, 0, 0);
                            }
                        }
                    }
                    if (!dwResult && cardvalue < 7)
                    {
                        if (lay[cardidx + 1] <= 0 || lay[cardidx + 2] <= 0)
                        {
                        }
                        else
                        {
                            lay[cardidx + 1]--;
                            lay[cardidx + 2]--;
                            dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                            if (dwResult)
                            {
                                MJ_AddUnit(huDetails, MJ_CT_SHUN, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                            }
                        }
                    }
                }
                if (!dwResult)
                {
                    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        // ����
                        dwResult = MJ_CanHu_Chi_Joker(lay, nCardID, nJokerID, nJokerID2,
                                gameflags, huflags, huDetails, dwFlags);
                    }
                }
            }
        }
    }
    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_CHI;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Chi_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);

    for (int i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (i / MJ_LAYOUT_MOD > MJ_CS_DONG)
        {
            break;
        }
        if (i % MJ_LAYOUT_MOD < 2 || i % MJ_LAYOUT_MOD > 7)
        {
            continue;
        }
        if (lay[i] > 0 && lay[i + 1] > 0)
        {
            //
            lay[i]--;
            lay[i + 1]--;
            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                int ju, ju2;
                ju = ju2 = 0;
                MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i, ju, ju2, jokeridx, jokeridx2, 2, 0);
                break;
            }
            else
            {
                lay[i]++;
                lay[i + 1]++;
            }
        }
    }
    if (!dwResult && IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))
    {
        // �����Գ�
        int a[9], b[9];
        memset(a, 0, sizeof(a));
        memset(b, 0, sizeof(b));
        if (lay[31] > 0 && lay[32] > 0)
        {
            a[0] = 31;    // ����
            b[0] = 32;
        }
        if (lay[31] > 0 && lay[33] > 0)
        {
            a[1] = 31;    // ����
            b[1] = 33;
        }
        if (lay[31] > 0 && lay[34] > 0)
        {
            a[2] = 31;    // ����
            b[2] = 34;
        }
        if (lay[32] > 0 && lay[33] > 0)
        {
            a[3] = 32;    // ����
            b[3] = 33;
        }
        if (lay[32] > 0 && lay[34] > 0)
        {
            a[4] = 32;    // �ϱ�
            b[4] = 34;
        }
        if (lay[33] > 0 && lay[34] > 0)
        {
            a[5] = 33;    // ����
            b[5] = 34;
        }
        if (lay[35] > 0 && lay[36] > 0)
        {
            a[6] = 35;    // �з�
            b[6] = 36;
        }
        if (lay[35] > 0 && lay[37] > 0)
        {
            a[7] = 35;    // �а�
            b[7] = 37;
        }
        if (lay[36] > 0 && lay[37] > 0)
        {
            a[8] = 36;    // ����
            b[8] = 37;
        }

        for (int i = 0; i < 9; i++)
        {
            if (a[i] > 0 && b[i] > 0 && lay[a[i]] > 0 && lay[b[i]] > 0)
            {
                lay[a[i]]--;
                lay[b[i]]--;
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit_Simple(huDetails, MJ_CT_SHUN, a[i], b[i], cardidx);
                    break;
                }
                else
                {
                    lay[a[i]]++;
                    lay[b[i]]++;
                }
            }
        }
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_BaoTou(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu_Diao(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL fang_qgng = IS_BIT_SET(dwFlags, MJ_HU_FANG)
        || IS_BIT_SET(dwFlags, MJ_HU_QGNG); // �ų��������

    if (!use_joker)
    {
        // ��ʹ�ò���
        return 0;
    }
    if (fang_qgng)
    {
        // �ų��������
        return 0;
    }
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
    if (jokernum + jokernum2 <= 0)
    {
        return 0;
    }
    int jn, jn2;
    MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
    dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        MJ_AddUnit(huDetails, MJ_CT_DUIZI, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
    }

    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_BTOU;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Diao(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    if (!use_joker)
    {
        // ��ʹ�ò���
        if (lay[cardidx] <= 0)
        {
            return 0;
        }
        lay[cardidx]--;
        dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
        if (dwResult)
        {
            MJ_AddUnit(huDetails, MJ_CT_DUIZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
        }
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (lay[cardidx] > 0)
            {
                lay[cardidx]--;
                dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_DUIZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                }
            }
            else
            {
                if (IS_BIT_SET(gameflags, MJ_GF_JOKER_DIAO_ZIMO))
                {
                    // ���񵥵���������
                    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        return 0;
                    }
                }
                if (IS_BIT_SET(gameflags, MJ_GF_NO_GANGROB_BAOTOU))
                {
                    // ��ͷ��������
                    if (IS_BIT_SET(dwFlags, MJ_HU_QGNG))
                    {
                        return 0;
                    }
                }
                jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
                if (jokernum + jokernum2 <= 0)
                {
                    return 0;
                }
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_DUIZI, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                }
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                {
                    return 0;
                }
                dwResult = MJ_CanHu_Diao_Joker(lay, nCardID, nJokerID, nJokerID2,
                        gameflags, huflags, huDetails, dwFlags);
            }
            else
            {
                // ������Ի�ԭ
                if (lay[cardidx] > 0)
                {
                    lay[cardidx]--;
                    dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_DUIZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                    }
                }
                if (!dwResult)
                {
                    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        // ����
                        dwResult = MJ_CanHu_Diao_Joker(lay, nCardID, nJokerID, nJokerID2,
                                gameflags, huflags, huDetails, dwFlags);
                    }
                }
            }
        }
    }
    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_DIAO;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Diao_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
    int total = 0;
    for (int i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (lay[i] > 0)
        {
            total += lay[i];
            lay[i]--;
            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                int ju, ju2;
                ju = ju2 = 0;
                MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, ju, ju2, jokeridx, jokeridx2, 0, 0);
                break;
            }
            else
            {
                lay[i]++;
            }
        }
    }
    if (!dwResult && 0 == total && 1 == (jokernum + jokernum2))
    {
        // 2�Ų���û�б����
        dwResult = MJ_HU;
        int ju, ju2;
        ju = ju2 = 0;
        MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
        ju += jokernum;
        ju2 += jokernum2;
        MJ_AddUnit(huDetails, MJ_CT_DUIZI, 0, ju, ju2, jokeridx, jokeridx2, 0, 0);
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Duid(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    if (!MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags))
    {
        return 0;
    }
    assert(nCardID >= 0);

    BOOL use_joker = IS_BIT_SET(gameflags, MJ_GF_USE_JOKER); // ʹ�ò���
    BOOL joker_revert = IS_BIT_SET(gameflags, MJ_GF_JOKER_REVERT); // ������Ի�ԭ
    BOOL is_joker = MJ_IsJokerEx(nCardID, nJokerID, nJokerID2, gameflags); // �Ƿ����

    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    if (!use_joker)
    {
        // ��ʹ�ò���
        if (lay[cardidx] < 2)
        {
            return 0;
        }
        lay[cardidx] -= 2;
        dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, 0, gameflags, huflags, huDetails, dwFlags);
        if (dwResult)
        {
            MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
        }
    }
    else
    {
        // ʹ�ò���
        if (!is_joker)
        {
            // ���ǲ���
            if (lay[cardidx] >= 2)
            {
                lay[cardidx] -= 2;
                dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                }
            }
            else if (lay[cardidx] >= 1)
            {
                lay[cardidx] -= 1;
                jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
                if (jokernum + jokernum2 <= 0)
                {
                    return 0;
                }
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                }
            }
            else
            {
                if (IS_BIT_SET(gameflags, MJ_GF_JOKER_DUID_ZIMO))
                {
                    // ����Ե���������
                    if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        return 0;
                    }
                }
                jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
                if (jokernum + jokernum2 < 2)
                {
                    return 0;
                }
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 2);       // �����2
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                }
            }
        }
        else
        {
            // �ǲ���
            if (!joker_revert)
            {
                // ���񲻿��Ի�ԭ
                if (!IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                {
                    return 0;
                }
                dwResult = MJ_CanHu_Duid_Joker(lay, nCardID, nJokerID, nJokerID2,
                        gameflags, huflags, huDetails, dwFlags);
            }
            else
            {
                // ������Ի�ԭ
                if (lay[cardidx] >= 2)
                {
                    lay[cardidx] -= 2;
                    dwResult = MJ_CanHu(lay, -1, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
                    if (dwResult)
                    {
                        MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, 0, 0, jokeridx, jokeridx2, 0, 0);
                    }
                }
                if (!dwResult)
                {
                    if (IS_BIT_SET(dwFlags, MJ_HU_ZIMO))
                    {
                        // ����
                        dwResult = MJ_CanHu_Duid_Joker(lay, nCardID, nJokerID, nJokerID2,
                                gameflags, huflags, huDetails, dwFlags);
                    }
                }
            }
        }
    }
    if (dwResult)
    {
        huDetails.dwHuFlags[1] |= MJ_HU_DUID;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_Duid_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int jokernum = 0;
    int jokernum2 = 0;
    int addpos = 0;
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    DWORD dwResult = 0;
    int jokeridx = 0;
    int jokeridx2 = 0;
    MJ_GetJokerIndex(nJokerID, nJokerID2, gameflags, jokeridx, jokeridx2);

    int cardidx = MJ_CalcIndexByID(nCardID, gameflags);

    jokernum = MJ_JoinCard(lay, -1, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
    int i = 0;
    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (lay[i] >= 2)
        {
            lay[i] -= 2;
            dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
            if (dwResult)
            {
                int ju, ju2;
                ju = ju2 = 0;
                MJ_TellJokerUsed(cardidx, jokeridx, jokeridx2, ju, ju2);
                MJ_AddUnit(huDetails, MJ_CT_KEZI, i, ju, ju2, jokeridx, jokeridx2, 0, 0);
                break;
            }
            else
            {
                lay[i] += 2;
            }
        }
    }
    if (!dwResult && jokernum + jokernum2 > 0)
    {
        for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
        {
            if (lay[i] >= 1)
            {
                lay[i]--;
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
                if (dwResult)
                {
                    MJ_AddUnit(huDetails, MJ_CT_KEZI, cardidx, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                    break;
                }
                else
                {
                    lay[i]++;
                    jokernum = jn;
                    jokernum2 = jn2;
                }
            }
        }
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_7Dui(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    dwFlags |= MJ_HU_7DUI;
    DWORD dwResult = MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_7DUI;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_13BK(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    dwFlags |= MJ_HU_13BK;
    DWORD dwResult = MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_13BK;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_7Fng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    dwFlags |= MJ_HU_7FNG;
    DWORD dwResult = MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_7FNG;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_QFng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut)
{
    if (dwOut && !IS_BIT_SET(dwOut, MJ_OUT_FENG))
    {
        // ���ܳԵ��Ʋ��Ƿ��
        return 0;
    }
    dwFlags |= MJ_HU_QFNG;
    DWORD dwResult = MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_QFNG;
    }
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHu_258(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut)
{
    if (dwOut && !IS_BIT_SET(dwOut, MJ_OUT_258))
    {
        // ���ܳԵ��Ʋ���258
        return 0;
    }
    dwFlags |= MJ_HU_258;
    DWORD dwResult = MJ_CanHu(nCardsLay, nCardID, nJokerID, nJokerID2, gameflags, huflags, huDetails, dwFlags);
    if (dwResult)
    {
        huDetails.dwHuFlags[0] |= MJ_HU_258;
    }
    return dwResult;
}

int CMJCalclator::MJ_AddUnit_Simple(HU_DETAILS& huDetails, DWORD type, int a, int b, int c, int d)
{
    assert(MJ_CT_GANG == type || MJ_CT_KEZI == type
        || MJ_CT_DUIZI == type || MJ_CT_SHUN == type);
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = type;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = a;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = b;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = c;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[3] = d;

    return 1;
}

int CMJCalclator::MJ_AddUnit(HU_DETAILS& huDetails, DWORD type, int index,
    int jokernum, int jokernum2, int jokeridx, int jokeridx2, int jokerpos, int emptypos)
{
    assert(MJ_CT_GANG == type || MJ_CT_KEZI == type
        || MJ_CT_DUIZI == type || MJ_CT_SHUN == type);
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = type;
    if (MJ_CT_GANG == type)
    {
        // ����
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index;
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index;
        if (0 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[3] = index;
        }
        else if (1 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[3]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        }
    }
    else if (MJ_CT_KEZI == type)
    {
        // ����
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
        if (0 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index;
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index;
        }
        else if (1 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index;
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        }
        else if (2 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        }
    }
    else if (MJ_CT_DUIZI == type)
    {
        // ����
        if (0 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index;
        }
        else if (1 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        }
        else if (2 == jokernum + jokernum2)
        {
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
            huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        }
    }
    else if (MJ_CT_SHUN == type)
    {
        // ˳��
        if (0 == jokernum + jokernum2)
        {
            if (2 == emptypos)
            {
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index + 1;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 3;
            }
            else if (1 == emptypos)
            {
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index + 2;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 3;
            }
            else if (0 == emptypos)
            {
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index + 1;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 2;
            }
        }
        else if (1 == jokernum + jokernum2)
        {
            if (2 == jokerpos)
            {
                if (1 == emptypos)
                {
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                        = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 3;
                }
                else if (0 == emptypos)
                {
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index + 1;
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2]
                        = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
                }
            }
            else if (1 == jokerpos)
            {
                if (2 == emptypos)
                {
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                        = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 3;
                }
                else  if (0 == emptypos)
                {
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0] = index;
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
                        = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
                    huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 2;
                }
            }
            else if (0 == jokerpos)
            {
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0]
                    = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1] = index;
                huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2] = index + 1;
            }
        }
    }
    else
    {
    }
    return huDetails.nUnitsCount;
}

DWORD CMJCalclator::MJ_CanHuWithJoker(int nCardsLay[], int nCardID,
    int nJokerID, int nJokerID2,
    int& jokernum, int& jokernum2,
    int& addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));
    jokernum = MJ_JoinCard(lay, nCardID, nJokerID, nJokerID2, addpos, gameflags, FALSE, jokernum2);
    DWORD dwResult = MJ_CanHuAsJoined(lay, jokernum, jokernum2, nJokerID, nJokerID2, addpos, gameflags, huflags, huDetails, dwFlags);
    return dwResult;
}

DWORD CMJCalclator::MJ_CanHuWithoutJoker(int nCardsLay[], int nCardID,
    int nJokerID, int nJokerID2,
    int& jokernum, int& jokernum2,
    int& addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));
    MJ_JoinCard(lay, nCardID, nJokerID, nJokerID2, addpos, gameflags, TRUE, jokernum2);
    DWORD dwResult = MJ_CanHuAsJoined(lay, 0, 0, -1, -1, addpos, gameflags, huflags, huDetails, dwFlags);
    return dwResult;
}

int CMJCalclator::MJ_DecreaseJokerNum(int& jn, int& jn2, int& jokernum, int& jokernum2, int dec)
{
    jn = jokernum;
    jn2 = jokernum2;

    if (dec <= 0)
    {
        return 0;
    }

    int decreased = 0;
    while (jokernum > 0 || jokernum2 > 0) //���ٻ���һ������
    {
        if (jokernum > jokernum2) //����1��������
        {
            if (jokernum2 > 0) //�в���2
            {
                jokernum2--;
                decreased++;
                if (decreased >= dec)
                {
                    return dec;
                }
            }
            else //û�в���2��
            {
                if (jokernum > 0) //����1����ʣ��
                {
                    jokernum--;
                    decreased++;
                    if (decreased >= dec)
                    {
                        return dec;
                    }
                }
                else
                {
                    return decreased;
                }
            }
        }
        else//ʹ�ò���1
        {
            if (jokernum > 0) //ʹ�ò���1
            {
                jokernum--;
                decreased++;
                if (decreased >= dec)
                {
                    return dec;
                }
            }
            else//ʹ�ò���2
            {
                if (jokernum2 > 0) //���в���2
                {
                    jokernum2--;
                    decreased++;
                    if (decreased >= dec)
                    {
                        return dec;
                    }
                }
                else
                {
                    return decreased;
                }
            }
        }
    }
    return decreased;
}

int CMJCalclator::MJ_RestoreJokerNum(int jn, int jn2, int& jokernum, int& jokernum2)
{
    jokernum = jn;
    jokernum2 = jn2;

    return 1;
}

int CMJCalclator::MJ_UseJokerNum(int& jokernum, int& jokernum2, int jokeridx, int jokeridx2)
{
    if (jokernum > jokernum2) //����1��������
    {
        if (jokernum2 > 0) //�в���2
        {
            jokernum2--;
            return jokeridx2;
        }
        else //û�в���2��
        {
            if (jokernum > 0) //����1����ʣ��
            {
                jokernum--;
                return jokeridx;
            }
            else
            {
                return 0;
            }
        }
    }
    else//ʹ�ò���1
    {
        if (jokernum > 0) //ʹ�ò���1
        {
            jokernum--;
            return jokeridx;
        }
        else//û�в���1��,ʹ�ò���2
        {
            if (jokernum2 > 0) //���в���2
            {
                jokernum2--;
                return jokeridx2;
            }
            else
            {
                return 0;
            }
        }
    }
    return 0;
}

int CMJCalclator::MJ_TellJokerUsed(int cardidx, int jokeridx, int jokeridx2, int& ju, int& ju2)
{
    ju = ju2 = 0;
    if (cardidx == jokeridx)
    {
        ju = 1;
    }
    else if (cardidx == jokeridx2)
    {
        ju2 = 1;
    }
    return ju + ju2;
}

// �жϺ��Ƶĵݹ麯���������ǡ��߶��ӡ��͡�ʮ��������������򲻹������͡�
DWORD CMJCalclator::MJ_HuPai(int lay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, BOOL bJiang, int deepth)
{
    //if( !XygCardRemains(lay) ) return MJ_HU; // �ݹ��˳����������û��ʣ�ƣ�����Ʒ��ء�
    //����һ���ݹ�����жϣ�����1000������������ʮ�����־
    if (deepth > MJ_MAX_DEEPTH)
    {
        //LOG_ERROR(_T("CMJCalclator MJ_HuPai!!! deepth too much, more than 1000)"));

        return 0;    //�����ݹ����޷���
    }

    if (deepth == 10)
    {

    }

    deepth++;

    if (!XygCardRemains(lay)) //�Ѿ�û��ʣ�����
    {
        if (MJ_TotalJokerNum(jokernum, jokernum2) == 0) //���в���ƥ�����
        {
            return MJ_HU;
        }
        //ʣ��������2��!�ݹ�

        if (MJ_TotalJokerNum(jokernum, jokernum2) >= 3) //ʣ��������3
        {
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 3);   // �����3

            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddJokerUnit(huDetails, MJ_CT_KEZI, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2);
                return MJ_HU;               // ���ʣ�������ϳɹ�������
            }
            else
            {
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }

        if (!bJiang && MJ_TotalJokerNum(jokernum, jokernum2) >= 2)
        {
            bJiang = TRUE;                  // ���ý��Ʊ�־
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 2);   // �����2

            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddJokerUnit(huDetails, MJ_CT_DUIZI, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2);
                return MJ_HU;               // ���ʣ�������ϳɹ�������
            }
            else
            {
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
                bJiang = FALSE;     // ������Ʊ�־
            }
        }
        return 0;//�޷�ƥ��,���ܺ�!
    }

    int i = 0;
    for (i = 1; lay[i] <= 0 && i < MAX_CARDS_LAYOUT_NUM; i++); // �ҵ����Ƶĵط���i���ǵ�ǰ��λ��, lay[i]������

    //UwlTrace(_T("i = %d\n"), i); // ������Ϣ

    // 4�����(����)
    if (lay[i] == 4)
    {
        // �����ǰ��������4��
        lay[i] = 0;     // ����ȫ��4����

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_GANG, i, 0, 0, jokeridx, jokeridx2, 0, 0);
            return MJ_HU;       // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i] = 4;     // ����ȡ��4�����
        }
    }
    // 3�����(���: 3��һ��)
    if (lay[i] >= 3)
    {
        // �����ǰ�Ʋ�����3��
        lay[i] -= 3;        // ��ȥ3����

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_KEZI, i, 0, 0, jokeridx, jokeridx2, 0, 0);
            return MJ_HU;       // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i] += 3; // ȡ��3�����
        }
    }
    // 3�����(���: 2��һ�� + ����)
    if (lay[i] >= 2 && MJ_TotalJokerNum(jokernum, jokernum2))
    {
        // �����ǰ�Ʋ�����2�Ų����в���
        lay[i] -= 2;        // ��ȥ2����
        int jn, jn2;
        MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_KEZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
            return MJ_HU;       // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i] += 2; // ȡ��3�����
            MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
        }
    }
    // 3�����(��X + 2�Ų���)
    if (lay[i] > 0 && MJ_TotalJokerNum(jokernum, jokernum2) >= 2)
    {
        // �����ǰ�Ʋ�����1�Ų�����2�����ϲ���
        lay[i]--;   // ������1
        int jn, jn2;
        MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 2);   // �����2

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_KEZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
            return MJ_HU; // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i]++; // �ָ�����
            MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
        }
    }
    // 2�����(����: 2��һ��)
    if (!bJiang && lay[i] >= 2)
    {
        // ���֮ǰû�н��ƣ��ҵ�ǰ�Ʋ�����2��
        bJiang = TRUE;                  // ���ý��Ʊ�־
        lay[i] -= 2;                // ��ȥ2����

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, 0, 0, jokeridx, jokeridx2, 0, 0);
            return MJ_HU;               // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i] += 2;    // ȡ��2�����
            bJiang = FALSE;     // ������Ʊ�־
        }
    }
    // 2�����(����: 1�� + ����)
    if (!bJiang && lay[i] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
    {
        // ���֮ǰû�н��ƣ��ҵ�ǰ�Ʋ�����1�Ų����в���
        bJiang = TRUE;                  // ���ý��Ʊ�־
        lay[i]--;               // ��ȥ1����
        int jn, jn2;
        MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1

        if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
        {
            MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
            return MJ_HU;               // ���ʣ�������ϳɹ�������
        }
        else
        {
            lay[i]++;   // ȡ��2�����
            MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            bJiang = FALSE;     // ������Ʊ�־
        }
    }
    if (i < 30)
    {
        // ˳����ϣ�ע���Ǵ�ǰ������ϣ�
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 2 && i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 && // �ų���ֵΪ8��9����
            lay[i + 1] > 0 && lay[i + 2] > 0)
        {
            // �������������������

            lay[i]--;
            lay[i + 1]--;
            lay[i + 2]--; // ��������1

            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i, 0, 0, jokeridx, jokeridx2, 0, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[i]++;
                lay[i + 1]++;
                lay[i + 2]++; // �ָ�������
            }
        }
        // ˳����ϣ�2������ + 1�Ų���
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 &&   // �ų���ֵΪ9����
            lay[i + 1] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // �������������1����,�����в���

            lay[i]--;
            lay[i + 1]--;   // ��������1
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1

            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[i]++;
                lay[i + 1]++; // �ָ�������
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        // ˳����ϣ���X + 1�Ų��� + ��(X+2)
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 2 && i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1 &&   // �ų���ֵΪ8��9����
            lay[i + 2] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // �������������,�����в���

            lay[i]--;
            lay[i + 2]--;   // ��������1
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1

            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[i]++;
                lay[i + 2]++; // �ָ�������
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
    }
    else if (IS_BIT_SET(gameflags, MJ_GF_FENG_CHI))
    {
        // �����Գ�
        if (lay[31] > 0 && lay[32] > 0 && lay[33] > 0)
        {
            // ������
            lay[31]--;
            lay[32]--;
            lay[33]--;
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;
                lay[32]++;
                lay[33]++;
            }
        }
        if (lay[31] > 0 && lay[32] > 0 && lay[34] > 0)
        {
            // ���ϱ�
            lay[31]--;
            lay[32]--;
            lay[34]--;
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 2);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;
                lay[32]++;
                lay[34]++;
            }
        }
        if (lay[32] > 0 && lay[33] > 0 && lay[34] > 0)
        {
            // ������
            lay[32]--;
            lay[33]--;
            lay[34]--;
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, 0, 0, jokeridx, jokeridx2, 0, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[32]++;
                lay[33]++;
                lay[34]++;
            }
        }
        if (lay[31] > 0 && lay[33] > 0 && lay[34] > 0)
        {
            // ������
            lay[31]--;
            lay[33]--;
            lay[34]--;
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, 0, 0, jokeridx, jokeridx2, 0, 1);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;
                lay[33]++;
                lay[34]++;
            }
        }
        if (lay[35] > 0 && lay[36] > 0 && lay[37] > 0)
        {
            // �з���
            lay[35]--;
            lay[36]--;
            lay[37]--;
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, 0, 0, jokeridx, jokeridx2, 0, 0);
                return MJ_HU; // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[35]++;
                lay[36]++;
                lay[37]++;
            }
        }
        if (lay[31] > 0 && lay[32] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[31]--;      // ��ȥ1����
            lay[32]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;      // ��1����
                lay[32]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[31] > 0 && lay[33] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[31]--;      // ��ȥ1����
            lay[33]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;      // ��1����
                lay[33]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[31] > 0 && lay[34] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[31]--;      // ��ȥ1����
            lay[34]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 31, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 2);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[31]++;      // ��1����
                lay[34]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[32] > 0 && lay[33] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[32]--;      // ��ȥ1����
            lay[33]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[32]++;      // ��1����
                lay[33]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[32] > 0 && lay[34] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // �ϱ�
            lay[32]--;      // ��ȥ1����
            lay[34]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 32, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[32]++;      // ��1����
                lay[34]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[33] > 0 && lay[34] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[33]--;      // ��ȥ1����
            lay[34]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 33, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[33]++;      // ��1����
                lay[34]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[35] > 0 && lay[36] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // �з�
            lay[35]--;      // ��ȥ1����
            lay[36]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 2, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[35]++;      // ��1����
                lay[36]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[35] > 0 && lay[37] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // �а�
            lay[35]--;      // ��ȥ1����
            lay[37]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 35, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 1, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[35]++;      // ��1����
                lay[37]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
        if (lay[36] > 0 && lay[37] > 0 && MJ_TotalJokerNum(jokernum, jokernum2))
        {
            // ����
            lay[36]--;      // ��ȥ1����
            lay[37]--;      // ��ȥ1����
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            if (MJ_HuPai(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos, gameflags, huflags, huDetails, bJiang, deepth))
            {
                MJ_AddUnit(huDetails, MJ_CT_SHUN, 36, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
                return MJ_HU;       // ���ʣ�������ϳɹ�������
            }
            else
            {
                lay[36]++;      // ��1����
                lay[37]++;      // ��1����
                MJ_RestoreJokerNum(jn, jn2, jokernum, jokernum2);
            }
        }
    }
    // �޷�ȫ����ϣ�������
    return 0;
}

DWORD CMJCalclator::MJ_HuPai_7Dui(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (!IS_BIT_SET(huflags, MJ_HU_7DUI))
    {
        // �������߶��Ӻ�
        return 0;
    }
    int remains = XygCardRemains(lay) + jokernum + jokernum2;
    if (12 != remains && 14 != remains)
    {
        return 0;
    }
    int joker_needs = 0;
    int i = 0;
    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        //
        if (1 == lay[i] || 3 == lay[i])
        {
            joker_needs++;
        }
    }
    if (jokernum + jokernum2 < joker_needs)
    {
        return 0;    // ���񲻹���
    }

    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        //
        if (1 == lay[i])
        {
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
        }
        else if (2 == lay[i])
        {
            MJ_AddUnit(huDetails, MJ_CT_DUIZI, i, 0, 0, jokeridx, jokeridx2, 0, 0);
        }
        else if (3 == lay[i])
        {
            int jn, jn2;
            MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);   // �����1
            MJ_AddUnit(huDetails, MJ_CT_GANG, i, jn - jokernum, jn2 - jokernum2, jokeridx, jokeridx2, 0, 0);
        }
        else if (4 == lay[i])
        {
            MJ_AddUnit(huDetails, MJ_CT_GANG, i, 0, 0, jokeridx, jokeridx2, 0, 0);
        }
        else {}
    }
    return MJ_HU;
}

DWORD CMJCalclator::MJ_HuPai_13BK(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (MJ_HuPai_13BK_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
            gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
    {
        // �װ�ɴ������
        if (1 == lay[jokeridx])
        {
            // ��ԭ�װ�
            int baiban_idx = MJ_GetBaiban(jokeridx, jokeridx2, gameflags);
            lay[baiban_idx] = 1;
            lay[jokeridx] = 0;
            if (MJ_HuPai_13BK_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
                    gameflags, huflags, huDetails))
            {
                return MJ_HU;
            }
        }
    }
    return 0;
}

DWORD CMJCalclator::MJ_HuPai_7Fng(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (MJ_HuPai_7Fng_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
            gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
    {
        // �װ�ɴ������
        if (1 == lay[jokeridx])
        {
            // ��ԭ�װ�
            int baiban_idx = MJ_GetBaiban(jokeridx, jokeridx2, gameflags);
            lay[baiban_idx] = 1;
            lay[jokeridx] = 0;
            if (MJ_HuPai_7Fng_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
                    gameflags, huflags, huDetails))
            {
                return MJ_HU;
            }
        }
    }
    return 0;
}

DWORD CMJCalclator::MJ_HuPai_QFng(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (MJ_HuPai_QFng_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
            gameflags, huflags, huDetails))
    {
        return MJ_HU;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
    {
        // �װ�ɴ������
        if (1 == lay[jokeridx])
        {
            // ��ԭ�װ�
            int baiban_idx = MJ_GetBaiban(jokeridx, jokeridx2, gameflags);
            lay[baiban_idx] = 1;
            lay[jokeridx] = 0;
            if (MJ_HuPai_QFng_Base(lay, jokernum, jokernum2, jokeridx, jokeridx2, addpos,
                    gameflags, huflags, huDetails))
            {
                return MJ_HU;
            }
        }
    }
    return 0;
}

DWORD CMJCalclator::MJ_HuPai_13BK_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (!IS_BIT_SET(huflags, MJ_HU_13BK))
    {
        // ������ʮ������
        return 0;
    }
    int remains = XygCardRemains(lay) + jokernum + jokernum2;
    if (14 != remains)
    {
        return 0;
    }

    int i = 0;
    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        //
        if (lay[i] >= 2)
        {
            return 0;
        }
    }
    int jokerid = MJ_ReverseIndexToID(jokeridx, gameflags);
    int jokerid2 = MJ_ReverseIndexToID(jokeridx2, gameflags);

    for (i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        //
        if (0 == lay[i])
        {
            continue;
        }
        if (MJ_IsFeng(i, jokerid, jokerid2, gameflags))
        {
            continue;
        }
        // ��������
        if (i % MJ_LAYOUT_MOD != MJ_LAYOUT_MOD - 1)
        {
            if (lay[i + 1] >= 1 || lay[i + 2] >= 1)
            {
                return 0;
            }
        }
    }
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = MJ_CT_13BK;
    return MJ_HU;
}

DWORD CMJCalclator::MJ_HuPai_7Fng_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (!IS_BIT_SET(huflags, MJ_HU_7FNG))
    {
        // ����������ȫ
        return 0;
    }
    for (int i = MJ_INDEX_DONGFENG; i <= MJ_INDEX_BAIBAN; i++)
    {
        if (0 == lay[i])
        {
            BOOL pure_7fng = IS_BIT_SET(gameflags, MJ_GF_7FNG_PURE); // ������治������ȫ
            if (!pure_7fng && jokernum + jokernum2 > 0)
            {
                int jn, jn2;
                MJ_DecreaseJokerNum(jn, jn2, jokernum, jokernum2, 1);       // �����1
                continue;
            }
            return 0;
        }
    }
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = MJ_CT_7FNG;
    return MJ_HU;
}

DWORD CMJCalclator::MJ_HuPai_QFng_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (!IS_BIT_SET(huflags, MJ_HU_QFNG))
    {
        // ������ȫ���
        return 0;
    }
    int remains = XygCardRemains(lay) + jokernum + jokernum2;
    if (0 == remains)
    {
        return 0;
    }

    int jokerid = MJ_ReverseIndexToID(jokeridx, gameflags);
    int jokerid2 = MJ_ReverseIndexToID(jokeridx2, gameflags);

    for (int i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        if (0 == lay[i])
        {
            continue;
        }
        if (0 == MJ_IsFeng(i, jokerid, jokerid2, gameflags))
        {
            return 0;
        }
    }
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = MJ_CT_QFNG;
    return MJ_HU;
}

DWORD CMJCalclator::MJ_HuPai_258(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
    DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails)
{
    int lay[MAX_CARDS_LAYOUT_NUM];  //
    memcpy(lay, nCardsLay, sizeof(lay));

    if (!IS_BIT_SET(huflags, MJ_HU_258))
    {
        // ������258��
        return 0;
    }
    int remains = XygCardRemains(lay) + jokernum + jokernum2;
    if (0 == remains)
    {
        return 0;
    }

    int jokerid = MJ_ReverseIndexToID(jokeridx, gameflags);
    int jokerid2 = MJ_ReverseIndexToID(jokeridx2, gameflags);

    for (int i = 1; i < MAX_CARDS_LAYOUT_NUM; i++)
    {
        //
        if (0 == lay[i])
        {
            continue;
        }
        if (MJ_IsFeng(i, jokerid, jokerid2, gameflags))
        {
            return 0;
        }
        if (!MJ_Is258(i))
        {
            return 0;
        }
    }
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = MJ_CT_258;
    return MJ_HU;
}

int CMJCalclator::MJ_IsBianCardRightWithJoker(int cardshape, int cardvalue, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))
    {
        // ��ʹ�ò���
        return 0;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
    {
        // �װ�ɴ������
        return 0;
    }
    int jokershape = MJ_CalculateCardShape(nJokerID, gameflags);
    int jokervalue = MJ_CalculateCardValue(nJokerID, gameflags);
    int jokershape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
    int jokervalue2 = MJ_CalculateCardValue(nJokerID2, gameflags);

    if (cardshape == jokershape && cardvalue - 3 == jokervalue
        || cardshape == jokershape2 && cardvalue - 3 == jokervalue2)
    {
        return 1;
    }
    return 0;
}

int CMJCalclator::MJ_IsBianCardLeftWithJoker(int cardshape, int cardvalue, int nJokerID, int nJokerID2, DWORD gameflags)
{
    if (!IS_BIT_SET(gameflags, MJ_GF_USE_JOKER))
    {
        // ��ʹ�ò���
        return 0;
    }
    if (IS_BIT_SET(gameflags, MJ_GF_BAIBAN_JOKER))
    {
        // �װ�ɴ������
        return 0;
    }
    int jokershape = MJ_CalculateCardShape(nJokerID, gameflags);
    int jokervalue = MJ_CalculateCardValue(nJokerID, gameflags);
    int jokershape2 = MJ_CalculateCardShape(nJokerID2, gameflags);
    int jokervalue2 = MJ_CalculateCardValue(nJokerID2, gameflags);

    if (cardshape == jokershape && cardvalue + 3 == jokervalue
        || cardshape == jokershape2 && cardvalue + 3 == jokervalue2)
    {
        return 1;
    }
    return 0;
}

int CMJCalclator::MJ_ReverseIndexToID(int index, DWORD gameflags)
{
    for (int i = 0; i < MJ_MAX_CARDS; i++)
    {
        if (index == MJ_CalcIndexByID(i, gameflags))
        {
            return i;
        }
    }
    return INVALID_OBJECT_ID;
}

int CMJCalclator::MJ_Is258(int index)
{
    if (2 == index || 5 == index || 8 == index)
    {
        return 1;
    }
    if (12 == index || 15 == index || 18 == index)
    {
        return 1;
    }
    if (22 == index || 25 == index || 28 == index)
    {
        return 1;
    }

    return 0;
}

int CMJCalclator::MJ_TotalJokerNum(int jokernum, int jokernum2)
{
    if (jokernum >= 0 && jokernum2 >= 0)
    {
        return jokernum + jokernum2;
    }
    return 0;
}

int CMJCalclator::MJ_AddJokerUnit(HU_DETAILS& huDetails, DWORD type, int jokernum, int jokernum2, int jokeridx, int jokeridx2)
{
    assert(MJ_CT_GANG == type || MJ_CT_KEZI == type
        || MJ_CT_DUIZI == type || MJ_CT_SHUN == type);
    huDetails.nUnitsCount++;
    huDetails.HuUnits[huDetails.nUnitsCount - 1].dwType = type;

    if (MJ_CT_DUIZI == type)
    {
        // ����
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0]
            = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
            = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
    }
    else if (MJ_CT_KEZI == type)
    {
        // ����
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[0]
            = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[1]
            = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
        huDetails.HuUnits[huDetails.nUnitsCount - 1].aryIndexes[2]
            = -MJ_UseJokerNum(jokernum, jokernum2, jokeridx, jokeridx2);
    }

    return huDetails.nUnitsCount;
}

int CMJCalclator::MJ_CanJokerReverseUnit(HU_UNIT& joker_unit, int nJokerID, int nJokerID2, DWORD gameflags)
{
    HU_UNIT unit;
    memcpy(&unit, &joker_unit, sizeof(HU_UNIT));

    for (int i = 0; i < MJ_UNIT_LEN; i++)
    {
        if (unit.aryIndexes[i] < 0)
        {
            unit.aryIndexes[i] = -unit.aryIndexes[i];
        }
    }
    if (MJ_CT_SHUN == unit.dwType)
    {
        int lay[MAX_CARDS_LAYOUT_NUM];  //
        memset(lay, 0, sizeof(lay));
        lay[unit.aryIndexes[0]]++;
        lay[unit.aryIndexes[1]]++;
        lay[unit.aryIndexes[2]]++;
        return MJ_CanShunAsJoined(lay, unit.aryIndexes[0], nJokerID, nJokerID2, gameflags);
    }
    else if (MJ_CT_DUIZI == unit.dwType)
    {
        return (unit.aryIndexes[0] == unit.aryIndexes[1]);
    }
    else if (MJ_CT_KEZI == unit.dwType)
    {
        return (unit.aryIndexes[0] == unit.aryIndexes[1]
                && unit.aryIndexes[0] == unit.aryIndexes[2]);
    }
    else if (MJ_CT_GANG == unit.dwType)
    {
        return (unit.aryIndexes[0] == unit.aryIndexes[1]
                && unit.aryIndexes[0] == unit.aryIndexes[2]
                && unit.aryIndexes[0] == unit.aryIndexes[3]);
    }
    return 0;
}

int CMJCalclator::MJ_CanJokerReverse(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int count = 0;
    for (int i = 0; i < huDetails.nUnitsCount; i++)
    {
        for (int j = 0; j < MJ_UNIT_LEN; j++)
        {
            if (huDetails.HuUnits[i].aryIndexes[j] < 0)
            {
                count++;
                if (!MJ_CanJokerReverseUnit(huDetails.HuUnits[i], nJokerID, nJokerID2, gameflags))
                {
                    return 0;
                }
                else
                {
                    break;
                }
            }
        }
    }
    return count;
}

// ���
int CMJCalclator::MJ_IsFengEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags)
{
    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsFeng(index, nJokerID, nJokerID2, gameflags);
}

// ��������
int CMJCalclator::MJ_IsFengDxnbEx(int nCardID, DWORD gameflags)
{
    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsFengDnxb(index, gameflags);
}

// �з���
int CMJCalclator::MJ_IsFengZfbEx(int nCardID, DWORD gameflags)
{
    int index = MJ_CalcIndexByID(nCardID, gameflags);
    return MJ_IsFengZfb(index, gameflags);
}

void CMJCalclator::MJ_MixupHuDetailsEx(HU_DETAILS& huDetails1, HU_DETAILS& huDetails2)
{
    for (int i = 0; i < MJ_HU_FLAGS_ARYSIZE; i++)
    {
        huDetails1.dwHuFlags[i] |= huDetails2.dwHuFlags[i];
    }
}

void CMJCalclator::xyReversalMoreByValue(int array[], int value[], int length)
{
    int i, j, temp;
    for (i = 0; i < length - 1; i++)
    {
        for (j = i + 1; j < length; j++) /*ע��ѭ����������*/
        {
            if (value[i] < value[j])
            {
                temp = array[i];
                array[i] = array[j];
                array[j] = temp;
                temp = value[i];
                value[i] = value[j];
                value[j] = temp;
            }
        }
    }

}

void CMJCalclator::xyRandomSort(int array[], int length, int seed)
{
    srand(seed);
    int* value = new int[length];
    int s = length * 1000;
    for (int i = 0; i < length; i++)
    {
        value[i] = rand() % s;
    }
    xyReversalMoreByValue(array, value, length);
    delete[]value;
}
