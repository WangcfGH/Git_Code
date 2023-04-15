#pragma once
// ԭ�����commonBase��ķ�����ʾ�߹���


struct PromptComponent
{
    int  m_nRoomPromptLine;      //������ʾ��  �����ҵ����Ӵ�����ʾ��  ��ʾ���ȥ��������
};

class PromptSystem
{
public:
    ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
    // args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
    ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnNewTable(CCommonBaseTable* table);

    virtual void    InitPromptLine(CCommonBaseTable* table);
    virtual void    ResetPromptLine(CCommonBaseTable* table);

    void OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CCommonBaseTable* pTable, CPlayer* pPlayer);
};