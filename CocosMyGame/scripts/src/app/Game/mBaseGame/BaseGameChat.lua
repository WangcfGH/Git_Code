
local BaseGameChat = class("BaseGameChat")

function BaseGameChat:ctor(chatPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._chatPanel             = chatPanel

    self._chatEdit              = nil
    self._chatList              = nil

    self:init()
end

function BaseGameChat:init()
    if not self._chatPanel then return end

    self:setVisible(false)

    local function onSend()
        self:onSend()
    end
    local buttonSend = self._chatPanel:getChildByName("chat_btn_send")
    if buttonSend then
        buttonSend:addClickEventListener(onSend)
    end

    local function onChatListClk(sender, eventType)
        self:onChatListClk(sender, eventType)
    end
    self._chatList = self._chatPanel:getChildByName("List_chat")
    if self._chatList then
        self._chatList:addEventListener(onChatListClk)
    end

    local editBG = self._chatPanel:getChildByName("Panel_editBG")
    if editBG then
        local editBox = editBG:getChildByName("chat_edit")

        local depositAmoutInp = editBox
        depositAmoutInp:setVisible(false)
        self._chatEdit = ccui.EditBox:create(editBG:getContentSize(), "res/GameCocosStudio/chat/frame/chat_sp_edit.png")
        self._chatEdit:setPosition(editBG:getPosition())
        self._chatEdit:setAnchorPoint(depositAmoutInp:getAnchorPoint())
        self._chatEdit.setTextColor = editBox.setFontColor
        self._chatEdit:setFontColor(display.COLOR_BLACK)
        self._chatEdit:setFontSize(depositAmoutInp:getFontSize())
        self._chatEdit:setPlaceHolder(depositAmoutInp:getPlaceHolder())
        self._chatEdit:setPlaceholderFontName(depositAmoutInp:getFontName())
        self._chatEdit:setPlaceholderFontSize(depositAmoutInp:getFontSize())
        self._chatEdit:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
        self._chatEdit:setFontName(depositAmoutInp:getFontName())
        self._chatEdit:setMaxLength(20)
        self._chatPanel:addChild(self._chatEdit)
        self._chatEdit.getString = editBox.getText
        self._chatEdit.setString = editBox.setText
    end
end

function BaseGameChat:setVisible(bVisible)
    if self._chatPanel then
        self._chatPanel:setVisible(bVisible)
    end
end

function BaseGameChat:isVisible()
    if self._chatPanel then
        return self._chatPanel:isVisible()
    end
    return false
end

function BaseGameChat:showChat(bShow)
    self:setVisible(bShow)

    if bShow then
        self._chatEdit:setText("")
    end
end

function BaseGameChat:onSend()
    local chatContent = self._chatEdit:getText()
    if 0 < string.len(chatContent) then
        local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
        self._gameController:onChatSend(gbChatContent)
    else
    end
    self:showChat(false)
end

function BaseGameChat:onChatListClk(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
        local selIndex = sender:getCurSelectedIndex()
        local selfItem = self._chatList:getChildByName("chat_" .. tostring(selIndex))
        if selfItem then
            local chatText = selfItem:getChildByName("chat_text")
            if chatText then
                local chatContent = chatText:getString()
                local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
                self._gameController:onChatSend(gbChatContent)
                self:showChat(false)
            end
        end
    end
end

function BaseGameChat:containsTouchLocation(x, y)
    local b = false
    if self._chatPanel then
        local frame = self._chatPanel:getChildByName("chat_sp_frame")
        if frame then
            local position = cc.p(self._chatPanel:getPosition())
            local s = frame:getContentSize()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            b = cc.rectContainsPoint(touchRect, cc.p(x, y))
        end
    end
    return b
end

return BaseGameChat
