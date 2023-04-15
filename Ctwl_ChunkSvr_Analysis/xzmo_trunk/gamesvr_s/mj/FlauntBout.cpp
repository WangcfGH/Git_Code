#include "StdAfx.h"
#include "FlauntBout.h"

void FlauntBoutModule::OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }
    GAME_WIN_MJ* pGameWin = (GAME_WIN_MJ*)pData;

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            game::UpdateFlauntBout updateFlaunt;
            updateFlaunt.set_nuserid(pPlayer->m_nUserID);

            BOOL bWin = FALSE;
            if (pGameWin->nHuChairs[i] > 0)
            {
                bWin = TRUE;
            }
            updateFlaunt.set_bwin(bWin);
            int datalen = updateFlaunt.ByteSize();
            LPVOID pData = new_byte_array(datalen);
            if (!updateFlaunt.SerializeToArray(pData, datalen))
            {
                SAFE_DELETE_ARRAY(pData);
            }

            REQUEST Request;
            memset(&Request, 0, sizeof(Request));
            Request.head.nRequest = GR_UPDATE_FLAUNT_INFO;
            Request.pDataPtr = pData;
            Request.nDataLen = datalen;
            Request.head.nRepeated = 0;
            imMsg2Chunk.notify(lpContext, &Request);
        }
    }
}
