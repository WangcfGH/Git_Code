local AnchorTableDef = 
{
    ANCHOR_TABLE_RESUME_TABLE_CTRL              = 'ANCHOR_TABLE_RESUME_TABLE_CTRL',             --唤醒
    ANCHOR_TABLE_ENTER_ROOM_SET_DATA            = 'ANCHOR_TABLE_ENTER_ROOM_SET_DATA',           --进房设置信息

    BOUT_TYPE_ONE_BOUT                          = 1,                                            -- 局数规则：单局
    BOUT_TYPE_PASS_EIGHT                        = 2,                                            -- 局数规则：过八
    BOUT_TYPE_PASS_A                            = 3,                                            -- 局数规则：过A
    PLAY_TYPE_NO_SHUFFLE                        = 1,                                            -- 玩法规则：不洗牌
    PLAY_TYPE_NORMAL                            = 2,                                            -- 玩法规则：经典
    ENCRYPTION_TYPE_NO                          = 0,                                            -- 秘钥规则：不加密
    ENCRYPTION_TYPE_IS                          = 1,                                            -- 秘钥规则：加密

    PASSWORD_LENGTH                             = 4,                                            -- 秘钥长度
}

return AnchorTableDef