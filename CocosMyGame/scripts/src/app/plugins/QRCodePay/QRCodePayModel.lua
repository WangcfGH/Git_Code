local QRCodePayModel = class("QRCodePayModel", import("src.app.GameHall.models.BaseModel"))
my.addInstance(QRCodePayModel)

QRCodePayModel.EVENT_PAY_RESULT = 'EVENT_PAY_RESULT'

function QRCodePayModel:onCreate()
    self._iapPlugin = nil
    self._payCallBack = nil
    self:wrapIAPPlugin()
end

-- 劫持IAPPlugin的回调及支付接口
function QRCodePayModel:wrapIAPPlugin()
    self._iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
    if not self._iapPlugin then return end
    local that = self
    local iapplugin_setCallback = self._iapPlugin.setCallback
    self._iapPlugin.setCallback = function(self, callback)
        if cc.exports.isQRCodePaySupported() then
            that._payCallBack = callback
        else
            iapplugin_setCallback(self, callback)
        end
    end

    local iapplugin_payForProduct = self._iapPlugin.payForProduct
    self._iapPlugin.payForProduct = function(self, params)
        if cc.exports.isQRCodePaySupported() then
            my.informPluginByName({ pluginName = 'QRCodePayCtrl', params = { payInfo = params } })
        else
            iapplugin_payForProduct(self, params)
        end
    end
end

function QRCodePayModel:onPayResult(code, msg)
    if self._payCallBack and type(self._payCallBack) == 'function' then
        self._payCallBack(code, msg)
        self._payCallBack = nil
    end
end

function QRCodePayModel:onExitQRCodePay()
    if self._payCallBack and type(self._payCallBack) == 'function' then
        self._payCallBack(PayResultCode.kPayCancel, '')
        self._payCallBack = nil
    end
end

function QRCodePayModel:dealPayResult(payResult)
    self:dispatchEvent({name = QRCodePayModel.EVENT_PAY_RESULT})
end

return QRCodePayModel
