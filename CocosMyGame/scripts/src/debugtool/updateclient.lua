--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local UpdateClient  = class("UpdateClient")


local APP_CODE                          = BusinessUtils:getInstance():getAbbr()
local UPDATE_DIR                        = BusinessUtils:getInstance():getUpdateDirectory()

cc.exports.UpdateClientDef = {
    UPDATESERVER_CONNECT_OK     = 1,   --连接update server success
    UPDATESERVER_CONNECT_FAILED = 2,   --连接update server failed
    UPDATESERVER_CONNECT_CLOSE  = 3,   --连接断开

    UPDATESERVER_CUSTOMER_MSG   = 4,   --应用层添加消息在这个之后
    UPDATESERVER_DOWNLOAD_MSG   = 100,
}

-- life connect

--@api
-- sendString
-- close

function UpdateClient:ctor()
    self._ready         = false
    self._session       = nil
    self._wait_msg      = nil
    
    self._defaultCB     = nil

    self._reqid         = UpdateClientDef.UPDATESERVER_DOWNLOAD_MSG+1
    self._cmd_cb_list   = {}

    self:reset()
    self:connect()
end

function UpdateClient:setDefaultCB(defaultCB)
    self._defaultCB = defaultCB
end

function UpdateClient:reset()
    self._ready = false
    self._session = nil
    self._wait_msg = nil

    self._reqid         = UpdateClientDef.UPDATESERVER_DOWNLOAD_MSG+1
    self._cmd_cb_list   = {}
end

function UpdateClient:close()
    if self._session then
        self._session:close()
    end
end

function UpdateClient:curReqid()
    local id = self._reqid
    self._reqid = id + 1
    return id
end

function UpdateClient:isReady()
    return self._ready
end

function UpdateClient:reqMsg(cmd, param, callback)
    if not param then
        return
    end
    if not callback then
        callback = param
        param = {}
    end
    local msg = {
        code        = cmd,
        userid      = DbgInterface:getPlayerId(),
        appcode     = APP_CODE,
        jsondata    = param or {},
        reqid       = self:curReqid()
    }
    self:sendMsg(msg, callback)
end

function UpdateClient:connect()
    if self._session then
        return
    end
    
    self._ready = false
    self._session = cc.WebSocket:createByAProtocol(gDbgConfig.update_server, "data")
    assert(self._session)

    local ft = {}
    ft[cc.WEBSOCKET_OPEN] = function()
        self:onOpen()
    end
    ft[cc.WEBSOCKET_MESSAGE] = function(data)
        self:onMessage(data)
    end
    ft[cc.WEBSOCKET_CLOSE] = function(code)
        self:onClose(code)
    end
    ft[cc.WEBSOCKET_ERROR] = function()
        self:onError()
    end

    for i,v in pairs(ft) do
        self._session:registerScriptHandler(v, i)
    end
end

function UpdateClient:sendMsg(msg, cb)
    if not self._session then
        return
    end

    if not self._ready then
        self._wait_msg = {
            msg = msg,
            cb = cb
        }
        return
    end
    

    local data = json.encode(msg)
    self._cmd_cb_list[msg.reqid] = cb
    self._session:sendString(data)
end

function UpdateClient:disconnect()
   -- assert(self._session)
    if self._session then
        self._session:close()
    end
end

function UpdateClient:onOpen()
    print("onOpen")
    self._ready = true
    
    if self._defaultCB then
        self._defaultCB(UpdateClientDef.UPDATESERVER_CONNECT_OK)
    end

    if self._wait_msg then
        local msg = self._wait_msg.msg
        local cb = self._wait_msg.cb
        self._wait_msg = nil
        self:sendMsg(msg, cb)
    end
end

function UpdateClient:onMessage(data)
    print("onMessage")
    data = MCCrypto:decodeBase64(data, data:len())
    local rsp = json.decode(data)
    local reqid = rsp.reqid
    if reqid then
        if self._cmd_cb_list[reqid] then
            local cb = self._cmd_cb_list[reqid]
            self._cmd_cb_list[reqid] = nil
            cb(rsp)
       elseif self._defaultCB then
            self._defaultCB(reqid, rsp)
       end
    end
end

function UpdateClient:onError()
    print("onError")
    if self._defaultCB then
        self._defaultCB(UpdateClientDef.UPDATESERVER_CONNECT_FAILED)
    end

    self:reset()
end

function UpdateClient:onClose(code)
    print("onClose")

    if self._defaultCB then
        self._defaultCB(UpdateClientDef.UPDATESERVER_CONNECT_CLOSE)
    end
    self:reset()
end

return UpdateClient
--endregion
