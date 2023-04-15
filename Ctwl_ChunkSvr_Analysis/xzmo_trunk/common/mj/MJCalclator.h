#pragma once

class CMJCalclator
{
public:
    CMJCalclator();
    virtual ~CMJCalclator();

    int MJCalclatorTest() { return 1; };

    virtual  int MJ_CalculateCardValue(int nID, DWORD gameflags);
    virtual  int MJ_CalculateCardShape(int nID, DWORD gameflags);
    virtual  int MJ_CalculateCardShapeByIndex(int nIndex, DWORD gameflags);
    virtual  DWORD MJ_LayCards(int nCardIDs[], int nCardsLen, int nCardsLay[], DWORD gameflags);
    virtual  DWORD MJ_CanAnGang(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int& index);
    virtual  DWORD MJ_CanAnGangEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    virtual  DWORD MJ_CanGangSelfEx(int nCardIDs[], int nCardsLen, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    virtual  int MJ_CalcIndexByID(int nID, DWORD gameflags);
    virtual  int MJ_DrawCardsByIndex(int nCardIDs[], int nCardsLen, int index, int nResultIDs[], int nCount, DWORD gameflags);
    virtual  int MJ_IsFengZfb(int index, DWORD gameflags);
    virtual  int MJ_IsFengDnxb(int index, DWORD gameflags);
    virtual  int MJ_GetGangNO(int beginno, int jokerno, int totalcards, int& tail_taken, BOOL& joker_jump);
    virtual  int MJ_IsHua(int index, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_IsHuaEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  BOOL MJ_IsJoker(int index, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  BOOL MJ_IsJokerEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_GetJokerIndex(int nJokerID, int nJokerID2, DWORD gameflags, int& jokeridx, int& jokeridx2);
    virtual  int MJ_CalcJokerIndex(int j_shape, int j_value);
    virtual  int MJ_IsSameCard(int id1, int id2, DWORD gameflags);
    virtual  int MJ_GetBaiban(int jokeridx, int jokeridx2, DWORD gameflags);
    virtual  int MJ_GetBaibanEx(int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_IsBaiban(int index, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_IsBaibanEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_DrawSameCards(int nCardIDs[], int nCardsLen, int nCardID, int nResultIDs[], int nCount, DWORD gameflags);
    virtual  DWORD MJ_CanPeng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanPengEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    virtual  DWORD MJ_CanMnGang(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanMnGangEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    virtual  int MJ_JoinCard(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2,
        int& addpos, DWORD gameflags, BOOL to_revert_joker, int& jokernum2);
    virtual  DWORD MJ_CanShunAsJoined_Normal(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanShunAsJoined_Feng(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  int MJ_IsFeng(int index, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanShunAsJoined(int nCardsLay[], int addpos, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanChi(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual  DWORD MJ_CanChiEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    virtual int MJ_GetJokerNum(int nCardsLay[], int nJokerID, int nJokerID2, DWORD gameflags, int& jokernum2);
    // 麻将 公共函数
    // 能否胡牌的基本判断函数
    virtual DWORD MJ_CanHu(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否花牌
    virtual DWORD MJ_CanHua(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual DWORD MJ_CanHuaEx(int nCardIDs[], int nCardsLen, int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, int nResultIDs[]);
    // 能否嵌张的判断函数
    virtual DWORD MJ_CanHu_Qian(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHu_Qian_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否胡牌的详细判断函数
    virtual DWORD MJ_CanHu_Various(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut);
    virtual DWORD MJ_CanHuAsJoined(int nCardsLay[], int jokernum, int jokernum2, int nJokerID, int nJokerID2, int addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual int MJ_HuaCount(int nCardsLay[], int nJokerID, int nJokerID2, DWORD gameflags);
    // 能否边张的判断函数
    virtual DWORD MJ_CanHu_Bian(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHu_Bian_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否吃张的判断函数
    virtual DWORD MJ_CanHu_Chi(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHu_Chi_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否爆头的判断函数
    virtual DWORD MJ_CanHu_BaoTou(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否单吊的判断函数
    virtual DWORD MJ_CanHu_Diao(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHu_Diao_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否对倒的判断函数
    virtual DWORD MJ_CanHu_Duid(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHu_Duid_Joker(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否七对子的判断函数
    virtual DWORD MJ_CanHu_7Dui(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否十三不靠的判断函数
    virtual DWORD MJ_CanHu_13BK(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否七字全的判断函数
    virtual DWORD MJ_CanHu_7Fng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    // 能否全风板的判断函数
    virtual DWORD MJ_CanHu_QFng(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut);
    // 能否258胡的判断函数
    virtual DWORD MJ_CanHu_258(int nCardsLay[], int nCardID, int nJokerID, int nJokerID2, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags, DWORD dwOut);
    virtual int MJ_Is258(int index);

    virtual int MJ_AddUnit_Simple(HU_DETAILS& huDetails, DWORD type, int a, int b, int c = 0, int d = 0);
    virtual int MJ_AddUnit(HU_DETAILS& huDetails, DWORD type, int index,
        int jokernum, int jokernum2, int jokeridx, int jokeridx2, int jokerpos, int emptypos);

    virtual DWORD MJ_CanHuWithJoker(int nCardsLay[], int nCardID,
        int nJokerID, int nJokerID2,
        int& jokernum, int& jokernum2,
        int& addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);
    virtual DWORD MJ_CanHuWithoutJoker(int nCardsLay[], int nCardID,
        int nJokerID, int nJokerID2,
        int& jokernum, int& jokernum2,
        int& addpos, DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, DWORD dwFlags);

    virtual int MJ_DecreaseJokerNum(int& jn, int& jn2, int& jokernum, int& jokernum2, int dec);
    virtual int MJ_RestoreJokerNum(int jn, int jn2, int& jokernum, int& jokernum2);
    virtual int MJ_UseJokerNum(int& jokernum, int& jokernum2, int jokeridx, int jokeridx2);
    virtual int MJ_TellJokerUsed(int cardidx, int jokeridx, int jokeridx2, int& ju, int& ju2);

    virtual DWORD MJ_HuPai(int lay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails, BOOL bJiang, int deepth);
    virtual DWORD MJ_HuPai_7Dui(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_13BK(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_7Fng(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_QFng(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_13BK_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_7Fng_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_QFng_Base(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual DWORD MJ_HuPai_258(int nCardsLay[], int jokernum, int jokernum2, int jokeridx, int jokeridx2, int addpos,
        DWORD gameflags, DWORD huflags, HU_DETAILS& huDetails);
    virtual int MJ_AddJokerUnit(HU_DETAILS& huDetails, DWORD type, int jokernum, int jokernum2, int jokeridx, int jokeridx2);
    virtual int MJ_IsBianCardRightWithJoker(int cardshape, int cardvalue, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_IsBianCardLeftWithJoker(int cardshape, int cardvalue, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_ReverseIndexToID(int index, DWORD gameflags);
    virtual int MJ_TotalJokerNum(int jokernum, int jokernum2);//该函数实体位于TcMj1.0
    virtual int MJ_CanJokerReverseUnit(HU_UNIT& joker_unit, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_CanJokerReverse(HU_DETAILS& huDetails, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_IsFengEx(int nCardID, int nJokerID, int nJokerID2, DWORD gameflags);
    virtual int MJ_IsFengDxnbEx(int nCardID, DWORD gameflags);
    virtual int MJ_IsFengZfbEx(int nCardID, DWORD gameflags);

    void  MJ_MixupHuDetailsEx(HU_DETAILS& huDetails1, HU_DETAILS& huDetails2);
    void  xyReversalMoreByValue(int array[], int value[], int length);
    void  xyRandomSort(int array[], int length, int seed);
};

