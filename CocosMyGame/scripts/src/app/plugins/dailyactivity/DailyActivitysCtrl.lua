
local viewCreater=import('src.app.plugins.dailyactivity.DailyActivitysView')
local DailyActivitysCtrl=class('DailyActivitysCtrl',cc.load('BaseCtrl'))
local relief=mymodel('hallext.ReliefActivity'):getInstance()
local checkin=mymodel('hallext.CheckinActivity'):getInstance()
local user=mymodel('UserModel'):getInstance()

local constStrings=cc.load('json').loader.loadFile('DailyActivitysStrings.json')
--local LoginLotteryCtrl = import("src.app.plugins.loginlottery.LoginLotteryCtrl")
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel")

function DailyActivitysCtrl:onCreate( ... )
    print("DailyActivitysCtrl:onCreate relief.state cc.exports.isReliefSupported()",relief.state,cc.exports.isReliefSupported())
    if not relief.state then  --防止ios上PLAYER_DATA_UPDATED消息没有响应，点击时重新获取一下
        if cc.exports.isReliefSupported() then
           print("DailyActivitysCtrl:onCreate queryConfig ")
           relief:queryConfig()
        end
    end

	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

	self:bindDestroyButton(self._viewNode.closeBt)

	local moduleList={
--		checkinCtrl='CheckinCtrl',
        checkinCtrl='LoginLotteryCtrl',
		reliefCtrl='ReliefCtrl',
		shareCtrl='ShareCtrl',
	}

	local bindList={
		'checkin',
		'relief',
		'share',
	}

	--[[self:bindSomeButtonsToPlugin({
		bindList=bindList,
		moduleList=moduleList
	})]]--
    for i = 1, #bindList do
        local btnName = bindList[i].."Bt"
        local pluginName = moduleList[bindList[i].."Ctrl"]
        viewNode[btnName]:addClickEventListener(function()
            my.informPluginByName({pluginName = pluginName})
            my.scheduleOnce(function() self:removeSelfInstance() end, 0)
        end)
    end

	self:bindSomeDestroyButtons(viewNode,{
		'closeBt',
		--'checkinBt',
		'reliefStartGameBt',
		--'reliefBt',
		--'shareBt',
	})

	self:bindProperty(relief,'State',self,'ReliefState')

--	self:bindProperty(checkin,'State',self,'CheckinState')
--	self:listenTo(checkin,checkin.CHECKIN_TAKE_FAILED,handler(self,self.onTakeCheckinFailed))
    viewNode.checkinBt:setEnabled(true)
    viewNode.checkinBt:setVisible(true)

    local offsetY = 0
	--deposite and score mode
    local propertyMode = 3
	--[[if(cc.exports.GetExtraConfigInfo()["PropertyMode"] == 2)then
        assert(self.uiConfig.Relief == false, 'propertymode is score relief must be false')
        offsetY = 120
	end]]--
    -- adjust ctrl pos
    local tmpCtrl = viewNode.closeBt
    tmpCtrl:setPosition(tmpCtrl:getPositionX(), tmpCtrl:getPositionY() - offsetY)

    tmpCtrl = viewNode.title
    tmpCtrl:setPosition(tmpCtrl:getPositionX(), tmpCtrl:getPositionY() - offsetY)

    local tmpCtrl = viewNode.sharePanel:getParent()
    local size = tmpCtrl:getSize()
    tmpCtrl:setSize(size.width, size.height-offsetY)

    -- show function item from the src.app.HallConfig.UIConfig
    local function funShow(viewNode)
        local ui = {true, cc.exports.isReliefSupported(), cc.exports.isShareSupported()}
        local funNode = {viewNode.checkinPanel, viewNode.reliefPanel, viewNode.sharePanel}
        local funs = {} -- nodes to show
        local yy = {}
        for i = 1, #funNode do
            local node = funNode[i]
            yy[i] = node:getPositionY() - offsetY
            if not ui[i] then
                node:setVisible(false)
            else
                table.insert(funs, node)
            end
        end
        for i =1, #funs do funs[i]:setPositionY(yy[i]) end
    end
    funShow(viewNode)

    local times = 3
    --根据配置设置
    local dailyLimitNum = 0
    if cc.exports.gameReliefData then
        dailyLimitNum = cc.exports.gameReliefData.config.Limit.DailyLimitNum or times
    end 
    local reliefText = viewNode.reliefText
    reliefText:setString(string.format(reliefText:getString(), dailyLimitNum))

    if true == cc.exports.IsPackage_qh360() then
        local gameJsonConfig = cc.exports._gameJsonConfig
        if gameJsonConfig and nil ~= gameJsonConfig.AdsFor360 then
            mymodel("AdsModel"):getInstance():showChannelAd()
        end
    end
    
    --local loginLottery = LoginLotteryCtrl:getInstance()
    --if loginLottery then
        local isNeedRedDot = LoginLotteryModel:isNeedRedDot()
        if viewNode.checkinRedDot then
            viewNode.checkinRedDot:setVisible(isNeedRedDot)
        end
    --end
--    if self._schedulerID then
--        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schedulerID)
--        self._schedulerID = nil
--    end
--    local function callback(dt)
--    end
--    self._schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 1.0, false)
end

function DailyActivitysCtrl:setReliefState(data)
	local state=data.state
	if(not state)then
		return
	end
	local viewNode=self._viewNode
	local titleStringMap={
		[relief.NOT_OPENED]='relief_invalid',
		[relief.USED_UP]='relief_used_up',
		[relief.UNSATISFIED]='relief_unsatisfied',
		[relief.NOT_LOGINED]='relief_not_logined',
	}
	local titleString=titleStringMap[state]
	local titleString=titleString and constStrings[titleString]
	if(titleString)then
		viewNode.reliefBt:setEnabled(false)
		viewNode.reliefBt:setTitleText(titleString)
	end

    local upperLimit = data.config.Limit.UpperLimit or 1000
    local lowerLimit = data.config.Limit.LowerLimit or 300
    local reliefTextDetail = viewNode.reliefTextDetail
    reliefTextDetail:setString(string.format(reliefTextDetail:getString(), lowerLimit, upperLimit))
end

function DailyActivitysCtrl:setCheckinState(data)
	local state=data
	if(not state)then
		printf("~~~~~~~~setCheckinState nil~~~~~~~~~~~~~~~~~~~~~~~")
		return
	end
	local viewNode=self._viewNode
	if(state==checkin.NOT_LOGINED)then
		viewNode.checkinBt:setEnabled(false)
		viewNode.checkinBt:setTitleText(constStrings['checkin_not_logined'])
	elseif(state==checkin.NOT_OPENED)then
		viewNode.checkinBt:setEnabled(false)
		viewNode.checkinBt:setTitleText(constStrings['relief_invalid'])
	else
		local buttonTitle=constStrings[state]
		if(buttonTitle)then
			viewNode.checkinBt:setEnabled(false)
			viewNode.checkinBt:setTitleText(buttonTitle)
		end
	end
end

function DailyActivitysCtrl:onTakeCheckinFailed(e)
	local statu=self.state
end

--[[local function dailyConfig()
    return cc.exports.uiConfig
end
DailyActivitysCtrl.uiConfig = dailyConfig();]]--

return DailyActivitysCtrl
