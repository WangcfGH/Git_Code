local SmallGameView = class('SmallGameView', cc.Node)

function SmallGameView:ctor()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    
    local webView = ccexp.WebView:create()
    webView:setAnchorPoint(cc.p(0,0))
    self._webView = webView
    if self:isIPhoneX() then
        self:fitSizeOnIPhoneX();
    else
        webView:setContentSize(visibleSize)
        webView:setPosition(cc.p(0,0))
    end
    webView:setScalesPageToFit(true)
    webView:setJavascriptInterfaceScheme('lua')
    webView:setTransparent(0)
    webView:setName("GAME_WEB")
    webView:setOnShouldStartLoading(function(wv, url)
        print('url setOnShouldStartLoading', url)
        return true
    end)
    webView:setOnDidFinishLoading(function(wv, url)
        print('url setOnDidFinishLoading', url)
        self._finishedLoading = true
        return true
	end)
	webView:setOnDidFailLoading(function(wv, url)
        print('url setOnDidFailLoading', url)
        return true
	end)
    self:addChild(webView)
end

function SmallGameView:getRealNode()
    return self
end

function SmallGameView:getWebView()
    return self._webView
end

function SmallGameView:isIPhoneX()
    local phoneModel = DeviceUtils:getInstance():getPhoneModel()
    local mainVer = tonumber(phoneModel:match("iPhone(%d+),%d+"))
    if (mainVer and mainVer >= 11)
    or phoneModel == "iPhone10,3" or phoneModel == "iPhone10,6" then
        return true
    else
        return false
    end
end

function SmallGameView:fitSizeOnIPhoneX()
    local phoneModel = DeviceUtils:getInstance():getPhoneModel()
    if phoneModel == "iPhone11,6" or phoneModel == "iPhone11,4" -- IPhoneXS Max 要特殊处理
    or phoneModel == "iPhone10,3" or phoneModel == "iPhone10,6" then --IPhoneX 也和其他手机不一样
        self._webView:setContentSize(cc.size(display.width + 170, display.height + 39))
        self._webView:setPosition(cc.p(-85,-39))
    else
        self._webView:setContentSize(cc.size(display.width + 154, display.height + 37))
        self._webView:setPosition(cc.p(-77,-37))
    end
end

return SmallGameView