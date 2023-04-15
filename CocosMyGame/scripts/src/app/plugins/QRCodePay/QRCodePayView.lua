local viewCreator = cc.load("ViewAdapter"):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/QRCodePay/Layer_QRCodePay.csb',
    {
        panelAnimation = 'Panel_Main.Panel_Animation',
        {
            _option = {
                prefix = 'Panel_Main.Panel_Animation.'
            },
            btnClose = 'Btn_Close',
            panelPayInfo = 'Panel_PayInfo',
            {
                _option = {
                    prefix = 'Panel_PayInfo.'
                },
                btnAliPay = 'Btn_AliPay',
                btnWeChatPay = 'Btn_WeChatPay',
                valueProductName = 'Value_ProductName',
                valueProductPrice = 'Value_ProductPrice',
            },
            panelQRCode = 'Panel_QRCode',
            {
                _option  = {
                    prefix = 'Panel_QRCode.'
                },
                btnBackToPayInfo = 'Btn_BackToPayInfo',
                panelWebView = 'Panel_WebView',
                textPayTip = 'Text_PayTip'
            }
        },
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
    viewNode.webView = webview
end

return viewCreator
