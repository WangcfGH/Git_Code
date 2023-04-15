--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/shophsox/outlaygame.csb',
}

local visibleSize     = cc.Director:getInstance():getVisibleSize()

function viewCreator:onCreateView(viewNode, ctrl)
    self._ctrl = ctrl
    self:createWebview(viewNode)
end

function viewCreator:createWebview(viewNode)
    local Panel_Main = viewNode:getChildByName("Panel_Main")
    Panel_Main:setContentSize(visibleSize.width, visibleSize.height)
    Panel_Main:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    Panel_Main:setBackGroundColor(cc.c3b(0, 0, 0))
    Panel_Main:setBackGroundColorOpacity(255 * 0.9)
    --Panel_Main:setBackGroundColorOpacity(0)
    --Panel_Main:setTouchEnabled(false)
    Panel_Main:setAnchorPoint(0.5, 0.5)
    Panel_Main:setPosition(display.center)
    --
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
    local btnRetry = ccui.Button:create('res/hall/hallpic/outlaygame/BtnRetry_Normal.png', 'res/hall/hallpic/outlaygame/BtnRetry_Press.png')
    errorLayer:addChild(btnRetry)
    btnRetry:setAnchorPoint(0, 1)
    btnRetry:setPosition(visibleSize.width / 2 + 5, visibleSize.height / 2 - 170)
    btnRetry:addTouchEventListener(onRetry)
    viewNode.errorLayer = errorLayer

    self:initWeb(viewNode)
    
    -- 网页右侧美女图
    local spBubble = cc.Scale9Sprite:create('res/hall/hallpic/outlaygame/img_qipao05.png')
    local spWoman = cc.Sprite:create('res/hall/hallpic/outlaygame/img_woman02.png')
    local text = ccui.Text:create()
    Panel_Main:addChild(spWoman)
    spWoman:addChild(spBubble)
    spWoman:addChild(text)
    text:setString("充值完成将直接\n进入您的账户")
    text:setFontSize(24)
    text:setColor(cc.c3b(0xEF, 0xC8, 0x92))
    local xStart = 0
    --[[
    if cc.exports.isIPhoneFullScreen() then
        xStart = 80
    else
        xStart = 0
    end
    ]]
    spWoman:setPosition(visibleSize.width - ((visibleSize.width - (xStart + visibleSize.width/2)) / 2) + 150, 200)
    spBubble:setPosition(-25, 685)
    text:setPosition(-23, 695)
    spBubble:setCapInsets(CCRectMake(47, 30, 1, 1))
    spBubble:setContentSize(cc.size(200, 100)) 

    -- close
    local btnClose = ccui.Button:create('res/hall/hallpic/outlaygame/Hall_Btn_Close.png', 'res/hall/hallpic/outlaygame/Hall_Btn_Close.png')
    Panel_Main:addChild(btnClose)
    btnClose:setAnchorPoint(1, 1)
    btnClose:setPosition(visibleSize.width-40, visibleSize.height -40)
    btnClose:addTouchEventListener(onBack)
end

function viewCreator:initWeb(viewNode)
    local webView = viewNode.webView
    if (not webView) then
        local textLoading = ccui.Text:create()
        textLoading:setString("加载中 请稍后 ...")
        textLoading:setFontSize(24)
        textLoading:setColor(cc.c3b(0xEF, 0xC8, 0x92))
        textLoading:setPosition(visibleSize.width/4, display.center.y)
        viewNode:addChild(textLoading)
        webView = ccexp.WebView:create()
        viewNode:addChild(webView)
        webView:setContentSize(cc.size(visibleSize.width/2, visibleSize.height))
        webView:setScalesPageToFit(true)
        webView:setAnchorPoint(0, 0.5)
        --这里判断ios是否是铺满全屏
        --[[
        if cc.exports.isIPhoneFullScreen() then
            webView:setPosition(cc.p( 80, display.center.y))
        else
        ]]
            webView:setPosition(cc.p(0 , display.center.y))
        --end
        viewNode.webView = webView
        webView:setVisible(true)
    end
end

function viewCreator:ShowError(viewNode, show)
    if viewNode.errorLayer then
        viewNode.errorLayer:setVisible(show)
    end

    if viewNode.webview then
        viewNode.webview:setVisible(not show)
    end
end

function viewCreator:destroyWebView(viewNode)
    if viewNode.webView then
        viewNode.webView:setOnDidFinishLoading(function() -- close callback first
            -- do nothing
        end)
        viewNode.webView:removeFromParent()
    end
    viewNode.webView = nil
    viewNode.errorLayer = nil
end

return viewCreator

--endregion
