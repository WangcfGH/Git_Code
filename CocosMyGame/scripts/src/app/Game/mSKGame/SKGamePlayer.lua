
local BaseGamePlayer = import("src.app.Game.mBaseGame.BaseGamePlayer")
local SKGamePlayer = class("SKGamePlayer", BaseGamePlayer)
local constStrings1 = cc.load('json').loader.loadFile('ChatStrings.json')
local constStrings2 = cc.load('json').loader.loadFile('ChatStrings-female.json')

local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local ReportModel = require('src.app.plugins.Report.ReportModel'):getInstance()

local SK_FACE_INDEX = {
    SK_FACE_NORMAL      = 0,
    SK_FACE_BANKER      = 1,
    SK_FACE_HELPER      = 2,
}

local ToolsSilver = {
    Up   = 300,
    Down = 300,
    Rose = 1000,
    Lighting = 3000
}

local lbsLabel={}
local lbsInfoTable={}
local headPic={}
local headPathTable={}
local originalHeadPicSize={}
local selfDefineHeadPicSize={}
local defaltHeadPicSize={}

selfDefineHeadPicSize.width=100
selfDefineHeadPicSize.height=100

defaltHeadPicSize.width=130
defaltHeadPicSize.height=130

function SKGamePlayer:ctor(playerPanel, playerNode, drawIndex, gameController)
    self._playerNode                = playerNode
    self._playerHead                = nil

    self._playerPass                = nil
    self._playerCards               = nil
    self._playerCardsCount          = nil
    
    self._playerFlower              = nil
    self._playerFlowerNum           = nil
    self._playerScore               = nil
    self._playerScoreNum            = nil

    self._playerFlowerCount         = 0
    self._playerScoreCount          = 0

    self._playerShowCards           = nil

    self._playerInfoHead               = nil

    self._playerSilverValue         = nil
    
    self._nickSex                   = 0
    self._faceIndex                 = SK_FACE_INDEX.SK_FACE_NORMAL

    
    self._playerUserID              = 0
    self._playerLbsPanel            = nil
    self._playerLbs                 = nil
    self._headSize                  = {}

    self._addTimer                  = nil
    self._upTimer                 = nil
    self._downTimer                 = nil
    self._RoseTimer                 = nil
    self._LightingTimer             = nil

    self._gameStart                 = false

    self._canDownBtn = true
    cc.exports._canUpBtn = true
    self._canRoseBtn = true
    self._canLightingBtn = true
    self._canTouchBtns = true

    self._upCount                 = 0
    self._downCount               = 0
    
    

    lbsLabel={}
    lbsInfoTable={}
    headPic={}
    headPathTable={}

    SKGamePlayer.super.ctor(self, playerPanel, drawIndex, gameController)
end

function SKGamePlayer:init()
    if self._playerPanel then
        self._playerNode:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + self._drawIndex)
        self._playerPanel:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + self._drawIndex)
        if self._drawIndex == 4 then
            self._playerNode:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + 10)
            self._playerPanel:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + 10)
        end

        self._playerInfoHead = self._playerNode:getChildByName("Panel_PlayerInfo")
        self._playerBtnHead     = self._playerInfoHead:getChildByName("Btn_PlayerInfo")
        self._playerBtnHead:setVisible(false)

        self._playerHead        = self._playerInfoHead:getChildByName("Icon_Player")
        if self._playerHead then
            self._headSize = self._playerHead:getContentSize()
        end

        local playerName = self._playerPanel:getChildByName("Node_PlayerName"):getChildByName("Panel_PlayerName")
        self._playerUserName    = playerName:getChildByName("Text_PlayerName")

        self._playerReady       = self._playerPanel:getChildByName("Node_Ready")
        self._playerChatFrame = self._playerPanel:getChildByName("Node_ChatPapo"):getChildByName("Panel_ChatPapo")
        if self._playerChatFrame then
            self._playerChatStr = self._playerChatFrame:getChildByName("Text_Chat")
        end
        self._playerInfoPanel   = self._playerPanel:getChildByName("Node_PlayInfo"):getChildByName("Panel_PlayerInfo")
        if self._playerInfoPanel then
            self._playerInfoPanel:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO)
            self._playerInfoPanel:setVisible(false)

            self._infoLevelImage = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Img_GameLevel")
            self._infoLevelImage:setVisible(false)
        end
      
        self._playerLbsPanel = self._playerPanel:getChildByName("Node_Play_lbs")
        if self._playerLbsPanel then
            self._playerLbsPanel:setVisible(false)
            self._playerLbs = self._playerLbsPanel:getChildByName("Img_Lbs"):getChildByName("Text_1")      --位置信息
        end

        
        self._playerPass            = self._playerPanel:getChildByName("Node_Skip")
        self._playerCards           = ccui.Helper:seekWidgetByName(self._playerInfoHead, "Panel_CardRemain")
        self._playerCardsCount      = ccui.Helper:seekWidgetByName(self._playerInfoHead, "Value_CardRemain")
        
        self._playerSilverValue    = self._playerPanel:getChildByName("Node_SilverValue"):getChildByName("Panel_Skip")
        --self._playerFlower          = ccui.Helper:seekWidgetByName(self._playerPanel, "img_flower_"..tostring(self._drawIndex))
        --self._playerFlowerNum       = ccui.Helper:seekWidgetByName(self._playerPanel, "Player_num_flower")
        --self._playerScore           = ccui.Helper:seekWidgetByName(self._playerPanel, "Player_sp_Score")
        --self._playerScoreNum        = ccui.Helper:seekWidgetByName(self._playerPanel, "Player_num_Score")

        --self._playerShowCards       = self._playerPanel:getChildByName("icon_player_shown")
        self._playerUpNum         = ccui.Helper:seekWidgetByName(playerName, "Value_Praise")
        self._playerUpNum:setString("0")
        --self._playerUpAniNode       = self._playerPanel:getChildByName("Node_goodjob_light_"..tostring(self._drawIndex))

        self._playerLevelImage = self._playerInfoHead:getChildByName("Img_GameLevel")
        self._playerLevelColor = self._playerLevelImage:getChildByName("Img_LevelColor")
        self._playerLevelText = self._playerLevelImage:getChildByName("Text_LevelNum")

        
        self._playerHeadSize = self._playerHead:getContentSize()

        self._addFriendBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Add")
        self._selfExchangeBg = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Img_Exchange")

        --获取举报控件
        self._report = self._playerNode:getChildByName("Btn_Report")
        ReportModel:clearReportNameList()
    end

    self:setClickEvent()
    self:initPlayer()

    self:onUpdateExchangeNum()
end

function SKGamePlayer:initPlayer()
    self:stopAddFriendTimer()
    self:stopDownPlayerTimer()
    self:stopUpTimer()
    self:stopRoseTimer()
    self:stopLightingTimer()
    self._canDownBtn = true
    cc.exports._canUpBtn = true
    self._canRoseBtn = true
    self._canLightingBtn = true
    self._canTouchBtns = true
    SKGamePlayer.super.initPlayer(self)
end

function SKGamePlayer:stopAddFriendTimer()
    if self._addTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._addTimer)
        self._addTimer = nil
    end
end

function SKGamePlayer:stopDownPlayerTimer()
    if self._downTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._downTimer)
        self._downTimer = nil
    end
end

function SKGamePlayer:hideAllChildren()
    if self._gameController:isGameRunning() then
        return
    end

    if not self._playerPanel then return end

    local playerChildren = self._playerPanel:getChildren()
    for i = 1, self._playerPanel:getChildrenCount() do
        local child = playerChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    if not self._playerInfoHead then return end

    local playerChildren = self._playerInfoHead:getChildren()
    for i = 1, self._playerInfoHead:getChildrenCount() do
        local child = playerChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    self._playerLevelData = nil
    self._playerUserID = 0
end

function SKGamePlayer:resetPlayer()
    self:setWaitingAnimation(false)
    self:showPass(false)
    self:FreshPlace(0)
--    self:setPlayerFlower(0)
--    self:setPlayerCurrentGains(0)
--    self:showBanker(false)
    self:setCardsCount(0, false)
    self:setShowCards(false)
end

function SKGamePlayer:setShowCards(bShow)
    if self._playerShowCards then
        self._playerShowCards:setVisible(bShow)
    end
end

function SKGamePlayer:setUserName(szUserName)
    if self._playerUserName then
        self._playerUserName:setVisible(true)

        local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
        my.fitStringInWidget(utf8name, self._playerUserName, 115)

        local playerName = self._playerPanel:getChildByName("Node_PlayerName")
        playerName:setVisible(true)
    end
end

function SKGamePlayer:setSoloPlayer(soloPlayer)
    SKGamePlayer.super.setSoloPlayer(self, soloPlayer)
    self._gameController:playGamePublicSound("Snd_Enter.mp3")
    if self._playerBtnHead then
        self._playerBtnHead:setVisible(true)
    end
    if self._playerHead then
        self._playerHead:setVisible(true)
    end

    if self._playerPanel then
        self._playerPanel:setVisible(true)
    end
    
    self:showMemberIcon(soloPlayer)

    --贵族系统头像框显示
    self:showNobilityPrivilegeHead(soloPlayer)

    if self._drawIndex == 1 then --暂时只请求自己的数据
        self._gameController:OnUpInfo(soloPlayer)
    end

    if self._drawIndex ~= 1 then 
        if self:isRobot(soloPlayer.nUserType)
        and PUBLIC_INTERFACE.IsStartAsTimingGame() then
            TimingGameModel:reqTimingGameRobotInfoData(soloPlayer.nUserID)
            soloPlayer.nDeposit = soloPlayer.nUserID %15000 + soloPlayer.nUserID % 3 * 17 + soloPlayer.nUserID % 2 * 5
            soloPlayer.nScore = soloPlayer.nUserID %1700 * 8 + soloPlayer.nUserID % 3 * 25 + soloPlayer.nUserID % 2 * 3
            if  soloPlayer.nUserID % 6 == 0 then
                soloPlayer.nScore = -soloPlayer.nScore
            end
        end
    end
    
    --等级添加
    self._gameController:OnUserLevelData(soloPlayer)

    --about remark name
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
       if(tcyFriendPlugin:isFriend(soloPlayer.nUserID))then
           local remark = tcyFriendPlugin:getRemarkName(soloPlayer.nUserID)
           if(remark~="")then
                local gbkName = MCCharset:getInstance():utf82GbString(remark, string.len(remark))         
                self:setUserName(gbkName)
           end
       end
    end

----create lbs label
    if self._playerLbs then
        lbsLabel[soloPlayer.nUserID]=self._playerLbs
        if(lbsInfoTable[soloPlayer.nUserID])then
            self._playerLbs:setString(lbsInfoTable[soloPlayer.nUserID])
            self._playerLbsPanel:setVisible(true)
            self._playerLbs:setVisible(true)
        else
            self._playerLbs:setString("")
            self._playerLbsPanel:setVisible(false)
            self._playerLbs:setVisible(false)
        end
    end
    
    --create head pic
    --[[
    headPic[soloPlayer.nUserID]=self._playerHead
    if not self._gameController:isGameRunning() then    
        local resName = ""
        local size
        if(headPathTable[soloPlayer.nUserID])then
            size = selfDefineHeadPicSize            
            resName = headPathTable[soloPlayer.nUserID]
        else
            size = defaltHeadPicSize
            resName = self:getDefaltHeadPic()
        end
        self._playerHead:loadTexture(resName)
        self._playerHead:setVisible(true)
        self._playerHead:setContentSize(size)
    end
    ]]
    self._playerUserID=soloPlayer.nUserID
    if not self._addFriendBtn then
        return    
    end

    if cc.exports.IsSocialSupportted() then
        local json = cc.load("json").json
        local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
        if( ofile == "")then
            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
            return
        end
        local des = json.decode(ofile)
        local addDes=des["addInChartered"]
        local title=des["add"]

        if self._gameController:isRandomRoom() then
            addDes=des["addInRandomRoom"]
        end

        ofile = MCFileUtils:getInstance():getStringFromFile("AppConfig.json")
        if( ofile == "")then
            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
            return
        end
        des = json.decode(ofile)
        addDes=string.format(addDes,des["name"])

        local function dealAddBtn()
            printf("dealAddBtn")
            self:stopAddFriendTimer()
            if self._addFriendBtn then
                self._addFriendBtn:setTouchEnabled(true)
            end
        end

        local function addFriend()
            self._addFriendBtn:setTouchEnabled(false)
            self._gameController:addFriend(soloPlayer.nUserID,addDes)
            self:stopAddFriendTimer()
            self._addTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealAddBtn , 5, false)
        end
        self._addFriendBtn:addClickEventListener(addFriend)
    else
        self._addFriendBtn:setTouchEnabled(false)
        self._addFriendBtn:setBright(false)
        self._addFriendBtn:setVisible(false)
    end 
end

function SKGamePlayer:playUpAnimation(bShow)
    if self._playerUpAniNode then
        self._playerUpAniNode:setVisible(bShow)
        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_Animation_Goodjob.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                 self._playerUpAniNode:runAction(action)
                 action:gotoFrameAndPlay(1, 91, false)
            end
        end
    end 
end

function SKGamePlayer:setShowUpInfo(upInfo)
    dump(upInfo, "setShowUpInfo dianzan")
    if not self._playerUserName and not self._playerHead then
        return
    end
    if not self._playerUserName:isVisible() and not self._playerHead:isVisible() then
        return
    end
    ---拉黑功能数据填充  数据附在nReserved 中
    local downBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_HateInfo")
    if downBtn then
        local num = tonumber(upInfo.nReserved[4]) - tonumber(upInfo.nReserved[3])
        self:setToolsInfo(downBtn, num, ToolsSilver.Down)
        if num > 0 then
            self._downCount = num
        elseif not cc.exports.isSafeBoxSupported() then
            downBtn:setTouchEnabled(false)
            downBtn:setBright(false)
        end
    end
    -----------------------------------------------------------
    
    if self._playerUpNum then
        local playerInfoManager = self._gameController:getPlayerInfoManager()
        local playerInfo = playerInfoManager:getPlayerInfo(self._drawIndex)
        if playerInfo ~= nil then
            --举报功能 更新房间信息，填入对象姓名，id，携银
            ReportModel:updateRoominfo();
            
            local reportPlayerInfon = {
                name = '',
                userID = 1,
                deposit = 0
            }

            reportPlayerInfon.name = playerInfo.szNickName
            reportPlayerInfon.userID = playerInfo.nUserID
            reportPlayerInfon.deposit = playerInfo.nDeposit

            ReportModel.ReportNameList[self._drawIndex] = reportPlayerInfon
        end

        if (self._drawIndex ~= 1 and upInfo.nUserID == upInfo.nDestID)
        or (playerInfo and upInfo.nDestChairNO ~= playerInfo.nChairNO)  then
            self._playerUpNum:setString("获取数据中，请稍候~")
        else
            if playerInfo and self:isRobot(playerInfo.nUserType) then
                upInfo.nUpedCount = upInfo.nUpedCount + self:getRobotAdditionPraise(playerInfo)
            end
            if upInfo and upInfo.nUpedCount then
                self._playerUpNum:setString(tostring(upInfo.nUpedCount))
            end
        end
        self:showPraiseTextInfo()

        local hardUpBtn = self._playerInfoHead:getChildByName("Btn_Praise")
        hardUpBtn:setVisible(false)
        local function onUpPlayer()
            self:onUpPlayer(self._drawIndex)
        end
        hardUpBtn:addClickEventListener(onUpPlayer)

        local upBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_PraiseInfo")

        if upBtn then
            self:setLastUpCount(upInfo.nUserID, tonumber(upInfo.nCurUpCount))
            local curUpCount = self:getLastUpCount(upInfo.nUserID)
            local num = tonumber(upInfo.nMaxUpCount) - curUpCount
            self:setToolsInfo(upBtn, num, ToolsSilver.Up)
            if num > 0 then
                self._upCount = num
            end

            if num <= 0 and not cc.exports.isSafeBoxSupported() then
                upBtn:setTouchEnabled(false)
                upBtn:setBright(false)
            else
                if upInfo.nUpState == SKGameDef.SK_UP_OTHER_FULL or upInfo.nUpState == SKGameDef.SK_UP_SELF_FULL or upInfo.nUpState == SKGameDef.SK_UP_SAME_ROUND then
                    upBtn:setTouchEnabled(false)
                    upBtn:setBright(false)
                    hardUpBtn:setTouchEnabled(false)
                    hardUpBtn:setBright(false)
                elseif upInfo.nUpState == SKGameDef.SK_UP_SUCCESS then--or upInfo.nUpState == SKGameDef.SK_UP_FULL then
                    upBtn:setTouchEnabled(true)
                    upBtn:setBright(true)
                    hardUpBtn:setTouchEnabled(true)
                    hardUpBtn:setBright(true)
                elseif upInfo.nUpState == SKGameDef.SK_UP_FULL then
                    upBtn:setTouchEnabled(true)
                    upBtn:setBright(true)
                    hardUpBtn:setTouchEnabled(true)
                    hardUpBtn:setBright(true)
                end
            end
        end
        local valuePanel = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Lose")
        if valuePanel then
            valuePanel:setString(tostring(upInfo.nUpedCount))
        end
    end

    local RoseBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Rose")
    if RoseBtn then
        if cc.exports.ExpressionInfo.nRoseNum and cc.exports.ExpressionInfo.nRoseNum > 0 then
            self:setToolsInfo(RoseBtn, cc.exports.ExpressionInfo.nRoseNum, ToolsSilver.Rose)
        else
            self:setToolsInfo(RoseBtn, 0, ToolsSilver.Rose)
        end
    end
    local LightingBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Lighting")
    if LightingBtn then
        if cc.exports.ExpressionInfo.nLightingNum and cc.exports.ExpressionInfo.nLightingNum > 0 then
            self:setToolsInfo(LightingBtn, cc.exports.ExpressionInfo.nLightingNum, ToolsSilver.Lighting)
        else

            self:setToolsInfo(LightingBtn, 0, ToolsSilver.Lighting)
        end
    end
 ------添加举报功能--------------------------------
    --获取举报按钮控件
    local ReportBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Report")
    --显示按钮,一号位是自己
    if ReportBtn and ReportModel.open == true and self._drawIndex ~= 1 then
        --按钮谁的面板上按的，就选谁
        ReportModel.newObject = self._drawIndex
        --绑定事件 点击按钮，实例化举报界面
        ReportBtn:addClickEventListener(handler(self, self.Report))
    end
    ---------------------------------------------------
end

--举报事件:实例化大厅那边的插件-举报功能
function SKGamePlayer:Report()
    my.informPluginByName({pluginName='ReportCtrl'}) 
end

function SKGamePlayer:getRobotAdditionPraise(playerInfo)
    local additionCount = 0
    additionCount = playerInfo.nUserID % 20 + (playerInfo.nUserID % 2) * 3
    return additionCount
end

function SKGamePlayer:getRobotAdditionPraise(playerInfo)
    local additionCount = 0
    additionCount = playerInfo.nUserID % 20 + (playerInfo.nUserID % 2) * 3
    return additionCount
end

function SKGamePlayer:updataUpInfo(upData)  
    if self._playerUpNum then       
        local playerInfoManager = self._gameController:getPlayerInfoManager()
        local playerInfo = playerInfoManager:getPlayerInfo(self._drawIndex)

        if self:isRobot(playerInfo.nUserType) then
            upData.nUpCount = upData.nUpCount + self:getRobotAdditionPraise(playerInfo)
        end
        self._playerUpNum:setString(tostring(upData.nUpCount))

        local valuePanel = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Lose")
        if valuePanel then
            valuePanel:setString(tostring(upData.nUpCount))
        end
    end
end

function SKGamePlayer:updataOtherUpInfo(upData, index)
    print("self chairno ", self._gameController:getMyChairNO())
    dump(upData, "updataOtherUpInfo  dianzan")
    local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(upData.nDestChairNO)
    local upBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_PraiseInfo")
    
    --local upedImage = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Img_PraiseInfo")
    if upBtn then
        local myChairNO = self._gameController:getMyChairNO()
        local curUpCount = tonumber(upData.nCurUpCount)
        if myChairNO == upData.nSourceChairNO then
            local userID = UserPlugin:getUserID()
            self:setLastUpCount(userID, tonumber(upData.nCurUpCount))
            curUpCount = self:getLastUpCount(userID)
        end

        local num = tonumber(upData.nMaxUpCount) - curUpCount
        self:setToolsInfo(upBtn, num, ToolsSilver.Up)
        if num > 0 then
            self._upCount = num
        end

        --[[
        local textL = ccui.Helper:seekWidgetByName(self._playerInfoPanel, ("Value_Praise_L"))
        textL:setString(tostring(upData.nCurUpCount))
        local textR = ccui.Helper:seekWidgetByName(self._playerInfoPanel,("Value_Praise_R"))
        textR:setString(tostring(upData.nMaxUpCount))
        --]]

        --textL:setTextColor(cc.c4b(163,72,17))
        --textR:setTextColor(cc.c4b(163,72,17))

        local hardUpBtn = self._playerInfoHead:getChildByName("Btn_Praise")
        --[[if upData.nCurUpCount >= upData.nMaxUpCount then
            upBtn:setTouchEnabled(false)
            upBtn:setBright(false)
            
            --textL:setTextColor(cc.c4b(77,77,77))
            --textR:setTextColor(cc.c4b(77,77,77))
            --textL:setVisible(false)
            --textR:setVisible(false)
            
            hardUpBtn:setTouchEnabled(false)
            hardUpBtn:setBright(false)
        end]]
        if drawIndex == index then
            --upedImage:setVisible(true)
            upBtn:setTouchEnabled(false)
            upBtn:setBright(false)

            --textL:setVisible(false)
            --textR:setVisible(false)
            
            hardUpBtn:setTouchEnabled(false)
            hardUpBtn:setBright(false)
          
            local valuePanel = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Lose")
            if valuePanel then
                valuePanel:setString(tostring(upData.nUpCount))
            end
        end
    end
end

function SKGamePlayer:updataOtherDownInfo(upData, index)
    local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(upData.nDestChairNO)
    local downBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_HateInfo")
    
    if downBtn then
        local num = tonumber(upData.nMaxCount) - tonumber(upData.nCurrentCount)
        self:setToolsInfo(downBtn, num, ToolsSilver.Down)
        if num > 0 then
            self._downCount = num
        end
        --[[
        local textL = ccui.Helper:seekWidgetByName(self._playerInfoPanel, ("Value_Hate_L"))
        textL:setString(tostring(upData.nCurrentCount))
        local textR = ccui.Helper:seekWidgetByName(self._playerInfoPanel,("Value_Hate_R"))
        textR:setString(tostring(upData.nMaxCount))
        --]]
    end
end

function SKGamePlayer:setWaitingAnimation(bShow)
    local nodeAnimation = self._playerPanel:getChildByName("Node_light_"..tostring(self._drawIndex))
    if nodeAnimation then
        nodeAnimation:setVisible(bShow)

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/game_scene_animation/Node_light.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                nodeAnimation:runAction(action)
                action:gotoFrameAndPlay(1, 20, true)
            end
        end
    end
end

function SKGamePlayer:setReady(bReady)
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        --bReady = false
    end
    if self._playerReady then
        self._playerReady:setVisible(bReady)

        if bReady then
            local csbPath = "res/GameCocosStudio/csb/Node_Ready.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._playerReady:runAction(action)
                action:gotoFrameAndPlay(1, 6, false)
            end
        end
    end
end

function SKGamePlayer:showPass(bShow)
    if self._playerPass then
        self._playerPass:setVisible(bShow)

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_Skip.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._playerPass:runAction(action)
                action:gotoFrameAndPlay(0, 60, false)
            end
        end
    end
end

function SKGamePlayer:addPlayerFlower()
    self:setPlayerFlower(self._playerFlowerCount + 1)
end

function SKGamePlayer:setPlayerFlower(nFlower)
    if "number" ~= type(nFlower) then return end

    self._playerFlowerCount = nFlower

    if 0 < nFlower then
        if self._playerFlowerNum then
            self._playerFlowerNum:setVisible(true)
            self._playerFlowerNum:setString(tostring(nFlower))
        end
        if self._playerFlower then
            self._playerFlower:setVisible(true)
        end
    else
        if self._playerFlowerNum then
            self._playerFlowerNum:setVisible(false)
        end
        if self._playerFlower then
            self._playerFlower:setVisible(false)
        end
    end
end

function SKGamePlayer:addPlayerCurrentGains(gains)
    self:setPlayerCurrentGains(self._playerScoreCount + gains)
end

function SKGamePlayer:setPlayerCurrentGains(gains)
    if "number" ~= type(gains) then return end

    self._playerScoreCount = gains

    if 0 < gains then
        if self._playerScoreNum then
            self._playerScoreNum:setVisible(true)
            self._playerScoreNum:setString(tostring(gains))
        end
        if self._playerScore then
            self._playerScore:setVisible(true)
        end
    else
        if self._playerScoreNum then
            self._playerScoreNum:setVisible(false)
        end
        if self._playerScore then
            self._playerScore:setVisible(false)
        end
    end
end

function SKGamePlayer:getDefaltHeadPic()
    local resName = ""
    if 1 == self._nickSex then
        resName = "res/Game/GamePic/PlayerRole/Role_Girl.png"
    else
        resName = "res/Game/GamePic/PlayerRole/Role_Boy.png"
    end

    return resName
end

function SKGamePlayer:setNickSex(nNickSex)
    self._nickSex = nNickSex
    
    --[[if not self._gameController:isGameRunning() then
        if self._playerHead then
            local resName = ""
            local size
            if(headPathTable[self._playerUserID])then
                size = selfDefineHeadPicSize  
                resName = headPathTable[self._playerUserID]
            else
                size = defaltHeadPicSize
                resName = self:getDefaltHeadPic()
            end
            self._playerHead:loadTexture(resName)           
            self._playerHead:setVisible(true)
            self._playerHead:setContentSize(size)
        end
    else  ]]
        if self._playerHead then
            --self._playerHead:setVisible(true)
        
            local resName = ""
            if 1 == nNickSex then
                resName = "res/Game/GamePic/GameContents/Role_HeadGirl.png"
            else
                resName = "res/Game/GamePic/GameContents/Role_HeadBoy.png"
            end
            self._playerHead:loadTexture(resName)
        end
--    end
end

function SKGamePlayer:setOriginFace()
    if SK_FACE_INDEX.SK_FACE_BANKER == self._faceIndex then
        self:showBanker(true)
    elseif SK_FACE_INDEX.SK_FACE_HELPER == self._faceIndex then
        self:showHelper(true)
    else
        self:setNickSex(self._nickSex)
    end
end

function SKGamePlayer:showRobot(bRobot)
    if self._playerHead then
        self._playerHead:setVisible(true)
        if bRobot then
            self._playerHead:setContentSize(cc.size(171,196))
            local resName = "res/Game/GamePic/GameContents/Role_Robot.png"
            self._playerHead:loadTexture(resName)
        else
            self._playerHead:setContentSize(self._playerHeadSize)
            self:setOriginFace()
        end
    end
end

function SKGamePlayer:showBanker(bBanker)
    --[[if self._playerHead then
        self._playerHead:setVisible(true)
        if bBanker then
            self._faceIndex = SK_FACE_INDEX.SK_FACE_BANKER

            if not self._gameController:isAutoPlay() then
                local resName = "res/Game/GamePic/player_icon/icon_role_landlord.png"
                self._playerHead:loadTexture(resName)
            end
        else
            self._faceIndex = SK_FACE_INDEX.SK_FACE_NORMAL

            self:setNickSex(self._nickSex)
        end
    end--]]
end

function SKGamePlayer:showHelper(bHelper)
    --[[if self._playerHead then
        self._playerHead:setVisible(true)
        if bHelper then
            if SK_FACE_INDEX.SK_FACE_BANKER == self._faceIndex then return end

            self._faceIndex = SK_FACE_INDEX.SK_FACE_HELPER

            --if not self._gameController:isAutoPlay() then
                local resName = "res/Game/GamePic/player_icon/icon_role_lagt.png"
                self._playerHead:loadTexture(resName)
            --end

            --self._gameController:playGamePublicSound("Snd_dog.ogg")
        else
            self._faceIndex = SK_FACE_INDEX.SK_FACE_NORMAL

            self:setNickSex(self._nickSex)
        end
    end--]]
end

function SKGamePlayer:isFarmer()
    return SK_FACE_INDEX.SK_FACE_NORMAL == self._faceIndex
end

function SKGamePlayer:reStart()
    self._faceIndex = SK_FACE_INDEX.SK_FACE_NORMAL

    self:setNickSex(self._nickSex)
end

function SKGamePlayer:setCardsCount(cardsCount, bSound)
    if 0 < cardsCount then
        if self._playerCards then
            self._playerCards:setVisible(true)       
        end    
        if self._playerCardsCount then
            self._playerCardsCount:setVisible(true) 
            self._playerCardsCount:setString(tostring(cardsCount))
        end

        if bSound then
            local strPath
            local sex = self._nickSex
            local data = self._gameController._baseGameScene:getSetting()
            local langauge = data._selectedLangauge

            if sex == 1 then
                if langauge == 0 then
                    strPath = "res/Game/GameSound/ThrowCards/Female/Mandarin/"
                else
                    strPath = "res/Game/GameSound/ThrowCards/Female/Dialect/"
                end
            else
                if langauge == 0 then
                    strPath = "res/Game/GameSound/ThrowCards/Male/Mandarin/"
                else
                    strPath = "res/Game/GameSound/ThrowCards/Male/Dialect/"
                end
            end
            if cardsCount == 2 then
                audio.playSound(strPath.."baopai2.ogg", false)
            elseif cardsCount == 1 then
                audio.playSound(strPath.."baopai1.ogg", false)
            end
        end
    else
        if self._playerCards then 
            self._playerCards:setVisible(false)       
        end    
        if self._playerCardsCount then
            self._playerCardsCount:setVisible(false)
        end
    end
end

function SKGamePlayer:showPlayerSex(playerInfo)
    local sex = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "img_icon_sex_"..tostring(self._drawIndex))
    if sex then
        local resName = ""
        if 1 == self._nickSex then
            resName = "res/Game/GamePic/player_icon/icon_sex_1.png"
        else
            resName = "res/Game/GamePic/player_icon/icon_sex_2.png"
        end
        sex:loadTexture(resName)
    end
end

function SKGamePlayer:showPlayerName(playerInfo)
    local name = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Name")
    if name then
        local userName = playerInfo.szUserName

        local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()  
        if tcyFriendPlugin then
           if(tcyFriendPlugin:isFriend(playerInfo.nUserID))then
               local remark = tcyFriendPlugin:getRemarkName(playerInfo.nUserID)
               if(remark~="")then
                    local gbkName = MCCharset:getInstance():utf82GbString(remark, string.len(remark))         
                    userName = gbkName
               end
           end
        end

        if userName then
            local utf8Name = MCCharset:getInstance():gb2Utf8String(userName, string.len(userName))
            my.fitStringInWidget(utf8Name, name, 267)
        end
    end
end

function SKGamePlayer:showPlayerSilver(playerInfo)
    local silver = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Silver")
    if silver then
        local userDeposit = playerInfo.nDeposit        
        silver:setString(tostring(userDeposit))
    end
end

function SKGamePlayer:showPlayerScore(playerInfo)
    local score = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Score")
    if score then
        local userScore = playerInfo.nScore
        if userScore then
            local msg = string.format(self._gameController:getGameStringByKey("G_SCORE"), userScore)
            local utf8Score = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
            score:setString(utf8Score)
        end
    end
end

function SKGamePlayer:showPlayerLevel(playerInfo)
    local level = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Level")
    if level then
        --local userLevel = self._gameController:getScoreLevel(playerInfo.nScore)
        local userLevel = self._gameController:getDepositLevel(playerInfo.nDeposit)
        if userLevel then
            local utf8Name = MCCharset:getInstance():gb2Utf8String(userLevel, string.len(userLevel))
            level:setString(utf8Name)
        end
    end
end

function SKGamePlayer:showPlayerWinBouts(playerInfo)
    --[[local win = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "value_num_victorycombo_"..tostring(self._drawIndex))
    if win then
        local userWin = playerInfo.nWin
        if userWin then
            win:setString(tostring(userWin))
        end
    end--]]
end

function SKGamePlayer:showPlayerWinRate(playerInfo)
    if playerInfo.nWin and playerInfo.nLoss and playerInfo.nStandOff then
        local totalBout = playerInfo.nWin + playerInfo.nLoss + playerInfo.nStandOff

        local bout = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Victory")
        if bout then
            local winRate = 0
            if totalBout > 0 then
                winRate = math.floor(playerInfo.nWin / totalBout * 100)
            end
            bout:setString(winRate .. "%")
        end

        if PUBLIC_INTERFACE.IsStartAsTimingGame() then --定时赛隐藏胜率
            bout:setVisible(false)
            local txtVictory = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Victory")
            if txtVictory then
                txtVictory:setVisible(false)
            end
        end

        bout = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Bout")
        if bout then
            local msg = string.format(self._gameController:getGameStringByKey("GAME_PLAYER_INFO_BOUT"), playerInfo.nWin)
            local utf8Score = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
            bout:setString(utf8Score)
        end

        if PUBLIC_INTERFACE.IsStartAsTimingGame() then --定时赛隐藏局数
            bout:setVisible(false)
            local txtBout = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Bout")
            if txtBout then
                txtBout:setVisible(false)
            end
        end

        bout = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_Bout2")
        if bout then
            local msg = string.format(self._gameController:getGameStringByKey("GAME_PLAYER_INFO_BOUT"), playerInfo.nLoss)
            local utf8Score = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
            bout:setString(utf8Score)
        end

        if PUBLIC_INTERFACE.IsStartAsTimingGame() then --定时赛隐藏局数
            bout:setVisible(false)
            local txtBout = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Bout2")
            if txtBout then
                txtBout:setVisible(false)
            end
        end
    end
end

function SKGamePlayer:showPlayerUpBtn(playerInfo)
    local upBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_PraiseInfo")
    if upBtn then
        if self._drawIndex == 1 then
            upBtn:setVisible(false)
            return
        end
        local function dealUpBtn()
            self:stopUpTimer()
            cc.exports._canUpBtn = true
        end
        local function onUpPlayer()
            if self._canTouchBtns then
                self._canTouchBtns = false
                my.scheduleOnce(function()
                    self._canTouchBtns = true
                    end, 0.5)
            else
                return
            end

            if not cc.exports._canUpBtn then
                self._gameController:tipMessageByKey("G_GAME_LAHEI_TIME_TIP")
                return
            end

            cc.exports._canUpBtn = false
            self:stopUpTimer()
            self._upTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealUpBtn, 3, false)

            if self._upCount <= 0 and not self:CheckSilver(ToolsSilver.Up) then
                return
            end
            self:onUpPlayer(self._drawIndex)

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_UP_PLAYER_BTN)
        end
       upBtn:addClickEventListener(onUpPlayer)
    end
end

function SKGamePlayer:showPlayerDownBtn(playerInfo)
    local downBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_HateInfo")
    --举报按钮通常隐藏
    local ReportBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Report")
    ReportModel:updateRoominfo()
    if(ReportModel.open and self._drawIndex ~= 1) then
        ReportBtn:setVisible(true)
    else
        ReportBtn:setVisible(false)
    end

    if downBtn then
        if self._drawIndex == 1 then
            downBtn:setVisible(false)
            --downBtn:setTouchEnabled(false)
            --downBtn:setBright(false)
            return
        end 
        local function dealDownBtn()
            --downBtn:setTouchEnabled(true)
            --downBtn:setBright(true)
            self:stopDownPlayerTimer()

            self._canDownBtn = true
        end

        local function onDownPlayer()
            if self._canTouchBtns then
                self._canTouchBtns = false
                my.scheduleOnce(function()
                    self._canTouchBtns = true
                    end, 0.5)
            else
                return
            end

            if not self._canDownBtn then
                self._gameController:tipMessageByKey("G_GAME_LAHEI_TIME_TIP")
                return
            end
            
            self._canDownBtn = false
            --downBtn:setTouchEnabled(false)
            --downBtn:setBright(false)
            self:stopDownPlayerTimer()
            self._downTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealDownBtn, 3, false)

            if self._downCount <= 0 and not self:CheckSilver(ToolsSilver.Down) then
                return
            end
            self:onBuyPropsThrow(self._drawIndex)

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_DOWN_PLAYER_BTN)
        end
       downBtn:addClickEventListener(onDownPlayer)
    end
end

function SKGamePlayer:onUpPlayer()
    self._gameController:onUpPlayer(self._drawIndex)
    self:showPlayerInfo(false)
end

function SKGamePlayer:onBuyPropsThrow()
    self._gameController:onBuyPropsThrow(self._drawIndex)
    self:showPlayerInfo(false)
end

function SKGamePlayer:showPlayerInfo(bShow)
    if self._playerInfoPanel then
        if bShow then
            local playerInfoManager = self._gameController:getPlayerInfoManager()
            if playerInfoManager then
                local playerInfo = playerInfoManager:getPlayerInfo(self._drawIndex)
                if playerInfo then
                    --self:showPlayerSex(playerInfo)
                    self:showPlayerName(playerInfo)
                    self:showPlayerSilver(playerInfo)
                    --self:showPlayerScore(playerInfo)
                    self:showPlayerLevel(playerInfo)
                    --self:showPlayerWinBouts(playerInfo)
                    self:showPlayerWinRate(playerInfo)
                    self:showPlayerUpBtn(playerInfo)
                    self:showPlayerDownBtn(playerInfo)
                    self:showPlayerHeadImg(playerInfo)
                    self:showPlayerRoseBtn()
                    self:showPlayerLightingBtn()

                    if self._addFriendBtn then
                        local addBtn = self._addFriendBtn
                        local selfID = self._gameController:getPlayerInfoManager():getSelfUserID()
                        if not cc.exports.IsSocialSupportted() or (self._playerUserID == selfID)then
                            --addBtn:setVisible(false)
                            addBtn:setTouchEnabled(false)
                            addBtn:setBright(false)
                            addBtn:setVisible(false)
                            self._selfExchangeBg:setVisible(true)
                        else
                            self._selfExchangeBg:setVisible(false)
                            addBtn:setVisible(true)
                            if(self._gameController:isFriend(self._playerUserID))then
                                --addBtn:setVisible(false)
                                addBtn:setTouchEnabled(false)
                                addBtn:setBright(false)
                            else
                                addBtn:setVisible(true)
                                addBtn:setTouchEnabled(true)
                                addBtn:setBright(true)
                            end
                        end
                    end                    
                end
            end

            self._gameController:playGamePublicSound("Snd_Info.mp3")
        end
        
        self._playerInfoPanel:setVisible(bShow)
        self._playerPanel:getChildByName("Node_PlayInfo"):setVisible(true)

        -- local csbPath = "res/GameCocosStudio/csb/Node_PlayerInfo.csb"
        -- local action = cc.CSLoader:createTimeline(csbPath)
        -- action:play("animation_appear", false)
        -- self._playerInfoPanel:runAction(action)
        local panelPopup = self._playerInfoPanel:getChildByName('Panel_Ani')
        my.runPopupAction(panelPopup)
    end
end

function SKGamePlayer:onClickPlayerHead()
    --self._gameController:playBtnPressedEffect()

    print("onClickPlayerHead" .. tostring(self._drawIndex))
    self._gameController:onClickPlayerHead(self._drawIndex)
end

function SKGamePlayer:containsTouchLocation(x, y)
    if not self._playerBtnHead or not self._playerBtnHead:isVisible() then
        return false
    end

    --local position = self._playerBtnHead:getParent():convertToWorldSpace(cc.p(self._playerBtnHead:getPosition()))
    local btnPosWorld = self._playerBtnHead:getParent():convertToWorldSpace(cc.p(self._playerBtnHead:getPosition()))
    local operatePanel = self._playerBtnHead:getParent():getParent():getParent()
    local btnPosLocalInOperatePanel = operatePanel:convertToNodeSpace(btnPosWorld)
    local position = btnPosLocalInOperatePanel

    local s = self._playerBtnHead:getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

function SKGamePlayer:containsTouchInfoLocation(x, y)
    if not self._playerInfoPanel or not self._playerInfoPanel:isVisible()then
        return false
    end

    local position = self._playerInfoPanel:getParent():convertToWorldSpace(cc.p(self._playerInfoPanel:getPosition()))
    local s = self._playerInfoPanel:getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

function SKGamePlayer:playFacial(nodeName,facialName)
    local csbPath = "res/GameCocosStudio/csb/facial_emotion/"
    local emotion = cc.CSLoader:createNode(csbPath..nodeName)    
    local action = cc.CSLoader:createTimeline(csbPath..nodeName)
    if emotion and action then
        emotion:runAction(action)
        self._playerPanel:addChild(emotion)
        local emotionNode = self._playerPanel:getChildByName("Node_Emotion")
        emotion:setPosition(emotionNode:getPosition())           
    end             
    action:play(facialName, false)
    
    local function callback(frame)
        if frame then 
            local event = frame:getEvent()
            if "Action_Facial" == event then
                action:clearFrameEventCallFunc()
                emotion:stopAllActions()
                emotion:removeSelf()
                emotion = nil
            end
        end
    end
    action:setFrameEventCallFunc(callback)
end

function SKGamePlayer:tipChatContent(content)
    if self._playerPanel then
        local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
        --local str = string.sub(utf8Content,1,-2)
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


        if self._playerChatStr then
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
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
            else
                constStrings = constStrings1
                strPath = "res/Game/GameSound/Chat/Male/Mandarin/chat_"
            end        
            print(strPath)
            for i=1,15 do
                if constStrings["HLS_CHAT_WORDS_"..i+50] == str then
                    print(strPath..tostring(i-1)..".mp3")
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

function SKGamePlayer:FreshPlace(nPlace)
    local RankNode = self._playerPanel:getChildByName("Node_Ranking")
    RankNode:setVisible(true)
    local playerRanking = RankNode:getChildByName("Panel_Ranking")

    local RankImage1    = playerRanking:getChildByName("Icon_First")
    RankImage1:setVisible(false)
    local RankImage2    = playerRanking:getChildByName("Icon_Second")
    RankImage2:setVisible(false)
    local RankImage3    = playerRanking:getChildByName("Icon_Third")
    RankImage3:setVisible(false)
    local RankImage4    = playerRanking:getChildByName("Icon_Last")
    RankImage4:setVisible(false)

    if nPlace == 1 then
        RankImage1:setVisible(true)
    elseif nPlace == 2 then        
        RankImage2:setVisible(true)
    elseif nPlace == 3 then        
        RankImage3:setVisible(true)
    elseif nPlace == 4 then        
        RankImage4:setVisible(true)
    end
end

function SKGamePlayer:showBomeSilverValue(value)
    if self._playerSilverValue then
        self._playerSilverValue:getParent():setVisible(true)
        self._playerSilverValue:setVisible(true)
        local Value_SilverAdd = self._playerSilverValue:getChildByName("Value_SilverAdd")
        local Value_SilverMinus = self._playerSilverValue:getChildByName("Value_SilverMinus")
        Value_SilverMinus:setVisible(false)
        Value_SilverAdd:setVisible(false)

        local csbPath = "res/GameCocosStudio/csb/Node_SilverValue.csb"
        local action = cc.CSLoader:createTimeline(csbPath)
        if value >= 0 then
            Value_SilverAdd:setVisible(true)
            Value_SilverAdd:setString("+"..tostring(value))
            action:play("animation_SilverAdd", false)
            self._playerSilverValue:runAction(action)
        else
            Value_SilverMinus:setVisible(true)           
            Value_SilverMinus:setString(tostring(value))
            action:play("animation_SilverMinus", false)
            self._playerSilverValue:runAction(action)
        end       
        local speed = action:getTimeSpeed()  

        local startFrame = action:getStartFrame()  
        local endFrame = action:getEndFrame()  
        local frameNum = endFrame - startFrame 
        local duration = 1.0 /(speed * 60.0) * frameNum

        local block = cc.CallFunc:create( function(sender)  
            Value_SilverMinus:setVisible(false)
            Value_SilverAdd:setVisible(false)
        end )  
 
        self._playerSilverValue:runAction(cc.Sequence:create(cc.DelayTime:create(duration+1), block))  
    end
end

function SKGamePlayer:showMemberIcon(soloPlayer)
    local memberIcon = self._playerInfoHead:getChildByName("Icon_Vip")
    memberIcon:setVisible(false)
end

-------------------------------------------------------
function SKGamePlayer:setLbs(nUserID,lbs)
    local label = lbsLabel[nUserID]
    printf("SKGamePlayer:setLbs %s", lbs)
    if label then
        local parent = label:getParent():getParent()
        if parent then
            label:setString(lbs)
            label:setVisible(true)
            parent:setVisible(true)
            lbsInfoTable[nUserID]=lbs
        end
    end
end

function SKGamePlayer:setPlayerHead(nUserID,path)
    if(path=="")then
        return
    end
    headPathTable[nUserID]=path
    printf("~~~~~~~~~~~~setPlayerHead id[%d] path[%s]~~~~~~~~~~~~~~~~~~~~~~~~",nUserID,path)
    if self._gameController:isGameRunning() then    
        return 
    end
--[[    
    local pic = headPic[nUserID]
    if(pic)then
        pic:loadTexture(path)
        pic:setContentSize(selfDefineHeadPicSize)
        pic:setVisible(true)
        headPathTable[nUserID]=path
    end
]]
end

function SKGamePlayer:showPlayerHeadImg(playerInfo)
    local imgHead = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Img_Player")
    if imgHead then

        local resName = ""
        local size = {}
        if headPathTable[playerInfo.nUserID] then
            size.height = selfDefineHeadPicSize.height - 15
            size.width =  selfDefineHeadPicSize.width -15          
            resName = headPathTable[playerInfo.nUserID]
        else
            size = selfDefineHeadPicSize
            --如果是自己的性别，确保与大厅保持一致
            local UserModel = mymodel('UserModel'):getInstance()
            local sexChecked = UserModel:getNickSexWithCheckSelf(playerInfo.nUserID, playerInfo.nNickSex )

            if sexChecked == 1 then
                resName = "res/Game/GamePic/GameContents/touxiang_girl.png"
            else
                resName = "res/Game/GamePic/GameContents/touxiang_boy.png"
            end
        end

        imgHead:loadTexture(resName)
        imgHead:setVisible(true)
    end
end

function SKGamePlayer:updataUserLevelInfo(msgLevelData)
    print(msgLevelData.nLevel)
    local BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(msgLevelData.nLevel)
    if self._drawIndex == 1 or msgLevelData.nLevel >= 25 then

        self._playerLevelImage:loadTexture(BGResName)
        self._playerLevelColor:loadTexture(ColorResName)
        self._playerLevelText:setString(levelString)

        self._playerLevelImage:setVisible(true)
    end

    local infoLevelImage = self._infoLevelImage
    local infoLevelColor = infoLevelImage:getChildByName("Img_LevelColor")
    local infoLevelText = infoLevelImage:getChildByName("Text_LevelNum")
    infoLevelImage:loadTexture(BGResName)
    infoLevelColor:loadTexture(ColorResName)
    infoLevelText:setString(levelString)
    infoLevelImage:setVisible(true)

    self._playerLevelData = clone(msgLevelData)

    if self._gameStart then
        self:onStartPlayToShowLevelAnimation()
    end
end

function SKGamePlayer:onStartPlayToShowLevelAnimation()
    local enterAni = self._playerNode:getChildByName("Node_Ani_Enter")
    if enterAni and self._playerLevelData and self._playerLevelData.nLevel >= 37 then
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Ani_Enter.csb")
        action:play("animation0", false)
        enterAni:runAction(action)
        enterAni:setVisible(true)
    end
    self._gameStart = true
end

function SKGamePlayer:onUpdateExchangeNum()
    if self._drawIndex == 1 and ExchangeCenterModel:getTicketNumData() then
        local exchangeText = self._selfExchangeBg:getChildByName("Text_ExchangeValue")
        exchangeText:setString(ExchangeCenterModel:getTicketNumData())
    end
end

function SKGamePlayer:showPlayerRoseBtn()
    local roseBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Rose")
    if roseBtn then
        if self._drawIndex == 1 then
            roseBtn:setVisible(false)
            
            local Attention = self._playerInfoPanel:getChildByName("Panel_Ani"):getChildByName("Attention")
            Attention:setVisible(true)
            return
        else
            local Attention = self._playerInfoPanel:getChildByName("Panel_Ani"):getChildByName("Attention")
            Attention:setVisible(false)
        end 
        local function dealRoseBtn()
            self:stopRoseTimer()

            self._canRoseBtn = true
        end

        local function onRosePlayer()

            if not cc.exports.isSafeBoxSupported() then
                if cc.exports.ExpressionInfo.nRoseNum and cc.exports.ExpressionInfo.nRoseNum <= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString="数量不足，请先从商城购买~", removeTime = 1}})
                    return
                end
            end

            if self._canTouchBtns then
                self._canTouchBtns = false
                my.scheduleOnce(function()
                    self._canTouchBtns = true
                    end, 0.5)
            else
                return
            end

            if not self._canRoseBtn then
                self._gameController:tipMessageByKey("G_GAME_LAHEI_TIME_TIP")
                return
            end

            self._canRoseBtn = false

            self:stopRoseTimer()
            self._RoseTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealRoseBtn, 3, false)

            if cc.exports.ExpressionInfo.nRoseNum and cc.exports.ExpressionInfo.nRoseNum <= 0 and not self:CheckSilver(ToolsSilver.Rose) then
                return
            end
            self:onBuyExpression(2)

            --17期客户端埋点
            --my.dataLink(cc.exports.DataLinkCodeDef.GAME_DOWN_ROSE_BTN)
        end
        roseBtn:addClickEventListener(onRosePlayer)
    end
end
function SKGamePlayer:showPlayerLightingBtn()
    local lightingBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Lighting")
    if lightingBtn then
        if self._drawIndex == 1 then
            lightingBtn:setVisible(false)
            return
        end 
        local function dealLightingBtn()
            self:stopLightingTimer()

            self._canLightingBtn = true
        end

        local function onLightingPlayer()
            
            if not cc.exports.isSafeBoxSupported() then
                if cc.exports.ExpressionInfo.nLightingNum and cc.exports.ExpressionInfo.nLightingNum <= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString="数量不足，请先从商城购买~", removeTime = 1}})
                    return
                end
            end

            if self._canTouchBtns then
                self._canTouchBtns = false
                my.scheduleOnce(function()
                    self._canTouchBtns = true
                    end, 0.5)
            else
                return
            end

            if not self._canLightingBtn then
                self._gameController:tipMessageByKey("G_GAME_LAHEI_TIME_TIP")
                return
            end
            
            self._canLightingBtn = false

            self:stopLightingTimer()
            self._LightingTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealLightingBtn, 3, false)

            if cc.exports.ExpressionInfo.nLightingNum and cc.exports.ExpressionInfo.nLightingNum <= 0 and not self:CheckSilver(ToolsSilver.Lighting) then
                return
            end
            self:onBuyExpression(1)

            --17期客户端埋点
            --my.dataLink(cc.exports.DataLinkCodeDef.GAME_DOWN_LGHTING_BTN)
        end
        lightingBtn:addClickEventListener(onLightingPlayer)
    end
end
function SKGamePlayer:stopUpTimer()
    if self._upTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._upTimer)
        self._upTimer = nil
    end
end
function SKGamePlayer:stopRoseTimer()
    if self._RoseTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._RoseTimer)
        self._RoseTimer = nil
    end
end
function SKGamePlayer:stopLightingTimer()
    if self._LightingTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._LightingTimer)
        self._LightingTimer = nil
    end
end

function SKGamePlayer:onBuyExpression(propID)
    self._gameController:onBuyExpression(self._drawIndex, propID)
    self:showPlayerInfo(false)
end

function SKGamePlayer:updataExpressionInfo()
    if not self._playerInfoPanel then
        return
    end

    local RoseBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Rose")
    if RoseBtn then
        if cc.exports.ExpressionInfo.nRoseNum and cc.exports.ExpressionInfo.nRoseNum > 0 then
            self:setToolsInfo(RoseBtn, cc.exports.ExpressionInfo.nRoseNum, ToolsSilver.Rose)
        else
            self:setToolsInfo(RoseBtn, 0, ToolsSilver.Rose)
        end
    end

    local LightingBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_Lighting")
    if LightingBtn then
        if cc.exports.ExpressionInfo.nLightingNum and cc.exports.ExpressionInfo.nLightingNum > 0 then
            self:setToolsInfo(LightingBtn, cc.exports.ExpressionInfo.nLightingNum, ToolsSilver.Lighting)
        else
            self:setToolsInfo(LightingBtn, 0, ToolsSilver.Lighting)
        end
    end
end

function SKGamePlayer:CheckSilver(silver)
    local user = mymodel('UserModel'):getInstance()
    if cc.exports.isSafeBoxSupported() then
        local nSafe = user.nSafeboxDeposit or 0
        if silver > nSafe then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString=self._gameController:getGameStringToUTF8ByKey("G_GAME_BUY_PROP_FAIL_ANDROID"),removeTime=2}})
            return false
        else
            return true
        end
    elseif cc.exports.isBackBoxSupported() then
        local nBack = user.nBackDeposit or 0
        if silver > nBack then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString=self._gameController:getGameStringToUTF8ByKey("G_GAME_BUY_PROP_FAIL_IOS"),removeTime=2}}) 
            return false
        else
            return true
        end
    end
    return true
end

function SKGamePlayer:setToolsInfo(btn, num, silver)
    local LeftImg = btn:getChildByName("LeftImg")
    local numText = btn:getChildByName("num")
    local silverImg = btn:getChildByName("silverImg")

    if cc.exports.isSafeBoxSupported() and num <= 0 then
        LeftImg:setVisible(false)
        numText:setVisible(false)
        silverImg:setVisible(true)
        silverImg:setSpriteFrame("GameCocosStudio/plist/Game_img/Silver_" .. silver ..".png")
    else
        LeftImg:setVisible(true)
        numText:setVisible(true)
        numText:setString(num)
        silverImg:setVisible(false)
    end
end

function SKGamePlayer:isRobot(userType)
    if not userType then return false end
    return bit.band(userType, 0x40000000) == 0x40000000 
end

function SKGamePlayer:showNobilityPrivilegeHead(soloPlayer)
    if not soloPlayer.nReserved or not soloPlayer.nReserved[2] then return end
    local nPlayerLevel = soloPlayer.nReserved[2]
    if self._drawIndex == 1 then --判断当前贵族等级是否大于进房间时的等级
        local level = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel()
        if level > soloPlayer.nReserved[2] then --此时就是游戏中充值，贵族等级上升
            print("show current level of privilege")
            nPlayerLevel = level
        end
    end
    if self:isRobot(soloPlayer.nUserType) then --是机器人
        if soloPlayer.nBout > 30 and soloPlayer.nBout <= 50 then
            nPlayerLevel = 1
        elseif soloPlayer.nBout > 50 and soloPlayer.nBout <= 100 then
            nPlayerLevel = 2
        elseif soloPlayer.nBout > 100 and soloPlayer.nBout <= 300 then
            nPlayerLevel = 3
        elseif soloPlayer.nBout > 300 and soloPlayer.nBout <= 500 then
            nPlayerLevel = 4
        elseif soloPlayer.nBout > 500 then
            nPlayerLevel = 5
        end
        local userID = soloPlayer.nUserID 
        if userID % 3 ~= 0 then
            nPlayerLevel = 0
        end
    end
    self:freshNobilityPrivilegeHead(nPlayerLevel)
end

--分离出来一个函数，用于
function SKGamePlayer:freshNobilityPrivilegeHead(nPlayerLevel)
    if not nPlayerLevel then return end   
    local memberIcon = self._playerInfoHead:getChildByName("Icon_Vip")
    if nPlayerLevel >= 0 then  --有贵族系统，不显示会员
        memberIcon:setVisible(false)
    end
    local nLevel = 0
    if nPlayerLevel >= 2 then
        if nPlayerLevel >= 15 then
            nLevel = 15
        elseif nPlayerLevel >= 12 then
            nLevel = 12
        elseif nPlayerLevel >= 10 then
            nLevel = 10
        elseif nPlayerLevel >= 7 then
            nLevel = 7
        elseif nPlayerLevel >= 5 then
            nLevel = 5
        elseif nPlayerLevel >= 2 then
            nLevel = 2
        end
        self._playerInfoHead:getChildByName("Panel_NobilityPrivilege"):setVisible(true)
        self._playerInfoHead:getChildByName("Panel_NobilityPrivilege"):getChildByName("Image_NobilityPrivilege"):loadTexture("res/Game/png/NobilityPrivilege/NobilityPrivilege_head"..nLevel..".png")
        self._playerInfoHead:getChildByName("Panel_NobilityPrivilege"):getChildByName("Text_NobilityPrivilege"):setString(nPlayerLevel)
        local aniFile = "res/hallcocosstudio/NobilityPrivilege/tx_kuang.csb"
        local aniNode = self._playerInfoHead:getChildByName("Panel_NobilityPrivilege"):getChildByName("Node_NobilityPrivilege")
        aniNode:stopAllActions()
        aniNode:removeAllChildren()
        local node = cc.CSLoader:createNode(aniFile)
        local action = cc.CSLoader:createTimeline(aniFile)
        aniNode:addChild(node)
        if not tolua.isnull(action) then
            node:runAction(action)
            action:play("animation0", true)
        end
    else
        self._playerInfoHead:getChildByName("Panel_NobilityPrivilege"):setVisible(false)
    end
end

--获取当前的点赞次数
function SKGamePlayer:getLastUpCount(userID)
    local day = os.date('%Y%m%d',os.time())
    local tbl = CacheModel:getCacheByKey("LastUpCount_HAGD_" .. day .. "_" .. userID)
    checktable(tbl)

    return tbl.upCount or 0
end

--设置当天点赞次数，只会增加不会减少
function SKGamePlayer:setLastUpCount(userID, count)
    local day = os.date('%Y%m%d',os.time())
    local tbl = CacheModel:getCacheByKey("LastUpCount_HAGD_" .. day .. "_" .. userID)
    checktable(tbl)
    tbl.upCount = tbl.upCount or 0
    if tbl.upCount > count then
        return
    end
    tbl.upCount = count
    CacheModel:saveInfoToCache("LastUpCount_HAGD_" .. day .. "_" .. userID, tbl)
end


return SKGamePlayer
