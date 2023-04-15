local NewInviteGiftModel        = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
local AssistModel               = mymodel('assist.AssistModel'):getInstance()
local UserModel                 = mymodel('UserModel'):getInstance()

local NewUserInviteGiftModel = class("NewUserInviteGiftModel", require('src.app.GameHall.models.BaseModel'))
my.addInstance(NewUserInviteGiftModel)


--话费兑换类型
NewUserInviteGiftModel.ExchangeType = {
    NewUser      = 0,
    OldUser      = 1,
    DailyShare   = 2
}

-- 事件
NewUserInviteGiftModel.EVENT_UPDATE_CONFIG              = "EVENT_UPDATE_CONFIG"
NewUserInviteGiftModel.EVENT_UPDATE_DATA                = "EVENT_UPDATE_DATA"
NewUserInviteGiftModel.EVENT_UPDATE_TICKET_ICON         = "EVENT_UPDATE_TICKET_ICON"

NewUserInviteGiftModel.GR_NEWUSER_GET_REWARDDATA        =   400000 + 4621--请求新用户数据
NewUserInviteGiftModel.GR_NEWUSER_UPDATE_REWARD         =   400000 + 4622--对局增加话费券
NewUserInviteGiftModel.GR_NEWUSER_TAKE_REWARD           =   400000 + 4623--领奖（话费券）
NewUserInviteGiftModel.GR_NEWUSER_TAKE_REWARD_FAILED    =   400000 + 4624--领奖（话费券）失败

NewUserInviteGiftModel.CACHE_KEY_NEWUSERINVITEGIFT = 'cache_key_newuserinvitegift'

function NewUserInviteGiftModel:onCreate()
    -- 注册回调
    self:initAssistResponse()

    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self.onAssistConnectOK))

    self:initEvent()
end

-- 注册回调
function NewUserInviteGiftModel:initAssistResponse()
    self._assistResponseMap = {
        [NewUserInviteGiftModel.GR_NEWUSER_GET_REWARDDATA] = handler(self, self.onUpdateReward),
        [NewUserInviteGiftModel.GR_NEWUSER_UPDATE_REWARD] = handler(self, self.onRefreshReward),
        [NewUserInviteGiftModel.GR_NEWUSER_TAKE_REWARD] = handler(self, self.onTakeReward),
        [NewUserInviteGiftModel.GR_NEWUSER_TAKE_REWARD_FAILED] = handler(self, self.onTakeRewardFailed),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NewUserInviteGiftModel:onAssistConnectOK()
    self:reqNewUserGetAwarddata()
end

function NewUserInviteGiftModel:initEvent()
    NewInviteGiftModel:addEventListener(NewInviteGiftModel.EVENT_NEWUSER_TRIGGER, handler(self, self.onNewUserGiftTrigger))
end

function NewUserInviteGiftModel:onUpdateReward(data)
    self._newUserData = pb_decode('tc.protobuf.fission.PB_NewUserData', data)
    self:dispatchEvent({name = NewUserInviteGiftModel.EVENT_UPDATE_DATA, value = self._newUserData})
    self:dispatchEvent({name = NewUserInviteGiftModel.EVENT_UPDATE_TICKET_ICON})
end

function NewUserInviteGiftModel:onRefreshReward(data)
end

function NewUserInviteGiftModel:onTakeReward(data)
    -- print("话费兑换成功")
    local rewardNum = self:getTelephoneCharge()
    local tipContent = string.format("兑换成功，%s元话费\n将在24小时内充值到您指定的手机号", rewardNum)
    local cb = function ()
        local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
        OldUserInviteGiftModel:sendInviteGiftData()
        NewInviteGiftModel:reqBindInfo()
    end
    my.informPluginByName({ pluginName = 'NewUserInviteTipCtr', params = { content = tipContent, isOne = true ,knowCallBack= cb ,closeCallBack = cb } })
    self:reqNewUserGetAwarddata()
end

function NewUserInviteGiftModel:onTakeRewardFailed(data)
    local _, failedType = string.unpack(data, '<i')
    if failedType == NewInviteGiftModel.TakeRewardError.REWARD_PHONE_INVALID then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "手机号格式异常" } })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_PHONE_TAKED then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "手机号已领过奖励" } })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_TICKET_LESS then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "话费券不满足可领条件" } })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_BOUT_LIMIT then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "对局过程存在异常，请联系客服处理" } })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_DAY_INVALID then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "不在领奖有效期" } })
    elseif failedType == NewInviteGiftModel.TakeRewardError.REWARD_CEILING then
        -- 奖励上限后显示假的提示语
        local rewardNum = self:getTelephoneCharge()
        local tipContent = string.format("兑换成功，%s元话费\n将在24小时内充值到您指定的手机号", rewardNum)
        local cb = function ()
            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
            NewInviteGiftModel:reqBindInfo()
        end
        my.informPluginByName({ pluginName = 'NewUserInviteTipCtr', params = { content = tipContent, isOne = true ,knowCallBack= cb  ,closeCallBack = cb} })
    end
end

-- 请求参与活动
function NewUserInviteGiftModel:reqNewUserGetAwarddata()
    local data = {
        nUserID =  UserModel.nUserID,
        szNickName = UserModel.szNickName,
        szDeviceID = cc.exports.getDeviceID()
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_ReqUserData', data)
    AssistModel:sendData(NewUserInviteGiftModel.GR_NEWUSER_GET_REWARDDATA, pbdata)
end



--新玩家信息
function NewUserInviteGiftModel:getNewUserData()
    return  self._newUserData or {}
end

--请求兑换话费
function NewUserInviteGiftModel:requireGetAward(phoneNum)
    local info = self:getNewUserData() 
    local data = {
        nUserID =  UserModel.nUserID,
        nOldUserID = info.nOldUserID,
	    szPhoneNum  =phoneNum,--手机号	
    }
    local pbdata = protobuf.encode('tc.protobuf.fission.PB_TakeUserReward', data)
    AssistModel:sendData(NewUserInviteGiftModel.GR_NEWUSER_TAKE_REWARD, pbdata)
end

-- 自动进入游戏
function NewUserInviteGiftModel:autoEnterGame()
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
end

-- 触发新手邀请礼包
function NewUserInviteGiftModel:onNewUserGiftTrigger(data)
    local value = data.value
    if not value then return end
    self._newUserData = value.stNewUser
    if not self._newUserData.szBindDate then
        self._newUserData.szBindDate = self:getCurTimeStr() .. "-00:00:00"
    end
    NewInviteGiftModel:setAutoEnterGame(false)
    if value.nNewStatus == NewInviteGiftModel.NewUserStatus.NOTBIND then
        print("[NewUserInviteGiftModel:onNewUserGiftTrigger] new user not bind")
    elseif value.nNewStatus == NewInviteGiftModel.NewUserStatus.BINDING then
        -- 再判断不是切后台复制口令的 直接进游戏 否则弹出特殊情况的话费弹窗
        if NewInviteGiftModel:isBackgroundCopy() then
            print("status is binding pop binding NewUserInviteGiftCtrl")
            -- 弹特殊弹窗
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("NewUserInviteGiftCtrlEx", true)
            PluginProcessModel:startPluginProcess()

            -- PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "NewUserInviteGiftCtrl" , params = {isBinding = true}})
        else
            NewInviteGiftModel:setAutoEnterGame(true)
            NewInviteGiftModel:setNewUserStatus(NewInviteGiftModel.NewUserStatus.BINDED)
            -- 直接进游戏
            self:autoEnterGame()
        end
    elseif value.nNewStatus == NewInviteGiftModel.NewUserStatus.BINDED then
        if NewInviteGiftModel:isBackgroundCopy() and self._newUserData.nBoutNum == 0 then
            -- 处理复制了口令但是又发生了重连
            print("status is binded, bout is 0 and background copy, pop binding NewUserInviteGiftCtrl")
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("NewUserInviteGiftCtrlEx", true)
            PluginProcessModel:startPluginProcess()

            -- PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "NewUserInviteGiftCtrlEx" , params = {isBinding = true}})
        else
            -- 弹出话费弹窗
            if not self:isGetedAward() and self:isOpenActiveTime() then
                local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
                PluginProcessModel:setPluginReadyStatus("NewUserInviteGiftCtrl", true)
                PluginProcessModel:startPluginProcess()

                -- PluginTrailMonitor:pushPluginIntoTrail({ pluginName = "NewUserInviteGiftCtrl"}) 
            end
        end
    end
    self:dispatchEvent({name = NewUserInviteGiftModel.EVENT_UPDATE_TICKET_ICON})
    self:dispatchEvent({name = NewUserInviteGiftModel.EVENT_UPDATE_DATA, value = self._newUserData})
end



--获取当前话费券
function NewUserInviteGiftModel:getCurPhoneTicket()
    local data = self:getNewUserData()
    return data.fPhoneTicket or 0
end

--获取配置
function NewUserInviteGiftModel:getInviteGiftConfig()
    return NewInviteGiftModel:getNewUserConfig() or {}
end


function NewUserInviteGiftModel:getDiffAndTotalMoney()
    if not self:isOpenNewUserPhoneAct() then
        return 0,0
    end
    local data = self:getNewUserData()
    local curMoney = data.fPhoneTicket or 0
    local totalReward = self:getTelephoneCharge()
    return totalReward,totalReward-curMoney
end

-- 在游戏内icon显示状态
--1.如果不在活动期间 不显示
--2.如果累计话费兑换了 不显示
function NewUserInviteGiftModel:isShowInGameScene()
    local isAct = self:isOpenNewUserPhoneAct()
    if not isAct then return  false end
    local data = self:getNewUserData()
    local nRewardStatus = data.nRewardStatus or 0
    if nRewardStatus >= 1 then return false end --如果话费券已经兑换了 就不显示
    return true
end

--是否新用户话费活动开启
function NewUserInviteGiftModel:isOpenNewUserPhoneAct()
    local status = NewInviteGiftModel:getNewUserStatus()
    if not status or status == NewInviteGiftModel.NewUserStatus.NOTBIND then  
        return  false
    end 
    if not self:isOpenActiveTime() then
        return false
    end
    local data = self:getNewUserData()
    local phoneNum = data.szPhoneNum or ""
    if phoneNum and string.len( phoneNum ) == 11 then
        return false
    end
    return true   
end

--是否在兑换有效期内（不在有效时间内 再次登入不显示入口）
function NewUserInviteGiftModel:isOpenActiveTime()
    -- local config = NewUserInviteGiftModel:getInviteGiftConfig()
    -- if not config or not config.dateEnd or not config.dateBegin then
    --     return false
    -- end
    -- -- 活动时间判断
    -- local currentDay = tonumber(self:getCurTimeStr())
    -- if currentDay < config.dateBegin or currentDay > config.dateEnd then
    --     return false
    -- end
    local endTime =  self:getAwardEndTime()
    return endTime > 0
end

function NewUserInviteGiftModel:getCurTimeStr()
    local time2 = os.time()  
    local tmYear    = os.date('%Y',os.time())
    local tmMon     = os.date('%m',os.time())
    local tmMday    = os.date('%d',os.time())
    return tmYear..tmMon..tmMday
end

--剩余兑换有效时间
function NewUserInviteGiftModel:getAwardEndTime()
    local config = self:getInviteGiftConfig()
    local exchangeDay = 0
    if config and config.newUser then
        exchangeDay = config.newUser.exchangeDay or 0
    end
    local data = self:getNewUserData()

    if not data.szBindDate then
        return 0
    end

    local bindTime = tonumber(string.sub(data.szBindDate,1,8) or 0)
    local currentDay = tonumber(self:getCurTimeStr())
    return exchangeDay - ( currentDay - bindTime )
end


--是否可以兑换
function NewUserInviteGiftModel:isCanGetAward()
    if not self:isOpenNewUserPhoneAct() then
        return false
    end
    local data = self:getNewUserData()
    local curMoney = data.fPhoneTicket or 0
    local totalReward = self:getTelephoneCharge()
    local nRewardStatus = data.nRewardStatus or 0
    if totalReward > 0 and curMoney >= totalReward and nRewardStatus <= 0 then
        return true
    end
    return false
end

--是否已经兑换了
function NewUserInviteGiftModel:isGetedAward()
    local data = self:getNewUserData()
    local nRewardStatus = data.nRewardStatus or 0
    if nRewardStatus == 1 then return  true end
    return false
end

--获取配置中的话费额
function NewUserInviteGiftModel:getTelephoneCharge()
    local config = self:getInviteGiftConfig() or {}
    local info = config.newUser or {}
    local rewardNum = 0
    if info and info.totalReward then
        rewardNum =  info.totalReward.rewardNum or 0
    end
    return rewardNum
end

-- 是否在结果界面上显示过了
function NewUserInviteGiftModel:isShowOnResultView()
    local info = CacheModel:getCacheByKey(NewUserInviteGiftModel.CACHE_KEY_NEWUSERINVITEGIFT)
    if not info.isShowOnResult then
        info.isShowOnResult = 0
        self:setShowOnResult(0)
    end

    return info.isShowOnResult == 1
end

function NewUserInviteGiftModel:setShowOnResult(value)
    local info = CacheModel:getCacheByKey(NewUserInviteGiftModel.CACHE_KEY_NEWUSERINVITEGIFT)
    info.isShowOnResult = value
    CacheModel:saveInfoToUserCache(NewUserInviteGiftModel.CACHE_KEY_NEWUSERINVITEGIFT, info)
end


--首次弹大奖界面 埋点缓存
NewUserInviteGiftModel.NEWFIRSTSHOWREWARDPANEL     = 'NewFirstShowRewardPanel'
function NewUserInviteGiftModel:setPopRewardPanel(value)
    local info = CacheModel:getCacheByKey(NewUserInviteGiftModel.NEWFIRSTSHOWREWARDPANEL)
    info.firstReward = value
    CacheModel:saveInfoToUserCache(NewUserInviteGiftModel.NEWFIRSTSHOWREWARDPANEL, info)
end


return NewUserInviteGiftModel