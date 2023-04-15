
local BaseGamePlayer = class("BaseGamePlayer")

function BaseGamePlayer:create(playerPanel, drawIndex, gameController)
    return BaseGamePlayer.new(playerPanel, drawIndex, gameController)
end

function BaseGamePlayer:ctor(playerPanel, drawIndex, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._playerPanel           = playerPanel
    self._drawIndex             = drawIndex

    self._playerBtnHead         = nil
    self._playerUserName        = nil
    self._playerMoney           = nil
    self._playerReady           = nil
    self._playerChatFrame       = nil
    self._playerChatStr         = nil
    self._playerInfoPanel       = nil
    self._bottomWidgets         = {}

    self:init()
end

function BaseGamePlayer:init()
    if self._playerPanel then
        self._playerBtnHead     = self._playerPanel:getChildByName("Player_btn_head")
        self._playerUserName    = self._playerPanel:getChildByName("Player_text_name")
        self._playerMoney       = self._playerPanel:getChildByName("Player_text_money")
        self._playerReady       = self._playerPanel:getChildByName("Player_sp_ready")
        self._playerChatFrame   = self._playerPanel:getChildByName("Panel_playerchatBG")
        if self._playerChatFrame then
            self._playerChatStr = self._playerChatFrame:getChildByName("playerchat")
        end

        self._playerInfoPanel   = self._playerPanel:getChildByName("Panel_playerinfo")
    end

    self:setClickEvent()
    self:initPlayer()
end

function BaseGamePlayer:setClickEvent()
    local function onClickPlayerHead()
        self:onClickPlayerHead()
    end
    if self._playerBtnHead then
        self._playerBtnHead:addClickEventListener(onClickPlayerHead)
    end
end

function BaseGamePlayer:initPlayer()
    self:stopTipChatTimer()
    self:hideAllChildren()
    self:hidePlayer()
end

function BaseGamePlayer:hideAllChildren()
    if not self._playerPanel then return end

    local playerChildren = self._playerPanel:getChildren()
    for i = 1, self._playerPanel:getChildrenCount() do
        local child = playerChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function BaseGamePlayer:hideBottom()
    if not self._playerPanel then return end

    for _, widget in pairs(self._playerPanel:getChildren()) do
        printLog("BaseGamePlayer:hideBottom", widget:getName())
        if widget.setVisible and widget:isVisible() then 
            local localPosition = cc.p(widget:getPositionX(), widget:getPositionY())
            local worldPosition = self._playerPanel:convertToWorldSpace(localPosition)
            if worldPosition.y <= display.height/6 then 
                widget:setVisible(false)
                table.insert(self._bottomWidgets, widget) 
            end
        end
    end
end

function BaseGamePlayer:showBottom()
    if type(self._bottomWidgets) ~= 'table' then return end
    for _, widget in pairs(self._bottomWidgets) do
        widget:show()
    end
end

function BaseGamePlayer:setSoloPlayer(soloPlayer)
    self:setVisible(true)
    self:setUserName(soloPlayer.szUserName)
    self:setMoney(soloPlayer.nDeposit)

    --self:setNickSex(soloPlayer.nNickSex)

    --如果是自己的性别，确保与大厅保持一致
    local UserModel = mymodel('UserModel'):getInstance()
    local sexChecked = UserModel:getNickSexWithCheckSelf(soloPlayer.nUserID, soloPlayer.nNickSex)
    self:setNickSex(sexChecked)
end

function BaseGamePlayer:playerAbort()
    self:initPlayer()
end

function BaseGamePlayer:setUserName(szUserName)
    if self._playerUserName then
        self._playerUserName:setVisible(true)
        local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
        self._playerUserName:setString(utf8name)
    end
end

function BaseGamePlayer:hideUserName()
    if self._playerUserName then
        self._playerUserName:setVisible(false)
    end
end

function BaseGamePlayer:setMoney(nDeposit)
    if self._playerMoney then
        self._playerMoney:setVisible(true)
        self._playerMoney:setString(nDeposit)
    end
end

function BaseGamePlayer:hideMoney()
    if self._playerMoney then
        self._playerMoney:setVisible(false)
    end
end

function BaseGamePlayer:setNickSex(nNickSex)
    if self._playerBtnHead then
        self._playerBtnHead:setVisible(true)
        if 1 == nNickSex then
            self._playerBtnHead:loadTextureNormal("res/GameCocosStudio/game/player/player_btn_head_girl.png")
            self._playerBtnHead:loadTexturePressed("res/GameCocosStudio/game/player/player_btn_head_girl_pressed.png")
        else
            self._playerBtnHead:loadTextureNormal("res/GameCocosStudio/game/player/player_btn_head_boy.png")
            self._playerBtnHead:loadTexturePressed("res/GameCocosStudio/game/player/player_btn_head_boy_pressed.png")
        end
    end
end

function BaseGamePlayer:setReady(bReady)
    if self._playerReady then
        self._playerReady:setVisible(bReady)
    end
end

function BaseGamePlayer:hidePlayer()
    self:setVisible(false)
end

function BaseGamePlayer:onClickPlayerHead()
    self._gameController:playBtnPressedEffect()

    print("onClickPlayerHead" .. tostring(self._drawIndex))
    self._gameController:onClickPlayerHead(self._drawIndex)
end

function BaseGamePlayer:setVisible(visible)
    if self._playerPanel then
        self._playerPanel:setVisible(visible)
    end
end

function BaseGamePlayer:isVisible()
    if self._playerPanel then
        return self._playerPanel:isVisible()
    end
    return false
end

function BaseGamePlayer:isPlayerEnter()
    return self:isVisible()
end

function BaseGamePlayer:setPosition(x, y)
    if self._playerPanel then
        self._playerPanel:setPosition(x, y)
    end
end

function BaseGamePlayer:tipChatContent(content)
    if self._playerChatFrame then
        self._playerChatFrame:setVisible(true)

        if self._playerChatStr then
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
            self._playerChatStr:setString(utf8Content)
        end

        local function onAutoHideChatTip(dt)
            self:hideChatTip()
        end
        local duration = 3
        self:stopTipChatTimer()
        self.tipChatTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onAutoHideChatTip, duration, false)
    end
end

function BaseGamePlayer:stopTipChatTimer()
    if self.tipChatTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tipChatTimerID)
        self.tipChatTimerID = nil
    end
end

function BaseGamePlayer:hideChatTip()
    self:stopTipChatTimer()

    if self._playerChatFrame then
        self._playerChatFrame:setVisible(false)
    end
end

function BaseGamePlayer:showPlayerInfo(bShow)
    if self._playerInfoPanel then
        if bShow then
            local playerInfoManager = self._gameController:getPlayerInfoManager()
            if playerInfoManager then
                local playerInfo = playerInfoManager:getPlayerInfo(self._drawIndex)
                if playerInfo then
                    local name = self._playerInfoPanel:getChildByName("text_name")
                    if name then
                        local userName = playerInfo.szUserName
                        if userName then
                            local utf8Name = MCCharset:getInstance():gb2Utf8String(userName, string.len(userName))
                            name:setString(utf8Name)
                        end
                    end

                    local id = self._playerInfoPanel:getChildByName("text_userid")
                    if id then
                        local userID = playerInfo.nUserID
                        if userID then
                            id:setString(tostring(userID))
                        end
                    end

                    local deposit = self._playerInfoPanel:getChildByName("text_deposit")
                    if deposit then
                        local userDeposit = playerInfo.nDeposit
                        if userDeposit then
                            deposit:setString(tostring(userDeposit))
                        end
                    end

                    local level = self._playerInfoPanel:getChildByName("text_level")
                    if level then
                        local userLevel = self._gameController:getDepositLevel(playerInfo.nDeposit)
                        if userLevel then
                            local utf8Name = MCCharset:getInstance():gb2Utf8String(userLevel, string.len(userLevel))
                            level:setString(utf8Name)
                        end
                    end

                    local win = self._playerInfoPanel:getChildByName("text_win")
                    if win then
                        local userWin = playerInfo.nWin
                        if userWin then
                            win:setString(tostring(userWin))
                        end
                    end

                    local lose = self._playerInfoPanel:getChildByName("text_loss")
                    if lose then
                        local userLose = playerInfo.nLoss
                        if userLose then
                            lose:setString(tostring(userLose))
                        end
                    end

                    local standoff = self._playerInfoPanel:getChildByName("text_standoff")
                    if standoff then
                        local userStandoff = playerInfo.nStandOff
                        if userStandoff then
                            standoff:setString(tostring(userStandoff))
                        end
                    end
                end
            end
        end
        self._playerInfoPanel:setVisible(bShow)
    end
end

function BaseGamePlayer:isPlayerInfoShow()
    if self._playerInfoPanel then
        return self._playerInfoPanel:isVisible()
    end
    return false
end

function BaseGamePlayer:onTouchBegin(x,y)

end

function BaseGamePlayer:addFriend(userID)
    if self._gameController then
        local friendSource = ""
        local friendConfig = ""

        local friendConfigFile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
        if friendConfigFile ~= "" then
            friendConfig = json.decode(friendConfigFile)
        end
        if friendConfig ~= "" then
            friendSource = string.format(friendConfig["CHARTEREDROOM_FRIENDSOURCE_GAME"], self._gameController:getUtilsInfoManager():getRoomID())
        end
        self._gameController:addFriend(userID, friendSource)
    end
end

function BaseGamePlayer:hideStateMent()
    if self._stateMentNode then 
        self._stateMentNode:setVisible(false)
    end
end

return BaseGamePlayer
