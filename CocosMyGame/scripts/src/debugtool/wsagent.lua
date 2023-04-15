local WSAgent = class("WSAgent")

function WSAgent:ctor(interface)
	self._bConnect = false
	self._bConnecting = false
	self._interface = interface
end

function WSAgent:connect()
	if self:isConnect() then
		return
	end

	if self._bConnecting then
		return
	end

	self._bConnecting = true

	local url = "ws://" .. gDbgConfig.gmserver..":"..gDbgConfig.gmport
	self._websocket = cc.WebSocket:createByAProtocol(url, "data")

	local function wsOpen(szData)
		self._bConnect = true
		self._bConnecting = false
	    self:onOpen()
	end

	local function wsMessage(szData)
		if szData == "heartbeat" then
			-- print("====>>>>heartbeat")
			return
		end
		self:onMessage(szData)
	end

	local function wsClose(szData)
		self._bConnect = false
		self._bConnecting = false
		self:onClose()
	end

	local function wsError(szData)
		self._bConnecting = false
		self:onError()
	end

	if nil ~= self._websocket then
	    self._websocket:registerScriptHandler(wsOpen, cc.WEBSOCKET_OPEN)
	    self._websocket:registerScriptHandler(wsMessage, cc.WEBSOCKET_MESSAGE)
	    self._websocket:registerScriptHandler(wsClose, cc.WEBSOCKET_CLOSE)
	    self._websocket:registerScriptHandler(wsError, cc.WEBSOCKET_ERROR)
	else
		print("[ERROR] Websocket Create Faild!!!")
		self._bConnecting = false
	end
end

function WSAgent:startReconnet()
	self:stopReconnect()
	local scheduler = cc.Director:getInstance():getScheduler()
	self._nSchedulerId = scheduler:scheduleScriptFunc(function()
		if self:isConnect() then
			self:stopReconnect()
			return
		end
		self:connect()
	end, 1, false)
end

function WSAgent:stopReconnect()
	if self._nSchedulerId then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self._nSchedulerId)
		self._nSchedulerId = nil
	end
end

function WSAgent:isConnect()
	return self._bConnect
end

function WSAgent:onOpen()
	print("====>>>>WSAgent:onOpen")
	self._interface:onWSOpen()
end

function WSAgent:onMessage(data)
	print("====>>>>WSAgent:onMessage")
	-- todo
	data = json.decode(data)
	if data.cmd == "strcmd" and data.strcmd then
		local ok, msg = pcall(function ()
			local ret = loadstring(data.strcmd)()
		end)
		if not ok then
			print(msg)
		end
	end
end

function WSAgent:onClose()
	print("====>>>>WSAgent:onClose")
end

function WSAgent:onError()
	print("====>>>>WSAgent:onError")
end

function WSAgent:send(data)
	if not self:isConnect() then
		print("====>>>>Websocket Not Connected")
		return
	end
	self._websocket:sendString(json.encode(data))
end

function WSAgent:close()
	if not self:isConnect() then
		return
	end
	self._websocket:close()
end

return WSAgent