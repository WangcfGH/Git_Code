#pragma once
// ��Ϸ��Ϣ
#define     TOTAL_CHAIRS            4//�������
#define     TOTAL_CARDS             108//�ܹ���������
#define     MAX_CARDSID             108//�Ƶ����ID(�޶���)
#define     REST_CARDS              0//���������Ƶ�����������̨�齫��������
#define     TOTAL_PACKS             4
#define     CHAIR_CARDS             32//ÿ����������������
#define     LAYOUT_MOD              10//ͬ�ֻ�ɫ�в�ͬ��ֵ���������齫Ϊ10���˿�Ϊ13��
#define     LAYOUT_NUM_EX           LAYOUT_NUM

#define     THROW_WAIT              20// ���Ƶȴ�ʱ��
#define     PGCH_WAIT               10// ��ײ�ܳԵĵȴ�ʱ��
#define     MAX_BANKER_HOLD         100// ���������ׯ����
#define     BANKER_BONUS            0  // ��ׯ��Ӯ׷�ӷ���
#define     LAYOUT_NUM              49//��ͬ��ɫ���ƹ��ж�����

#define     HU_MAX                  16  //����������34

#define     XZMO_BASE_BONUS             1  //LIMK�мҵ׷�
#define     XZMO_BASE_BANKER            3  //LIMKׯ�ҵ׷�

#define     DINGQUE_WAIT            10 //add 20130916 ��ȱ

#define  MJ_HU_HUAZHU                   0x00000010
#define  MJ_HU_TING                     0x00000020
#define  MJ_GIVE_UP                     0x00000040

#define  MJ_HU_MNGANG                   0x00000100  // ����
#define  MJ_HU_PNGANG                   0x00000200  // ����
#define  MJ_HU_ANGANG                   0x00000400  // ����

#define  SYSMSG_PLAYER_HU               3
#define  SYSMSG_PLAYER_NEXTTURN         4
#define  SYSMSG_PLAYER_GIVEUP           5
#define  SYSMSG_PLAYER_FIXMISS          7
#define  SYSMSG_PLAYER_EXCHANGE3CARDS   8

#define  CARD_TYPE_COUNT                3
#define  SVR_WAIT_SECONDS               2
#define  FAPAITIME                      0.5 //����ʱÿ��0.5s
#define  EXCHANGE3CARDS_COUNT           3

#define  ROOM_TYPE_XUELIU               0x00000008
#define  ROOM_TYPE_EXCHANGE3CARDS       0x00000010
#define  TS_WAITING_EXCHANGE3CARDS      0x00000004 //�ȴ�������
#define  TS_WAITING_GIVEUP              0x00000008 //�ȴ�����

#define MJ_HU_CALLTRANSFER              0x00000008  // ����ת��
#define MJ_HU_DRAWBACK                  0x00000080  // ��˰
#define MJ_HU_GPAO                      0x00200000  // ������
#define MJ_HU_DEPOSIT_LIMIT             0x00800000  // ������С����
#define LAYOUT_XZMO             30
#define SHAPE_COUNT             3

enum
{
    Dir_Clockwise, //˳ʱ��
    Dir_AntiClockwise, //��ʱ��
    Dir_Opposite, //�����
    Dir_Max,
};

#define     GAME_FLAGSEX             MJ_GF_CHI_FORBIDDEN     \
                                    | MJ_GF_GANG_PN_ROB     \
                                    | MJ_GF_ONE_THROW_MULTIHU  \
                                    | MJ_GF_BAIBAN_NOSORT   \
                                    | MJ_GF_ANGANG_SHOW

#define     GAME_FLAGS2EX           PGL_MJGF_HUFIRST

#define     HU_FLAGS_0EX             MJ_HU_FANG            \
                                    | MJ_HU_ZIMO            \
                                    | MJ_HU_QGNG            \
                                    | MJ_HU_7DUI            \
                                    | MJ_HU_TIAN            \
                                    | MJ_HU_DI              \
                                    | MJ_HU_GKAI

#define     HU_FLAGS_1EX             0

enum HU_GAIN
{
    HU_GAIN_BASE,                // С��
    HU_GAIN_7DUI,                // 7��
    HU_GAIN_L7DUI,               // ��7��
    HU_GAIN_PNPN,                // ������
    HU_GAIN_1CLR,                // ��һɫ
    HU_GAIN_19,                  // ���۾�
    HU_GAIN_258,                 // ����
    HU_GAIN_GEN,                 // ����
    HU_GAIN_GKAI,                // ���ϻ�
    HU_GAIN_GPAO,                // ����
    HU_GAIN_QGNG,                // ����
    HU_GAIN_TIAN,                // ���
    HU_GAIN_DI,                  // �غ�
    HU_GAIN_GANG,                // ��
    HU_GAIN_SOUBAYI,             // �ְ�һ
    HU_GAIN_SEABED,              // ��������
};

static int g_nHuGains[HU_MAX] =
{
    1, // С��         //0
    2, // 7��         //1
    4, // ��7��        //2
    1, // ������       //3
    2, // ��һɫ       //4
    2, // ���۾�       //5
    3, // ����         //6
    1, // ����         //7
    1, // ���ϻ�       //8
    1, // ������       //9
    1, // ����         //10
    5, // ���           //11
    5, // �غ�         //12
    1, // ��          //13
    1, // �ְ�һ       //14
    2, // ��������      15
};

static TCHAR g_aryGainText[HU_MAX][16] =
{
    _T("ƨ��"),       //0
    _T("�߶�"),       //1
    _T("���߶�"),     //2
    _T("������"),     //3
    _T("��һɫ"),     //4
    _T("���۾�"),     //5
    _T("����"),       //6
    _T("����"),       //7
    _T("���ϻ�"),     //8
    _T("������"),      //9
    _T("����"),       //10
    _T("���"),         //11
    _T("�غ�"),       //12
    _T("��"),         //13
    _T("�𹳵�"),     //14
    _T("δ����")      //15
};

#define TC_ASSERT_RETURN(DATA,RESULT)                   \
if (NULL == (DATA))                                     \
{                                                   \
    UwlLogFile("Data Is NULL, RESULT=%d, %s, %d", RESULT, __FILE__, __LINE__);  \
    return RESULT;                                  \
    }\

//for client

#define     GAME_SOCKET(nRoomID, nTableNO)              (-nRoomID)
#define     GAME_TOKEN(nRoomID, nTableNO)               (-nTableNO)
#define     GR_GAME_TIMER                               500000