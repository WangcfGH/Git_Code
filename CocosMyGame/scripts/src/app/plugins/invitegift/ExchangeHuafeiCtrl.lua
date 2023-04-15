
local ExchangeHuafeiCtrl    = class('ExchangeHuafeiCtrl',  cc.load('BaseCtrl'))
local viewCreater   = import('src.app.plugins.invitegift.ExchangeHuafeiView')

local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
ExchangeHuafeiCtrl.RUN_ENTERACTION = true

function ExchangeHuafeiCtrl:onCreate( params )
    self._callback = params.cb
    self._content = params.content or ""
    self._exchangeType = params.exchangeType 
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    local image="res/hallcocosstudio/images/plist/NewUserInviteGift/editbox.png"
    self.editbox = my.createEditBox(viewNode.textPhoneNum,viewNode.textPhoneNum,image,cc.c3b(252, 237, 167))
    self:addClickEvent(viewNode.btnGet, handler(self, self.onExchange))
end


function ExchangeHuafeiCtrl:onExchange()
    self:playEffectOnPress()
    local viewNode = self._viewNode
    local textPhoneNum=self.editbox:getString()
    local subs =  textPhoneNum:sub(1,1)
	if tonumber(subs) ~= 1 or string.len( textPhoneNum ) < 11 or not my.isNumberByString( textPhoneNum ) then
        self:informPluginByName('TipPlugin',{tipString="请输入正确的手机号"})
        return
	end
   
    local function sendExchange()
        if self._exchangeType == NewUserInviteGiftModel.ExchangeType.DailyShare then
            -- local DailyShareActiveModel   = import('src.app.plugins.dailyshareactive.DailyShareActiveModel'):getInstance() 
            -- DailyShareActiveModel:requireGetHuaFei(textPhoneNum)
        elseif self._exchangeType == NewUserInviteGiftModel.ExchangeType.NewUser then
            NewUserInviteGiftModel:requireGetAward(textPhoneNum)
        elseif self._exchangeType == NewUserInviteGiftModel.ExchangeType.OldUser then
            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:requireGetAward(textPhoneNum)
        end
        
        print("兑换话费号码：",textPhoneNum)
        self:removeSelfInstance()
    end
   
    my.informPluginByName({pluginName='NewUserInviteTipCtr', params = { phone = textPhoneNum ,item = self._content,callBack = sendExchange}})
    self:removeSelfInstance()

end

return ExchangeHuafeiCtrl
