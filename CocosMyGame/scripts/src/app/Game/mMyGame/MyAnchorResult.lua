local MyAnchorResult = class('MyAnchorResult')
local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")

MyAnchorResult.RESOURCE_PATH = 'res/GameCocosStudio/csb/Layer_AnchorGameResult.csb'

MyAnchorResult.CSB_RESULTTITLEANI_PATH_WIN = 'res/GameCocosStudio/csb/Node_ResultTitle_Win.csb'
MyAnchorResult.CSB_RESULTTITLEANI_PATH_LOSE = 'res/GameCocosStudio/csb/Node_ResultTitle_Lose.csb'
MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN = 'res/GameCocosStudio/csb/Node_ResultLightLoop_Win.csb'
MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE = 'res/GameCocosStudio/csb/Node_ResultLightLoop_Lose.csb'

MyAnchorResult.IMG_ROLEHEAD_GIRL_WIN = 'res/Game/GamePic/GameContents/Role_Girl.png'
MyAnchorResult.IMG_ROLEHEAD_GIRL_LOSE = 'res/Game/GamePic/GameContents/Role_Girl_L.png'
MyAnchorResult.IMG_ROLEHEAD_BOY_WIN = 'res/Game/GamePic/GameContents/Role_Boy.png'
MyAnchorResult.IMG_ROLEHEAD_BOY_LOSE = 'res/Game/GamePic/GameContents/Role_Boy_L.png'

function MyAnchorResult:ctor(baseNode, gamecontroller, resultData)
    self._gameController = gamecontroller
    self._resultData = resultData
    self._win = false
    self:calcWinLose()
    self:initUI(baseNode)
end

function MyAnchorResult:calcWinLose()
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
        if winChairNo == selfChairNO or winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(selfChairNO-1))+1 then
            self._win = true
        else
            self._win = false
        end
    end

    return false
end

function MyAnchorResult:isWin()
    return self._win
end

function MyAnchorResult:initUI(baseNode)
    local resultLayer = cc.CSLoader:createNode(MyAnchorResult.RESOURCE_PATH)
    local resultPanelAni = resultLayer:getChildByName('Panel_Main'):getChildByName('Panel_Animation')
    resultLayer:setLocalZOrder(SKGameDef.SK_ZORDER_RESULT)
    baseNode:addChild(resultLayer)
    resultLayer:setContentSize(display.size)
    ccui.Helper:doLayout(resultLayer)

    self:initAni(resultPanelAni)
    self:initRole(resultPanelAni)
    self:initBtns(resultPanelAni)
end

function MyAnchorResult:initAni(resultPanelAni)
    local nodeLightLoopAni = resultPanelAni:getChildByName('Node_ResultLightLoopAni')
    local nodeResultTitleAni = resultPanelAni:getChildByName('Node_ResultTitleAni')
    if self:isWin() then
        local lightLoopNode = cc.CSLoader:createNode(MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN)
        local lightLoopAni = cc.CSLoader:createTimeline(MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_WIN)
        if lightLoopNode and lightLoopAni then
            nodeLightLoopAni:addChild(lightLoopNode)
            lightLoopNode:runAction(lightLoopAni)
            lightLoopAni:play('animation_LightLoop', true)
        end

        local titleNode = cc.CSLoader:createNode(MyAnchorResult.CSB_RESULTTITLEANI_PATH_WIN)
        local titleAni = cc.CSLoader:createTimeline(MyAnchorResult.CSB_RESULTTITLEANI_PATH_WIN)
        if titleNode and titleAni then
            nodeResultTitleAni:addChild(titleNode)
            titleNode:runAction(titleAni)
            titleAni:play('animation_TitleWin', false)
        end

    else
        local lightLoopNode = cc.CSLoader:createNode(MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE)
        local lightLoopAni = cc.CSLoader:createTimeline(MyAnchorResult.CSB_RESULTLIGHTLOOPANI_PATH_LOSE)
        if lightLoopNode and lightLoopAni then
            nodeLightLoopAni:addChild(lightLoopNode)
            lightLoopNode:runAction(lightLoopAni)
            lightLoopAni:play('animation_LightLoop', true)
        end

        local titleNode = cc.CSLoader:createNode(MyAnchorResult.CSB_RESULTTITLEANI_PATH_LOSE)
        local titleAni = cc.CSLoader:createTimeline(MyAnchorResult.CSB_RESULTTITLEANI_PATH_LOSE)
        if titleNode and titleAni then
            nodeResultTitleAni:addChild(titleNode)
            titleNode:runAction(titleAni)
            titleAni:play('animation_TitleLose', false)
        end
    end
end

function MyAnchorResult:initRole(resultPanelAni)
    local imgRole = resultPanelAni:getChildByName('Img_Role')
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if self:isWin() then
        if playerInfoManager:getSelfNickSex() == 1 then
            imgRole:loadTexture(MyAnchorResult.IMG_ROLEHEAD_GIRL_WIN)
        else
            imgRole:loadTexture(MyAnchorResult.IMG_ROLEHEAD_BOY_WIN)
        end
    else
        if playerInfoManager:getSelfNickSex() == 1 then
            imgRole:loadTexture(MyAnchorResult.IMG_ROLEHEAD_GIRL_LOSE)
        else
            imgRole:loadTexture(MyAnchorResult.IMG_ROLEHEAD_BOY_LOSE)
        end
    end
end

function MyAnchorResult:initBtns(resultPanelAni)
    local btnSure = resultPanelAni:getChildByName('Btn_Sure')
    if btnSure then
        btnSure:addClickEventListener(handler(self, self.onBtnSureClicked))
    end

    local btnContinue = resultPanelAni:getChildByName('Btn_Continue')
    if btnContinue then
        btnContinue:addClickEventListener(handler(self, self.onBtnContinueClicked))
    end

    -- todo 按钮显示逻辑，连局显示继续，终局显示确定
    
end

function MyAnchorResult:onBtnSureClicked()
    
end

function MyAnchorResult:onBtnContinueClicked()
    
end

return MyAnchorResult