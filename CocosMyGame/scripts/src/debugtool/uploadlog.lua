local Uploader = {}

Uploader.BUFSIZE    = 2^13

function Uploader:encodeURL(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function Uploader:httpencode(data)
    local newdata = ""
    local first = true
    for key,value in pairs(data) do
        if not first then 
            newdata = newdata .. "&"
        end
        first = false
        newdata = newdata .. key .. "=" .. self:encodeURL(value)
    end
    return newdata
end

function Uploader:send(data, fnCallback)
    data.log = MCAgent:getInstance():zipMemory(data.log, string.len(data.log))

    local url = string.gsub(gDbgConfig.logserver, "ttps", "ttp") .. "/log/uploadlog_v3.0.php"
    local http = cc.XMLHttpRequest:new()
    http:open("POST", url)
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING

    -- 回调函数
    local function callback()
        if http.readyState == 4 and (http.status >= 200 and http.status < 207) then
            -- todo
            if fnCallback then
                fnCallback(true)
            end            
        else
            -- todo
            if fnCallback then
                fnCallback(false)
            end
        end
    end
    http:registerScriptHandler(callback)
    http:send(self:httpencode(data))
end

function Uploader:uploadPrintLog(szLog)
    self._cachePrintLog = self._cachePrintLog or {}
    self._cachePrintLog[#self._cachePrintLog+1] = szLog
    self._cachetTotalLen = (self._cachetTotalLen or 0) + string.len(szLog)
    if self._cachetTotalLen >= (2^10) then
        self:flushPrintLog()
    end
end

function Uploader:flushPrintLog()
    if not self._cachePrintLog or #self._cachePrintLog <= 0 then
        return
    end
    
    local szLog = table.concat(self._cachePrintLog, "")
    self._cachePrintLog = nil
    self._cachetTotalLen = nil

    local userid = DbgInterface:getPlayerId()
    local data = {
        type        = 1,
        game        = DbgInterface:getGameAbbr(),
        userid      = userid,
        date        = os.date("%Y%m%d"),
        time        = os.date("%H%M%S"),        
        log         = szLog,
        filename    = string.format("%s.txt", userid),
        isAdd       = 1,    --是否是追加
        blcokSize   = 0, --块大小
        currBlock   = 0, --当前块下标
    }
    self:send(data)
end

function Uploader:selectFileContent( fileHander )
    if DEBUG <= 0 then   --截取日志长度
        local maxCacheSize = 1024 * 1024 * 10
        local cacheSize = fileHander:seek("end")
        if cacheSize > maxCacheSize then
            fileHander:seek("end", -maxCacheSize)
        else
            fileHander:seek("set")
        end
    end
end

function Uploader:uploadFile(filePath, uploadEventHandler, customFileName)
    if self._uploading then
        return
    end
    local f = io.open(filePath, "r")
    if not f then
        return
    end
    
    self:selectFileContent(f)

    self._uploadFileName = customFileName or string.match(filePath, "([^/\\]+.txt)")
    self._uploadEventHandler = uploadEventHandler
    self.tbBlocks = {}

    while true do
        local block = f:read(self.BUFSIZE)
        if not block then
            break
        end
        table.insert(self.tbBlocks, block)
    end
    f:close()
    self:startScheduleUpload()

    return true
end

function Uploader:onUploadEvent(event)
    if self._uploadEventHandler then
        self._uploadEventHandler(event)
    end
end

function Uploader:startScheduleUpload()
    self:onUploadEvent({state = "start"})
    self._uploading = true
    self._uploadBlockIndex = 0
    self:stopScheduleUpload()
    self.nScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:onScheduleUpload()
    end, 0, false)
end

function Uploader:stopScheduleUpload()
    if self.nScheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.nScheduleId)
        self.nScheduleId = nil
    end
end

function Uploader:onScheduleUpload()
    if not self._uploading then
        return
    end
    self._uploadBlockIndex = (self._uploadBlockIndex or 0) + 1
    local block = self.tbBlocks[self._uploadBlockIndex]
    if not block then
        self:stopScheduleUpload()
        return
    end
    local percent = self._uploadBlockIndex / #self.tbBlocks
    percent = math.floor(percent * 10000) / 100
    local data = {
        type        = 2,
        game        = DbgInterface:getGameAbbr(),
        userid      = DbgInterface:getPlayerId(),
        date        = os.date("%Y%m%d"),
        time        = os.date("%H%M%S"),
        log         = block,
        filename    = self._uploadFileName,
        isAdd       = 0,    --是否是追加
        blcokSize   = self.BUFSIZE, --块大小
        currBlock   = self._uploadBlockIndex, --当前块下标
    }

    self:send(data, function(bSuccess)
        if not self._uploading then
            return
        end
        if not bSuccess then
            self:onUploadEvent({state = "finish", success = false})
            self:stopScheduleUpload()
            self._uploading = false
            return
        end
        local event = {
            state   = "uploading",
            percent = percent,
        }
        self:onUploadEvent(event)
        if percent >= 100 then
            self:onUploadEvent({state = "finish", success = true})
            self:stopScheduleUpload()
            self._uploading = false
        end
    end)
end

function Uploader:uploadMCLogFile(fileName, uploadEventHandler)
    if self._uploading or not MCAgent:getInstance().getLogPath or not fileName then
        return
    end
    local filePath = MCAgent:getInstance():getLogPath()
    if not filePath then
        return
    end
    local f = io.open(filePath, "r")
    if not f then
        return
    end
    
    self:selectFileContent(f)

    self._uploadFileName = fileName
    self._uploadEventHandler = uploadEventHandler

    self.tbBlocks = {}
    while true do
        local block = f:read(self.BUFSIZE)
        if not block then
            break
        end
        table.insert(self.tbBlocks, block)
    end
    f:close()
    self:startScheduleUpload()
    
    return true
end

--上传小块缓存日志
function Uploader:uploadLogString(fileTitle, logString)
    --避免下重复上传
    if not logString or self._prelogString == logString then
        return
    end

    local userid = DbgInterface:getPlayerId()
    local data = {
        type        = 2,
        game        = DbgInterface:getGameAbbr(),
        userid      = userid,
        date        = os.date("%Y%m%d"),
        time        = os.date("%H%M%S"),        
        log         = logString,
        filename    = string.format("%s_%s_%s.txt", fileTitle, userid, math.floor(socket.gettime() * 1000)),
        isAdd       = 1, --是否是追加
        blcokSize   = 0, --块大小
        currBlock   = 0, --当前块下标
    }
    self:send(data)

    self._prelogString = logString

    return true
end

return Uploader
