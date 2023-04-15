local MonthCardDef = 
{
    --月卡相关
    GR_STORE_MCARD_DEVID_REQ    = 404200, -- 够买月卡前，先发送设备ID给chunksvr
    GR_BUY_MCARD_REQ            = 404201, -- 购买月卡消息请求  （待定是否要使用）
    GR_BUY_MCARD_RSP            = 404202, -- 购买月卡消息反馈  trunksvr --》assistsvr --》 game(Client)
    GR_GET_MCARD_INFO_REQ       = 404203, -- 查询月卡信息请求  client --》 assistsvr --》chunksvr
    GR_GET_MCARD_INFO_RSP       = 404204, -- 查询月卡信息响应  trunksvr --》assistsvr --》 game(Client)
    GR_GET_GAINGIFT_REQ         = 404205, -- 领取月卡赠送 请求
    GR_GET_GAINGIFT_RSP         = 404206,  -- 领取月卡赠送 响应

    GR_RECHARGE_LOG_REQ          = 407001,

    -- EVENT_RECHARGE_INFO_UPDATE = "EVENT_RECHARGE_INFO_UPDATE",
    -- EVENT_GET_LOTTERY_RESULT = "EVENT_GET_LOTTERY_RESULT",
    -- EVENT_GET_LOTTERY_FAILED = "EVENT_GET_LOTTERY_FAILED",

    -- TYPE_SILVER = 0,
    -- TYPE_TICKET = 1,       --礼券
    -- COLOR_PURPLE = 0,      --紫色
    -- COLOR_RED = 1,         --红色
}

return MonthCardDef