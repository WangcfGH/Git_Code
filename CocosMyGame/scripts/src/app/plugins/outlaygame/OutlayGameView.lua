--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local OutlayGameView = class('OutlayGameView', cc.load('ViewAdapter'))


OutlayGameView.viewConfig={
	'res/hallcocosstudio/outlaygame/outlaygame.csb',
}

function OutlayGameView:isIPhoneX()
    local modelList = {
        "iPhone10,3",   --iPhoneX
        "iPhone10,6",   --iPhoneX
        "iPhone11,8",   --iPhoneXR
        "iPhone11,2",   --iPhoneXS
        "iPhone11,4",   --iPhoneXS Max
        "iPhone11,6",   --iPhoneXS Max
    }
    local phoneModel = DeviceUtils:getInstance():getPhoneModel()

    for nIndex, model in ipairs(modelList) do
        if model == phoneModel then
            return true;
        end
    end
    
    return false
end

function OutlayGameView:onCreateView(viewNode, ctrl)
	self._ctrl = ctrl
	self:createWebview(viewNode)
end

function OutlayGameView:createWebview(viewNode)
    local visibleSize 	= cc.Director:getInstance():getVisibleSize()

	local errorLayer = cc.Layer:create()
	viewNode:addChild(errorLayer)
    errorLayer:setContentSize(visibleSize.width, visibleSize.height)
	errorLayer:setAnchorPoint(0, 0)

    local errorBG = cc.LayerColor:create(cc.c3b(255, 255, 255), visibleSize.width, visibleSize.height)
    errorLayer:addChild(errorBG)

    local errorLogo = cc.Sprite:create('res/hall/hallpic/outlaygame/ErrorLogo.png')
    errorLayer:addChild(errorLogo)
    errorLogo:setAnchorPoint(0.5, 0.5)
    errorLogo:setPosition(visibleSize.width / 2 + 5, visibleSize.height / 2)

    local function onBack(sender, eventType)
	    if eventType == ccui.TouchEventType.ended then
           self._ctrl:goBack()
	    end
	end
	local btnBack = ccui.Button:create('res/hall/hallpic/outlaygame/BtnBack_Normal.png', 'res/hall/hallpic/outlaygame/BtnBack_Press.png')
	errorLayer:addChild(btnBack)
    btnBack:setAnchorPoint(1, 1)
    btnBack:setPosition(visibleSize.width / 2 - 5, visibleSize.height / 2 - 170)
	btnBack:addTouchEventListener(onBack)

    local function onRetry(sender, eventType)
	    if eventType == ccui.TouchEventType.ended then
			self._ctrl:retry()
	    end
	end
	local btnBack = ccui.Button:create('res/hall/hallpic/outlaygame/BtnRetry_Normal.png', 'res/hall/hallpic/outlaygame/BtnRetry_Press.png')
	errorLayer:addChild(btnBack)
    btnBack:setAnchorPoint(0, 1)
    btnBack:setPosition(visibleSize.width / 2 + 5, visibleSize.height / 2 - 170)
	btnBack:addTouchEventListener(onRetry)
	viewNode.errorLayer = errorLayer
	-- viewNode.errorLayer:setVisible(true)

	local webView = viewNode.webview
	if (not webView) then
		webView = ccexp.WebView:create()
        viewNode:addChild(webView)
        webView:setAnchorPoint(cc.p(0, 0))
        if self:isIPhoneX() then
            webView:setContentSize(cc.size(display.width + 170, display.height + 40))
            webView:setPosition(cc.p(-85,-40))
        else
            webView:setContentSize(cc.size(visibleSize.width, visibleSize.height))
            webView:setPosition(cc.p(0, 0))
        end
        --webView:setContentSize(cc.size(visibleSize.width, visibleSize.height))
        webView:setScalesPageToFit(true)
		--webView:setAnchorPoint(0.5, 0.5)
		--webView:setPosition(display.center)

		viewNode.webview = webView
	end
	webView:setVisible(true)
end

function OutlayGameView:ShowError(viewNode, show)
	if viewNode.errorLayer then
		viewNode.errorLayer:setVisible(show)
	end

	if viewNode.webview then
		viewNode.webview:setVisible(not show)
	end
end

function OutlayGameView:destroyWebview(viewNode)
    if viewNode.webView then
        viewNode.webView:setOnDidFinishLoading(function() -- close callback first
            -- do nothing
        end)
        viewNode.webView:removeFromParent()
    end
	viewNode.webView = nil
	viewNode.errorLayer = nil
end

return OutlayGameView

--endregion
