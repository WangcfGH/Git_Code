#include "stdafx.h"
#include "UserRecordData.h"
#include "UserRecordDataReq.h"
#include "tcycomponents/TcyMsgCenter.h"

UserRecordData::UserRecordData()
{
}


UserRecordData::~UserRecordData()
{
}

void UserRecordData::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_LOG_USERBEHAVIOR, imToChunkLog);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_APP_UPLOAD, imToChunkLog);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_NEW_APP_UPLOAD, imToChunkLog);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_LOG_FUNC_USED, imToChunkLog);
    }
}
