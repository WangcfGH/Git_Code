local user = mymodel('UserModel'):getInstance()
local deviceModel = mymodel('DeviceModel'):getInstance()

local PlayerModel = class('PlayerModel', require('src.app.GameHall.models.hallext.ExtendProtocol'))

local sendRequestTrain = cc.load('asynsender').sendRequestTrain
local syncsender = cc.load('asynsender').SyncSender

local userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
local FLAG_GETRNDKEY_MOBILE=0x00000800

my.addInstance(PlayerModel)

PlayerModel.PLAYER_LOGIN_SUCCEEDED = 'PLAYERLOGINEDDATA_UPDATED'
PlayerModel.PLAYER_CONTINUE_PWDWRONG = 'PLAYER_CONTINUE_PWDWRONG'
PlayerModel.PLAYER_DATA_UPDATED = 'PLAYERDATA_UPDATED'
PlayerModel.PLAYER_RNDKEY_UPDATED = 'PLAYERRNDKEY_UPDATED'
PlayerModel.PLAYER_GET_RNDKEY_FAILED = 'PLAYER_GET_RNDKEY_FAILED'
PlayerModel.PLAYER_SAFEBOX_DATA_UPDATED = 'PLAYERSAFEBOXDATA_UPDATED'
PlayerModel.PLAYER_MEMBER_INFO_UPDATED = 'PLAYERMEMBERINFO_UPDATED'
PlayerModel.PLAYER_LOGIN_OFF = 'PLAYER_LOGIN_OFF'
PlayerModel.HARDID_MISMATCH = 'HARDID_MISMATCH'
PlayerModel.PLAYER_KICKED_OFF = 'PLAYER_KICKED_OFF'
PlayerModel.PLAYER_KICKED_OFF_BY_ADMIN = 'PLAYER_KICKED_OFF_BY_ADMIN'
PlayerModel.PLAYER_MOVE_SAFE_DEPOSIT_FAILED = 'PLAYER_MOVE_SAFE_DEPOSIT_FAILED'
PlayerModel.PLAYER_TRANSFER_DEPOSIT_FAILED = 'PLAYER_TRANSFER_DEPOSIT_FAILED'
PlayerModel.PLAYER_SAFEBOX_OPERATION_SUCCEED = 'PLAYER_SAFEBOX_OPERATION_SUCCEED'
PlayerModel.PLAYER_KICKED_OFF_FORBIDTWOHALL = 'PLAYER_KICKED_OFF_FORBIDTWOHALL'
PlayerModel.PLAYER_PORTRAIT_UPDATED = 'PLAYER_PORTRAIT_UPDATED'
PlayerModel.PLAYER_WECHAT_UPDATED = 'PLAYER_WECHAT_UPDATED'

PlayerModel.EVENT_MAP = {
    ["playerModel_onGetDxxwInfo"] = "playerModel_onGetDxxwInfo"
}

---------------------------
-- 0:boy, 1:girl, -1:unknown
PlayerModel.SEX = {
	boy = 0,
	girl = 1,
	unknown = - 1,
}

local mclient = mc.createClient()
function PlayerModel:_initData()
	user.dwQueryFlags = mc.FLAG_QUERYUSERGAMEINFO_HANDPHONE
	user.nSafeboxDeposit = nil --改成nil是为了在没有获取保险箱金额的时候能触发后去
	user.bHaveSecurePwd = false
	user.nRemindDeposit = 1
	self.bNeedRelief = false
	self:registUserPluginEvents()
end

function PlayerModel:resetPlayerExtendFlag()
	self.bNeedRelief = false
end

function PlayerModel:postDataUpdatedEvent()
	self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
	self:dispatchEvent({name = self.PLAYER_SAFEBOX_DATA_UPDATED, value = user})
	local boxDeposit = 0
	if cc.exports.isSafeBoxSupported() then
		boxDeposit = user.nSafeboxDeposit
	elseif cc.exports.isBackBoxSupported() then
		boxDeposit = user.nBackDeposit
	end
	local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()
	local relief=mymodel('hallext.ReliefActivity'):getInstance()
	if relief and relief.config and relief.config.Limit and cc.exports.getReliefLowLimit() and user and user.nDeposit then
		if user.nDeposit + boxDeposit < cc.exports.getReliefLowLimit() then
			if SafeboxModel:isDataReady() then
				relief:queryConfig()
			end
		end
	end
end

function PlayerModel:mergeUserData(dataMap)
	table.merge(user, dataMap)
	if(dataMap.szUtf8Username) then
		user:setUserUtf8Name(dataMap.szUtf8Username)
	elseif(dataMap.szUsername) then
		user:setUserName(dataMap.szUsername)
	end
	self:postDataUpdatedEvent()
	dump(user)
	
end

function PlayerModel:_initSettings()
	
	mclient:registHandler(mc.KICKEDOFF_BYADMIN, handler(self, self._onKickedOffByAdmin), 'room')
	mclient:registHandler(mc.KICKEDOFF_BYADMIN, handler(self, self._onKickedOffByAdmin), 'hall')
	mclient:registHandler(mc.KICKOFF_ROOM_PLAYER, handler(self, self._onKickedOffByAdmin), 'room')
	mclient:registHandler(mc.KICKEDOFF_LOGONAGAIN, handler(self, self._onKickedOff), 'hall')
	mclient:registHandler(mc.GR_KICKEDOFF_FORBIDTWOHALL, handler(self, self._onKickedOff_forbidTwoHall), 'hall')
	
	mclient:registHandler(mc.UR_SOCKET_ERROR, function(respondType, data, msgType, dataMap)
		self:_onLoginOff()
	end, 'hall')
	
	mclient:registHandler(mc.UR_SOCKET_GRACEFULLY_ERROR, function(respondType, data, msgType, dataMap)
		self:_onLoginOff()
	end, 'hall')
	
	mclient:registHandler(mc.GR_CURRENCY_EXCHANGE, function(respondType, data, msgType, dataMap)
		self:onCurrencyChange(respondType, data, msgType, dataMap)
	end, 'hall')
	
	PlayerRequestHelper:setDataUpdateCallback(handler(self, self.postDataUpdatedEvent))
	CacheModel:registInfoChangeByKey("multilayer", handler(self, self.refreshPlayerInfoOnStyleChange))
end

function PlayerModel:_onKickedOffByAdmin()
	self:_onLoginOff()
	self:dispatchEvent({name = self.PLAYER_KICKED_OFF_BY_ADMIN, value = user})
end

function PlayerModel:_onKickedOff()
	self:_onLoginOff()
	self:dispatchEvent({name = self.PLAYER_KICKED_OFF, value = user})
end

function PlayerModel:_onKickedOff_forbidTwoHall()
	self:_onLoginOff()
	self:dispatchEvent({name = self.PLAYER_KICKED_OFF_FORBIDTWOHALL, value = user})
end

function PlayerModel:_onLoginOff()
	self:dispatchEvent({name = self.PLAYER_LOGIN_OFF, value = user})
end

local scheduler = cc.Director:getInstance():getScheduler()
local id
local newAccoutWaitingForLogin = false
function PlayerModel:login(callback)
	user:ReadUserInfo()
	local function onReqCallback(respondType, data, msgType, dataMap)
		--KPI start
		if(respondType == mc.LOGON_SUCCEED or respondType == mc.GR_LOGON_SUCCEEDED_V2 or respondType == mc.PB_LOGON_SUCCEEDED) then
			if(dataMap.szUniqueID) then
				deviceModel.szUniqueID = dataMap.szUniqueID
				if(not deviceModel.szHardID) then
					deviceModel.szHardID = deviceModel.szUniqueID
				end
			end

			table.merge(user,dataMap)

            user:setUserNameRaw(user.szUsername)

            local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
            local utf8nickname = userPlugin:getNickName()
            dump("-----------aaaaaaaaaaaaa--------------" .. utf8nickname )
            local nickname = MCCharset:getInstance():utf82GbString(utf8nickname, string.len(utf8nickname))
            user:setUserName(nickname)

			if( bit.band(dataMap.nUserType,1) == 1 )then
				user.isMember=true
			else
				user.isMember=false
			end
			
			PlayerModel.isMovingDeposit = false
			if type(callback) == 'function' then callback(respondType) end
			self:onLoginSucceed()
			self:dispatchEvent({name = self.PLAYER_LOGIN_SUCCEEDED, value = user})
		elseif(respondType == mc.CONTINUE_PWDWRONG) then
			if type(callback) == 'function' then callback(respondType) end
			self:dispatchEvent({name = self.PLAYER_CONTINUE_PWDWRONG, value = user})
		elseif(respondType == mc.HARDID_MISMATCH) then
			if type(callback) == 'function' then callback(respondType) end
			self:dispatchEvent({name = self.HARDID_MISMATCH, value = user})
		else
			if type(callback) == 'function' then callback(respondType) end
			printInfo('login failed, code is %d', respondType)
			self:dispatchEvent({name = self.PLAYER_LOGIN_OFF, value = user})
		end
	end
	HallRequests:LOGON_USER_PB(onReqCallback)
	--KPI end
end

function PlayerModel:logoff()
	mclient:sendRequest(mc.LOGOFF_USER, {}, 'hall', false)
end

function PlayerModel:update(itemList, callback)
    --bug修复：如果处于未连接状态，发送了需要回应的大厅请求，会触发请求超时；后面连接成功之后，超时重发会再次失败（不确定啥原因），
    --导致MyMCServer:setTimeOuts()触发dispatchSocketError()，又要重新走一遍重连;所以这里发送请求的时候，先确认连接状态
    local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
    if not CenterCtrl:checkNetStatus() then
        print("PlayerRequestHelper:aquireListInfo but checkNetStatus fail!!!")
        return
    end

	local requestMap = {
		UserGameInfo	= "QUERY_USER_GAMEINFO",
		RndKey		= "GET_RNDKEY",
		SafeboxInfo	= not isSafeBoxSupported() and isBackBoxSupported() and "QUERY_BACKDEPOSIT" or "QUERY_SAFE_DEPOSIT",
		-- HappyCoin	= "MR_YQW_GET_HAPPY_COIN",
		-- MemberInfo	= "QUERY_MEMBER",
		WealthInfo 	= "QUERY_WEALTH"
	}
	local requestList = {}

	for key, value in pairs(requestMap) do
		if table.indexof(itemList, key) then
			requestList[value] = true
		end
	end
	
	PlayerRequestHelper:aquireListInfo(requestList, callback)
end

--[Comment]
--消息内容优化，根据
function PlayerModel:queryAllUserInfo(callback)
	PlayerRequestHelper:aquireClassicInfo(callback)	
end

PlayerModel.isMovingDeposit = false
----------------------
--take money from safebox
--
function PlayerModel:moveSafeDeposit(deposit)
	--    MOVE_SAFE_DEPOSIT
	if(PlayerModel.isMovingDeposit) then
		return false
	end
	PlayerModel.isMovingDeposit = true
	
	deposit = checkint(deposit)
	if(deposit == 0) then
		PlayerModel.isMovingDeposit = false
		return
	end
	
	local nResult = 0
	if(self:isSafeboxHasSecurePwd() and self:hasSafeboxGotRndKey()) then
		nResult = self:calculateKeyResult(user.nRndKey, user.lpszSecurePwd)
	end
	
	--    user.nRndKey=nil
	--    user.lpszSecurePwd=nil
	local mcProtocal = mc.MOVE_SAFE_DEPOSIT
	if not isSafeBoxSupported() and isBackBoxSupported() then
		mcProtocal = mc.TAKE_BACKDEPOSIT
	end
	
	syncsender.run(mclient, function()
		local respondType, data, msgType, dataMap = syncsender.send(mcProtocal, {nKeyResult = nResult or 0, nDeposit = deposit}, nil, true)
		PlayerModel.isMovingDeposit = false
		if(respondType == mc.UR_OPERATE_SUCCEED) then
			user.nDeposit = user.nDeposit + deposit
			user.nSafeboxDeposit = user.nSafeboxDeposit - deposit
			self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
			self:dispatchEvent({name = self.PLAYER_SAFEBOX_OPERATION_SUCCEED, value = user})
		else
			user.nRndKey = nil
			user.lpszSecurePwd = nil
			self:dispatchEvent({name = self.PLAYER_MOVE_SAFE_DEPOSIT_FAILED, respondType = respondType, value = dataMap})
		end
	end)
	
end

----------没有任何提示地取出玩家保险箱中的银两------------
function PlayerModel:moveSafeDepositQuiet(deposit, successCallBack)
    --取银前的携银
    my.dataLink(cc.exports.DataLinkCodeDef.BEFORE_SILVER, {count = user.nDeposit})
    if(PlayerModel.isMovingDeposit)then
        print("[ERROR] The player is moving deposits from safebox.")
        return false
    end
    PlayerModel.isMovingDeposit=true

    deposit=checkint(deposit)
    if(deposit==0)then
        PlayerModel.isMovingDeposit=false
        return
    end

    local nResult=0
    if(self:isSafeboxHasSecurePwd() and self:hasSafeboxGotRndKey())then
        nResult=self:calculateKeyResult(user.nRndKey, user.lpszSecurePwd)
    end

    local mcProtocal = mc.MOVE_SAFE_DEPOSIT
    if not isSafeBoxSupported() and isBackBoxSupported() then
       mcProtocal=mc.TAKE_BACKDEPOSIT
    end

    syncsender.run(mclient,function()
        local respondType,data,msgType,dataMap=syncsender.send(mcProtocal,{nKeyResult=nResult or 0,nDeposit=deposit})
        PlayerModel.isMovingDeposit=false
        if(respondType==mc.UR_OPERATE_SUCCEED)then
            user.nDeposit=user.nDeposit+deposit
            user.nSafeboxDeposit=user.nSafeboxDeposit-deposit
            self:dispatchEvent({name=self.PLAYER_DATA_UPDATED,value=user})
            if successCallBack and type(successCallBack) == 'function' then
                successCallBack()
            end
        end
        my.dataLink(cc.exports.DataLinkCodeDef.AFTER_SILVER, {count = user.nDeposit})
    end)
end

----------------------
--save money to safebox
--
function PlayerModel:transferSafeDeposit(deposit)
	--    MOVE_SAFE_DEPOSIT
	if(PlayerModel.isMovingDeposit) then
		return false
	end
	PlayerModel.isMovingDeposit = true
	
	deposit = checkint(deposit)
	if(deposit == 0) then
		PlayerModel.isMovingDeposit = false
		return
	end
	
	--    user.nRndKey=nil
	--    user.lpszSecurePwd=nil
	local mcProtocal = mc.TRANSFER_DEPOSIT
	local params = {dwFlags = mc.FLAG_SUPPORT_KEEPDEPOSIT, nDeposit = deposit}
	if not isSafeBoxSupported() and isBackBoxSupported() then
		mcProtocal = mc.SAVE_BACKDEPOSIT
		params = {dwFlags = mc.FLAG_SUPPORT_KEEPDEPOSIT, nDeposit = deposit, nToGame = my.getGameID()}
	end
	
	syncsender.run(mclient, function()
		local respondType, data, msgType, dataMap = syncsender.send(mcProtocal, params, nil, true)
		PlayerModel.isMovingDeposit = false
		if(respondType == mc.UR_OPERATE_SUCCEED) then
			--            user.nRndKey=nil
			user.nDeposit = user.nDeposit - deposit
			
			if cc.exports.isSafeBoxSupported() then
				user.nSafeboxDeposit = user.nSafeboxDeposit + deposit
			else
				if cc.exports.isBackBoxSupported() then
					user.nBackDeposit = user.nBackDeposit + deposit
				end
			end
			
			local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()
			SafeboxModel:saveDepositOK(deposit)
		
			printf("safeboxdeposit is  " .. user.nSafeboxDeposit)
			
			self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
			self:dispatchEvent({name = self.PLAYER_SAFEBOX_OPERATION_SUCCEED, value = user})
		else
			self:dispatchEvent({name = self.PLAYER_TRANSFER_DEPOSIT_FAILED, respondType = respondType, value = dataMap})
		end
	end)
	
end

function PlayerModel:isSafeboxHasSecurePwd()
	assert(user.bHaveSecurePwd ~= nil, '')
	return user.bHaveSecurePwd ~= 0
end

function PlayerModel:hasSafeboxGotRndKey()
	return user.nRndKey ~= nil and user.nRndKey ~= '' and user.lpszSecurePwd ~= nil and user.lpszSecurePwd ~= ''
end

local MIN_SECUREPWD_LEN = 8
local DEF_SECUREPWD_LEN = 16

function PlayerModel:calculateKeyResult(nRndKey, lpszSecurePwd)
	if(string.len(lpszSecurePwd) > DEF_SECUREPWD_LEN) then
		return - 1
	end
	if(string.len(lpszSecurePwd) < MIN_SECUREPWD_LEN) then
		return - 1
	end
	local nResult = 0
	
	local a = math.modf(nRndKey / 10000, 1)
	local b = math.modf(nRndKey % 10000, 1)
	
	nResult = a + b
	
	local str = lpszSecurePwd
	while(str:len() >= MIN_SECUREPWD_LEN / 2) do
		local add = str:sub(0, MIN_SECUREPWD_LEN / 2)
		--        local key = atoi(add.c_str())
		local key = math.modf(checknumber(add), 1)
		nResult = nResult + key
		str = str:sub(MIN_SECUREPWD_LEN / 2 + 1)
	end
	if(str:len() > 0) then
		--        local key = atoi(str.c_str())
		local key = math.modf(checknumber(str), 1)
		nResult = nResult + key
	end
	return nResult
end

function PlayerModel:getPlayerRndKey()
	return user.nRndKey
end

function PlayerModel:getPlayerData()
	return user
end

function PlayerModel:getPlayerLoginedData()
	return user
end

function PlayerModel:setGameDeposit(nDeposit)
	user.nDeposit = nDeposit
	self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
end

--[Comment]
--入参可以是负数
function PlayerModel:addGameDeposit(nDeposit)
	--当没有对应的值的时候，会触发元表操作，发送请求去获取对应的数据
	if user.nDeposit then
		user.nDeposit = user.nDeposit + nDeposit
		self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
	end
end

--[Comment] 
--入参可以是负数
function PlayerModel:addGameScore(nScore)
	--当没有对应的值的时候，会触发元表操作，发送请求去获取对应的数据
	if user.nScore then
		user.nScore = user.nScore + nScore
		self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
	end
end

--[Comment]
--入参可以是负数
function PlayerModel:addHappyCoin(nHappyCoin)
	--当没有对应的值的时候，会触发元表操作，发送请求去获取对应的数据
	if user.nTotalBalance then
		user.nTotalBalance = user.nTotalBalance + nHappyCoin
		self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
	end
end

--[Comment]
--入参可以是负数
--根据后备箱保险箱配置自动调整
function PlayerModel:addSafeboxDeposit(nDeposit)
    --当没有对应的值的时候，会触发元表操作，发送请求去获取对应的数据
    if isSafeBoxSupported() then
        user.nSafeboxDeposit = user.nSafeboxDeposit + nDeposit
    else
        user.nBackDeposit = user.nBackDeposit + nDeposit
    end
    self:dispatchEvent({name=self.PLAYER_DATA_UPDATED,value=user})
end

function PlayerModel:resetLogin()
	PlayerModel.isLogining = false
	my.isUpdating = false
end

function PlayerModel:userSeek(userid, callback)
	local function onSearchPlayer(respondType, data, msgType, dataMap)
		if respondType == mc.UR_OPERATE_SUCCEED then
			callback(dataMap)
		end
	end
	local requestTrain = {
		{
			mc.SEARCH_PLAYER_INGAME,
			onSearchPlayer,
			{
				nGameID = user.nGameID,
				nPlayer = userid,
				nAskerID = user.nUserID,
				szHardID = deviceModel.szHardID
			}
		},
	}
	sendRequestTrain(requestTrain, mc.createClient())
end

function PlayerModel:registUserPluginEvents()
	local function dataUpdated()
		self:postDataUpdatedEvent()
	end
	local eventMap = {
		[UserActionResultCode.kModifyNameSuccess]	= function(code)
			user:setUserUtf8Name(userPlugin:getUserName())
			dataUpdated()
		end,
		[UserActionResultCode.kModifySexSuccess]	= function(code)
			user:setUserSex(userPlugin:getUserSex())
			dataUpdated()
		end,
		[UserActionResultCode.kModifyPasswordSuccess] = function(code)
			user:setUserPassword(userPlugin:getPassword())
			dataUpdated()
		end,
		[UserActionResultCode.kBindMobileSucess]	= dataUpdated,
		[UserActionResultCode.kUnBindMobileSucess]	= dataUpdated,
		[UserActionResultCode.kUpdateBirthdaySuccess] = dataUpdated
	}
	for code, handler in pairs(eventMap) do
		userPlugin:registCallbackEvent(code, handler)
	end
end

function PlayerModel:getDXXWInfo(callback)
	local client = mc.createClient()
	client:setCallback(function(respondType, data, msgType, dataMap)
		callback(respondType, dataMap)
		print("PlayerModel:getDXXWInfo>>>>>>")
		--callback(10, {nRoomID = 4479})
	end)
	client:sendRequest(mc.MR_QUERY_DXXW_INFO, {}, 'hall', true)
end

function PlayerModel:checkDXXWInfo(callback)
	local function _onGetDXXWInfo(respondType, dataMap)
		print("PlayerModel:checkDXXWInfo, ret="..respondType)
		dump(dataMap)
		if respondType ~= mc.UR_OPERATE_SUCCEED then
			printLog('onGetDXXWInfo', 'no DXXWInfo got')
		else
			--[[local roomManager = require("src.app.GameHall.room.ctrl.RoomManager"):getInstance()
			roomManager:onGetDXXWInfo(dataMap.nRoomID, dataMap.nTableNO)]]--
        self:dispatchEvent({name = PlayerModel.EVENT_MAP["playerModel_onGetDxxwInfo"], value = {["roomId"] = dataMap.nRoomID, ["tableNo"] = dataMap.nTableNO}})
		end
		if type(callback) == "function" then
			callback(respondType)
		end
	end
	self:getDXXWInfo(_onGetDXXWInfo)
end

function PlayerModel:getWechatInfo(onGetWechatInfo)
	--onGetWechatInfo(
	--  isBinded, 是否绑定
	--  info      微信信息
	--)
	user:setWechatBindStatus(nil)
	user:setWechatInfo(nil)
	UserPlugin:queryThirdAccountBindStatus("weixin", function(code, msg)
		print("queryThirdAccountBindStatus", code, msg)
		if code == ThirdAccountStatus.kBinded then
			user:setWechatBindStatus(true)
			UserPlugin:queryThirdInfo("weixin", function(code, msg, info)
				print("queryThirdInfo", code, msg)
				dump(info)
				if type(onGetWechatInfo) == "function" then onGetWechatInfo(true, info) end
				if code == AsyncQueryStatus.kSuccess then
					user:setWechatInfo(info)
					self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
					self:dispatchEvent({name = self.PLAYER_WECHAT_UPDATED, value = user})
				end
			end)
		else
			if type(onGetWechatInfo) == "function" then onGetWechatInfo(false) end
			user:setWechatBindStatus(false)
			self:dispatchEvent({name = self.PLAYER_DATA_UPDATED, value = user})
			self:dispatchEvent({name = self.PLAYER_WECHAT_UPDATED, value = user})
		end
	end)
end

function PlayerModel:onCurrencyChange(respondType, data, msgType, dataMap)
	print("onCurrencyChange")
	dump(dataMap)
	local currencyType = dataMap and dataMap.currencyExchange and dataMap.currencyExchange.nCurrency
	if TCY_CURRENCY.TCY_CURRENCY_HAPPYCOIN == currencyType then
		self:update({'HappyCoin'})
	elseif TCY_CURRENCY.TCY_CURRENCY_DEPOSIT == currencyType then
		self:update({'UserGameInfo'})
	end
end

function PlayerModel:getPortraitInfo()
  print("PlayerModel:getPortraitInfo")
	user:setPortraitStatus(nil)
	user:setPortraitPath(nil)
	local imageCtrl = import('src.app.BaseModule.ImageCtrl')
	imageCtrl:removeCallbackByTag(self.__cname)
	imageCtrl:getSelfImage('400-400', function(code, path, imageStatus)
			print("code = %d", code)
			print("path = %s", path)
			
			if code == imageCtrl.IMAGELOAD_GETLOCAL_SUCCESS_SYNC
			or code == ImageLoadActionResultCode.kImageLoadOnlineSuccess then
				user:setPortraitPath(path)
			elseif code == imageCtrl.IMAGELOAD_GETLOCAL_FAILED_SYNC
			or	code == ImageLoadActionResultCode.kImageLoadOnlineSuccess
			or	code == ImageLoadActionResultCode.kImageLoadOnlineFailed
			or	code == ImageLoadActionResultCode.kImageLoadOnlineCancel then
				
			end
			
			user:setPortraitStatus(imageStatus)
			self:dispatchEvent({name = self.PLAYER_PORTRAIT_UPDATED, value = user})
	end, nil, self.__cname)
end

function PlayerModel:checkPlayerGameStatus(onGameStatusNormal, checkPlayertatusFinishedCallback)
    self:checkDXXWInfo(function(respondType)
		if type(checkPlayertatusFinishedCallback) == "function" then
			checkPlayertatusFinishedCallback()
		end

		if respondType == mc.UR_OPERATE_SUCCEED then
			return
        else
            --没有断线续玩信息
		    if type(onGameStatusNormal) == "function" then
			    onGameStatusNormal()
	        end
		end
	end)
end

function PlayerModel:queryNetworkStateInfo()
	local function onReqNetWorkCallback(respondType, data, msgType, dataMap)
		if respondType ~= mc.MR_CHECK_NETWORK then
			my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "本机IP地址获取失败", removeTime = 1}})
			user.strIP = ""
			return
		end
		local _, ip = string.unpack(data, "<L")
		user.strIP = my.ipIntToString(ip)
	end
	
	local mclient = mc.createClient()
	mclient:setCallback(onReqNetWorkCallback)
	mclient:sendRequest(mc.MR_CHECK_NETWORK, {}, nil, true)
end

function PlayerModel:getThirdPortraitByUrl(url)
	user:setPortraitStatus(nil)
	user:setPortraitPath(nil)
	if type(url) == "string" and string.len(url) > 0 then
		local thirdPartyImageCtrl = import('src.app.BaseModule.YQWImageCtrl')
		thirdPartyImageCtrl:getUserImage(UserPlugin:getUserID(), url, function(code, path)
			if code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess and path ~= "" then
				user:setPortraitPath(path)
				user:setPortraitStatus(nil)
			else
			end
			self:dispatchEvent({name = self.PLAYER_PORTRAIT_UPDATED, value = user})
		end)
	else
		printError("getThirdPortrait get in proper input value" .. tostring(url))
		self:dispatchEvent({name = self.PLAYER_PORTRAIT_UPDATED, value = user})
	end
end

function PlayerModel:onLoginSucceed()
	user:setPortraitStatus(nil)
	user:setPortraitPath(nil)
	user:setWechatBindStatus(nil)
	user:setWechatInfo(nil)
	self:refreshPlayerInfoOnStyleChange(CacheModel:getCacheByKey("multilayer"))
end

--[Comment]
--玩法切换
--目前只有头像需要手动刷新，因为微信头像path和同城游头像path用的同一个字段
function PlayerModel:refreshPlayerInfoOnStyleChange(multiLayerData)
	self:getPortraitInfo()	
end

function PlayerModel:startPulse()
	self:stopPulse()
	local pulseSchedule = PingModeule:isPingSupported() and 60 or 5
	self._pulseId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(HallRequests, HallRequests.MR_REQUEST_PULSE), pulseSchedule, false)
end

function PlayerModel:stopPulse()
	if self._pulseId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pulseId)
		self._pulseId = nil
	end
end

return PlayerModel
