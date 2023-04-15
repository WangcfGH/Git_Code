
local MyGamePromptGoBackRoom = class("MyGamePromptGoBackRoom", ccui.Layout)

local player=mymodel('hallext.PlayerModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(MyGamePromptGoBackRoom,PropertyBinder)

function MyGamePromptGoBackRoom:ctor(gameController, needReturnRoomID, takeDepositNum)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController
    self._PromptPanel           = nil
    self.needReturnRoomID        = needReturnRoomID
    self.m_takeDepositNum = takeDepositNum

    self._HallOrGame = true
    if self._HallOrGame then
	    self:listenTo(player,player.PLAYER_RNDKEY_UPDATED,handler(self,self.onGotRndKey))
	    self:listenTo(player,player.PLAYER_MOVE_SAFE_DEPOSIT_FAILED,handler(self,self.onMoveSafeDepositFailed))
        self:listenTo(player,player.PLAYER_SAFEBOX_OPERATION_SUCCEED,handler(self,self.onSafeBoxOperationSucceed))
    end

    if self.onCreate then self:onCreate() end
end

function MyGamePromptGoBackRoom:onCreate()
    self:init()
end

function MyGamePromptGoBackRoom:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_GoBack.csb"
    
    self._PromptPanel = cc.CSLoader:createNode(csbPath)
    if self._PromptPanel then
        self:addChild(self._PromptPanel)
        SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel"))
        my.presetAllButton(self._PromptPanel)

        local panelPrompt = self._PromptPanel:getChildByName("Panel_Prompt_GoBack")
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
            local function onPay()
                self:onPay()
            end
            Btn_Pay:addClickEventListener(onPay)

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

            local Btn_Store = panelPrompt:getChildByName("Btn_Store")
            Btn_Store:addClickEventListener(onSafe)
            if cc.exports.isSafeBoxSupported() then
                Btn_Safe:setVisible(true)
                Btn_Store:setVisible(false)
            elseif cc.exports.isBackBoxSupported() then
                Btn_Safe:setVisible(false)
                Btn_Store:setVisible(true)
            end

            if self.m_takeDepositNum < 0 then
                Btn_Store:setTouchEnabled(false)
                Btn_Store:setBright(false)
                Btn_Safe:setTouchEnabled(false)
                Btn_Safe:setBright(false)
                
                local playerInfoManager = self._gameController:getPlayerInfoManager()
                local playerDeposit = 0
                if playerInfoManager then
                    local playerInfo = playerInfoManager:getPlayerInfo(self:getMyDrawIndex())
                    playerDeposit = playerInfo.nDeposit
                end
                --local returnRoomInfo = cc.exports.getRoomInfoForRoomID(self.needReturnRoomID)
                local returnRoomInfo = RoomListModel.roomsInfo[self.needReturnRoomID]

                local Word = panelPrompt:getChildByName("Text_PromptWord")
                Word:setString(string.format(Word:getString(), returnRoomInfo.nMinDeposit - playerDeposit))
            else
                local Word = panelPrompt:getChildByName("Text_PromptWord")
                Word:setString(string.format(Word:getString(), self.m_takeDepositNum))
            end
        end
    end

    if(self._PromptPanel.registerScriptHandler)then
		self._PromptPanel:registerScriptHandler(function(event)
			if event == "enter" then
				--self:onEnter()
			elseif event == 'exit' then
				self:onExit()
			elseif event == "enterTransitionFinish" then
				--self:onEnterTransitionDidFinish()
			end
		end)
	end

    -- local action = cc.CSLoader:createTimeline(csbPath)
    -- if action then
    --     self._PromptPanel:runAction(action)
    --     action:gotoFrameAndPlay(1,10 , false)
    -- end
end

function MyGamePromptGoBackRoom:onClose()
    self._gameController:playBtnPressedEffect()
    self._gameController:KeepCurrentRoom()
    
    self._gameController._baseGameScene._GoBackRoomPrompt = nil
    self._gameController._PayCallbackNeedGobackRoomID = nil

    self:removeEventHosts()
    self:removeFromParentAndCleanup()
end


function MyGamePromptGoBackRoom:onPay()
    self._gameController:playBtnPressedEffect()
    self._gameController:OnGetItemInfo(self.needReturnRoomID)
    self._gameController._PayCallbackNeedGobackRoomID = self.needReturnRoomID
    
    --self:removeEventHosts()
    --self:removeFromParentAndCleanup()
end

function MyGamePromptGoBackRoom:onSafe()
    if self._HallOrGame then
        self._gameController:playBtnPressedEffect()

        if(player:isSafeboxHasSecurePwd() and not player:hasSafeboxGotRndKey())then
		    my.informPluginByName('SafeboxPswPlaneCtrl',{})
	    else
		    player:moveSafeDeposit(self.m_takeDepositNum)
        end
        return
    else
        if self._gameController.m_nHaveSecurePwd and self._gameController.m_nHaveSecurePwd ~= 0 then
            self._gameController:tipMessageByKey("G_GAME_SAFEBOX_HAVE_KEY")
        else
            self._gameController:playBtnPressedEffect()
            self._gameController:onTakeDeposit(self.m_takeDepositNum, 0)
        end
    end
    self._gameController._baseGameScene._GoBackRoomPrompt = nil
    self._gameController._PayCallbackNeedGobackRoomID = nil

    self:removeEventHosts()
    self:removeFromParentAndCleanup()
end

function MyGamePromptGoBackRoom:onSafeBoxOperationSucceed()
    if self and self._gameController then
        self._gameController:GoBackRoom(self.needReturnRoomID)
    
        self._gameController._baseGameScene._GoBackRoomPrompt = nil
        self._gameController._PayCallbackNeedGobackRoomID = nil

        self:removeEventHosts()
        self:removeFromParentAndCleanup()
    end
end

function MyGamePromptGoBackRoom:onGotRndKey(data)
	player:moveSafeDeposit(self.m_takeDepositNum)
end

local constStrings=cc.load('json').loader.loadFile('SafeboxStrings.json')
function MyGamePromptGoBackRoom:onMoveSafeDepositFailed(data)

	local tipIdToStringMap={
		[mc.DEPOSIT_NOTENOUGH]='HLS_MOVESAFEDEPOSIT_NOTENOUGH',
		[mc.UR_INVALID_PARAM]='HLS_SECUREPWD_KEY_ERROR',
		[mc.CONTINUE_PWDWRONG]='HLS_CONTINUE_SECUREPWDERROR_TAKEDEPOSIT',
		[mc.UR_OBJECT_NOT_EXIST]='HLS_CHECK_USER_NAME',
	}
	local tipString=tipIdToStringMap[data.respondType]
	local value=data.value
	if(tipString~=nil)then
		tipString=constStrings[tipString]
	elseif(data.respondType==mc.INPUTLIMIT_DAILY)then
		local nRemain=value.nTransferLimit-value.nTransferTotal
		tipString=string.format(constStrings['HLS_INPUTLIMIT_DAILY'],value.nTransferLimit,nRemain)
	elseif(data.respondType==mc.BOUT_NOTENOUGH)then
		tipString=string.format(constStrings['HLS_OUTPUT_BOUT_NOTENOUGH'],value.nMinBout)
	elseif(data.respondType==mc.TIMECOST_NOTENOUGH)then
		tipString=string.format(constStrings['HLS_OUTPUT_TIMECOST_NOTENOUGH'],value.nMinMinute)
	else
		tipString='respond id is '..mc.getIdMeaning(data.respondType)
		if(DEBUG>2)then
			self._gameController:informPluginByName('TipPlugin',{tipString=tipString})
		end
		return
	end
	self._gameController:informPluginByName('TipPlugin',{tipString=tipString})
end

function MyGamePromptGoBackRoom:onExit()
    self._gameController._baseGameScene._GoBackRoomPrompt = nil
    self._gameController._PayCallbackNeedGobackRoomID = nil
    self:removeEventHosts()
end

return MyGamePromptGoBackRoom
