local BankruptcyDef = 
{
	GR_BANKRUPTCY_REQ_STATUS = (400000 + 3501),
    GR_BANKRUPTCY_REQ_APPLY_BAG = (400000 + 3502),
	GR_BANKRUPTCY_PAY_SUCCEED = (400000 + 3503),
	GR_BANKRUPTCY_TRIGGER_EVT = (400000 + 3504),
    GR_BANKRUPTCY_BUY_EVT = (400000 + 3505),

    BANKRUPTCY_APPTYPE_AN_TCY = 1,
	BANKRUPTCY_APPTYPE_AN_SINGLE = 2,
	BANKRUPTCY_APPTYPE_AN_SET = 3,
	BANKRUPTCY_APPTYPE_IOS_TCY = 4,
    BANKRUPTCY_APPTYPE_IOS_SINGLE = 5,

	ServiceClose = 'ServiceClose',          -- 服务端enbale为0,所有接口关闭
    ServiceNotShow = 'ServiceNotShow',      -- 服务端开启，但是没有破产礼包
    ServiceOK = 'ServiceOK',      
    BANKRUPTCY_STATUS_RSP = 'BANKRUPTCY_STATUS_RSP',
    BANKRUPTCY_APPLY_BAG_RSP = 'BANKRUPTCY_APPLY_BAG_RSP',
    BANKRUPTCY_TIME_UPDATE = 'BANKRUPTCY_TIME_UPDATE',
}

return BankruptcyDef