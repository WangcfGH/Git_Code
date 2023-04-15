
local SKGameResultPanel = import("src.app.Game.mSKGame.SKGameResultPanel")
local MyResultPanel = class("MyResultPanel", SKGameResultPanel)

--local RoomsView =  require("src.app.plugins.myroomspanel.MyRoomsView")
local localGamePublicInterface = require("src.app.Game.mMyGame.GamePublicInterface")
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

function MyResultPanel:ctor(gameWin, gameController, isNetless)
    if not gameController then return end

    self._selfChairNO   = gameController._selfChairNO + 1

    self._gamedata  = gameController:getMyGameDataXml()

    self._winChairNo = 0
    for i = 1, 4 do
        if gameWin.nPlace[i] == 1 then
            self._winChairNo = i
            break
        end
    end      

    self._closeTime = false

    self._isNetLess = isNetless

    MyResultPanel.super.ctor(self, gameWin, gameController)
end

function MyResultPanel:init()
    MyResultPanel.super.init(self)
end

function MyResultPanel:onExit()
    print("MyResultPanel:onExit")
    self._gameController:hideBannerAdvert()

    self._gameController._baseGameScene._MyPanel_Odds:setVisible(false)
    self._gameController:IsHaveTaskFinish()
    --MyResultPanel.super.onExit(self)
end

function MyResultPanel:isLose()
    if self._gameWin then     
        local MyGameUtilsInfoManager    = self._gameController._baseGameUtilsInfoManager  
        if self._winChairNo == self._selfChairNO or self._winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(self._selfChairNO-1))+1 then
            return false
        else
            return true
        end
    end

    return false
end

function MyResultPanel:chairIsLose(chairNo)
    if self._gameWin then     
        local MyGameUtilsInfoManager    = self._gameController._baseGameUtilsInfoManager  
        if self._winChairNo == chairNo or self._winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(chairNo-1))+1 then
            return false
        else
            return true
        end
    end

    return false
end

function MyResultPanel:initResultPanel()
    local csbPath = "res/GameCocosStudio/csb/Node_Result_Win.csb"
    if self:isLose() then
        csbPath = "res/GameCocosStudio/csb/Node_Result_Lose.csb"
        self._gameController:playGamePublicSound("Snd_lose.mp3")

        self._gamedata.winContinual = 0
    else
        self._gameController:playGamePublicSound("Snd_win.mp3")

        if self._gamedata.winContinual then
            self._gamedata.winContinual = self._gamedata.winContinual + 1
        else
            self._gamedata.winContinual = 1
        end
    end
    self._gameController:saveMyGameDataXml(self._gamedata)

    
    self._resultPanel = cc.CSLoader:createNode(csbPath)
    if self._resultPanel then
        self:addChild(self._resultPanel)
        SubViewHelper:adaptNodePluginToScreen(self._resultPanel, self._resultPanel:getChildByName("Panel_Shade"))
        local panelResult = self._resultPanel:getChildByName("Panel_Result")
        if self:isLose() then
            panelResult = self._resultPanel:getChildByName("Panel_Result")
        end

        if panelResult then
            self:initButtons(panelResult)
            self:initAnimation(panelResult)
            self:initScore(panelResult)
            --self:initSimple(panelResult)
            self:initDetails(panelResult)
            self:initLevel()
        end
    end
   
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._resultPanel:runAction(action)
        if self:isLose() then
            action:gotoFrameAndPlay(1, 35, false)
        else
            action:gotoFrameAndPlay(1, 28, false)
        end
    end
end

function MyResultPanel:initButtons(panelResult)
    local function onClose()
        self:onClose()
    end
    local buttonClose = ccui.Helper:seekWidgetByName(panelResult, "Btn_Close")
    if buttonClose then
        buttonClose:addClickEventListener(onClose)
    end
    local function onShare()
        self:onShare()
    end
    local buttonShare = ccui.Helper:seekWidgetByName(panelResult, "Btn_Show")
    if buttonShare then
        buttonShare:addClickEventListener(onShare)
    end

    local function onRestart()
        self:onRestart()
    end
    local buttonRestart = ccui.Helper:seekWidgetByName(panelResult, "Btn_Continue")
    if buttonRestart then
        buttonRestart:addClickEventListener(onRestart)
    end

    if buttonShare and not cc.exports.isShareSupported() then
        buttonShare:setVisible(false)
        buttonRestart:setPosition(cc.p(display.center.x, buttonRestart:getPositionY()))
    end

    local buttonJump = ccui.Helper:seekWidgetByName(panelResult, "Btn_Jump")
    buttonJump:setVisible(false)
    buttonJump:setScale9Enabled(false)

     --初始化Btn_Prompt
    local function onGoToRoom()
        self:onGoToRoom()
    end

    --判定Btn_Prompt是否需要显示，若显示则显示相关按钮，并记录跳转房间
    --依赖数据：PromptLine、所在房间上限、结算后携带银子、所在房间号、进阶提示房间名
    local gameJsonConfig = cc.exports._gameJsonConfig
    --local roomInfo = PublicInterface.GetCurrentRoomInfo()
    
    local nRoomID       =  self._gameController._baseGameUtilsInfoManager:getRoomID()
    local nMaxDeposit   =  self._gameController._baseGameUtilsInfoManager:getRoomMaxDeposit()
    local nMinDeposit   =  self._gameController._baseGameUtilsInfoManager:getRoomMinDeposit()

    if gameJsonConfig.PromptLine ~= nil then
        local nPromptLine   = gameJsonConfig.PromptLine[tostring(nRoomID)] --提示线
        local gameplayer    = self._gameController:getPlayerInfoManager()
        local nSelfDeposit  = gameplayer:getSelfDeposit() --携银
        
        if RoomListModel:isLimitTimeOpenRoom(nRoomID) then
            local curTimeStamp = MyTimeStamp:getLatestTimeStamp()
            local startHour, startMinute, endHour, endMinute = RoomListModel:getOpenTime(roomInfo["nRoomID"])
            local curYear = os.date("%Y", curTimeStamp)
            local curMonth = os.date("%m", curTimeStamp)
            local curDay = os.date("%d", curTimeStamp)            
            local startTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=startHour, min=startMinute, sec=0})
            local endTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=endHour, min=endMinute, sec=0})
            if curTimeStamp < startHour or endTimeStamp < curTimeStamp then
                nPromptLine = nil
            end                    
        end

        --if nPromptLine and nSelfDeposit >= nPromptLine and nSelfDeposit <= nMaxDeposit then
        if nPromptLine and nSelfDeposit >= nPromptLine then
            --获取进阶提示房
            --[[local roomlist = RoomsView:GetCurrentSecondGradeRoomsList()
            local jumpRoomID, jumpRoomMin = localGamePublicInterface:getPromptTipRoomID(roomlist, nPromptLine,nRoomID)]]--
            local seniorRoomInfo = RoomListModel:findSeniorRoomInGame(cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo())

            --self._junpRoomID = jumpRoomID
            --if jumpRoomMin < nMinDeposit then
            if not seniorRoomInfo then
                self._gotoRoom = nil
                -- 如果计算得到的房间比当前房间下限小，则不要显示进阶跳转按钮
                return
            end
 
            local jumpRoomName = seniorRoomInfo["szRoomName"]
            self._gotoRoom = seniorRoomInfo
            --[[for i = 1, #roomlist do
                local roomImpl = roomlist[i].original

                if roomImpl and roomImpl.nRoomID == jumpRoomID then
                     jumpRoomName = roomImpl.szRoomName
                     self._gotoRoom = roomlist[i]  
                     break
                end
            end]]--
            
            local posX = buttonShare:getPositionX()
            local isShowJumpButton = false
            local imgPath = ""
            --jumpRoomName = MCCharset:getInstance():gb2Utf8String( jumpRoomName, string.len(jumpRoomName) ) 

            local roomNameSecond = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SECOND")        -- 初级房
            local roomNameThird = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_THIRD")          -- 中级房
            local roomNameFourth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FOURTH")        -- 高级房
            local roomNameFiveth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FIVETH")        -- 大师房
            local roomNameSixth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SIXTH")          -- 至尊房
            local roomNameSeventh = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SEVENTH")       -- 至尊房
            
            cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/JumpRoomBtns.plist")
            if jumpRoomName ==  MCCharset:getInstance():gb2Utf8String(roomNameSecond, string.len(roomNameSecond) )then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomLow.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameThird, string.len(roomNameThird)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomMiddle.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFourth, string.len(roomNameFourth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomHigh.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFiveth, string.len(roomNameFiveth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomMaster.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSixth, string.len(roomNameSixth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomSupreme.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSeventh, string.len(roomNameSeventh)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomZongShi.png"
            end
            
            if true ==  isShowJumpButton then
                buttonRestart:setPositionX(posX + 220)
                buttonJump:setPositionX(posX + 440)
                buttonJump:loadTextureNormal(imgPath, 1)
                buttonJump:setVisible(true)
                buttonJump:addClickEventListener(handler(self, self.onGoToRoom))
            end

            if self._gotoRoom then
                --self._gameController._promptRoom = clone(self._gotoRoom)
                self._gameController._promptRoom = {
                    ["jumpNewRoom"] = false,
                    ["targetRoomInfo"] = self._gotoRoom
                }
            end
        end
    end

end

function MyResultPanel:initAnimation(panelResult)
    local panelAnimation = panelResult:getChildByName("Panel_TitleLight"):getChildByName("Node_LightLoop")

    if panelAnimation then
        local csbPath = "res/GameCocosStudio/csb/Node_ResultLightLoop_Win.csb"
        if self:isLose() then
            csbPath = "res/GameCocosStudio/csb/Node_ResultLightLoop_Lose.csb"
        end
        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            panelAnimation:runAction(action)
            action:play("animation_LightLoop", true)
        end
    end
    if self:isLose() then
        panelAnimation = panelResult:getChildByName("Panel_TitleLight"):getChildByName("Node_Sown")
        if panelAnimation then
            panelAnimation:setLocalZOrder(-1)
            local csbPath = "res/GameCocosStudio/csb/Node_Failed_Animation_Circle.csb"

            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                panelAnimation:runAction(action)
                action:gotoFrameAndPlay(1, 20, true)
            end
        end

        panelAnimation = panelResult:getChildByName("Node_ResultTitle_Lose")
        if panelAnimation then
            local csbPath = "res/GameCocosStudio/csb/Node_ResultTitle_Lose.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                panelAnimation:runAction(action)
                action:play("animation_TitleLose", false)
            end
        end
    else
        self:createContinualWinEffect(panelResult, self._gamedata.winContinual)
    end 

    local boyIcon = panelResult:getChildByName("Panel_Role"):getChildByName("Img_Boy")
    local girlIcon = panelResult:getChildByName("Panel_Role"):getChildByName("Img_Girl")
    boyIcon:setVisible(false)
    girlIcon:setVisible(false)

    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if playerInfoManager then
        local nNickSex = playerInfoManager:getSelfNickSex()       
        if nNickSex == 1 then
            girlIcon:setVisible(true)
        else
            boyIcon:setVisible(true)
        end
    end
end

function MyResultPanel:createContinualWinEffect(panelResult, nContinualWinNum)
    --[[if nContinualWinNum <= 1 then
        return
    end--]]
    local wsBout = cc.exports.getGuideCommentsWSBout()
    if wsBout and nContinualWinNum >= toint(wsBout) then
        cc.exports.needShowGuideComments = true
    end

    if nContinualWinNum >= 2 then
        local panelAnimation = panelResult:getChildByName("Node_ResultTitle_Parlay")
        local parlayNum = panelAnimation:getChildByName("Panel_TitleParlay"):getChildByName("Font_ParlayNum")
        if parlayNum then
            if nContinualWinNum >=9 then
                nContinualWinNum = 9
            end
            parlayNum:setString(tostring(nContinualWinNum))
        end
        if panelAnimation then
            local csbPath = "res/GameCocosStudio/csb/Node_ResultTitle_Parlay.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                panelAnimation:runAction(action)
                action:play("animation_ResultTitle_Parlay", false)
            end
        end
    else
        local panelAnimation = panelResult:getChildByName("Node_ResultTitle_Win")
        if panelAnimation then
            local csbPath = "res/GameCocosStudio/csb/Node_ResultTitle_Win.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                panelAnimation:runAction(action)
                action:play("animation_TitleWin", false)
            end
        end
    end
end

function MyResultPanel:initScore(panelResult)
    --[[local Score = ccui.Helper:seekWidgetByName(panelResult, "fnt_value_score")
    if Score then
        local winscore = self._gameWin.nBaseScore
        if winscore then
            Score:setString(tostring(winscore))
        end
    end

    local double = ccui.Helper:seekWidgetByName(panelResult, "fnt_value_times")--]]
    --[[if double then
        local showDoubles = self._gameWin.nReserved3[1]
        if showDoubles then
            double:setString(tostring(showDoubles))
        end
    end--]]
end

function MyResultPanel:initSimple(panelResult)
    local panelSimple = panelResult:getChildByName("panel_simple")
    if self:isLose() then
        panelSimple = panelResult:getChildByName("panel_failed_simple")
    end

    if panelSimple then
        panelSimple:setVisible(true)

        self:setSimpleRole(panelSimple)
        self:setSimpleScore(panelSimple)
        self:setDetailsBtn(panelSimple)
    end
end

function MyResultPanel:isBanker(chairno)
    return chairno == self._gameWin.nBanker
end

function MyResultPanel:isHelper(chairno)
    return chairno == self._gameWin.nFriendChair
end

function MyResultPanel:setSimpleRole(panelSimple)
    local iconRole = ccui.Helper:seekWidgetByName(panelSimple, "img_icon_role")
    if iconRole then
        local playerInfoManager = self._gameController:getPlayerInfoManager()
        if playerInfoManager then
            local nNickSex = playerInfoManager:getSelfNickSex()
            local resName = ""
            if self:isBanker(self:getMyChairNO()) then
                resName = "res/Game/GamePic/result_role/role_landelord"
            elseif self:isHelper(self:getMyChairNO()) then
                resName = "res/Game/GamePic/result_role/role_lagt"
            elseif 1 == nNickSex then
                resName = "res/Game/GamePic/result_role/role_famer_female"
            else
                resName = "res/Game/GamePic/result_role/role_famer_male"
            end

            if self:isLose() then
                resName = resName.."_2.png"
            else
                resName = resName.."_1.png"
            end

            iconRole:loadTexture(resName)
        end
    end
end

function MyResultPanel:setSimpleScore(panelSimple)
    local score = ccui.Helper:seekWidgetByName(panelSimple, "fnt_score_all")
    if score then
        local scoreDiff = self._gameWin.nScoreDiffs[self._selfChairNO]
        if 0 <= scoreDiff then
            score:setString("+"..tostring(scoreDiff))
        else
            score:setString(tostring(scoreDiff))
        end
    end

    local bonus = ccui.Helper:seekWidgetByName(panelSimple, "value_score_exra")
end

function MyResultPanel:setDetailsBtn(panelSimple)
    local function onShowDetails()
        self:showDetails(true)
    end
    local buttonShowDetails = ccui.Helper:seekWidgetByName(panelSimple, "btn_checkdetail")
    if buttonShowDetails then
        buttonShowDetails:addClickEventListener(onShowDetails)
    end
end

function MyResultPanel:initDetails(panelResult)
    local panelDetails = panelResult:getChildByName("Panel_ResultMain")

    if panelDetails then
        local ContinuousFont = panelDetails:getChildByName("Font_Continuous")
        if self._gameWin.nBoutCount >= 2 then
            ContinuousFont:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CONTINUOUS_TIP")..tostring(self._gameWin.nBoutCount).."/"..tostring(self._gameWin.nBoutCount))
        else
            ContinuousFont:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CONTINUOUS_TIP")..tostring(self._gameWin.nBoutCount).."/"..tostring(2))
        end           

        local upRankEx = panelDetails:getChildByName("Panel_DoubleArrest"):getChildByName("Text_Score")
        upRankEx:setString("x"..tostring(self._gameWin.upRankEx))

        local upRankText = panelDetails:getChildByName("Panel_DoubleArrest"):getChildByName("Text_DoubleArrest")
        if self._gameWin.upRankEx == 4 then
            upRankText:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_DOUBLE_ARREST"))
        elseif self._gameWin.upRankEx == 2  then
            upRankText:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_SINGLY_ARREST"))
        else
            upRankText:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_FLAT_BUCKLE"))
        end        

        local BomeRate = panelDetails:getChildByName("Panel_Multiple"):getChildByName("Text_Score")
        BomeRate:setString("x"..tostring(self._gameWin.BomeRate))
    
        local Text_Tips = panelDetails:getChildByName("Text_Tips")
        if self._gameController:isNeedDeposit() then       
            Text_Tips:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CASHUI_TIP"), self._gameWin.nWinFees[self:getMyChairNO()+1]))
            for i = 1, 4 do
                local Panel_playerSelf = panelDetails:getChildByName("Panel_Player"..tostring(i))
                if i== 1 then
                    Panel_playerSelf:getChildByName("Text_SilverSelf"):setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_DEPOSIT"))
                else
                    Panel_playerSelf:getChildByName("Text_Silver"):setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_DEPOSIT"))
                end
            end
        else
            Text_Tips:setVisible(false)
            for i = 1, 4 do
                local Panel_playerSelf = panelDetails:getChildByName("Panel_Player"..tostring(i))
                if i== 1 then
                    Panel_playerSelf:getChildByName("Text_SilverSelf"):setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_SCORE"))
                else
                    Panel_playerSelf:getChildByName("Text_Silver"):setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_SCORE"))
                end
            end
        end
      
        local NextRank = self._gameWin.nNextRank[self._winChairNo]

        if NextRank == 13 then
            NextRank = 0
        end
        local Img_CardNum = panelDetails:getChildByName("Panel_NextPart"):getChildByName("Img_CardNum")
        Img_CardNum:loadTexture("res/Game/GamePic/Num/num_black_"..tostring(NextRank+1)..".png")

        if self._gameWin.nReserved1[4] == 1 then  --拓展字段第4个为一时 说明是随机级牌房间           
            Img_CardNum:loadTexture("res/Game/GamePic/Num/num_black_Question.png")
        end

        local Panel_Player1 = panelDetails:getChildByName("Panel_Player1")

        local Panel_playerSelf = panelDetails:getChildByName("Panel_Player"..tostring(self._gameWin.nPlace[self:getMyChairNO()+1]))
        if self._gameWin.nPlace[self:getMyChairNO()+1] ~= 1 then
            local pointTemp = cc.p(Panel_Player1:getPosition())
            local pointTemp1 = cc.p(Panel_playerSelf:getPosition())
            Panel_Player1:setPosition(pointTemp1)
            Panel_playerSelf:setPosition(pointTemp)

            local panelTemp = Panel_Player1
            Panel_Player1 = Panel_playerSelf
            Panel_playerSelf = panelTemp
        end
      
        local Text_ScoreSelf = Panel_playerSelf:getChildByName("Text_ScoreSelf")    
        self:setValueText(Text_ScoreSelf, self:getMyChairNO()+1)   
        
        local Text_MyselfName = Panel_playerSelf:getChildByName("Text_MyselfName")               
        --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(self._gameController:getMyChairNO()))
        local name = self._gameController._playerInfo[1].szUserName
        --昵称
        name = self:getPlayerName(name, self._gameController._playerInfo[1])

        local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
        Text_MyselfName:setString(utf8Name)

        local bThree = false
        for i = 1, 4 do
            if i ~= self:getMyChairNO()+1 then      
                      
                if self._gameWin.nPlace[i] == 4 and self._gameWin.upRankEx == 4 and not bThree then
                    bThree = true
                    local Panel_player = panelDetails:getChildByName("Panel_Player"..tostring(3))
                    local Text_Score = Panel_player:getChildByName("Text_Score")                       
                    self:setValueText(Text_Score, i)

                    local Text_Name = Panel_player:getChildByName("Text_PlayerName")   
                    --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(i-1))
                    local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                    name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                    if name then
                        local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                        Text_Name:setString(utf8Name)  
                    end 
                else
                    if self._gameWin.nPlace[i] == 1 then
                        local Text_Score = Panel_Player1:getChildByName("Text_Score")    
                        self:setValueText(Text_Score, i)

                        local Text_Name = Panel_Player1:getChildByName("Text_PlayerName")   
                        --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(i-1))
                        local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                        name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                        if name then
                            local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                            Text_Name:setString(utf8Name)  
                        end
                    end

                    if self._gameWin.nPlace[i] == 2 or self._gameWin.nPlace[i] == 3 or self._gameWin.nPlace[i] == 4 then
                        local Panel_player = panelDetails:getChildByName("Panel_Player"..tostring(self._gameWin.nPlace[i]))
                        local Text_Score = Panel_player:getChildByName("Text_Score")                            
                        self:setValueText(Text_Score, i)

                        local Text_Name = Panel_player:getChildByName("Text_PlayerName")   
                        --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(i-1))
                        local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                        name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                        if name then
                            local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                            Text_Name:setString(utf8Name)  
                        end
                    end
                end
            end
        end
        local exchangePanel = panelDetails:getChildByName("Panel_Exchange")
        if exchangePanel then
            if self._gameWin.nExchangeVouNum and self._gameWin.nExchangeVouNum[self:getMyChairNO()+1] > 0 then
                exchangePanel:setVisible(true)
                local exchangeText = exchangePanel:getChildByName("Text_ExchangeValue")
                if exchangeText then
                    exchangeText:setString("+"..self._gameWin.nExchangeVouNum[self:getMyChairNO()+1])
                end
            else
                exchangePanel:setVisible(false)
            end
        end
        --self:setBankerDetails(panelDetails)
        --self:setHelperDetails(panelDetails)
        --self:setFarmerDetails(panelDetails)
    end
end

function MyResultPanel:initLevel()
    local upgradeNode = self._resultPanel:getChildByName("Node_Upgrade")
    local panelLevel = self._resultPanel:getChildByName("Node_Level"):getChildByName("Panel_Level")
    upgradeNode:setVisible(false)
    if self._isNetLess or cc.exports._userLevelData.nLevelExp == nil then
        if panelLevel then
            panelLevel:setVisible(false)
        end
        return
    end
    if panelLevel then
        panelLevel:setVisible(true)
        local Experiencevalue = panelLevel:getChildByName("Text_Experiencevalue")
        local nextLevel = cc.exports._userLevelData.nLevel
        local isMax = true --是否满级
        if cc.exports._userLevelData.nLevelExp < cc.exports._userLevelData.nNextExp then
            nextLevel = nextLevel + 1
            isMax = false
        else
            isMax = true
            self._gameWin.nLevelExpUp[self:getMyChairNO()+1] = 0
        end
        cc.exports._userLevelData.nLevelExp = cc.exports._userLevelData.nLevelExp + self._gameWin.nLevelExpUp[self:getMyChairNO()+1]
        Experiencevalue:setString(cc.exports._userLevelData.nLevelExp.."(+"..self._gameWin.nLevelExpUp[self:getMyChairNO()+1]..")/"..cc.exports._userLevelData.nNextExp)

        local thisLevelImage = panelLevel:getChildByName("Img_This")
        local thisLevelColor = thisLevelImage:getChildByName("Img_LevelColor")
        local thisLevelText = thisLevelImage:getChildByName("Text_LevelNum")
        local nextLevelImage = panelLevel:getChildByName("Img_Next")
        local nextLevelColor = nextLevelImage:getChildByName("Img_LevelColor2")
        local nextLevelText = nextLevelImage:getChildByName("Text_LevelNum2")
        local BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(cc.exports._userLevelData.nLevel)
        thisLevelImage:loadTexture(BGResName)
        thisLevelColor:loadTexture(ColorResName)
        thisLevelText:setString(levelString)
        
        if not isMax and cc.exports._userLevelData.nLevelExp >= cc.exports._userLevelData.nNextExp then --升级
            --播动画 重新请求下自己的等级
            self:ShowLevelUpgrade(upgradeNode, nextLevel, cc.exports._userLevelData.nUpgradeExchange, cc.exports._userLevelData.nUpgradeDeposit)

            self._gameController:OnUserLevelDataForSelf()
            if cc.exports.oneRoundGameWinData.getVoucherNum == nil then -- 兑换券数
                cc.exports.oneRoundGameWinData.getVoucherNum = 0
            end
            cc.exports.oneRoundGameWinData.getVoucherNum = cc.exports.oneRoundGameWinData.getVoucherNum + cc.exports._userLevelData.nUpgradeExchange

            require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance():addTicketNum(cc.exports._userLevelData.nUpgradeExchange)

            if cc.exports._userLevelData.nUpgradeDeposit then
                local drawIndex = self._gameController:getMyDrawIndex()
                self._gameController:addPlayerDeposit(drawIndex, cc.exports._userLevelData.nUpgradeDeposit)
                local user=mymodel('UserModel'):getInstance()
                self._gameController._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
            end
        end

        BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(nextLevel)
        nextLevelImage:loadTexture(BGResName)
        nextLevelColor:loadTexture(ColorResName)
        nextLevelText:setString(levelString)
        local levelProgressBar = panelLevel:getChildByName("Progressbar_Level")
        local progressVlaue = cc.exports._userLevelData.nLevelExp / cc.exports._userLevelData.nNextExp
        if progressVlaue > 1 then
            progressVlaue = 1
        end
        levelProgressBar:setPercent(progressVlaue * 100)

        local vipIcon = levelProgressBar:getChildByName("Img_VipTip")
        vipIcon:setPositionX(levelProgressBar:getContentSize().width * progressVlaue)
        vipIcon:setVisible(false)
        local user=mymodel('UserModel'):getInstance()
        local ruleBtn = panelLevel:getChildByName("Img_Rule")
        ruleBtn:setTouchEnabled(true)
        ruleBtn:addClickEventListener(handler(self, self.showLevelRulePanel))
    end
end

function MyResultPanel:ShowLevelUpgrade(node, level, exchangeNum, depositNum)
    node:setVisible(true)

    local csbPath = "res/GameCocosStudio/csb/Node_Upgrade.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        node:runAction(action)
        action:play("animation0", false)

        local function onFrameEvent( frame)
            if frame then 
                local event = frame:getEvent()
                if "Play_Over" == event then
                    action:play("animation1", true)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
    end

    local BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(level)
    local UpgradePanel = node:getChildByName("Panel_Upgrade")
    local GameLevelImg = UpgradePanel:getChildByName("Img_GameLevel")
    local GameLevelColor = GameLevelImg:getChildByName("Img_LevelColor")
    local GameLevelNum = GameLevelImg:getChildByName("Text_LevelNum")
    GameLevelImg:loadTexture(BGResName)
    GameLevelColor:loadTexture(ColorResName)
    GameLevelNum:setString(levelString)

    local exchangePanle = UpgradePanel:getChildByName("Img_Exchange")
    local silverPanle = UpgradePanel:getChildByName("Img_Silver")
    exchangePanle:setVisible(false)
    silverPanle:setVisible(false)
    if exchangeNum > 0 then
        local exchangeTxt = exchangePanle:getChildByName("Text_ExchangeNum")
        exchangeTxt:setString("+"..exchangeNum)
        exchangePanle:setVisible(true)
    end
    if depositNum > 0 then
        local depositTxt = silverPanle:getChildByName("Text_SilverNum")
        depositTxt:setString("+"..depositNum)
        silverPanle:setVisible(true)
    end
    local sureBtn = UpgradePanel:getChildByName("Btn_Sure")
    sureBtn:addClickEventListener(function ()
        node:setVisible(false)
    end)
    if exchangeNum > 0 and depositNum > 0 then
    elseif exchangeNum > 0 then
        exchangePanle:setPositionX((exchangePanle:getPositionX() + silverPanle:getPositionX()) / 2 )
    elseif depositNum > 0 then
        silverPanle:setPositionX((exchangePanle:getPositionX() + silverPanle:getPositionX()) / 2 )
    else
        local imgCongratulations = UpgradePanel:getChildByName("Img_Congratulations")
        if imgCongratulations then
            imgCongratulations:setVisible(false)
        end
        sureBtn:setPositionY(sureBtn:getPositionY() + 100)
    end

    local levelText = UpgradePanel:getChildByName("Text_Level")
    levelText:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_LEVEL_STRING")..level)
end

function MyResultPanel:showLevelRulePanel()
    my.informPluginByName({pluginName='GameRulePlugin'})
end

--昵称
function MyResultPanel:getPlayerName(playName, playerInfo)  
    local name = playName
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        if(tcyFriendPlugin:isFriend(playerInfo.nUserID))then
            local remark = tcyFriendPlugin:getRemarkName(playerInfo.nUserID)
            if(remark~="")then
                local gbkName = MCCharset:getInstance():utf82GbString(remark, string.len(remark))         
                name = gbkName
            end
        end
    end
    return name
end

function MyResultPanel:setValueText(Text_Score, index)
    if self._gameController:isNeedDeposit() then        
        Text_Score:setString(tostring(self._gameWin.nDepositDiffs[index] + self._gameWin.nWinFees[index]))         
        if (self._gameWin.nDepositDiffs[index] + self._gameWin.nWinFees[index]) >= 0 then
            Text_Score:setString("+"..tostring(self._gameWin.nDepositDiffs[index] + self._gameWin.nWinFees[index]))    
        end
    else
        Text_Score:setString(tostring(self._gameWin.nScoreDiffs[index]))
        if self._gameWin.nScoreDiffs[index]>=0 then
            Text_Score:setString("+"..tostring(self._gameWin.nScoreDiffs[index]))    
        end
    end
end

function MyResultPanel:getPlayerInfo(chairno)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if playerInfoManager then
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(chairno)
        local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)
        if playerInfo then
            return playerInfo
        end
    end

    return nil
end

function MyResultPanel:setPlayerName(playerName, playerInfo)

    local userName = playerInfo.szUserName
    if 12 < string.len(userName) then
        userName = string.sub(userName, 1, 10).."..."
    end
    if userName then
        local utf8Name = MCCharset:getInstance():gb2Utf8String(userName, string.len(userName))
        playerName:setString(utf8Name)
    end
end

function MyResultPanel:setPlayerDetails(panelDetails, chairno, stringEnd)
    -- name
    local playerInfo = self:getPlayerInfo(chairno)
    if playerInfo then
        local name = ccui.Helper:seekWidgetByName(panelDetails, "text_name_"..stringEnd)
        if name then
            self:setPlayerName(name, playerInfo)
        end
    end

    -- bonus
    local bonus = ccui.Helper:seekWidgetByName(panelDetails, "text_score_extra_"..stringEnd)
    if bonus then
        local chairBonus = self._gameWin.nBonus[chairno + 1]
        if chairBonus >= 0 then
            bonus:setTextColor(cc.c3b(255, 0, 0))
        else
            bonus:setTextColor(cc.c3b(96, 96, 96))
        end
        bonus:setString(tostring(chairBonus))
    end

    -- score
    local score = ccui.Helper:seekWidgetByName(panelDetails, "text_score_detail_"..stringEnd)
    if score then
        local chairScore = self._gameWin.nScoreDiffs[chairno + 1] - self._gameWin.nBonus[chairno + 1]
        if chairScore >= 0 then
            score:setTextColor(cc.c3b(255, 0, 0))
        else
            score:setTextColor(cc.c3b(96, 96, 96))
        end
        score:setString(tostring(chairScore))
    end

    -- totalscore
    local totalScore = ccui.Helper:seekWidgetByName(panelDetails, "text_score_all_"..stringEnd)
    if totalScore then
        local chairTotalScore = self._gameWin.nScoreDiffs[chairno + 1]
        if chairTotalScore >= 0 then
            totalScore:setTextColor(cc.c3b(255, 0, 0))
        else
            totalScore:setTextColor(cc.c3b(96, 96, 96))
        end
        totalScore:setString(tostring(chairTotalScore))
    end
end

function MyResultPanel:setBankerDetails(panelDetails)
    --self:setPlayerDetails(panelDetails, self._gameWin.nBanker, "landlord")
end

function MyResultPanel:setHelperDetails(panelDetails)
    if -1 == self._gameWin.nFriendChair or self._gameWin.nBanker == self._gameWin.nFriendChair then
        local iconHelper = ccui.Helper:seekWidgetByName(panelDetails, "panel_icon_2")
        if iconHelper then
            iconHelper:setVisible(false)
        end
        return
    end

    --self:setPlayerDetails(panelDetails, self._gameWin.nFriendChair, "lagt")
end

function MyResultPanel:setFarmerDetails(panelDetails)
    local count = 0
    for i = 1, self._gameController:getTableChairCount() do
        local chairNO = i - 1
        if not self:isBanker(chairNO) and not self:isHelper(chairNO) then
            count = count + 1
            if 4 == count then      -- 1vs4
                self:setPlayerDetails(panelDetails, chairNO, "lagt")
            else
                self:setPlayerDetails(panelDetails, chairNO, "farmer_"..tostring(count))
            end
        end
    end
end

function MyResultPanel:showDetails(bShow)
    if not self._resultPanel then return end

    local panelResult = self._resultPanel:getChildByName("panel_result_victory")
    if self:isLose() then
        panelResult = self._resultPanel:getChildByName("panel_result_failed")
    end
    if not panelResult then return end

    local panelSimple = panelResult:getChildByName("panel_simple")
    if self:isLose() then
        panelSimple = panelResult:getChildByName("panel_failed_simple")
    end
    if panelSimple then
        panelSimple:setVisible(not bShow)
    end

    local panelDetails = panelResult:getChildByName("panel_victory_detail")
    if self:isLose() then
        panelDetails = panelResult:getChildByName("panel_failed_Detail")
    end
    if panelDetails then
        panelDetails:setVisible(bShow)
    end
end

function MyResultPanel:onClose()
    self._gameController:playBtnPressedEffect()

    if self._shareTime or self._closeTime then
        return
    end
    self._closeTime = true
    self:onExit()

    self.gotoRoom = nil
    self._gameController:onCloseResultLayerEx()
end

function MyResultPanel:onShare()
    self._gameController:playBtnPressedEffect()
    if self._shareTime or self._closeTime then
        return
    end

    self._shareTime = true

    local function shareTimeFunc(dt)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.shareTimeFuncID)
        self.shareTimeFuncID = nil
        self._shareTime = false
    end

    self.shareTimeFuncID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(shareTimeFunc, 3, false) 

    
    self:onExit()
    self._gameController:onShareResult()
end

function MyResultPanel:onRestart()
    self._gameController:playBtnPressedEffect()
    if self._shareTime or self._closeTime then
        return
    end
    self._closeTime = true
    self:onExit()
    self._gameController:onRestart()
end


function MyResultPanel:rul_GetDrawIndexByChairNO(chairNO)
    if not self._gameController:isValidateChairNO(chairNO) then return 0 end

    local index = 0

    local selfChairNO = self._gameController._selfChairNO
    local tableChairCount = self._gameController:getTableChairCount()
    index = self._gameController:getMyDrawIndex()

    for i = 1, tableChairCount do
        if selfChairNO == chairNO then
            return index
        else
            index = index + 1
            selfChairNO = (selfChairNO - 1) % tableChairCount
        end
    end

    return index
end

function MyResultPanel:getMyChairNO()
    return self._gameController._selfChairNO
end

function MyResultPanel:onGoToRoom()
    if not self._gotoRoom then
        return false
    end

    self._gameController:playBtnPressedEffect()
    --self._gameController._promptRoom = self._gotoRoom
    self._gameController._promptRoom = {
        ["jumpNewRoom"] = false,
        ["targetRoomInfo"] = self._gotoRoom
    }
    self._gameController._baseGameConnect:gc_LeaveGame()

    self._gameController._promptRoom.jumpNewRoom = true -- 用于区分是进阶跳转还是 直接退出
    self.gotoRoom = nil

    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.RESULT_VIEW_GOTO_LOW_GRADE_ROOM)
    
    self:removeFromParentAndCleanup()  --?
end

return MyResultPanel