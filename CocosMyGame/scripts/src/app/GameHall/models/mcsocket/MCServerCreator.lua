
local ServerConfig = require('src.app.HallConfig.ServerConfig')

local clientList = { }

-- common proxy begin
local function isNeedCommonProxy(name)
    -- 暂时只有roomsvr才会使用common mp
    if name ~= "room" then
        return false
    end
    -- 没有commonmp IP和PORT的话，也没办法使用
    local mpConfig = ServerConfig["commonmp"]
    if not mpConfig[1] or not mpConfig[2] then
        return false
    end

    local v = ServerConfig[name]
    return true, my.convertToConnectInfo(v[1], v[2], 3)
end

local function createClient(name)
    print("create socket ",name)
    local client = clientList[name]
    
    local bProxy = false
    local connectStr = ""

    if (not client) then
        local v = ServerConfig[name]
        dump(v)

        local ip = v[1]
        if MCAgent and MCAgent.getInstance and MCAgent:getInstance().getIpList then
            local arrayip = MCAgent:getInstance():getIpList(v[1])
            if type(arrayip) == 'table' and next(arrayip) and arrayip[1] and my.judgeIPString(arrayip[1]) then
                ip = arrayip[1]
            end
        end

        if name == "room" then
            bProxy, client, connectStr = my.commonMPConnect(ip, v[2], 3)
        else
            client = MCAgent:getInstance():createClient(ip, v[2])
        end

        clientList[name] = client

        local connect_called = false
        local client_connect = client.connect
        function client:connect()
            if (not connect_called) then
                client_connect(self)
            end
            connect_called = true
        end

        local client_disconnect = client.disconnect
        function client:disconnect()
            if (connect_called) then
                client_disconnect(self)
                connect_called = false
            end
        end

        local client_destroy = client.destroy
        function client:destroy()
            client_destroy(self)
            connect_called = false
        end

        local client_reconnection = client.reconnection
        function client:reconnection()
            --disconnect 之后调用connect 会出现永远连接不上的情况
            -- if (connect_called) then
                client_reconnection(self)
            -- else
            --     self:connect()
            --     connect_called = true
            -- end
        end
        local client_sendRequest = client.sendRequest
        function client:sendRequest(requestId, data, datalen, isWaiting)
            return client_sendRequest(self, requestId, data, datalen, isWaiting)
        end

    end
    return client, bProxy, connectStr
end
-- common proxy end

local function removeClient(name)
    clientList[name] = nil
end

return {
    createClient = createClient,
    removeClient = removeClient,
}
