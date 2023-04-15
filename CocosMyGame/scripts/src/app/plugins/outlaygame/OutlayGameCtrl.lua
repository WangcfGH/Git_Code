--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local OutlayGameView       = import('src.app.plugins.outlaygame.OutlayGameView')
local OutlayGameCtrl      = class('OutlayGameCtrl', cc.load('BaseCtrl'))
local MainCtrl       = require('src.app.plugins.mainpanel.MainCtrl'):getInstance()

my.addInstance(OutlayGameCtrl)
OutlayGameCtrl.RUN_ENTERACTION = true

local iapPlugin 	= plugin.AgentManager:getInstance():getIAPPlugin()
local json 			= cc.load('json').json

local md5Key		= 'MW0N39VPLWAIB2D5'
local js2LuaScheme	= 'lua'

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

function OutlayGameCtrl:onCreate(...)
	-- DeviceUtils:getInstance():setInterfaceOrientation(cc.exports.InterfaceOrientation.kPortrait)
	-- display.toggleOrientation()

    my.dataLink(cc.exports.DataLinkCodeDef.CHUAN_QI_BTN_PRESENT)

	self._isWebLoadFinish = false
	self._isWebLoadFailed = false
	local viewNode = self:setViewIndexer(OutlayGameView:createViewIndexer(self))

	local params = {...}
    self._url = params[1].url

    self:init()
    self:showWeb()
end

function OutlayGameCtrl:retry()
	self:init()
    self:showWeb()
end

function OutlayGameCtrl:removeSelfInstance( )
	-- DeviceUtils:getInstance():setInterfaceOrientation(cc.exports.InterfaceOrientation.kLandscape)
	-- display.toggleOrientation()
	OutlayGameCtrl.super.removeSelfInstance(self)
end

function OutlayGameCtrl:goBack()
	-- 退出联运时打开背景音乐关闭网页音效
	self:stopAllSounds()
	-- MainCtrl:playBGM()
	self:removeSelfInstance()
	-- my.informPluginByName({pluginName = 'MoreGameCtrl'})
end

function OutlayGameCtrl:stopAllSounds()
    audio.stopAllSounds()
end

function OutlayGameCtrl:onKeyBack()
	if not DeviceUtils:getInstance():isNetworkConnected() 
	or not self._isWebLoadFinish
	or self._isWebLoadFailed then
		self:playEffectOnPress()
		self:goBack()
		print('onKeyBack goBack')
		return
	end

	if self._viewNode and self._viewNode.webview then
		self._viewNode.webview:evaluateJS('onKeyBack()')
		print('onKeyBack evaluateJS')
	end
end

function OutlayGameCtrl:onExit()
	OutlayGameView:destroyWebview(self._viewNode)
	OutlayGameCtrl.super.onExit(self)
	print('WebPage onExit')
end

function OutlayGameCtrl:init()
	if not self._viewNode.errorLayer then
		release_print('member variable is nil!!!')
		return
	end

    if DeviceUtils:getInstance():isNetworkConnected() then
	    OutlayGameView:ShowError(self._viewNode, false)
    else
	    OutlayGameView:ShowError(self._viewNode, true)
    end

	iapPlugin:setCallback(function(code, msg)
		print('code', code)
		print('msg', msg)
		
		if code >= PayResultCode.kRechargeDirectlySuccess and code <= PayResultCode.kRechargeDirectlyCanceled then
			if self._viewNode and self._viewNode.webview then
				self._viewNode.webview:evaluateJS('onRechargeDirectlyCallback(' .. code .. ',\'' .. msg ..'\')')
			end
		end
	end)
	
	local function jsCallback(webview, url)
        local funcName, param = parseJsCallbackUrl(url)
        print('jsCallbackUrl', url, funcName)
		if param then
			dump(param)
		end
        if funcName == 'exit' then
			self:goBack()
		elseif funcName == 'refresh' then
			if DeviceUtils:getInstance():isNetworkConnected() then
				if self._viewNode and self._viewNode.webview then
					self._viewNode.webview:reload()
				end
			else
				OutlayGameView:ShowError(self._viewNode, true)
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
				if self._viewNode and self._viewNode.webview then
					self._viewNode.webview:evaluateJS(callback .. '(\'' .. jsonParam .. '\')')
				end
			end
        end
	end
	self._viewNode.webview:setJavascriptInterfaceScheme(js2LuaScheme)
	self._viewNode.webview:setOnJSCallback(jsCallback)
	self._viewNode.webview:setOnShouldStartLoading(function(wv, url)
        print('url onShouldStartLoading', url)
        return true
	end)
	self._viewNode.webview:setOnDidFinishLoading(function(wv, url)
        print('url onDidFinishLoading', url)
		self._isWebLoadFinish = true
		-- 关闭大厅背景音乐
		cc.exports.hallBGMplaying = false
		-- MainCtrl:stopBGM()
        return true
	end)
	self._viewNode.webview:setOnDidFailLoading(function(wv, url)
        print('url onDidFailLoading', url)
		self._isWebLoadFailed = true
        return true
	end)
end

function OutlayGameCtrl:showWeb()
	if self._viewNode then
		self._viewNode.webview:loadURL(self._url)
	end
end

return OutlayGameCtrl
--endregion
