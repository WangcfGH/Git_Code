
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/exchange/exchange.csb',{
		{
            _option={prefix='Operate_Panel.'},
            topBarPanel='Panel_TopBar',
            {
                _option={prefix='Panel_TopBar.'},
                closeBt='Btn_Back',
            }
		},
	}
}

function viewCreator:onCreateView(viewNode)
    local webView = viewNode.webView
    if not webView then
        local marginTop = viewNode.topBarPanel:getSize().height
        webView = ccexp.WebView:create()
        viewNode:addChild(webView)
        local visibleRect = cc.Director:getInstance():getOpenGLView():getVisibleRect()
        local wvSize = cc.size(visibleRect.width, visibleRect.height - marginTop)
        webView:setPosition(cc.p(visibleRect.x + wvSize.width / 2, visibleRect.y + wvSize.height / 2))
        webView:setAnchorPoint(cc.p(0.5,0.5))
        webView:setTransparent(0)
        webView:setContentSize(wvSize)

        webView:setOnShouldStartLoading(function(wv,url)
            print(url)
            return true
        end)
        viewNode.webView = webView


        cc.exports.zeroBezelNodeAutoAdapt(viewNode.webView)
        if visibleRect.width/visibleRect.height >= 2 then
            local sizeAutoEnd = webView:getContentSize()
            wvSize = cc.size(sizeAutoEnd.width, sizeAutoEnd.height - marginTop)
            webView:setContentSize(wvSize)
        end
    end
    webView:setVisible(true)
end

return viewCreator
