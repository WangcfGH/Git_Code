local RedPack100Model =class('RedPack100Model',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local RedPack100Def = require('src.app.plugins.RedPack100.RedPack100Def')
local RedPack100Req = require('src.app.plugins.RedPack100.RedPack100Req')
local user = mymodel('UserModel'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local RedPack100Cache = import('src.app.plugins.RedPack100.RedPack100Cache'):getInstance()

local treepack = cc.load('treepack')

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(RedPack100Model,PropertyBinder)
my.addInstance(RedPack100Model)

RedPack100Model.BREAK_CONDITION = {
    LOGIN_COND = 1,
    BOUT_REACH = 2
}

RedPack100Model.REDPACK_ACTIVITY_AVALIABLE = "RedPackActivityAvaliable"

function RedPack100Model:onCreate()
    self:initAssistResponse()
    self._RedPackInfo = {}
end

function RedPack100Model:initAssistResponse()
    self._assistResponseMap = {
        [RedPack100Def.GR_REDPACK100_QUERY_RESP] = handler(self, self.onRedPackQueryResp),
        [RedPack100Def.GR_REDPACK100_BREAK_RESP] = handler(self, self.onRedPackBreakResp),
        [RedPack100Def.GR_REDPACK100_REWARD_RESP] = handler(self, self.onRedPackRewardResp),
        [RedPack100Def.GR_REDPACK100_ACTIVITY_UPDATE_RESP] = handler(self, self.onRedPackUpdateResp),
        [RedPack100Def.GR_REDPACK100_BOUT_UPDATE] = handler(self, self.onRedPackPlayedBoutUpdate),
        
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

-- 红包查询请求
function RedPack100Model:gc_GetRedPackInfo()
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Model:gc_GetRedPackInfo()")
    local bCheck = self:CacheCheckVailadate()
    if false == bCheck then
        print("RedPack100Model gc_GetRedPackInfo CacheCheckVailadate return false!")
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("RedPack100Model userinfo is not ok")
        return
    end

    local device = require("src.app.GameHall.models.DeviceModel"):getInstance()
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID
    local data = {
        nUserID = user.nUserID,
        nUserBout   = user.nBout,
        nChannelID = BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0,
        szDeviceID = deviceCombineID,
    }

    AssistModel:sendRequest(RedPack100Def.GR_REDPACK100_QUERY_REQ, RedPack100Req.REDPACK_QUERY_REQ, data, false)
    if DEBUG then
        print("RedPack100Model gc_GetRedPackInfo send!!!", user.nUserID, user.nBout)

--[[        for i=1, 100 do
            data.nUserID = 435400+i
            data.szDeviceID = i..deviceCombineID
            AssistModel:sendRequest(RedPack100Def.GR_REDPACK100_QUERY_REQ, RedPack100Req.REDPACK_QUERY_REQ, data, false)
        end
    ]]--
    end
end

-- 拆红包请求
function RedPack100Model:gc_BreakRedPack(nBreakCondition)
    local bCheck = self:CacheCheckVailadate()
    if false == bCheck then
        print("RedPack100Model gc_BreakRedPack CacheCheckVailadate return false!")
        self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_BREAK_FAILED, value=RedPack100Def.BREAK_OUT_OF_DATE})
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("gc_BreakRedPack userinfo is not ok")
        return
    end

    local data = {
        nUserID = user.nUserID,
        nUserBout   = user.nBout,
        nChannelID = BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0,
        nBreakCond = nBreakCondition,
        szUserName = user.szUsername,
    }

    AssistModel:sendRequest(RedPack100Def.GR_REDPACK100_BREAK_REQ, RedPack100Req.REDPACK_BREAK_REQ, data, false)
end

-- 领奖励请求
function RedPack100Model:gc_RewardRedPack(dataIn)
    local bCheck = self:CacheCheckVailadate()
    if false == bCheck then
        print("RedPack100Model gc_RewardRedPack CacheCheckVailadate return false!")
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("gc_RewardRedPack userinfo is not ok")
        return
    end

    local data = {
        nUserID = user.nUserID,
        nAccumulateMoney = dataIn.nAccumulateMoney,
        nRewardNum = dataIn.nRewardNum,
        nChannelID = BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0,
    }

    AssistModel:sendRequest(RedPack100Def.GR_REDPACK100_REWARD_REQ, RedPack100Req.REDPACK_REWARD_REQ, data, false)
end

-- 红包活动界面的定时更新请求
function RedPack100Model:gc_UpdateRedPackReq()
    if user.nUserID == nil or user.nUserID < 0 then
        print("gc_UpdateRedPackReq userinfo is not ok")
        return
    end

    local data = {
        nUserID = user.nUserID,
    }

    AssistModel:sendRequest(RedPack100Def.GR_REDPACK100_ACTIVITY_UPDATE_REQ, RedPack100Req.REDPACK_UPDATE_REQ, data, false)
end


function RedPack100Model:GetRedPackInfo()
    return self._RedPackInfo
end

-- 登陆查询请求的响应
function RedPack100Model:onRedPackQueryResp(data)
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Model:onRedPackQueryResp begin")
    local info = AssistModel:convertDataToStruct(data, RedPack100Req["REDPACK_QUERY_DATA"]);
    if info.nUserID ~= user.nUserID then
        return
    end

    --分sdkname显示礼券插件
    if cc.exports.isRedPacket100Supported() then
        info.nShowMode = RedPack100Def.REDPACK_SHOW_VOCHER_MODE
    end

    local redpackPluginName = "RedPack100Plugin"
    if info.nShowMode == RedPack100Def.REDPACK_SHOW_VOCHER_MODE then
        redpackPluginName = "Vocher_RedPack100Plugin"
    end
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    if info.nRespCode ~=  RedPack100Def.QUERY_SUCCESS then
        --登录弹窗模块
        PluginProcessModel:setPluginNameInPluginList(redpackPluginName, 1)
        PluginProcessModel:setPluginReadyStatus(redpackPluginName, false)
        PluginProcessModel:startPluginProcess()    

        local rpCache = RedPack100Cache:getDataWithUserID()
        local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
        local nTodayDate = tonumber(strTodayDate)    
        if rpCache and nil == rpCache.Enable then
            if DEBUG then
                print("onRedPackQueryResp will setSache, user.nBout", user.nBout)
            end
            if user.nBout > 0 then
                rpCache.Enable = false
                RedPack100Cache:saveCacheFileByName(rpCache)
            end
        end

        if DEBUG then
            local msg = "onRedPackQueryResp  query result:  DeviceLimit!!!"
            if info.nRespCode == RedPack100Def.QUERY_DEVICE_LIMIT then
                msg = "onRedPackQueryResp QUERY_DEVICE_LIMIT!!!"
                --my.informPluginByName({pluginName='TipPlugin',params={tipString = msg, removeTime = 2}})
            elseif info.nRespCode == RedPack100Def.QUERY_ACTIVITY_END then
                msg = "onRedPackQueryResp  ACTIVITY_END!!!"
                --my.informPluginByName({pluginName='TipPlugin',params={tipString = msg, removeTime = 2}})
            elseif info.nRespCode == RedPack100Def.QUERY_DB_ERROR then
                msg = "onRedPackQueryResp  QUERY_DB NO Data!!!"
                --my.informPluginByName({pluginName='TipPlugin',params={tipString = msg, removeTime = 2}})
            elseif info.nRespCode == RedPack100Def.QUERY_CHANNEL_CLOSED then
                msg = "onRedPackQueryResp QUERY_CHANNEL_CLOSED!!!"
                --my.informPluginByName({pluginName='TipPlugin',params={tipString = msg, removeTime = 2}})
            end
            print(msg)
        end

        return
    end

    local rpCache = RedPack100Cache:getDataWithUserID()
    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)    

    if info.nRewardDate > 0 then
        -- 领取过奖励了，不用弹窗
        PluginProcessModel:setPluginReadyStatus(redpackPluginName, false)
    else
        if rpCache and rpCache.BreakDate ~= nTodayDate then
            --step1 插入登录弹窗模块
            PluginProcessModel:setPluginNameInPluginList(redpackPluginName, 1)
            PluginProcessModel:setPluginReadyStatus(redpackPluginName, true)
            PluginProcessModel:removePluginList("ActivityCenterCtrl")
            if PluginProcessModel:isNeedStart() == true then    --判断是否当天第一次登陆
                print("RedPack100Model startPluginProcessWhileTimeOut ")    
                PluginProcessModel:startPluginProcessWhileTimeOut()  
            else
                PluginProcessModel._processStatus = PluginProcessModel.PROCSEE_RUNNING
                local bResult = PluginProcessModel:continuePluginProcess() 
                print("RedPack100Model continuePluginProcess ", bResult)    
                if false == bResult then
                    -- 进入这里说明，其他窗口已经弹结束，但是红包依然没拆过，那就强制弹出一个
                    print("RedPack100Model directly informPlugin", redpackPluginName)    
                    my.informPluginByName({pluginName=redpackPluginName})
                end 
            end
        end
    end


    rpCache.Enable = true
    RedPack100Cache:saveCacheFileByName(rpCache)

    -- 更新数据
    self._RedPackInfo.nUserID           = info.nUserID
    self._RedPackInfo.nStartDate        = info.nStartDate
    self._RedPackInfo.nEndDate          = info.nEndDate
    self._RedPackInfo.nAccumulateMoney  = info.nAccumulateMoney
    self._RedPackInfo.nPlayedBout       = info.nPlayedBout
    self._RedPackInfo.nDestBout         = info.nDestBout
    self._RedPackInfo.nAvailableBout    = info.nAvailableBout
    self._RedPackInfo.nBtnStartShowDay  = info.nBtnStartShowDay
    self._RedPackInfo.nRewardDate       = info.nRewardDate
    self._RedPackInfo.szCompleteUsers   = info.szCompleteUsers
    self._RedPackInfo.nShowMode         = info.nShowMode

    self._RedPackInfo.nCurrentDay       = info.nCurrentDay
    self._RedPackInfo.nCurrentData      = info.nCurrentData
    self._RedPackInfo.nDestData         = info.nDestData

    if DEBUG then

        local nBreakDate = rpCache.BreakDate 
        if nil == nBreakDate then nBreakDate = 0 end
        local strMsg = string.format("onRedPackQueryResp success, breakDate: %d, nTodayDate:%d", nBreakDate, nTodayDate)
        print(strMsg)
        --my.informPluginByName({pluginName='TipPlugin',params={tipString = strMsg, removeTime = 2}})
    end

    -- step 2 通知活动界面，创建佰元红包
    my.scheduleOnce(function()
        self:askRefreshActivityCenter()
        self:updateRedDot()  
    end, 1)

    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Model:onRedPackQueryResp end")

    -- 通知ActivityCenter，转给RedPack100Ctrl
    self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_DATA_UPDATE })
end

-- 拆红包请求的响应
function RedPack100Model:onRedPackBreakResp(data)
    local info = AssistModel:convertDataToStruct(data, RedPack100Req["REDPACK_BREAK_DATA"]);
    if info.nUserID ~= user.nUserID then
        return
    end

    local rpCache = RedPack100Cache:getDataWithUserID()
    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate) 

    if info and info.nRespCode ~= RedPack100Def.BREAK_DB_SET_DATA_SUCCESS then
        if info.nRespCode == RedPack100Def.BREAK_DB_DATA_NOT_FOUND then
            print("onRedPackBreakResp :  DB data not found!!!")
        elseif info.nRespCode == RedPack100Def.BREAK_ALEADY_TODAY then
            print("onRedPackBreakResp  Breaked aleady today!!!")
        end
        rpCache.BreakDate = nTodayDate
        rpCache.EndDate = info.nEndDate   
        RedPack100Cache:saveCacheFileByName(rpCache)
        self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_BREAK_FAILED, value=info.nRespCode})
        return
    end

    rpCache.BreakDate = nTodayDate
    rpCache.EndDate = info.nEndDate   
    RedPack100Cache:saveCacheFileByName(rpCache)

    self._RedPackInfo.nGetMoney         = info.nGetMoney
    self._RedPackInfo.nAccumulateMoney  = info.nAccumulateMoney
    self._RedPackInfo.nAvailableBout    = info.nAvailableBout
    self._RedPackInfo.nMoneyArry        = info.nMoneyArry
    self._RedPackInfo.szUserNameArry    = info.szUserNameArry
    self._RedPackInfo.nBreakCondRet     = info.nBreakCondRet

    if info.nBreakCondRet == RedPack100Def.BREAK_COND_DAY_TASK then
        self._RedPackInfo.nCurrentData      = -1
    end

    self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_BREAK_RESP, value=info.nBreakCondRet})
    self:updateRedDot() 
end

-- 领取奖励请求的响应
function RedPack100Model:onRedPackRewardResp(data)
    local rewardRsp = AssistModel:convertDataToStruct(data, RedPack100Req["REDPACK_REWARD_DATA"]);
    if rewardRsp.nUserID ~= user.nUserID then
        return
    end

    if rewardRsp.nRespCode == RedPack100Def.REWARD_CHECK_SUCCESS then
        self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_REWARD_SUCCESS,  value = rewardRsp})
    else
        self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_REWARD_FAILED,  value = rewardRsp})
    end
    self:updateRedDot() 
end

-- 活动界面刷新 请求的响应
function RedPack100Model:onRedPackUpdateResp(data)
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Model:onRedPackUpdateResp")
    local updateRsp = AssistModel:convertDataToStruct(data, RedPack100Req["REDPACK_UPDATE_DATA"]);
    if updateRsp.nUserID ~= user.nUserID then
        return
    end
    -- 合并数据
    if updateRsp.nAvailableBout > 0 then
        self._RedPackInfo.nAvailableBout = updateRsp.nAvailableBout
    end

    local userNameArry = self._RedPackInfo.szCompleteUsers
    if updateRsp.szCompleteUsers and #updateRsp.szCompleteUsers > 0 then
        for i=1, #userNameArry - 1 do
            userNameArry[i] = userNameArry[i+1]
        end
        userNameArry[#userNameArry] = updateRsp.szCompleteUsers[1] -- 直接取第一个补在原数组的末尾
    end
    -- 通知ActivityCenter，转给RedPack100Ctrl
    self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_DATA_UPDATE })
end

-- 服务端通知活动界面，更新对局数
function RedPack100Model:onRedPackPlayedBoutUpdate(data)
    local addBoutInfo = AssistModel:convertDataToStruct(data,RedPack100Req["NTF_TABLE_PLAYER_ADD_BOUT"]);
    if addBoutInfo.nUserID ~= user.nUserID then
        return
    end
    if self._RedPackInfo then
        self._RedPackInfo.nAvailableBout = addBoutInfo.nPlayBout
    end
    self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_DATA_UPDATE })
    if true == self:NeedShowRedDot() then
        -- 直接刷新大厅红点
        local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
        activityCenterModel:addRedDotTypeCount(activityCenterModel.ACTIVITY_TYPE, RedPack100Def.ID_IN_ACTIVITY_CENTER, true)
    end
end

function RedPack100Model:askRefreshActivityCenter()
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    local pageInfo = activityCenterModel:getMatrixInfoByKey(1, RedPack100Def.ID_IN_ACTIVITY_CENTER)
    if pageInfo and not pageInfo.showByActivityReturn then
        activityCenterModel:setMatrixActivityNeedShow(RedPack100Def.ID_IN_ACTIVITY_CENTER, true)
    end
end

function RedPack100Model:NeedShowRedDot()
    local info = self._RedPackInfo
    if false == self._RedDotShow  then
        return false
    end

    if info and info.nRewardDate then
        if info.nRewardDate <= 0 and info.nAccumulateMoney > RedPack100Def.REDPACK_REWARD_NUM then
            return true
        end

        if info.nRewardDate > 0 and info.nAccumulateMoney > RedPack100Def.REDPACK_REWARD_NUM then
            return false
        end

        --每日任务完成也要显示红点
        if info.nCurrentDay <= 4 then
            if info.nCurrentData ~= -1  and  info.nDestData ~= 0 and info.nCurrentData >= info.nDestData then
                return true
            end
        end

        if self._RedPackInfo.nAvailableBout >= self._RedPackInfo.nDestBout then
            return true
        else
            return false
        end

    end
    return false
end

function RedPack100Model:updateRedDot()
    self:dispatchEvent({name = RedPack100Def.MSG_REDPACK_UPDATE_REDDOT})
end

function RedPack100Model:onCountDownZero()
    self._RedDotShow = false
    self:updateRedDot()

    self:dispatchEvent({name = RedPack100Def.MSG_REDPACK_CLOCK_ZERO})
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    activityCenterModel:setMatrixActivityNeedShow(RedPack100Def.ID_IN_ACTIVITY_CENTER, false)
end

function RedPack100Model:NotifyActivityRedPackUpdate()
    self:dispatchEvent({name=RedPack100Def.MSG_REDPACK_SIMPLE_TIXIAN})
end

function RedPack100Model:CacheCheckVailadate()
    local rpCache = RedPack100Cache:getDataWithUserID()
    if nil == rpCache.Enable then
        return true
    end

    if false == rpCache.Enable then -- 缓存控制是否发消息
        if DEBUG then
            print("CacheCheckVailadate  rpCache.Enable is false")
        end
        if user.nBout > 0 then 
            return false
        end
    else
        if rpCache.EndDate then -- 判断是否过期
            local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
            local nTodayDate = tonumber(strTodayDate)  
            if nTodayDate > 0 and rpCache.EndDate <= nTodayDate then
                if DEBUG then
                print("CacheCheckVailadate  rpCache.EndDate ", rpCache.EndDate , nTodayDate)
                end
                return  false-- 今天日期比结束日期大，不用发请求了
            end 
        end       
    end

    return true

end

-- 播放进度条动画需要的数据
function RedPack100Model:setDataForProcessAni(nPrevMoney, bPlay)
    self._RedPackInfo.nPrevMoney = nPrevMoney
    self._bPlayProcessTextAni = bPlay
end


function RedPack100Model:isNeedPlayProcessTextAni()
    if true == self._bPlayProcessTextAni then
        return true
    else
        return false
    end
end

function RedPack100Model:notifyActivityCenterSwitch()
    self:dispatchEvent({name = RedPack100Def.MSG_REDPACK_NOTIFY_SWITCH_TAB})
end

function RedPack100Model:notifyActivityCenterSwitchExchangeLottery()
    self:dispatchEvent({name = RedPack100Def.MSG_REDPACK_NOTIFY_SWITCH_EXCHANGELOTTERY_TAB})
end

return RedPack100Model