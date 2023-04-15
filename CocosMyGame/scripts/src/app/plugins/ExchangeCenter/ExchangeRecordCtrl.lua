local ExchangeRecordCtrl = class('ExchangeRecordCtrl',cc.load('BaseCtrl'))
local ExchangeRecordView = import('src.app.plugins.ExchangeCenter.ExchangeRecordView')
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

function ExchangeRecordCtrl:onCreate(params,...)
    self._params = params

    self:setView(ExchangeRecordView)
    ExchangeRecordView:setCtrl(self)

	local viewNode = self:setViewIndexer(ExchangeRecordView:createViewIndexer())

    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.MY_TICKET_RECORD_UPDATED, handler(self, self.onExchangeRecordDataUpdated))
end

function ExchangeRecordCtrl:onEnter()
    ExchangeRecordCtrl.super.onEnter(self)
    ExchangeRecordView:refreshView(self._viewNode)

end

function ExchangeRecordCtrl:onExit()
    ExchangeRecordView:onExit()
    ExchangeRecordCtrl.super.onExit(self)

end

function ExchangeRecordCtrl:onExchangeRecordDataUpdated()
    ExchangeRecordView:refreshView(self._viewNode)
end

return ExchangeRecordCtrl
