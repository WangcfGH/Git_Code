local viewCreator = cc.load("ViewAdapter"):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/shop/Layer_ChargeAgreement.csb',
    {
        panelAnimation = 'Panel_Main.Panel_Animation',
        panelWebView = 'Panel_Main.Panel_Animation.Panel_WebView',
        btnClose = 'Panel_Main.Panel_Animation.Button_Close',
    }
}

function viewCreator:onCreateView(viewNode)
    local webview = ccexp.WebView:create()
    local viewSize = viewNode.panelWebView:getContentSize()

    webview:setScalesPageToFit(true)
    webview:setContentSize(viewSize)
    webview:setAnchorPoint(cc.p(0.5, 0.5))
    webview:setPosition(viewSize.width / 2, viewSize.height / 2)
    webview:setName("WebView")
    webview:setVisible(false)
    viewNode.panelWebView:addChild(webview)
end

return viewCreator
