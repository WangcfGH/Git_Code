local AssistModel               = mymodel('assist.AssistModel'):getInstance()
local scheduler                 = cc.Director:getInstance():getScheduler()
local NewInviteGiftModel        = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
local UserModel                 = mymodel('UserModel'):getInstance()
local PlayerModel               = mymodel("hallext.PlayerModel"):getInstance()

local OldUserInviteGiftModel = class('OldUserInviteGiftModel', require('src.app.GameHall.models.BaseModel'))

my.addInstance(OldUserInviteGiftModel)
protobuf.register_file('src/app/plugins/invitegift/Fission.pb')

-- 消息号
OldUserInviteGiftModel.GR_QUERY_INVITEGIFT_CONFIG	    =	400000 + 4601
OldUserInviteGiftModel.GR_OLDUSER_ATTEND_INVITE         =   400000 + 4641
OldUserInviteGiftModel.GR_OLDUSER_GET_INVITEDATA        =   400000 + 4642
OldUserInviteGiftModel.GR_OLDUSER_TAKE_REWARD           =   400000 + 4643
OldUserInviteGiftModel.GR_OLDUSER_TAKE_REWARD_FAILED    =   400000 + 4644

OldUserInviteGiftModel.GR_OLDUSER_INVITESHARE_TAKE_REWARD =	400000 + 4645 --分享
OldUserInviteGiftModel.GR_OLDUSER_SHAREBTN_CLICK        = 400000 + 4671 -- 玩家点击分享

-- 事件
OldUserInviteGiftModel.EVENT_UPDATE_CONFIG          = "EVENT_UPDATE_CONFIG"
OldUserInviteGiftModel.EVENT_UPDATE_DATA            = "EVENT_UPDATE_DATA"
OldUserInviteGiftModel.EVENT_TASKREARD_SUCCEED      = "EVENT_TASKREARD_SUCCEED"         -- 奖励领取成功
OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON     = "EVENT_UPDATE_PACKET_ICON"        -- 显示红包图标
OldUserInviteGiftModel.EVENT_UPDATE_GIFT_ICON       = "EVENT_UPDATE_GIFT_ICON"          -- 显示邀请有礼图标
OldUserInviteGiftModel.EVENT_FRIEND_FIST_BINDING    = "EVENT_FRIEND_FIST_BINDING"       -- 首次出现和自己绑定的玩家
OldUserInviteGiftModel.EVENT_ATTEND_SUCCESS         = "EVENT_ATTEND_SUCCESS"            -- 参加活动成功
OldUserInviteGiftModel.EVENT_ATTEND_FAILED          = "EVENT_ATTEND_FAILED"             -- 参加活动失败
OldUserInviteGiftModel.EVENT_REDPACKET_OVER         = "EVENT_REDPACKET_OVER"            -- 红包流程结束
OldUserInviteGiftModel.EVENT_YQYL_RED_DOT           = 'EVENT_YQYL_RED_DOT'

OldUserInviteGiftModel.EVENT_SHAREREWARD_SUCCEED      = "EVENT_SHAREREWARD_SUCCEED"         -- 分享领取奖励成功

-- 缓存键值
OldUserInviteGiftModel.CACHE_KEY_RED_PACKET     = 'cache_key_red_packet'
OldUserInviteGiftModel.CACHE_KEY_POP_RECORD     = 'cache_key_pop_record'


--奖励类型
OldUserInviteGiftModel.RewardType = {
    YINZI       = 1,
    HUAFEI      = 2,
}

OldUserInviteGiftModel.RewardStatus = {
    notGet = 0,
    canGet = 1,
    getted = 2
}

function OldUserInviteGiftModel:onCreate()
    -- 注册回调
    self:initAssistResponse()

    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self.onAssistConnectOK))
    self:initEvent()
end

-- 注册回调
function OldUserInviteGiftModel:initAssistResponse()
    self._assistResponseMap = {
        [OldUserInviteGiftModel.GR_OLDUSER_ATTEND_INVITE] = handler(self, self.onAttendActivity),
        [OldUserInviteGiftModel.GR_OLDUSER_GET_INVITEDATA] = handler(self, self.onGetInviteData),
        [OldUserInviteGiftModel.GR_OLDUSER_TAKE_REWARD_FAILED] = handler(self, self.onTakeRewardFailed),
        [OldUserInviteGiftModel.GR_OLDUSER_TAKE_REWARD] = handler(self, self.onTakeReward),
        [OldUserInviteGiftModel.GR_OLDUSER_INVITESHARE_TAKE_REWARD] = handler(self, self.onInviteShareTakeReward),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function OldUserInviteGiftModel:onAssistConnectOK()
    self:sendInviteGiftData()
end

function OldUserInviteGiftModel:initEvent()
    NewInviteGiftModel:addEventListener(NewInviteGiftModel.EVENT_OLDUSER_TRIGGER, handler(self, self.onOldUserGiftTrigger))
end

function OldUserInviteGiftModel:reflashYqylRedDotEvent()
    self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_YQYL_RED_DOT})
end

function OldUserInviteGiftModel:sendInviteGiftData()
    local data = {
        nUserID =  UserModel.nUserID,
        szNickName = UserModel.szNickName,
        szDeviceID = cc.exports.getDeviceID()
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_ReqUserData', data)
    AssistModel:sendData(OldUserInviteGiftModel.GR_OLDUSER_GET_INVITEDATA, pbdata)
end

-- 请求参与活动
function OldUserInviteGiftModel:reqAttendActivity()
    local data = {
        nUserID =  UserModel.nUserID,
        szNickName = UserModel.szNickName,
        szDeviceID = cc.exports.getDeviceID()
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_ReqUserData', data)
    AssistModel:sendData(OldUserInviteGiftModel.GR_OLDUSER_ATTEND_INVITE, pbdata)
    self._isOpen = true
end

function OldUserInviteGiftModel:onAttendActivity(rawData)
    local _, status = string.unpack(rawData, '<i')
    if status == 0 then
        self:sendInviteGiftData()
        self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_ATTEND_SUCCESS})
    else
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "开红包失败"} })
        self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_ATTEND_FAILED})
    end
end

function OldUserInviteGiftModel:onGetInviteData(rawData)
    self:onInvitegiftData(rawData)

    self:reflashYqylRedDotEvent()
end

function OldUserInviteGiftModel:onTakeRewardFailed(data)
    print("邀请有礼领取奖励失败")
    local _,failedType = string.unpack(data, '<i')
    if failedType == NewInviteGiftModel.TakeRewardError.REWARD_CEILING then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "库存不足，请明日再来"} })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_DATE_INVALID then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "活动已结束"} })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_SHARE_NOTOPEN then
        if self._invitegiftData and self._invitegiftData.bInviteShareTakeReward then  --如果分享领奖开关关闭 处理为已经领过 
            self:sendInviteGiftData()
        end
    else
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "领取奖励失败"} })
    end
end

function OldUserInviteGiftModel:onTakeReward(data)
    print("邀请有礼领取奖励成功")
    self:onTaskReardSucceed(data)
 
    self:reflashYqylRedDotEvent()
end

function OldUserInviteGiftModel:onInviteShareTakeReward(data)
    print("分享成功 领取奖励成功")
    self:onShareRewardSucceed(data)

    self:reflashYqylRedDotEvent()
end

function OldUserInviteGiftModel:onInvitegiftData(rawData)
    local data = pb_decode('tc.protobuf.fission.PB_InviteGiftData', rawData)
    if self._invitegiftData then
        -- 如果新数据中有绑定的玩家信息，旧数据中没有
        local list = self:getUserList()
        if #list == 0 and (data.stUserList and #data.stUserList > 0) then
            if self:isEnable() then
                my.informPluginByName({ pluginName = 'OldUserInitGiftCtrl', params = {notReqData = true }})
            end
        end
    end

    -- 更新数据
    self._invitegiftData = pb_decode('tc.protobuf.fission.PB_InviteGiftData', rawData)
    if self._invitegiftData.nNeedShowOpen and self._invitegiftData.nNeedShowOpen == 1 then
        self._isOpen = false
    else
        self._isOpen = true
    end
    --加上本地时间 用于计算剩余时间 处理活动结束表现
    if self._invitegiftData.nCountDown then
        self._invitegiftData.nCountDown = self._invitegiftData.nCountDown + os.time()
    end

    self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_UPDATE_DATA, value = self._invitegiftData})
    self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON})
end 

function OldUserInviteGiftModel:onTaskReardSucceed(data)
    local data  = pb_decode('tc.protobuf.fission.PB_UserReward', data)

    -- local isFirstReward = false
    -- if not self:isReward() then
    --     isFirstReward = true
    -- end
    local nRewardType = data.nRewardType
    if nRewardType == 1 then --领取银子成功
        local rewardList = {}
        local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
        table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = data.nRewardNum})
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    else
        local tipContent = string.format("兑换成功，%s元话费\n将在24小时内充值到您指定的手机号", data.nRewardNum)
        my.informPluginByName({ pluginName = 'NewUserInviteTipCtr', params = { content = tipContent, isOne = true } })
    end

    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/InvitAwardSound.mp3'),false)
    
    PlayerModel:update({"UserGameInfo"})
    self:changeDataById(data.nNewUserID)

    local nInviteShareType = data.nInviteShareType
    if nInviteShareType == 0 then
        self._invitegiftData.bInviteRewardTakeReward = data.bInviteStaus
    elseif nInviteShareType == 1 then
        self._invitegiftData.bInviteShareTakeReward= data.bInviteStaus
    elseif nInviteShareType == 2 then
        self._invitegiftData.bInviteClickTakeReward= data.bInviteStaus
    end

    self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_TASKREARD_SUCCEED, value = data})
    self:sendInviteGiftData()

    -- if isFirstReward then
    --     -- 第一次领奖成功需要结束红包流程
    --     self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_REDPACKET_OVER})
    --     self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON})
    --     self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_UPDATE_GIFT_ICON})

    --     my.scheduleOnce(function ()
    --         my.informPluginByName({ pluginName = 'InviteGiftAwardCtrl' })
    --     end, 1.5) 
    -- end
end

--分享领取奖励成功
function OldUserInviteGiftModel:onShareRewardSucceed(data)
    local data  = pb_decode('tc.protobuf.fission.PB_UserReward', data)
    local rewardList = {}
    local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
    table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = data.nRewardNum})
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/InvitAwardSound.mp3'),false)
    PlayerModel:update({"UserGameInfo"})
    self:changeDataById(data.nNewUserID)
     
    local nInviteShareType = data.nInviteShareType
    if nInviteShareType == 0 then
        self._invitegiftData.bInviteRewardTakeReward = data.bInviteStaus
    elseif nInviteShareType == 1 then
        self._invitegiftData.bInviteShareTakeReward= data.bInviteStaus
    elseif nInviteShareType == 2 then
        self._invitegiftData.bInviteClickTakeReward= data.bInviteStaus
    end
    self:sendInviteGiftData()
    self:dispatchEvent({name = OldUserInviteGiftModel.EVENT_SHAREREWARD_SUCCEED, value = data})
end

-- 老玩家的邀请有礼可以被触发
function OldUserInviteGiftModel:onOldUserGiftTrigger(data)
    local value = data.value
    if not value then return end

    if not self:isRedPacketEnable() then
        return
    end

    -- 老玩家处理
    if value.nOldStatus == NewInviteGiftModel.OldUserStatus.CANDO then
        --如果新用户成老用户不需要判断对局数等限制
        if self:judgeCondition() or (value.nIsNewToOld and value.nIsNewToOld == 1) then
            self._isOpen = false
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("OldUserInitGiftCtrl", true)
            PluginProcessModel:startPluginProcess()
            --PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "OldUserInitGiftCtrl" })
            self:dispatchEvent({ name = OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON })
        else
            NewInviteGiftModel:setOldUserStatus(NewInviteGiftModel.OldUserStatus.NOTDO)
        end
    elseif value.nOldStatus == NewInviteGiftModel.OldUserStatus.DOING then
        -- 判断是红包阶段还是邀请有礼阶段
        -- self._isOpen = true
        -- if self:isReward() then
        --     PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "InviteGiftAwardCtrl" })
        --     self:dispatchEvent({ name = OldUserInviteGiftModel.EVENT_UPDATE_GIFT_ICON })
        -- else
        local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
        PluginProcessModel:setPluginReadyStatus("OldUserInitGiftCtrl", true)
        PluginProcessModel:startPluginProcess()
        -- PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "OldUserInitGiftCtrl" })
        self:dispatchEvent({ name = OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON })
        -- end
    end
end

--请求领取奖励
function OldUserInviteGiftModel:requireGetAward(phoneNum)
    local data = {
        nUserID =  UserModel.nUserID,
        nOldUserID = UserModel.nUserID,
        szPhoneNum  =phoneNum,--手机号	
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_TakeUserReward', data)
    AssistModel:sendData(OldUserInviteGiftModel.GR_OLDUSER_TAKE_REWARD, pbdata)
end

--请求分享奖励 1是分享立领 2是好友点击链接
function OldUserInviteGiftModel:requireGetShareAward( shareType )
    if self.isClickGetAward then
        return
    end
    self.isClickGetAward = true
    my.scheduleOnce(function()
        self.isClickGetAward = false
    end, 2)

    local data = {
        nUserID =  UserModel.nUserID,
        nType = shareType,
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_InviteShareTakeUserReward', data)
    AssistModel:sendData(OldUserInviteGiftModel.GR_OLDUSER_INVITESHARE_TAKE_REWARD, pbdata)
end

function OldUserInviteGiftModel:getConfig()
    local cfg = NewInviteGiftModel:getOldUserConfig()
    return cfg
end

--分享配置
function OldUserInviteGiftModel:getInviteShareCfg()
    local cfg = self:getConfig()
    if not cfg or not cfg.InviteShare then
        print("not InviteShare cfg")
        return  nil
    end
    return cfg.InviteShare
end


--分享开关是否开启
function OldUserInviteGiftModel:isOpenShare()
    local cfg = self:getInviteShareCfg()
    if not cfg or cfg.Enable ~= 1 then
        return false
    end
    return true
end

-- 客户端判断参与条件
function OldUserInviteGiftModel:judgeCondition()
    local config = self:getConfig()
    if not config then
        return false
    end

    -- 地区判断
    local areaJudge = false
    local lbsModel  = mymodel('hallext.LbsModel'):getInstance()
    local info = lbsModel:getLbsInfo()
    for _, v in pairs(config.oldUser.wellArea) do
        if v == info.cityName then
            areaJudge = true
            break
        end
    end
    
    local player = mymodel('hallext.PlayerModel'):getInstance()
    local playerData = player:getPlayerData()

    local boutJudge = false
    if areaJudge then
        boutJudge = playerData.nBout >= config.oldUser.localAreaBout
    else
        boutJudge = playerData.nBout >= config.oldUser.otherAreaBout
    end

    if not boutJudge then
        print("[OldUserInviteGiftModel:judgeCondition] not satisfy boutJudge")
        return false
    end

    -- 胜率判断
    local winRate = playerData.nWin / playerData.nBout
    if winRate < config.oldUser.winRate.bottom or winRate > config.oldUser.winRate.top then
        print("[OldUserInviteGiftModel:judgeCondition] not satisfy winRate")
        return false
    end

    return true
end

-- 获取奖励列表
function OldUserInviteGiftModel:getRewardList()
    local config = self:getConfig()
    if not config then
        print("OldUserConfig is empty")
        return {}
    end
    return config.oldUser.rewardList
end

function OldUserInviteGiftModel:getActiveTime()
    local config = self:getConfig()
    if not config then
        return 0, 0
    end
    return config.dateBegin or 0, config.dateEnd or 0
end

function OldUserInviteGiftModel:getInviteGiftData()
    return self._invitegiftData or {}
end

function OldUserInviteGiftModel:getUserList()
    if not self._invitegiftData then
        print("oldUserData is empty")
        return {}
    end

    return self._invitegiftData.stUserList or {}
end

function OldUserInviteGiftModel:changeDataById(userId)
    local data = self:getUserList() or {}
    for k, v in pairs(data) do
        if v and v.nNewUserID == userId then
            v.szOldRewardDate = self:getCurTimeStr()
        end
    end
end

function OldUserInviteGiftModel:getCurTimeStr()
    local time2 = os.time()  
    local tmYear    = os.date('%Y',os.time())
    local tmMon     = os.date('%m',os.time())
    local tmMday    = os.date('%d',os.time())
    return tmYear..tmMon..tmMday
end

function OldUserInviteGiftModel:getMaxProgressUser()
    local list = self:getUserList()
    if #list < 1 then
        return nil
    end
    local res = list[1]
    for _, v in pairs(list) do
        if res.nBoutNum < v.nBoutNum then
            res = v
        end
    end

    return res
end

function OldUserInviteGiftModel:getSortBindUserList(sortType)
    local userList = clone(self:getUserList()) or {}
    local function sortFunc(a, b)
        if not a or not b then return false end
        local aTime = tonumber(string.sub(a.szOldRewardDate,1,8) or 0)
        local bTime = tonumber(string.sub(b.szOldRewardDate,1,8) or 0)
        if aTime > 0 and bTime > 0 then
            return aTime < bTime
        end

        if aTime == bTime then
            return a.nBoutNum > b.nBoutNum
        end

        if sortType and sortType == 1 then  --已经完成的排在后面
            return aTime < bTime
        else
            return aTime > bTime
        end
    end
    table.sort(userList, sortFunc)

    return userList
end

-- 获取活动剩余时间
function OldUserInviteGiftModel:getRemainSecond()
    local dateBegin, dateEnd = self:getActiveTime()
    local data = {
        year = math.floor(dateEnd / 10000),
        month = math.floor((dateEnd % 10000) / 100),
        day = dateEnd % 100,
        hour = 0,
        minute = 0,
        second = 0
    }
    local endTimeStamp = os.time(data) + 60 * 60 * 24
    local currentTimeStamp = os.time()

    if currentTimeStamp >= endTimeStamp then
        print("[OldUserInviteGiftModel:getRemainSecond] activity is over")
        return 0
    end

    return endTimeStamp - currentTimeStamp
end

-- 获取剩余时间，格式天 时 分
function OldUserInviteGiftModel:GetRemainTimeDHM(second)
    local s = second % 60
    local m = ((second - s) / 60) % 60
    local h = ((second - s - (m * 60)) / 3600) % 24
    local d = (second - s - (m * 60) - (h * 3600)) / (3600 * 24)

    return {day = d, hour = h, minute = m, second = s}
end

-- 时间戳转日期
function OldUserInviteGiftModel:convertStampToDate(timeStamp)
    if timeStamp and timeStamp >= 0 then
        local tb = {}
        tb.year = tonumber(os.date("%Y",timeStamp))
        tb.month =tonumber(os.date("%m",timeStamp))
        tb.day = tonumber(os.date("%d",timeStamp))
        tb.hour = tonumber(os.date("%H",timeStamp))
        tb.minute = tonumber(os.date("%M",timeStamp))
        tb.second = tonumber(os.date("%S",timeStamp))
        return tb
    end
end

-- 今日是否还可领取奖励
function OldUserInviteGiftModel:isCanGetAwardToday()
    local modelData = self:getUserList() 
    local getNum = 0
    local curTime = tonumber(OldUserInviteGiftModel:getCurTimeStr())
    for k, v in pairs(modelData) do
        local time = tonumber(string.sub(v.szOldRewardDate,1,8) or 0)
        if curTime == time then
            getNum = getNum + 1
        end
    end

    local config = self:getConfig()
    local dailyLimit = 1
    if config and config.oldUser then
        dailyLimit = config.oldUser.dailyLimit
    end
    return getNum < dailyLimit
end

-- 获取默认的分享方式
function OldUserInviteGiftModel:getDefaultShareType()
    local config = self:getConfig()

    if (not config) or (not config.oldUser) or (not config.oldUser.defaultShareType) then
        return 1
    end

    return config.oldUser.defaultShareType
end

-- 是否有绑定的玩家
function OldUserInviteGiftModel:isBinding()
    local userList = self:getUserList()
    
    if #userList > 0 then
        return true
    end

    return false
end

-- 活动是否开启
function OldUserInviteGiftModel:isEnable()
    local config = self:getConfig()
    if not config then return false end

    if config.enable ~= 1 then
        return false
    end

    -- 活动时间判断
    local currentDay = tonumber(self:getCurTimeStr())
    if currentDay < config.dateBegin or currentDay > config.dateEnd then
        return false
    end

    -- 判断老玩家活动状态
    local status = NewInviteGiftModel:getOldUserStatus()
    if not status then return false end

    if status == 0 then
        return false
    end

    return true
end

-- 已经达到领取上限
function OldUserInviteGiftModel:isRewardMax()
    local userList = self:getUserList()
    local rewardList = self:getRewardList()
    
    if #userList == 0 then
        return false
    end

    local i = 0
    for k, v in pairs(userList) do
        if v.szOldRewardDate ~= "0" then
            i = i + 1
        end
    end

    if i >= #rewardList then
        return true
    end

    return false
end

-- 绑定者全都已经领取过了
function OldUserInviteGiftModel:isBindUserAllRewarded()
    local userList = self:getUserList()
    
    if #userList == 0 then
        return false
    end

    local i = 0
    for k, v in pairs(userList) do
        if v.szOldRewardDate ~= "0" then
            i = i + 1
        end
    end

    if i == #userList then
        return true
    end

    return false
end

--获取本小期剩余活动时间
function OldUserInviteGiftModel:getCurrentPeriodTime()
    if self._invitegiftData and  self._invitegiftData.nCountDown then
        return self._invitegiftData.nCountDown- os.time()
    end
    return 0
end

-- 红包活动是否开启
function OldUserInviteGiftModel:isRedPacketEnable()
    if not self:isEnable() then
        print("[OldUserInviteGiftModel:isRedPacketEnable] active is not enable")
        return false
    end

    --如果这个为1一定会开
    if self._invitegiftData and self._invitegiftData.nNeedShowOpen == 1 then
        return  true
    end

    if not self._invitegiftData or self._invitegiftData.nRewardNo <= 0 then
        return false
    end

    if self:getCurrentPeriodTime() <= 0 and self:getInviteRewardStatus() ~= OldUserInviteGiftModel.RewardStatus.canGet then
        return  false
    end

    -- if self:isReward() then
    --     print("[OldUserInviteGiftModel:isRedPacketEnable] red packet is rewarded")
    --     return false
    -- end

    return true
end

-- 邀请有礼是否开启
function OldUserInviteGiftModel:isInviteGiftEnable()
    if not self:isEnable() then
        return false
    end 
    return true
end

-- 老玩家是否有领过任何一次奖励
function OldUserInviteGiftModel:isReward()
    local list = self:getUserList()
    
    if #list == 0 then
        return false
    end

    for k, v in pairs(list) do
        if v.szOldRewardDate ~= "0" then
            return true
        end
    end 

    return false
end

-- 是否领过此用户ID的奖励
function OldUserInviteGiftModel:isRewardByUserID(bindUserID)
    local list = self:getUserList()
    
    if #list == 0 then
        return false
    end

    for k, v in pairs(list) do
        if v.nUserID == bindUserID and v.szOldRewardDate ~= "0" then
            return true
        end
    end 

    return false
end

-- 是否开启过红包
function OldUserInviteGiftModel:isOpenPacket()
    return self._isOpen
end

-- 在已邀请的玩家中，是否有可以领奖的
function OldUserInviteGiftModel:isEnableReward()
    local userList = self:getUserList()
    if #userList == 0 then
        return false
    end

    local rewardList = self:getRewardList()
    if #rewardList == 0 then
        return false
    end

    local res = false

    for _, v in pairs(userList) do
        if (v.nBoutNum >= rewardList[1].boutNum) and (v.szOldRewardDate == "0") then
            res = true
            break
        end
    end

    return res
end

--是否显示红点
function OldUserInviteGiftModel:isShowRedDot()
    -- local rewardListCfg = OldUserInviteGiftModel:getRewardList() or {}
    -- local reward = rewardListCfg[1] or {}
    -- local maxBout = reward.boutNum or 10
    -- local list = self:getUserList() or {}
    -- local getCont = 0
    -- local canGet = false
    -- for i, data in pairs(list) do
    --     local curBout = data.nBoutNum
    --     local getTime = string.len(data.szOldRewardDate) > 1 and 1 or 0
    --     --已领取次数
    --     if getTime > 0 and curBout >= maxBout then
    --         getCont = getCont + 1
    --     end
    --     if getTime <= 0 and curBout >= maxBout then
    --         canGet = true
    --     end
    -- end
    -- --领取次数小于上限次数 并且能够领取
    -- if getCont < #rewardListCfg and canGet then
    --     return true
    -- end

    return false
end

-- ****缓存Cache相关****

-- 是否看到过邀请流程图
function OldUserInviteGiftModel:isSeeFlowCache()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.seeFlowView then
        info.seeFlowView = 0
        self:setSeeFlowCache(0)
        return false
    end

    return info.seeFlowView == 1
end

-- 是否首次对局结束
function OldUserInviteGiftModel:isFistBoutRes()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.isFistBout then
        info.isFistBout = 1
        self:setFistBoutCache(1)
        return true
    end

    return info.isFistBout == 1
end

-- 是否看到第一次对局的奖励
function OldUserInviteGiftModel:isSeeFirstBoutReward()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.isFistBoutReward then
        info.isFistBoutReward = 0
        self:setFistBoutRewardCache(0)
        return false
    end

    return info.isFistBoutReward == 1 
end

-- 参与到当前活动后对局
function OldUserInviteGiftModel:getBoutCache()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.numBout then
        info.numBout = 0
        self:setBoutCache(0)
    end

    return info.numBout
end

-- 是否看到了被邀请人登录
function OldUserInviteGiftModel:isShowFriendHelpCache()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.seeFriendHelp then
        info.seeFriendHelp = 0
        self:setShowFriendHelpCache(0)
    end

    return info.seeFriendHelp == 1
end

-- 是否测试过能领取多少
function OldUserInviteGiftModel:isQualificationJudgeCache()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.isJudge then
        info.isJudge = 0
        self:setQualificationJudgeCache(0)
    end

    return info.isJudge == 1
end

-- 获取邀请操作信息
function OldUserInviteGiftModel:getShareOperateInfo()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.shareStatus then
        info.shareStatus = 0
        self:setShareOperate(0)
    end

    return info
end

-- 今日破产时是否可以弹出
function OldUserInviteGiftModel:isEnablePop()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_POP_RECORD)
    if not info.date then
        self:setPopRecord(0)
        return true
    end

    if info.date ~= cc.exports.getCurrentDayNum() then
        self:setPopRecord(0)
        return true
    end

    dump(info)

    if info.count < 1 then
        return true
    end

    return false
end

function OldUserInviteGiftModel:setBoutCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.numBout = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:addBoutCache()
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    if not info.numBout then
        info.numBout = 0
    end
    if info.numBout < 10 then
        info.numBout = info.numBout + 1
    end
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setSeeFlowCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.seeFlowView = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setShareOperate(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.shareStatus = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setQualificationJudgeCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.isJudge = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setShowFriendHelpCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.seeFriendHelp = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setFistBoutCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.isFistBout = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setFistBoutRewardCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET)
    info.isFistBoutReward = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_RED_PACKET, info)
end

function OldUserInviteGiftModel:setPopRecord(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_POP_RECORD)
    info.date = cc.exports.getCurrentDayNum()
    info.count = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_POP_RECORD, info)
end

--设置每小周期首次弹大奖界面
OldUserInviteGiftModel.OLDFIRSTSHOWREWARDPANEL     = 'OldFirstShowRewardPanel'
function OldUserInviteGiftModel:setPopRewardPanel(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.OLDFIRSTSHOWREWARDPANEL)
    info.PopReward = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.OLDFIRSTSHOWREWARDPANEL, info)
end

--每小期埋点缓存
OldUserInviteGiftModel.CACHE_KEY_REWARD_NO     = 'CACHE_KEY_REWARD_NO'
function OldUserInviteGiftModel:setnRewardNoCache(value)
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_REWARD_NO)
    info.RewardNo = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_REWARD_NO, info)
end

--每日点缓存
OldUserInviteGiftModel.CACHE_KEY_DAY_TIME = "CACHE_KEY_DAY_TIME"
function OldUserInviteGiftModel:setDayTimeCache( value )
    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_DAY_TIME)
    info.time = value
    CacheModel:saveInfoToUserCache(OldUserInviteGiftModel.CACHE_KEY_DAY_TIME, info)
end

-- 获取RewardIndex
function OldUserInviteGiftModel:getRewardIndex()
    local cfg = self:getConfig()
    local uID = UserModel.nUserID
    if uID then
        local nEndNum = uID % 10
        local rewardTableIndex = cfg.RewardTableIndexByUserID[tostring(nEndNum)]
        if rewardTableIndex > 0 and rewardTableIndex <= #cfg.Reward then
            return rewardTableIndex
        end
    end

    return 1
end

--获取本期活动配置数据
function OldUserInviteGiftModel:getCurTimeActCfgData()
    local cfg = self:getConfig()
    local Rewards = cfg.Reward
    local rewardIndex= self:getRewardIndex()

    if self._invitegiftData and self._invitegiftData.nRewardNo then
        local rewardNo = self._invitegiftData.nRewardNo
        for k, v in pairs(Rewards[rewardIndex]) do
            if v and v.Id == rewardNo then
                return v
            end
        end
    end
    return nil
end

--是否可以立领奖励
function OldUserInviteGiftModel:getShareTakeRewardStatus()
    if not self._invitegiftData or not self._invitegiftData.bInviteShareTakeReward then
        return false
    end
    return self._invitegiftData.bInviteShareTakeReward == 1
end

--是否可以领取好友点击链接后的奖励
function OldUserInviteGiftModel:getInviteClickTakeRewardStatus()
    if not self._invitegiftData or not self._invitegiftData.bInviteClickTakeReward then
        return 0
    end
    return self._invitegiftData.bInviteClickTakeReward
end

--是否可以领取最终奖励
function OldUserInviteGiftModel:getInviteRewardStatus()
    if not self._invitegiftData or not self._invitegiftData.bInviteRewardTakeReward then
        return 0
    end
    return self._invitegiftData.bInviteRewardTakeReward
end


function OldUserInviteGiftModel:getNeedSatisfy()
    local cfg = self:getCurTimeActCfgData()
    local list = self:getUserList()
    local numP = cfg.Limit_OldPlayer
    local diffP = numP - #list
    if diffP > 0 then
        return 1,diffP
    end
    local limit = cfg.Limit_NewPlayer 
    local total = limit * numP

    local completeBoutNum = 0
    for _, v in pairs(list) do
        if v.nBoutNum >= limit then
            completeBoutNum = completeBoutNum + limit
        else
            completeBoutNum = completeBoutNum + v.nBoutNum
        end
    end
    local dif = total - completeBoutNum
    return 2,dif
end


--获取本期活动配置数据
function OldUserInviteGiftModel:getNextTimeActCfgData(RewardType,rewardNo)
    local cfg = self:getConfig()
    local rewardIndex= self:getRewardIndex()
    local Rewards = cfg.Reward
    local nextNo = nil
    local rewardIDs = {}
    for k, v in pairs(Rewards[rewardIndex]) do
        if v.RewardType == RewardType and v.OldPlayer_Can == 1 then
            table.insert(rewardIDs, v.Id)
        end
    end
    -- 找比输入的id大的，没找到就是最小的那个
    local isFind = false;
    for i, id in ipairs(rewardIDs) do
        if id > rewardNo then
            nextNo = id
            isFind = true
            break
        end
    end

    if not isFind and #rewardIDs > 0 then
        nextNo = rewardIDs[1]
    end
    
    if nextNo == nil then
        return nil
    end
    return Rewards[rewardIndex][nextNo]
end

function OldUserInviteGiftModel:clickLookUserList()
    self._isClick = true
    local list = self:getUserList()
    self.userNum = #list
    
    self:reflashYqylRedDotEvent()
end

function OldUserInviteGiftModel:lookUserListRed()
    local list = self:getUserList()
    if not self.userNum then
        self.userNum = #list
    end
    if #list > self.userNum then
        self._isClick = false
    end

    if #list > self.userNum and not self._isClick then
        return true
    end
    return false
end

function OldUserInviteGiftModel:isRedPacketDotShow()
 
    if self:isCanGetAward() then
        return true
    end 
    --好友是否有新增
    if self:lookUserListRed() then
        return true
    end

    return  false

end

function OldUserInviteGiftModel:isCanGetAward()
    --是否可以领取好友点击链接后的奖励
    if self:getInviteClickTakeRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet and self:isOpenShare() then
        return true
    end 
    --大奖是否可领
    if self:getInviteRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
        return true
    end
    return false
end


--开始游戏 再来一局判断是否显示 本次登录指弹一次
function OldUserInviteGiftModel:isClickShowPanel(cb)
    if self:isRedPacketEnable() and self:getInviteRewardStatus() ~= OldUserInviteGiftModel.RewardStatus.getted and not self.signPopTipGift then
        self.signPopTipGift = true
        my.informPluginByName({ pluginName = "OldUserInitGiftCtrl",params = {clickCloseBtnCb = cb} })
        return  true
    end
    return  false
end


--开始游戏 再来一局判断是否显示 以及本次登录第一次从房间退出弹一次
function OldUserInviteGiftModel:canGetAwardPop()
    if self:isRedPacketEnable() and not self.firstPop then
        self.firstPop = true
        my.scheduleOnce(function()
            my.informPluginByName({ pluginName = "OldUserInitGiftCtrl"})
        end, 0) 
        return 
    end

    if self:isRedPacketEnable() and self:getInviteRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
        my.scheduleOnce(function()
            my.informPluginByName({ pluginName = "OldUserInitGiftCtrl"})
        end, 0) 
    end
end

function OldUserInviteGiftModel:reqShareBtnClick()
    local data = {
        nUserID =  UserModel.nUserID,
        nChannelID = my.getTcyChannelId()
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_OnShareBtnClick', data)
    AssistModel:sendData(OldUserInviteGiftModel.GR_OLDUSER_SHAREBTN_CLICK, pbdata)
end

return OldUserInviteGiftModel