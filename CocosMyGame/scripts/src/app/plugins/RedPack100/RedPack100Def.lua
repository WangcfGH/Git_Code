local RedPack100Def = 
{
    REDPACK_REWARD_NUM                  =       10000,     -- 100元 = 奖励兑换券数量

    GR_REDPACK100_QUERY_REQ				=		410330,    -- 百元红包第一层数据请求 （登陆查询会下发）
    GR_REDPACK100_QUERY_RESP			=		410331,    -- 回包
    GR_REDPACK100_BREAK_REQ			    =		410332,    -- 百元红包第二层数据请求 （拆红包时候下发）
    GR_REDPACK100_BREAK_RESP			=		410333,    -- 百元红包第二层数据请求响应
    GR_REDPACK100_REWARD_REQ			=		410334,    -- 百元红包领奖请求
    GR_REDPACK100_REWARD_RESP			=		410335,    -- 百元红包领奖回包
    GR_REDPACK100_ACTIVITY_UPDATE_REQ	    =		410336,    -- 百元红包活动界面数据更新
    GR_REDPACK100_ACTIVITY_UPDATE_RESP	    =		410337,    -- 百元红包活动界面数据更新回报
    GR_REDPACK100_BOUT_UPDATE            =       410338,     -- 通知刷新局数的回报

    REDPACK_SHOW_CASH_MODE = 0,		-- 现金模式
    REDPACK_SHOW_VOCHER_MODE = 1,	-- 现兑换券模式

    ID_IN_ACTIVITY_CENTER               = 104,
    BREAK_COND_EVERYDAY_LOGIN		=       1,
    BREAK_COND_BOUT_REACHED			=       2,
    BREAK_COND_DAY_TASK			    =       3,

    QUERY_SUCCESS           = 0,      -- 查询结果成功，显示红包
    QUERY_DEVICE_LIMIT      = -1,     -- 查询结果设备限制，不显示红包   
    QUERY_ACTIVITY_END = -2,            -- 查询活动已结束
    QUERY_DB_ERROR = -3,                -- 查询结果数据库错误，不显示
    QUERY_CHANNEL_CLOSED = -4,          -- 查询结果渠道关闭

    BREAK_DB_SET_DATA_SUCCESS = 0,  -- 拆红包成功
    BREAK_DB_DATA_NOT_FOUND  = -1,  -- 拆红包数据没查到，非法
    BREAK_DB_SET_DATA_ERROR = -2,   -- 拆红包数据库写入错误
    BREAK_ALEADY_TODAY = -3,        -- 今日已经拆过
    BREAK_OUT_OF_DATE = -4,        -- 缓存校验过期了

    REWARD_CHECK_SUCCESS = 0,       -- 领奖校验成功
	REWARD_EXCEED=1,			    -- 领奖过期
	REWARD_ALEADY=2,			    -- 领奖重复领取
	REWARD_SOAP_FAILED=3,	        -- 领奖soap调用失败
    REWARD_MONEY_CHECK=4,           -- 领奖金额校验失败
	REWARD_ERROR = 5,			    -- 领奖非法


    MSG_REDPACK_REWARD_SUCCESS       = "RedPack100RewardSuccess",
    MSG_REDPACK_REWARD_FAILED       = "RedPack100RewardFailed",
    MSG_REDPACK_DATA_UPDATE         = "RedPack100DataUpdate",
    MSG_REDPACK_BREAK_RESP          = "RedPack100BreakResp",       -- 通知拆红包
    MSG_REDPACK_BREAK_FAILED        = "RedPack100BreakFailed",       -- 通知拆红包

    MSG_REDPACK_SIMPLE_TIXIAN       = "RedPack100SimpleTixian",    -- 活动界面拆红包弹出窗口，点击提现发的消息
    MSG_REDPACK_CLOCK_ZERO          = "RedPack100ClockZero",
    MSG_REDPACK_UPDATE_REDDOT       = "RedPack100UpdateRedDot",
    MSG_REDPACK_NOTIFY_SWITCH_TAB          = "RedPack100NotifySwitch",      -- 活动界面已经打开的情况，通知它切换到红包界面
    MSG_REDPACK_NOTIFY_SWITCH_EXCHANGELOTTERY_TAB          = "RedPack100NotifySwitchExchangeLottery",      -- 活动界面已经打开的情况，通知它切换到惊喜夺宝
}

return RedPack100Def