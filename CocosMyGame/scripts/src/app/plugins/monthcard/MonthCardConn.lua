local MonthCardConn= class("MonthCardConn",require('src.app.GameHall.models.BaseModel'))

local Req                   = import('src.app.plugins.monthcard.MonthCardReq')
local Def                   = import('src.app.plugins.monthcard.MonthCardDef')

local treepack                              = cc.load("treepack")
local user = mymodel('UserModel'):getInstance()
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local DeviceModel           = mymodel("DeviceModel"):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

MonthCardConn.EVENT_MAP = {
    ["monthCard_rewardAvailChanged"] = "monthCard_rewardAvailChanged"
}

function MonthCardConn:onCreate()
    self._assistResponseMap = {
        [Def.GR_STORE_MCARD_DEVID_REQ] = handler(self, self.storeMcardDeviceResp),
        [Def.GR_BUY_MCARD_RSP] = handler(self, self.buyMcardResp),
        [Def.GR_GET_MCARD_INFO_RSP] = handler(self, self.getMcardInfoResp),
        [Def.GR_GET_GAINGIFT_RSP] = handler(self, self.getGainGiftResp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
    self._MonthCardData       = nil
    self._MonthGoodsID        = nil
end
function MonthCardConn:QueryMonthCardReq()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local device = DeviceModel
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID

    local data      = {
        nUserID     = user.nUserID,
        szDeviceID     = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }

    AssistModel:sendRequest(Def.GR_GET_MCARD_INFO_REQ, Req.QURTY_MONTH_CARD, data, false)
end

function MonthCardConn:QueryMonthCardBuyInfo()
    -- 支付成功后，向服务器查询购买结果
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local device = DeviceModel
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID

    local data      = {
        nUserID     = user.nUserID,
        szDeviceID     = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }
    AssistModel:sendRequest(Def.GR_BUY_MCARD_REQ, Req.QURTY_MONTH_CARD, data, false)
end

function MonthCardConn:canUserBuyMCard()
    local mcInfo = self._MonthCardData
    if mcInfo then
        if 1 == mcInfo.nIsPay then
            return false -- 已经购买过，不能再次购买
        end
    end
    return true
end

function MonthCardConn:storeMcardDeviceResp(data)
    -- 点击充值按钮先通知chunksvr保存DeviceID，收到回应后，开始触发支付 （目的在于如果chunksvr重启，这样可以确保每次充值chunksvr都能有正确的DeviceID）
    print('storeMcardDeviceResp')
    self.Ctrl:startPayForProduct()

    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("monthCard", MonthCardConn.EVENT_MAP["monthCard_rewardAvailChanged"])
end

function MonthCardConn:buyMcardResp(data)
    print('buyMcardResp')
        -- 充值成功后，chunssvr收到后台通知，保存数据库后，再通知到该消息到此处。则一个完整的充值流程结束
        -- 如果没有收到，则客户端会开启定时查询
        local MONTH_CARD_BUY_OK = Req.NTF_MCARD_BUY_RSP
        local mcBuyInfo = treepack.unpack(data, MONTH_CARD_BUY_OK)
        local retData = {}
        retData.nEnable = 1
        retData.nUserID = mcBuyInfo.nUserID
        retData.nIsPay = mcBuyInfo.nResult
        retData.nIsGift = 0
        retData.nFirstPay = 0
        retData.nLeftDays = 30
        retData.nBuyPrice = mcBuyInfo.nBuyPrice
        self._MonthCardData = retData

        if mcBuyInfo.nResult  == 1 then
            self.Ctrl:StopShowLoadingByMsgReturn()   -- 如果及时的（10s内）收到chunksvr通知过来的 结束购买流程消息， 则提前关闭loading 动画
            player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})  
            -- my.scheduleOnce(function()

            --     local mcInfo = self._MonthCardData
            --     local mainCtrl = cc.load('MainCtrl'):getInstance()
            --     if mcInfo.nIsPay == 1 and mcInfo.nIsGift == 0 then
            --         mainCtrl:informPluginByName("WeekCard") -- 弹出领取窗口
            --     end
            -- end, 1)
        end

    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("monthCard", MonthCardConn.EVENT_MAP["monthCard_rewardAvailChanged"])
end

function MonthCardConn:getMcardInfoResp(data)
        -- 客户端登陆在mainCtrl里，会查询月卡信息。 （登陆一次查询一次）
        print('getMcardInfoResp')
        local MONTH_CARD_INFO_OK = Req.MONTH_CARD_INFO_OK
		local mcInfo = treepack.unpack(data, MONTH_CARD_INFO_OK)
        self._MonthCardData = mcInfo
        --local mainCtrl = cc.load('MainCtrl'):getInstance()
        if mcInfo then
            -- local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            if mcInfo.nEnable and mcInfo.nEnable == 1 then
                --mainCtrl:showMonthCardPanel() -- 收到月卡信息, 且月卡功能开启时, 才显示月卡按钮
                self._myStatusDataExtended["isPluginAvail"] = true --本功能可见
                if mcInfo.nIsPay == 1 and mcInfo.nIsGift == 0 then
                    -- mainCtrl:informPluginByName("MonthCard") -- 弹出领取窗口
                    --登录弹窗模块
                    -- PluginProcessModel:setPluginReadyStatus("MonthCard", true)
                    -- PluginProcessModel:startPluginProcess()
                else
                    --登录弹窗模块
                    -- PluginProcessModel:setPluginReadyStatus("MonthCard", false)
                    -- PluginProcessModel:startPluginProcess() 
                end
            else
                --登录弹窗模块
                -- PluginProcessModel:setPluginReadyStatus("MonthCard", false)
                -- PluginProcessModel:startPluginProcess()                
            end
        end
        if self.Ctrl then
            self.Ctrl:refreshView()
        end
    
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("monthCard", MonthCardConn.EVENT_MAP["monthCard_rewardAvailChanged"])
end

function MonthCardConn:getGainGiftResp(data)
    print('getGainGiftResp')
        local MONTH_CARD_GIFT_OK = Req.NTF_MCARD_GIFT_RSP
        local mcGiftInfo = treepack.unpack(data, MONTH_CARD_GIFT_OK)
        if mcGiftInfo.nResult > 0 then
            -- TODO 刷新赠银
            player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})  -- TODO 建议领取动画增加
            my.scheduleOnce(function()
                player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})  
            end, 1.5)
            self.Ctrl:showTips(self.Ctrl.MCardStrings['MCARD_GIFT_DEPOSIT_TIPS'],2)
            self.Ctrl:onGetGiftOK()      -- 领取成功后, 更新UI, 更新配置
        else
            self.Ctrl:showTipsByResultID(mcGiftInfo.nResult)
        end
        self.Ctrl:CloseMonthCardView()

    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("monthCard", MonthCardConn.EVENT_MAP["monthCard_rewardAvailChanged"])
end
--[[function MonthCardConn:onMCardDataReceived(request, data)
    if request == Def.GR_STORE_MCARD_DEVID_REQ then
        

    elseif request == Def.GR_BUY_MCARD_RSP then
        



    elseif request == Def.GR_GET_MCARD_INFO_RSP then

    elseif request == Def.GR_GET_GAINGIFT_RSP then
        
    end

    --收到购买，领取，获取信息的消息之后，都去刷新大厅的月卡红点
    -- if self._MonthCardData then
    --     cc.load('MainCtrl'):getInstance():updateMonthCardRedDot(self._MonthCardData)
    -- end
end]]--

-- function MonthCardConn:initMonthCardCtrl(ctrl)
--     if ctrl then
-- 		self._MonthCardCtrl = ctrl
--         self:listenTo(AssistModel, AssistModel.ASSIST_CONNECT_ERROR ,handler(self,self.onConnectError))
-- 	end
-- end

function MonthCardConn:SendDeviceID()
    local device = DeviceModel:getInstance()
    --local params = {szHardID = device.szHardID,szMachineID = device.szMachineID,szVolumeID=device.szVolumeID}
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID

    local data      = {
        nUserID     = user.nUserID,
        szDeviceID     = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }

    AssistModel:sendRequest(Def.GR_STORE_MCARD_DEVID_REQ, Req.QURTY_MONTH_CARD, data, false)
end

function MonthCardConn:onGetGiftDeposit()
    local device = DeviceModel:getInstance()
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID
    
    local data      = {
        nUserID     = user.nUserID,
        szDeviceID     = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }

    AssistModel:sendRequest(Def.GR_GET_GAINGIFT_REQ, Req.QURTY_MONTH_CARD, data, false)

end

function MonthCardConn:onReChargeLogReq(reqData)
    local RECHARGE_LOG_REQ_DATA = AssistReq["RECHARGE_LOG_REQ"]
    local pData = treepack.alignpack(reqdata, RECHARGE_LOG_REQ_DATA)

    if self._client then
        dump(reqData)		-- add by wuym
        self._client:sendData(Def.GR_RECHARGE_LOG_REQ, pData)
    end
end

function MonthCardConn:GetMonthCardInfo()
    if self._MonthCardData then
        return self._MonthCardData
    end
    return nil
end

function MonthCardConn:isRewardAvail(data)
    if not self._MonthCardData or not self._MonthCardData.nIsGift then
        return false
    end

    if self._MonthCardData.nIsGift == 0 and self._MonthCardData.nIsPay == 1 then
        return true
    else
        return false
    end
end

function MonthCardConn:ClearMonthCardInfo()
    self._MonthCardData = nil
end
return MonthCardConn
