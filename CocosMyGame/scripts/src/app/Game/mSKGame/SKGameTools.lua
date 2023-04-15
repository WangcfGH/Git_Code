
local BaseGameTools = import("src.app.Game.mBaseGame.BaseGameTools")
local SKGameTools = class("SKGameTools", BaseGameTools)

local SKGameDef                = import("src.app.Game.mSKGame.SKGameDef")

local SK_TOOLS_INDEX = {
    SK_TOOLS_INDEX_ADD          = 1,
    SK_TOOLS_INDEX_QUIT         = 2,
    SK_TOOLS_INDEX_SETTING      = 3,
    SK_TOOLS_INDEX_SAFEBOX      = 4,
    SK_TOOLS_INDEX_ROBOT        = 5,
    SK_TOOLS_INDEX_RULE         = 6,
    SK_TOOLS_INDEX_MENU         = 7,
    SK_TOOLS_INDEX_SUPPLY       = 8,
}

function SKGameTools:ctor(toolsPanel, expanding, gameController)
    if not gameController then printError("gameController is nil!!!") return end

    self.isShow = false

    SKGameTools.super.ctor(self, toolsPanel, expanding, gameController)
    
    self._NodePanel = toolsPanel:getParent()
    self._NodeTools = toolsPanel:getChildByName("Panel_Tools")
end

function SKGameTools:init()
    if not self._toolsPanel then return end

    --self._background = ccui.Helper:seekWidgetByName(self._toolsPanel, "img_topbg")
    
    self._toolsPanel:getParent():setLocalZOrder(SKGameDef.SK_ZORDER_TOOLS)
    
    local function onAdd()
        self:onAdd()
    end
    local buttonAdd = ccui.Helper:seekWidgetByName(self._toolsPanel, "Tools_btn_add")
    if buttonAdd then
        buttonAdd:addClickEventListener(onAdd)

        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_ADD
        self._toolbtns[index] = buttonAdd
        self._btnpos[index] = cc.p(buttonAdd:getPositionX(), buttonAdd:getPositionY())
    end

    local function onQuit()
        self:onQuit()

        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_BACK_TO_HALL)
    end
    local buttonQuit = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_Exit")
    if buttonQuit then
        buttonQuit:addClickEventListener(onQuit)

        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT
        self._toolbtns[index] = buttonQuit
        self._btnpos[index] = cc.p(buttonQuit:getPositionX(), buttonQuit:getPositionY())
    end

    local function onSetting()
        self:onSetting()
    end
    local buttonSetting = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_Sitting")
    if buttonSetting then
        buttonSetting:addClickEventListener(onSetting)

        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_SETTING
        self._toolbtns[index] = buttonSetting
        self._btnpos[index] = cc.p(buttonSetting:getPositionX(), buttonSetting:getPositionY())
    end

    local function onSafeBox()
        self:onSafeBox()
    end
    local buttonSafeBox = ccui.Helper:seekWidgetByName(self._toolsPanel, "Tools_btn_safebox")
    if buttonSafeBox then
        buttonSafeBox:addClickEventListener(onSafeBox)

        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_SAFEBOX
        self._toolbtns[index] = buttonSafeBox
        self._btnpos[index] = cc.p(buttonSafeBox:getPositionX(), buttonSafeBox:getPositionY())
    end
    
    local function onRobot()
        self:onRobot()
    end
    local buttonRobot = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_Robot")
    if buttonRobot then
        buttonRobot:addClickEventListener(onRobot)
        
        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT
        self._toolbtns[index] = buttonRobot
        self._btnpos[index] = cc.p(buttonRobot:getPositionX(), buttonRobot:getPositionY())
    end
    
    local function onRule()
        self:onRule()
    end
    local buttonRule = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_Rule")
    if buttonRule then
        buttonRule:addClickEventListener(onRule)
        
        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_RULE
        self._toolbtns[index] = buttonRule
        self._btnpos[index] = cc.p(buttonRule:getPositionX(), buttonRule:getPositionY())
    end

    local function onAutoSupply()
        self:onAutoSupply()
    end
    local buttonAutoSupply = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_AutoSupply")
    if buttonAutoSupply then
        buttonAutoSupply:addClickEventListener(onAutoSupply)
        
        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_SUPPLY
        self._toolbtns[index] = buttonAutoSupply
        self._btnpos[index] = cc.p(buttonAutoSupply:getPositionX(), buttonAutoSupply:getPositionY())
    end

    local function onMenu()
        self:onMenu()
    end

    local buttonMenu = ccui.Helper:seekWidgetByName(self._toolsPanel, "Btn_Menu")
    if buttonMenu then
        buttonMenu:addClickEventListener(onMenu)
        
        local index = SK_TOOLS_INDEX.SK_TOOLS_INDEX_MENU
        self._toolbtns[index] = buttonMenu
        self._btnpos[index] = cc.p(buttonMenu:getPositionX(), buttonMenu:getPositionY())
    end

    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, false)
end

function SKGameTools:onGameStart()
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, false)
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, true)
    self:disableSafeBox()
    cc.exports.inGame = true  
end

function SKGameTools:setBtnRobotStatus(status)
    if status == true then
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, true)
    else
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, false)
    end
end

function SKGameTools:ope_StartPlay()
    local SKGameScene = self._gameController._baseGameScene
    SKGameScene._MyQuickBoomBtn:setVisible(true)
    local imgBubble = SKGameScene._MyQuickBoomBtn:getChildByName("Img_Bubble")
    local function callbackFunc()
        imgBubble:setVisible(false)
    end
    local aniNode = imgBubble
    local time = 0.5 
    local scaleto1 = cc.ScaleTo:create(time, 1.2, 1.2)
    local scaleto2 = cc.ScaleTo:create(time, 0.95, 0.95)
    local sequenceAction  = cc.Sequence:create(scaleto1,scaleto2, scaleto1, scaleto2, scaleto1, scaleto2, cc.CallFunc:create(callbackFunc))
    aniNode:runAction(sequenceAction)

 --[[   local sortFlag = self._gameController:GetSortCardFlag()
    if sortFlag == SKGameDef.SORT_CARD_BY_ORDER and SKGameScene._MyBoomBtn then
        SKGameScene._MyBoomBtn:setVisible(false)
        SKGameScene._MyOrderSortBtn:setVisible(false)
        SKGameScene._MyColorSortBtn:setVisible(false)
        SKGameScene._MyNumSortBtnEx:setVisible(false)
    end
    if sortFlag == SKGameDef.SORT_CARD_BY_SHPAE and SKGameScene._MyOrderSortBtn then
        SKGameScene._MyOrderSortBtn:setVisible(true)
        SKGameScene._MyColorSortBtn:setVisible(false)
        SKGameScene._MyBoomBtn:setVisible(false)
        SKGameScene._MyNumSortBtnEx:setVisible(false)
    end
    if sortFlag == SKGameDef.SORT_CARD_BY_BOME and SKGameScene._MyColorSortBtn then
        SKGameScene._MyOrderSortBtn:setVisible(false)
        SKGameScene._MyColorSortBtn:setVisible(false)
        SKGameScene._MyBoomBtn:setVisible(false)
        SKGameScene._MyNumSortBtnEx:setVisible(true)
    end
    if sortFlag == SKGameDef.SORT_CARD_BY_NUM and SKGameScene._MyNumSortBtnEx then
        SKGameScene._MyOrderSortBtn:setVisible(false)
        SKGameScene._MyColorSortBtn:setVisible(true)
        SKGameScene._MyBoomBtn:setVisible(false)
        SKGameScene._MyNumSortBtnEx:setVisible(false)
    end
    ]]
    --[[if SKGameScene._MyArrageBtn then
        SKGameScene._MyArrageBtn:setVisible(false)
    end
    if SKGameScene._MyResetBtn then
        SKGameScene._MyResetBtn:setVisible(true)
    end--]]
    self._gameController:ResetArrageButton()
    --self._gameController:startNewPlayerTips()   --去掉老的新手提示，20191128
end

function SKGameTools:onGameWin()
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        if self._gameController:canLeaveAnchorMatchGame() then
            self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
        else
            local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
            local tableRule = AnchorTableModel:getTableRule()
            local UserModel = mymodel('UserModel'):getInstance()
            if tableRule then
                if tableRule.AnchorUserID == UserModel.nUserID then
                    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
                end
            end
        end
    else
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
    end

    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_SAFEBOX, true)
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, false)
    self:onHideOtherButton()
    cc.exports.inGame = false
end

function SKGameTools:showQuitBtn(resetGame)
    if resetGame and resetGame == 1 then
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, true)
    else
        self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_QUIT, false)
    end
end

function SKGameTools:onHideOtherButton()
    local SKGameScene = self._gameController._baseGameScene
    if SKGameScene._MyQuickBoomBtn then
        SKGameScene._MyQuickBoomBtn:setVisible(false)
    end
--[[    if SKGameScene._MyOrderSortBtn then
        SKGameScene._MyOrderSortBtn:setVisible(false)
    end
    if SKGameScene._MyColorSortBtn then
        SKGameScene._MyColorSortBtn:setVisible(false)
    end
    if SKGameScene._MyBoomBtn then
        SKGameScene._MyBoomBtn:setVisible(false)
    end
    if SKGameScene._MyArrageBtn then
        SKGameScene._MyArrageBtn:setVisible(false)
    end
    if SKGameScene._MyResetBtn then
        SKGameScene._MyResetBtn:setVisible(false)
    end
    if SKGameScene._MyNumSortBtnEx then
        SKGameScene._MyNumSortBtnEx:setVisible(false)
    end
    ]]
    self:enableBtn(SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, false)
end

function SKGameTools:containsTouchLocation(x, y)   -- 只判断托管按钮
    local b = false
    --[[if self._toolsPanel then
        local position = cc.p(self._toolsPanel:getPosition())
        local s = self._toolsPanel:getContentSize()
        local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
        b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    end--]]
    for i=SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT, SK_TOOLS_INDEX.SK_TOOLS_INDEX_ROBOT do
        if self._toolbtns[i] then
            
            local position = self._NodeTools:convertToWorldSpace(cc.p(self._toolbtns[i]:getPosition()))
            local s = self._toolbtns[i]:getContentSize()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            b = cc.rectContainsPoint(touchRect, cc.p(x, y))
            if b then
                return true
            end
        end       
    end
    
    return b
end

function SKGameTools:onRobot()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end
    print("onRobot")

    if self._gameController then
        self._gameController:onRobot()
    end

    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.GAME_AUTO_PLAYBTN)
end

function SKGameTools:onRule()
    if self._gameController:isArenaPlayer() then
        my.informPluginByName({pluginName='ArenaPlayerCourseCtrl'})
    else
        my.informPluginByName({pluginName='GameRulePlugin'})
    end
end

function SKGameTools:onMenu()
    self._gameController:playBtnPressedEffect()
   
    if self._toolsMoving then return end
    print("onMenu")
    
    local csbPath = "res/GameCocosStudio/csb/Node_GameTools.csb"

    --如果有补银用另外一个csb
    if self._gameController:isSupportAutoSupply() then
        csbPath = "res/GameCocosStudio/csb/Node_GameTools_AutoSupply.csb"
    end

    local action = cc.CSLoader:createTimeline(csbPath)

    --[[action:setLastFrameCallFunc(function()
        self._toolsMoving = false
    end)--]]

    self._toolsMoving = true
    self._toolsPanel:runAction(action)
    if self.isShow then
        self.isShow = false
        action:play("animation_MenuDisappear", false)

        self:clearAutoIndentTimer()
    else
        self.isShow = true      
        action:play("animation_MenuAppear", false)

        self:createAutoIndentTimer(action)
    end

    local speed = action:getTimeSpeed()  

    local startFrame = action:getStartFrame()  
    local endFrame = action:getEndFrame()  
    local frameNum = endFrame - startFrame 
    local duration = 1.0 /(speed * 60.0) * frameNum

    local block = cc.CallFunc:create( function(sender)  
        self._toolsMoving = false
    end )  
 
    self._toolsPanel:runAction(cc.Sequence:create(cc.DelayTime:create(duration), block))  

end

-- 清理打开菜单后自动缩进的计时
function SKGameTools:createAutoIndentTimer(action)
    self:clearAutoIndentTimer()

    -- 打开状态10秒后自动缩进
    self.autoIndent = my.scheduleOnce(function()
        if self.isShow == true then
            self.isShow = false
            if action then
                action:play("animation_MenuDisappear", false)
            end
        end
    end, 10) 
end

function SKGameTools:clearAutoIndentTimer()
    if self.autoIndent then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.autoIndent)
        self.autoIndent = nil
    end
end

function SKGameTools:onExit()
    self:clearAutoIndentTimer()
end

function SKGameTools:onAutoSupply()
    self._gameController:playBtnPressedEffect()

    if self._toolsMoving then return end
    print("onAutoSupply")

    if self._gameController then
        self._gameController:onAutoSupply()
    end
end

return SKGameTools