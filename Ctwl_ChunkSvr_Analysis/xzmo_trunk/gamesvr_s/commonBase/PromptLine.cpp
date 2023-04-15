#include "StdAfx.h"
#include "PromptLine.h"

using namespace plana::events;

void PromptSystem::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{

}

void PromptSystem::OnNewTable(CCommonBaseTable* table)
{
    table->m_entity.assign<PromptComponent>();
    table->evResetRound += delegate(this, &PromptSystem::ResetPromptLine);
    table->evStartDoing += delegate(this, &PromptSystem::InitPromptLine);
}

void PromptSystem::InitPromptLine(CCommonBaseTable* table)
{
    auto* com = table->m_entity.component<PromptComponent>();
    com->m_nRoomPromptLine = DEFAULT_PROMPT_LIME;

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), table->m_nRoomID);
    imGetIniInt("promptline", szRoomID, com->m_nRoomPromptLine);
}

void PromptSystem::ResetPromptLine(CCommonBaseTable* table)
{
    auto* com = table->m_entity.component<PromptComponent>();
    com->m_nRoomPromptLine = DEFAULT_PROMPT_LIME;
}

void PromptSystem::OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CCommonBaseTable* pTable, CPlayer* pPlayer)
{
    auto* com = pTable->m_entity.component<PromptComponent>();
    if (com->m_nRoomPromptLine == DEFAULT_PROMPT_LIME)
    {
        return;
    }

    ROOM_PROMPT_LINE promptLine;
    memset(&promptLine, 0, sizeof(promptLine));
    promptLine.nRoomID = pTable->m_nRoomID;
    promptLine.nTableNO = pTable->m_nTableNO;
    promptLine.nChairNO = pPlayer->m_nChairNO;
    promptLine.nUserID = pPlayer->m_nUserID;
    promptLine.nRoomPromptLine = com->m_nRoomPromptLine;
    imNotifyOneUser.notify(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ROOM_PROMPT_LINE, &promptLine, sizeof(promptLine), FALSE);
}
