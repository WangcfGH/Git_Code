local listener
local MonthCardHejiView = class('MonthCard')
local windowSize = cc.Director:getInstance():getWinSize()
local MonthCardConn = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()

MonthCardHejiView.EVENT_PAY = "button_pay underpress!"
MonthCardHejiView.EVENT_ACHIEVE = "button_achieve underpress!"

local event = cc.load('event')
event:create():bind(MonthCardHejiView)

MonthCardHejiView.layer         = nil
local panelAnimation             = nil
local btnGet                = nil
local btnClose              = nil
local textGift              = nil
local panel_shade           = nil

local MAX_PLAYERS_PER_DEVICE = 300000  -- 每台设备最多允许同时激活的月卡用户数量

local MCARD_STATUS = {
    UNKNOWN_STATUS          = -1,
    FIRST_PAY               = 0,
    COMMON_PAY              = 1,
    DURING_GIFT             = 2,
    END_GIFT                = 3
}

local PAY_RESULT = {
    NOT_PAY             = 0,
    HAS_PAY             = 1
}

local GIFT_RESULT = {
    NOT_ACHIEVE             = 0,
    HAS_ACHIEVE            = 1
}

local PAY_PRICE = {
    OLD_NOMAL_FIRST_PRICE            = 3,
    OLD_NOMAL_SECOND_PRICE           = 6,
    NEW_NOMAL_SECOND_PRICE           = 12,
    OLD_HEJI_FIRST_PRICE             = 20,
    OLD_HEJI_SECOND_PRICE            = 40,
    NEW_HEJI_SECOND_PRICE            = 28
}
cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/MonthCard_Img.plist")
function MonthCardHejiView:create()
    if not tolua.isnull(MonthCardHejiView.layer) then
        return MonthCardHejiView.layer 
    end
    listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(handler(MonthCardHejiView,MonthCardHejiView.onKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    if mcInfo == nil or mcInfo == {} then
        print("[Error] MonthCard, MonthCardConn._MonthCardData is nil or {}!!!!")
        MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_GET_DATA_FAILED'])       
        return MonthCardHejiView.layer 
    end

    if MonthCardHejiView.Ctrl._PayResultOK ~= nil then
       if MonthCardHejiView.Ctrl._PayResultOK == true and mcInfo.nIsPay == 0 then
            -- 已经支付成功，但是
            MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_PAY_SUCCESS_BUT_NO_CHUNK_MSG'])           
            return MonthCardHejiView.layer 
       end 
    end

    local resPath = nil
    local fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_3000_DEPOSIT']
    local fntBuyText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_12W_DEPOSIT']
    
    local mcStatus = MCARD_STATUS.UNKNOWN_STATUS;                    -- 当前月卡状态, 0, 第一次购; 1, 第二次购; 2, 领取奖励

    -- 根据月卡购买信息决定弹窗类型, 或者不弹
    if mcInfo.nIsPay == PAY_RESULT.NOT_PAY then              -- 未购买月卡
        -- 设备购买次数限制, 配置为主, 无配置使用默认宏
        local maxPlayers = MAX_PLAYERS_PER_DEVICE
        if mcInfo.nExistPlayers >= maxPlayers then
            MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_TOO_MANY_PLAYERS_ONE_DEVICE'])
            return MonthCardHejiView.layer 
        end
        -- 2018年11月22日 去掉首次购买半价， 且合集包28元购买得银12万，每日领取3000两
        resPath     = "res/hallcocosstudio/monthcard/layer_monthcard_new.csb"
        mcStatus    = MCARD_STATUS.COMMON_PAY   

    else
        mcStatus        = MCARD_STATUS.DURING_GIFT                 -- 领取月卡奖励
        resPath         = "res/hallcocosstudio/monthcard/layer_monthcard_gift.csb"
        local MCInfo = MonthCardHejiView.Ctrl:GetMonthCardInfo()
        if MCInfo and MCInfo.nBuyPrice then
            if MCInfo.nBuyPrice == PAY_PRICE.OLD_NOMAL_SECOND_PRICE or  MCInfo.nBuyPrice == PAY_PRICE.OLD_NOMAL_FIRST_PRICE then
                -- 如果拿到的价格小于等于6元，说明是老包买的月卡
                fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_1500_DEPOSIT']
            elseif MCInfo.nBuyPrice == PAY_PRICE.OLD_HEJI_SECOND_PRICE or MCInfo.nBuyPrice == PAY_PRICE.OLD_HEJI_FIRST_PRICE then
                -- 价格等于20 或者40，说明以前是老合集包购买月卡
                fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_3300_DEPOSIT']
            end 
        end
    end
       
    local exist = cc.FileUtils:getInstance():isFileExist(resPath)

    MonthCardHejiView.layer = cc.CSLoader:createNode(resPath)
    MonthCardHejiView.layer:setContentSize(windowSize)
    ccui.Helper:doLayout(MonthCardHejiView.layer) --自适应位置和大小

    -- 处理三个界面公共部分
    panelAnimation           = MonthCardHejiView.layer:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
    btnGet              = panelAnimation:getChildByName("Btn_Get")
    btnClose            = panelAnimation:getChildByName("Btn_Close")

    btnClose:addClickEventListener(function()
        self:playEffectOnPress()
        MonthCardHejiView.Ctrl:CloseMonthCardView()
    end)

    -- 不同部分
    if mcStatus == MCARD_STATUS.DURING_GIFT then                   -- 领取月卡奖励
        textGift = panelAnimation:getChildByName("Img_Ribbon"):getChildByName("Text_Gift")
        if textGift then
            textGift:setString("活动剩余天数: "..(mcInfo.nLeftDays - mcInfo.nIsGift).."天") -- 若已领取, 则显示减一天
        end
        if btnGet then
            btnGet:addClickEventListener(function()
                self:_onClickGetRewardDeposit()
            end)
            self:enableGiftBtn(mcInfo.nIsGift == GIFT_RESULT.NOT_ACHIEVE)
        end

        -- 合集包 领取设置每日领取银两
        local panel_Silver = panelAnimation:getChildByName("Panel_Silver")
        local fnt_Silver = panel_Silver:getChildByName("Text_Count")
        fnt_Silver:setString(fntGiftText)
    else
        if btnGet then
            btnGet:addClickEventListener(function()
                self:_onClickPay()
            end)
            -- 合集包，设置28元购买按钮
            local fntBuyButtonText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_28RMB_TO_BUY']
            local fnt_PriceBuy = btnGet:getChildByName("Text_Desc")            
            fnt_PriceBuy:setString(fntBuyButtonText)
        end

        -- 合集包 设置28元图片
        local panel_Title = panelAnimation:getChildByName("Img_Ribbon")
        local fntPrice = panel_Title:getChildByName("Fnt_Price")
        fntPrice:setString("28")

        -- 合集包 设置12万两银子
        local panel_Silver1 = panelAnimation:getChildByName("Panel_Silver1")
        local fnt_Silver = panel_Silver1:getChildByName("Text_Count")
        fnt_Silver:setString(fntBuyText)

    end

    MonthCardHejiView.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, MonthCardHejiView.layer)

    panel_shade         = MonthCardHejiView.layer:getChildByName("Panel_Shade")
    if Panel_shade then
        Panel_shade:onTouch(function(e)
            if(e.name=='began')then
                self:playEffectOnPress()
            elseif(e.name=='ended')then
                --MonthCardHejiView.layer:removeSelf()
                MonthCardHejiView.Ctrl:CloseMonthCardView()
            elseif (e.name=='cancelled')then
            elseif(e.name=='moved')then
                printf("~~~moved~~~~~x=%d y=%d",e.x,e.y)
            end
        end)
    end

    if(MonthCardHejiView.layer.registerScriptHandler)then
        MonthCardHejiView.layer:registerScriptHandler(function(event)
            if event == "enter" then
                my.autoBlockKeyboardListener(listener)
                self:playPopOutAni(resPath)    -- 播放弹出动画
            elseif event == 'exit' then
                my.removeKeyboardListener(listener)
            elseif event == "enterTransitionFinish" then
            end
        end)
    end

    return MonthCardHejiView.layer
end

function MonthCardHejiView:_onClickPay()
    self:playEffectOnPress()
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    if mcInfo.nIsPay == PAY_RESULT.HAS_PAY then
		MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_PAY_CLICK_TOO_FREQ'])
		return
	end
	if self._BtnGetVaild == false then
		print("  +++++++++++++++ click button Pay too frequently!!!")
		return
	end
	self._BtnGetVaild = false
	my.scheduleOnce(function()
		self._BtnGetVaild = true
	end, 5)
	MonthCardHejiView.Ctrl:SendDeviceID()
	--支付流程： send GR_STORE_MCARD_DEVID_REQ 给chunksvr， 
	-- 在MonthCardConn:onMCardDataReceived 收到通知后 再分发EVENT_PAY 事件触发购买
	--MonthCardHejiView:dispatchEvent({name = MonthCardHejiView.EVENT_PAY}) -- 在收到GR_STORE_MCARD_DEVID_REQ的响应时，触发购买
end

function MonthCardHejiView:_onClickGetRewardDeposit()
    self:playEffectOnPress()
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    if mcInfo.nIsGift == GIFT_RESULT.HAS_ACHIEVE then
        MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_ACHIEVE_CLICK_TOO_FREQ'])
        return
    end
    if self._BtnGetVaild == false then
        print("  +++++++++++++++ click button achieve too frequently!!!")
        return
    end
    self._BtnGetVaild = false
    my.scheduleOnce(function()
        self._BtnGetVaild = true
    end, 3)

    MonthCardHejiView.Ctrl.onGetGiftDeposit()
end

function MonthCardHejiView:onKeyboardReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACK then
        print('~~on key back clicked~~')
        self:playEffectOnPress()
        MonthCardHejiView.Ctrl:CloseMonthCardView() --插件是“BlockLayer”，则调用该方法
    end
end

function MonthCardHejiView:playEffectOnPress()
    my.playClickBtnSound()
end

function MonthCardHejiView:enablePayButton(enable)
    if btnGet then
        btnGet:setEnabled(false)
        local fnt = btnGet:getChildByName("Text_Desc")     
        fnt:setColor(cc.c3b(58,58,58)) 
    end

end

function MonthCardHejiView:onGetGiftOK()
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    -- 剩余天数修改
    if textGift and mcInfo then
        textGift:setString("活动剩余天数: "..(mcInfo.nLeftDays - mcInfo.nIsGift).."天")
    end
    -- 禁用按钮
    self:enableGiftBtn(false)
end

function MonthCardHejiView:enableGiftBtn(bEnable)
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    if btnGet and  mcInfo and mcInfo.nIsPay == PAY_RESULT.HAS_PAY then
        btnGet:setBright(bEnable)
        btnGet:setEnabled(bEnable)
        if bEnable then
            local fnt = btnGet:getChildByName("Text_Desc")     
            fnt:setColor(cc.c3b(41,107,8)) 
        else
            local fnt = btnGet:getChildByName("Text_Desc")     
            fnt:setColor(cc.c3b(58,58,58)) 
        end
    end 
end

function MonthCardHejiView:playPopOutAni(resPath)
    panelAnimation           = MonthCardHejiView.layer:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
    panelAnimation:setScale(0.6)
    panelAnimation:setOpacity(255)
    local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
    local scaleTo2 = cc.ScaleTo:create(0.09, 1)

    -- MonthCardView.layer:runAction(timeline)
    local callback = cc.CallFunc:create(function ()
        local timeline = cc.CSLoader:createTimeline(resPath)
        timeline:play("animation_show", true)
    end)

    local ani = cc.Sequence:create(scaleTo1, scaleTo2,callback,nil)
    panelAnimation:runAction(ani)
end

--用于适配周卡
function MonthCardHejiView:showView(viewNode)
    if not tolua.isnull(MonthCardHejiView.layer) and not tolua.isnull(MonthCardHejiView.showPanel) then
        MonthCardHejiView.showPanel:setVisible(true)
        return MonthCardHejiView.layer 
    end
    
    local mcInfo = MonthCardConn:GetMonthCardInfo()
    if mcInfo == nil or mcInfo == {} then
        print("[Error] MonthCard, MonthCardConn._MonthCardData is nil or {}!!!!")
        MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_GET_DATA_FAILED'])       
        return MonthCardHejiView.layer 
    end

    if MonthCardHejiView.Ctrl._PayResultOK ~= nil then
       if MonthCardHejiView.Ctrl._PayResultOK == true and mcInfo.nIsPay == 0 then
            -- 已经支付成功，但是
            MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_PAY_SUCCESS_BUT_NO_CHUNK_MSG'])           
            return MonthCardHejiView.layer 
       end 
    end

    local resPath = nil
    local fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_3000_DEPOSIT']
    local fntBuyText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_12W_DEPOSIT']
    
    local mcStatus = MCARD_STATUS.UNKNOWN_STATUS;                    -- 当前月卡状态, 0, 第一次购; 1, 第二次购; 2, 领取奖励

    -- 根据月卡购买信息决定弹窗类型, 或者不弹
    if mcInfo.nIsPay == PAY_RESULT.NOT_PAY then              -- 未购买月卡
        -- 设备购买次数限制, 配置为主, 无配置使用默认宏
        local maxPlayers = MAX_PLAYERS_PER_DEVICE
        if mcInfo.nExistPlayers >= maxPlayers then
            MonthCardHejiView.Ctrl:showTips(MonthCardHejiView.Ctrl.MCardStrings['MCARD_TOO_MANY_PLAYERS_ONE_DEVICE'])
            return MonthCardHejiView.layer 
        end
        -- 2018年11月22日 去掉首次购买半价， 且合集包28元购买得银12万，每日领取3000两
        resPath     = "Panel_Month"
        mcStatus    = MCARD_STATUS.COMMON_PAY   

    else
        mcStatus        = MCARD_STATUS.DURING_GIFT                 -- 领取月卡奖励
        resPath         = "Panel_MonthDaily"
        local MCInfo = MonthCardHejiView.Ctrl:GetMonthCardInfo()
        if MCInfo and MCInfo.nBuyPrice then
            if MCInfo.nBuyPrice == PAY_PRICE.OLD_NOMAL_SECOND_PRICE or  MCInfo.nBuyPrice == PAY_PRICE.OLD_NOMAL_FIRST_PRICE then
                -- 如果拿到的价格小于等于6元，说明是老包买的月卡
                fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_1500_DEPOSIT']
            elseif MCInfo.nBuyPrice == PAY_PRICE.OLD_HEJI_SECOND_PRICE or MCInfo.nBuyPrice == PAY_PRICE.OLD_HEJI_FIRST_PRICE then
                -- 价格等于20 或者40，说明以前是老合集包购买月卡
                fntGiftText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_GIFT_3300_DEPOSIT']
            end 
        end
    end

    MonthCardHejiView.layer = viewNode:getRealNode()
    MonthCardHejiView.layer:setContentSize(windowSize)
    ccui.Helper:doLayout(MonthCardHejiView.layer) --自适应位置和大小

    -- 处理三个界面公共部分
    panelAnimation = MonthCardHejiView.layer:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
    local panel = panelAnimation:getChildByName(resPath)
    MonthCardHejiView.showPanel = panel
    panel:setVisible(true)
    btnGet = panel:getChildByName("Btn_Get")

    -- 不同部分
    if mcStatus == MCARD_STATUS.DURING_GIFT then                   -- 领取月卡奖励
        textGift = panel:getChildByName("Img_Ribbon"):getChildByName("Text_Gift")
        if textGift then
            textGift:setString("活动剩余天数: "..(mcInfo.nLeftDays - mcInfo.nIsGift).."天") -- 若已领取, 则显示减一天
        end
        if btnGet then
            btnGet:addClickEventListener(function()
                self:_onClickGetRewardDeposit()
            end)
            self:enableGiftBtn(mcInfo.nIsGift == GIFT_RESULT.NOT_ACHIEVE)
        end

        -- 合集包 领取设置每日领取银两
        local panel_Silver = panel:getChildByName("Panel_Silver")
        local fnt_Silver = panel_Silver:getChildByName("Text_Count")
        fnt_Silver:setString(fntGiftText)
    else
        if btnGet then
            btnGet:addClickEventListener(function()
                self:_onClickPay()
            end)
            -- 合集包，设置28元购买按钮
            local fntBuyButtonText = MonthCardHejiView.Ctrl.MCardStrings['MCARD_28RMB_TO_BUY']
            local fnt_PriceBuy = btnGet:getChildByName("Text_Desc")            
            fnt_PriceBuy:setString(fntBuyButtonText)
        end

        -- 合集包 设置28元图片
        local panel_Title = panel:getChildByName("Img_Ribbon")
        local fntPrice = panel_Title:getChildByName("Fnt_Price")
        fntPrice:setString("28")

        -- 合集包 设置12万两银子
        local panel_Silver1 = panel:getChildByName("Panel_Silver1")
        local fnt_Silver = panel_Silver1:getChildByName("Text_Count")
        fnt_Silver:setString(fntBuyText)

    end
end

return MonthCardHejiView

