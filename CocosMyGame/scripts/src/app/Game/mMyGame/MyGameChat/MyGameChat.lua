local SKGameChat = import("src.app.Game.mSKGame.SKGameChat")
local MyGameChat = class("MyGameChat",SKGameChat)
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local myConstStrings1=cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/Game/mSKGame/ChatStrings.json"))
local myConstStrings2=cc.load('json').json.decode(cc.FileUtils:getInstance():getStringFromFile('src/app/Game/mSKGame/ChatStrings-female.json'))

local myConstStrings = myConstStrings1

function MyGameChat:init()
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
    
    local listCount = 0
    if self._chatList then
        self._chatList:addEventListener(onChatListClk)
        self._chatList:addScrollViewEventListener(onScrollViewEvent)
        local zOrder = self._chatList:getLocalZOrder()
        -- local defaultItem = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_Chat_Phrase.csb")
        -- if not defaultItem then
        --     return          
        -- end
        
        --local content   = self._chatList:getContentSize()
        --self._chatList:setInnerContainerSize(cc.size(content.wight, 50*(listCount+1) + 11*listCount))
        
        local playerInfoManager = self._gameController._baseGamePlayerInfoManager
        if playerInfoManager then
            local nNickSex = playerInfoManager:getSelfInfo().nNickSex
            if nNickSex == 1 then
                myConstStrings = myConstStrings2
                listCount = 13
            else
                myConstStrings = myConstStrings1
                listCount = 14
            end
        end
        self._chatItemList = {}
        for i=1, listCount do 
            local custom_button = ccui.Button:create("res/Game/GamePic/chat/Chat_Btn_Phrase_N.png", "res/Game/GamePic/chat/Chat_Btn_Phrase_L.png")  
            custom_button:setScale9Enabled(true)  
            custom_button:setContentSize(315,50)  

            local text = ccui.Text:create() --cc.Label:create()        
            text:setFontSize(22)       
            text:setColor(cc.c3b(185,106,77))
            text:setString(myConstStrings["HLS_CHAT_WORDS_"..i])
            text:setFontName('res/common/font/mainfont.TTF')
            local sizeText = text:getContentSize()
            local sizeCB = custom_button:getContentSize()
            text:setContentSize(sizeText.width, sizeCB.height)
            custom_button:addChild(text)
            table.insert(self._chatItemList, text)
            
            local custom_item = ccui.Layout:create()  
            custom_item:setContentSize(custom_button:getContentSize())  
            custom_button:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))  
            --text:setPosition(cc.p(custom_item:getContentSize().width / 2.0 + 5, custom_item:getContentSize().height / 2.0+12))  
            text:setPosition(cc.p(sizeText.width / 2.0 + 5, custom_item:getContentSize().height / 2.0+12))  
            
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
    --隐藏自由聊天框
    local rootNode = self._chatPanel:getChildByName("Panel_Main")
    local panelMsg = ccui.Helper:seekWidgetByName(rootNode,"Panel_Msg")
    panelMsg:setVisible(false)
end

function MyGameChat:onEmotion(index)  
    local chatContent = ""
    chatContent = myConstStrings["HLS_CHAT_Emotion_"..index]
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

function MyGameChat:onChatListClk(sender, eventType)
    if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
        local selIndex = sender:getCurSelectedIndex()
        local chatContent =  myConstStrings["HLS_CHAT_WORDS_"..(selIndex+1 + 50)]
        local gbChatContent = MCCharset:getInstance():utf82GbString(chatContent, string.len(chatContent))
        self._gameController:onChatSend(gbChatContent)
        self:showChat(false)
    end
end

function MyGameChat:setVisible(bVisible)
    if self._chatPanel then
        self._chatPanel:setVisible(bVisible)
        if bVisible then
            if not tolua.isnull(self._chatPanel) then
                local panelContent = self._chatPanel:getChildByName("Panel_Main")
                panelContent:setVisible(true)
                panelContent:setScale(0.6)
                panelContent:setOpacity(255)
                local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
                local scaleTo2 = cc.ScaleTo:create(0.09, 1)
    
                local ani = cc.Sequence:create(scaleTo1, scaleTo2)
                panelContent:runAction(ani)

                if #self._chatItemList > 0 then
                    for i = 1, #self._chatItemList do
                        local item = self._chatItemList[i]
                        if item then
                            local size = item:getContentSize()
                            if size.width > 315 then
                                item:stopAllActions()
                                local custom_button = item:getParent()
                                local custom_item = custom_button:getParent()
                                local pos = cc.p(size.width / 2.0 + 5, custom_item:getContentSize().height / 2.0+12)
                                
                                local diff = 315 - size.width - 18
                                local actionMoveBy = cc.MoveBy:create(-diff / 20, { x = diff, y = 0 })
                                local actionMoveTo = cc.MoveTo:create(0.2, { x = pos.x, y = pos.y })
                                item:runAction(cc.RepeatForever:create(cc.Sequence:create(
                                    actionMoveTo,
                                    cc.DelayTime:create(1.0),
                                    actionMoveBy,    
                                    cc.DelayTime:create(1.0),      
                                    actionMoveTo,
                                    cc.DelayTime:create(2.0)      
                                )))
                            end
                        end
                    end
                end
            end
        end
    end
end

return MyGameChat