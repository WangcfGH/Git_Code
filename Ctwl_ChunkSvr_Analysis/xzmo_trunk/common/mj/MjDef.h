#pragma once

#define     MJ_CHAIR_COUNT           4  // �齫������
#define     MJ_BREAK_DOUBLE          8  // ���ܿ۷ֱ���
#define     MJ_THROW_WAIT           15  // �齫���Ƶȴ�ʱ��(��)
#define     MJ_PGCH_WAIT             5  // �齫���ܳԺ��ȴ�ʱ��(��)
#define     MJ_PGCH_WAIT_EXT         2  // �齫���ܳԺ��ȴ�ʱ��(׷��)(��)
#define     MJ_MAX_BANKER_HOLD       3  // ���������ׯ����
#define     MJ_MAX_AUTO             INT_MAX // 
#define     MJ_UNDERTAKE_LIMEN       3  // �а���ֵ
#define     MJ_TOTAL_CARDS          152 // �齫���ܹ�����
#define     MJ_TOTAL_PACKS           4  // �齫����ͬ������
#define     MJ_CHAIR_CARDS          32  // ����������������
#define     MJ_LAYOUT_NUM           58  // �齫�Ʒ��󳤶�
#define     MJ_LAYOUT_MOD           10  // �齫�Ʒ���ģ��
#define     MJ_MAX_CARDS            168 // �齫���������
#define     MJ_MAX_OUT              36  // ��������
#define     MJ_MAX_PENG             6   // ���������
#define     MJ_MAX_GANG             6   // ��������
#define     MJ_MAX_CHI              6   // ��������
#define     MJ_MAX_HUA              36  // ��󲹻���
#define     MJ_INIT_HAND_CARDS      14

// �齫��״̬
#define     MJ_STAT_PENG_OUT        10  // ����
#define     MJ_STAT_GANG_OUT        12  // �ܳ�
#define     MJ_STAT_CHI_OUT         14  // �Գ�
#define     MJ_STAT_HUA_OUT         16  // ����

#define     MJ_STAT_PENG_IN         30  // ����
#define     MJ_STAT_GANG_IN         32  // �ܽ�
#define     MJ_STAT_CHI_IN          34  // �Խ�

// �齫�ƻ�ɫ
#define     MJ_CS_WAN               0   // ����
#define     MJ_CS_TIAO              1   // ����
#define     MJ_CS_DONG              2   // ����
#define     MJ_CS_FENG              3   // ���
#define     MJ_CS_HUA               4   // ����
#define     MJ_CS_TOTAL             5   // ��ɫ����

#define     TS_AFTER_CHI            0x00000020  //�ճԹ�һ����
#define     TS_AFTER_PENG           0x00000040  //������һ����
#define     TS_AFTER_GANG           0x00000080  //�ոܹ�һ����

#define     MJ_PENG                 0x00000001  // ��
#define     MJ_GANG                 0x00000002  // ��
#define     MJ_CHI                  0x00000004  // ��
#define     MJ_HU                   0x00000008  // ��
#define     MJ_HUA                  0x00000010  // ����
#define     MJ_GUO                  0x00000020  // ����

#define     MJ_GANG_MN              0x00000001  // ����
#define     MJ_GANG_PN              0x00000002  // ����
#define     MJ_GANG_AN              0x00000004  // ����

#define     MJ_HU_FLAGS_ARYSIZE     4
#define     MJ_HU_GAINS_ARYSIZE     64

// dwHuFlags[0]
#define     MJ_HU_FANG              0x00000001  // �ų�
#define     MJ_HU_ZIMO              0x00000002  // ����
#define     MJ_HU_QGNG              0x00000004  // ����

#define     MJ_HU_7DUI              0x00000010  // �߶���
#define     MJ_HU_13BK              0x00000020  // ʮ������
#define     MJ_HU_7FNG              0x00000040  // ����ȫ(�߷�)
#define     MJ_HU_QFNG              0x00000080  // ȫ���

#define     MJ_HU_TIAN              0x00000100  // ���
#define     MJ_HU_DI                0x00000200  // �غ�
#define     MJ_HU_REN               0x00000400  // �˺�
#define     MJ_HU_BANK              0x00000800  // ׯ�Һ�

#define     MJ_HU_PNPN              0x00001000  // ������(�ԶԺ�)
#define     MJ_HU_1CLR              0x00002000  // ��һɫ
#define     MJ_HU_2CLR              0x00004000  // ��һɫ
#define     MJ_HU_FENG              0x00008000  // ��һɫ(ȫ��)

//
#define     MJ_HU_WUDA              0x00010000  // �޴�
#define     MJ_HU_CSGW              0x00020000  // �����λ(��ԭ)|�ù�
#define     MJ_HU_3CAI              0x00040000  // ����
#define     MJ_HU_4CAI              0x00080000  // �Ĳ�

#define     MJ_HU_GKAI              0x00100000  // �ܿ�
#define     MJ_HU_DDCH              0x00200000  // �����
#define     MJ_HU_HDLY              0x00400000  // ��������

#define     MJ_HU_258               0x01000000  // 258(��һɫ)

#define     MJ_HU_MQNG              0x10000000  // ������(������)
#define     MJ_HU_QQRN              0x20000000  // ȫ����

// dwHuFlags[1]
#define     MJ_HU_BTOU              0x00000001  // ��ͷ
#define     MJ_HU_CAIP              0x00000002  // ��Ʈ

#define     MJ_HU_DIAO              0x00000010  // ����
#define     MJ_HU_DUID              0x00000020  // �Ե�
#define     MJ_HU_QIAN              0x00000040  // Ƕ��
#define     MJ_HU_BIAN              0x00000080  // ����
#define     MJ_HU_CHI               0x00000100  // ����

//
#define     MJ_UNIT_LEN             4           // �������������
#define     MJ_MAX_UNITS            8           // ������൥Ԫ��

// ����
#define     MJ_CT_SHUN              0x00000001  // ˳��
#define     MJ_CT_KEZI              0x00000002  // ����
#define     MJ_CT_DUIZI             0x00000004  // �齫(С����)
#define     MJ_CT_GANG              0x00000008  // ����

#define     MJ_CT_13BK              0x00000020  // ʮ������
#define     MJ_CT_7FNG              0x00000040  // ����ȫ(�߷�)
#define     MJ_CT_QFNG              0x00000080  // ȫ���
#define     MJ_CT_258               0x00000100  // 258(��һɫ)

#define     MJ_CT_REGULAR(ct)       (MJ_CT_13BK != ct && MJ_CT_7FNG != ct && MJ_CT_QFNG != ct && MJ_CT_258 != ct)

// ��Ϸ����ѡ��
#define     MJ_GF_USE_JOKER         0x00000001  // �в���(�ٴ�)
#define     MJ_GF_JOKER_PLUS1       0x00000002  // ���Ƽ�1�ǲ���
#define     MJ_GF_BAIBAN_JOKER      0x00000004  // �װ�ɴ������
#define     MJ_GF_JOKER_REVERT      0x00000008  // ������Ի�ԭ(���ܳԺ�)

#define     MJ_GF_16_CARDS          0x00000010  // 16���齫
#define     MJ_GF_FENG_CHI          0x00000020  // �����Գ�

#define     MJ_GF_CHI_FORBIDDEN     0x00000100  // ���ܳ�
#define     MJ_GF_FANG_FORBIDDEN    0x00000200  // ���ܷų�
#define     MJ_GF_QGNG_FORBIDDEN    0x00000400  // ��������

#define     MJ_GF_GANG_MN_ROB       0x00001000  // ����������
#define     MJ_GF_GANG_PN_ROB       0x00002000  // ����������
#define     MJ_GF_NO_GANGROB_BAOTOU 0x00004000  // ��ͷ��������

#define     MJ_GF_JOKER_SHOWN_SKIP  0x00010000  // ������������
#define     MJ_GF_JOKER_THROWN_PIAO 0x00020000  // ֧�ֲ�Ʈ
#define     MJ_GF_ONE_THROW_MULTIHU 0x00040000  // ֧��һ�ڶ���
#define     MJ_GF_FEED_UNDERTAKE    0x00080000  // ����Ҫ�а�

#define     MJ_GF_7FNG_PURE         0x00400000  // ������治������ȫ

#define     MJ_GF_JOKER_DIAO_ZIMO   0x01000000  // ���񵥵���������
#define     MJ_GF_JOKER_DUID_ZIMO   0x02000000  // ����Ե���������
#define     MJ_GF_JOKER_QIAN_ZIMO   0x04000000  // ����Ƕ�ű�������
#define     MJ_GF_JOKER_BIAN_ZIMO   0x08000000  // ������ű�������

#define     MJ_GF_DICES_TWICE       0x10000000  // ����Ҫ������
#define     MJ_GF_ANGANG_SHOW       0x20000000  // ���ܵ����ܷ���ʾ
#define     MJ_GF_JOKER_SORTIN      0x40000000  // �����Ʋ��̶���ͷ��
#define     MJ_GF_BAIBAN_NOSORT     0x80000000  // ��������Ʋ������

// ���ܳԵ��Ƶ�״̬
#define     MJ_OUT_FENG             0x00000001  // ȫ���
#define     MJ_OUT_258              0x00000002  // 258
#define     MJ_OUT_MIXUP            0x10000000  // �����

// ��Ӯ���
#define     MJ_GW_FANG              0x01000000  // �ų��
#define     MJ_GW_ZIMO              0x02000000  // ������
#define     MJ_GW_QGNG              0x04000000  // ���ܺ�

#define     MJ_GW_MULTI             0x10000000  // һ�ڶ���

// �������
#define     MJ_UC_QUICK_CATCH       0x00000001  // ����ץ��

// ����״̬
#define     MJ_TS_HU_READY          0x01000000  // ����״̬
#define     MJ_TS_GANG_MN           0x02000000  // ������״̬
#define     MJ_TS_GANG_PN           0x04000000  // ������״̬
#define     MJ_TS_GANG_AN           0x08000000  // ������״̬

#define     MJ_FIRST_CATCH_13       13
#define     MJ_FIRST_CATCH_16       16

#define     MJ_INDEX_DONGFENG       31  // ����
#define     MJ_INDEX_NANFENG        32  // �Ϸ�
#define     MJ_INDEX_XIFENG         33  // ����
#define     MJ_INDEX_BEIFENG        34  // ����

#define     MJ_INDEX_HONGZHONG      35  // ����
#define     MJ_INDEX_FACAI          36  // ����
#define     MJ_INDEX_BAIBAN         37  // �װ�

#define     MJ_MATCH_HUFLAGS(demand, result, flag)  (IS_BIT_SET(demand, flag) && IS_BIT_SET(result, flag))

#define     MJ_ERR_HU_GAINS_LESS    -1000   // ����|̨��|��������

#define     MJ_MAX_GAIN_TEXT_SIZE   256     // ����������󳤶�

#define     MJ_GF_14_HANDCARDS          14      // 14���齫
#define     MJ_GF_17_HANDCARDS          17      // 17���齫

//gameflag2
#define     PGL_MJGF_HUFIRST                0x00000001       //���Ȳ�����
#define     PGL_MJGF_PENFIRST               0x00000002       //���ܸ���
#define     YQW_LIMIT_WINPOINTS             0x00000004  // һ����ⶥ����
#define     MJ_HU_MAXWINPOINTS              0x00000008       //һ�ڶ���,������ߵ��˺���

#define     MJ_HU_PRETING                   0x00000010       //����ǰ����������
#define     MJ_AUTO_BUHUA                   0x00000020 //������Զ�����

#define     MJ_GF_GANG_AN_ROB               0x00008000        //����������
#define     MJ_TING                         0x00000040  // ����

#define     MERGE_THROWCARDS_CATCHCARDS     100
#define     CARD_BACK_ID                    -2

//pb msg
#define     MJ_GR_PREHU_TINGCARD            GAME_REQ_BASE_EX + 19002
#define     MJ_GR_BAOTING_THROWCARDS        GAME_REQ_BASE_EX + 19003
#define     MJ_GR_BAOTING_MERGETHROWCARDS   GAME_REQ_BASE_EX + 19004
#define     NTF_SOMEONE_BUHUA               GAME_REQ_BASE_EX + 19005

#define     MJ_MAX_DEEPTH  1000

#define     YQW_AUTOPLAY_WAIT                0// ��ײ�ܳԵĵȴ�ʱ��
#define     YQW_YQWQUICK_WAIT                9// 9����ٷ��ĵȴ�ʱ��
#define     YQW_LIMIT_WINPOINTS_VALUE        123         // �ⶥ����
#define     YQWMJ_GAME_FLAGS2                0

#define     MJ_GAME_FIAGS    MJ_GF_USE_JOKER          \
                            | MJ_GF_GANG_PN_ROB       \
                            | MJ_GF_NO_GANGROB_BAOTOU \
                            | MJ_GF_JOKER_SHOWN_SKIP

enum MJ_PGC_TYPE
{
    MJ_TYPE_CHI = 1,
    MJ_TYPE_ANGANG = 2,
    MJ_TYPE_PNGANG = 3,
    MJ_TYPE_MNGANG = 4,
    MJ_TYPE_PENG = 5,
};
typedef struct _tagHU_UNIT
{
    DWORD dwType;   //
    int aryIndexes[MJ_UNIT_LEN];
    int nReserved[2];
} HU_UNIT, *LPHU_UNIT;

typedef struct _tagHU_DETAILS
{
    DWORD dwHuFlags[MJ_HU_FLAGS_ARYSIZE];       // ���Ʊ�־
    int nHuGains[MJ_HU_GAINS_ARYSIZE];          // ���Ʒ���
    int nSubGains[MJ_HU_GAINS_ARYSIZE];         // ���Ʒ���(����)
    int nUnitsCount;                            // �������͵�Ԫ��
    HU_UNIT HuUnits[MJ_MAX_UNITS];              // ���ƾ�������
    int nReserved2[4];
} HU_DETAILS, *LPHU_DETAILS;

typedef struct _tagCARDS_UNIT
{
    int nCardIDs[MJ_UNIT_LEN];
    int nCardChair;
    int nReserved[2];
} CARDS_UNIT, *LPCARDS_UNIT;

typedef CArray<CARDS_UNIT, CARDS_UNIT&> CCardsUnitArray;

