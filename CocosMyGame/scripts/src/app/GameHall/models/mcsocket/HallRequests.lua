local HallRequests = class('HallRequests')
--KPI start
protobuf.register_file('src/app/GameHall/models/mcsocket/halllogon.pb')
--KPI end

HallRequests.ServerType = {
    ['SERVER_TYPE_HALL']    = 1,
    ['SERVER_TYPE_CHECK']   = 2,
    ['SERVER_TYPE_DOWN']    = 3,
}

function HallRequests:ctor()
    self._userModel     = mymodel('UserModel'):getInstance()
    self._gameModel     = mymodel('GameModel'):getInstance()
    self._deviceModel   = mymodel('DeviceModel'):getInstance()

    self._notifyCallback = {}
    self:_registNotifyHandler()
end

function HallRequests:getInstance()
    HallRequests._instance = HallRequests._instance or HallRequests:create()
    return HallRequests._instance
end

function HallRequests:GET_SERVERS(serverType, callback, isRepsonse)
    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nGameID       = self._gameModel.nGameID,
        nServerType   = serverType,
        nSubType      = 0,
        nAgentGroupID = self._gameModel.nAgentGroupID,
        dwGetFlags    = isRepsonse and 0x00000800 or 0x00000801
    }

    if type(callback) == 'function' and not isRepsonse then
        self._notifyCallback[mc.GET_SERVERS] = self._notifyCallback[mc.GET_SERVERS] or {}
        table.insert(self._notifyCallback[mc.GET_SERVERS], callback)
    end
    client:sendRequest(mc.GET_SERVERS, params, nil, isRepsonse)
end

function HallRequests:CHECK_VERSION(callback)
    assert(type(callback) == 'function', 'HallRequests:CHECK_VERSION(callback), incalid callback type:%s', type(callback))

    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nMajorVer    = self._gameModel.nMajorVer,
        nMinorVer    = self._gameModel.nMinorVer,
        nBuildNO     = self._gameModel.nBuildNO,
        nGameID      = self._gameModel.nGameID,
        szExeName    = self._deviceModel.szExeName
    }
    client:sendRequest(mc.CHECK_VERSION, params, nil, true)
end

function HallRequests:LOGON_USER(callback)
    assert(type(callback) == 'function', 'HallRequests:LOGON_USER(callback), invalid callback type:%s', type(callback))

    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nBlockSvrID     = 0,
        nUserID         = self._userModel.nUserID,
        nHallSvrID      = 0,
        nAgentGroupID   = self._gameModel.nAgentGroupID,
        nGroupType      = self._gameModel.nGroupType,
        dwIPAddr        = 0,
        dwSoapFlags     = 0,
        dwLogonFlags    = self._userModel.dwLogonFlags,
        lTokenID        = 0,
        nResponse       = 0,
        szUsername      = self._userModel.szUsername,
        szPassword      = self._userModel.szPassword,
        szHardID        = self._deviceModel.szHardID,
        szVolumeID      = self._deviceModel.szVolumeID,
        szMachineID     = self._deviceModel.szMachineID,
        szHashPwd       = self._deviceModel.szHashPwd,
        szRndKey        = 0,
        unused          = '',
        dwSysVer        = self._gameModel.dwSysVer,
        nLogonSvrID     = 0,
        nHallBuildNO    = self._gameModel.nHallBuildNO,
        nHallNetDelay   = self._gameModel.nHallNetDelay,
        nHallRunCount   = self._gameModel.nHallRunCount,
        nGameID         = self._gameModel.nGameID,
        dwGameVer       = self._gameModel.dwGameVer,
        nRecommenderID  = self._gameModel.nRecommenderID
    }
    client:sendRequest(mc.LOGON_USER, params, nil, true)
end

function HallRequests:LOGON_USER_V2(callback)
    assert(type(callback) == 'function', 'HallRequests:LOGON_USER_V2(callback), invalid callback type:%s', type(callback))

    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nUserID         = self._userModel.nUserID or 0,
        nHallSvrID      = 0,
        nAgentGroupID   = self._gameModel.nAgentGroupID,
        dwIPAddr        = 0,
        dwLogonFlags    = self._userModel.dwLogonFlags,
        lTokenID        = 0,
        szUsername      = self._userModel.szUsername,
        szPassword      = self._userModel.szPassword,
        szHardID        = self._deviceModel.szHardID,
        szVolumeID      = self._deviceModel.szVolumeID,
        szMachineID     = self._deviceModel.szMachineID,
        szHashPwd       = self._deviceModel.szHashPwd,
        szRndKey        = "",
        dwSysVer        = self._gameModel.dwSysVer,
        nLogonSvrID     = 0,
        nHallBuildNO    = self._gameModel.nHallBuildNO,
        nHallNetDelay   = self._gameModel.nHallNetDelay,
        nHallRunCount   = self._gameModel.nHallRunCount,
        nGameID         = self._gameModel.nGameID,
        dwGameVer       = self._gameModel.dwGameVer,
        nRecommenderID  = self._gameModel.nRecommenderID,
        nChannelID      = tonumber(BusinessUtils:getInstance():getTcyChannel()),
        szGameCode      = my.getAbbrName()
    }
    client:sendRequest(mc.MR_LOGON_USER_V2, params, nil, true)
end

--KPI start
function HallRequests:LOGON_USER_PB(callback)
    assert(type(callback) == 'function', 'HallRequests:LOGON_USER_PB(callback), invalid callback type:%s', type(callback))

    -- 登录来源参数，用于统计
    local recommGameID = 0
    local recommGameCode = ''
    local recommGameVer = ''
    local content = launchParamsManager:getContent()
    if content and content.sourcecode and content.sourceid then
        local id = tonumber(content.sourceid)
        if id then
            recommGameID   = id
        end
        recommGameCode = content.sourcecode
    end
    if content and content.sourcever then
        recommGameVer = content.sourcever
    end

    local packageType = -1
    local model = MCAgent:getInstance():getLaunchMode()
    if model then
        if model == 1 then
            packageType = 100
        elseif model == 2 then
            packageType = 110
        end
    end

    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        packageType = 1000
    end

    local client = mc.createClient()
    local function onReqCallback(respondType, data, msgType)
        local dataMap = {}
        if respondType == mc.PB_LOGON_SUCCEEDED then
            local pbData = protobuf.decode('halllogon.LogOnSucceed', data)
            protobuf.extract(pbData)
            dataMap.nUserID = pbData.userid
            dataMap.nNickSex = pbData.nicksex
            dataMap.nPortrait = pbData.portrait
            dataMap.nUserType = pbData.usertype
            dataMap.nClothingID = pbData.clothingid
            dataMap.nRegisterGroup = pbData.registergroup
            dataMap.nDownloadGroup = pbData.downloadgroup
            dataMap.nAgentGroupID = pbData.agentgroupid
            dataMap.nExpiration = pbData.expiration
            dataMap.nMemberLevel = pbData.memberlevel
            dataMap.nHallID = pbData.hallid
            dataMap.szUserName = MCCharset:getInstance():utf82GbString(pbData.username, string.len(pbData.username))
            dataMap.szNickName = MCCharset:getInstance():utf82GbString(pbData.nickname, string.len(pbData.nickname))
            dataMap.szUniqueID = pbData.uniqueid
            dataMap.szIMToken = pbData.imtoken
            dataMap.szIDCard = pbData.idcard
            dataMap.nCreateDay = pbData.createday
            dataMap.nCreateHour = pbData.createhour

            dataMap.usergameinfo = pbData.usergameinfo

            dataMap.nGameID = pbData.usergameinfo.gameid
            dataMap.nDeposit = pbData.usergameinfo.deposit
            dataMap.nPlayerLevel = pbData.usergameinfo.playerlevel
            dataMap.nScore = pbData.usergameinfo.score
            dataMap.nExperience = pbData.usergameinfo.experience
            dataMap.nBreakOff = pbData.usergameinfo.breakoff
            dataMap.nWin = pbData.usergameinfo.win
            dataMap.nLoss = pbData.usergameinfo.loss
            dataMap.nStandOff = pbData.usergameinfo.standoff
            dataMap.nBout = pbData.usergameinfo.bout
            dataMap.nTimeCost = pbData.usergameinfo.timecost
            dataMap.nSalaryTime = pbData.usergameinfo.salarytime
            dataMap.nSalaryDeposit = pbData.usergameinfo.salarydeposit
            dataMap.nTotalSalary = pbData.usergameinfo.totalsalary

            -- common proxy begin
            if cc.exports.isCommonMpSvrSupported() then
                if pbData.svrs and pbData.svrs[1] then
                    -- 默认取第一个
                    local svr = pbData.svrs[1]
                    local ServerConfig = require('src.app.HallConfig.ServerConfig')
                    if my.judgeIPString(svr.ip) then
                        ServerConfig.commonmp[1] = svr.ip       -- 真实IP  优先使用真实的IP
                        ServerConfig.commonmp[2] = svr.port
                        print("Get CommonMP ", ServerConfig.commonmp[1], ServerConfig.commonmp[2])
                    elseif string.len( svr.www ) ~= 0 then
                        ServerConfig.commonmp[1] = svr.www      -- 域名
                        ServerConfig.commonmp[2] = svr.port
                        print("Get CommonMP ", ServerConfig.commonmp[1], ServerConfig.commonmp[2])
                    else
                        print("Get CommonMP IP or WWW Error")
                    end
                else
                    print("No CommonProxy Svrs")
                end
            end
            -- common proxy end

        end
        callback(respondType, data, msgType, dataMap)
    end
    client:setCallback(onReqCallback)
    local params = {
        userid         = self._userModel.nUserID or 0,
        hallsvrid      = 0,
        agentgroupid   = self._gameModel.nAgentGroupID,
        ipaddr        = 0,
        logonflags    = self._userModel.dwLogonFlags,
        tokenid        = 0,
        username      = self._userModel.szUtf8Username,
        password      = self._userModel.szPassword,
        hardid        = self._deviceModel.szHardID,
        volumeid      = self._deviceModel.szVolumeID,
        machineid     = self._deviceModel.szMachineID,
        hashpwd       = self._deviceModel.szHashPwd,
        rndkey        = "",
        sysver        = self._gameModel.dwSysVer,
        logonsvrid     = 0,
        hallbuildno    = self._gameModel.nHallBuildNO,
        hallnetdelay   = self._gameModel.nHallNetDelay,
        hallruncount   = self._gameModel.nHallRunCount,
        gameid         = self._gameModel.nGameID,
        gamever        = my.getGameVersion(),
        recommenderid  = self._gameModel.nRecommenderID,
        channelid      = tonumber(BusinessUtils:getInstance():getTcyChannel()),
        gamecode      = my.getAbbrName(),

        recommgameid = recommGameID,
        recommgamecode = recommGameCode,
        accesstoken = "",
        justforverify = 0,
        recommgamever = recommGameVer,
        pkgtype = packageType,
        cuid = BusinessUtils:getInstance().getTcyCUID and BusinessUtils:getInstance():getTcyCUID() or '',
        imsiid = DeviceUtils:getInstance():getIMSI(),
        simserialno = DeviceUtils:getInstance():getSimSerialNumber(),
    }
    --- 额外添加gsclientdata信息 :: begin
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin then
        if analyticsPlugin.setCommonInfoMap then
            local params =
            {
                gameId    = tostring(my.getGameID()),   --客户端游戏id
                gameCode  = my.getGameShortName(),      --客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
                gameVers  = my.getGameVersion(),        --客户端游戏版本
                roomNo    = "0",
            }
            analyticsPlugin:setCommonInfoMap(params)

            local deviceInfo = analyticsPlugin:getDisdkDeviceInfo()
            print("new kpi--- deviceInfo")
            dump(deviceInfo)
        end
        if analyticsPlugin.getDisdkExtendedJsonInfo then
            local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
            params['gsclientdata'] = gsClient
        end
    end
    local pdata = protobuf.encode('halllogon.LogOnUser', params)
    --- 额外添加gsclientdata信息 :: end
    client:sendData(mc.PB_LOGON_USER, pdata, nil, true)
end
--KPI end

function HallRequests:_registNotifyHandler()
    local mclient=mc.createClient()
    mclient:registHandler(mc.GET_SERVERS_OK, handler(self, self._onGetServerOK), 'hall')
end

function HallRequests:_onGetServerOK(respondType, data, msgType, dataMap)
    for _, handler in pairs(self._notifyCallback[mc.GET_SERVERS]) do 
        handler(respondType, data, msgType, dataMap)
    end
end

function HallRequests:MR_GET_ASSISTSVR(callback)
--    local FLAG_GETASSITSVR_INGORE_TYPE = 0x00000002

    local client = mc.createClient()
    client:setCallback(callback)
    --[[
    local  = {
        nGameID         = self._gameModel.nGameID,
        nType           = require('src.app.HallConfig.AssistModelConfig').ASSISTSERVER_TYPE,
        nSubType        = 0,
        nAgentGroupID   = self._gameModel.nAgentGroupID,
        dwGetFlags      = 0,
--        dwGetFlags      = FLAG_GETASSITSVR_INGORE_TYPE,
    }
    --]]
    local params = {}
    if BusinessUtils:getInstance():isGameDebugMode() then
        params = {
            nGameID         = self._gameModel.nGameID,
            nAgentGroupID   = self._gameModel.nAgentGroupID,
            nType           = require('src.app.HallConfig.AssistModelConfig').ASSISTSERVER_TYPE,
	    }
    else
        params ={
            nGameID         = self._gameModel.nGameID,
            nAgentGroupID   = self._gameModel.nAgentGroupID,
	    }
    end
    client:sendRequest(mc.MR_GET_ASSISTSVR, params, nil, true)
end

function HallRequests:MR_GET_ROOM(nRoomID, callback)
    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nAgentGroupID = self._gameModel.nAgentGroupID,
        nGameID       = self._gameModel.nGameID,
        nRoomID       = nRoomID, 
        dwFlags       = 0,
    }
    client:sendRequest(mc.MR_GET_ROOM, params, nil, true)
end

function HallRequests:MR_GET_YQWROOMINFO( nYQWRoomNo, callback, nClubNO )
    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nYQWRoomNo  = nYQWRoomNo,
        nUserID     = self._userModel.nUserID,
        nClubNo     = nClubNO or 0 --带有亲友圈号的请求才可以查询到亲友圈的房间数据
    }
    client:sendRequest(mc.MR_GET_YQWROOMINFO, params, nil, true)
end

function HallRequests:MR_GET_YQWPLAYERINFO( callback )
    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nUserID = self._userModel.nUserID,
    }
    client:sendRequest(mc.MR_GET_YQWPLAYERINFO, params, nil, true)
end

function HallRequests:MR_YQW_DON_HAPPY_COIN(nReceiveUserID, nAmount, callback )
    local client = mc.createClient()
    client:setCallback(callback)
    local params = {
        nUesrID          = self._userModel.nUserID,
        nGameID         = self._gameModel.nGameID,
        szHardID        = self._deviceModel.szHardID,
        nReceiveUserID  = nReceiveUserID,
        nAmount         = nAmount,
        nChannelID      = tonumber(BusinessUtils:getInstance():getTcyChannel()),
        nHttpFlag       = 0,
        pHttpAck        = 0,
        nFromType       = YQW_REQ_FROMTYPE.kGame,
        szOrderID       = my.getRandomUnsignedCharString(8),
        nOrderDate      = tonumber(os.date("%Y%m%d"))
    }
    --订单号是同一个，可以重复发，并且会返回成功
    client:sendRequest(mc.MR_YQW_DON_HAPPY_COIN, params, nil, true)
end

function HallRequests:MR_GET_YQWROUNDWIN(nDirection, nLastBillTimestamp, nPageSize, callback, abbr)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nPlayerID       = self._userModel.nUserID,
        nDirection      = nDirection,
        nLastBillTimestamp = nLastBillTimestamp,
        nPageSize       = nPageSize,
        szGameCode      = abbr
    }

    client:sendRequest(mc.MR_GET_YQWROUNDWIN, params, nil, true)
end

function HallRequests:MR_GET_YQWGAMEWIN(szRoundBillID, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        szRoundBillID       = szRoundBillID,
        nNeedRule           = 1
    }

    client:sendRequest(mc.MR_GET_YQWGAMEWIN, params, nil, true)
end

function HallRequests:MR_REQUEST_PULSE()
    local client = mc.createClient()
    client:setCallback(function()
    end)

    local params = {}

    client:sendRequest( mc.MR_REQUEST_PULSE, params, nil, true)
end

function HallRequests:QUERY_USER_GAMEINFO(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {}

    client:sendRequest( mc.QUERY_USER_GAMEINFO, params, nil, true)
end

local FLAG_GETRNDKEY_MOBILE=0x00000800
function HallRequests:GET_RNDKEY(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nRegisterGroup  = 1,
        dwGetFlags      = FLAG_GETRNDKEY_MOBILE
    }

    client:sendRequest(mc.GET_RNDKEY, params, nil, true)
end


function HallRequests:QUERY_BACKDEPOSIT(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {}

    client:sendRequest(mc.QUERY_BACKDEPOSIT, params, nil, true)
end

function HallRequests:QUERY_SAFE_DEPOSIT(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {}

    client:sendRequest(mc.QUERY_SAFE_DEPOSIT, params, nil, true)
end

function HallRequests:MR_YQW_GET_HAPPY_COIN(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {nFromType = YQW_REQ_FROMTYPE.kGame}

    client:sendRequest(mc.MR_YQW_GET_HAPPY_COIN, params, nil, true)
end

function HallRequests:QUERY_MEMBER(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {}

    client:sendRequest(mc.QUERY_MEMBER, params, nil, true)
end

function HallRequests:QUERY_WEALTH(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {}

    client:sendRequest( mc.QUERY_WEALTH, params, nil, true)
end

function HallRequests:MR_GET_WEBSIGN( callback )
    local client = mc.createClient()
    client:setCallback(callback)
    client:sendRequest(mc.MR_GET_WEBSIGN, {}, nil, true)
end

function HallRequests:UR_SOCKET_CONFIG()
    local client = mc.createClient()
    client:sendRequest(mc.UR_SOCKET_CONFIG, {dwConfig = 1})
end

table.merge(HallRequests, import('src.app.GameHall.models.mcsocket.ClubRequests'))

cc.exports.HallRequests = HallRequests:getInstance()

return HallRequests 
