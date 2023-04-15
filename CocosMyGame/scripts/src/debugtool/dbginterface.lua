-- @Author     : wangyao
-- @DateTime   : 2017-05-10 12:00:15
-- @Description: 测试接口

local WSAgent       = import("src.debugtool.wsagent")
local UpLoader      = import("src.debugtool.uploadlog")
local GMLayer       = import("src.debugtool.gmlayer")
local GMIcon        = import("src.debugtool.gmicon")
local MEMText       = import("src.debugtool.memText")
local FlyMsg        = import("src.debugtool.flymsg")
local scheduler     = cc.Director:getInstance():getScheduler()

cc.exports.DbgInterface = {}

function DbgInterface:run()
    self.nScheduleId = scheduler:scheduleScriptFunc(function()
        myxpcall(function()
            self:onSchedule()
        end)
    end, 1, false)
end

function DbgInterface:onSchedule()
    self:showGMIcon()
    self:showMEMText()

    UpLoader:flushPrintLog()
end

function DbgInterface:connectTestServer()
    if not gDbgConfig.gmenable then
        return
    end
    if self:getPlayerId() <= 0 then
        return
    end
    if not self._wsAgent then
        self._wsAgent = WSAgent:create(self)
    end
    if self._wsAgent:isConnect() then
        return
    end
    --self._wsAgent:startReconnet()
    self._wsAgent:connect()
end

function DbgInterface:disConnectTestServer()
    if self._wsAgent then
        self._wsAgent:close()
    end
end

function DbgInterface:onWSOpen()
    self._wsAgent:send({
        cmd = "login",
        nUserID = self:getPlayerId(),
        szPassword = "woshishabi",
    })
end

function DbgInterface:isWSConnect()
    if self._wsAgent then
        return self._wsAgent:isConnect()
    end
    return false
end

function DbgInterface:uploadPrintLog(szLog)
    if not gDbgConfig.synclog then
        return
    end
    if self:getPlayerId() <= 0 then
        return
    end    
    UpLoader:uploadPrintLog(szLog)
end

function DbgInterface:uploadFile(szPath, uploadEventHandler, customFileName)
    return UpLoader:uploadFile(szPath, uploadEventHandler, customFileName)
end

function DbgInterface:uploadMCLogFile(fileName, uploadEventHandler)
    return UpLoader:uploadMCLogFile(fileName, uploadEventHandler)
end

function DbgInterface:uploadLogString(fileTitle, logString)
    if not cc.exports.isAutoUpdateDBGLogSupported() then return end
    return UpLoader:uploadLogString(fileTitle, logString)
end

function DbgInterface:showMsg(szMsg, color)
    package.loaded["src.debugtool.flymsg"] = nil           -- reload for test
    local FlyMsg = import("src.debugtool.flymsg")          -- reload for test    

    FlyMsg:create(szMsg, color)
end

function DbgInterface:showGMLayer()
    package.loaded["src.debugtool.gmlayer"] = nil           -- reload for test
    local GMLayer = import("src.debugtool.gmlayer")         -- reload for test

    self:connectTestServer()
    GMLayer:create()
end

function DbgInterface:closeGMLayer()
    local curScene = display.getRunningScene()
    if curScene and curScene._gmLayer then
        myxpcall(function()
            curScene._gmLayer:remove()
        end)        
        curScene._gmLayer = nil
    end
end

function DbgInterface:setLogFileStartLine(nLineIdx)
    self._logFileStartLine = nLineIdx
end

function DbgInterface:getLogFileStartLine()
    return self._logFileStartLine or 0
end

function DbgInterface:showGMIcon()
    local curScene = display.getRunningScene()
    if curScene and not curScene._disableGMIcon and not curScene._gmIcon then
        curScene._gmIcon = GMIcon:create()
    end
end

function DbgInterface:showMEMText()
    local curScene = display.getRunningScene()
    if not curScene then return end

    if gDbgConfig.memenable or curScene._enableMEMInfo then
        if not curScene._memText then
            curScene._memText = MEMText:create()
        end
        curScene._memText:refresh()
    else
        if curScene._memText then
            curScene._memText:close()
            curScene._memText = nil
        end
    end
end

function DbgInterface:isMemTextVisible()
    local curScene = display.getRunningScene()
    if curScene and curScene._memText then
        return true
    end
    return false
end

function DbgInterface:closeGMIcon()
    local curScene = display.getRunningScene()
    if curScene and curScene._gmIcon then
        myxpcall(function()
            curScene._gmIcon:remove()
        end)        
        curScene._gmIcon = nil
    end
end

function DbgInterface:disableGMIconInCurrentScene()
    local curScene = display.getRunningScene()
    if curScene then
        curScene._disableGMIcon = true
    end
    self:closeGMIcon()
end

function DbgInterface:getPlayerId()
    if mymodel then
        local user = mymodel("UserModel"):getInstance()
        if user and user.nUserID then
            return user.nUserID
        end
    end
    return 0
end

function DbgInterface:getGameAbbr()
    if my and my.getAbbrName then
        return my.getAbbrName()
    end
    return "xxxx"
end

function DbgInterface:updateLogPaintedEggshell()
    if gCurLogPath and not self._isDBGLogUpdateing then
        local playerID = self:getPlayerId()
        local fileName = tostring(playerID)
        if playerID <= 0 then
            fileName = "unlogin"
        end
        fileName = fileName .. "_".. tostring(math.floor(socket.gettime() * 1000))
        
        self._isDBGLogUpdateing = self:uploadFile(gCurLogPath, function(event)
            if event.state == "start" then
            elseif event.state == "uploading" then
            elseif event.state == "finish" then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString="游戏日志上传成功",removeTime=3}})
                self._isDBGLogUpdateing = false
                my.scheduleOnce(function()
                    self._isDBGLogUpdateing = self:uploadMCLogFile("release_tcy_"..fileName..".txt", function(event)
                        if event.state == "finish" then
                            my.informPluginByName({pluginName='ToastPlugin',params={tipString="引擎日志上传成功",removeTime=3}})
                            self._isDBGLogUpdateing = false
                        end
                    end)
                end)
            end
        end, "release_"..fileName..".txt")
    end
end

function DbgInterface:autoUpdateLogToSever(isPing)
    if not cc.exports.isAutoUpdateDBGLogSupported() then return end
    if gCurLogPath and not self._isDBGLogUpdateing then
        if isPing and MCCharset then
            local dnsResult, resolved = nil, nil
            for i = 1, 4 do
                dnsResult, resolved = socket.dns.getaddrinfo("m" .. i .. ".108uc.com")
                print("m" .. i .. ".108uc.com")
                dump(dnsResult)
            end
            local serverConfig = require('src.app.HallConfig.ServerConfig')
            dnsResult, resolved = socket.dns.getaddrinfo(serverConfig["hall"][1])
            print(serverConfig["hall"][1])
            dump(dnsResult)
        end
        local playerID = self:getPlayerId()
        local fileName = tostring(playerID)
        if playerID <= 0 then
            fileName = "unlogin"
        end
        fileName = fileName .. "_".. tostring(math.floor(socket.gettime() * 1000))

        self._isDBGLogUpdateing = self:uploadFile(gCurLogPath, function(event)
            if event.state == "start" then
            elseif event.state == "uploading" then
            elseif event.state == "finish" then
                self._isDBGLogUpdateing = false
                my.scheduleOnce(function()
                    self._isDBGLogUpdateing = self:uploadMCLogFile("auto_tcy_"..fileName..".txt", function(event)
                        if event.state == "finish" then
                            self._isDBGLogUpdateing = false
                        end
                    end)
                end)
            end
        end, "auto_"..fileName..".txt")
    end
end

function DbgInterface:gameReconnectAutoUpdateLog(count)
    local DBGLogCount = cc.exports.getGameReconnectCountDBGLog()
    if DBGLogCount and count == DBGLogCount then  
        self:autoUpdateLogToSever(true)
    end
end

function DbgInterface:updateLogToSeverForName(fileTitle, needTime)
    if not cc.exports.isAutoUpdateDBGLogSupported() then return end
    if gCurLogPath and not self._isDBGLogUpdateing then
        local playerID = self:getPlayerId()
        local fileName = tostring(playerID)
        if playerID <= 0 then
            fileName = "unlogin"
        end
        if needTime then
            fileName = fileName .. "_".. tostring(math.floor(socket.gettime() * 1000))
        end
        self._isDBGLogUpdateing = self:uploadFile(gCurLogPath, function(event)
            if event.state == "start" then
            elseif event.state == "uploading" then
            elseif event.state == "finish" then
                self._isDBGLogUpdateing = false
                my.scheduleOnce(function()
                    self._isDBGLogUpdateing = self:uploadMCLogFile(fileTitle.."_tcy_"..fileName..".txt", function(event)
                        if event.state == "finish" then
                            self._isDBGLogUpdateing = false
                        end
                    end)
                end)
            end
        end, fileTitle.."_"..fileName..".txt")
    end
end

return DbgInterface
