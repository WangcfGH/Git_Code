local SKGameChat = class("SKGameChat")
local constStrings1=cc.load('json').loader.loadFile('ChatStrings.json')
local constStrings2=cc.load('json').loader.loadFile('ChatStrings-female.json')
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local constStrings = constStrings1

function SKGameChat:ctor(chatPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._chatPanel             = chatPanel

    self._chatEdit              = nil
    self._chatList              = nil
    self._emotionBt = {}

    self:init()
end

function SKGameChat:init()
    if not self._chatPanel then return end

    self._chatPanel:setLocalZOrder(SKGameDef.SK_ZORDER_CHAT)

    self:setVisible(false)

    local function onSend()
        self:onSend()
    end
    local rootNode = self._chatPanel:getChildByName("Panel_Main")
    local buttonSend = ccui.Helper:seekWidgetByName(rootNode, "Btn_Send")
    if buttonSend then
        buttonSend:addClickEventListener(onSend)
    end
    
    local function onClose()
        self:onClose()
    end
    local buttonclose = ccui.Helper:seekWidgetByName(rootNode, "Btn_Close")
    if buttonclose then
        buttonclose:addClickEventListener(onClose)
    end
    
    local function onChatListClk(sender, eventType)
        self:onChatListClk(sender, eventType)
    end
    local function onScrollViewEvent(sender, eventType)
        self:onScrollViewEvent(sender, eventType)
    end
    self._chatList = ccui.Helper:seekWidgetByName(rootNode,"ListView_Phrase")
    
    local listCount = 15

    if self._chatList then
        self._chatList:addEventListener(onChatListClk)
        self._chatList:addScrollViewEventListener(onScrollViewEvent)
        local zOrder = self._chatList:getLocalZOrder()
        local defaultItem = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_Chat_Phrase.csb")
        if not defaultItem then
            return          
        end
        
        --local content   = self._chatList:getContentSize()
        --self._chatList:setInnerContainerSize(cc.size(content.wight, 50*(listCount+1) + 11*listCount))
        
        local playerInfoManager = self._gameController._baseGamePlayerInfoManager
        if playerInfoManager then
            local nNickSex = playerInfoManager:getSelfInfo().nNickSex
            if nNickSex == 1 then
                constStrings = constStrings2
            else
                constStrings = constStrings1
            end
        end
        for i=1, listCount do 
            local custom_button = ccui.Button:create("res/Game/GamePic/chat/Chat_Btn_Phrase_N.png", "res/Game/GamePic/chat/Chat_Btn_Phrase_L.png")  
            custom_button:setScale9Enabled(true)  
            custom_button:setContentSize(315,50)  

            local text = ccui.Text:create() --cc.Label:create()        
            text:setFontSize(22)       
            text:setColor(cc.c3b(185,106,77))
            text:setString(constStrings["HLS_CHAT_WORDS_"..i])
            text:setContentSize(custom_button:getContentSize())
            custom_button:addChild(text)
            
            local custom_item = ccui.Layout:create()  
            custom_item:setContentSize(custom_button:getContentSize())  
            custom_button:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))  
            text:setPosition(cc.p(custom_item:getContentSize().width / 2.0 + 5, custom_item:getContentSize().height / 2.0+12))  
            
            custom_item:addChild(custom_button)  
            self._chatList:addChild(custom_item)  
 
        end
    end
 
    for i = 1, 9 do
        local btnEmotion = ccui.Helper:seekWidgetByName(rootNode, "Btn_Emotion"..tostring(i))
        if btnEmotion then
            local function onEmotion() 
                self:onEmotion(i) 
            end
            btnEmotion:addClickEventListener(onEmotion)
        end
        if i == 7 then
            btnEmotion:setVisible(false)
        end
    end

    local editBG = ccui.Helper:seekWidgetByName(rootNode,"Img_EditBG")
    
    if editBG then
        local editBox = ccui.Helper:seekWidgetByName(rootNode,"TextField_Msg")

        local depositAmoutInp = editBox
        depositAmoutInp:setVisible(false)
        self._chatEdit = ccui.EditBox:create(editBG:getContentSize(), "res/Game/GamePic/chat/chat_box_typebox.png")
        self._chatEdit:setPosition(cc.p(editBG:getPositionX() + 3, editBG:getPositionY()))
        self._chatEdit:setAnchorPoint(depositAmoutInp:getAnchorPoint())
        self._chatEdit.setTextColor = editBox.setFontColor
        self._chatEdit:setFontColor(cc.c3b(165, 63, 42))
        self._chatEdit:setFontSize(depositAmoutInp:getFontSize())
        self._chatEdit:setPlaceHolder(depositAmoutInp:getPlaceHolder())
        self._chatEdit:setPlaceholderFontName(depositAmoutInp:getFontName())
        self._chatEdit:setPlaceholderFontSize(depositAmoutInp:getFontSize())
        self._chatEdit:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
        self._chatEdit:setFontName(depositAmoutInp:getFontName())
        self._chatEdit:setMaxLength(30)
        local father = ccui.Helper:seekWidgetByName(rootNode,"Panel_Msg")
        father:addChild(self._chatEdit)
        self._chatEdit.getString = editBox.getText
        self._chatEdit.setString = editBox.setText
    end
end

function SKGameChat:setVisible(bVisible)
    if self._chatPanel then
        self._chatPanel:setVisible(bVisible)
    end
end

function SKGameChat:onEmotion(index)  
    local chatContent = ""
    chatContent = constStrings["HLS_CHAT_Emotion_"..index]
    --[[if index == 1 then chatContent="#beated" 
    elseif index == 2 then chatContent="#cool" 
    elseif index == 3 then chatContent="#cry" 
    elseif index == 4 then chatContent="#embarrassed" 
    elseif index == 5 then chatContent="#en" 
    elseif index == 6 then chatContent="#hurt" 
    elseif index == 7 then chatContent="#innocent" 
    elseif index == 8 then chatContent="#loser" 
    elseif index == 9 then chatContent="#sexy" 
    else 
    end --]]
    if 0 < string.len(chatContent) then
        local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
        self._gameController:onChatSend(gbChatContent)
    else
    end
    self:showChat(false)
end


function SKGameChat:isVisible()
    if self._chatPanel then
        return self._chatPanel:isVisible()
    end
    return false
end

function SKGameChat:showChat(bShow)
    self:setVisible(bShow)

--    if bShow then
--        self._chatEdit:setText("")
--    end
end

function SKGameChat:onSend()
    self._gameController:playBtnPressedEffect()
    local chatContent = self._chatEdit:getText()
    if 0 < string.len(chatContent) then
        local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
        self._gameController:onChatSend(gbChatContent)
    else
    end
    self._chatEdit:setText('')
    self:showChat(false)
end

function SKGameChat:onClose()
    self._gameController:playBtnPressedEffect()
    self:showChat(false)
end

function SKGameChat:onChatListClk(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
        local selIndex = sender:getCurSelectedIndex()
        local chatContent =  constStrings["HLS_CHAT_WORDS_"..(selIndex+1 + 50)]
        local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
        self._gameController:onChatSend(gbChatContent)
        self:showChat(false)
    end
end

-- �����¼������ص�  
function SKGameChat:onScrollViewEvent(sender, eventType)  
    -- �������ײ�  
    if eventType == ccui.ScrollviewEventType.scrollToBottom then  
        print("SCROLL_TO_BOTTOM")  
        -- ����������  
    elseif eventType == ccui.ScrollviewEventType.scrollToTop then  
        print("SCROLL_TO_TOP")  
    end  

end  

function SKGameChat:containsTouchLocation(x, y)
    local b = false
    if self._chatPanel then
        local frame = self._chatPanel:getChildByName("Panel_Main")
        if frame then
            local position = cc.p(self._chatPanel:getPosition())
            local s = frame:getContentSize()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            b = cc.rectContainsPoint(touchRect, cc.p(x, y))
        end
    end
    return b
end

return SKGameChat
