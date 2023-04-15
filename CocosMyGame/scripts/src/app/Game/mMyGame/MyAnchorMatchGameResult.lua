local MyAnchorMatchGameResult = class('MyAnchorMatchGameResult')
local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")

MyAnchorMatchGameResult.RESOURCE_PATH = 'res/GameCocosStudio/csb/Layer_AnchorGameResult.csb'

MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_WIN = 'res/GameCocosStudio/csb/Node_ResultTitle_Win.csb'
MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_LOSE = 'res/GameCocosStudio/csb/Node_ResultTitle_Lose.csb'
MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN = 'res/GameCocosStudio/csb/Node_ResultLightLoop_Win.csb'
MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE = 'res/GameCocosStudio/csb/Node_ResultLightLoop_Lose.csb'

MyAnchorMatchGameResult.IMG_ROLEHEAD_GIRL_WIN = 'res/Game/GamePic/GameContents/Role_Girl.png'
MyAnchorMatchGameResult.IMG_ROLEHEAD_GIRL_LOSE = 'res/Game/GamePic/GameContents/Role_Girl_L.png'
MyAnchorMatchGameResult.IMG_ROLEHEAD_BOY_WIN = 'res/Game/GamePic/GameContents/Role_Boy.png'
MyAnchorMatchGameResult.IMG_ROLEHEAD_BOY_LOSE = 'res/Game/GamePic/GameContents/Role_Boy_L.png'

function MyAnchorMatchGameResult:ctor(baseNode, gamecontroller, resultData)
    self._gameController = gamecontroller
    self._resultData = resultData

    self._resultLayer = nil
    self._autoStartTimer = nil
    self._autoStartTime = 10
    self._win = false
    self:calcWinLose()
    self:initUI(baseNode)
end

function MyAnchorMatchGameResult:calcWinLose()
    local selfChairNO = (self._gameController._selfChairNO or self._gameController:getMyChairNO())

    local winChairNo = 0
    for i = 1, 4 do
        if self._resultData.nPlace[i] == 1 then
            winChairNo = i - 1
            break
        end
    end

    if self._resultData then
        local MyGameUtilsInfoManager = self._gameController._baseGameUtilsInfoManager  
        if winChairNo == selfChairNO or winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(selfChairNO)) then
            self._win = true
        else
            self._win = false
        end
    end

    return false
end

function MyAnchorMatchGameResult:isWin()
    return self._win
end

function MyAnchorMatchGameResult:initUI(baseNode)
    local resultLayer = cc.CSLoader:createNode(MyAnchorMatchGameResult.RESOURCE_PATH)
    self._resultLayer = resultLayer
    local resultPanelAni = resultLayer:getChildByName('Panel_Main'):getChildByName('Panel_Animation')
    resultLayer:setLocalZOrder(SKGameDef.SK_ZORDER_RESULT)
    baseNode:addChild(resultLayer)
    resultLayer:setContentSize(display.size)
    ccui.Helper:doLayout(resultLayer)

    self:initAni(resultPanelAni)
    self:initRole(resultPanelAni)
    self:initBtns(resultPanelAni)
    self:initAutoStart(resultPanelAni)
end

function MyAnchorMatchGameResult:initAni(resultPanelAni)
    local nodeLightLoopAni = resultPanelAni:getChildByName('Node_ResultLightLoopAni')
    local nodeResultTitleAni = resultPanelAni:getChildByName('Node_ResultTitleAni')
    if self:isWin() then
        local lightLoopNode = cc.CSLoader:createNode(MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN)
        local lightLoopAni = cc.CSLoader:createTimeline(MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN)
        if lightLoopNode and lightLoopAni then
            nodeLightLoopAni:addChild(lightLoopNode)
            lightLoopNode:runAction(lightLoopAni)
            lightLoopAni:play('animation_LightLoop', true)
        end

        local titleNode = cc.CSLoader:createNode(MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_WIN)
        local titleAni = cc.CSLoader:createTimeline(MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_WIN)
        if titleNode and titleAni then
            nodeResultTitleAni:addChild(titleNode)
            titleNode:runAction(titleAni)
            titleAni:play('animation_TitleWin', false)
        end

    else
        local lightLoopNode = cc.CSLoader:createNode(MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE)
        local lightLoopAni = cc.CSLoader:createTimeline(MyAnchorMatchGameResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE)
        if lightLoopNode and lightLoopAni then
            nodeLightLoopAni:addChild(lightLoopNode)
            lightLoopNode:runAction(lightLoopAni)
            lightLoopAni:play('animation_LightLoop', true)
        end

        local titleNode = cc.CSLoader:createNode(MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_LOSE)
        local titleAni = cc.CSLoader:createTimeline(MyAnchorMatchGameResult.CSB_RESULTTITLEANI_PATH_LOSE)
        if titleNode and titleAni then
            nodeResultTitleAni:addChild(titleNode)
            titleNode:runAction(titleAni)
            titleAni:play('animation_TitleLose', false)
        end
    end
end

function MyAnchorMatchGameResult:initRole(resultPanelAni)
    local imgRole = resultPanelAni:getChildByName('Img_Role')
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if self:isWin() then
        if playerInfoManager:getSelfNickSex() == 1 then
            imgRole:loadTexture(MyAnchorMatchGameResult.IMG_ROLEHEAD_GIRL_WIN)
        else
            imgRole:loadTexture(MyAnchorMatchGameResult.IMG_ROLEHEAD_BOY_WIN)
        end
    else
        if playerInfoManager:getSelfNickSex() == 1 then
            imgRole:loadTexture(MyAnchorMatchGameResult.IMG_ROLEHEAD_GIRL_LOSE)
        else
            imgRole:loadTexture(MyAnchorMatchGameResult.IMG_ROLEHEAD_BOY_LOSE)
        end
    end
end

function MyAnchorMatchGameResult:initBtns(resultPanelAni)
    local btnSure = resultPanelAni:getChildByName('Btn_Sure')
    if btnSure then
        btnSure:addClickEventListener(handler(self, self.onBtnSureClicked))
    end

    local btnContinue = resultPanelAni:getChildByName('Btn_Continue')
    if btnContinue then
        btnContinue:addClickEventListener(handler(self, self.onBtnContinueClicked))
    end

    -- todo 按钮显示逻辑，连局显示继续，终局显示确定
    local canLeave = self._gameController:canLeaveAnchorMatchGame()
    btnSure:setVisible(canLeave)
    btnContinue:setVisible(not canLeave)
end

function MyAnchorMatchGameResult:initAutoStart(resultPanelAni)
    self:stopAutoStartTimer()
    self._textAutoStartTime = resultPanelAni:getChildByName('Text_AutoStartTime')
    if self._textAutoStartTime then
        if self._gameController:canLeaveAnchorMatchGame() then
            self._textAutoStartTime:setVisible(false)
        else
            self._textAutoStartTime:setVisible(true)
            self._textAutoStartTime:setString(tostring(self._autoStartTime) .. 'S')
            local function onTimer()
                if not self._textAutoStartTime or tolua.isnull(self._textAutoStartTime) then
                    self:stopAutoStartTimer()
                    return
                end

                if self._autoStartTime <= 0 then
                    self:startGame()
                    self:remove()
                    return
                end
                self._autoStartTime = self._autoStartTime - 1
                self._textAutoStartTime:setString(tostring(self._autoStartTime) .. 'S')
            end

            self:startAutoStartTimer(onTimer)
        end
    end
end

function MyAnchorMatchGameResult:onBtnSureClicked()
    self._gameController:playBtnPressedEffect()
    self._gameController:onQuit()
end

function MyAnchorMatchGameResult:onBtnContinueClicked()
    self._gameController:playBtnPressedEffect()
    self:startGame()
    self:remove()
end

function MyAnchorMatchGameResult:stopAutoStartTimer()
    if self._autoStartTimer then
        my.removeSchedule(self._autoStartTimer)
    end
end

function MyAnchorMatchGameResult:startAutoStartTimer(callback)
    self._autoStartTimer = my.createSchedule(function()
        callback()
    end, 1)
end

function MyAnchorMatchGameResult:startGame()
    if self._gameController then
        self._gameController:onStartGame()
    end
end

function MyAnchorMatchGameResult:remove()
    self:stopAutoStartTimer()
    if self._gameController._baseGameScene and self._gameController._baseGameScene._anchorMatchGameResult then
        self._gameController._baseGameScene._anchorMatchGameResult = nil
    end
    if self._resultLayer then
        self._resultLayer:removeFromParentAndCleanup()
        self._resultLayer = nil
        self._gameController:onCloseResultLayerEx()
    end
end

function MyAnchorMatchGameResult:onKeyBack()
    if self._gameController:canLeaveAnchorMatchGame() then
        self._gameController:onQuit()
    else
        self:startGame()
        self:remove()
    end
end

return MyAnchorMatchGameResult