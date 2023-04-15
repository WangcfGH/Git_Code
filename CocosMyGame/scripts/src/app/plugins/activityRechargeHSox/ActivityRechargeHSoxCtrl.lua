--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreater = import('src.app.plugins.activityRechargeHSox.ActivityRechargeHSoxView')
local ActivityRechargeHSoxCtrl = class('ActivityRechargeHSoxCtrl', cc.load('BaseCtrl'))

local event=cc.load('event')
event:create():bind(ActivityRechargeHSoxCtrl)

--my.addInstance(ActivityRechargeHSoxCtrl)

ActivityRechargeHSoxCtrl.RUN_ENTERACTION = true
ActivityRechargeHSoxCtrl.CLOSE_SHOPBTN_BUUULE = "CLOSE_SHOPBTN_BUUULE"
local oscodeDefault = 0
local oscodeAndroid = 1
local oscodeIOS     = 2
local oscodeWindows = 3

local iapPlugin     = plugin.AgentManager:getInstance():getIAPPlugin()
local json             = cc.load('json').json

local md5Key        = 'MW0N39VPLWAIB2D5'
local js2LuaScheme    = 'lua'

local function encodeURI(s)
    s = string.gsub(s, '([^%w%.%- ])', function(c) return string.format('%%%02X', string.byte(c)) end)
    return string.gsub(s, ' ', '+')
end
    
local function decodeURI(s)
    return string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end

local function parseJsCallbackUrl(url)
    local headStr = js2LuaScheme .. '://'
    local startIndex = string.find(url, headStr)

    if 1 == startIndex and string.len(url) > string.len(headStr) then
        local bodyStr = string.sub(url, string.len(headStr) + 1, string.len(url))

        local endIndex = string.find(bodyStr, '?')
        if nil == endIndex then
            return bodyStr
        elseif 1 == endIndex then
            return nil
        elseif string.len(bodyStr) == endIndex then
            return string.sub(bodyStr, 1, string.len(bodyStr) - 1)
        else
            local interface = string.sub(bodyStr, 1, endIndex - 1)
            local paramList = string.sub(bodyStr, endIndex + 1, string.len(bodyStr))
            
            local specialIndex = string.find(paramList, '=')
            if nil == specialIndex then
                return interface
            elseif 1 == specialIndex then
                return interface
            else
                local param = {}

                while specialIndex do
                    local key = string.sub(paramList, 1, specialIndex - 1)
                    local value = string.sub(paramList, specialIndex + 1, string.len(paramList))

                    endIndex = string.find(value, '&')
                    if nil == endIndex then
                        param[key] = decodeURI(value)
                        break
                    else
                        paramList = string.sub(value, endIndex + 1, string.len(value))
                        value = string.sub(value, 1, endIndex - 1)
                        param[key] = decodeURI(value)
                        specialIndex = string.find(paramList, '=')
                    end
                end
                return interface, param
            end
        end
    else
        return nil
    end
end

function ActivityRechargeHSoxCtrl:onCreate(params)
    self._params = params
    --在游戏内充值会有什么问题吗，这里是直接
    if my.isInGame() then
        self._bInGame = true
    else
        self._bInGame = false
    end

    if (DEBUG > 0) then
        self._domain = "http://paytcysys.uc108.org:1507/static/ingameh5/buyproduct.html"
    else
        self._domain = "https://paytcysys.uc108.net/static/ingameh5/buyproduct.html"
    end

    -- 1:安卓 2:苹果
    local osType = oscodeAndroid
    if device.platform == 'ios' then osType = oscodeIOS end
    -- urlParams
    local gamemodel = mymodel('GameModel'):getInstance()
    self._Allparams = {
        AppClientId     = gamemodel.clientID,
        ClientChannelId = BusinessUtils:getInstance():getClientChannelId(),
        UserId          = plugin.AgentManager:getInstance():getUserPlugin():getUserID(),
        Os              = osType,
        AppVersionNo    = BusinessUtils:getInstance():getAppVersion(),
        ChannelId       = BusinessUtils:getInstance():getTcyChannel(),        
        ProductName     = self._params.Product_Name,
        Price           = self._params.Product_Price,
        GameId          = BusinessUtils:getInstance():getGameID(),
        GameCode        = BusinessUtils:getInstance():getAbbr(),
        AppCode         = BusinessUtils:getInstance():getAbbr(),
        ExtArgs         = self._params.ext_args,
        ThroughData     = self._params.through_data,
        ExchangeId      = self._params.Exchange_Id,
    }

    self._isWebLoadFinish = false
    self._isWebLoadFailed = false
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer(self))
    --下面这个估计是一个显示动画
    --self:dispatchEvent({name = self.CLOSE_SHOPBTN_BUUULE})
end

function ActivityRechargeHSoxCtrl:onEnter()
    if self._viewNode then
        viewCreater:initWeb(self._viewNode )
    end
    self:init()
    self:showWeb()
end

function ActivityRechargeHSoxCtrl:retry()
    self:init()
    self:showWeb()
end

function ActivityRechargeHSoxCtrl:goBack()
    self:removeSelfInstance()
end

function ActivityRechargeHSoxCtrl:onExit()
    print("ActivityRechargeHSoxCtrl:onExit()")

    if (self._params and ( self._params.bNoTime and self._params.closeCallback )) then
        self._params.closeCallback()
        self._params.closeCallback = nil
    end
    --cc.exports.ReducePluginopeningamecount()
    viewCreater:destroyWebView(self._viewNode)
    ActivityRechargeHSoxCtrl.super.onExit(self)
end

function ActivityRechargeHSoxCtrl:init()
    if not self._viewNode.errorLayer then
        release_print('member variable is nil!!!')
        return
    end

    --控制对应的错误界面
    if DeviceUtils:getInstance():isNetworkConnected() then
        viewCreater:ShowError(self._viewNode, false)
    else
        viewCreater:ShowError(self._viewNode, true)
    end

    iapPlugin:setCallback(function(code, msg)
        print('code', code)
        print('msg', msg)
        
        if code >= PayResultCode.kRechargeDirectlySuccess and code <= PayResultCode.kRechargeDirectlyCanceled then
            if self._viewNode and self._viewNode.webView then
                self._viewNode.webView:evaluateJS('onRechargeDirectlyCallback(' .. code .. ',\'' .. msg ..'\')')
            end
        end
    end)
    
    local function jsCallback(webView, url)
        local funcName, param = parseJsCallbackUrl(url)
        print('jsCallbackUrl', url, funcName)
        if param then
            dump(param)
        end
        if funcName == 'exit' then
            self:goBack()
        elseif funcName == 'refresh' then
            if DeviceUtils:getInstance():isNetworkConnected() then
                if self._viewNode and self._viewNode.webView then
                    self._viewNode.webView:reload()
                end
            else
                viewCreater:ShowError(self._viewNode, true)
            end
        elseif funcName == 'aliPay' then
            local orderinfo = param['orderinfo']
            local orderinfosign = param['orderinfosign']
            local md5str = orderinfo .. md5Key
            local md5 = MCCrypto:md5(md5str, string.len(md5str))
            if orderinfosign == md5 then
                iapPlugin:rechargeDirectly(RechargeDirectlyType.kRechargeDirectlyAlipay, orderinfo)
            end
        elseif funcName == 'wxPay' then
            local orderinfo = param['orderinfo']
            local orderinfosign = param['orderinfosign']
            local md5str = orderinfo .. md5Key
            local md5 = MCCrypto:md5(md5str, string.len(md5str))
            if orderinfosign == md5 then
                iapPlugin:rechargeDirectly(RechargeDirectlyType.kRechargeDirectlyWxPay, orderinfo)
            end
        elseif funcName == 'openBrowser' then
            local url = param['url']
            if url then
                DeviceUtils:getInstance():openBrowser(url)
            end
            self:goBack()
        elseif funcName == 'copyToClipboard' then
            local copystr = param['copystr']
            if copystr then
                DeviceUtils:getInstance():copyToClipboard(copystr)
            end
        elseif funcName == 'queryEngineVersion' then
            local callback = param['callback']
            if callback then
                local callbackParam = {}
                callbackParam['version'] = BusinessUtils:getInstance():getEngineVersion()
                local jsonParam = json.encode(callbackParam)
                if self._viewNode and self._viewNode.webView then
                    self._viewNode.webView:evaluateJS(callback .. '(\'' .. jsonParam .. '\')')
                end
            end
        end
    end
    self._viewNode.webView:setJavascriptInterfaceScheme(js2LuaScheme)
    if self._viewNode.webView.setOnJSCallback then
        self._viewNode.webView:setOnJSCallback(jsCallback)
    else
        print("webView setOnJSCallback not exist!")
    end
    self._viewNode.webView:setOnShouldStartLoading(function(wv, url)
        --print('url onShouldStartLoading', url)
        return true
    end)
    self._viewNode.webView:setOnDidFinishLoading(function(wv, url)
        --print('url onDidFinishLoading', url)
        self._isWebLoadFinish = true
        return true
    end)
    self._viewNode.webView:setOnDidFailLoading(function(wv, url)
        --print('url onDidFailLoading', url)
        self._isWebLoadFailed = true
        return true
    end)
    
    local function onPause()
        if self._viewNode and self._viewNode.webView and self._viewNode.webView.evaluateJS then
            self._viewNode.webView:evaluateJS('onPauseCallback()')
        end
    end
    local function onResume()
        if self._viewNode and self._viewNode.webView and self._viewNode.webView.evaluateJS then
            self._viewNode.webView:evaluateJS('onResumeCallback()')
        end
    end
    AppUtils:getInstance():addPauseCallback(onPause, 'Game_SetBackgroundCallback')
    AppUtils:getInstance():addResumeCallback(onResume, 'Game_SetForegroundCallback')
end

function ActivityRechargeHSoxCtrl:showWeb()
    local hsoxurl = self._domain
    local connecter = "?"
    for k, v in pairs(self._Allparams) do
        if k == "ProductName" or k == "ExtArgs" or k == "ThroughData" then
            hsoxurl = hsoxurl .. connecter .. k .. "=" .. string.urlencode(tostring(v))
        else
            hsoxurl = hsoxurl .. connecter .. k .. "=" .. v
        end
        
        connecter = "&"
    end

    --结尾参数以ext=1结尾
    hsoxurl = hsoxurl .. "&ext=1"

    print('loadURL', hsoxurl)    
    my.scheduleOnce(function() 
        if self._viewNode then
            self._viewNode.webView:loadURL(hsoxurl)
        end
    end)
end

return ActivityRechargeHSoxCtrl

--endregion
