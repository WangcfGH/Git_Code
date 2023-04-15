
local MonthCardView = nil
if  cc.exports.IsHejiPackage() then
    MonthCardView = require("src.app.plugins.monthcard.MonthCardHejiView")
else
    MonthCardView = require("src.app.plugins.monthcard.MonthCardView")
end
local MonthCardRecharge = require("src.app.plugins.monthcard.MonthCardRecharge")
local MonthCardConn = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()

local MonthCardCtrl = class("MonthCardCtrl", cc.load('BaseCtrl'))

local MCardStrings = cc.load('json').loader.loadFile('MonthCardStrings.json')
local AssistModel = mymodel('assist.AssistModel'):getInstance()

local event = cc.load('event')
event:create():bind(MonthCardCtrl)

MonthCardCtrl.EVENT_SHOW_FIRSTRECHARGE="Show_Month_Card"
MonthCardCtrl.EVENT_HIDE_FIRSTRECHARGE="Hide_Month_Card"
MonthCardCtrl.EVENT_PAY_OK="pay ok!"
MonthCardCtrl.EVENT_START_PAY="start_pay"

MonthCardRecharge.Ctrl   = MonthCardCtrl
MonthCardView.Ctrl  = MonthCardCtrl
MonthCardConn.Ctrl  = MonthCardCtrl

MonthCardView.Ctrl.MCardStrings = MCardStrings

--接口，游戏中需要用到
function MonthCardCtrl:createConnect(ctrl)
    -- MonthCardConn:initMonthCardCtrl(self)
    MonthCardConn:QueryMonthCardReq()
    MonthCardView.Ctrl._PayResultOK = nil
    MonthCardConn:ClearMonthCardInfo()
end

function MonthCardCtrl:onCreate( )
    self:initialListenTo()
end
function MonthCardCtrl:initialListenTo()
    self:listenTo(AssistModel, AssistModel.ASSIST_CONNECT_ERROR ,handler(self,self.onConnectError))
end
-- 领取成功后的处理
function MonthCardCtrl:onGetGiftOK()
    -- 配置修改
    local mcInfo = self:GetMonthCardInfo()
    if mcInfo then
        mcInfo.nIsGift = 1  -- 修改为已领取
    end
    -- UI修改
    MonthCardView:onGetGiftOK()
end

function MonthCardCtrl:createViewNode()
    local node = MonthCardView:create()
    if node then
        my.presetAllButton(node)
    end
    return node
end

function MonthCardCtrl:StartGetMCardRechargeconfig()
    MonthCardRecharge:StartGetMCardRechargeconfig()
end

-- 更改月卡页面 充值按钮 --  领取按钮
function MonthCardCtrl:showButtonPayOrAchieve()

end

function MonthCardCtrl:canUserBuyMCard()
    return MonthCardConn:canUserBuyMCard()
end

-- 请求月卡所有信息
function MonthCardCtrl:QueryMonthCardReq()
    return MonthCardConn:QueryMonthCardReq()
end

-- 查询月卡购买情况
function MonthCardCtrl:QueryMonthCardBuyInfo()
    return MonthCardConn:QueryMonthCardBuyInfo()
end

-- 购买第一步，发送设备ID给chunksvr
function MonthCardCtrl:SendDeviceID()
    return MonthCardConn:SendDeviceID()
end

function MonthCardCtrl:onMCardDataReceived(request, data)
    return MonthCardConn:onMCardDataReceived(request, data)
end

function MonthCardCtrl:startPayForProduct()
    MonthCardView:dispatchEvent({name = MonthCardView.EVENT_PAY})
    MonthCardCtrl:dispatchEvent({name = MonthCardCtrl.EVENT_START_PAY })
end
    
function MonthCardCtrl:isFirstPay()
    --[[if MonthCardConn._MonthCardData and MonthCardConn._MonthCardData.nFirstPay == 1 then 
        return true
    end]]--
    -- 日期2018年11月23日 取消了首充
    return false
end

function MonthCardCtrl:onGetGiftDeposit()
    return MonthCardConn:onGetGiftDeposit()
end

-- 获取弹出月卡界面的按钮 有效状态
function MonthCardCtrl:getBtnGetVailed()
    return MonthCardCtrl._BtnGetVaild
end

function MonthCardCtrl:CloseMonthCardView()
    if nil == MonthCardView.layer then
        print("~~~MonthCardView.layer is nil ,so can not excute removeSelf()~~~~~")
    else
        MonthCardView.layer:removeSelf()
        MonthCardView.layer = nil
    end
end
    
function MonthCardCtrl:enablePayButton(enable)
    MonthCardView:enablePayButton(enable)
end

function MonthCardCtrl:showTipsByResultID(nResult)
    if nResult == -1 then
        MonthCardCtrl:showTips(MCardStrings['MCARD_AREADY_ACHIEVE'])    -- 已经领取提示
    elseif nResult == -2 then
        MonthCardCtrl:showTips(MCardStrings['MCARD_AREADY_OVER'])       -- 月卡到期提示
    elseif nResult == -3 then
        MonthCardCtrl:showTips(MCardStrings['MCARD_GIFT_DEPOSIT_FAILED'])   -- 月卡领取赠送银失败提示（soap调用失败）
    else
        MonthCardCtrl:showTips(MCardStrings['MCARD_DEAFULT'])   -- 默认提示 （领取其他异常）
    end
end

function MonthCardCtrl:showTips(showText, timeSec)
    local defaultSec = 1
    if timeSec ~= nil then
        defaultSec = timeSec
    end

    my.informPluginByName({pluginName='ToastPlugin',params={tipString= showText,removeTime=defaultSec}})
end


function MonthCardCtrl:StopShowLoadingByMsgReturn()
   if(self.stopShowLoad ~= nil)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.stopShowLoad)
        self.stopShowLoad = nil
    end

    --cc.exports.forbiddenOnkeyback=false
    my.stopProcessing()
    local node = cc.Director:getInstance():getRunningScene():getChildByName("MCARD_PAY_LOADING")
    if(node)then
        node:removeSelf()
    end

    -- MonthCardCtrl:CloseMonthCardView()
    self:refreshView()

end

function MonthCardCtrl:StopShowLoading()
    if(self.stopShowLoad ~= nil)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.stopShowLoad)
        self.stopShowLoad = nil
    end
    my.stopProcessing()

    --cc.exports.forbiddenOnkeyback=false
    local node = cc.Director:getInstance():getRunningScene():getChildByName("MCARD_PAY_LOADING")
    if(node)then
        node:removeSelf()
    end

    MonthCardCtrl:CloseMonthCardView()
    MonthCardCtrl:showTips(MCardStrings['MCARD_PAY_SUCCESS_BUT_NO_CHUNK_MSG'], 2) -- 购买默认银成功，赠送银失败（没有等到chunksvr的通知）
end

function MonthCardCtrl:OnGetMonthCardBuyInfo()
    self:QueryMonthCardBuyInfo()
    if not self.QueryBuyInfoCount then
        self.QueryBuyInfoCount = 1
    else
        self.QueryBuyInfoCount = self.QueryBuyInfoCount + 1
        if self.QueryBuyInfoCount >= 5 then
            self:StopShowLoading()
        end
    end
end

function MonthCardCtrl:StartPayLoading()
    --[[local forbiddenScene = cc.CSLoader:createNode( "res/hallcocosstudio/hallcommon/loading.csb" )
    forbiddenScene:setName("MCARD_PAY_LOADING")
    cc.Director:getInstance():getRunningScene():addChild(forbiddenScene,1000)
    ccui.Helper:doLayout(forbiddenScene)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()
    local startX = visibleSize.width/(2)
    local startY = visibleSize.height/2 + origin.y
    forbiddenScene:getChildByName("Panel_Shade"):setContentSize(visibleSize)
    forbiddenScene:setPosition(startX,startY)
    forbiddenScene:setAnchorPoint(0.5,0.5)

    ccui.Helper:doLayout(forbiddenScene)

    local action = cc.CSLoader:createTimeline('res/hallcocosstudio/hallcommon/loading.csb')
    forbiddenScene:runAction(action)
    action:gotoFrameAndPlay(0, true)

    cc.exports.forbiddenOnkeyback=true]]--

    my.startProcessing(nil, 2)  --loading 动画

    if nil == self.stopShowLoad then
        self.stopShowLoad = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(MonthCardCtrl,MonthCardCtrl.OnGetMonthCardBuyInfo), 2, false)
    end
    
end


-- 充值支付事件绑定
MonthCardView:addEventListener(MonthCardView.EVENT_PAY,MonthCardRecharge.PayForProduct)
-- 领取赠银事件绑定
MonthCardView:addEventListener(MonthCardView.EVENT_ACHIEVE,MonthCardCtrl.onGetGiftDeposit)
MonthCardRecharge:addEventListener(MonthCardRecharge.EVENT_PURCHASE_SUCCEEDED,function()
    local config = cc.exports.GetShopConfig()
    local showText
    if(config["Trans_type"]==0)then
        showText = config["BuyDeporsiteInboxOK"]
    elseif(config["Trans_type"]==2)then
        showText = config["BuyDeporsiteOK"]
    else
        showText = config["BuyScoreOK"]
    end
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if userPlugin:getUsingSDKName() == "uconline" then
        showText = config["UConlineAccountOK"]
    end

    my.informPluginByName({pluginName='TipPlugin',params={tipString=showText,removeTime=3}})
    MonthCardCtrl:CloseMonthCardView()
    printf("MonthCardCtrl.event_success")
   
    MonthCardCtrl:dispatchEvent({name = MonthCardCtrl.EVENT_PAY_OK })
end)


function  MonthCardCtrl:GetCurrentDeviceType()
    if MonthCardRecharge.CurDeviceType then
        return MonthCardRecharge.CurDeviceType 
    end
    return "andriod"
end

function MonthCardCtrl:GetMCardRechargeItemsInfo(index)
    return MonthCardRecharge:GetMCardRechargeItemsInfo(index)
end

function MonthCardCtrl:onReChargeLogReq(reqData)
    return MonthCardConn:onReChargeLogReq(reqData)
end

function MonthCardCtrl:GetMonthCardInfo()
    return MonthCardConn:GetMonthCardInfo()
end

function MonthCardCtrl:onConnectError( )
    self:CloseMonthCardView()
end

function MonthCardCtrl:onKeyBack()
    -- local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    -- PluginProcessModel:stopPluginProcess()
    MonthCardCtrl.super.onKeyBack(self)
end

--用于适配周卡
function MonthCardCtrl:showView(viewNode)
    MonthCardView:showView(viewNode)
end

function MonthCardCtrl:refreshView()
    if not tolua.isnull(MonthCardView.layer) and not tolua.isnull(MonthCardView.showPanel) then
        local name = MonthCardView.showPanel:getName()
        print("MonthCardCtrl:refreshView---- ", name)

        local PAY_RESULT = {
            NOT_PAY             = 0,
            HAS_PAY             = 1
        }

        local mcInfo = MonthCardConn:GetMonthCardInfo()
        local weekCardCtrl = import("src.app.plugins.WeekCard.WeekCardCtrl"):getInstance()
        if name == "Panel_Month" and mcInfo and mcInfo.nIsPay ~= PAY_RESULT.NOT_PAY then
            MonthCardView.showPanel:setVisible(false)
            MonthCardView.showPanel=nil
            self:showView(weekCardCtrl._viewNode)
        end
    end
end


return MonthCardCtrl