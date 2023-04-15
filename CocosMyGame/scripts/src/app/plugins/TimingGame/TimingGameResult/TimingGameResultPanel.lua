local TimingGameResultPanel = class("TimingGameResultPanel", ccui.Layout)
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder

my.setmethods(TimingGameResultPanel,PropertyBinder)

function TimingGameResultPanel:ctor(gameWin, gameController)
    if not gameWin then printError("gameWin is nil!!!") return end
    if not gameController then printError("gameController is nil!!!") return end
    self._gameWin               = gameWin
    self._gameController        = gameController

    self._resultPanel           = nil

    self._selfChairNO   = (gameController._selfChairNO or gameController:getMyChairNO()) + 1
    self._oldTimingGameData = gameController._oldTimingGameData

    if self.onCreate then self:onCreate() end
end

function TimingGameResultPanel:onCreate()
    self:init()
end

function TimingGameResultPanel:init()
    self:initResultPanel()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self, self.refreshView))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getApplySucceedFromSvr"], handler(self, self.refreshView))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_restartGame"], handler(self, self.onClose))
end

function TimingGameResultPanel:onExit()
    print("TimingGameResultPanel:onExit")
    if self._gameController then
        self._gameController:hideBannerAdvert()
    end
    self:removeEventHosts()
end

function TimingGameResultPanel:isLose()
    if self._gameWin then     
        local score = self._gameWin.nScoreDiffs[self._selfChairNO] --这个值是加过1的
        if score > 0 then
            return false
        else
            return true
        end
    end

    return false
end

function TimingGameResultPanel:initResultPanel()
    local csbPath = "res/hallcocosstudio/TimingGame/TimingGameResult.csb"
    if self:isLose() then
        self._gameController:playGamePublicSound("Snd_lose.mp3")
    else
        self._gameController:playGamePublicSound("Snd_win.mp3")
    end
    
    self._resultPanel = cc.CSLoader:createNode(csbPath)
    if self._resultPanel then
        self._resultPanel:setAnchorPoint(cc.p(0.5,0.5))
        self:addChild(self._resultPanel)
        SubViewHelper:adaptNodePluginToScreen(self._resultPanel, self._resultPanel:getChildByName("Panel_Shade"))
        self:initBtns()
        self:initDetails()
    end

    -- 广告模块 start
    local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
    print("AdvertModel:TimingGameResultPanel:initResultPanel")
    print("self._hasShowBanner: ", self._hasShowBanner)
    if self._gameController:isShowBanner() and not self._gameController._hasShowBanner then
        AdvertModel:showBannerAdvert()
        self._gameController._hasShowBanner = true
    end
    -- 广告模块 end
end

function TimingGameResultPanel:refreshView()
    if not self._resultPanel then
        return
    end
    local mainBox = self._resultPanel:getChildByName("Img_MainBox")
    local btnStart = mainBox:getChildByName("Btn_Start")
    local txtInfo = mainBox:getChildByName("Text_Info")

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    local infoDataSt = TimingGameModel:getInfoDataStamp()

    local btnType, status = TimingGameModel:getBtnStatus()
    if btnType == 1 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_xjks.png"
        btnStart:loadTextureNormal(path, ccui.TextureResType.plistType)
        btnStart:loadTexturePressed(path, ccui.TextureResType.plistType)
    elseif btnType == 2 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_baoming.png"
        btnStart:loadTextureNormal(path, ccui.TextureResType.plistType)
        btnStart:loadTexturePressed(path, ccui.TextureResType.plistType)
    elseif btnType == 4 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_ybm.png"
        btnStart:loadTextureNormal(path, ccui.TextureResType.plistType)
        btnStart:loadTexturePressed(path, ccui.TextureResType.plistType)
        btnStart:setTouchEnabled(false)
        btnStart:setBright(false)
    else
        local path = "hallcocosstudio/images/plist/TimingGame/btn_bmjs.png"
        btnStart:loadTextureNormal(path, ccui.TextureResType.plistType)
        btnStart:loadTexturePressed(path, ccui.TextureResType.plistType)
        btnStart:setTouchEnabled(false)
        btnStart:setBright(false)
    end
    
    local txtCurrentRank = mainBox:getChildByName("Text_CurrentRank")
    local txtRankChange = mainBox:getChildByName("Text_RankChange")
    local txtCurrentScore2 = mainBox:getChildByName("Text_CurrentScore2")

    txtCurrentRank:setString(infoData.ranking)
    local str
    if infoDataSt == self._oldTimingGameData[2] then --还未获取到新的infodata
    else
        if infoData.ranking > self._oldTimingGameData[1].ranking and self._oldTimingGameData[1].ranking ~= 0 then
            str = string.format("(↓%d)", infoData.ranking - self._oldTimingGameData[1].ranking)
        elseif infoData.ranking < self._oldTimingGameData[1].ranking then
            str = string.format("(↑%d)", self._oldTimingGameData[1].ranking - infoData.ranking)
        else
            str = ""
        end
        txtRankChange:setString(str)
        txtCurrentScore2:setString(infoData.rankingscore)

        self:showInfoText(config, infoData, txtInfo, btnType)
    end
end

function TimingGameResultPanel:initBtns()
    if not self._resultPanel then
        return
    end
    local mainBox = self._resultPanel:getChildByName("Img_MainBox")
    local btnQuit = mainBox:getChildByName("Btn_Quit")
    local btnRankList = mainBox:getChildByName("Btn_RankList")
    local btnStart = mainBox:getChildByName("Btn_Start")

    if btnQuit then
        btnQuit:addClickEventListener(function ()
            self:onQuit()
        end)
    end

    if btnRankList then
        btnRankList:addClickEventListener(function ()
            self._gameController:playBtnPressedEffect()
            my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameRank"}) end, 0)
        end) 
    end

    if btnStart then
        btnStart:setTouchEnabled(true)
        btnStart:setBright(true)

        btnStart:addClickEventListener(function ()
            local btnType, status = TimingGameModel:getBtnStatus()
            if btnType == 1 then
                self:onRestart()
            elseif btnType == 2 then
                if status == TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH then
                    TimingGameModel:showTips("门票不足!")
                    if cc.exports.getTimmingGameTicketEntranceSwitch() == 0 then
                        -- my.informPluginByName({pluginName='ToastPlugin',params={tipString="门票不足",removeTime=3}})
                    else
                        my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameGetTicket"}) end, 0)
                    end
                else
                    TimingGameModel:reqApplyMatch()
                    -- TimingGameModel:showTips("报名中，请稍后!")
                    -- my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameLayer"}) end, 0)
                end
            elseif btnType == 4 then
                TimingGameModel:showTips("已报名!")
                self:refreshView()
            else
                TimingGameModel:showTips("报名截止!")
                self:refreshView()
            end
        end)
    end
end

function TimingGameResultPanel:onQuit()
    self._gameController:playBtnPressedEffect()

    self._gameController._TimingGame_onQuit = true
    self:onExit()
    self._gameController:onCloseResultLayerEx()
end

function TimingGameResultPanel:onClose()
    self:onExit()
    if self._gameController then
        self._gameController:onCloseResultLayerEx()
    end
end

function TimingGameResultPanel:onRestart()
    self._gameController:playBtnPressedEffect()
    self:onExit()
    self._gameController:onRestart()
end

function TimingGameResultPanel:initDetails()
    if not self._resultPanel then
        return
    end
    local mainBox = self._resultPanel:getChildByName("Img_MainBox")
    local txtCurrentScore1 = mainBox:getChildByName("Text_CurrentScore1")
    local txtCurrentGetScore = mainBox:getChildByName("Text_GetScore")
    local txtCurrentScore2 = mainBox:getChildByName("Text_CurrentScore2")
    local txtCurrentRank = mainBox:getChildByName("Text_CurrentRank")
    local txtDesc = mainBox:getChildByName("Text_Desc")
    local txtRankChange = mainBox:getChildByName("Text_RankChange")
    local txtInfo = mainBox:getChildByName("Text_Info")
    txtInfo:setVisible(false)

    if not self._oldTimingGameData then return end

    local score = self._gameWin.nScoreDiffs[self._selfChairNO]

    txtCurrentScore1:setString(self._oldTimingGameData[1].seasonScore + score)
    local prefix = ""
    if score > 0 then
        prefix = "+"
    end
    txtCurrentGetScore:setString(prefix .. score)

    local infoData = TimingGameModel:getInfoData()
    local infoDataSt = TimingGameModel:getInfoDataStamp()
    local config = TimingGameModel:getConfig()
    
    if infoDataSt == self._oldTimingGameData[2] then --还未获取到新的infodata
        txtCurrentRank:setString(self._oldTimingGameData[1].ranking)
        txtRankChange:setString(string.format("(正在查询)"))
        txtCurrentScore2:setString(self._oldTimingGameData[1].rankingscore)
    else
        txtCurrentRank:setString(infoData.ranking)
        local str
        if infoData.ranking > self._oldTimingGameData[1].ranking and self._oldTimingGameData[1].ranking ~= 0 then
            str = string.format("(↓%d)", infoData.ranking - self._oldTimingGameData[1].ranking)
        elseif infoData.ranking < self._oldTimingGameData[1].ranking then
            str = string.format("(↑%d)", self._oldTimingGameData[1].ranking - infoData.ranking)
        else
            str = ""
        end
        txtRankChange:setString(str)
        txtCurrentScore2:setString(infoData.rankingscore)
        local btnType, status = TimingGameModel:getBtnStatus()
        self:showInfoText(config, infoData, txtInfo, btnType)
    end

    txtDesc:setString(string.format("每%d分钟刷新一次", math.floor(config.HallRefreshTime / 60) ))
end 
 
function TimingGameResultPanel:showInfoText(config, infoData, txtInfo, btnType)
    if btnType == 1 then
        txtInfo:setVisible(true)
        txtInfo:setString(string.format("当前局数（%d/%d）", infoData.seasonBoutNum, config.SeasonMaxBout))
    elseif btnType == 2 then
        txtInfo:setVisible(true)
        local applyStartTime = TimingGameModel:getTimeTable(infoData.applyStartTime)
        local applyEndTime = TimingGameModel:getTimeTable(infoData.applyEndTime)
        local stApplyStartTime = os.time(applyStartTime)
        local stApplyEndTime = os.time(applyEndTime)
        local stStartTime, stEndTime = TimingGameModel:getCurrentSeasonTime()
        local date = tonumber(os.date("%Y%m%d", TimingGameModel:getCurrentTime()))
        
        local infoApplyTime = infoData.applyedTime

        if date ~= infoData.applyDate or stApplyStartTime ~= stStartTime or
        stApplyEndTime ~= stEndTime then
            infoApplyTime = 0
        end
        local applyedTime = infoApplyTime + 1
        applyedTime = applyedTime <= 0 and 1 or applyedTime

        local applyTicketNums = config.ApplyTicketsNum[1]
        if applyedTime <= #config.ApplyTicketsNum then
            applyTicketNums = config.ApplyTicketsNum[applyedTime]
        else
            applyTicketNums = config.ApplyTicketsNum[#config.ApplyTicketsNum]
        end
        txtInfo:setString(string.format("报名需要%d张门票\n当前拥有%d张门票",
        applyTicketNums, TimingGameModel:getSelfTicketCount()))
    end
end

return TimingGameResultPanel