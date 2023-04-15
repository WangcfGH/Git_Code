local AnchorTableCtrl 		= class('AnchorTableCtrl', cc.load('SceneCtrl'))
local AnchorTableModel 		= import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
local AnchorTableDef 		= require('src.app.plugins.AnchorTable.AnchorTableDef')
local viewCreater 			= import('src.app.plugins.AnchorTable.AnchorTableView')
local AnchorTableNodeView 	= import('src.app.plugins.AnchorTable.AnchorTableNodeView')
local UserModel         	= mymodel('UserModel'):getInstance()                                                            --玩家信息模块
local RoomDataManager   	= require("src.app.plugins.AnchorTable.RoomDataManager.RoomDataManager"):getInstance()          --房间数据管理
local ActionDef         	= import('src.app.plugins.AnchorTable.Define.ActionDef') 										--对应玩家的消息订阅
local DataChangesDef    	= import('src.app.plugins.AnchorTable.Define.DataChangesDef') 									--对应数据变化订阅
local MyTimeStamp 			= import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

-- 创建实例
function AnchorTableCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

	self._bResume        = false -- 是否唤醒
	self._scrollView = viewNode.scrollTalbe
    local params = {...}

	AnchorTableModel:enterRoom()
	self:startRefreshTimer()
    self:initialListenTo()
    self:initialUI()
    self:initialBtnClick()
end

-- 注册监听
function AnchorTableCtrl:initialListenTo()	
	self:listenTo(AnchorTableModel, AnchorTableDef.ANCHOR_TABLE_RESUME_TABLE_CTRL, handler(self,self.resume))						-- 切后台操作：唤醒玩家重刷桌子
	self:listenTo(AnchorTableModel, AnchorTableDef.ANCHOR_TABLE_ENTER_ROOM_SET_DATA, handler(self, self.refreshTableList))  		-- 刷新房间数据	
	self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_SEATED, handler(self, self.playerSeated))               					-- 玩家坐下动作 进入桌子后会发送这个消息       
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_UNSEATED, handler(self, self.playerUnseated))           					-- 玩家起立动作 玩家的许多操作都会触发这个消息，换桌，换座等等操作
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_STARTED, handler(self, self.playerStarted))             					-- 玩家启动游戏客户端动作，玩家点击开始
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_PLAYING, handler(self, self.playerPlaying))             					-- 非solo房玩家四人都举手游戏客户端启动后自动开局的动作，游戏开始改变当前状态
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_LEFT, handler(self, self.playerLeft))                   					-- 玩家离开房间动作 
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_LEAVETABLE, handler(self, self.playerLeaveTable))       					-- 玩家离开桌子动作
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_NEWTABLE, handler(self, self.playerNewTable))           					-- 玩家换桌动作
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_GAMESTARTUP, handler(self, self.playerGameStartUp))     					-- solo房玩家游戏开局动作
    self:listenTo(RoomDataManager, ActionDef.EVENT_PLAYER_GAMEBOUTEND, handler(self, self.playerGameBoutEnd))     					-- 玩家一局结束
    self:listenTo(RoomDataManager, ActionDef.EVENT_SOLOTABLE_CLOSED, handler(self, self.soloTableClosed))         					-- 强制散桌
    self:listenTo(RoomDataManager, DataChangesDef.EVENT_PLAYER_PORTRAIT, handler(self, self.playerPortrait))      					-- 玩家头像加载
    self:listenTo(RoomDataManager, DataChangesDef.EVENT_ROOM_INFO_REFRESH, handler(self, self.refreshTableList))  					-- 刷新房间数据	

	self:setBackgroundCallback() --设置切后台回调pause
    self:setForegroundCallback() --设置切后台回来的回调resume
end

--设置切后台的回调函数
function AnchorTableCtrl:setBackgroundCallback()
    local callback = function()
        self:onPause()
    end
    AppUtils:getInstance():removePauseCallback("XzRoom_AnchorTableModel_setBackgroundCallback")
    AppUtils:getInstance():addPauseCallback(callback, "XzRoom_AnchorTableModel_setBackgroundCallback")
end

--设置从后台切回来的回调函数
function AnchorTableCtrl:setForegroundCallback()
    local callback = function()
        self:onResume()
    end
    AppUtils:getInstance():removeResumeCallback("XzRoom_AnchorTableModel_setForegroundCallback")
    AppUtils:getInstance():addResumeCallback(callback, "XzRoom_AnchorTableModel_setForegroundCallback")
end


-- 初始化界面
function AnchorTableCtrl:initialUI()
    if self._viewNode == nil then return end
	
	self:refreshScrollView(true)
end

-- 注册点击事件
function AnchorTableCtrl:initialBtnClick()
    local viewNode = self._viewNode    
    viewNode.btnClose:addClickEventListener(handler(self, self.onClickClose))
	viewNode.btnCreateTable:addClickEventListener(handler(self, self.onCreateTable))	
end

-- 刷新桌子
function AnchorTableCtrl:refreshScrollView(isInit)
	if not cc.exports.isAnchorRoomSupported() then return end

	if self._viewNode == nil then return end

	if self._scrollView and tolua.isnull(self._scrollView:getRealNode()) then return end
    if self._scrollView then
        self._scrollView:removeAllChildren()
    end

	local tablesInfo = {}
	local userIDs = AnchorTableModel:anchorUserIDByChannelID()
	for i=1, #userIDs do
		local talbeNoBegin, tableNoEnd = AnchorTableModel:anchorTableNO(userIDs[i])
		local bHourMiu, eHourMiu = AnchorTableModel:anchorTime(userIDs[i])
		if talbeNoBegin and tableNoEnd and bHourMiu and eHourMiu then
			local curHourMiu = AnchorTableModel:getCurrentHourMiu()
			if bHourMiu <= curHourMiu and curHourMiu < eHourMiu then
				for i=talbeNoBegin, tableNoEnd do
					local tableInfo = RoomDataManager:query("TableInfo", i - 1)				
					if tableInfo.nPlayerCount > 0 and AnchorTableModel:haveAnchorPlayer(i - 1) then
						table.insert(tablesInfo, tableInfo)
					end
				end
			end
		end
	end

	local tableCount = #tablesInfo

	local width    = AnchorTableNodeView.Width * tableCount
    local content   = self._scrollView:getContentSize()
	if width < content.width or tableCount <= 3 then
        width      = content.width
        self._scrollView:setInnerContainerSize(content)
    else
        self._scrollView:setInnerContainerSize(cc.size(width, content.height))
    end

	if tableCount == 0 then
		self._scrollView:setVisible(false)		
	elseif tableCount == 1 then
		self._scrollView:setVisible(true)

		if tableCount < 3 then tableCount = 3 end

		for i=1, tableCount do
			local node  = cc.CSLoader:createNode(AnchorTableNodeView.CsbPath)
			local view  = my.NodeIndexer(node, AnchorTableNodeView.ViewConfig)
			my.presetAllButton(node)
			self:initTableInfo(view, i, tablesInfo)
			if i == 1 then
				node:setPosition(cc.p(568, 220)) 
			elseif i == 2 then
				node:setPosition(cc.p(198, 220)) 
			else
				node:setPosition(cc.p(198 + (i - 1) * (AnchorTableNodeView.Width - 30), 220)) 
			end
			self._scrollView:addChild(node)
		end
	else
		self._scrollView:setVisible(true)

		if tableCount < 3 then tableCount = 3 end

		for i=1, tableCount do
			local node  = cc.CSLoader:createNode(AnchorTableNodeView.CsbPath)
			local view  = my.NodeIndexer(node, AnchorTableNodeView.ViewConfig)
			my.presetAllButton(node)
			self:initTableInfo(view, i, tablesInfo)
			node:setPosition(cc.p(198 + (i - 1) * (AnchorTableNodeView.Width - 30), 220)) 
			self._scrollView:addChild(node)
		end
	end    
	
	if tableCount <= 3 then
		self._scrollView:setBounceEnabled(false)
	else
		self._scrollView:setBounceEnabled(true)
	end

	if tableCount == 0 then
		if not isInit then
			self._viewNode.imgEmpty:setVisible(true)
		end
	else
		self._viewNode.imgEmpty:setVisible(false)
	end

	local warnningTip = cc.exports.getAnchorRoomWarnningTip()
	self._viewNode.txtWarning:setString(warnningTip)
	if AnchorTableModel:isAnchorUser(UserModel.nUserID) then
		self._viewNode.txtUseTime:setVisible(true)
		local curHourMiu = AnchorTableModel:getCurrentHourMiu()
		local bHourMiu, eHourMiu = AnchorTableModel:anchorTime(UserModel.nUserID)
		local bHour = math.modf(bHourMiu / 100) 
		local bMiu = bHourMiu % 100
		local eHour = math.modf(eHourMiu / 100) 
		local eMiu = eHourMiu % 100
		local strUseTime = string.format("%02d:%02d-%02d:%02d", bHour, bMiu, eHour, eMiu)
		self._viewNode.txtUseTime:setString("使用时间"..strUseTime)
		self._viewNode.btnCreateTable:setVisible(true)
		if bHourMiu <= curHourMiu and curHourMiu < eHourMiu then
			self._viewNode.btnCreateTable:setTouchEnabled(true)
			self._viewNode.btnCreateTable:setBright(true)
		else
			self._viewNode.btnCreateTable:setTouchEnabled(false)
			self._viewNode.btnCreateTable:setBright(false)
		end
	else
		self._viewNode.txtUseTime:setVisible(false)
		self._viewNode.btnCreateTable:setVisible(false)
	end
end

function AnchorTableCtrl:initTableInfo(itemNode, index, tablesInfo)
	if index > #tablesInfo then
		itemNode.imgNoneBg:setVisible(true)
		itemNode.imgBg:setVisible(false)
	else
		itemNode.imgNoneBg:setVisible(false)
		itemNode.imgBg:setVisible(true)
		if tablesInfo[index].bHavePassword > 0 then
			itemNode.imgTableLock:setVisible(true)
		else
			itemNode.imgTableLock:setVisible(false)
		end
		for i=1, 4 do
			itemNode["btnWaitJoin"..i]:setVisible(true)
			itemNode["btnWaitJoin"..i]:addClickEventListener(function() self:onJoinTable(tablesInfo[index].nTableNO, i - 1, tablesInfo[index].bHavePassword) end)	
			itemNode["imgBoyHead"..i]:setVisible(false)
			itemNode["imgGirlHead"..i]:setVisible(false)
			itemNode["txtNickName"..i]:setString("玩家"..i)
			local userID = tablesInfo[index].nPlayerAry[i]
			if userID then
				local playerInfo = RoomDataManager:query("PlayerInfoByUserID", userID)
				if playerInfo then
					itemNode["btnWaitJoin"..i]:setVisible(false)
					if playerInfo.nNickSex == 0 then
						itemNode["imgBoyHead"..i]:setVisible(true)
						itemNode["imgGirlHead"..i]:setVisible(false)
					else
						itemNode["imgBoyHead"..i]:setVisible(false)
						itemNode["imgGirlHead"..i]:setVisible(true)
					end
					local utf8name = MCCharset:getInstance():gb2Utf8String(playerInfo.szUsername, string.len(playerInfo.szUsername))
					my.fitStringInWidget(utf8name, itemNode["txtNickName"..i], 100)
					--itemNode["txtNickName"..i]:setString(utf8name)
				end
			end
		end
	end
end

--创建桌子
function AnchorTableCtrl:onCreateTable()
	my.playClickBtnSound()	
	my.informPluginByName({pluginName = "AnchorRulePasswordCtrl", params = {createRoom = true, anchorTalbeCtrl = self}})
end

function AnchorTableCtrl:isJoinBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastJoinBtnTime = self._lastJoinBtnTime or 0
    if nowTime - self._lastJoinBtnTime > GAP_SCHEDULE then
        self._lastJoinBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

--加入桌子
function AnchorTableCtrl:onJoinTable(tableNO, chairNO, bHavePassword)	
	my.playClickBtnSound()
	if self:isJoinBtnClickGap() then return end
	local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
    AnchorTableModel:setTableRule(nil)
	if bHavePassword and bHavePassword > 0 then
		my.informPluginByName({pluginName = "AnchorRulePasswordCtrl", params = {createRoom = false, anchorTalbeCtrl = self, tableNO = tableNO, chairNO = chairNO}})
	else
		AnchorTableModel:reqSeatForce(tableNO, chairNO)
	end
end

--刷新指定桌子
function AnchorTableCtrl:updateByTableNO(tableno)
    
end

--切后台
function AnchorTableCtrl:onPause() 
    self._bResume = true
end

--从后台回来，需要主动的去请求一些信息
function AnchorTableCtrl:onResume()
    AnchorTableModel:reqResume()
end

--是否切后台
function AnchorTableCtrl:isResume()
    return self._bResume
end

--切后台操作：唤醒玩家重刷桌子
function AnchorTableCtrl:resume(...)
    my.scheduleOnce(function()
        self._bResume = false
        -- 刷新桌子显示
    	self:refreshScrollView()
    end)
end

--玩家就桌
function AnchorTableCtrl:playerSeated(data)
    local tableno = data.value.newValue.pp.nTableNO
    self:updateByTableNO(tableno)
end

--玩家离桌
function AnchorTableCtrl:playerUnseated(data)
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

--玩家准备
function AnchorTableCtrl:playerStarted(data)
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

--玩家开始玩
function AnchorTableCtrl:playerPlaying(data) 
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

-- 玩家离开房间
function AnchorTableCtrl:playerLeft(data)
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

--玩家离开桌子
function AnchorTableCtrl:playerLeaveTable(data) 
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

--玩家换桌
function AnchorTableCtrl:playerNewTable(data)  
    local tableno = data.value.newValue.pp.nTableNO
    self:updateByTableNO(tableno)
end

--sole房间的玩家开局
function AnchorTableCtrl:playerGameStartUp(data) 
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

--游戏一局结束
function AnchorTableCtrl:playerGameBoutEnd(data) 
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

-- 强制散桌
function AnchorTableCtrl:soloTableClosed(data) 
    local tableno = data.value.newValue.nTableNO
    self:updateByTableNO(tableno)
end

-- 加载玩家头像
function AnchorTableCtrl:playerPortrait(data) 
    local userid = data.value.who
    local playerInfo = self._delegate:getPlayerInfoByUserID(userid)
    local tableno = playerInfo.nTableNO
    self:updateByTableNO(tableno)
end

--刷新桌子列表
function AnchorTableCtrl:refreshTableList(data) 
    -- 刷新桌子显示
    self:refreshScrollView()
end

--刷新桌子
function AnchorTableCtrl:updateByTableNO(tableno) 
    -- 刷新桌子信息    
	self:refreshScrollView()
end

function AnchorTableCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

function AnchorTableCtrl:goBack()
	self:stopRefreshTimer()
	AnchorTableModel:leaveRoom()
	AppUtils:getInstance():removePauseCallback("XzRoom_AnchorTableModel_setBackgroundCallback")
    AppUtils:getInstance():removeResumeCallback("XzRoom_AnchorTableModel_setForegroundCallback")  

    if type(self._callback) == 'function' then
        self._callback()
    end
    AnchorTableCtrl.super.removeSelf(self)
end

function AnchorTableCtrl:startRefreshTimer()
    self:stopRefreshTimer()
    local scheduler=cc.Director:getInstance():getScheduler()
    self._refreshTimer = scheduler:scheduleScriptFunc(function ()
        self:refreshScrollView()
    end, 60, false)
end
function AnchorTableCtrl:stopRefreshTimer()
    if self._refreshTimer then
        local scheduler=cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self._refreshTimer)
        self._refreshTimer = nil
    end
end 

return AnchorTableCtrl