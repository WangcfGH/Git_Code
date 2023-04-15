
local viewCreater       = import('src.app.plugins.exchange.ExchangeView')
local ExchangeCtrl      = class('ExchangeCtrl', cc.load('SceneCtrl'))
local ActivityConfig    = import('src.app.HallConfig.ActivitysConfig')

my.addInstance(ExchangeCtrl)

ExchangeCtrl.LOGUI = 'Exchange'

function ExchangeCtrl:onCreate( ... )
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
	local webView = viewNode.webView

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local url = myhttp:getExchangeBaseUrl()
    url = string.format('%smobile/mall/index?activityGuid=%s', url, ActivityConfig.ExchangeGUID)
	url = string.format('%s&userID=%d&gameID=%d&userToken=%s', url, userPlugin:getUserID(), my.getGameID(), userPlugin:getAccessToken())
    --[[KPI start ]]
    --请求的HSox页面后加上ClientLinkID=客户端唯一ID（userid+gameid+time+mac地址）
    local deviceUtils = DeviceUtils:getInstance()
    local clientLinkID  = string.format('%d%d%d%s', userPlugin:getUserID(),my.getGameID(),socket.gettime(), deviceUtils:getMacAddress())
    url = string.format('%s&ClientLinkID=%s', url, clientLinkID)
    --上报KPI信息
    local httpUrl = string.format("%sMobile/Client/ReportData", myhttp:getExchangeBaseUrl())
    local function _onCallBack(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            print("--->>>", result.StatusCode)
        end
    end
    self:httpPost(httpUrl, clientLinkID, _onCallBack)
    --[[KPI end ]]
	webView:loadURL(url)

	webView:setOnDidFinishLoading(function(wv, url)
		if wv and self._isWebpageGoingBack then
			self._isWebpageGoingBack = false
			wv:reload()
		end
	end)

	self:bindUserEventHandler(viewNode, {'closeBt'})

	self:setOnExitCallback(function()
		webView:setVisible(false)
	end)
end

function ExchangeCtrl:goBack()
	self._isWebpageGoingBack = true
	local webView = self._viewNode.webView
	if webView:canGoBack() then
		webView:goBack()
	else
		if my.informPluginByName({params={message='remove'}}) then
			self:removeSelfInstance()
		end
	end
end

function ExchangeCtrl:closeBtClicked()
	self:goBack()
end

function ExchangeCtrl:onKeyBack()
    self:playEffectOnPress()
	self:goBack()
end

--[[KPI start ]]
function ExchangeCtrl:httpPost(url,clientLinkID, callback)
    local gsClient = nil
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
    end
    if not gsClient then return end    

    local xhr = cc.XMLHttpRequestExt:new()
    xhr:setRequestHeader('Content-Type', 'application/json')
    xhr.responseType = 0

    local str = string.gsub(json.encode(gsClient), '\"', '\\"')
    local params = string.format("{\"ClientLinkID\":\"%s\",\"GsClientData\":\"%s\"}", clientLinkID, str)
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
        printLog(self.__cname, 'status: %s, response: %s', xhr.status, xhr.response)
        callback(xhr)
    end )
    xhr:send(params)
    printLog(self.__cname, 'http post url: %s, params: %s', url, params)
end
--[[KPI end ]]

return ExchangeCtrl
