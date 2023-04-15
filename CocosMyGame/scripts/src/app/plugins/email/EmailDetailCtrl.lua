local EmailDetailCtrl = class("EmailDetailCtrl",  cc.load("BaseCtrl"))

EmailDetailCtrl.viewCreater = import('src.app.plugins.email.EmailDetailView')
EmailDetailCtrl.RUN_ENTERACTION = true

function EmailDetailCtrl:ctor(params)
    self._emailInfo = params.emailInfo
    self._emailList = params.emailList
    --之所以需要传参而不是直接从model获取是因为随着邮件列表的操作model层邮件的顺序会变化，上一封下一封需要和邮件列表的顺序一致
    EmailDetailCtrl.super.ctor(self, params)
end

function EmailDetailCtrl:onCreate()
    self:setViewIndexer(self.viewCreater:createViewIndexer(self._emailInfo))
    self._emailModel = mymodel("hallext.EmailModel"):getInstance()
    self._emailConfig = import("src.app.HallConfig.EmailConfig")
--    self._emailList = clone(self._emailModel:getLocalEmailList())
    --读取邮件 领取物品后model层会重新整理邮件顺序，所以自己保存一份顺序
    self:registWidgetEvents()
end

function EmailDetailCtrl:onEnter()
    EmailDetailCtrl.super.onEnter(self)

    self._emailModel:readEmailIfNotRead(self._emailInfo.EmailId)
end

function EmailDetailCtrl:registWidgetEvents()
    local viewNode = self._viewNode
    local function _handler(func)
        return function(...)
            self:playEffectOnPress()
            self[func](self, ... )
        end
    end
    viewNode.btnPre:addClickEventListener(_handler("showLastEmail"))
    viewNode.btnNext:addClickEventListener(_handler("showNextEmail"))
    viewNode.btnClose:addClickEventListener(_handler("removeSelfInstance"))
    viewNode.btnDelete:addClickEventListener(_handler("deleteEmail"))
    viewNode.btnReward:addClickEventListener(_handler("takeReward"))
    viewNode.btnNoticeClose:addClickEventListener(_handler("removeSelfInstance"))
    viewNode.btnRewardClose:addClickEventListener(_handler("removeSelfInstance"))
end

function EmailDetailCtrl:initEventHandler()
    local emailModel = self._emailModel
    local function filter(host, interface)
        return function(event)
            interface(host, event.value)
        end
    end
    -- self:listenTo(emailModel, emailModel.EVENT_EMAILLIST_UPDATED,   filter(self,self.onMailListUpdated))
    self:listenTo(emailModel, emailModel.EVENT_REWARD_GOT,          filter(self,self.onRewardGot))
    -- self:listenTo(emailModel, emailModel.EVENT_EMAILREWARD_GOT,     filter(self,self.onMailRewardGot))
    -- self:listenTo(emailModel, emailModel.EVENT_ALLREWARD_GOT,       filter(self,self.onAllRewardGot))
    -- self:listenTo(emailModel, emailModel.EVENT_EMAIL_READ,          filter(self,self.onMailRead))
    -- self:listenTo(emailModel, emailModel.EVENT_EMAIL_DELETED,       filter(self,self.onMailDeleted))
    -- self:listenTo(emailModel, emailModel.EVENT_OPERATE_FAILED,      filter(self,self.onOperateFailed))
    -- self:listenTo(emailModel, emailModel.EVENT_NEED_INPUT,          filter(self,self.onNeedInput))
    -- self:listenTo(emailModel, emailModel.EVENT_REWARDED_BEFORE,     filter(self,self.onRewardedBefore))
    -- self:listenTo(emailModel, emailModel.EVENT_NEWEMAIL_GOT,        filter(self,self.onNewEmailGot))
end

function EmailDetailCtrl:showLastEmail()
    local emailList = self._emailList
    local lastEmail
    for count, emailInfo in pairs(emailList) do
        if emailInfo.EmailId == self._emailInfo.EmailId then
            --由于邮件列表的邮件数据有备份，所以点开下一封的时候需要考虑一下该邮件是否已经被删除
            local plus = 1
            repeat
                lastEmail   = emailList[count - plus]
                plus        = plus + 1
            until lastEmail == nil or table.nums(self._emailModel:getEmailInfo(lastEmail.EmailId)) > 0
            break
        end
    end
    if not lastEmail then
        self:informPluginByName("TipPlugin", {tipString = self._emailConfig.description.noMoreMail})
    else
        self._emailInfo = lastEmail
        self._viewNode:setEmailInfo(lastEmail)
        self._emailModel:readEmailIfNotRead(self._emailInfo.EmailId)
    end
end

function EmailDetailCtrl:showNextEmail()
    local emailList = self._emailList
    local nextEmail
    for count, emailInfo in pairs(emailList) do
        if emailInfo.EmailId == self._emailInfo.EmailId then
            --由于邮件列表的邮件数据有备份，所以点开上一封的时候需要考虑一下该邮件是否已经被删除
            local plus = 1
            repeat
                nextEmail   = emailList[count + plus]
                plus        = plus + 1
            until nextEmail == nil or table.nums(self._emailModel:getEmailInfo(nextEmail.EmailId)) > 0
            break
        end
    end
    if not nextEmail then
        self:informPluginByName("TipPlugin", {tipString =self._emailConfig.description.noMoreMail})
    else
        self._emailInfo = nextEmail
        self._viewNode:setEmailInfo(nextEmail)
        self._emailModel:readEmailIfNotRead(self._emailInfo.EmailId)
    end
end

function EmailDetailCtrl:deleteEmail()
    local awardNames = {}
    for _, award in pairs (self._emailInfo.EmailAwardList or {}) do
        if not award.isRewarded then
            table.insert( awardNames, award.ItemName)
        end
    end
    local tipContent = #awardNames == 0 and self._emailConfig.description.ensureDeleteEmail
                        or self._emailConfig.description.ensureDeleteAwardEmail
--                       or string.format(self._emailConfig.description.ensureDeleteAwardEmail, table.concat(awardNames, "、"))

    self:informPluginByName("ChooseDialog", {
        onOk = function()
            self._emailModel:deleteEmail(self._emailInfo.EmailId)
            self:removeSelfInstance()
        end,
        tipContent = tipContent
    })
end

function EmailDetailCtrl:takeReward()
    self._emailModel:takeAwardByEmailID(self._emailInfo.EmailId)
    self:removeSelfInstance()
end

function EmailDetailCtrl:onRewardGot(value)
    printf("EmailDetailCtrl：onRewardGot: emailId = %s, itemId = %s", tostring(value.emailId), tostring(value.itemId))
    self._viewNode:setItemAwardStatus(value.itemId, true)
end

return EmailDetailCtrl