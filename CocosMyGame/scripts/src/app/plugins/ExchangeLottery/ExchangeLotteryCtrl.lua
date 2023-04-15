local ExchangeLotteryCtrl = class("ExchangeLotteryCtrl")
local viewCreater       	    = import("src.app.plugins.ExchangeLottery.ExchangeLotteryView")
local ExchangeLotteryModel      = import("src.app.plugins.ExchangeLottery.ExchangeLotteryModel"):getInstance()
local Def                       = import('src.app.plugins.ExchangeLottery.ExchangeLotteryDef')
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

function ExchangeLotteryCtrl:ctor(...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self._waitingClick = false
    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
end

function ExchangeLotteryCtrl:onEnter(...)
    self:updateUI()
end

function ExchangeLotteryCtrl:initialListenTo( )

end

function ExchangeLotteryCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.Btn_DrawOne:addClickEventListener(handler(self, self.onClickDrawOne))
    viewNode.Btn_DrawTen:addClickEventListener(handler(self, self.onClickDrawTen))
    viewNode.Btn_Buy:addClickEventListener(handler(self, self.onBuyEmoji))
    viewNode.Btn_Help:addClickEventListener(function ()
        my.informPluginByName({pluginName='ExchangeLotteryRuleCtrl'})
    end)
end

function ExchangeLotteryCtrl:updateUI()
    if nil == ExchangeLotteryModel:GetExchangeLotteryInfo() then 
        ExchangeLotteryModel:gc_GetExchangeLotteryInfo()
        return
    end

    self:freshRewards()
    self:freshSeizeCount()
    self:freshFirstFree()
    self:freshDrawTenGift()
end

function ExchangeLotteryCtrl:freshRewards()
    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local rewardList = info.stRewardList

    local function getImagePath(nType,nCount)
        local Path = "hallcocosstudio/images/plist/ExchangeLottery/"
        if nType == Def.REWARD_TYPE_SILVER then
            if nCount>=10000 then 
                Path = Path .. "Img_Silver4.png"
            elseif nCount>=5000 then
                Path = Path .. "Img_Silver3.png"
            elseif nCount>=1000 then
                Path = Path .. "Img_Silver2.png"
            else
                Path = Path .. "Img_Silver1.png"
            end
        elseif nType == Def.REWARD_TYPE_TICKET then
            if nCount>=100 then 
                Path = Path .. "Img_Ticket4.png"
            elseif nCount>=50 then
                Path = Path .. "Img_Ticket3.png"
            elseif nCount>=20 then
                Path = Path .. "Img_Ticket2.png"
            else
                Path = Path .. "Img_Ticket1.png"
            end
        elseif nType == Def.REWARD_TYPE_CARDMARKER_1D then
            Path = Path .. "1tian.png"
        elseif nType == Def.REWARD_TYPE_CARDMARKER_7D then
            Path = Path .. "7tian.png"
        elseif nType == Def.REWARD_TYPE_CARDMARKER_30D then
            Path = Path .. "30tian.png"
        end
        return Path
    end
    
    local viewNode = self._viewNode

    for i=1,rewardList.nNum do
        local award = viewNode.Panel_Main:getChildByName("Node" .. i)
        if award then
            local type  = rewardList.stReward[i].nType
            local count = rewardList.stReward[i].nCount

            award:getChildByName("Img_Silver"):setVisible(false)
            award:getChildByName("Img_Ticket"):setVisible(false)
            award:getChildByName("Img_CardMarker"):setVisible(false)
            award:getChildByName("Img_Jump"):setVisible(false)
            award:getChildByName("Ani_Hit"):setVisible(false)
            local imgNode
            local fntNum = award:getChildByName("Fnt_Num")
            if type == Def.REWARD_TYPE_SILVER then
                imgNode = award:getChildByName("Img_Silver")
            elseif type == Def.REWARD_TYPE_TICKET then
                imgNode = award:getChildByName("Img_Ticket")
            else
                imgNode = award:getChildByName("Img_CardMarker")
            end
            imgNode:setVisible(true)

            local imgPath = getImagePath(type,count)
            imgNode:loadTexture(imgPath,ccui.TextureResType.plistType)
            fntNum:setString(count)
        end
    end
end

function ExchangeLotteryCtrl:freshSeizeCount( )
    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local nSeizeCount = info.nCount
    local nFirstFree = info.nFirstFree
    local nFreeCount = nFirstFree == 1 and 1 or 0
    local viewNode = self._viewNode
    viewNode.Text_Count:setString(tostring(nSeizeCount));

    viewNode.Ani_DrawOne:setVisible(false)
    viewNode.Ani_DrawTen:setVisible(false)
    local aniBtnFile= "res/hallcocosstudio/activitycenter/cj_anniu.csb"
    if nSeizeCount>0 or nFirstFree==1 then
        viewNode.Ani_DrawOne:setVisible(true)
        viewNode.Ani_DrawOne:stopAllActions()
        local action = cc.CSLoader:createTimeline(aniBtnFile)
        if not tolua.isnull(action) then
            viewNode.Ani_DrawOne:runAction(action)
            action:play("animation0", true)
        end
    end
    if nSeizeCount>=10 then
        viewNode.Ani_DrawTen:setVisible(true)
        viewNode.Ani_DrawTen:stopAllActions()
        local action = cc.CSLoader:createTimeline(aniBtnFile)
        if not tolua.isnull(action) then
            viewNode.Ani_DrawTen:runAction(action)
            action:play("animation0", true)
        end  
    end
end

function ExchangeLotteryCtrl:freshFirstFree( )
    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local nFirstFree = info.nFirstFree

    local viewNode = self._viewNode
    viewNode.Img_Bubble1:setVisible(nFirstFree == 1)
end

function ExchangeLotteryCtrl:freshDrawTenGift( )
    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local nGiveCardMaker = info.nGiveCardMaker
    local viewNode = self._viewNode
    viewNode.Img_Bubble2:setVisible(nGiveCardMaker == 1)
end

function ExchangeLotteryCtrl:onClickDrawOne( )
    my.playClickBtnSound()
    if self._waitingClick then return end
    if self._waitingResponse or self._playingDrawAni then return end


    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local nSeizeCount = info.nCount
    local nFirstFree = info.nFirstFree

    if nSeizeCount>0 or nFirstFree==1 then
        self._waitingResponse = true
        self._CDTimer = my.scheduleOnce(function()
            if self then
                self._CDTimer = nil
                self._waitingResponse = false
            end
        end, 2.5)
        BroadcastModel:stopInsertMessage()
        ExchangeLotteryModel:gc_ExchangeLotteryDrawReq(1)

        local user=mymodel('UserModel'):getInstance()
        local safeDeposit = user.nSafeboxDeposit
        local deposit = user.nDeposit
    
        my.dataLink(cc.exports.DataLinkCodeDef.JXDB_DRAW_ONE, {safeDeposit=safeDeposit, selfDeposit=deposit})
    else
        self._waitingResponse = true
        self._CDTimer = my.scheduleOnce(function()
            if self then
                self._CDTimer = nil
                self._waitingResponse = false
            end
        end, 1)
        my.informPluginByName({pluginName = "ChooseDialog", params = {
            onOk = function()
                my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = 'expression'}})
                return
            end,
            tipContent = Def.TipContent
        }})
    end
end

function ExchangeLotteryCtrl:onClickDrawTen( )
    my.playClickBtnSound()
    if self._waitingClick then return end
    if self._waitingResponse or self._playingDrawAni then return end

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = ExchangeLotteryModel:GetExchangeLotteryInfo()
    if not info then return end

    local nSeizeCount = info.nCount
    if nSeizeCount >= 50 then  --剩余大于50次的时候，提示玩家是否次数全部用完
        local lotteryTip = Def.TipQuickLotteryContent
        local checkTip = Def.TipNoRemindAgainContent
        if nSeizeCount > 100 then
            lotteryTip = Def.TipQuickLottery100Content
            nSeizeCount = 100
        end
        local remindAgain = CacheModel:getCacheByKey("ELCheckBoxSelected")
        if remindAgain and remindAgain == 1 then
            self:sendExchangeLotteryReq(nSeizeCount)
        else
            my.informPluginByName({pluginName = "ChooseDialog", params = {
                onOk = function(checkBoxSelected)
                    if checkBoxSelected then
                        CacheModel:saveInfoToCache("ELCheckBoxSelected", 1)
                    else
                        CacheModel:saveInfoToCache("ELCheckBoxSelected", 0)
                    end
                    self:sendExchangeLotteryReq(nSeizeCount)
                end,
                onCancel = function(checkBoxSelected)
                    self:sendExchangeLotteryReq(10)
                end,
                onClose=function(checkBoxSelected)
                    self:sendExchangeLotteryReq(10)
                end,
                tipContent = lotteryTip,
                checkBoxContent = checkTip
            }})
        end

        return
    end

    if nSeizeCount<10 then
        self._waitingResponse = true
        self._CDTimer = my.scheduleOnce(function()
            if self then
                self._CDTimer = nil
                self._waitingResponse = false
            end
        end, 1)
        my.informPluginByName({pluginName = "ChooseDialog", params = {
            onOk = function()
                my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = 'expression'}})
                return
            end,
            tipContent = Def.TipContent
        }})
    else
        self._waitingResponse = true
        self._CDTimer = my.scheduleOnce(function()
            if self then
                self._CDTimer = nil
                self._waitingResponse = false
            end
        end, 2.5)
        BroadcastModel:stopInsertMessage()
        ExchangeLotteryModel:gc_ExchangeLotteryDrawReq(10)

        local user=mymodel('UserModel'):getInstance()
        local safeDeposit = user.nSafeboxDeposit
        local deposit = user.nDeposit
    
        my.dataLink(cc.exports.DataLinkCodeDef.JXDB_DRAW_TEN, {safeDeposit=safeDeposit, selfDeposit=deposit})
    end
end

function ExchangeLotteryCtrl:onBuyEmoji()
    my.dataLink(cc.exports.DataLinkCodeDef.JXDB_BUY_LIGHTING)
    my.playClickBtnSound()
    if self._waitingClick then return end
    if self._waitingResponse or self._playingDrawAni then return end

    self._waitingResponse = true
    self._CDTimer = my.scheduleOnce(function()
        if self then
            self._CDTimer = nil
            self._waitingResponse = false
        end
    end, 1)
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end
    my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = 'expression'}})
end

function ExchangeLotteryCtrl:onGetDrawResult(data)
    self:freshSeizeCount()
    self:freshFirstFree()

    if(type(data)~='table' or type(data.value)~='table')then
        return
    end
    self._playingDrawAni = true
    self._waitingResponse = false
    local resultList = data.value.resultList
    self._resultList = resultList
    -- local num = resultList.nNum
    -- if num<=0 then
    --     self._waitingResponse = false
    --     return
    -- end

    local reward = resultList.stReward[1]
    local nHitIndex = reward.nIndex + 1

    self:showLotteryResult(nHitIndex,resultList)
end

function ExchangeLotteryCtrl:showLotteryResult(nHitIndex,resultList)
    self:HideNodeEffect()
    
    self._lastIndex = 1
    self._jumpIndex = 1
    self._round = 0
    local function Jump()
        local viewNode = self._viewNode
        if self._round >=1 then
            local lastNode = viewNode.Panel_Main:getChildByName("Node" .. self._lastIndex)
            lastNode:getChildByName("Img_Jump"):setVisible(false)
            local award = viewNode.Panel_Main:getChildByName("Node" .. self._jumpIndex)
            award:getChildByName("Img_Jump"):setVisible(true)
            if nHitIndex == self._jumpIndex then
                --动画结束
                if self._JumpTimerID then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._JumpTimerID)
                    self._JumpTimerID = nil
                end

                local aniNode = award:getChildByName("Ani_Hit")
                aniNode:setVisible(true)
                local aniHitFile= "res/hallcocosstudio/activitycenter/xz_guang.csb"

                aniNode:stopAllActions()
                local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
                if not tolua.isnull(aniDraw) then
                    aniNode:runAction(aniDraw)
                    aniDraw:play("animation0", true)
                end
                aniNode:setVisible(true)

                local function call_back()
                    local rewardList = {}
                    for i = 1,resultList.nNum do
                        local reward = resultList.stReward[i]
                        table.insert( rewardList,{nType = reward.nType,nCount = reward.nCount})
                    end
                    if resultList.nNum == 1 then
                        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList}})
                    else
                        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOneByOne = true}})
                    end
                end
                self:twinkle(award:getChildByName("Img_Jump"),call_back)
            else
                self._lastIndex = self._jumpIndex
                self._jumpIndex = self._jumpIndex + 1
                if self._jumpIndex >10 then
                    self._round = self._round + 1
                    self._jumpIndex = 1
                end
            end
        else
            local lastNode = viewNode.Panel_Main:getChildByName("Node" .. self._lastIndex)
            lastNode:getChildByName("Img_Jump"):setVisible(false)
            local award = viewNode.Panel_Main:getChildByName("Node" .. self._jumpIndex)
            award:getChildByName("Img_Jump"):setVisible(true)
            self._lastIndex = self._jumpIndex
            self._jumpIndex = self._jumpIndex + 1
            if self._jumpIndex >10 then
                self._round = self._round + 1
                self._jumpIndex = 1
            end
        end
    end
    self._soundHandle = audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/Lottery2.mp3'),false)
    if self._JumpTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._JumpTimerID)
        self._JumpTimerID = nil
    end
    self._JumpTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(Jump, 0.062, false)
end

function ExchangeLotteryCtrl:onExit()
    if self._JumpTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._JumpTimerID)
        self._JumpTimerID = nil
    end
    if self._CDTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimer)
        self._CDTimer = nil
    end
    if self._TwinkleTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TwinkleTimer)
        self._TwinkleTimer = nil
    end
    if self._dalayTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dalayTimer)
        self._dalayTimer = nil
    end

    if self._soundHandle then
        audio.stopSound(self._soundHandle)
        self._soundHandle = nil
    end
    self._waitingResponse = false
    BroadcastModel:ReStartInsetMessage()
end

function ExchangeLotteryCtrl:HideNodeEffect()
    local viewNode = self._viewNode
    for i=1,10 do
        local award = viewNode.Panel_Main:getChildByName("Node" .. i)
        if award then
            award:getChildByName("Img_Jump"):setVisible(false)
            local aniNode = award:getChildByName("Ani_Hit")
            aniNode:stopAllActions()
            aniNode:setVisible(false)
        end
    end
end

function ExchangeLotteryCtrl:onDrawFailed( )
    self._waitingResponse = false
end

function ExchangeLotteryCtrl:twinkle(node,call_back)
    if not tolua.isnull(node) then
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.12),cc.FadeOut:create(0.03),cc.DelayTime:create(0.12),cc.FadeIn:create(0.03))
        local reAction = cc.Repeat:create(sequence,4)
        node:runAction(cc.Sequence:create(reAction,cc.DelayTime:create(0.0),cc.CallFunc:create(function()
            self._dalayTimer = my.scheduleOnce(function()
                self._waitingResponse = false
                self._playingDrawAni = false
                self._hasClickedClose = false
            end,0.5)
            BroadcastModel:ReStartInsetMessage()
            if call_back then
                call_back()
            end
        end)))
    end
end

function ExchangeLotteryCtrl:onClickClose()
    if self._playingDrawAni and type(self._resultList)=="table" then
        if self._JumpTimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._JumpTimerID)
            self._JumpTimerID = nil
        end
        if self._TwinkleTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TwinkleTimer)
            self._TwinkleTimer = nil
        end

        if self._soundHandle then
            audio.stopSound(self._soundHandle)
            self._soundHandle = nil
        end

        if self._hasClickedClose then
            return
        end
        self._hasClickedClose = true
        if self._dalayTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dalayTimer)
            self._dalayTimer = nil
        end

        self:HideNodeEffect()
        local viewNode =self._viewNode
        local reward = self._resultList.stReward[1]
        local nHitIndex = reward.nIndex + 1
        local award = viewNode.Panel_Main:getChildByName("Node" .. nHitIndex)
        award:getChildByName("Img_Jump"):setVisible(true)
        local aniNode = award:getChildByName("Ani_Hit")
        aniNode:setVisible(true)
        local aniHitFile = "res/hallcocosstudio/activitycenter/xz_guang.csb"

        aniNode:stopAllActions()
        local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
        if not tolua.isnull(aniDraw) then
            aniNode:runAction(aniDraw)
            aniDraw:play("animation0", true)
        end
        aniNode:setVisible(true)

        local function call_back()
            local rewardList = {}
            for i = 1, self._resultList.nNum do
                local reward = self._resultList.stReward[i]
                table.insert(rewardList, {nType = reward.nType, nCount = reward.nCount})
            end
            if self._resultList.nNum == 1 then
                my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
            else
                my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList, showOneByOne = true}})
            end
        end
        self:twinkle(award:getChildByName("Img_Jump"), call_back)
        return false
    elseif self._waitingResponse then 
        return false
    end
    return true
end

function ExchangeLotteryCtrl:setViewIndexer(viewIndexer)
    self._viewNode=viewIndexer
    return self._viewNode
end

function ExchangeLotteryCtrl:setClickCD(bEnable)
    self._waitingClick = bEnable
end

--发送惊喜夺宝请求
function ExchangeLotteryCtrl:sendExchangeLotteryReq(lotteryCount)
    self._waitingResponse = true
    self._CDTimer = my.scheduleOnce(function()
        if self then
            self._CDTimer = nil
            self._waitingResponse = false
        end
    end, 2.5)

    BroadcastModel:stopInsertMessage()
    ExchangeLotteryModel:gc_ExchangeLotteryDrawReq(lotteryCount)

    local user=mymodel('UserModel'):getInstance()
    local safeDeposit = user.nSafeboxDeposit
    local deposit = user.nDeposit

    my.dataLink(cc.exports.DataLinkCodeDef.JXDB_DRAW, {safeDeposit=safeDeposit, selfDeposit=deposit, lotteryCount=lotteryCount})
    return
end

return ExchangeLotteryCtrl