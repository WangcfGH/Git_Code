local GoldSilverCtrl = class('GoldSilverCtrl', cc.load('BaseCtrl'))

local AssistModel = mymodel('assist.AssistModel'):getInstance()
local GoldSilverView = require("src.app.plugins.goldsilver.GoldSilverView")
local GoldSilverModel = import("src.app.plugins.goldsilver.GoldSilverModel"):getInstance()
local Def = require('src.app.plugins.goldsilver.GoldSilverDef')
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local player = mymodel('hallext.PlayerModel'):getInstance()

function GoldSilverCtrl:onCreate(param)
    local viewNode = self:setViewIndexer(GoldSilverView:createViewIndexer(self))
    self._viewNode = viewNode
    cc.exports.zeroBezelNodeAutoAdapt(self._viewNode:getChildByName("Operate_Panel"))
    self:initialListenTo()
    self:initialBtnClick()
    
    self:updateUI()
    self:playAnimation()
    --self:showTip()
end


function GoldSilverCtrl:initialListenTo( )
    self:listenTo(GoldSilverModel, Def.GoldSilverInfoReceived, handler(self,self.updateUI))
    self:listenTo(GoldSilverModel, Def.GoldSilverTakeRewardRet, handler(self,self.updateUI))
    self:listenTo(GoldSilverModel, Def.SynGoldSilverScore, handler(self,self.updateUI))
    self:listenTo(GoldSilverModel, Def.SynGoldSilverBuyState, handler(self,self.updateUI))
    self:listenTo(MyTimeStamp,MyTimeStamp.UPDATE_STAMP, handler(self,self.updateUI))
    self:listenTo(ShopModel, ShopModel.EVENT_UPDATE_RICH,handler(self,self.freshUserInfo))
    self:listenTo(player, player.PLAYER_DATA_UPDATED, handler(self,self.freshUserInfo))
end

function GoldSilverCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.Btn_Back:addClickEventListener(handler(self, self.onClose))
    viewNode.Btn_Rule:addClickEventListener(handler(self, self.showRule))
    viewNode.Btn_Close:addClickEventListener(handler(self, self.hideRule))
    viewNode.Btn_Add:addClickEventListener(handler(self, self.addSilver))
    viewNode.Btn_FreeTake:addClickEventListener(handler(self, self.takeFreeReward))
    --viewNode.Panel_OneKetGet:addClickEventListener(handler(self, self.oneKeyGet))
    --viewNode.Panel_UnLock:addClickEventListener(handler(self, self.unLock))
    viewNode.Img_SilverCover:addClickEventListener(handler(self, self.unLockSilver))
    viewNode.Img_GoldCover:addClickEventListener(handler(self, self.unLockGold))
    viewNode.Btn_GetScore:addClickEventListener(handler(self, self.getScore))
    viewNode.Btn_Play:addClickEventListener(handler(self, self.getScore))
    viewNode.Btn_Arrow:addClickEventListener(handler(self, self.onClickArrow))
    viewNode.Img_FreeComplete:addClickEventListener(handler(self, self.onClockComplete))

    viewNode.Panel_UnLock:onTouch(function(e)
        if e.name == "began" then
            e.target:setColor(cc.c3b(166,166,166))
            if self._spUnLock then
                self._spUnLock:setColor(cc.c3b(166,166,166))
            end
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))
            if self._spUnLock then
                self._spUnLock:setColor(cc.c3b(255,255,255))
            end
        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            if self._spUnLock then
                self._spUnLock:setColor(cc.c3b(255,255,255))
            end
            self:unLock()
        end
    end)

    viewNode.Img_SilverLock:setTouchEnabled(true)
    viewNode.Img_SilverLock:onTouch(function(e)
        if e.name == "began" then
            e.target:setColor(cc.c3b(166,166,166))
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))
        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            self:unLockSilver()
        end
    end)

    viewNode.Img_GoldLock:setTouchEnabled(true)
    viewNode.Img_GoldLock:onTouch(function(e)
        if e.name == "began" then
            e.target:setColor(cc.c3b(166,166,166))
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))
        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            self:unLockGold()
        end
    end)

    viewNode.Panel_OneKetGet:onTouch(function(e)
        if e.name == "began" then
            e.target:setColor(cc.c3b(166,166,166))
            if self._spOneKeyGet then
                self._spOneKeyGet:setColor(cc.c3b(166,166,166))
            end
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))
            if self._spOneKeyGet then
                self._spOneKeyGet:setColor(cc.c3b(255,255,255))
            end
        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            if self._spOneKeyGet then
                self._spOneKeyGet:setColor(cc.c3b(255,255,255))
            end
            self:oneKeyGet()
        end
    end)
end

function GoldSilverCtrl:updateUI( )
    if nil == GoldSilverModel:GetGoldSilverInfo() then 
        GoldSilverModel:GoldSilverInfoReq()
        return
    end

    self:freshGoldSilverCup()
    self:freshScrollView()
    self:freshUserInfo()
    self:freshTopInfo()
    self:freshCountDown()
    self:freshDuringTime()
    self:freshRightInfo()
    self:freshRule()
    self:onJumpRightPlace()
end

function GoldSilverCtrl:playAnimation()
    local action = cc.CSLoader:createTimeline("res/hallcocosstudio/goldsilver/goldsilver.csb")
    if action and self._viewNode then
        self._viewNode:runAction(action)
        action:play("BtnAnimation", true)
    end
end

function GoldSilverCtrl:freshGoldSilverCup( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()
    if not rewardConfig then return end

    local viewNode = self._viewNode
    if info.nSilverBuyStatus == 1 then
        viewNode.Img_SilverCover:setVisible(false)
        viewNode.Img_SilverCup:setVisible(false)
        viewNode.Text_SilverCup:setVisible(false)
        if not self._spYinbei then
            local actionName = "yinbei"    
            self._spYinbei = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/gold_silver/jybhd.json", "res/hallcocosstudio/images/skeleton/gold_silver/jybhd.atlas",1)  
            self._spYinbei:setAnimation(0, actionName, true) 
            --spMeigui:setDebugBonesEnabled(false) 
            self._spYinbei:setPosition(viewNode.Img_SilverCup:getPositionX(),viewNode.Img_SilverCup:getPositionY()-30)

            viewNode.Panel_CenterLeft:addChild(self._spYinbei)
        end
    else
        viewNode.Img_SilverCover:setVisible(true)
        viewNode.Text_SilverCup:setVisible(true)
    end

    if info.nGoldBuyStatus == 1 then
        viewNode.Img_GoldCover:setVisible(false)
        viewNode.Img_GoldCup:setVisible(false)
        viewNode.Text_GoldCup:setVisible(false)
        if not self._spJinbei then
            local actionName = "jinbei"    
            self._spJinbei = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/gold_silver/jybhd.json", "res/hallcocosstudio/images/skeleton/gold_silver/jybhd.atlas",1)  
            self._spJinbei:setAnimation(0, actionName, true) 
            --spMeigui:setDebugBonesEnabled(false) 
            self._spJinbei:setPosition(viewNode.Img_GoldCup:getPositionX(),viewNode.Img_GoldCup:getPositionY()-30)

            viewNode.Panel_CenterLeft:addChild(self._spJinbei)
        end
    else
        viewNode.Img_GoldCover:setVisible(true)
        viewNode.Text_GoldCup:setVisible(true)
    end
    
    local silverSilver = 0
    local silverTicket = 0
    local goldSilver = 0
    local goldTicket = 0

    for i = 1,#rewardConfig do
        local reward = rewardConfig[i]["stReward"]
        silverSilver = silverSilver + reward.nSilverSilver
        silverTicket = silverTicket + reward.nSilverTicket
        goldSilver = goldSilver + reward.nGoldSilver
        goldTicket = goldTicket + reward.nGoldTicket
    end

    local silverValue
    local goldValue
    if GoldSilverModel:IsHejiPackage() then
        silverValue = (silverSilver + silverTicket*100)/5000
        goldValue = (goldSilver + goldTicket*100)/5000
    else
        silverValue = (silverSilver + silverTicket*100)/10000
        goldValue = (goldSilver + goldTicket*100)/10000
    end

    local expectedSilverDeposit, expectedSilverTicket = GoldSilverModel:getRewardCountByCurLevel(Def.TAKETYPE_SILVER)
    local goodSilverConfig = GoldSilverModel:getGoodConfigByType(Def.PAY_TYPE_SILVER)
    local silverString = string.format( "可获得价值%d元的银两",silverValue)
    if info.nSilverBuyStatus == 0 then
        if goodSilverConfig and goodSilverConfig.value
        and expectedSilverDeposit > goodSilverConfig.value then
            local str = GoldSilverModel:getSilverNumString(expectedSilverDeposit)
            silverString = string.format("当前已可领取%s两银子", str)
        end
    else
        local str = GoldSilverModel:getSilverNumString(expectedSilverDeposit)
        silverString = string.format("当前已可领取%s两银子", str)
    end
    viewNode.Text_SilverReward:setString(silverString)

    local expectedGoldDeposit, expectedGoldTicket = GoldSilverModel:getRewardCountByCurLevel(Def.TAKETYPE_GOLD)
    local goodGoldConfig = GoldSilverModel:getGoodConfigByType(Def.PAY_TYPE_GOLD)
    local goldString = string.format( "可获得价值%d元的银两和礼券",goldValue)
    if info.nGoldBuyStatus == 0 then
        if goodGoldConfig and goodGoldConfig.value
        and expectedGoldDeposit > goodGoldConfig.value then
            local str = GoldSilverModel:getSilverNumString(expectedGoldDeposit)
            goldString = string.format("当前已可领取%s两银子以及%d张礼券", str, expectedGoldTicket)
        end
    else
        local str = GoldSilverModel:getSilverNumString(expectedGoldDeposit)
        goldString = string.format("当前已可领取%s两银子以及%d张礼券", str, expectedGoldTicket)
    end

    viewNode.Text_GoldReward:setString(goldString)

    local silverConfig = GoldSilverModel:getGoodConfigByType(Def.PAY_TYPE_SILVER)
    local textDescSilver = viewNode.Img_SilverLock:getChildByName("Txt_Desc")
    if silverConfig and silverConfig.price and textDescSilver then
        textDescSilver:setString(string.format("%d元解锁", silverConfig.price))
    end
    local goldConfig = GoldSilverModel:getGoodConfigByType(Def.PAY_TYPE_GOLD)
    local textDescGold = viewNode.Img_GoldLock:getChildByName("Txt_Desc")
    if goldConfig and goldConfig.price and textDescGold then
        textDescGold:setString(string.format("%d元解锁", goldConfig.price))
    end

    --去掉立即解锁
    if info.nSilverBuyStatus == 1 and info.nGoldBuyStatus == 1 then
        viewNode.Panel_UnLock:setVisible(false)
        viewNode.Btn_UnLock:setVisible(false)
        if self._spUnLock then
            self._spUnLock:removeFromParent()
            self._spUnLock = nil
        end
    else
        viewNode.Panel_UnLock:setVisible(false)
        viewNode.Btn_UnLock:setVisible(false)
        -- if not self._spUnLock then
        --     local actionName = "ljjs"    
        --     self._spUnLock = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/gold_silver/jybhd.json", "res/hallcocosstudio/images/skeleton/gold_silver/jybhd.atlas",1)  
        --     self._spUnLock:setAnimation(0, actionName, true) 
        --     --spMeigui:setDebugBonesEnabled(false) 
        --     self._spUnLock:setPosition(viewNode.Btn_UnLock:getPosition())
            
        --     viewNode.Panel_UnLock:addChild(self._spUnLock)
        -- end
    end
end

function GoldSilverCtrl:freshScrollView( )
    local viewNode = self._viewNode
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()
    if not rewardConfig then return end
    local curLevel = GoldSilverModel:GetCurLevel()
    if not curLevel then return end

    local levelCount = #rewardConfig
    if levelCount > 5 then
        viewNode.Scroll_Reward:setInnerContainerSize(cc.size(104*levelCount, 430))
    end
    viewNode.Scroll_Reward:removeAllChildren()
    
    for i=1,levelCount do
        local nodeItem = cc.CSLoader:createNode(GoldSilverView.PATH_NODE_AWARDITEM)
        local nodeAward = nodeItem:getChildByName("Panel_Item")
        nodeAward:retain()
        nodeAward:removeFromParent()
        self:scriptAwardItem(nodeAward,i,curLevel)

        nodeAward:setPosition(cc.p(104 * i - 52, 247))

        viewNode.Scroll_Reward:addChild(nodeAward)
        nodeAward:release()
    end

    my.scheduleOnce(function()
        if not self._viewNode then return end 
        if self._cachePos then
            local container = self._viewNode.Scroll_Reward:getInnerContainer()
            container:setPosition(self._cachePos)
            self._cachePos = nil
        end
    end, 1)
end

function GoldSilverCtrl:scriptAwardItem(nodeAward, nIndex, nCurLevel)
    if tolua.isnull(nodeAward) then return end
    local config = GoldSilverModel:GetGoldSilverRewardConfig()
    if not config then return end
    local rewardConfig = config[nIndex]["stReward"]
    --刷新等级
    local textLevel = nodeAward:getChildByName("Panel_Silver"):getChildByName("Text_Level")
    textLevel:setString(string.format( "等级%d",nIndex))

    local function getSilverReward(  )

        if not CenterCtrl:checkNetStatus() then
            self:removeSelfInstance()
            return
        end

        GoldSilverModel:GoldSilverTakeRewardReq(1, nIndex)
        self:saveTakePosition()
    end
    local function getGoldReward(  )

        if not CenterCtrl:checkNetStatus() then
            self:removeSelfInstance()
            return
        end

        GoldSilverModel:GoldSilverTakeRewardReq(2, nIndex)
        self:saveTakePosition()
    end
    --设置领取按钮点击事件
    local btnTakeSilverReward = nodeAward:getChildByName("Panel_Silver"):getChildByName("Btn_SilverTake")
    btnTakeSilverReward:onTouch(function(e)
        if e.name == "began" then
            my.playClickBtnSound()
            e.target:setColor(cc.c3b(166,166,166))
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))

        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            getSilverReward()
        end
    end)
    -- btnTakeSilverReward:addClickEventListener(function()
    --     getSilverReward()
    -- end)

    local btnTakeGoldReward = nodeAward:getChildByName("Panel_Gold"):getChildByName("Btn_GoldTake")
    btnTakeGoldReward:onTouch(function(e)
        if e.name == "began" then
            my.playClickBtnSound()
            e.target:setColor(cc.c3b(166,166,166))
        elseif e.name == "cancelled" then
            e.target:setColor(cc.c3b(255,255,255))
        elseif e.name == "ended" then
            e.target:setColor(cc.c3b(255,255,255))
            getGoldReward()
        end
    end)
    -- btnTakeGoldReward:addClickEventListener(function()
    --     getGoldReward()
    -- end)

    local function clickSilverCover()
        self:clickSilverCover(nIndex)
    end

    local function clickGoldCover()
        self:clickGoldCover(nIndex)
    end

    local function clickSilverLight()
        self:clickSilverLight()
    end

    local function clickGoldLight()
        self:clickGoldLight()
    end

    --点击蒙层
    local silverCover = nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Cover")
    silverCover:addClickEventListener(function()
        clickSilverCover()
    end)
    local goldCover = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Cover")
    goldCover:addClickEventListener(function()
        clickGoldCover()
    end)
    --点击高亮
    local silverLight = nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_SilverLight")
    silverLight:addClickEventListener(function()
        clickSilverLight()
    end)
    local goldLight = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_GoldLight")
    goldLight:addClickEventListener(function()
        clickGoldLight()
    end)

    --刷新奖励物品
    local imgSilverAward = nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_ItemBG"):getChildByName("Img_Item")
    local imgSilverAwardCount = nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_ItemBG"):getChildByName("Fnt_Num")
    local imgGoldAward1 = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):getChildByName("Img_Item1")
    local imgGoldAwardCount1 = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):getChildByName("Fnt_Num1")
    local imgGoldAward2 = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):getChildByName("Img_Item2")
    local imgGoldAwardCount2 = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):getChildByName("Fnt_Num2")

    --设置银杯奖励
    nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_ItemBG"):setVisible(true)
    if rewardConfig.nSilverSilver>0 then
        local imgPath = self:getImagePath(Def.REWARD_TYPE_SILVER,rewardConfig.nSilverSilver)
        imgSilverAward:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgSilverAwardCount:setString(rewardConfig.nSilverSilver)
    elseif rewardConfig.nSilverTicket>0 then
        local imgPath = self:getImagePath(Def.REWARD_TYPE_TICKET,rewardConfig.nSilverTicket)
        imgSilverAward:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgSilverAwardCount:setString(rewardConfig.nSilverTicket)
    else
        nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_ItemBG"):setVisible(false)
    end

    --设置金杯奖励
    nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):setVisible(true)
    nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):setVisible(true)
    if rewardConfig.nGoldSilver>0 and rewardConfig.nGoldTicket>0 then
        local imgPath = self:getImagePath(Def.REWARD_TYPE_SILVER,rewardConfig.nGoldSilver)
        imgGoldAward1:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgGoldAwardCount1:setString(rewardConfig.nGoldSilver)
        imgPath = self:getImagePath(Def.REWARD_TYPE_TICKET,rewardConfig.nGoldTicket)
        imgGoldAward2:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgGoldAwardCount2:setString(rewardConfig.nGoldTicket)
    elseif rewardConfig.nGoldSilver>0 then
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):setVisible(false)
        local imgPath = self:getImagePath(Def.REWARD_TYPE_SILVER,rewardConfig.nGoldSilver)
        imgGoldAward1:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgGoldAwardCount1:setString(rewardConfig.nGoldSilver)
    elseif rewardConfig.nGoldTicket>0 then
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):setVisible(false)
        local imgPath = self:getImagePath(Def.REWARD_TYPE_TICKET,rewardConfig.nGoldTicket)
        imgGoldAward1:loadTexture(imgPath,ccui.TextureResType.plistType)
        imgGoldAwardCount1:setString(rewardConfig.nGoldTicket)
    else
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):setVisible(false)
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):setVisible(false)
    end

    local aniFile = "res/hallcocosstudio/passcheck/tsk.csb"
    --设置领取状态
    nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_ItemBG"):getChildByName("Ani_Tsk"):setVisible(false)
    nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):getChildByName("Ani_Tsk"):setVisible(false)
    nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG2"):getChildByName("Ani_Tsk"):setVisible(false)
    if nIndex > nCurLevel then
        --银杯
        nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_SilverLight"):setVisible(false)
        nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Cover"):setVisible(true)
        nodeAward:getChildByName("Panel_Silver"):getChildByName("Btn_SilverTake"):setVisible(false)
        nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Rewarded"):setVisible(false)
        --金杯
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_GoldLight"):setVisible(false)
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Cover"):setVisible(true)
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Btn_GoldTake"):setVisible(false)
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Rewarded"):setVisible(false)
    else
        --银杯
        if GoldSilverModel:IsLevelGiftReward(Def.TAKETYPE_SILVER, nIndex) then
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Btn_SilverTake"):setVisible(false)
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Rewarded"):setVisible(true)
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_SilverLight"):setVisible(false)
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Cover"):setVisible(false)
        else
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_SilverLight"):setVisible(true)
            nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Cover"):setVisible(false)

            if GoldSilverModel:IsBuySilverCup() then
                nodeAward:getChildByName("Panel_Silver"):getChildByName("Btn_SilverTake"):setVisible(true)
                nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Rewarded"):setVisible(false)
            else
                nodeAward:getChildByName("Panel_Silver"):getChildByName("Btn_SilverTake"):setVisible(false)
                nodeAward:getChildByName("Panel_Silver"):getChildByName("Img_Rewarded"):setVisible(false)
            end
        end


        --金杯
        if GoldSilverModel:IsLevelGiftReward(Def.TAKETYPE_GOLD, nIndex) then
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_GoldLight"):setVisible(false)
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Cover"):setVisible(false)
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Btn_GoldTake"):setVisible(false)
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Rewarded"):setVisible(true)
        else
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_GoldLight"):setVisible(true)
            nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Cover"):setVisible(false)              
            if GoldSilverModel:IsBuyGoldCup() then
                nodeAward:getChildByName("Panel_Gold"):getChildByName("Btn_GoldTake"):setVisible(true)
                nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Rewarded"):setVisible(false)
            else
                nodeAward:getChildByName("Panel_Gold"):getChildByName("Btn_GoldTake"):setVisible(false)
                nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_Rewarded"):setVisible(false)
            end
        end
    end

    --播放奖励框动画
    local nMaxSilver = GoldSilverModel:GetMaxGoldSilver()
    if nMaxSilver == rewardConfig.nGoldSilver then
        nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):getChildByName("Ani_Tsk"):setVisible(true)
        local nodeAni1 = nodeAward:getChildByName("Panel_Gold"):getChildByName("Img_ItemBG1"):getChildByName("Ani_Tsk")
        nodeAni1:setVisible(true)
        local ani1 = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(ani1) then
            nodeAni1:stopAllActions()
            nodeAni1:runAction(ani1)
            ani1:play("animation0", true)
        end
    end

end

function GoldSilverCtrl:freshUserInfo( )
    local viewNode = self._viewNode
    viewNode.Fnt_UserSilver:setMoney(UserModel.nDeposit)
end

function GoldSilverCtrl:freshTopInfo()
    self:freshLevel()
    self:freshScore()
end

function GoldSilverCtrl:freshDuringTime()
    local viewNode = self._viewNode
    local str = GoldSilverModel:GetDuringTimeString()
    if viewNode and viewNode.Text_DuringTime then
        viewNode.Text_DuringTime:setString(str)
    end
end

function GoldSilverCtrl:freshCountDown( )
    local viewNode = self._viewNode

    local endDate = GoldSilverModel:GetEndData()
    if self._coutndown == nil then
        self._coutndown = import("src.app.plugins.timecalc.TimeCountDown").new(viewNode.Text_Days, 0, endDate, 000000, 000000)
        self._coutndown:startcountdown()
    else
        self._coutndown:resettime(0, endDate, 000000, 000000)
    end    
end

function GoldSilverCtrl:freshRightInfo( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()
    if not rewardConfig then return end
    local viewNode = self._viewNode

    --刷新赛季
    local nSeason = info.nSeason
    if nSeason and type(nSeason) == "number" then
        viewNode.Fnt_Season:setString(string.format( "S%d赛季",nSeason))
    end

    --刷新免费奖励
    local curLevel = GoldSilverModel:GetCurLevel()
    local item =rewardConfig[1]["stReward"]
    local nextItemLevel = 1
    local tipString = "免费奖励已领完"
    local bAllRewarded = true
    local lastItem = rewardConfig[1]["stReward"]
    for i = 1, #rewardConfig do
        if not GoldSilverModel:IsLevelGiftReward(Def.TAKETYPE_FREE, i) then
            item = rewardConfig[i]["stReward"]
            if item.nFreeSilver>0 or item.nFreeTicket>0 then
                nextItemLevel = i
                bAllRewarded = false
                break
            end
        end
        local award = rewardConfig[i]["stReward"]
        if award.nFreeSilver>0 or award.nFreeTicket>0 then
            lastItem = award
        end
    end

    self._nextFreeInex = nextItemLevel
    if bAllRewarded then
        item =lastItem
        tipString = "免费奖励已领完"
        viewNode.Img_FreeComplete:setVisible(true)
        viewNode.Btn_Play:setVisible(false)
        viewNode.Btn_FreeTake:setVisible(false)
        viewNode.Img_FreeCover:setVisible(true)
    else
        if curLevel>=nextItemLevel then
            viewNode.Img_FreeComplete:setVisible(false)
            viewNode.Btn_Play:setVisible(false)
            viewNode.Btn_FreeTake:setVisible(true)
            viewNode.Img_FreeCover:setVisible(false)
        else
            viewNode.Img_FreeComplete:setVisible(false)
            viewNode.Btn_Play:setVisible(true)
            viewNode.Btn_FreeTake:setVisible(false)
            viewNode.Img_FreeCover:setVisible(true)
        end

        tipString = string.format( "%d级可以领取",nextItemLevel)
    end

    if item.nFreeSilver>0 then
        local imgPath = self:getImagePath(Def.REWARD_TYPE_SILVER,item.nFreeSilver)
        viewNode.Img_FreeItem:loadTexture(imgPath,ccui.TextureResType.plistType)
        viewNode.Fnt_FreeCount:setString(item.nFreeSilver)
    elseif item.nFreeTicket >0 then
        local imgPath = self:getImagePath(Def.REWARD_TYPE_TICKET,item.nFreeTicket)
        viewNode.Img_FreeItem:loadTexture(imgPath,ccui.TextureResType.plistType)
        viewNode.Fnt_FreeCount:setString(item.nFreeTicket)
    end

    --刷新提示语
    viewNode.Text_Tip:setString(tipString)

    viewNode.Panel_Center:getChildByName("Panel_Bubble"):setVisible(false)
    --刷新一键领取按钮
    local count = GoldSilverModel:GetCountCanReward()
    if count>1 then
        viewNode.Panel_OneKetGet:setVisible(true)
        viewNode.Btn_OneKeyGet:setVisible(false)
        viewNode.Btn_OneKeyGet2:setVisible(false)
        viewNode.Panel_Center:getChildByName("Panel_Bubble"):setVisible(true)

        if not self._spOneKeyGet then
            local actionName = "yjlq"    
            self._spOneKeyGet = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/gold_silver/yjlq.json", "res/hallcocosstudio/images/skeleton/gold_silver/yjlq.atlas",1)  
            self._spOneKeyGet:setAnimation(0, actionName, true) 
            self._spOneKeyGet:setPosition(viewNode.Btn_OneKeyGet:getPosition())
            viewNode.Panel_OneKetGet:addChild(self._spOneKeyGet)
        end
    else
        viewNode.Panel_OneKetGet:setVisible(false)
        viewNode.Btn_OneKeyGet:setVisible(false)
        viewNode.Btn_OneKeyGet2:setVisible(true)
        if self._spOneKeyGet then
            self._spOneKeyGet:removeFromParent()
            self._spOneKeyGet = nil
        end
    end
end

function GoldSilverCtrl:freshRule()
    local info = GoldSilverModel:GetGoldSilverInfo()
    local roomScore = GoldSilverModel:GetRoomScoreConfig()
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()

    if not info then return end
    if not roomScore then return end
    local viewNode = self._viewNode
    roomScore = checktable(roomScore)
    local imgRule = viewNode.Img_Rule
    for i = 2,7,1 do
        local winLoseScore = roomScore[i]
        if winLoseScore and next(winLoseScore) ~= nil then
            imgRule:getChildByName("Text_" .. i .. "_Lose"):setString(winLoseScore.nLose)
            imgRule:getChildByName("Text_" .. i .. "_Win"):setString(winLoseScore.nOneWin)
            imgRule:getChildByName("Text_" .. i .. "_DoubleWin"):setString(winLoseScore.nDoubleWin)
        end
    end

    local levelCount = #rewardConfig
    local height = 450 + 50 * levelCount + 40
    viewNode.Scroll_Rule:setInnerContainerSize(cc.size(800, height))
    viewNode.Img_Title:setPosition(400,height - 40)
    viewNode.Img_Rule:setPosition(400,height - 270)


    for j = 1, levelCount do
        local config = rewardConfig[j]
        if config.nNeedScore then
            local tipString = string.format( "%d级 : %d积分",j, config.nNeedScore)
            local textTip = ccui.Text:create()
            textTip:setString(tipString)
            textTip:setFontSize(24)
            textTip:setPosition(200,height -450 - j*50)
            viewNode.Scroll_Rule:addChild(textTip)
        end
    end
    if info.nMaxDailyScore then
        viewNode.Text_DailyScore:setString(info.nMaxDailyScore)
    end
end

function GoldSilverCtrl:freshLevel( )
    local viewNode = self._viewNode
    local level = GoldSilverModel:GetCurLevel()
    if level then
        viewNode.Fnt_Level:setString(level)
    end
end

function GoldSilverCtrl:freshScore( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()
    if not rewardConfig then return end

    local nCurLevel = GoldSilverModel:GetCurLevel()
    local levelCount = #rewardConfig

    local totalScore = info.nTotalScore
    local molecule = 0
    local Denominator= 0

    if nCurLevel == 0 then
        molecule = totalScore
        Denominator = rewardConfig[1].nNeedScore
    elseif nCurLevel == levelCount then
        molecule = rewardConfig[levelCount].nNeedScore
        Denominator = rewardConfig[levelCount].nNeedScore
    elseif nCurLevel>0 and nCurLevel<levelCount then
        for i=1,nCurLevel do
            if totalScore>=rewardConfig[i].nNeedScore then
                totalScore = totalScore - rewardConfig[i].nNeedScore
            end
        end
        molecule = totalScore
        Denominator = rewardConfig[nCurLevel + 1].nNeedScore
    end

    self:setScore(molecule,Denominator)
    self:setLevelBar(molecule, Denominator)

    --当日经验达到上限，给个提示
    local viewNode = self._viewNode
    viewNode.Btn_GetScore:getChildByName("Panel_Bubble"):setVisible(false)
    if info.nDailyScore and info.nMaxDailyScore and info.nDailyScore >= info.nMaxDailyScore then
        viewNode.Btn_GetScore:getChildByName("Panel_Bubble"):setVisible(true)
    end
end

function GoldSilverCtrl:setScore(molecule, Denominator)
    local viewNode = self._viewNode
    viewNode.Fnt_Score:setString(string.format("经验 %d/%d", molecule, Denominator))
end

function GoldSilverCtrl:setLevelBar(molecule, Denominator)
    local viewNode = self._viewNode
    viewNode.LoadingBar_Process:setPercent(tostring(molecule/Denominator*100))
end


function GoldSilverCtrl:onClose()
    my.playClickBtnSound()
    self:removeSelfInstance()
end

function GoldSilverCtrl:showRule()
    local viewNode = self._viewNode
    my.playClickBtnSound()
    viewNode.Panel_Rule:setVisible(true)
end

function GoldSilverCtrl:hideRule( )
    local viewNode = self._viewNode
    my.playClickBtnSound()
    viewNode.Panel_Rule:setVisible(false)
end

function GoldSilverCtrl:addSilver( )
    my.playClickBtnSound()
    my.informPluginByName({ pluginName = 'ShopCtrl' })
end

function GoldSilverCtrl:takeFreeReward( )
    my.playClickBtnSound()
    if self._nextFreeInex then
        GoldSilverModel:GoldSilverTakeRewardReq(Def.TAKETYPE_FREE,self._nextFreeInex)
    end
end

function GoldSilverCtrl:oneKeyGet( )
    my.playClickBtnSound()
    GoldSilverModel:GoldSilverTakeRewardReq(Def.TAKETYPE_ALL,0)
end

function GoldSilverCtrl:unLock( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end

    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    if info.nSilverBuyStatus == 0 and info.nGoldBuyStatus == 0 then
        my.playClickBtnSound()
        my.informPluginByName({ pluginName = 'GoldSilverBuyLayer' })
    elseif info.nSilverBuyStatus == 0 then
        self:PayForSilverCup()
    elseif info.nGoldBuyStatus == 0 then
        self:PayForGoldCup()
    end

end

function GoldSilverCtrl:PayForSilverCup( )
    my.playClickBtnSound()
    GoldSilverModel:payForReq(Def.PAY_TYPE_SILVER)
end

function GoldSilverCtrl:PayForGoldCup( )
    my.playClickBtnSound()
    GoldSilverModel:payForReq(Def.PAY_TYPE_GOLD)
end

function GoldSilverCtrl:unLockSilver( )
    my.playClickBtnSound()
    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    local tipString = "是否确认解锁"
    --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local nowDate = os.date('%Y%m%d',nowtimestamp)
    local dayDiff = tonumber(GoldSilverModel:GetEndData()) - tonumber(nowDate) - 1
    if GoldSilverModel:GetCurLevel() <= cc.exports.getGoldSilverTipLevelValue()  and dayDiff <= cc.exports.getGoldSilverTipDayValue() then
        tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
    end

    GoldSilverModel:payForReq(Def.PAY_TYPE_SILVER)
end

function GoldSilverCtrl:unLockGold( )
    my.playClickBtnSound()
    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    local tipString = "是否确认解锁"
    --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local nowDate = os.date('%Y%m%d',nowtimestamp)
    local dayDiff = tonumber(GoldSilverModel:GetEndData()) - tonumber(nowDate) - 1
    if GoldSilverModel:GetCurLevel() <= cc.exports.getGoldSilverTipLevelValue()  and dayDiff <= cc.exports.getGoldSilverTipDayValue() then
        tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
    end
    
    GoldSilverModel:payForReq(Def.PAY_TYPE_GOLD)
end

function GoldSilverCtrl:getScore( )
    my.playClickBtnSound()
    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local function quickStart(dt)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end

    PluginProcessModel:closeShopCtrl()

    if not my.isInGame() then
        PluginProcessModel:notifyClosePlugin()
        my.scheduleOnce(quickStart, 0.5)
    end
end

function GoldSilverCtrl:getImagePath(nType,nCount)
    local Path = "hallcocosstudio/images/plist/GoldSilver_Img/"
    if nType == Def.REWARD_TYPE_SILVER then
        if nCount >= 10000 then
            Path = Path .. "Img_Silver4.png"
        elseif nCount >= 5000 then
            Path = Path .. "Img_Silver3.png"
        elseif nCount >= 1000 then
            Path = Path .. "Img_Silver2.png"
        else
            Path = Path .. "Img_Silver1.png"
        end
    elseif nType == Def.REWARD_TYPE_TICKET then
        if nCount >= 100 then
            Path = Path .. "Img_Ticket4.png"
        elseif nCount >= 50 then
            Path = Path .. "Img_Ticket3.png"
        elseif nCount >= 20 then
            Path = Path .. "Img_Ticket2.png"
        else
            Path = Path .. "Img_Ticket1.png"
        end
    end
    return Path
end

function GoldSilverCtrl:onClickArrow( )
    my.playClickBtnSound()
    local viewNode = self._viewNode
    

    local posx = viewNode.Scroll_Reward:getInnerContainer():getPositionX()
    local len = viewNode.Scroll_Reward:getInnerContainerSize().width - viewNode.Scroll_Reward:getContentSize().width
    if len == 0 then
        return
    end
    local percent = -100 * posx / len
    percent = percent + 100 / (5 * 2)  --设计时1显示的是5个,10等份，每次走1半好一点
    if percent > 100 then
        percent = 100
    end
    viewNode.Scroll_Reward:jumpToPercentHorizontal(percent)
end

function GoldSilverCtrl:onClockComplete()
    my.playClickBtnSound()
    my.informPluginByName({ pluginName = 'TipPlugin', params = {tipString = "免费奖励已领完"}})
end

function GoldSilverCtrl:clickSilverCover(nIndex)
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end
    
    if not GoldSilverModel:IsLevelGiftReward(Def.TAKETYPE_SILVER, nIndex) then
        if self:IsDuringLastTwoDays() then
            local tipString
            if info.nSilverBuyStatus == 0 then
                tipString = "活动已结束，不能购买了哦"
            else
                tipString = "活动已结束"
            end
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
            return
        end 

        my.playClickBtnSound()
        my.informPluginByName({ pluginName = 'TipPlugin', params = {tipString = "升级即可领取"}})
    end
end

function GoldSilverCtrl:clickGoldCover(nIndex)
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end

    if not GoldSilverModel:IsLevelGiftReward(Def.TAKETYPE_GOLD, nIndex) then
        if self:IsDuringLastTwoDays() then
            local tipString
            if info.nGoldBuyStatus == 0 then
                tipString = "活动已结束，不能购买了哦"
            else
                tipString = "活动已结束"
            end
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
            return
        end 

        my.playClickBtnSound()
        my.informPluginByName({ pluginName = 'TipPlugin', params = {tipString = "升级即可领取"}})
    end
end

function GoldSilverCtrl:clickSilverLight( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end

    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    if info.nSilverBuyStatus == 0 then
        local tipString = "解锁银杯即可获得大量银子奖励，点击确定购买"
        local function callback()
            self:PayForSilverCup()
        end
        my.playClickBtnSound()
        my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
    end
end

function GoldSilverCtrl:clickGoldLight( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end

    if self:IsDuringLastTwoDays() then
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end 

    if info.nGoldBuyStatus == 0 then
        local tipString = "解锁金杯即可获得大量银子以及礼券奖励，点击确定购买"
        local function callback()
            self:PayForGoldCup()
        end
        my.playClickBtnSound()
        my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
    end
end

function GoldSilverCtrl:onExit( )
    if self._coutndown then
        self._coutndown:stopcountdown()
        self._coutndown = nil
    end

    local HallContext = require("src.app.plugins.mainpanel.HallContext"):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_backToMainSceneFromNonSceneFullScreenCtrl"]})

    --每日登录弹框
    PluginProcessModel:PopNextPlugin()
end

function GoldSilverCtrl:IsDuringLastTwoDays( )
    return GoldSilverModel:IsDuringLastTwoDays()
end

function GoldSilverCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        print('on key back clicked')
        local viewNode = self._viewNode
        if viewNode.Panel_Rule:isVisible() then
            self:playEffectOnPress()
            viewNode.Panel_Rule:setVisible(false)
		elseif(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function GoldSilverCtrl:onJumpRightPlace( )
    local level = GoldSilverModel:GetCurLevel()
    --等级小于4不处理
    if level < 4 then return end 
   
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()
    if not rewardConfig then return end
    local levelCount = #rewardConfig

    local viewNode = self._viewNode
    local percent = 0
    if level >= (levelCount - 4) then
        percent = 100
    else
        percent = 10*(level - 3.5)/3.5
    end
    if percent > 100 then
        percent = 100
    end
    viewNode.Scroll_Reward:jumpToPercentHorizontal(percent)
end

function GoldSilverCtrl:onKeyBack()
    PluginProcessModel:stopPluginProcess()
    GoldSilverCtrl.super.onKeyBack(self)
end

--保存当前领取的位置，更新之后恢复到该位置
function GoldSilverCtrl:saveTakePosition()
    if not self._viewNode then return end
    local container = self._viewNode.Scroll_Reward:getInnerContainer()
    self._cachePos = cc.p(container:getPosition())
end

return GoldSilverCtrl