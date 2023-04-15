
local MyGamePromptMoreMoney = class("MyGamePromptMoreMoney", ccui.Layout)
--local localRoomModelManager =  require("src.app.plugins.roomspanel.RoomListModel")
local localGamePublicInterface = require("src.app.Game.mMyGame.GamePublicInterface")
--local RoomsView =  require("src.app.plugins.myroomspanel.MyRoomsView")
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local UserModel = mymodel('UserModel'):getInstance()

function MyGamePromptMoreMoney:ctor(gameController, takeDepositNum, HallOrGame, directSave)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController
    self._HallOrGame        = HallOrGame        --大厅还是游戏中，true 是大厅
    self._PromptPanel           = nil
    self.m_takeDepositNum       = takeDepositNum
    self._DirectSave            = directSave    -- 是否显示 保险箱按钮，并直接存银self.m_takeDepositNum

    if self.onCreate then self:onCreate() end
end

function MyGamePromptMoreMoney:onCreate()
    self:init()
end

function MyGamePromptMoreMoney:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_MoreSilver.csb"
    
    self._PromptPanel = cc.CSLoader:createNode(csbPath)
    if self._PromptPanel then
        self:addChild(self._PromptPanel)
        SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel"))
        my.presetAllButton(self._PromptPanel)

        local panelPrompt = self._PromptPanel:getChildByName("Panel_Prompt_Quit")
        if panelPrompt then
            if not tolua.isnull(panelPrompt) then
				panelPrompt:setVisible(true)
				panelPrompt:setScale(0.6)
				panelPrompt:setOpacity(255)
				local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
				local scaleTo2 = cc.ScaleTo:create(0.09, 1)

				local ani = cc.Sequence:create(scaleTo1, scaleTo2)
				panelPrompt:runAction(ani)
			end
            local Btn_Pay = panelPrompt:getChildByName("Btn_Pay")
            local function onGoToRoom()
                self:onGoToRoom()
            end
            Btn_Pay:addClickEventListener(onGoToRoom)
            Btn_Pay:setTouchEnabled(true)
            Btn_Pay:setBright(true)
            self._btnGotoRoom = Btn_Pay

            local Btn_Safe = panelPrompt:getChildByName("Btn_Safe")
            local function onSafe()
                self:onSafe()
            end
            Btn_Safe:addClickEventListener(onSafe)

            local Btn_Close = panelPrompt:getChildByName("Btn_Close")
            local function onClose()
                self:onClose()
            end
            Btn_Close:addClickEventListener(onClose)
            self._closeBtn = Btn_Close

            local Btn_Store = panelPrompt:getChildByName("Btn_Store")
            Btn_Store:addClickEventListener(onSafe)

            local showSafeBox = true
            if cc.exports.isSafeBoxSupported() then
                Btn_Safe:setVisible(true)
                Btn_Store:setVisible(false)
            elseif cc.exports.isBackBoxSupported() then
                Btn_Safe:setVisible(false)
                Btn_Store:setVisible(true)
            else
                showSafeBox = false
                Btn_Safe:setVisible(false)
                Btn_Store:setVisible(false)
                panelPrompt:getChildByName('infoBg_right'):setVisible(false)

                local size = panelPrompt:getContentSize()

                Btn_Pay:setPositionX(size.width / 2)
                panelPrompt:getChildByName('infoBg_left'):setPositionX(size.width / 2)
                panelPrompt:getChildByName('Text_PromptWord_Pay'):setPositionX(size.width / 2)

            end

            local btnBgRight = panelPrompt:getChildByName("infoBg_right")
            local btnBgLeft = panelPrompt:getChildByName("infoBg_left")

            if not self._HallOrGame then
                local isTeamGame = false
                if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then               
                    Btn_Pay:setTouchEnabled(false)
                    Btn_Pay:setBright(false)

                    isTeamGame = true
                end

                local uitleInfoManager  = self._gameController:getUtilsInfoManager()
                local nRoomID         = uitleInfoManager:getRoomID()
                local roomImpl = RoomListModel.roomsInfo[nRoomID]
                --[[local bFind=false
                for i,v in ipairs( cc.exports.RoomModelList )do
                    for j,k in ipairs(v.RoomList)do
                        local Impl = k.original
                        if Impl then
                            if Impl.nRoomID == nRoomID then
                                roomImpl = Impl
                                bFind = true
                                break
                            end
                        end
                    end
                    if bFind then
                        break
                    end
                end]]--
                --[[if roomImpl.nMinDeposit <= 500 then
                    Btn_Safe:setTouchEnabled(false)
                    Btn_Safe:setBright(false)
                end
                if isTeamGame and roomImpl.nMinDeposit <= 500 then
                    Btn_Safe:setTouchEnabled(true)
                    Btn_Safe:setBright(true)
                end]]
                local gameplayer = self._gameController:getPlayerInfoManager()
                local nSelfDeposit = gameplayer:getSelfDeposit()
                local leftDeposit = cc.exports.GetPlayerMinDeposit()

                if nSelfDeposit > leftDeposit then
                    local needTakeNumByConfig = nSelfDeposit - leftDeposit  -- 根据gameconfig.json配置里最低银计算出 要存入多少银两
                    if needTakeNumByConfig <= 0 then
                        needTakeNumByConfig = nSelfDeposit - roomImpl.nMaxDeposit
                    end
                    
                    local needTakeNum = math.min(needTakeNumByConfig, self.m_takeDepositNum)
                    self.m_takeDepositNum = needTakeNum
                    self._gameController.m_SaveDepositNum = needTakeNum
                end
            end -- End if not self._HallOrGame then

            local fitRoomInfo, isNoFitRoom = RoomListModel:findFitRoomByDepositEx(UserModel.nDeposit, nil, UserModel.nSafeboxDeposit)
            if fitRoomInfo == nil or isNoFitRoom == true then
                self._DirectSave = true --如果没找到目标房间，则无法显示跳转
                self:setGotoRoomBtnState(false)
            end

            local roomNameSecond = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_SECOND")        -- 初级房
            local roomNameThird = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_THIRD")          -- 中级房
            local roomNameFourth = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_FOURTH")        -- 高级房
            local roomNameFiveth = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_FIVETH")        -- 大师房
            local roomNameSixth = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_SIXTH")          -- 至尊房
            local roomNameSeventh = cc.exports.GamePublicInterface:getGameString("G_GAME_ROOMNAME_SEVENTH")      -- 宗师房
                
            local text_PromptWord_Pay = panelPrompt:getChildByName("Text_PromptWord_Pay")

            if true == self._DirectSave then -- 目前仅竞技场里银两富余直接显示 保险箱存银 按钮
                local Word = panelPrompt:getChildByName("Text_PromptWord")

                local tipString
                if cc.exports.isSafeBoxSupported() then
                    tipString = string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_SAVE_SILVER_TIP"), self.m_takeDepositNum)
                else
                    tipString = self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_SAVE_SILVER_TIP_NOSAFEBOX")
                end
                Word:setString(tipString)

                local imgPath = "img_text_seniorroom"
                local jumpRoomName = (fitRoomInfo or {}).szRoomName or ""
                if jumpRoomName ==  MCCharset:getInstance():gb2Utf8String(roomNameSecond, string.len(roomNameSecond) )then
                    imgPath = "img_text_chujiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameThird, string.len(roomNameThird)) then
                    imgPath = "img_text_zhongjiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFourth, string.len(roomNameFourth)) then
                    imgPath = "img_text_seniorroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFiveth, string.len(roomNameFiveth)) then
                    imgPath = "img_text_dashiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSixth, string.len(roomNameSixth)) then
                    imgPath = "img_text_zhizhunroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSeventh, string.len(roomNameSeventh)) then
                    imgPath = "img_text_zongshiroom"
                else
                    imgPath = "img_text_seniorroom"
                end
                text_PromptWord_Pay:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_JUMP_TO"), jumpRoomName))
                local img = Btn_Pay:getChildByName(imgPath)
                if img then
                    img:setVisible(true)
                end
            else
                local Word = panelPrompt:getChildByName("Text_PromptWord")
                Word:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_ENOUGH_SILVER_JUMP_TIP")))
                -- 2018年5月15日 需求变更：为了促进玩家跳转高级房，隐藏掉保险箱存银入口。
                Btn_Safe:setVisible(false)
                btnBgRight:setVisible(false)
                local posX, posY = Btn_Pay:getPosition()
                
                if showSafeBox then
                    text_PromptWord_Pay:setPositionX(posX + 150)
                    btnBgLeft:setPositionX(posX + 150)
                end

                -- 增加了不洗牌大房间后，需要通过该接口获取 相应大房间里 子房间列表
            	--local roomlist = RoomsView:GetCurrentSecondGradeRoomsList()
                --local jumpRoomID, noJumpRoom = localGamePublicInterface:getQuickStartRoomID(roomlist)
                --local fitRoomInfo, isNoFitRoom = RoomListModel:findFitRoomByDeposit(UserModel.nDeposit)
                if cc.exports.PUBLIC_INTERFACE.IsStartAsArenaPlayer() or true == isNoFitRoom then
                    -- 说明银两超出一千万，没找到有更高级的房间了 或者 竞技场，只能存银了
                    Word:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_ENOUGH_SILVER_TO_SAVE")))
                    text_PromptWord_Pay:setVisible(false)
                    Btn_Safe:setVisible(true)
                    btnBgRight:setVisible(true)
                    Btn_Pay:setVisible(false)
                    btnBgLeft:setVisible(false)
                    Btn_Safe:setPositionX(posX + 150)
                    btnBgRight:setPositionX(posX + 150)
                    return
                end

                local jumpRoomName = fitRoomInfo["gradeNameZh"]
                --[[for i = 1, #roomlist do
                    local roomImpl = roomlist[i].original

                    if roomImpl and roomImpl.nRoomID == jumpRoomID then
                         jumpRoomName = roomImpl.szRoomName
                         break
                    end
                end]]--
                --jumpRoomName = MCCharset:getInstance():gb2Utf8String( jumpRoomName, string.len(jumpRoomName) )
                local str = string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_JUMP_TO"), jumpRoomName)
                text_PromptWord_Pay:setString(str) 

                local imgPath = ""
                local isShowJumpButton = false

                --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/common/common_btn.plist")
                --local path = 'res/common/common_btn/'
                if DEBUG and DEBUG == 1 then
                    print("MyGamePromptMoreMoney: jumpRoomName", jumpRoomName)
                end
                if jumpRoomName ==  MCCharset:getInstance():gb2Utf8String(roomNameSecond, string.len(roomNameSecond) )then
                    isShowJumpButton = true
                    imgPath = "img_text_chujiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameThird, string.len(roomNameThird)) then
                    isShowJumpButton = true
                    imgPath = "img_text_zhongjiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFourth, string.len(roomNameFourth)) then
                    isShowJumpButton = true
                    imgPath = "img_text_seniorroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFiveth, string.len(roomNameFiveth)) then
                    isShowJumpButton = true
                    imgPath = "img_text_dashiroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSixth, string.len(roomNameSixth)) then
                    isShowJumpButton = true
                    imgPath = "img_text_zhizhunroom"
                elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSeventh, string.len(roomNameSeventh)) then
                    isShowJumpButton = true
                    imgPath = "img_text_zongshiroom"
                else
                    isShowJumpButton = true
                    text_PromptWord_Pay:setString("跳转至高级房!")
                    imgPath = "img_text_seniorroom"
                end
                if true == isShowJumpButton then
                    if showSafeBox then
                        Btn_Pay:setPositionX(posX + 150)
                        btnBgLeft:setPositionX(posX + 150)
                        btnBgRight:setVisible(false)
                    end
                    -- Btn_Pay:setPositionX(posX + 150)
                    -- btnBgRight:setVisible(false)
                    -- btnBgLeft:setPositionX(posX + 150)
                    --Btn_Pay:loadTextureNormal(imgPath, 1) --永远显示高级房
                    local img = Btn_Pay:getChildByName(imgPath)
                    if img then
                        --img:loadTexture(imgPath,1)
                        img:setVisible(true)
                    end
                end
            end
        end
    end

    -- local action = cc.CSLoader:createTimeline(csbPath)
    -- if action then
    --     self._PromptPanel:runAction(action)
    --     action:gotoFrameAndPlay(1,10 , false)
    -- end
end

function MyGamePromptMoreMoney:setGotoRoomBtnState(state)
    if self._btnGotoRoom then
        self._btnGotoRoom:setTouchEnabled(state)
        self._btnGotoRoom:setBright(state)
    end
end

function MyGamePromptMoreMoney:onClose()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
    end

    if cc.exports.isSafeBoxSupported() then
        my.informPluginByName({pluginName='SafeboxCtrl', params={takeDepositeNum=self.m_takeDepositNum, btnOutVisible=false, HallOrGame=self._HallOrGame, gameController = self._gameController}})
    end

    self:removeFromParentAndCleanup()
end

function MyGamePromptMoreMoney:onCloseEx()
    self:removeFromParentAndCleanup()
    if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
        cc.exports.GamePublicInterface._gameController:onExitGameClicked()
    end
end

function MyGamePromptMoreMoney:onGoToRoom()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
        --[[local MainCtrl          = require('src.app.plugins.mainpanel.MainCtrl')
        MainCtrl:JumpRoomInCurrentArea(nil)]]--
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    else
        self._gameController:playBtnPressedEffect()
        self._gameController._gotoHighRoom = true
        self._gameController._baseGameConnect:gc_LeaveGame()
        --[[my.scheduleOnce(function()
            local MainCtrl          = require('src.app.plugins.mainpanel.MainCtrl')
            MainCtrl:quickStartBtClicked(nil)         
        end, 0.6)]]
    end

    self:removeFromParentAndCleanup()
end

function MyGamePromptMoreMoney:onSafe()
    print("MyGamePromptMoreMoney:onSafe() _HallOrGame "..tostring(self._HallOrGame))
    if self._HallOrGame then
        self._gameController:playEffectOnPress()

        local player=mymodel('hallext.PlayerModel'):getInstance()
		player:transferSafeDeposit(self.m_takeDepositNum)
    else
        self._gameController:playBtnPressedEffect()
        self._gameController:onSaveDeposit(self.m_takeDepositNum)
    end

    self:removeFromParentAndCleanup()
end

function MyGamePromptMoreMoney:updateSaveDeposit(roomID)
    local nRoomID = roomID
    local roomImpl = RoomListModel.roomsInfo[roomID]
    --[[local bFind=false
    for i,v in ipairs( cc.exports.RoomModelList )do
        for j,k in ipairs(v.RoomList)do
            local Impl = k.original
            if Impl then
                if Impl.nRoomID == nRoomID then
                    roomImpl = Impl
                    bFind = true
                    break
                end
            end
        end
        if bFind then
            break
        end
    end]]--
    
    local nSelfDeposit = UserModel.nDeposit
    local leftDeposit = cc.exports.GetPlayerMinDeposit()
    if nSelfDeposit > leftDeposit then
        self.m_takeDepositNum = nSelfDeposit - leftDeposit
        if self.m_takeDepositNum <= 0 then
            self.m_takeDepositNum = nSelfDeposit - roomImpl.nMaxDeposit
        end
    end
    
    local panelPrompt = self._PromptPanel:getChildByName("Panel_Prompt_Quit")
    local Word = panelPrompt:getChildByName("Text_PromptWord")
    --Word:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_SAVE_SILVER_TIP"), self.m_takeDepositNum))
    Word:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_PROMPT_ENOUGH_SILVER_JUMP_TIP")))
end

return MyGamePromptMoreMoney
