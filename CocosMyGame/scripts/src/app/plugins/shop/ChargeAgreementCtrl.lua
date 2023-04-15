local ChargeAgreementCtrl = class('ChargeAgreement',cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.shop.ChargeAgreementView')

my.addInstance(ChargeAgreementCtrl)

function ChargeAgreementCtrl:onCreate(fatherCtrl, params)
    self._fatherCtrl = fatherCtrl
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnClose)
    my.runPopupAction(viewNode.panelAnimation:getRealNode())
    self:initEventListeners()
    self:loadWebView()
end

function ChargeAgreementCtrl:initEventListeners()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    self:listenTo(netProcess, netProcess.EventEnum.SoketError, handler(self, self.removeSelfInstance))
    self:listenTo(netProcess, netProcess.EventEnum.NetWorkError, handler(self, self.removeSelfInstance))
    self:listenTo(netProcess, netProcess.EventEnum.KickedOff, handler(self, self.removeSelfInstance))
    -- self:listenTo(netProcess, netProcess.EventEnum.LoginOff, handler(self, self.removeSelfInstance))
end

function ChargeAgreementCtrl:onExit()
    self:removeEventListeners()
end

function ChargeAgreementCtrl:removeEventListeners()
    self:removeEventHosts()
end

function ChargeAgreementCtrl:loadWebView()
    local webView = self._viewNode.panelWebView:getChildByName('WebView')
    if webView then
        webView:setVisible(true)
        webView:loadURL("https://tcysysres.tcy365.com/m/recharge_appoint.html")
    end
end

return ChargeAgreementCtrl