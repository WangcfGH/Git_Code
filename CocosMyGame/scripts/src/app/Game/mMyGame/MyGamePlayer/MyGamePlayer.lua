local SKGamePlayer = import("src.app.Game.mSKGame.SKGamePlayer")
local MyGamePlayer = class("MyGamePlayer", SKGamePlayer)

local constStrings1=cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/Game/mSKGame/ChatStrings.json"))
local constStrings2=cc.load('json').json.decode(cc.FileUtils:getInstance():getStringFromFile('src/app/Game/mSKGame/ChatStrings-female.json'))

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

MyGamePlayer.EFFECT_BAOJING_PATH = "PublicSound/alarm.mp3"
function MyGamePlayer:init()
    MyGamePlayer.super.init(self)
    self._nodeJingBao = self._playerPanel:getChildByName("Node_JingBao")
    local playerName = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Panel_PlayerName")
    self._playerUserDeposit = playerName:getChildByName("Value_sliver")
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        local silverIcon = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Hall_Icon_Silver_S_1")
        silverIcon:setVisible(false)
        local silverBG = playerName:getChildByName('Image_1')
        silverBG:setVisible(false)
        self._playerUserDeposit:setVisible(false)
    end
    self._playerUserTimingScore = playerName:getChildByName("Value_timingscore")
end

function MyGamePlayer:initPlayer()
    MyGamePlayer.super.initPlayer(self)
    self._haveAlarm = false
end

function MyGamePlayer:resetPlayer()
    MyGamePlayer.super.resetPlayer(self)
    self._haveAlarm = false
end

function MyGamePlayer:setAlarm(isHaveAlarm)
    self._haveAlarm = isHaveAlarm
end

function MyGamePlayer:tipJingBao()
    local path = 'res/GameCocosStudio/csb/Node_BaoJing.csb'

    if self._nodeJingBao and not self._haveAlarm then
        self:setAlarm(true)
        local aniNode   = cc.CSLoader:createNode(path)
        local action    = cc.CSLoader:createTimeline(path)

        local panelJingBao = self._playerPanel:getChildByName("Node_JingBao")
        self._playerPanel:addChild(aniNode)
        aniNode:setPosition(panelJingBao:getPosition())
        if action then
            aniNode:runAction(action)
            action:play("animation0", false)
            self._gameController:playEffect(self.EFFECT_BAOJING_PATH)
        local function callBack(frame)
            if frame and frame:getEvent() == "Play_Over" then
                action:clearFrameEventCallFunc()
                aniNode:removeFromParent()
            end
        end
        action:setFrameEventCallFunc(callBack)
        end
    end

end

--玩家银子显示
function MyGamePlayer:setDeposit(iDeposit)
    if self._playerUserDeposit then
        if not PUBLIC_INTERFACE.IsStartAsTimingGame() then
            self._playerUserDeposit:setVisible(true)
        end
        self._playerUserDeposit:setMoney(iDeposit)
    end
end

--玩家定时赛积分显示
function MyGamePlayer:setTimingScore(iDeposit)
    if self._playerUserDeposit then
        self._playerUserDeposit:setVisible(false)
        self._playerUserTimingScore:setVisible(true)
        self._playerUserTimingScore:setString(iDeposit)

        local icon = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Hall_Icon_Silver_S_1")
        --icon:ignoreContentAdaptWithSize(true)
        icon:setTexture("res/GameCocosStudio/CharteredRoom/background/Hall_Icon_Score_S.png")
    end
end

--重载：设置银子和不显示位置
function MyGamePlayer:setSoloPlayer(soloPlayer)
    MyGamePlayer.super.setSoloPlayer(self, soloPlayer)

    if PUBLIC_INTERFACE.IsStartAsTimingGame() then
        self:setTimingScore(soloPlayer.nReserved[3])
    elseif not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        self:setDeposit(soloPlayer.nDeposit)
    end
    self._playerLbsPanel:setVisible(false)

    --重载：为了获取位置控件，屏蔽控件显示
    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    for i = 1, self._gameController:getTableChairCount() do
        if self._playerLbs then
            if playerManager._players[i] and playerManager._players[i]._playerUserID == soloPlayer.nUserID then
                playerManager._players[i]._playerLbs = self._playerLbs
            end
         end
    end
end


--重载：屏蔽头像旁边的等级
function MyGamePlayer:updataUserLevelInfo(msgLevelData)
    MyGamePlayer.super.updataUserLevelInfo(self,msgLevelData)
    self._playerLevelImage:setVisible(false)
end

--重载：屏蔽头像旁边的点赞按钮
function MyGamePlayer:updataOtherUpInfo(upData, index)
    MyGamePlayer.super.updataOtherUpInfo(self,upData, index)
    self._playerInfoHead:getChildByName("Btn_Praise"):setVisible(false)
end

--重载：屏蔽头像旁边的点赞按钮和点赞信息
function MyGamePlayer:setShowUpInfo(upInfo)
    MyGamePlayer.super.setShowUpInfo(self,upInfo)

    self._playerInfoHead:getChildByName("Btn_Praise"):setVisible(false)

    local playerName = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Panel_PlayerName")  
    ccui.Helper:seekWidgetByName(playerName, "Text_Praise"):setVisible(false)
    self._playerUpNum:setVisible(false)
end

--重载：屏蔽头像旁边的点赞按钮和点赞信息
function MyGamePlayer:updataUpInfo(upData)
    MyGamePlayer.super.updataUpInfo(self,upData)
    
    local playerName = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Panel_PlayerName")  
    ccui.Helper:seekWidgetByName(playerName, "Text_Praise"):setVisible(false)
    self._playerUpNum:setVisible(false)
end

--获取点赞信息
function MyGamePlayer:showPraiseTextInfo()
    local playerUpNum = self._playerUpNum:getString()
    local praiseText = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_praise")
    if praiseText then
        praiseText:setString(playerUpNum)
    end
end

--获取地理位置
function MyGamePlayer:showPositionTextInfo()
    local positionInfo = self._playerLbs:getString()
    local positionText = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_position")
    local text = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_position")
    if positionText and positionInfo ~= "" then
        positionText:setString(positionInfo)
        positionText:setVisible(true)
        text:setVisible(true)
    else
        positionText:setVisible(false)
        text:setVisible(false)
    end
end

--重载：显示详情界面的点赞信息和位置信息
function MyGamePlayer:showPlayerInfo(bShow)
    MyGamePlayer.super.showPlayerInfo(self, bShow)
    if self._playerInfoPanel then
        if bShow then
            self:showPraiseTextInfo()
            self:showPositionTextInfo()
        end
    end
end

--名字最多5个汉字  同时设置底框
function MyGamePlayer:setUserName(szUserName)
    if not self._playerUserName then return end

    local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
    my.fitStringInWidget(utf8name, self._playerUserName, 115)
    self._playerUserName:setVisible(true)

    local playerName = self._playerPanel:getChildByName("Node_PlayerName")
    playerName:setVisible(true)
    self._playerInfoHead:getChildByName("touxiangkuang"):setVisible(true)
end

function MyGamePlayer:setNickSex(nNickSex)
    self._nickSex = nNickSex

    if self._playerHead then
        local resName = ""
        if 1 == nNickSex then
            resName = "res/Game/GamePic/GameContents/touxiang_girl.png"
        else
            resName = "res/Game/GamePic/GameContents/touxiang_boy.png"
        end
        self._playerHead:setTexture(resName)
    end
end

function MyGamePlayer:tipChatContent(content)
    if self._playerPanel then
        local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
        utf8Content = string.gsub(utf8Content, "%s", "")
        utf8Content = string.gsub(utf8Content, "AUTO_CHAT_SUFFIX", "")
        --local str = string.sub(utf8Content,1,-2)
        print("tipChatContent ", utf8Content)
        local str = utf8Content
        if str == constStrings1["HLS_CHAT_Emotion_1"] then
            self:playFacial("Node_Facial_huaixiao.csb","animation_facial")
            return       
        elseif str == constStrings1["HLS_CHAT_Emotion_2"] then
            self:playFacial("Node_Facial_mojing.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_3"] then
            self:playFacial("Node_Facial_paizhuan.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_4"] then
            self:playFacial("Node_Facial_haose.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_5"] then
            self:playFacial("Node_Facial_weiqu.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_6"] then
            self:playFacial("Node_Facial_qian.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_7"] then
            self:playFacial("Node_Facial_chouyan.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_8"] then
            self:playFacial("Node_Facial_bishi.csb","animation_facial")
            return 
        elseif str == constStrings1["HLS_CHAT_Emotion_9"] then
            self:playFacial("Node_Facial_heise.csb","animation_facial")
            return 
        else
            
        end
    end

    if self._playerChatFrame then
        self._playerChatFrame:getParent():setVisible(true)
        self._playerChatFrame:setVisible(true)

        local loadingPath
        if self._drawIndex == 2 or self._drawIndex == 3 then
            loadingPath = "res/GameCocosStudio/csb/Node_ChatPapo_R.csb"
        elseif self._drawIndex == 1 or self._drawIndex == 4 then 
            loadingPath = "res/GameCocosStudio/csb/Node_ChatPapo_L.csb"
        end
        if loadingPath then           
            self._action = cc.CSLoader:createTimeline(loadingPath)
            self._playerChatFrame:runAction(self._action)
            self._action:play("animation_ChatPapo", false)
        end

        local listCount = 13
        if self._playerChatStr then
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
            utf8Content = string.gsub(utf8Content, "%s", "")
            utf8Content = string.gsub(utf8Content, "AUTO_CHAT_SUFFIX", "")
            --local str = string.sub(utf8Content,1,-2)
            local str = utf8Content
            local strPath
            local sex = self._nickSex
            local data = self._gameController._baseGameScene:getSetting()
            local langauge = data._selectedLangauge
            
            local constStrings = constStrings1
            if sex == 1 then
                constStrings = constStrings2    
                strPath = "res/Game/GameSound/Chat/Female/Mandarin/female_chat_"
                listCount = 13
            else
                constStrings = constStrings1
                strPath = "res/Game/GameSound/Chat/Male/Mandarin/chat_"
                listCount = 14
            end        
            for i=1,listCount do
                if constStrings["HLS_CHAT_WORDS_"..i+50] == str then
                    audio.playSound(strPath..tostring(i-1)..".mp3",false)
                    break
                end
            end
            
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

--点击玩家头像时获取点赞信息
function MyGamePlayer:setClickEvent()
    local function onClickPlayerHead()
        local playerInfoManager = self._gameController:getPlayerInfoManager() or {}
        local playerInfo = playerInfoManager:getPlayerInfo(self._drawIndex)
        if playerInfo and self._drawIndex ~= 1 then
            self._gameController:OnUpInfo({
                nUserID = playerInfo.nUserID,    
                nChairNO = playerInfo.nChairNO,  
            })
        end
        self:onClickPlayerHead()
    end
    if self._playerBtnHead then
        self._playerBtnHead:addClickEventListener(onClickPlayerHead)
    end
end


return MyGamePlayer