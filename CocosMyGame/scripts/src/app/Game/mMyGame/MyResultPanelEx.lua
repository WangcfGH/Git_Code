
local MyResultPanel = import("src.app.Game.mMyGame.MyResultPanel")
local MyResultPanelEx = class("MyResultPanelEx", MyResultPanel)
--local RoomsView =  require("src.app.plugins.myroomspanel.MyRoomsView")
local localGamePublicInterface = require("src.app.Game.mMyGame.GamePublicInterface")
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
--添加举报功能
local ReportModel = require('src.app.plugins.Report.ReportModel'):getInstance()

function MyResultPanelEx:initResultPanel()
    self._leftTime = 0
    self._oriOrder = 110 --没有点击时的zorder
    self._clickOrder = 115 --点击之后的zorder

    local csbPath = "res/GameCocosStudio/csb/Node_Result_Win_Ex.csb"
    if self:isLose() then
        csbPath = "res/GameCocosStudio/csb/Node_Result_Lose_Ex.csb"
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

    if self._gamedata.nTodayBouts == nil then
        self._gamedata.nTodayBouts = 0
    end

    if self._gamedata.logindate == nil then -- 新注册玩家在登陆的时候，（因为新手礼包的问题）时间存缓存被注释了。
        local date = self:getTodayDate()
        self._gamedata.logindate = date
    end
    self._gamedata.nTodayBouts = self._gamedata.nTodayBouts + 1 -- 每结算一次，今日局数加1， 2019年6月4日新增
    
    if DEBUG and DEBUG > 0 then
        print("===============MyResultPanelEx:initResultPanel  todayBouts: "..self._gamedata.nTodayBouts)
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
            self:initTimingGameTicket(panelResult)
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

    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.RESULT_VIEW)

    -- 广告模块 start
    local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
    print("AdvertModel:MyResultPanelEx:initResultPanel")
    print("self._hasShowBanner: ", self._hasShowBanner)
    if self._gameController:isShowBanner() and not self._gameController._hasShowBanner then
        AdvertModel:showBannerAdvert()
        self._gameController._hasShowBanner = true
    end
    -- 广告模块 end

    --邀请有礼
    if OldUserInviteGiftModel:isRedPacketEnable()  then
        OldUserInviteGiftModel:sendInviteGiftData()
    end
    
    my.scheduleOnce(function()
        -- 邀请有礼老玩家红包对局相关
        if OldUserInviteGiftModel:isRedPacketEnable() and OldUserInviteGiftModel:getInviteRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
            my.informPluginByName({ pluginName = 'OldUserInitGiftCtrl'})
        end
        -- 邀请有礼 新用户可兑换话费时弹框
        if NewUserInviteGiftModel:isShowInGameScene() and NewUserInviteGiftModel:isCanGetAward() and (not NewUserInviteGiftModel:isShowOnResultView()) then
            NewUserInviteGiftModel:setShowOnResult(1)
            my.informPluginByName({ pluginName = 'NewUserInviteGiftCtrl', params = { isOpenInGame = true } })
        end
    end, 2)
end

function MyResultPanelEx:startRefreshTimer()
    self._leftTime = 10        
    self.startRefreshTimeID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.refreshLeftTime), 1, false) 
end

function MyResultPanelEx:stopRefreshTimer()
    if self.startRefreshTimeID then     
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.startRefreshTimeID)
        self.startRefreshTimeID = nil
    end
end

function MyResultPanelEx:onClose()
    self:stopRefreshTimer()
    MyResultPanelEx.super.onClose(self)
end

function MyResultPanelEx:refreshLeftTime()
    if self._leftTime then
        self._leftTime = self._leftTime - 1
        if self._leftTime < 0 then self._leftTime = 0 end

        if self._resultPanel then
            local panelResult = self._resultPanel:getChildByName("Panel_Result")
            if panelResult then
                local textLeave = ccui.Helper:seekWidgetByName(panelResult, "Text_Leave")
                if textLeave then
                    textLeave:setString(self._leftTime.."s")
                end        
            end    
        end
    end    
end

function MyResultPanelEx:initButtons(panelResult)
    local function onClose()
        self:onClose()

        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.RESULT_VIEW_CLOSE_BTN)
    end
    local buttonClose = ccui.Helper:seekWidgetByName(panelResult, "Btn_Close")
    if buttonClose then
        buttonClose:addClickEventListener(onClose)
    end

    --组队2V2模式结算关闭按钮隐藏
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        buttonClose:setVisible(false)
    end

    local function onShare()
        self:onShare()
    end
    local buttonShare = ccui.Helper:seekWidgetByName(panelResult, "Btn_Show")
    if buttonShare then
        buttonShare:addClickEventListener(onShare)
        buttonShare:setVisible(false)
    end

    --组队2V2模式结算分享按钮隐藏
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        buttonShare:setVisible(false)
    end

    local function onLeave()
        self:stopRefreshTimer()
        self._gameController:onTeam2V2Leave()
    end
    local buttonLeave = ccui.Helper:seekWidgetByName(panelResult, "Btn_Leave")
    if buttonLeave then
        buttonLeave:addClickEventListener(onLeave)
    end

    --组队2V2模式结算离开按钮
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        if self._gameWin.bnResetGame == 1 then
            buttonLeave:setVisible(true)
        else
            buttonLeave:setVisible(false)
        end
    else
        if buttonLeave then
            buttonLeave:setVisible(false)
        end
    end

    -- 继续和离开按钮倒计时
    local textLeave = ccui.Helper:seekWidgetByName(panelResult, "Text_Leave")
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        textLeave:setVisible(true)
        self:stopRefreshTimer()    
        self:startRefreshTimer()
    else
        if textLeave then
            textLeave:setVisible(false)
        end
    end

    local function onRestart()
        self:stopRefreshTimer()
        self:onRestart()

        --17期客户端埋点
        local params = {}
        local curRoom = PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if curRoom and curRoom.nRoomID then
            params["roomID"] = curRoom.nRoomID
        end
        my.dataLink(cc.exports.DataLinkCodeDef.RESULT_VIEW_CONTIUE_BTN, params)
    end

    --旧的控件在房间晋级时使用，一般情况隐藏，新的控件在中央，一般都显示
    local buttonRestart_old = ccui.Helper:seekWidgetByName(panelResult, "Btn_Continue")
    local buttonRestart = ccui.Helper:seekWidgetByName(panelResult, "Btn_Continue_New")
    if buttonRestart then
        buttonRestart:addClickEventListener(onRestart)
        buttonRestart_old:addClickEventListener(onRestart)
    end
    buttonRestart_old:setVisible(false)

    ------添加举报功能--------------------------------
    --获取举报按钮控件
    local ReportBtn = ccui.Helper:seekWidgetByName(panelResult, "Btn_Report")
    if (ReportBtn) then
        ReportBtn:setVisible(false)
        --显示按钮
        if ReportBtn and ReportModel.open == true then
            ReportBtn:setVisible(true)
            --绑定事件 点击按钮，实例化举报界面
            ReportBtn:addClickEventListener(handler(self, self.Report))
        end
    end
    ---------------------------------------------------

    local buttonRestartTeam2V2 = ccui.Helper:seekWidgetByName(panelResult, "Btn_Continue_Team2V2")
    if buttonRestartTeam2V2 then
        buttonRestartTeam2V2:addClickEventListener(onRestart)
    end

    --组队2V2模式结算继续按钮隐藏
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        buttonRestart:setVisible(false)
        if self._gameWin.bnResetGame == 1 then
            buttonRestartTeam2V2:setVisible(false)
        else
            buttonRestartTeam2V2:setVisible(true)
        end
    else
        if buttonRestartTeam2V2 then
            buttonRestartTeam2V2:setVisible(false)
        end
    end

    local buttonJump = ccui.Helper:seekWidgetByName(panelResult, "Btn_Jump")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/JumpRoomBtns.plist")
    local imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomLow.png"
    buttonJump:loadTextureNormal(imgPath, 1)
    buttonJump:setEnabled(false)
    buttonJump:setVisible(false)
    buttonJump:setScale9Enabled(false)

    --组队2V2模式结算关闭按钮隐藏
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        buttonJump:setVisible(false)
    end

    --初始化Btn_Prompt
    local function onGoToRoom()
        self:onGoToRoom()
    end

    --判定Btn_Prompt是否需要显示，若显示则显示相关按钮，并记录跳转房间
    --依赖数据：PromptLine、所在房间上限、结算后携带银子、所在房间号、进阶提示房间名
    local gameJsonConfig = cc.exports._gameJsonConfig
    --local roomInfo = PublicInterface.GetCurrentRoomInfo()
    local nRoomID    = self._gameController._baseGameUtilsInfoManager:getRoomID()
    local nMaxDeposit = self._gameController._baseGameUtilsInfoManager:getRoomMaxDeposit()
    local nMinDeposit = self._gameController._baseGameUtilsInfoManager:getRoomMinDeposit()

    if gameJsonConfig.PromptLine ~= nil then
        local nPromptLine = gameJsonConfig.PromptLine[tostring(nRoomID)] --提示线
        local gameplayer    = self._gameController:getPlayerInfoManager()
        local nSelfDeposit = gameplayer:getSelfDeposit() --携银

        --if nPromptLine and nSelfDeposit >= nPromptLine and nSelfDeposit <= nMaxDeposit then
        if nPromptLine and nSelfDeposit >= nPromptLine and not mymodel('NewUserGuideModel'):getInstance():isNeedGuide() then
            --获取进阶提示房
            --[[local roomlist = RoomsView:GetCurrentSecondGradeRoomsList()
            local jumpRoomID, jumpRoomMin = localGamePublicInterface:getPromptTipRoomID(roomlist, nPromptLine, nRoomID)]]
            --
            local RoomListModel = require("src.app.GameHall.room.model.RoomListModel"):getInstance()
            local seniorRoomInfo = RoomListModel:findSeniorRoomInGame(cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo())
            --if jumpRoomMin < nMinDeposit then
            if not seniorRoomInfo then
                self._gotoRoom = nil
                -- 如果计算得到的房间比当前房间下限小，则不要显示进阶跳转按钮
                print("MyResultPanelEx: jumpRoomMin < nMinDeposit", jumpRoomMin, nMinDeposit)
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
            end]]
            --
            local posX = buttonShare:getPositionX()
            local isShowJumpButton = false
            local imgPath = ""
            --jumpRoomName = MCCharset:getInstance():gb2Utf8String( jumpRoomName, string.len(jumpRoomName) ) 
            if DEBUG and DEBUG == 1 then
                print("MyResultPanelEx: jumpRoomName", jumpRoomName)
            end
            local roomNameSecond = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SECOND")        -- 初级房
            local roomNameThird = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_THIRD")          -- 中级房
            local roomNameFourth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FOURTH")        -- 高级房
            local roomNameFiveth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FIVETH")        -- 大师房
            local roomNameSixth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SIXTH")          -- 至尊房
            local roomNameSeventh = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SEVENTH")      -- 至尊房

            if jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSecond, string.len(roomNameSecond)) then
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
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomMaster.png"   -- 大师房
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSixth, string.len(roomNameSixth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomSupreme.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSeventh, string.len(roomNameSeventh)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomZongShi.png"
            end

            local promotRoomID = seniorRoomInfo.nRoomID
            if RoomListModel:isLimitTimeOpenRoom(promotRoomID) then
                local curTimeStamp = MyTimeStamp:getLatestTimeStamp()
                local startHour, startMinute, endHour, endMinute = RoomListModel:getOpenTime(promotRoomID)
                local curYear = os.date("%Y", curTimeStamp)
                local curMonth = os.date("%m", curTimeStamp)
                local curDay = os.date("%d", curTimeStamp)
                local startTimeStamp = os.time({ year = curYear, month = curMonth, day = curDay, hour = startHour, min = startMinute, sec = 0 })
                local endTimeStamp = os.time({ year = curYear, month = curMonth, day = curDay, hour = endHour, min = endMinute, sec = 0 })
                if curTimeStamp < startHour or endTimeStamp < curTimeStamp then
                    isShowJumpButton = false
                end
            end

            if true == isShowJumpButton then
                buttonJump:loadTextureNormal(imgPath, 1)
                buttonJump:setVisible(true)
                buttonJump:setEnabled(true)
                buttonJump:addClickEventListener(handler(self, self.onGoToRoom))

                if buttonRestart and buttonRestart_old then
                    --房间升级时，显示右侧老控件，不然显示中央的新控件
                    buttonRestart:setVisible(false)
                    buttonRestart_old:setVisible(true)
                end    
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


--举报事件:实例化大厅那边的插件-举报功能
function MyResultPanelEx:Report()
    --把是结算界面的举报的开关打开
    ReportModel:SetReportResultSwoitch(true)
    --把四个人的输赢结果传递到举报功能的model中 nCardID
    for i=1,#ReportModel.ReportNameList do
        ReportModel.ReportNameList[self:rul_GetDrawIndexByChairNO(i-1)].deposit = self._gameWin.nDepositDiffs[i] + self._gameWin.nWinFees[i]
    end
    --结算按钮，没有举报对象
    ReportModel.newObject = 0
    my.informPluginByName({pluginName='ReportCtrl'}) 
end

function MyResultPanelEx:initDetails(panelResult)
    local panelDetails = panelResult:getChildByName("Panel_ResultMain")
    local isMaxMultiple = false

    if panelDetails then
    
        self:InitBtnTopBottom(panelDetails)

        --[[    -- 去掉连局显示
        local ContinuousFont = panelDetails:getChildByName("Font_Continuous")
        if ContinuousFont and self._gameWin.nBoutCount >= 2 then
            ContinuousFont:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CONTINUOUS_TIP")..tostring(self._gameWin.nBoutCount).."/"..tostring(self._gameWin.nBoutCount))
        else
            ContinuousFont:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CONTINUOUS_TIP")..tostring(self._gameWin.nBoutCount).."/"..tostring(2))
        end  
        ]]--        

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
    
        -- 默认隐藏输银超上限提示
        panelDetails:getChildByName("Panel_MaxMultipleTip"):setVisible(false)
        isMaxMultiple = false
        if not self._isNetLess and self._gameWin.nReserved1[2] > 0 then
            -- 输了超上限
            if self:isLose() and self._gameWin.upRankEx * self._gameWin.BomeRate > self._gameWin.nReserved1[2] then
                --BomeRate:setString("x"..tostring(self._gameWin.nReserved1[2] / self._gameWin.upRankEx))
                panelDetails:getChildByName("Panel_MaxMultipleTip"):setVisible(true)
                panelDetails:getChildByName("Panel_MaxMultipleTip"):getChildByName("Text_Tip"):setString("本房间最多输"..self._gameWin.nReserved1[2].."倍")
                isMaxMultiple = true
            end
            -- 赢了，但是有人输了超上限
            if not self:isLose() and self._gameWin.nWinPoints and self._gameWin.upRankEx * self._gameWin.BomeRate > self._gameWin.nReserved1[2] then
                --BomeRate:setString("x"..tostring(self._gameWin.nWinPoints[self:getMyChairNO()+1]))
                panelDetails:getChildByName("Panel_MaxMultipleTip"):setVisible(true)
                panelDetails:getChildByName("Panel_MaxMultipleTip"):getChildByName("Text_Tip"):setString("本房间最多输"..self._gameWin.nReserved1[2].."倍")
                isMaxMultiple = true
            end
        end

        -- 去掉本局消耗xxxx茶水费
        local Text_Tips = panelDetails:getChildByName("Text_Tips")
        if Text_Tips and self._gameController:isNeedDeposit() then       
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
        panelDetails:getChildByName("Panel_NextPart"):setVisible(false) -- 2019年5月7日 去掉下局显示

        if self._gameWin.nReserved1[4] == 1 then  --拓展字段第4个为一时 说明是随机级牌房间           
            Img_CardNum:loadTexture("res/Game/GamePic/Num/num_black_Question.png")
        end

        -- 组队2V2房显示打几
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            local function numToUnmStr(num)
                if num == 1 then
                    return "A"
                elseif num == 11 then
                    return "J"
                elseif num == 12 then
                    return "Q"
                elseif num == 13 then
                    return "K"
                end
                return tostring(num)
            end
            if self:isLose() then
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Img_OwnNextCard"):setVisible(false)
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Img_OwnEnemyCard"):setVisible(true)
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Txt_CardNum"):setString(numToUnmStr(NextRank+1))
            else
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Img_OwnNextCard"):setVisible(true)
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Img_OwnEnemyCard"):setVisible(false)
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):getChildByName("Txt_CardNum"):setString(numToUnmStr(NextRank+1))
            end

            if self._gameWin.bnResetGame == 1 then
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):setVisible(false)
            else
                panelDetails:getChildByName("Panel_NextPart_Team2V2"):setVisible(true)
            end
        else
            --应该是血战模式取不到对应的ui
            local panelNextPartTeam2V2 = panelDetails:getChildByName("Panel_NextPart_Team2V2")
            if panelNextPartTeam2V2 and not tolua.isnull(panelNextPartTeam2V2) then
                panelNextPartTeam2V2:setVisible(false)
            end
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
        self:setValueTextWithTopBottom(Panel_playerSelf,  Text_ScoreSelf, self:getMyChairNO()+1)   

        -- 组队2V2房显示升N
        local imgUpgradeSelf = Panel_playerSelf:getChildByName("Img_Upgrade")
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            if self:isLose() then
                imgUpgradeSelf:setVisible(false)
            else
                imgUpgradeSelf:setVisible(true)
                imgUpgradeSelf:getChildByName("Fnt_UpgradeNum"):setString(self._gameWin.nUpRank[self:getMyChairNO()+1])
            end
        else
            imgUpgradeSelf:setVisible(false)
        end

        local Text_MyselfName = Panel_playerSelf:getChildByName("Text_MyselfName")               
        --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(self._gameController:getMyChairNO()))
        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
         --昵称
        local utf8nickname = userPlugin:getNickName()
        local limitLen = Text_MyselfName:getContentSize().width
        Text_MyselfName:setString(utf8nickname)
        my.fitStringInWidget(utf8nickname, Text_MyselfName, limitLen)

        local bThree = false
        for i = 1, 4 do
            if i ~= self:getMyChairNO()+1 then      
                      
                if self._gameWin.nPlace[i] == 4 and self._gameWin.upRankEx == 4 and not bThree then
                    bThree = true
                    local Panel_player = panelDetails:getChildByName("Panel_Player"..tostring(3))
                    local Text_Score = Panel_player:getChildByName("Text_Score")                       
                    self:setValueTextWithTopBottom(Panel_player, Text_Score, i, 3)

                    local Text_Name = Panel_player:getChildByName("Text_PlayerName")   
                    if self._gameController._playerInfo and self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)] then
                        local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                        name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                        if name then
                            local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                            local limitLen = Text_Name:getContentSize().width
                            Text_Name:setString(utf8Name)  
                            my.fitStringInWidget(utf8Name, Text_Name, limitLen)
                        end 
                    end

                    -- 组队2V2房显示升N
                    local imgUpgrade = Panel_player:getChildByName("Img_Upgrade")
                    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                        if self:chairIsLose(i) then
                            imgUpgrade:setVisible(false)
                        else
                            imgUpgrade:setVisible(true)
                            imgUpgrade:getChildByName("Fnt_UpgradeNum"):setString(self._gameWin.nUpRank[i])
                        end
                    else
                        imgUpgrade:setVisible(false)
                    end                    
                else
                    if self._gameWin.nPlace[i] == 1 then
                        local Text_Score = Panel_Player1:getChildByName("Text_Score")    
                        self:setValueTextWithTopBottom(Panel_Player1, Text_Score, i)

                        local Text_Name = Panel_Player1:getChildByName("Text_PlayerName")   
                        if self._gameController._playerInfo and self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)] then
                            local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                            name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                            if name then
                                local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                                local limitLen = Text_Name:getContentSize().width
                                Text_Name:setString(utf8Name)  
                                my.fitStringInWidget(utf8Name, Text_Name, limitLen)
                            end
                        end

                        -- 组队2V2房显示升N
                        local imgUpgrade = Panel_Player1:getChildByName("Img_Upgrade")
                        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                            if self:chairIsLose(i) then
                                imgUpgrade:setVisible(false)
                            else
                                imgUpgrade:setVisible(true)
                                imgUpgrade:getChildByName("Fnt_UpgradeNum"):setString(self._gameWin.nUpRank[i])
                            end
                        else
                            imgUpgrade:setVisible(false)
                        end  
                    end

                    if self._gameWin.nPlace[i] == 2 or self._gameWin.nPlace[i] == 3 or self._gameWin.nPlace[i] == 4 then
                        local Panel_player = panelDetails:getChildByName("Panel_Player"..tostring(self._gameWin.nPlace[i]))
                        local Text_Score = Panel_player:getChildByName("Text_Score")                            
                        self:setValueTextWithTopBottom(Panel_player, Text_Score, i)

                        local Text_Name = Panel_player:getChildByName("Text_PlayerName")   
                        if self._gameController._playerInfo and self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)] then
                            local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                            name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                            if name then
                                local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                                local limitLen = Text_Name:getContentSize().width
                                Text_Name:setString(utf8Name)  
                                my.fitStringInWidget(utf8Name, Text_Name, limitLen)
                            end
                        end

                        -- 组队2V2房显示升N
                        local imgUpgrade = Panel_player:getChildByName("Img_Upgrade")
                        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                            if self:chairIsLose(i) then
                                imgUpgrade:setVisible(false)
                            else
                                imgUpgrade:setVisible(true)
                                imgUpgrade:getChildByName("Fnt_UpgradeNum"):setString(self._gameWin.nUpRank[i])
                            end
                        else
                            imgUpgrade:setVisible(false)
                        end 
                    end
                end
            end
        end
        
        local exchangePanel = panelDetails:getChildByName("Panel_Exchange")
        if exchangePanel then
            local isNeedShowExchangeTip = true
            if cc.exports._gameJsonConfig.NationalDaysActivity and next(cc.exports._gameJsonConfig.NationalDaysActivity) ~= nil then
            -- 满足该条件说明有巅峰榜活动，返回了积分
                local resultScore = self._gameController:getGameResultActivityScore()
                if resultScore then
                    local nBoutScore = resultScore.nBaseScore * resultScore.nFactor
                    if nBoutScore > 0 then
                        isNeedShowExchangeTip = false
                        my.scheduleOnce(function ()
                            if resultScore and resultScore.nTodayScore > 0 then
                                if self._gameController ~= nil then
                                    local content = string.format(self._gameController:getGameStringByKey("G_GAME_NATIONAL_DAYS_RESULT_SCORE_TIP"),nBoutScore ,  resultScore.nTodayScore)
                                    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                                    my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = utf8Content, removeTime = 2}})
                                end
                            end
                            if self._gameController then
                                self._gameController:clearGameResultActivityScore()
                            end
                        end, 1)
                    end
                end
            end

            local BoutInfo  = self._gameController:getCurrentExchangeBoutInfo() -- 结算时候，若没有BoutInfo，说明游戏服务没有发通知上来，包厢房、竞技场等，故也做隐藏处理
            
            if self:isNotShowExchangePanel(BoutInfo) then
                -- 向右移动的元素列表
                local posX = 240
                local moveYTable_R = {Panel_Player1="Panel_Player1",Panel_Player2="Panel_Player2", Panel_Player3="Panel_Player3", Panel_Player4="Panel_Player4"
                                , Img_Ranking="Img_Ranking", Image_BlueLeftBar="Image_BlueLeftBar"
                                , Panel_DoubleArrest="Panel_DoubleArrest", Panel_Multiple="Panel_Multiple" }
                if isMaxMultiple then
                    moveYTable_R = {Panel_Player1="Panel_Player1",Panel_Player2="Panel_Player2", Panel_Player3="Panel_Player3", Panel_Player4="Panel_Player4"
                                , Img_Ranking="Img_Ranking" }
                end
	            local needMoveRview = my.NodeIndexer(panelDetails, moveYTable_R)
                for key, value in pairs(needMoveRview._exchange) do 
                        needMoveRview[key]:setPositionX(needMoveRview[key]:getPositionX() + posX)
                end

                local posX2 = 80
                local panelTimingTicket = panelDetails:getChildByName("Panel_TimingTicket")
                if panelTimingTicket then
                    panelTimingTicket:setPositionX(panelTimingTicket:getPositionX() + posX2)
                end
                
                -- 需要隐藏的元素列表
                panelDetails:getChildByName("Image_YellowRightBar"):setVisible(false)
                panelDetails:getChildByName("Panel_RewardTip"):setVisible(false)
                panelDetails:getChildByName("Panel_Exchange"):setVisible(false)

                --向左移动的元素列表 2019年5月21日 第四个玩家和文字重叠
                -- Text_Tips:setPositionX(Text_Tips:getPositionX() - 100)
                -- Text_Tips:setPositionY(Text_Tips:getPositionY() - 60)
                
            else

                local  CurrentBoutText = exchangePanel:getChildByName("Text_BoutPlayed")
                local  TargetBoutText = exchangePanel:getChildByName("Text_BoutInfo")
            
                local playBoutNum = 0
                if BoutInfo.nTargetBout > 0 and  BoutInfo.nCurrentBount > 0 then
                    -- 若nTargetBout=0 的情况，说明房间没有配置 对局赠送兑换券
                    playBoutNum = math.mod(BoutInfo.nCurrentBount,BoutInfo.nTargetBout) 
                end
                if 0 == playBoutNum then playBoutNum = BoutInfo.nTargetBout end 

                CurrentBoutText:setString(playBoutNum)  -- self._gameWin.nBoutCount是连局数，一旦重新开桌就呗清零
                TargetBoutText:setString("/"..BoutInfo.nTargetBout.."局")

                local  ImgDisable_ExchangeBG = exchangePanel:getChildByName("Disable_ExchangeBG")
                local  ImgDisable_ExchangeIcon = exchangePanel:getChildByName("Disable_ExchangeIcon")

                local RewardVochersNum = 0

                if BoutInfo and BoutInfo.nRewardNums then
                    RewardVochersNum = BoutInfo.nRewardNums 
                end

                --if self._gameController.ExchangeData and self._gameController.ExchangeData.nPrizeNum and self._gameController.ExchangeData.nPrizeNum > 0 then
                if 1 == BoutInfo.nNeedReward then
                    local prizeVochersNum = BoutInfo.nRewardNums
                    ImgDisable_ExchangeBG:setVisible(false)
                    ImgDisable_ExchangeIcon:setVisible(false)


                    exchangePanel:setVisible(true)
                    local exchangeText = exchangePanel:getChildByName("Text_ExchangeValue")
                    if exchangeText then
                        exchangeText:setString(" ".. RewardVochersNum)
                    end

                    self._EggerActionNode = self._resultPanel:getChildByName("Node_EggAction")
                    self:showBreakEggsAnimation(8, prizeVochersNum)

                    if true == isNeedShowExchangeTip then
                        my.scheduleOnce(function ()
                            print("show exchange tips")
                            if not self._gameController then return end
                            local content = string.format(self._gameController:getGameStringByKey("G_GAME_TODAY_EXCHANGE_VOCHERS"), prizeVochersNum, BoutInfo.nTodayVochers)
                            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                            my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = utf8Content, removeTime = 2}})
                        end, 1)
                    end
                    

                    --self._gameController.ExchangeData = nil -- 结算完成就清掉，避免影响下次结算
                else
                    local exchangeText = exchangePanel:getChildByName("Text_ExchangeValue")
                    if exchangeText then
                        exchangeText:setString(" ".. RewardVochersNum)
                    end
                    ImgDisable_ExchangeBG:setVisible(true)
                    ImgDisable_ExchangeIcon:setVisible(true)
                end

                local panelDesc = exchangePanel:getChildByName("Panel_Desc")
                if panelDesc then
                    panelDesc:setVisible(false)
                    local txtDesc = panelDesc:getChildByName("Text_Desc")
                    local str = "1、任意房间对局可获得礼券\n2、房间等级越高，获得的礼券越多"
                    if txtDesc then
                        txtDesc:setString(str)
                    end

                    local txtTip = exchangePanel:getChildByName("Text_Tip")
                    local imgDisIcon = exchangePanel:getChildByName("Disable_ExchangeIcon")
                    local imgIcon = exchangePanel:getChildByName("Img_ExchangeIcon")
                    local showDesc = function (sender, event)
                        if event == ccui.TouchEventType.ended then
                            local bShow = panelDesc:isVisible()
                            local zOrder = self._oriOrder
                            if not bShow then
                                self._clickOrder = self._clickOrder + 1
                                zOrder = self._clickOrder
                            end
                            exchangePanel:setLocalZOrder(zOrder)
                            panelDesc:setVisible(not bShow)
                        end
                    end
                    if imgIcon then
                        imgIcon:setTouchEnabled(true)
                        imgIcon:addTouchEventListener(showDesc)
                    end
                    if txtTip then
                        txtTip:setTouchEnabled(true)
                        txtTip:addTouchEventListener(showDesc)
                    end
                    if imgDisIcon then
                        imgDisIcon:setTouchEnabled(true)
                        imgDisIcon:addTouchEventListener(showDesc)
                    end
                end
            end
        end -- End if exchangePanel ...

        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            if exchangePanel then
                exchangePanel:setVisible(false)
            end            
        end
    end 
end

function MyResultPanelEx:isNotShowExchangePanel(BoutInfo)
    local RoomExchangeConfig = cc.exports._gameJsonConfig.ExchangeRoomConfig
    local nRoomID       =  self._gameController._baseGameUtilsInfoManager:getRoomID()
    local oneConfig = nil 
    if RoomExchangeConfig then  -- assist服务挂了会引起RoomExchangeConfig是nil
        oneConfig = RoomExchangeConfig[tostring(nRoomID)]
    end

    return (nil == BoutInfo 
    or 0 == BoutInfo.nRewardNums 
    or 0 == BoutInfo.nTargetBout 
    or nil == oneConfig 
    or 0 == oneConfig.RewardNum 
    or 0 == oneConfig.BoutCount)
end

function MyResultPanelEx:initTimingGameTicket(panelResult)
    local panelDetails = panelResult:getChildByName("Panel_ResultMain")
    local panelTimingTicket = panelDetails:getChildByName("Panel_TimingTicket")
    if panelTimingTicket then
        panelTimingTicket:setVisible(false)
        panelTimingTicket:setLocalZOrder(self._oriOrder) --设置成比个人信息高一点
        if not TimingGameModel:isEnable() 
        or not TimingGameModel:isMatchDay()
        or PUBLIC_INTERFACE.IsStartAsArenaPlayer()
        or PUBLIC_INTERFACE.IsStartAsTimingGame()
        or not TimingGameModel:isTicketTaskEnable()
        or not self._gameController:isNeedDeposit()
        or self._isNetLess then
            return
        end
        panelTimingTicket:setVisible(true)
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            panelTimingTicket:setVisible(false)
        end

        local curRoom = PUBLIC_INTERFACE.GetCurrentRoomInfo()
        local panelDesc = panelTimingTicket:getChildByName("Panel_Desc")
        if panelDesc then
            panelDesc:setVisible(false)
            local txtDesc = panelDesc:getChildByName("Text_Desc")
            local lowRoom = TimingGameModel:getTimingGameLowestBoutTicketRoom()
            local str = "1、%s及以上房间对局可获得门票\n2、门票可用于话费赛报名"
            if txtDesc then
                if lowRoom then
                    txtDesc:setString(string.format(str, lowRoom.gradeNameZh))
                end
            end

            local imgIcon = panelTimingTicket:getChildByName("Img_Icon")
            local txtTip = panelTimingTicket:getChildByName("Text_Tip")
            local showDesc = function (sender, event)
                if event == ccui.TouchEventType.ended then
                    local bShow = panelDesc:isVisible()
                    local zOrder = self._oriOrder
                    if not bShow then
                        self._clickOrder = self._clickOrder + 1
                        zOrder = self._clickOrder
                    end
                    panelTimingTicket:setLocalZOrder(zOrder)
                    panelDesc:setVisible(not bShow)
                end
            end
            if imgIcon then
                imgIcon:setTouchEnabled(true)
                imgIcon:addTouchEventListener(showDesc)
            end
            if txtTip then
                txtTip:setTouchEnabled(true)
                txtTip:addTouchEventListener(showDesc)
            end

            if curRoom and curRoom.gradeIndex <= 2 then --初级房自动打开门票tips
                panelDesc:setVisible(true)
            end
        end

        local config = TimingGameModel:getConfig()
        local info = TimingGameModel:getInfoData()
        local totalNeedBoutNum = 0
        local totalTicketNum = 0
        local totalRoomBout = 0
        local curRoomNeedBoutNum = 0
        local curRoomTicketNum = 0
        local curRoomBout = 0
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            if TimingGameModel:isRoomIDCanAddBoutByGrade(curRoom.nRoomID, i) then
                curRoomNeedBoutNum = curRoomNeedBoutNum + config.GradeBoutObtainTickets[i].MinBoutNum
                curRoomTicketNum = curRoomTicketNum + config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum
                curRoomBout = curRoomBout + info.gradeBoutNums[i]
            end
            totalNeedBoutNum = totalNeedBoutNum + config.GradeBoutObtainTickets[i].MinBoutNum
            totalTicketNum = totalTicketNum + config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum
            totalRoomBout = totalRoomBout + info.gradeBoutNums[i]
        end
        local tmpRoomNeedBoutNum = curRoomNeedBoutNum
        local tmpRoomTicketNum = curRoomTicketNum
        local tmpCurRoomBout = curRoomBout
        if tmpRoomNeedBoutNum == 0 then
            tmpRoomNeedBoutNum = totalNeedBoutNum
            tmpRoomTicketNum = totalTicketNum
            tmpCurRoomBout = totalRoomBout
        end
        
        local txtValue = panelTimingTicket:getChildByName("Text_Value")
        if txtValue then
            txtValue:setString(tmpRoomTicketNum)
        end

        local  txtCurrentBout = panelTimingTicket:getChildByName("Text_BoutPlayed")
        if txtCurrentBout then
            txtCurrentBout:setString(tmpCurRoomBout)
        end
        local  txtTargetBout = panelTimingTicket:getChildByName("Text_BoutInfo")
        if txtTargetBout then
            txtTargetBout:setString("/".. tmpRoomNeedBoutNum .."局")
        end

        local  imgDisableBG = panelTimingTicket:getChildByName("Disable_BG")
        local  imgDisableIcon = panelTimingTicket:getChildByName("Disable_Icon")
        local bShow = (tmpCurRoomBout < tmpRoomNeedBoutNum)
        imgDisableBG:setVisible(bShow)
        imgDisableIcon:setVisible(bShow)
    end

end

function MyResultPanelEx:initLevel()
    MyResultPanelEx.super.initLevel(self)
    -- 2018年9月3日 新的结算界面直接不显示 等级进度条
    local panelLevel = self._resultPanel:getChildByName("Node_Level"):getChildByName("Panel_Level")
    if panelLevel then
        panelLevel:setVisible(false)
    end

end

function MyResultPanelEx:showBreakEggsAnimation(ntype, nNum)
    local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_ani_Exchange.csb")
    action:play("animation2", false)

    local rewardText = self._EggerActionNode:getChildByName("Panel_3"):getChildByName("Img_Reward"):getChildByName("Text_RewardNum")
    rewardText:setString("+"..nNum)
    local rewardImage1 = self._EggerActionNode:getChildByName("Panel_3"):getChildByName("Img_RewardIcon")
    local rewardImage2 = self._EggerActionNode:getChildByName("Panel_3"):getChildByName("Img_RewardIcon2")
    rewardImage1:setVisible(true)
    rewardImage2:setVisible(true)
    if ntype == 8 then  --兑换券
        rewardImage2:setVisible(false)
    else
        rewardImage1:setVisible(false)
    end
    self._EggerActionNode:runAction(action)
end

function MyResultPanelEx:BtnTopBottomClick(Panel_Player, index)
    local Btn_TopBottom = Panel_Player:getChildByName("Button_TopBottom")  
    local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
    local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
    local Image_jiantou = Btn_TopBottom:getChildByName("Image_jiantou")  
   
    Image_TopBottom:setVisible(true)
    Text_TopBottom:setVisible(true)
    Image_jiantou:setVisible(true)
    self._clickOrder = self._clickOrder + 1
    Panel_Player:setLocalZOrder(self._clickOrder)
    local a2 = cc.DelayTime:create(1)
    local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
        if Image_TopBottom and Image_TopBottom:isVisible() then
            Image_TopBottom:setVisible(false)
            Text_TopBottom:setVisible(false)
            Image_jiantou:setVisible(false)
            Panel_Player:setLocalZOrder(self._oriOrder)
        end
    end))
    Btn_TopBottom:runAction(a4)
end

function MyResultPanelEx:InitBtnTopBottom(panelDetails)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/Result_Ex.plist")
    for i=1, 4 do 
        local Panel_Player = panelDetails:getChildByName("Panel_Player"..tostring(i))
        Panel_Player:setLocalZOrder(100) --设置
        local Btn_TopBottom = Panel_Player:getChildByName("Button_TopBottom")  
        local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
        local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
        Btn_TopBottom:setVisible(false)
        Btn_TopBottom:addClickEventListener(function()
            self:BtnTopBottomClick(Panel_Player, i)
        end)
    end
end

function MyResultPanelEx:setValueTextWithTopBottom(Panel_player, Text_Score, chairno)
    self:setValueText(Text_Score, chairno)
    local textScorePosX = Text_Score:getPositionX()
    local selfOneScoreSize = 38  -- 经验值
    local OneScoreSize = 20 -- 经验值

    if self._gameController:isNeedDeposit() then
        -- 拿到其他玩家的椅子号
        local otherPlayerChair = {}
        for k, v in pairs(self._gameWin.nWinPoints) do 
            if k ~= chairno and v ~= 0 then
                table.insert(otherPlayerChair, k)
            end
        end

        local totalDeposit = self._gameWin.nDepositDiffs[chairno] + self._gameWin.nWinFees[chairno]
        local digitalCount = #tostring(math.abs(totalDeposit)) + 1  -- 计算得到分数是几位数
        print("textScore positionX and digitalCount ", textScorePosX, digitalCount)
        local offsetPosX = digitalCount * OneScoreSize
        if chairno == (self:getMyChairNO()+1) then
            offsetPosX = digitalCount * selfOneScoreSize
        end

        if totalDeposit > 0 then -- 加银子， 判断要不要封顶
        
            --[[ -- 记录输的玩家椅子号
            local loseChair = {}
            for chair=1,4 do 
                if self._gameWin.nWinPoints[chair] < 0 then
                    table.insert(loseChair, chair)
                end
            end]]--

            -- 计算本局结算目标分数
            local calcDeposit = math.abs(self._gameWin.nWinPoints[chairno]) * self._gameWin.nBaseDeposit + self._gameWin.nWinFees[chairno]
            -- 得到该玩家的携银
            local drawIndex = self:rul_GetDrawIndexByChairNO(chairno-1)
            local currentDeposit = self._gameController._baseGamePlayerInfoManager:getPlayerDeposit(drawIndex)
            -- 得到该玩加原来的携银
            local oldDeposit = self._gameWin.nOldDeposits[chairno]
            local bMinPlayer = true
            for k, v in pairs(otherPlayerChair) do
                local playerDeposit = self._gameWin.nOldDeposits[v]
                if playerDeposit < oldDeposit then
                    bMinPlayer = false  -- 如果输的玩家携银比 当前玩家还要少，则当前玩家不是最少携银玩家，不能作为封顶判断条件
                    break
                end
            end
            
            print("-------1---- oldDeposit ", oldDeposit)
            print("-------1---- calcDeposit ", calcDeposit)
            print("-------1---- bMinPlayer ", bMinPlayer)

            if oldDeposit < calcDeposit and true == bMinPlayer then
            --if true then
                -- 加银两的玩家携银 小于理论值， 输的两个玩家均大于该玩家携银。 判定为封顶
                local Btn_TopBottom = Panel_player:getChildByName("Button_TopBottom")  
                local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
                local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
                local Image_jiantou = Btn_TopBottom:getChildByName("Image_jiantou")  
                local imgPath = "GameCocosStudio/plist/Result_Ex/fengding.png"
                Btn_TopBottom:loadTextureNormal(imgPath, 1)
                Btn_TopBottom:setPositionX(textScorePosX + offsetPosX)
                Btn_TopBottom:setVisible(true)

                local content = string.format(self._gameController:getGameStringByKey("G_GAME_RESULT_BTN_TOP_TIP"), oldDeposit, totalDeposit)
                local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                Text_TopBottom:setString(utf8Content)
                local textSize = Text_TopBottom:getSize()
                Image_TopBottom:setContentSize(textSize.width + 20, Image_TopBottom:getSize().height)

                self._clickOrder = self._clickOrder + 1
                Panel_player:setLocalZOrder(self._clickOrder)

                local a2 = cc.DelayTime:create(2)
                local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
                   if Image_TopBottom and Image_TopBottom:isVisible() then
                        Image_TopBottom:setVisible(false)
                        Text_TopBottom:setVisible(false)
                        Image_jiantou:setVisible(false)
                        Panel_player:setLocalZOrder(self._oriOrder)
                    end
                end))
                Btn_TopBottom:runAction(a4)
            end
        else
            -- 扣银子， 判断要不要破产
            --[[ -- 记录赢的玩家椅子号
            local winChair = {}
            for chair=1,4 do 
                if self._gameWin.nWinPoints[chair] > 0 then
                    table.insert(winChair, chair)
                end
            end
            ]]--

            -- 计算本局结算目标分数
            local calcDeposit = math.abs(self._gameWin.nWinPoints[chairno]) * self._gameWin.nBaseDeposit + self._gameWin.nWinFees[chairno]
            -- 得到该玩加原来的携银
            local oldDeposit = self._gameWin.nOldDeposits[chairno]
            local bMinPlayer = true
            for k, v in pairs(otherPlayerChair) do
                local playerDeposit = self._gameWin.nOldDeposits[v]
                if playerDeposit < oldDeposit then
                    bMinPlayer = false  -- 如果输的玩家携银比 当前玩家还要少，则当前玩家不是最少携银玩家，不能作为封顶判断条件
                    break
                end
            end

            print("-------2---- oldDeposit ", oldDeposit)
            print("-------2---- calcDeposit ", calcDeposit)
            print("-------2---- bMinPlayer ", bMinPlayer)
            if oldDeposit < calcDeposit and true == bMinPlayer then
            --if true then
                -- 扣银两的玩家携银 小于理论值， 输的两个玩家均大于该玩家携银。 判定为封顶
                local Btn_TopBottom = Panel_player:getChildByName("Button_TopBottom")  
                local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
                local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
                local Image_jiantou = Btn_TopBottom:getChildByName("Image_jiantou")  
                -- 设置破产图片
                local imgPath = "GameCocosStudio/plist/Result_Ex/pochan.png"
                Btn_TopBottom:loadTextureNormal(imgPath, 1)
                Btn_TopBottom:loadTexturePressed(imgPath, 1)
                Btn_TopBottom:setPositionX(textScorePosX + offsetPosX)
                Btn_TopBottom:setVisible(true)
                -- 设置破产提示语
                local content = string.format(self._gameController:getGameStringByKey("G_GAME_RESULT_BTN_BOTTOM_TIP"))
                local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                Text_TopBottom:setString(utf8Content)
                local textSize = Text_TopBottom:getSize()
                Image_TopBottom:setContentSize(textSize.width + 20, Image_TopBottom:getSize().height)

                self._clickOrder = self._clickOrder + 1
                Panel_player:setLocalZOrder(self._clickOrder)

                local a2 = cc.DelayTime:create(2)
                local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
                   if Image_TopBottom and Image_TopBottom:isVisible() then
                        Image_TopBottom:setVisible(false)
                        Text_TopBottom:setVisible(false)
                        Image_jiantou:setVisible(false)
                        Panel_player:setLocalZOrder(self._oriOrder)
                    end
                end))
                Btn_TopBottom:runAction(a4)
            end
        end
    end
end

function MyResultPanelEx:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

return MyResultPanelEx