local XMLHttpRequestExt = cc.XMLHttpRequestExt

if XMLHttpRequestExt then
    return XMLHttpRequestExt
end

local XMLHttpRequestExt, XMLHttpRequest = {__cname = 'XMLHttpRequestExt'}, cc.XMLHttpRequest
local function getScheduler()
    return cc.Director:getInstance():getScheduler()
end

XMLHttpRequestExt.DEFAULTTIMEOUT = 8

XMLHttpRequestExt.HTTP_RESPONSE_TIMEOUT = -100 
XMLHttpRequestExt.HTTP_RESPONSE_SUCCEED = 200

-- class function
function XMLHttpRequestExt:new(...)
	local instance = XMLHttpRequest:new()
    instance.class = XMLHttpRequestExt
    instance.super = XMLHttpRequest

    setmetatableindex(instance, XMLHttpRequestExt)
    instance:ctor(...)
    return instance
end

function XMLHttpRequestExt.create(...)
    return XMLHttpRequestExt:new(...)
end

function XMLHttpRequestExt:ctor(...)
    self.timeout = self.DEFAULTTIMEOUT
end

-- overwrite super class
function XMLHttpRequestExt:registerScriptHandler(callback)
    self._callback = callback
    return self.super.registerScriptHandler(self, handler(self, self._onDataCallback))
end

function XMLHttpRequestExt:send(...)
    self:_startTimeout()
    return self.super.send(self, ...)
end

-- inner function
function XMLHttpRequestExt:_onDataCallback()
    self:_stopTimeout()
    if self._callback then
        self._callback()
    end
end

function XMLHttpRequestExt:_startTimeout()
    if self.timeout and not self._timeoutTimer then
        self._timeoutTimer = getScheduler():scheduleScriptFunc(handler(self, self._onTimeout), self.timeout, false)
    end
end

function XMLHttpRequestExt:_stopTimeout()
    if self._timeoutTimer then
        getScheduler():unscheduleScriptEntry(self._timeoutTimer)
        self._timeoutTimer = nil
    end
end

function XMLHttpRequestExt:_onTimeout()
    self:abort()
    self.status = self.HTTP_RESPONSE_TIMEOUT
    self:_onDataCallback()
end

function XMLHttpRequestExt:abort()
    self.super.abort(self)
    self.callback = nil
    self:_stopTimeout()
end

-- global
cc.XMLHttpRequestExt = XMLHttpRequestExt
return XMLHttpRequestExt
