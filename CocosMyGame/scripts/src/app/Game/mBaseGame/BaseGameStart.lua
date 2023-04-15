
local BaseGameStart = class("BaseGameStart")

function BaseGameStart:create(startPanel, gameController)
    return BaseGameStart.new(startPanel, gameController)
end

function BaseGameStart:ctor(startPanel, gameController)
    self._gameController        = gameController

    self._startPanel            = startPanel
    self._btnStart              = nil
    self._btnChange             = nil
    self._btnRandom             = nil
    self._waitingTip            = nil

    self:init()
end

function BaseGameStart:init()
    if not self._startPanel then return end
    
    local function onStartGame()
        self:onStartGame()
    end
    self._btnStart = self._startPanel:getChildByName("Start_btn_start")
    if self._btnStart then
        self._btnStart:addClickEventListener(onStartGame)
    end

    local function onChangeTable()
        self:onChangeTable()
    end
    self._btnChange = self._startPanel:getChildByName("Start_btn_change")
    if self._btnChange then
        self._btnChange:addClickEventListener(onChangeTable)
    end

    local function onRandomTable()
        self:onRandomTable()
    end
    self._btnRandom = self._startPanel:getChildByName("Start_btn_random")
    if self._btnRandom then
        self._btnRandom:addClickEventListener(onRandomTable)
    end

    self._waitingTip = self._startPanel:getChildByName("Start_sp_waiting")

    self:setVisible(false)
end

function BaseGameStart:onStartGame()
    self._gameController:playBtnPressedEffect()

    if self._gameController then
        self._gameController:onStartGame()
    end
end

function BaseGameStart:onChangeTable()
    self._gameController:playBtnPressedEffect()

    if self._gameController then
        self._gameController:onChangeTable()
    end
end

function BaseGameStart:onRandomTable()
    self._gameController:playBtnPressedEffect()

    if self._gameController then
        self._gameController:onRandomTable()
    end
end

function BaseGameStart:onGameExit()
    self:stopChangeBtnTimer()
end

function BaseGameStart:setVisible(visible)
    if self._startPanel then
        self._startPanel:setVisible(visible)
    end
end

function BaseGameStart:ope_ShowStart(bShow)
    if self._gameController and self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
        bShow = false
    end

    if bShow then
        if self._gameController then
            if self._gameController:isRandomRoom() then
                if self._btnRandom then
                    self._btnRandom:setVisible(true)
                end
                if self._btnChange then
                    self._btnChange:setVisible(false)
                end
            else
                if self._btnChange then
                    self._btnChange:setVisible(true)
                end
                if self._btnRandom then
                    self._btnRandom:setVisible(false)
                end
            end
        end

        if self._waitingTip then
            self._waitingTip:setVisible(false)
        end

        if self._btnStart then
            self._btnStart:setVisible(true)
            self._btnStart:setTouchEnabled(true)
            self._btnStart:setBright(true)
        end

        self:setVisible(true)
    else
        self:setVisible(false)
    end
end

function BaseGameStart:showWaitArrangeTable(bShow)
    if self._waitingTip then
        self._waitingTip:setVisible(bShow)
    end
    if bShow then
        if self._btnRandom then
            self._btnRandom:setVisible(false)
        end
        if self._btnStart then
            self._btnStart:setVisible(false)
        end
    end
end

function BaseGameStart:isWaitArrangeTableShow()
    if self._waitingTip then
        return self._waitingTip:isVisible()
    end
    return false
end

function BaseGameStart:rspStartGame()
    if self._btnStart then
        self._btnStart:setTouchEnabled(false)
         self._btnStart:setBright(false)
    end
    if self._btnChange then
        self._btnChange:setTouchEnabled(false)
        self._btnChange:setBright(false)

        local function onChangeBtnInterval(dt)
            self:onChangeBtnInterval()
        end
        self:stopChangeBtnTimer()
        self.changeBtnTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onChangeBtnInterval, 5.0, false)
    end
end

function BaseGameStart:onUserPosition()
    if self._btnStart then
        self._btnStart:setTouchEnabled(true)
        self._btnStart:setBright(true)
    end

    if self._btnChange then
        self._btnChange:setTouchEnabled(false)
        self._btnChange:setBright(false)

        local function onChangeBtnInterval(dt)
            self:onChangeBtnInterval()
        end
        self:stopChangeBtnTimer()
        self.changeBtnTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onChangeBtnInterval, 5.0, false)
    end
end

function BaseGameStart:onChangeBtnInterval()
    self:stopChangeBtnTimer()

    if self._btnChange then
        self._btnChange:setTouchEnabled(true)
        self._btnChange:setBright(true)
    end
end

function BaseGameStart:stopChangeBtnTimer()
    if self.changeBtnTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.changeBtnTimerID)
        self.changeBtnTimerID = nil
    end
end

return BaseGameStart
