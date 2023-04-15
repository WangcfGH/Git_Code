
local SKGamePlayer = import("src.app.Game.mSKGame.SKGamePlayer")
local SKGameSelfPlayer = class("SKGameSelfPlayer", SKGamePlayer)

function SKGameSelfPlayer:init()
    SKGameSelfPlayer.super.init(self)

    local img_info_bg = self._playerInfoHead:getChildByName("Img_InfoBG") --自己新增姓名板  不用原来那套
    img_info_bg:setVisible(true)
    
    self._playerUserName    = img_info_bg:getChildByName("Text_PlayerName")
    self._playerUpNum       = img_info_bg:getChildByName("Value_Praise")

    self._btnShrink = img_info_bg:getChildByName("Btn_Shrink")
    self._btnShrink:addClickEventListener(handler(self, self.onShrinkHeadAnimation))

    self._btnStretch = img_info_bg:getChildByName("Btn_Stretch")
    self._btnStretch:addClickEventListener(handler(self, self.onStretchHeadAnimation))
    
    self._btnShrink:setVisible(true)
    self._btnStretch:setVisible(false)

    local playerName = self._playerPanel:getChildByName("Node_PlayerName")
    if playerName then
        playerName:setPositionY(-10000)  --废弃原来的姓名面板  移到外边去
    end
end

function SKGameSelfPlayer:hideAllChildren()
    SKGameSelfPlayer.super.hideAllChildren(self)
    local img_info_bg = self._playerInfoHead:getChildByName("Img_InfoBG") --自己新增姓名板  不用原来那套
    img_info_bg:setVisible(true)
end

function SKGameSelfPlayer:onStartPlayToShrinkAnimation()
    if self._btnShrink:isVisible() and self._btnShrink:isTouchEnabled() then
        self:onShrinkHeadAnimation()
    end
end

function SKGameSelfPlayer:onShrinkHeadAnimation()
    local csbPath = "res/GameCocosStudio/csb/Node_Player_Self.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    action:play("animation0", false)
    self._playerNode:runAction(action)
    
    local function onFrameEvent( frame)
        if frame then 
            local event = frame:getEvent()
            if "Play_Over" == event then
                self._btnShrink:setVisible(false)
                self._btnStretch:setVisible(true)
                self._btnShrink:setTouchEnabled(true)
                self._btnStretch:setTouchEnabled(true)
            end
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    self._btnShrink:setTouchEnabled(false)
    self._btnStretch:setTouchEnabled(false)
end

function SKGameSelfPlayer:onStretchHeadAnimation()
    local csbPath = "res/GameCocosStudio/csb/Node_Player_Self.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    action:play("animation1", false)
    self._playerNode:runAction(action)

    local function onFrameEvent( frame)
        if frame then 
            local event = frame:getEvent()
            if "Play_Over" == event then
                self._btnShrink:setVisible(true)
                self._btnStretch:setVisible(false)
                self._btnShrink:setTouchEnabled(true)
                self._btnStretch:setTouchEnabled(true)
            end
        end
    end
    action:setFrameEventCallFunc(onFrameEvent)

    self._btnShrink:setTouchEnabled(false)
    self._btnStretch:setTouchEnabled(false)
end

function SKGameSelfPlayer:onStartPlayToShowLevelAnimation()
    local enterAni = self._playerInfoHead:getChildByName("Node_Ani_Enter")
    if enterAni and self._playerLevelData then
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Ani_Enter.csb")
        action:play("animation0", false)
        enterAni:runAction(action)
    end
    self._gameStart = true
end

function SKGameSelfPlayer:containsTouchInfoLocation(x, y)
    local infoTouch = SKGameSelfPlayer.super.containsTouchInfoLocation(self, x, y)
--    local btnTouch = SKGameSelfPlayer.super.containsTouchLocation(self, x, y)
    
    local position = self._btnShrink:getParent():convertToWorldSpace(cc.p(self._btnShrink:getPosition()))
    local s = self._btnShrink:getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))

    return infoTouch or b
end

function SKGameSelfPlayer:setUserName(szUserName)
    if self._playerUserName then
        self._playerUserName:setVisible(true)
        local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
        my.fitStringInWidget(utf8name, self._playerUserName, 115)

        local playerName = self._playerPanel:getChildByName("Node_PlayerName")
        playerName:setVisible(true)
    end
end

return SKGameSelfPlayer
