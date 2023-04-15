local ActivityJumpWebCtrl = class("ActivtiyJumpWebCtrl", cc.load('BaseCtrl'))
local viewCreater = require('src.app.plugins.activitycenter.ActivityJumpWebView')

function ActivityJumpWebCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    viewNode.closeBtn:addClickEventListener(function() my.playClickBtnSound() self:activityJumpWebCleanUp() end)
    viewNode.forwardBtn:addClickEventListener(function() my.playClickBtnSound() self:goForward() end)
    viewNode.backBtn:addClickEventListener(function() my.playClickBtnSound() self:goBack() end)
    viewNode.freshBtn:addClickEventListener(function() my.playClickBtnSound() self:goFresh() end)

    if params and params.url and not self._webview then   
        self._webview = ccexp.WebView:create()
        self._webview:setScalesPageToFit(true)
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        self._webview:setContentSize(cc.size(visibleSize.width, visibleSize.height - 80))
        self._webview:setPosition(visibleSize.width/2, (visibleSize.height - 80)/2)     
        self._webview:loadURL(params.url)
        self._webview:setVisible(true)
        viewNode.contentPanel:addChild(self._webview)
    end
end

function ActivityJumpWebCtrl:activityJumpWebCleanUp()
    if self._webview then
        self._webview:reload()
        self._webview:removeFromParent()
    end
    self:removeSelfInstance()
end

function ActivityJumpWebCtrl:goBack()
    if self._webview then
        self._webview:goBack()
    end
end

function ActivityJumpWebCtrl:goForward()
    if self._webview then
        self._webview:goForward()
    end
end

function ActivityJumpWebCtrl:goFresh()
    if self._webview then
        self._webview:reload()
    end
end

return ActivityJumpWebCtrl