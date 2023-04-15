
local CharteredRoomTalk = class("CharteredRoomTalk")

local UserModel = mymodel('UserModel'):getInstance()
local userID = UserModel.nUserID
local json              = cc.load("json").json
local talkData          = {}
local messageBarTable   = {}
local nextMsgGap        = {}
local MAX_TALK_NUM      = 20
local chatPanel         = nil
CharteredRoomTalk.isDXXW = false 
CharteredRoomTalk._isInBackground = false


local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
if( ofile == "")then
    printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
end
local des    = json.decode(ofile)
local addDes = des["CHARTEREDROOM_FRIENDSOURCE_CHARTEREDROOMCHAT"]


function CharteredRoomTalk:create(panel)

    local image_sendMessageBar   = panel:getChildByName("Image_sendMessageBar")
    local panel_message_roller   = panel:getChildByName("Panel_message_roller")
    chatPanel                    = panel_message_roller 
    local textField              = image_sendMessageBar:getChildByName("TextField_toSend")
    local text_textFieldAssist   = image_sendMessageBar:getChildByName("Text_placeHolder")
    local button_expressionTable = image_sendMessageBar:getChildByName("Button_expression")
    local button_send            = image_sendMessageBar:getChildByName("Button_send")
    local Image_expression       = panel:getChildByName("Image_expression")
    local button_expression11    = Image_expression:getChildByName("Button_expression11")
    local button_expression12    = Image_expression:getChildByName("Button_expression12")
    local button_expression13    = Image_expression:getChildByName("Button_expression13")
    local button_expression21    = Image_expression:getChildByName("Button_expression21")
    local button_expression22    = Image_expression:getChildByName("Button_expression22")
    local button_expression23    = Image_expression:getChildByName("Button_expression23")
    local button_expression31    = Image_expression:getChildByName("Button_expression31")
    local button_expression32    = Image_expression:getChildByName("Button_expression32")
    local button_expression33    = Image_expression:getChildByName("Button_expression33")

    Image_expression:setVisible(false)
    messageBarTable = {}
    userID = mymodel('UserModel'):getInstance().nUserID

    self:upgradeMyTextField(textField, text_textFieldAssist)

    --[[button_expressionTable:onTouch( function(e)
        if e.name == 'ended' then            
            Image_expression:setVisible(not Image_expression:isVisible())
            print("show some expressions")
        end
    end)]]--
    button_expressionTable:addClickEventListener(function()
        my.playClickBtnSound()
        Image_expression:setVisible(not Image_expression:isVisible())
        print("show some expressions")
    end)
    
    local function onTouchBegan(touch,event)
        print("ontouchbegin of exp")
        local location = touch:getLocation()
        local node = event:getCurrentTarget()
        local locationInNode = node:convertToNodeSpace(location)
        local size = node:getContentSize()
        local rect = cc.rect(0,0,size.width,size.height)
        
        local sizeExpButton = button_expressionTable:getContentSize()
        local px ,py = button_expressionTable:getPosition()
        local worldPos = button_expressionTable:getParent():convertToWorldSpace({x=px,y=py})
        local expButtonPos = node:convertToNodeSpace(worldPos)
        local rectExpButton = cc.rect(expButtonPos.x-sizeExpButton.width/2,expButtonPos.y-sizeExpButton.height/2,sizeExpButton.width,sizeExpButton.height)
        if not cc.rectContainsPoint(rect,locationInNode) and not cc.rectContainsPoint(rectExpButton,locationInNode) then
            node:setVisible(false)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,Image_expression)
    
    local map = {
        [button_expression11] = "#beated";
        [button_expression12] = "#cool";
        [button_expression13] = "#cry";
        [button_expression21] = "#embarrassed";
        [button_expression22] = "#en";
        [button_expression23] = "#hurt";
        [button_expression31] = "#innocent";
        [button_expression32] = "#loser";
        [button_expression33] = "#sexy";
    }

    for button, event in pairs(map) do 
        button:addClickEventListener(function()
            my.playClickBtnSound()
            Image_expression:setVisible(false)
            self:sendTalk(event)
        end)
    end

    --[[button_send:onTouch(function (e)
        if e.name == 'ended' then 
            print("sendMsg")
            local str = self.editBox:getString()
            self:sendTalk(str)
            self.editBox:setString("")
        end
    end)]]--
    button_send:addClickEventListener(function()
        my.playClickBtnSound()
        print("sendMsg")
        local str = self.editBox:getString()
        self:sendTalk(str)
        self.editBox:setString("")
    end)

    local innerContainer = chatPanel:getInnerContainer()
    chatPanel:addEventListener(function(target, selector)
        
        local topBarPosY = nil 
        for k,v in pairs(messageBarTable) do 
            topBarPosY = v:getPositionY()
            break 
        end
        if innerContainer:getPositionY() < 0 and topBarPosY then 
            if topBarPosY < 400 then 
                chatPanel:scrollToBottom(1,true)
            end
        end
    end)

end

local function str2numTableForExpression(letter)
    dump(letter)
    if letter     == "#beated" then
        return 1    
    elseif letter == "#cool" then
        return 2
    elseif letter == "#cry" then
        return 3
    elseif letter == "#embarrassed" then
        return 4
    elseif letter == "#en" then
        return 5
    elseif letter == "#hurt" then
        return 6
    elseif letter == "#innocent" then
        return 7
    elseif letter == "#loser" then
        return 8
    elseif letter == "#sexy" then
        return 9
    elseif string.sub(letter,1,1) == "#" then 
        return -1
    else
        return false 
    end

end

local function str2FileTableForExpression(letter)
    dump(letter)
    if letter     == "#beated" then
        return "Node_Facial_huaixiao.csb"
    elseif letter == "#cool" then
        return "Node_Facial_mojing.csb"
    elseif letter == "#cry" then
        return "Node_Facial_paizhuan.csb"
    elseif letter == "#embarrassed" then
        return "Node_Facial_haose.csb"
    elseif letter == "#en" then
        return "Node_Facial_weiqu.csb"
    elseif letter == "#hurt" then
        return "Node_Facial_qian.csb"
    elseif letter == "#innocent" then
        return "Node_Facial_chouyan.csb"
    elseif letter == "#loser" then
        return "Node_Facial_bishi.csb"
    elseif letter == "#sexy" then
        return "Node_Facial_heise.csb"
    elseif string.sub(letter,1,1) == "#" then 
        --return -1
    else
        return false 
    end

end

local function setPositionForMessageBar(newMessageBar)
    
    newMessageBar:setPosition(0,55+nextMsgGap.this)
    chatPanel:addChild(newMessageBar)
    local innerContainer = chatPanel:getInnerContainer()
    print("positionY",innerContainer:getPositionY())
    --innerContainer:setPositionY(innerContainer:getPositionY()+80)
    if (#messageBarTable < MAX_TALK_NUM) then  

        for k,v in ipairs(messageBarTable) do 
            if v then 
                v:setPositionY(v:getPositionY()+130+nextMsgGap.this)
            end
        end

        local size =chatPanel:getInnerContainerSize()
        --size.height = size.height+130
        if  nextMsgGap.last then 
            local topBarPosY = nil 
            for k,v in pairs(messageBarTable) do 
                topBarPosY = v:getPositionY()
                break 
            end
            if topBarPosY then 
                if topBarPosY > 380 then  
                    print('nextMsgGap.last:'..nextMsgGap.last) 
                    print('nextMsgGap.this:'..nextMsgGap.this) 
                    size.height = topBarPosY + 100
                else
                    innerContainer:setPositionY(-130)
                    print("positionY2",innerContainer:getPositionY())
                end
            end
        end
        chatPanel:setInnerContainerSize(size)

    elseif (#messageBarTable >= MAX_TALK_NUM) then 
        innerContainer:setPositionY(-(130+nextMsgGap.this))
        local removeMarker = 1
        for k,v in pairs(messageBarTable) do
            if v then 
                v:setPositionY(v:getPositionY()+130+nextMsgGap.this)
                if (removeMarker == 1) then 
                    chatPanel:removeChild(messageBarTable[k])
                    removeMarker = nil

                end
            end
        end  
        table.remove(messageBarTable,1)    
        for k,v in pairs(messageBarTable) do 
            local topBarPosY = messageBarTable[k]:getPositionY()
            local size = {width = 550, height = topBarPosY + 100}
            chatPanel:setInnerContainerSize(size)
            break 
        end
          
    else
        print("messageBarTable is not a table expected",type(messageBarTable))
    end

    table.insert(messageBarTable,newMessageBar)
    chatPanel:scrollToBottom(1,true)

end

local function addNewMessageBar(userName,vnUserID,text,path,sex)

    print('addNewMessageBar')
    dump(text)
    local newMessageBar          = nil 
    local panel_bk               = nil 
    local head                   = nil 
    local textUserName           = nil
    local textUserMessage        = nil 
    local Image_messageBar       = nil
    local headTexture            = nil 
    local textUserMessage_assist = nil

    if userID ~= vnUserID then 
        newMessageBar            = cc.CSLoader:createNode('res/GameCocosStudio/CharteredRoom/Talk_Left.csb')
    else 
        newMessageBar            = cc.CSLoader:createNode('res/GameCocosStudio/CharteredRoom/Talk_Right.csb')
        textUserMessage_assist   = newMessageBar:getChildByName("Panel_bk"):getChildByName("Img_head"):getChildByName("Text_talk_alignmentLeft")
        textUserMessage_assist:setVisible(false)    
        textUserMessage_assist:setPositionY(textUserMessage_assist:getPositionY()+8)
        --userName = UserModel.szUtf8Username
        userName = UserModel:getSelfDisplayName()
    end 

    panel_bk                     = newMessageBar:getChildByName("Panel_bk")
    Image_messageBar             = panel_bk:getChildByName("Image_messageBar")
    head                         = panel_bk:getChildByName("Img_head")
    textUserName                 = head:getChildByName("Text_userName")
    textUserMessage              = head:getChildByName("Text_talk")
    headTexture                  = head:getChildByName("Image_portrait")

    textUserMessage:setPositionY(textUserMessage:getPositionY()+8)
    --Image_messageBar:setPositionY(Image_messageBar:getPositionY()-10)

    --consider the gender
    if headTexture then
        --headTexture:loadTexture(cc.exports.getHeadResPath(sex))
        local nickSexChecked = UserModel:getNickSexWithCheckSelf(vnUserID, sex)
        headTexture:loadTexture(cc.exports.getHeadResPath(nickSexChecked))
    end
    
    if path and path ~= '' and cc.exports.isSocialSupported() then 
        headTexture:loadTexture(path)
    end    
    headTexture:setTouchEnabled(true)
    headTexture:setEnabled(true)

    --show userInfo falg

    local function touchBegan(touch, event)
        if CharteredRoomTalk._isInBackground then 
            return 
        end
        print('touch began')
        local node = event:getCurrentTarget()
        local location = touch:getLocation()
        local locationInNode = node:getParent():convertToNodeSpace(location)
        local s = node:getParent():getContentSize()
        local rect = cc.rect(0,0,s.width,s.height)

        local flagPos = {x=748.8,y=location.y-180}
        if flagPos.y<20 then 
            flagPos.y = 20
        end
        if (cc.rectContainsPoint(rect,locationInNode) and location.y<600) then 
            print('in node')   
            CharteredRoomTalk._room:showFlag(vnUserID,flagPos,false,addDes)
        end                         
    end    
    local listener1 = cc.EventListenerTouchOneByOne:create()
 --   listener1:setSwallowTouches(true) 
    listener1:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1,headTexture:getChildByName('Node_converter'))

    local orderNum  = nil

    --control the distance between messages 
    nextMsgGap.last = nextMsgGap.this
    nextMsgGap.this = nil 

    if (userName == '' or userName == nil ) then 
        print("unexpected situatuion, we get no username")
    else
         --textUserName:setString(userName)
         my.fitStringInWidget(userName, textUserName, 200)
    end

    if (text == '' or text == nil )then 
        print("unexpected situatuion, we get no text to send ")
    else
        
        --orderNum = str2numTableForExpression(text)
        orderNum = str2FileTableForExpression(text)
        
        print(string.len(text))
        print(orderNum)
        if orderNum then 
            Image_messageBar:setVisible(false)
            textUserMessage:setVisible(false)
            --local actionNodeStr = 'res/GameCocosStudio/chat/face/node_face_'..orderNum..'.csb'
            local actionNodeStr = "res/GameCocosStudio/csb/facial_emotion/"..orderNum
            local actionNode    = cc.CSLoader:createNode(actionNodeStr)
            local action        = cc.CSLoader:createTimeline(actionNodeStr)
           
            if userID ~= vnUserID then
                actionNode:setPosition(150,-5)
            else 
                actionNode:setPosition(430,-5)
            end
            panel_bk:addChild(actionNode)    
            if action and actionNode then 
                actionNode:runAction(action)
                --action:gotoFrameAndPlay(0, 25, true)
                action:play("animation_facial", true)
                nextMsgGap.this = 45
            end 
        end

        local labelWidth = 0
        local lable = cc.Label:create()
        if lable then
            lable:setSystemFontSize(textUserMessage:getFontSize())
            lable:setString(text)
            labelWidth = lable:getContentSize().width
        end

        local size                 = textUserMessage:getContentSize()
        textUserMessage:setString(text)
        local renderSize           = textUserMessage:getVirtualRendererSize()
        if (not nextMsgGap.this) then             
            if (labelWidth >= size.width) then
                nextMsgGap.this    = 0
                if userID == vnUserID then 
                    textUserMessage:setVisible(false)
                    textUserMessage_assist:setVisible(true)
                    textUserMessage_assist:setString(text)
                end
            else
                local contentSize  = Image_messageBar:getContentSize()
                contentSize.height = 60
                contentSize.width  = renderSize.width+8
                Image_messageBar:setContentSize(contentSize)
                nextMsgGap.this    = -5
            end
        end
    end

    if (orderNum == -1) then 
        print("unKnown expression, hide it")
        return 
    end
    setPositionForMessageBar(newMessageBar)  
end

function CharteredRoomTalk:loadHistory()
    talkData={}
    if CharteredRoomTalk.isDXXW == true then 
        --local filename=my.getTalkDataFilename()
        local filename=self:getTalkDataFilename()
        if(my.isCacheExist(filename))then
            local talkData_cache=my.readCache(filename)
            dump(talkData)
            if (talkData_cache.data~= nil) then 
                dump(talkData_cache.data)
                local talkData_cache_json = talkData_cache.data
               if talkData_cache_json == "[]" then 
                   talkData = {}
               else
                   talkData = json.decode(talkData_cache_json)
               end
            end    
        else
            my.saveCache(filename,talkData)
        end   
    end

end

function CharteredRoomTalk:getTalkDataFilename()
    local user=mymodel('UserModel'):getInstance()
    local fileName="TalkData_"..tostring(user.nUserID)..".xml"
	return fileName
end

function CharteredRoomTalk:saveHistory()
    --[[local filename      = self:getTalkDataFilename()
    local talkData_Json = json.encode(talkData)
    local tempTable     = {}
    tempTable.data      = talkData_Json
    my.saveCache(filename,tempTable)]]--
end


function CharteredRoomTalk:updateTalk()  
    for i,v in pairs(talkData)do
        addNewMessageBar(v.name,v.userID,v.message,v.path,v.sex)
    end
end

function CharteredRoomTalk:addHistory(talkinfo)
    print('step1')
    talkData[#talkData+1] = talkinfo
    if(table.maxn(talkData)>MAX_TALK_NUM)then
        table.remove(talkData,1)
    end
    self:saveHistory()
end

function CharteredRoomTalk:clearHistory()
    talkData={}
    self:saveHistory()
end



function CharteredRoomTalk:onSomeOneTalked(chatFromTable,tableChatContent)

    local talkinfo = {}

    print("data for talk get")
    for i,v in ipairs(self._room._playerInfo) do 
        if (v.nUserID == chatFromTable.nUserID) then 
            print(v.szUserName)
            local utf8Name        = MCCharset:getInstance():gb2Utf8String(v.szUserName, string.len(v.szUserName))
            local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
            if not tcyFriendPlugin then return end
            local remarkname      = tcyFriendPlugin:getRemarkName(v.nUserID)
            if remarkname and remarkname ~= "" then 
                printf("remarkname is " .. remarkname)
                addNewMessageBar(remarkname,v.nUserID,tableChatContent,v.portraitPath,v.nNickSex)
                talkinfo.name = remarkname
            else
                addNewMessageBar(utf8Name,v.nUserID,tableChatContent,v.portraitPath,v.nNickSex)
                talkinfo.name = utf8Name
            end
            talkinfo.message = tableChatContent
            talkinfo.userID  = v.nUserID
            talkinfo.path    = v.portraitPath
            talkinfo.sex     = v.nNickSex
            self:addHistory(talkinfo)
        end
    end
end

function CharteredRoomTalk:customerServiceTalked(content)
    local talkinfo      = {}
    talkinfo.name       = des["CHARTEREDROOM_CUSTOMERSERVICE"]
    talkinfo.userID     = 0
    talkinfo.message    = content
    talkinfo.path       =  cc.exports.getHeadResPath(true)-- 'res/HallCocosStudio/images/role_icon/gir2.head_pic.png'
    talkinfo.sex        = 0

    addNewMessageBar(talkinfo.name, talkinfo.userID, talkinfo.message, talkinfo.path, talkinfo.sex)
    self:addHistory(talkinfo)
end

function CharteredRoomTalk:sendTalk(message)
    self._room:sendTalk(message)

end

function CharteredRoomTalk:onGetSyncInfo()

    if not messageBarTable or messageBar == {} then 
        print("no messageBar exist")
        return 
    end
    for i,v in pairs (self._room._playerInfo )do 
        for ii,vv in pairs(messageBarTable) do 
            local head = vv:getChildByName('Panel_bk'):getChildByName('Img_head')         
            if (head:getChildByName('Text_userName') == v.szUserName) then 
                if cc.exports.isSocialSupported() then
                    head:getChildByName("Image_portrait"):loadTexture(v.portraitPath)
                end
            end
        end
    end

end

function CharteredRoomTalk:clearTalkPanel()

    --[[chatPanel:removeAllChildren()
    messageBarTable = {}]]--

end

function CharteredRoomTalk:quit()
    self:clearTalkPanel()
    self:clearHistory()  
    print('chatquit')
end

function CharteredRoomTalk:upgradeMyTextField(textField, text)

    self.text_placeHolder        = text:getString()
    text:setVisible(false)  

    local editBox=ccui.EditBox:create(textField:getContentSize(),'res/HallCocosStudio/imagesbox5_shuru_pic.png')
    editBox:setPosition(textField:getPosition())
    editBox:setAnchorPoint(textField:getAnchorPoint())
    editBox.getString=editBox.getText
    editBox.setString=editBox.setText
    editBox:setLocalZOrder(textField:getLocalZOrder()+1)
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    editBox:setFontColor(display.COLOR_BLACK)
    local parent=(textField:getParent()~=imageView and textField:getParent()) or textField:getParent():getParent()
    parent:addChild(editBox)
    editBox:setMaxLength(30)
    textField:setVisible(false)
    --editBox:setVisible(true)
    editBox:setFontColor(cc.c3b(255,255,255))
  
    editBox:setFontName("Arial")
    editBox:setFontSize(28)
    editBox:setPlaceHolder(self.text_placeHolder)
    editBox:setPlaceholderFontName("Arial")
    editBox:setPlaceholderFontColor(cc.c3b(116,116,116))
   
    self.editBox = editBox

end

function CharteredRoomTalk:onEnterForgroud()
    CharteredRoomTalk._isInBackground = false
end

function CharteredRoomTalk:onEnterBackground()
    CharteredRoomTalk._isInBackground = true
end

return CharteredRoomTalk
