
local BaseGameTools = class("BaseGameTools")

local TOOLS_INDEX = {
    TOOLS_INDEX_ADD         = 1,
    TOOLS_INDEX_QUIT        = 2,
    TOOLS_INDEX_SETTING     = 3,
    TOOLS_INDEX_SAFEBOX     = 4,
} 

function BaseGameTools:create(toolsPanel, expanding, gameController)
    return BaseGameTools.new(toolsPanel, expanding, gameController)
end

function BaseGameTools:ctor(toolsPanel, expanding, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._toolsPanel            = toolsPanel
    self._toolsExpanding        = expanding
    self._toolsMoving           = false

    self._background            = nil
    self._toolbtns              = {}
    self._btnpos                = {}

    self:init()
end

function BaseGameTools:init()
    if not self._toolsPanel then return end

    if self._toolsPanel then
        self._toolsPanel:setSwallowTouches(false)
    end

    self._background = self._toolsPanel:getChildByName("tools_sp_bg")

    local index = 1

    local function onAdd()
        self:onAdd()
    end
    local buttonAdd = self._toolsPanel:getChildByName("Tools_btn_add")
    if buttonAdd then
        buttonAdd:addClickEventListener(onAdd)

        self._toolbtns[index] = buttonAdd
        self._btnpos[index] = cc.p(buttonAdd:getPositionX(), buttonAdd:getPositionY())
        index = index + 1
    end

    local function onQuit()
        self:onQuit()
    end
    local buttonQuit = self._toolsPanel:getChildByName("Tools_btn_quit")
    if buttonQuit then
        buttonQuit:addClickEventListener(onQuit)

        self._toolbtns[index] = buttonQuit
        self._btnpos[index] = cc.p(buttonQuit:getPositionX(), buttonQuit:getPositionY())
        index = index + 1

        --[[
            local csbPath = "res/GameCocosStudio/game/GameScene.csb"
            local main = cc.CSLoader:createNode(csbPath)
            self._backToChartereRoom = main:getChildByName("Panel_Tools"):getChildByName("Tools_btn_quit")
            local function onBacktoCharteredRoom()
                self:onBacktoCharteredRoom()
            end
            self._backToChartereRoom:getParent():removeChild(self._backToChartereRoom)
            self._backToChartereRoom:addTo(buttonQuit)
            self._backToChartereRoom:addClickEventListener(onBacktoCharteredRoom)
            self._backToChartereRoom:setVisible(true)
            self._backToChartereRoom:setPosition(0,0)
            self._backToChartereRoom:setAnchorPoint(0,0)
            self._gameController._showCharteredBtn=self._backToChartereRoom
        --]]
    end

    local function onSetting()
        self:onSetting()
    end
    local buttonSetting = self._toolsPanel:getChildByName("Tools_btn_setting")
    if buttonSetting then
        buttonSetting:addClickEventListener(onSetting)

        self._toolbtns[index] = buttonSetting
        self._btnpos[index] = cc.p(buttonSetting:getPositionX(), buttonSetting:getPositionY())
        index = index + 1
    end

    local function onSafeBox()
        self:onSafeBox()
    end
    local buttonSafeBox = self._toolsPanel:getChildByName("Tools_btn_safebox")
    if buttonSafeBox then
        buttonSafeBox:addClickEventListener(onSafeBox)

        self._toolbtns[index] = buttonSafeBox
        self._btnpos[index] = cc.p(buttonSafeBox:getPositionX(), buttonSafeBox:getPositionY())
        index = index + 1
    end

    if not self._toolsExpanding then
        self:setToolsIndent()
    end
end

function BaseGameTools:onAdd()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end

    local duration = 0.3

    if self._toolsExpanding then
        if self._background then
            self._background:setVisible(false)
        end

        if self._toolbtns[1] then
            local actionTo = cc.RotateTo:create(duration, 720)
            self._toolbtns[1]:runAction(actionTo)
        end

        for i = 2, #self._toolbtns do
            if self._toolbtns[i] then
                local actionTo = cc.MoveTo:create(duration, self._btnpos[1])
                self._toolbtns[i]:runAction(actionTo)

                local actionFade = cc.FadeOut:create(duration / 2)
                self._toolbtns[i]:runAction(actionFade)
            end
        end

        self._toolsExpanding = false
    else
        if self._toolbtns[1] then
            local actionTo = cc.RotateTo:create(duration, -765)
            self._toolbtns[1]:runAction(actionTo)
        end

        for i = 2, #self._toolbtns do
            if self._toolbtns[i] then
                local actionTo = cc.MoveTo:create(duration, self._btnpos[i])
                self._toolbtns[i]:runAction(actionTo)

                local actionFade = cc.FadeIn:create(duration / 2)
                self._toolbtns[i]:runAction(actionFade)
            end
        end

        self._toolsExpanding = true
    end

    self._toolsMoving = true

    local function onToolsActionFinished(dt)
        self:onToolsActionFinished(dt)
    end
    self:stopToolsActionTimer()
    self.toolsActionTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onToolsActionFinished, duration, false)
end

function BaseGameTools:stopToolsActionTimer()
    if self.toolsActionTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.toolsActionTimerID)
        self.toolsActionTimerID = nil
    end
end

function BaseGameTools:onToolsActionFinished()
    self:stopToolsActionTimer()

    self._toolsMoving = false

    if self._toolsExpanding and self._background then
        self._background:setVisible(true)
    end
end

function BaseGameTools:onQuit()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end
    print("onQuit")

    if self._gameController then
        self._gameController:onQuit()
    end
end

function BaseGameTools:onSetting()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end
    print("onSetting")

    if self._gameController then
        self._gameController:onSetting()
    end
end

function BaseGameTools:onSafeBox()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end
    print("onSafeBox")

    if self._gameController then
        self._gameController:onSafeBox()
    end
end

function BaseGameTools:setToolsIndent()
    if not self._toolsExpanding then
        if self._background then
            self._background:setVisible(false)
        end

        for i = 2, #self._toolbtns do
            if self._toolbtns[i] then
                self._toolbtns[i]:setPosition(self._btnpos[1])
                self._toolbtns[i]:setOpacity(0)
            end
        end
    end
end

function BaseGameTools:hideTools()
    if self._toolsExpanding then
        self:onAdd()
    end
end

function BaseGameTools:onGameExit()
    self:stopToolsActionTimer()
end

function BaseGameTools:setVisible(visible)
    if self._toolsPanel then
        self._toolsPanel:setVisible(visible)
    end
end

function BaseGameTools:setPosition(x, y)
    if self._toolsPanel then
        self._toolsPanel:setPosition(x, y)
    end
end

function BaseGameTools:enableBtn(index, bEnable)
    if self._toolbtns[index] then
        self._toolbtns[index]:setTouchEnabled(bEnable)
        self._toolbtns[index]:setBright(bEnable)
    end
end

function BaseGameTools:onGameStart()
    self:enableBtn(TOOLS_INDEX.TOOLS_INDEX_QUIT, false)
    self:disableSafeBox()
end

function BaseGameTools:onGameWin()
    self:enableBtn(TOOLS_INDEX.TOOLS_INDEX_QUIT, true)
    self:enableBtn(TOOLS_INDEX.TOOLS_INDEX_SAFEBOX, true)
end

function BaseGameTools:onEnterRandomGame()
    self:disableSafeBox()
end

function BaseGameTools:disableSafeBox()
    self:enableBtn(TOOLS_INDEX.TOOLS_INDEX_SAFEBOX, false)
end

function BaseGameTools:isQuitBtnEnabled()
    if self._toolbtns[TOOLS_INDEX.TOOLS_INDEX_QUIT] then
        return self._toolbtns[TOOLS_INDEX.TOOLS_INDEX_QUIT]:isBright()
    end
end

--function BaseGameTools:onBacktoCharteredRoom()
--    self._gameController:showCharteredRoom(false)
--end

return BaseGameTools
