local MobileInputCtrl = class("MobileInputCtrl", import("src.app.plugins.inputplugin.BaseInputCtrl"))

MobileInputCtrl.viewCreater = import('src.app.plugins.inputplugin.MobileInputView')

-- params = {
--     jsonFormat = "mobile = %s",
--     onInputFinished = function(jsonResult, onInputValid)
--         print(jsonResult)
--     end,
--     defaultPhoneNum = "12321321"
-- }

function MobileInputCtrl:commitPhoneNum()
    local viewNode = self._viewNode
    local phoneNum1 = viewNode.editBoxPhoneNum:getString()
    local phoneNum2 = viewNode.editBoxPhoneNumCheck:getString()
    if self._viewNode:isCheckRight() then
        self._onInputFinished(string.format(self._jsonFormat, phoneNum1), handler(self, self.removeSelfInstance))
    else
        self:informPluginByName("TipPlugin", {tipString ="请确认您输入的号码是否正确"})
    end
end

function MobileInputCtrl:registEditBoxEvent()
    self._viewNode.editBoxPhoneNum:onEditHandler(handler(self, self.onPhoneNumInput))
    self._viewNode.editBoxPhoneNumCheck:onEditHandler(handler(self, self.onCheckPhoneNumInput))
end

function MobileInputCtrl:onCheckPhoneNumInput(event)
    local phoneNum = tonumber(self._viewNode.editBoxPhoneNum:getString())
    self._viewNode:setCheckPhoneNumValid(self:isPhoneNumInputValid(event.target:getString()) and phoneNum == tonumber(event.target:getString()))
end

function MobileInputCtrl:onPhoneNumInput(event)
    self._viewNode:setPhoneNumValid(self:isPhoneNumInputValid(event.target:getString()))
    local phoneNum = tonumber(self._viewNode.editBoxPhoneNum:getString())
    self._viewNode:setCheckPhoneNumValid(self:isPhoneNumInputValid(event.target:getString()) and phoneNum == tonumber(self._viewNode.editBoxPhoneNumCheck:getString()))
end

return MobileInputCtrl