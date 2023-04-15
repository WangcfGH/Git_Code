local function CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end 

local FileType = {
    "kPicture",
    "kVoice",
    "kFile",
    "kUnknown"
}
cc.exports.FileType = CreatEnumTable(FileType, 1)

local EnterGameType = {
    "kClassicGame",     --经典游戏
    "kOfflineGame",     --单机游戏
    "kYQWGame",         --一起玩游戏
    "kReplay",          --录像模式
    "kUnknown"
}
cc.exports.EnterGameType = CreatEnumTable(EnterGameType, 0)

local YQWShareType = {
    'YQWShareType_Play',
    'YQWShareType_Record',
    'YQWShareType_InviteGift',
}
cc.exports.YQWShareType = CreatEnumTable(YQWShareType, 1)

local YQWDXXWResultType = {
    'kNeedDxxw',
    'kNormal',
}
cc.exports.YQWDXXWResultType = CreatEnumTable(YQWDXXWResultType, 0)

local PortraitStatus = {
    "AUDITTING",
    "DENIED",
    "NORMAL",
} 
cc.exports.PortraitStatus = CreatEnumTable(PortraitStatus, 0)

local InGameParamsType = {
    "kTcyAppCreateRoom",
    "kInvitedToGame",
    "kInvitedToReplay",
}
cc.exports.InGameParamsType = CreatEnumTable(InGameParamsType, 0)

local PluginTrailOrder = {
    "kPlayStyleChoose",
    "kNovoiceGuide",
    "kCheckInDialog",
    "kWebBoardDialog",
    "kInviteGiftWeiXinBindDialog",
}
cc.exports.PluginTrailOrder = CreatEnumTable(PluginTrailOrder, 1)

local NR_TimeStampType = {
    "kSent",
    "kRecieved",
    "kDealed",
    "kEnded",
    "kError",
    "kAction"
}
cc.exports.NR_TimeStampType = CreatEnumTable(NR_TimeStampType, 1)

local NR_ProcessType = {
    "kOperate",
    "kLoginProcess",
    "kEnterRoom",
    "kReconnection",
}
cc.exports.NR_ProcessType = CreatEnumTable(NR_ProcessType, 1)

local NR_PortType = {
    "kClient",
    "kMpSvr",
    "kGameSvr",
    "kRoomSvr",
    "kHallSvr",
    "kTcySdk",
}
cc.exports.NR_PortType = CreatEnumTable(NR_PortType, 1)

cc.exports.NR_STATUS = {
    kSuccess            = 0,
    kNotRecieved        = 1,
    kNotDealed          = 2,
    kSendNotFound       = 4,
    kRecieveNotFound    = 8
}

cc.exports.RoomUnitType = {
    kBountRoom          = 0,
    kLapRoom            = 16,
}

cc.exports.ZORDER_ENUM = {
    kNormal     = 0,
    kTipString  = 1000,
    kWebView    = 1001,
}

--包括套接字连接和sdk调用没有通用的消息号，自定义一个
cc.exports.CUSTOM_REQUESTID = {
    SOCKET_HALL = 1000,
    SDK_LOGIN   = 1001,
    SOCKET_ROOM = 1002,
    SOCKET_GAME = 1003
}

local GAME_DOWNLOAD = {
    "GAME_CAN_START",               --不需要下载
    "USER_CANCEL_DOWNLOAD",         --不在wifi下，用户取消
    "GET_GAMEINFO_ERROR",           --获取更新信息失败
    "GAME_DOWNLOAD_START",          --开始下载
    "GAME_DOWNLOAD_PROGRESS",       --下载进度
    "GAME_DOWNLOAD_ERROR",          --下载失败
    "GAME_DOWNLOAD_SUCCESS",        --下载成功
    "GAME_DOWNLOAD_PAUSE",          --暂停下载某款游戏成功
    "IS_DOWNLOAD_CURRENT_NOT_WIFI", --当前非wifi是否继续下载
    "WIFI_CHANGE_4G",               --wifi切换到4G
}
cc.exports.GAME_DOWNLOAD = CreatEnumTable(GAME_DOWNLOAD, 1)