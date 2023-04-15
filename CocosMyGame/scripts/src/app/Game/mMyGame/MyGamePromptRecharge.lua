
local MyGamePromptRecharge = class("MyGamePromptRecharge", ccui.Layout)
my.setmethods(MyGamePromptRecharge, cc.load('coms').PropertyBinder)

local ShopModel = mymodel("ShopModel"):getInstance()
local LimitTimeGiftModel = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance()

function MyGamePromptRecharge:ctor(gameController, bFirst, RechargeData, HallOrGame, isLimitTimeGift, isShowJumpBtn, targetRoomInfo)
    if not gameController then printError("gameController is nil!!!") return end
    print("isLimitTimeGift", isLimitTimeGift)
    self._gameController  = gameController
    self._HallOrGame      = HallOrGame        --大厅还是游戏中，true 是大厅
    self._PromptPanel     = nil
    self._bFirst          = bFirst
    self._RechargeData    = RechargeData
    self._isLimitTimeGift = isLimitTimeGift
    self._isShowJumpBtn   = isShowJumpBtn
    self._targetRoomInfo  = targetRoomInfo
    if self._targetRoomInfo == nil then
        self._targetRoomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    end
    
    if self.onCreate then self:onCreate() end
end

function MyGamePromptRecharge:onCreate()
    self:enableNodeEvents()
    self:init()
    self:listenTo(LimitTimeGiftModel, LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"], handler(self,self.refreshOnLimitTimeUpdatedOfLimitTimeGift))
end

function MyGamePromptRecharge:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_Recharge.csb"
    if self._bFirst   then
        csbPath = "res/GameCocosStudio/csb/Node_Prompt_FirstRecharge.csb"
    end
    if self._isLimitTimeGift then
        csbPath = "res/hallcocosstudio/shop/node_limitTimeGift.csb"
    end
    
    self._PromptPanel = cc.CSLoader:createNode(csbPath)
    if self._PromptPanel then
        self:addChild(self._PromptPanel)
        if self._isLimitTimeGift then
            SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel_shade"))
        else
            SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel"))
        end
        my.presetAllButton(self._PromptPanel)

        local panelPrompt = self._PromptPanel:getChildByName("Panel_Recharge")
        if self._bFirst   then
            panelPrompt = self._PromptPanel:getChildByName("Panel_FirstRecharge")
        end
        if self._isLimitTimeGift then
            local action = cc.CSLoader:createTimeline(csbPath)
            if(action and self._PromptPanel) then
                self._PromptPanel:runAction(action)
                action:play("open",true)
                self._PromptPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function() action:play("round",true)end)))
            end
            panelPrompt = self._PromptPanel:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
            local Panel_shade = self._PromptPanel:getChildByName("Panel_shade")
            local function onClose()
                self:onClose()
            end
            Panel_shade:addClickEventListener(onClose)
        end
        if panelPrompt then
            if not tolua.isnull(panelPrompt) then
				panelPrompt:setVisible(true)
				panelPrompt:setScale(0.6)
				panelPrompt:setOpacity(255)
				local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
				local scaleTo2 = cc.ScaleTo:create(0.09, 1)

				local ani = cc.Sequence:create(scaleTo1, scaleTo2)
				panelPrompt:runAction(ani)
			end

            local closeBtn = panelPrompt:getChildByName("Btn_Close")
            local function onClose()
                self:onClose()
            end
            closeBtn:addClickEventListener(onClose)

            local PurchaseBtn = panelPrompt:getChildByName("Btn_Purchase")
            local function onPurchase()
                self:onPurchase()
            end
            PurchaseBtn:addClickEventListener(onPurchase)

            if  self._isLimitTimeGift then
                local button_pay = panelPrompt:getChildByName("Btn_Purchase")
                local button_exit = panelPrompt:getChildByName("Btn_Close")
                local priceIcon = panelPrompt:getChildByName("priceIcon")
                local timeLab = panelPrompt:getChildByName("timeLab")
                local numLab = panelPrompt:getChildByName("numLab")
                
                if next(self._RechargeData) ~= nil then
                    --self._countdown = cc.exports.limitTimeGiftInfo.nCountdown
                    --discount:setTexture("hallcocosstudio/images/plist/limitTimeGift_Img/Img_"..self._RechargeData['Icon_DesplayNo'].."zhe.png")
                    if  cc.exports.IsHejiPackage() then
                        --合集
                        priceIcon:setSpriteFrame("hallcocosstudio/images/plist/limitTimeGift_Img/title_"..self._RechargeData["itemData"]['price'].."yuanHJ.png")
                        local discount = panelPrompt:getChildByName("discountte")
                        discount:setVisible(true)
                    else
                        priceIcon:setSpriteFrame("hallcocosstudio/images/plist/limitTimeGift_Img/title_"..self._RechargeData["itemData"]['price'].."yuan.png")
                        local discount = panelPrompt:getChildByName("discount"..self._RechargeData["itemData"]['icondesplayno'])
                        discount:setVisible(true)
                    end
                    --timeLab:setString(LimitTimeGiftModel:getTime(self._countdown))
                    --self._LimitTimeGiftTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1,false)
                    local num = self._RechargeData["itemData"]['productnum'] + self._RechargeData["itemData"]['firstpay_rewardnum']
                    numLab:setString(num)  
                end
            else
                local money_price = {2,6,10,12,18,20,30,50,100}
                for i, v in pairs(money_price) do
                    local moneyicon = nil
                    if self._bFirst  then
                        moneyicon = panelPrompt:getChildByName("Panel_Box1"):getChildByName("Img_icon_"..v)
                    else
                        moneyicon = panelPrompt:getChildByName("Panel_Box"):getChildByName("Img_icon_"..v)
                    end
                    if moneyicon then
                        moneyicon:setVisible(false)
                    end
                end
                
                local Img_TwoYuan, Img_SixYuan, Img_TenYuan, Img_TwentyYuan, Text_Silver  = nil, nil, nil, nil, nil
                if self._bFirst  then
                    Text_Silver = panelPrompt:getChildByName("Panel_Box1"):getChildByName("Text_Silver")

                    local Text_Silver2 = panelPrompt:getChildByName("Panel_Box2"):getChildByName("Text_Silver")
                    Text_Silver2:setString(tostring(self._RechargeData["itemData"]['firstpay_rewardnum'])..GamePublicInterface:getGameStringToUTF8ByKey("G_GAME_PROMPT_DEPOSIT"))
                    
                    local moneyicon = panelPrompt:getChildByName("Panel_Box1"):getChildByName("Img_icon_"..self._RechargeData["itemData"]['price'])
                    if moneyicon then
                        moneyicon:setVisible(true)
                    end
                else
                    --[[local word = panelPrompt:getChildByName("Text_PromptWord")
                    if self._RechargeData.lackDeposit == nil then
                        self._RechargeData.lackDeposit = 500
                    end
                    word:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_RECHAGRE_TIP"), self._RechargeData.lackDeposit)) ]]
                    
                    Text_Silver = panelPrompt:getChildByName("Panel_Box"):getChildByName("Text_Silver")

                    local moneyicon = panelPrompt:getChildByName("Panel_Box"):getChildByName("Img_icon_"..self._RechargeData["itemData"]['price'])
                    if moneyicon then
                        moneyicon:setVisible(true)
                    end
                end
                Text_Silver:setString(tostring(self._RechargeData["itemData"]['productnum'])..GamePublicInterface:getGameStringToUTF8ByKey("G_GAME_PROMPT_DEPOSIT"))
                local btnJump = panelPrompt:getChildByName("Btn_Jump")
                if btnJump then
                    btnJump:setVisible(false)
                    if not self._HallOrGame then
                        btnJump:onTouch(function(e)
                            if e.name == 'ended' then        
                                self._gameController:playBtnPressedEffect()
                                self._gameController._gotoHighRoom = true
                                self._gameController._baseGameConnect:gc_LeaveGame()
                                self:removeFromParentAndCleanup()
                            end
                        end)
                        if self._isShowJumpBtn then
                            btnJump:setVisible(true)
                        else
                            btnJump:setVisible(false)
                        end
                    end
                end
            end
        end
    end
    if not self._isLimitTimeGift then
        -- local action = cc.CSLoader:createTimeline(csbPath)
        -- if action then
        --     self._PromptPanel:runAction(action)
        --     action:gotoFrameAndPlay(1,10 , false)
        -- end
    end
end

--解决切后台时间显示问题
--[[function MyGamePromptRecharge:updateTime()
    self._countdown = cc.exports.limitTimeGiftInfo.nCountdown
end]]--

--[[function MyGamePromptRecharge:getTime(countdown)
    local hours = math.modf(countdown/3600)
    local mins = math.modf((countdown - hours*3600)/60)
    local secs = countdown - hours*3600 - mins*60
    if tonumber(hours) < 10 then
        hours = "0"..hours
    end
    if tonumber(mins) < 10 then
        mins = "0"..mins
    end
    if tonumber(secs) < 10 then
        secs = "0"..secs
    end
    local time = hours..":"..mins..":"..secs
    return time
end]]--

--[[function MyGamePromptRecharge:update(delta)
    if self._countdown and self._countdown > 0 then
        self._countdown = self._countdown - 1
        if self._PromptPanel then
            self._PromptPanel:getChildByName("Panel_main"):getChildByName("timeLab"):setString(self:getTime(self._countdown))
        else
            if self._LimitTimeGiftTimer then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._LimitTimeGiftTimer)
                self._LimitTimeGiftTimer = nil
            end
        end
        
    else
        if self._LimitTimeGiftTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._LimitTimeGiftTimer)
            self:removeFromParentAndCleanup()
            self._LimitTimeGiftTimer = nil
        end
    end

end]]--

function MyGamePromptRecharge:onEnter()
    -- 埋点
    local isInGame = false
    local roomid = 0
    if my.isInGame() then 
        isInGame = true
        local PublicInterface = cc.exports.PUBLIC_INTERFACE
        if PublicInterface then
            local RoomInfo = PublicInterface.GetCurrentRoomInfo()
            if RoomInfo then
                roomid = RoomInfo.nRoomID
            end
        end
    end
    local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()
    ComEvtTrkingModel:sendQuickRechargeWakeupEvent(roomid, isInGame)
end

function MyGamePromptRecharge:refreshOnLimitTimeUpdatedOfLimitTimeGift()     
    if not self._PromptPanel or not self._isLimitTimeGift then return end
    local labelTime = self._PromptPanel:getChildByName("Panel_Main"):getChildByName("Panel_Animation"):getChildByName("timeLab")
    labelTime:setString(LimitTimeGiftModel:getTime(cc.exports.limitTimeGiftInfo.nCountdown))
end

function MyGamePromptRecharge:onClose()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
    end
    --[[if self._LimitTimeGiftTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._LimitTimeGiftTimer)
        self._LimitTimeGiftTimer = nil
    end]]--
    self:removeEventHosts()
    self:removeFromParentAndCleanup()
    -- 埋点
    local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()
    ComEvtTrkingModel:sendQuickRechargeClickCloseBtn() 
end

function MyGamePromptRecharge:onPurchase()
    local roomInfo = self._targetRoomInfo
    local utf8Name =  roomInfo.szRoomName     -- 房间名称
    local  minDeposit = roomInfo.nMinDeposit        -- 房间下限
    local function getReChargeSceneID(name)
        local Scene = cc.exports.ReChargeScene
        if name == "大厅" then
            return Scene.RECHARGE_SCENE_IN_HALL
        elseif name == "新手房" then
            return Scene.RECHARGE_SCENE_IN_LEVEL0
        elseif name == "初级房" then
            return Scene.RECHARGE_SCENE_IN_LEVEL1
        elseif name == "中级房" then
            return Scene.RECHARGE_SCENE_IN_LEVEL2
        elseif name == "高级房" then
            return Scene.RECHARGE_SCENE_IN_LEVEL3
        elseif name == "水浒传" then
            return Scene.RECHARGE_SCENE_IN_SHUIHU
        end
        return 0
    end

    local logDataInGame = {
        nRoomID = roomInfo.nRoomID,
        sRoomName = utf8Name,
        nMinDeposit = minDeposit,
        nReChargeType = ReChargeType.RECHARGE_TYPE_COMMON_PAY,
        nReChargePlace = ReChargeScene.RECHARGE_SCENE_IN_HALL,
    }

    if self._HallOrGame then
        self._gameController:playEffectOnPress()
        logDataInGame.nReChargePlace = ReChargeScene.RECHARGE_SCENE_IN_HALL_EX
    else
        -- 自测，发现游戏场内_HallOrGame=nil,这里开始获取房间ID，中高级房等。。。
        logDataInGame.nReChargePlace = getReChargeSceneID(utf8Name)
        self._gameController:playBtnPressedEffect()

        --self._gameController:rechagreInGame(self._RechargeData.index)
    end

    if self._isLimitTimeGift then
    -- 限时礼包走这里
        --[[if self._LimitTimeGiftTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._LimitTimeGiftTimer)
            self._LimitTimeGiftTimer = nil
        end]]--

        --local limitTimeGiftPay = require("src.app.plugins.limitTimeGift.limitTimeGiftPay")
        --limitTimeGiftPay.LimitTimeGiftInfo = self._RechargeData
                
        logDataInGame.nReChargeType = ReChargeType.RECHARGE_TYPE_LIMIT_TIME_BAG
        --limitTimeGiftPay:PayForProduct()
        --limitTimeGiftPay:PayForProductEx(logDataInGame)

        --注意限时礼包的显示项，由LimitTimeGiftModel._giftItemData决定，所以不需要传递给payLimitTimeGiftItem
        LimitTimeGiftModel:payCurrentGiftItem(not self._HallOrGame)
    else
    -- 普通弹窗充值
        if self._RechargeData and self._RechargeData["itemData"]["First_Support"] == 1 then
            logDataInGame.nReChargeType = ReChargeType.RECHARGE_TYPE_FIRST_RECHARGE
        end

        --local ShopExModel = require("src.app.plugins.shopcenterex.ShopExModel")
        --ShopExModel:OnPayItemClick(self._RechargeData.index)
         --ShopExModel:OnPayItemClickEx(self._RechargeData.index,  logDataInGame)

        ShopModel:PayForProductWithCustomCallback(self._RechargeData["itemData"], function(code, msg) 
            if code == PayResultCode.kPaySuccess then
                print("[INFO] quick-recharge successfully...")
                local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()
                ComEvtTrkingModel:sendQuickRechargeBuySuccessEvt()
            end
        end)

        -- 埋点
        local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()
        ComEvtTrkingModel:sendQuickRechargeClickBuyBtn()
        if self._RechargeData and self._RechargeData["itemData"] then
            ComEvtTrkingModel:saveRechargeInfo(self._RechargeData["itemData"].exchangeid,self._RechargeData["itemData"].price)
        end
    end

    self:removeFromParentAndCleanup()
end

return MyGamePromptRecharge
