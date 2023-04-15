local MyGameCardMakerTool = class("MyGameCardMakerTool")
my.addInstance(MyGameCardMakerTool)

function MyGameCardMakerTool:ctor(toolsPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end

    self._cardMakerToolNode     = toolsPanel
    self._gameController        = gameController

    self._Buy_pic        = self._cardMakerToolNode:getChildByName("Buy_pic")
    self._Time_text      = self._cardMakerToolNode:getChildByName("Time_text")
    self._CardMaker_bg   = self._cardMakerToolNode:getChildByName("cardMaker_bg")
    self._Red_point      = self._cardMakerToolNode:getChildByName("red_point")
    self._CardMakerBtn   = self._cardMakerToolNode:getChildByName("Button_CardMaker")

    self._CardMakerCountdown = 0
    self._CardMakerTimer = nil

    self:init()
    self:setCardMakerInfo()
end

function MyGameCardMakerTool:init()
    local function onClickCardMakerBtn()
        self:onShowClickCardMaker()
    end
    self._CardMakerBtn:addClickEventListener(onClickCardMakerBtn)
    --self._cardMakerToolNode:setVisible(true)
end

function MyGameCardMakerTool:onShowClickCardMaker()
    self._gameController:playBtnPressedEffect()

    if self._CardMaker_bg:isVisible() then
        --cardMaker_bg:setVisible(false)
        self:OnShowCardMakerInfo(false, true)
    else
        if self._Time_text:isVisible() or self._Red_point:isVisible() then  --倒计时结束显示00:00，记牌器还是能使用
            --cardMaker_bg:setVisible(true)
            self:onRefreshCardMaker()
            self:OnShowCardMakerInfo(true, true)
        else
            if cc.exports.CardMakerInfo.nCardMakerNum and (cc.exports.CardMakerInfo.nCardMakerNum > 0 or cc.exports.CardMakerInfo.nCardMakerCountdown > 0) then
                --cardMaker_bg:setVisible(true)
                self:onRefreshCardMaker()
                self:OnShowCardMakerInfo(true, true)
            else
                --ShopModel:tryBuyCardRecorder(ShopModel:getShopItemData("prop", 1, "prop_cardrecorder_day"))
                my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = "prop", NoBoutCardRecorder = true}})
            end
        end
    end
end

function MyGameCardMakerTool:setCardMakerInfo()
    if cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
        self._Buy_pic:setVisible(false)
        self._Time_text:setVisible(true)
        self._CardMaker_bg:setVisible(true)
        self._Red_point:setVisible(false)

        self:onRefreshCardMaker()

        self._CardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown
        self._Time_text:setString(self:getCardMakerTime(self._CardMakerCountdown))
        if not self._CardMakerTimer then
            self._CardMakerTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateCardMakerTime),1,false)
        end
    elseif cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
            self._Buy_pic:setVisible(false)
            self._Time_text:setVisible(false)
            self._CardMaker_bg:setVisible(true)
            self._Red_point:setVisible(true)
    
            if cc.exports.CardMakerInfo.nCardMakerNum > 99 then
                self._Red_point:getChildByName("num"):setString("99+")
            else
                self._Red_point:getChildByName("num"):setString(cc.exports.CardMakerInfo.nCardMakerNum)
            end
            
            self:onRefreshCardMaker()
    else
        self._Buy_pic:setVisible(true)
        self._Time_text:setVisible(false)
        self._CardMaker_bg:setVisible(false)
        self._Red_point:setVisible(false)
    end
    self:onShowCardMakerRank()
end

function MyGameCardMakerTool:updateCardMakerTime(delta)
    if self._CardMakerCountdown and self._CardMakerCountdown > 0 then
        self._CardMakerCountdown = self._CardMakerCountdown - 1
        self._Time_text:setString(self:getCardMakerTime(self._CardMakerCountdown))
    else
        if self._CardMakerTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CardMakerTimer)
            self._CardMakerTimer = nil
        end
    end
end

function MyGameCardMakerTool:onShowCardMakerRank()
    local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
    if rank < 1 then
        rank = 1
    end
    local pos = {463.50, 432, 401, 370, 339, 308, 277, 246, 215, 184, 153, 122, 91}
    self._CardMaker_bg:getChildByName("rank_tag" ):setPositionX(pos[rank])
end

function MyGameCardMakerTool:onRefreshCardMaker()
    for i=1,15 do
        local text = self._CardMaker_bg:getChildByName("Text_" .. i)
        local str = self._gameController._MyGameCardMakerInfo.ThrowCardByIndex[i]
        text:setString(str)
        if str > 0 then
            text:setColor(cc.c3b(208, 64, 8))
        else
            text:setColor(cc.c3b(140, 140, 140))
        end
    end
end

function MyGameCardMakerTool:OnShowCardMakerInfo(visible, isTouch)
    local isVisible = visible or false
    local tag = false
    if isVisible and cc.exports.CardMakerInfo.nCardMakerNum and (not self._Buy_pic:isVisible()) then
        self._CardMaker_bg:setScale(0.4)
        self._CardMaker_bg:runAction(cc.ScaleTo:create(0.2, 1, 1))
        self._CardMaker_bg:setVisible(isVisible)
        tag = true
    else
        self._CardMaker_bg:setVisible(false)
    end

    if isTouch then
        local data = {}
        data.isVisible = tag
        local cacheFile = "CardMaker.xml"
        my.saveCache(cacheFile,data)
    end
end

function MyGameCardMakerTool:getTime(countdown)
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
end

function MyGameCardMakerTool:getCardMakerTime(countdown)
    local timeStr = self:getTime(countdown)
    local dateTab = string.split(timeStr, ":")
    if dateTab[1] and tonumber(dateTab[1]) > 24 then
        local day = math.ceil(tonumber(dateTab[1])/24)
        local str = ""
        if day > 99 then
            str = "剩余天数:99+"
        else
            str = "剩余天数:" .. day
        end
        return str
    else
        return timeStr
    end
end

function MyGameCardMakerTool:updateCardMakerCountInGame()
    if self._gameController and self._gameController:isGameRunning() then
        if (cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0)
        or (cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0) then
            --local function setInfo(  )
                self._Red_point:setVisible(true)
                self._Buy_pic:setVisible(false)

                if my.isCacheExist("CardMaker.xml") then
                    local dateInfo = my.readCache("CardMaker.xml")
                    dateInfo=checktable(dateInfo)
                    self._CardMaker_bg:setVisible(dateInfo.isVisible)
                else
                    self._CardMaker_bg:setVisible(true)
                end
                
                self:updateCardMakerCount()
            --end
           --my.scheduleOnce(setInfo, 0.3)
        end
    end
end

function MyGameCardMakerTool:updateCardMakerCount()
    if cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
        self._Red_point:setVisible(false)
        return
    end
    
    if cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
        cc.exports.CardMakerInfo.nCardMakerNum = cc.exports.CardMakerInfo.nCardMakerNum -1
        if cc.exports.CardMakerInfo.nCardMakerNum > 99 then
            self._Red_point:getChildByName("num"):setString("99+")
        else
            self._Red_point:getChildByName("num"):setString(cc.exports.CardMakerInfo.nCardMakerNum)
        end

        self._Time_text:setVisible(false)
    end
end

function MyGameCardMakerTool:AddCardMakerCount()
    if self._Red_point:isVisible() and cc.exports.CardMakerInfo.nCardMakerNum then
        cc.exports.CardMakerInfo.nCardMakerNum = cc.exports.CardMakerInfo.nCardMakerNum + 1
    end
end

function MyGameCardMakerTool:onExit()
    if self._CardMakerTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CardMakerTimer)
        self._CardMakerTimer = nil
    end
end

return MyGameCardMakerTool
