local function CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end 

local CheckReturn = {
    'SAME',
    'MAJOR_DISUSE',
    'MINOR_DISUSE',
    'MINOR_EXCEED',
    'MONOR_EXCEED',
    'BUILDNO_DISUSE',
}

cc.exports.CheckReturn = CreatEnumTable(CheckReturn, 0)

local ServerType = {
    'SERVER_TYPE_HALL',
    'SERVER_TYPE_CHECK',
    'SERVER_TYPE_DOWN',
}

cc.exports.ServerType = CreatEnumTable(ServerType, 1)

local YQWIdentityType = {
    "EYIT_WECHAT",    -- 微信
    "EYIT_QQ",        -- QQ
    "EYIT_TCY",       -- 同城游
    "EYIT_MAX"
}

cc.exports.YQWIdentityType = CreatEnumTable(YQWIdentityType, 0)

local YQWRoomType = {
    "WECHAT",    -- 微信
    "QQ",        -- QQ
    "TCY",       -- 同城游
}

cc.exports.YQWRoomType = CreatEnumTable(YQWRoomType, 0)

local YWQRoomStatus = {
    "WAITING",
    "PLAYING",
}

cc.exports.YWQRoomStatus = CreatEnumTable(YWQRoomStatus, 0)

cc.exports.YQWJoinFlag = {
    YQW_JOIN_FLAG_OWNER = 0x00000001
}

local YQWGetBillResult = {
    'YQWGetBillResult_OK'
}
cc.exports.YQWGetBillResult = CreatEnumTable(YQWGetBillResult, 0)

cc.exports.YQW_DONATE_CODE = {
    YDC_SYSTEM_ERROR            = -1      ,-- 系统异常
    YDC_SUCCESS                 = 0       ,--成功
    YDC_SERVER_ERROR            = 10100   ,--服务异常
    YDC_DATA_ILLEGAL            = 10004   ,--请求数据不合法
    YDC_AUTH_FAILED             = 10101   ,--签名认证失败
    YDC_FREQUENT_OPERATION      = 10102   ,--操作过于频繁
    YDC_INVALID_PARAMS          = 20101   ,--参数错误
    YDC_ORDER_CLOSED            = 20102   ,--返还订单已关闭
    YDC_COIN_NOTENOUGH          = 20103   ,--***数量不足
    YDC_ADD_FAILED              = 20104   ,--***增加失败
    YDC_COIN_DEDUCTION_FAILED   = 20105   ,--***扣除失败
    YDC_REFUND_FAILED           = 20106   ,--***返还失败
    YDC_DONATE_FAILED           = 20107   ,--***转赠失败
    YDC_OPERATECODE_ERROR       = 20108   ,--操作码错误
    YDC_ACCOUNT_NOTEXIST        = 20109   ,--***账户不存在
    YDC_FORMAT_ERROR            = 20110   ,--业务订单号格式错误
    YDC_TB_DEDUCTION_FAILED     = 20111   ,--通宝扣除失败
    YDC_CONSUME_ORDER_NOEXIST   = 20112   ,--消耗订单不存在
    YDC_APP_VISIT_FORBIDDEN     = 20114   ,--应用不允许访问
}

cc.exports.YQW_DONATE_CHECK_CODE = {
    YDCC_SYSTEM_ERROR           = -1      ,-- 失败
    YDCC_SUCCESS                = 0       ,--成功
    YDCC_NOT_BINDING            = 32501   ,--该受赠人序号未绑定微信
    YDCC_FREQUENT_OPERATION     = 32503   ,--操作过于频繁
    YDCC_ACCOUNT_NOTEXIST       = 32507   ,--该受赠人序号不存在
}

cc.exports.YQW_REQ_FROMTYPE = {
    kWebPage    = 100,
    kTcyApp     = 200,
    kPcHall     = 300,
    kGame       = 400,
    kOther      = 999,
}

local Email_SourceId = {
    "PCGAME",                  --PC游戏
    "MOBILEGAME",             --移动游戏
    "PCPLATFORM",             --PC平台
}
cc.exports.Email_SourceId = CreatEnumTable(Email_SourceId, 1)

local Email_SourceType = {
    "PCSERVER",               --PC服务
    "MOBILEGAME",             --移动游戏
    "MOBILEGAME_EX",          --移动游戏(配合userplugin:getAuthInfo())
}
cc.exports.Email_SourceType = CreatEnumTable(Email_SourceType, 1)

--物品系统中物品类型枚举
cc.exports.ItemType = {
    USERITEM = {
        100000000,
        200000000,
        100007000,
        100008000,
        100010000,
        100006001,
        100006002,
        100006003,
        100006004,
        100006005
    },                              --用户物品（道具）
    JF              = 100006000,    --积分
    MATCHTICKETS    = 100011000,    --比赛券
    VIRTUALITEM     = 100012000,    --用户虚拟物品
    SILVER          = 300001000,    --银子
    EXCHANGETICKETS = 300002000,    --礼券
    HAPPYCOIN       = 300003000,    --***
    REALITEM        = 400000000,    --实物
    MOBILEBILL      = 500000000,    --话费
    HAPPYCOINTIKET  = 300004002,    --***券
}

cc.exports.Email_StatusCode = {
    RECEIVED_AWARD      = -3000001,
    FREQUENTLY_REQUEST  = -3000002,
}

--付费模式
cc.exports.YQW_ROOM_PAYMODE  = {
    ROOM_PAYMODE_HOST       = 0x00000000,   --房主付费
    ROOM_PAYMODE_AA         = 0x00000001,   --AA 
    ROOM_PAYMODE_COUPON     = 0x00000002,   --***券
    ROOM_PAYMODE_WIN        = 0x00000004,   --大赢家
}
--cc.exports.YQW_ROOM_PAYMODE = CreatEnumTable(YQW_ROOM_PAYMODE, 0)

cc.exports.PlatformType = {
    TCY_TRANSPORT       = 116,      --同城游APP联运
    TRADING_CENTER      = 151,      --交易中心
    MOBILE_GAME         = 188,      --移动游戏平台
    TCY_SELF_SUPPORT    = 3001,     --同城游APP自营
}

local  TCY_CURRENCY = 
{
	"TCY_CURRENCY_DEPOSIT",			        --银子
	"TCY_CURRENCY_SCORE",					--积分
	"TCY_CURRENCY_TONGBAO",				    --通宝
	"TCY_CURRENCY_GAMECOIN",				--游戏自定义货币
	"TCY_CURRENCY_HAPPYCOIN",				--***
    "TCY_CURRENCY_MAX",
}
cc.exports.TCY_CURRENCY = CreatEnumTable(TCY_CURRENCY, 0)

local  CLUB_PLAYERMSG_TYPE = 
{
	"APPLYJOIN",			        --申请加入亲友圈
	"APPLYREFUSED",					--申请被拒绝
	"JOINED",				        --玩家加入亲友圈
	"EXITED",				        --玩家退出亲友圈
}
cc.exports.CLUB_PLAYERMSG_TYPE = CreatEnumTable(CLUB_PLAYERMSG_TYPE, 1)

local  CLUB_PLAYER_ONLINE = 
{
	"OFFLINE",			        --离线
	"ONLINE",					--在线	
}
cc.exports.CLUB_PLAYER_ONLINE = CreatEnumTable(CLUB_PLAYER_ONLINE, 0)

local  CLUB_PLAYER_STATUS = 
{
	"JOINED",			        --加入亲友圈
	"EXITED",					--退出亲友圈	
}
cc.exports.CLUB_PLAYER_STATUS = CreatEnumTable(CLUB_PLAYER_STATUS, 0)

local  CLUB_PAYTYPE = 
{
    "ALL",			--全部
    "WINNER",			--大赢家
    "AVG",			--平摊
    "PLAYER",                   --房主
}
cc.exports.CLUB_PAYTYPE = CreatEnumTable(CLUB_PAYTYPE, 0)

local CLUB_YQWROOM_STATUS = {
    "ALL",                      --全部
    "CREATE",                   --建房(等待中)
    "START",                    --开局
    "CLOSE"                     --散桌
}
cc.exports.CLUB_YQWROOM_STATUS = CreatEnumTable(CLUB_YQWROOM_STATUS, -1)

local CLUB_ERROR_E  = {
	"CLUB_ERROR_NO_ERROR",			        --没有错误
	"CLUB_ERROR_UNKNOW_ERROR",		        --错误没有详细的描述
	"CLUB_ERROR_CLUBNO_NOT_EXIST",	        --亲友圈号不存在
	"CLUB_ERROR_CLUBGAME_NOT_EXIST",	    --亲友圈游戏不存在
	"CLUB_ERROR_REACH_MAXPLAYERCOUNT",      --亲友圈人数到达上限
	"CLUB_ERROR_ALREADY_MEMBER",		    --已经是亲友圈成员
	"CLUB_ERROR_DB_ERROR",			        --数据库操作出错
	"CLUB_ERROR_INVALID_DATA",		        --无效数据
	"CLUB_ERROR_INVALID_PARAM",		        --无效参数
	"CLUB_ERROR_SYSTEM_ERROR",		        --系统错误
	"CLUB_ERROR_MQ_ERROR",			        --MQ操作出错    
}
cc.exports.CLUB_ERROR_E = CreatEnumTable(CLUB_ERROR_E, 0)

local CHAIR_FLAG = {
    "NORMAL",                       --普通入座
    "APPOINT",                      --指定入座
}
cc.exports.CHAIR_FLAG = CreatEnumTable(CHAIR_FLAG, 0)

local CLUB_ALLOW_CREATEROOM = {
    "ABLE_DEFAULT",                 --默认可用
    "ABLE_APPOIINT",                --指定可用
    "DISABLE"                       --禁用
}
cc.exports.CLUB_ALLOW_CREATEROOM = CreatEnumTable(CLUB_ALLOW_CREATEROOM, 0)

--扣玩家币start--
--亲友圈的一些配置
cc.exports.CLUB_CONFIG = {
    --NOT_ALLOWPLAYERCREATEROOM   = 0x00000001,   --不允许玩家创建房间 在用 CLUB_ALLOW_CREATEROOM
    DEDUCTUSERCOINSTATUS        = 0x00000002,   --玩家付费 
    NOT_ALLOWFREECREATE         = 0x00000004,   --不允许玩家自选规则创房
}

cc.exports.CLUB_RULEDIF_NTF_CONFIG = {
	CLUB_RULE_STATUS_NORMAL = 0,	--正常
	CLUB_RULE_STATUS_DELETE = 1,	--删除   
}

--alloc 的标记 比较时注意用等于号
cc.exports.ALLOC_FLAG = {
    NORMAL_ROOM         = 0x00000000,  --普通开房
    ASSIST_AGENT        = 0x00000001,  --助手代开房
    CLIENT_AGENT        = 0x00000002,  --游戏客户端代开房
    CLUB_SYSTEM         = 0x00000004,  --俱乐部代理系统代开房
    CLUB_PLAYER         = 0x00000008,  --俱乐部用户代开房（扣推广员币）
    CLUB_PLAYER_EX      = 0x00000009,  --俱乐部用户代开房（扣玩家币）
}
--扣玩家币end--
