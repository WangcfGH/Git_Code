

local viewCreater=import('src.app.plugins.safebox.SafeboxView')
local SafeboxCtrl=class('SafeboxCtrl',cc.load('BaseCtrl'))
local NobilityPrivilegeModel = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel'):getInstance()
local NobilityPrivilegeDef = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')
local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()

local constStrings=cc.load('json').loader.loadFile('SafeboxStrings.json')

local player=mymodel('hallext.PlayerModel'):getInstance()

my.addInstance(SafeboxCtrl)

SafeboxCtrl.ctrlConfig = {
    ["pluginName"] = "SafeboxCtrl",
    ["isAutoRemoveSelfOnNoParent"] = true
}

function SafeboxCtrl:onCreate(params)
	params=checktable(params)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    if viewNode and player then
        if viewNode.closeBt then
	        self:bindDestroyButton(viewNode.closeBt)
        end
        if viewNode.saveDepositBt and viewNode.takeDepositBt then
            self:bindUserEventHandler(viewNode,{'saveDepositBt', 'takeDepositBt'})
        end
        if viewNode.allBtn then
            self:bindUserEventHandler(viewNode,{'allBtn'})
        end

	    self:bindProperty(player,'PlayerData',self,'PlayerSafeboxData')
	    self:listenTo(player,player.PLAYER_MOVE_SAFE_DEPOSIT_FAILED,handler(self,self.onMoveSafeDepositFailed))
	    self:listenTo(player,player.PLAYER_TRANSFER_DEPOSIT_FAILED,handler(self,self.onTransferDepositFailed))
        self:listenTo(player,player.PLAYER_SAFEBOX_OPERATION_SUCCEED,handler(self,self.onSafeBoxOperationSucceed))
	    self:listenTo(player,player.PLAYER_RNDKEY_UPDATED,handler(self,self.onGotRndKey))
	    self:listenTo(player,player.PLAYER_GET_RNDKEY_FAILED,handler(self,self.onGotRndKeyFailed))
        self:listenTo(NobilityPrivilegeModel, NobilityPrivilegeDef.NobilityPrivilegeInfoRet, handler(self, self.onNobilityPrivilegeInfoRet))

	    if(params.onUpdatePlayerData)then
		    params.onUpdatePlayerData()
	    else
		    player:update({'SafeboxInfo'})
	    end

        -- 银两富余窗口 退出后，弹出保险箱，此时自动填充存入 银两数目 add by wuym
        if params.takeDepositeNum and params.takeDepositeNum > 0 then  
            self._directSave = true 
            self._HallOrGame = params.HallOrGame
            self._takeDepositNum = params.takeDepositeNum
            self._gameController = params.gameController
            viewNode.depositAmoutInp:setString(params.takeDepositeNum);
        end
        if params.btnOutVisible == false then
            viewNode.takeDepositBt:setVisible(false)
        end

        --17期客户端埋点
        if next(params) == nil then  --表示直接点击，不是跳转
            self._NoParamTag = true
            my.dataLink(cc.exports.DataLinkCodeDef.HALL_SAFE_BOX_BTN)
        end
        self:setAddBtn(viewNode)

        self:freshNPLevelAndSaveCount()
    end
    
end

function SafeboxCtrl:setAddBtn(viewNode)
    local addBtns = {viewNode.addBtn1, viewNode.addBtn2, viewNode.addBtn3}
    local silvers = {5000, 10000, 50000}
    if cc.exports._gameJsonConfig.SafeBoxQuickAddSilver and cc.exports._gameJsonConfig.SafeBoxQuickAddSilver.add1 then
        silvers[1] = tonumber(cc.exports._gameJsonConfig.SafeBoxQuickAddSilver.add1)
        silvers[2] = tonumber(cc.exports._gameJsonConfig.SafeBoxQuickAddSilver.add2)
        silvers[3] = tonumber(cc.exports._gameJsonConfig.SafeBoxQuickAddSilver.add3)
    end

    for i,v in ipairs(addBtns) do
        v:getChildByName("siliver_text"):setString(silvers[i])
        v:addClickEventListener(function()
            my.playClickBtnSound()
            local deposit=viewNode.depositAmoutInp:getString()

            if deposit:len() == 0 then
                viewNode.depositAmoutInp:setString(silvers[i])
            elseif(checkint(checknumber(deposit))<0)then
                self:informPluginByName('TipPlugin',{tipString=constStrings['HLS_PLEASE_INPUT']})
            else
                local num = tonumber(deposit)+silvers[i]
                local totalNum = 99999999
                if num > totalNum then
                    num = totalNum
                    self:informPluginByName('TipPlugin',{tipString=constStrings['SAFEBOX_ADD_BTN']})
                end
                viewNode.depositAmoutInp:setString(num)
            end
        end)
    end

    viewNode.clearBtn:addClickEventListener(function()
            my.playClickBtnSound()
            viewNode.depositAmoutInp:setString("")
    end)
end
function SafeboxCtrl:setPlayerSafeboxData(data)
	local viewNode=self._viewNode
    if not data then return end
    printf("data.nSafeboxDeposit:"  ..data.nSafeboxDeposit)
    --printf("data.nBackDeposit:"  ..data.nBackDeposit)
    printf("data.nRemindDeposit:"  ..data.nRemindDeposit)
	viewNode.gameDepositAmountLb:setString(tostring(data.nDeposit or 0))
	local boxDeposit = nil
    if cc.exports.isSafeBoxSupported() then
        boxDeposit=tostring(data.nSafeboxDeposit or 0)
    else
        if cc.exports.isBackBoxSupported() then
            boxDeposit=tostring(data.nBackDeposit or 0)
        end
    end
    viewNode.safeboxDepositAmountLb:setString(boxDeposit)
end

function SafeboxCtrl:onMoveSafeDepositFailed(data)

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
			self:informPluginByName('TipPlugin',{tipString=tipString})
		end
		return
	end
	self:informPluginByName('TipPlugin',{tipString=tipString})
end

function SafeboxCtrl:onGotRndKeyFailed(data)
	local tipIdToStringMap={
		[mc.UR_OBJECT_NOT_EXIST]='HLS_OBJECT_NOT_EXIST',
	}
	local tipString=tipIdToStringMap[data.respondType]
	if(tipString~=nil)then
		tipString=constStrings[tipString]
	else
		tipString='respond id is '..mc.getIdMeaning(data.respondType)
	end
	self:informPluginByName('TipPlugin',{tipString=tipString})
end

function SafeboxCtrl:onTransferDepositFailed(data)

	local tipIdToStringMap={
		[mc.DEPOSIT_NOTENOUGH]='HLS_DEPOSIT_NOTENOUGH',
		[mc.UR_INVALID_PARAM]='HLS_SECUREPWD_KEY_ERROR',
		[mc.CONTINUE_PWDWRONG]='HLS_CONTINUE_SECUREPWDERROR_TAKEDEPOSIT',
		[mc.UR_OBJECT_NOT_EXIST]='HLS_CHECK_USER_NAME',
	}
	local tipString=tipIdToStringMap[data.respondType]
	local value=data.value
	if(tipString~=nil)then
		tipString=constStrings[tipString]
	elseif(data.respondType==mc.BOUT_NOTENOUGH)then
		tipString=string.format(constStrings['HLS_OUTPUT_BOUT_NOTENOUGH'],value.nMinBout)
	elseif(data.respondType==mc.TIMECOST_NOTENOUGH)then
		tipString=string.format(constStrings['HLS_OUTPUT_TIMECOST_NOTENOUGH'],value.nMinMinute)
	else
		tipString='respond id is '..mc.getIdMeaning(data.respondType)
		return
	end
	self:informPluginByName('TipPlugin',{tipString=tipString})
end

function SafeboxCtrl:onSafeBoxOperationSucceed()
    self:removeSelfInstance()
end

----------------------
--save money to safebox
--
function  SafeboxCtrl:safeDepositInHallOrGame()
    -- 分大厅银两富余弹窗 和  游戏场内银两富余弹窗。 目的为了游戏场内不出现  正在玩的游戏不能划账
    local viewNode=self._viewNode
	local deposit=viewNode.depositAmoutInp:getString()
	if(not deposit:gfind('%d')())then
		viewNode.depositAmoutInp:setString('')
	end
	if(deposit:len()==0 or checkint(checknumber(deposit))<=0)then
		self:informPluginByName('TipPlugin',{tipString=constStrings['HLS_PLEASE_INPUT']})
        return
    else
        local user=mymodel('UserModel'):getInstance()
        local nLeftDeposit = user.nDeposit - tonumber(deposit)
        local minDeposit = cc.exports.GetPlayerMinDeposit()
        if nLeftDeposit < minDeposit then  -- 外网有至少携带v两限制
            local tips = string.format(constStrings['SAFEBOX_USER_DEPOSIT_MUST_KEEP'], minDeposit)
            self:informPluginByName('TipPlugin',{tipString=tips})
            return 
        end
    end

    if DEBUG > 0 then
		print("SafeboxCtrl:safeDepositInHallOrGame++++++++++++++++++++++++++++++++++++++++++++++++++",self._HallOrGame, deposit)
	end
    
    self._gameController.m_SaveDepositNum = deposit
    if self._HallOrGame then
        self._gameController:playEffectOnPress()

        local player=mymodel('hallext.PlayerModel'):getInstance()
		player:transferSafeDeposit(deposit)
    else
        if self._gameController then
            self._gameController:playBtnPressedEffect()
            self._gameController:onSaveDeposit(deposit)
            self:removeSelfInstance()
        end
    end
    return
end

function SafeboxCtrl:saveDepositBtClicked()
    if isSafeboxSaveFuncEnableLimit() then
        local selfNPLevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel()
        local npLevelLimit = cc.exports.getSafeboxNPLevelLimit()
        if selfNPLevel < npLevelLimit then
            local tipString = '贵族' .. tostring(npLevelLimit) .. '开启存银权限，赶紧提升贵族等级吧~'
            local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
            local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
            local rechargedTotal = nobilityPrivilegeInfo.rechargeTotal
            
            local payItem = nil
    
            if npLevelLimit <= #(nobilityPrivilegeConfig.nobilityLevelList) then
                local nExperienceTotal = nobilityPrivilegeConfig.nobilityLevelList[npLevelLimit + 1].experienceTotal
                local ShopModel = mymodel('ShopModel'):getInstance()
                local needCharge = nExperienceTotal - rechargedTotal
                local shopItemList = ShopModel:GetShopItemsInfo()
        
                if shopItemList and #shopItemList > 0 then
                    for _, item in pairs(shopItemList) do
                        if item.producttype == 1 then
                            if item.price > needCharge then
                                if payItem == nil then
                                    payItem = item
                                else
                                    if payItem.price > item.price then
                                        payItem = item
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if payItem then
                local okBtTitle = tostring(payItem.price) .. '元升级'
                my.informPluginByName({pluginName = "SureDialog", 
                params = {
                    tipContent = tipString,
                    okBtTitle = okBtTitle,
                    closeBtVisible = true,
                    onOk = function()
                        local ShopModel = mymodel('ShopModel'):getInstance()
                        ShopModel:PayForProduct(payItem)
                    end,
                }})
            else
                my.informPluginByName({pluginName = "SureDialog", params = { tipContent = tipString, closeBtVisible = true }})
            end
    
            return
        end
    
        if not SafeboxModel:isSaveTimesEnough() then
            local tipString = '当日存银次数已达上限，请明天再存银吧~'
            my.informPluginByName({pluginName = "SureDialog", params = { tipContent = tipString, }})
            return
        end
    
        if not SafeboxModel:isSaveCountEnough() then
            local tipString = '当日存银数量已达上限，请明天再存银吧~'
            my.informPluginByName({pluginName = "SureDialog", params = { tipContent = tipString, }})
            return
        end
    end

    if self._directSave then
        print("SafeboxCtrl:saveDepositBtClicked   self._directSave = ",self._directSave)
        return self:safeDepositInHallOrGame()
    end

    if not self._canclick then
        self:informPluginByName('TipPlugin',{tipString=constStrings['SAFEBOX_USE_TOO_FAST']})
        return
    end
    self:setSchedule()

	print('save clicked')
	local viewNode=self._viewNode
	local deposit=viewNode.depositAmoutInp:getString()
	if(not deposit:gfind('%d')())then
		viewNode.depositAmoutInp:setString('')
	end
	if(deposit:len()==0 or checkint(checknumber(deposit))<=0)then
		self:informPluginByName('TipPlugin',{tipString=constStrings['HLS_PLEASE_INPUT']})
	else
		player:transferSafeDeposit(deposit)
	end

    --17期客户端埋点
    if self._NoParamTag then
        my.dataLink(cc.exports.DataLinkCodeDef.HALL_SAFE_BOX_IN_BTN)
    end
end

----------------------
--take money from safebox
--
function SafeboxCtrl:takeDepositBtClicked()
    if not self._canclick then
        self:informPluginByName('TipPlugin',{tipString=constStrings['SAFEBOX_USE_TOO_FAST']})
        return
    end
    self:setSchedule()

	print('take clicked')
	local viewNode=self._viewNode
	local deposit=viewNode.depositAmoutInp:getString()
	if(not deposit:gfind('%d')())then
		viewNode.depositAmoutInp:setString('')
	end

    if DEBUG > 0 then
		print("SafeboxCtrl:takeDepositBtClicked++++++++++++++++++++++++++++++++++++++++++++++++++",self._canclick, deposit, cc.exports.isSafeBoxSupported())
    end

    if(deposit:len()==0 or checkint(checknumber(deposit))<=0)then
        self:informPluginByName('TipPlugin',{tipString=constStrings['HLS_PLEASE_INPUT']})
    else
        if cc.exports.isSafeBoxSupported() then
            if(player:isSafeboxHasSecurePwd() and not player:hasSafeboxGotRndKey())then
                self:informPluginByName('SafeboxPswPlaneCtrl',{})
            else
                player:moveSafeDeposit(deposit)
            end
        else
            if cc.exports.isBackBoxSupported() then
                player:moveSafeDeposit(deposit)
            end
        end
    end

    --17期客户端埋点
    if self._NoParamTag then
        my.dataLink(cc.exports.DataLinkCodeDef.HALL_SAFE_BOX_OUT_BTN)
    end
end

function SafeboxCtrl:allBtnClicked()
    local playerData = player:getPlayerData()
    local allDeposits = 0
    if playerData and type(playerData.nSafeboxDeposit) == 'number' then
        allDeposits = playerData.nSafeboxDeposit
    end
    local viewNode = self._viewNode
    if viewNode and viewNode.depositAmoutInp then
        viewNode.depositAmoutInp:setString(tostring(allDeposits))
    end
    if allDeposits <= 0 then
        return
    end
    self:takeDepositBtClicked()
end

function SafeboxCtrl:onGotRndKey(data)
	self:takeDepositBtClicked()
end

function SafeboxCtrl:goShoppingBtClicked( ... )
	print('goto deposit clicked')
end

function SafeboxCtrl:onEnter()
    self._canclick = true
    --self:setSchedule()
end

function SafeboxCtrl:setSchedule()
    if self._clickUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._clickUpdate)
        self._clickUpdate = nil
    end
    local function onClickSafeBox(dt)
        self:onClickSafeBox()
    end
    self._canclick = false
    self._clickUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onClickSafeBox, 1.0, false)
end

function SafeboxCtrl:onClickSafeBox()
    if not self._canclick then
        self._canclick = true
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._clickUpdate)
        self._clickUpdate = nil
    end
end

function SafeboxCtrl:onExit()
    if self._clickUpdate then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._clickUpdate)
        self._clickUpdate = nil
    end
end

function SafeboxCtrl:freshNPLevelAndSaveCount()
    local viewNode = self._viewNode
    if isSafeboxSaveFuncEnableLimit() then
        local npLevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel()
        viewNode.valueNPLevel:setString('贵族' .. tostring(npLevel))

        local saveTimes = SafeboxModel:getSaveTimes()
        local saveTimesLimit = cc.exports:getSafeboxSaveTimesLimit()
        viewNode.valueSaveCount:setString(tostring(saveTimes) .. '/' .. tostring(saveTimesLimit))

        viewNode.textNPLevel:setVisible(true)
        viewNode.valueNPLevel:setVisible(true)
        viewNode.textSaveCount:setVisible(true)
        viewNode.valueSaveCount:setVisible(true)
    else
        viewNode.textNPLevel:setVisible(false)
        viewNode.valueNPLevel:setVisible(false)
        viewNode.textSaveCount:setVisible(false)
        viewNode.valueSaveCount:setVisible(false)
    end
end

function SafeboxCtrl:onNobilityPrivilegeInfoRet()
    self:freshNPLevelAndSaveCount()
end

return SafeboxCtrl
