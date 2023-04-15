local EmailListCtrl = class("EmailListCtrl", cc.load("BaseCtrl"))

import("src.app.plugins.email.EmailViewFactory")

EmailListCtrl.viewCreater = import('src.app.plugins.email.EmailPanelView')

EmailListCtrl.RUN_ENTERACTION = true
function EmailListCtrl:onCreate(params)
    self:setViewIndexer(self.viewCreater:createViewIndexer())
    self._emailModel = mymodel("hallext.EmailModel"):getInstance()
    self._emailConfig = import("src.app.HallConfig.EmailConfig")
    self._rewardWaitingMap = {}
    self:initEventHandler()
    self:registWidgetEvents()
end

--------------------------------------------------------------------------------------------------------
--数据层事件处理
--[Comment]
--value = {emailList = self._mailList}
function EmailListCtrl:onMailListUpdated(value)
    print("onMailListUpdated")
    --直接重新刷新邮件
    self:showEmailList()
end

--[Comment]
--value = {emailId = emailId, itemId = itemId}
function EmailListCtrl:onRewardGot(value)
    printf("onRewardGot: emailId = %s, itemId = %s", tostring(value.emailId), tostring(value.itemId))
    if type(self._rewardWaitingMap[value.itemId]) == "function" then
        self._rewardWaitingMap[value.itemId]()
        self._rewardWaitingMap[value.itemId] = nil
    end

    --领取成功话费实物等需要输入的物品之后自动领取邮件剩下的物品
    local awardInfo = self._emailModel:getAwardInfo(value.emailId, value.itemId)
    if awardInfo.ItemTypeID == ItemType.REALITEM
    or awardInfo.ItemTypeID == ItemType.MOBILEBILL then
        self._emailModel:takeAwardByEmailID(value.emailId)
    end
end

--[Comment]
--value = {emailId = emailId}
function EmailListCtrl:onMailRewardGot(value)
    printf("onMailRewardGot: emailId = %s", tostring(value.emailId))
    self:setEmailRewarded(value.emailId)
    self:setEmailCount()
    self:showRewardedList()
end

--[Comment]
--value = {}
function EmailListCtrl:onAllRewardGot(value)
    printf("onAllRewardGot")
end

--[Comment]
--value = {emailId = emailId}
function EmailListCtrl:onMailRead(value)
    self:setEmailCount()
    self:setEmailRead(value.emailId)
end

--[Comment]
--value = {emailId = emailId}
function EmailListCtrl:onMailDeleted(value)
    self:deleteEmail(value.emailId)
end

--[Comment]
--value = {code = code, msg = msg}
function EmailListCtrl:onOperateFailed(value)
    self:informPluginByName("TipPlugin", {tipString = value.msg})
end

--[Comment]
--value = {emailId = emailId, itemId = itemId, callback = callback}
--callback require extendJson as input
function EmailListCtrl:onNeedInput(value)
    local awardInfo = self._emailModel:getAwardInfo(value.emailId, value.itemId)
    if awardInfo.ItemTypeID == ItemType.MOBILEBILL then
        self:showMobileInput(value.callback, awardInfo)
    elseif awardInfo.ItemTypeID == ItemType.REALITEM then
        self:showAddressInput(value.callback, awardInfo)
    else
        printError("unexpected itemtype with input requirement")
        dump(value)
    end
end

--[Comment]
--value = {emailId = emailId, itemId = itemId}
function EmailListCtrl:onRewardedBefore(value)
    if self._emailModel:isEmailRewarded(value.emailId) then
        self:setEmailRewarded(value.emailId)
        self:setEmailCount()
    end
    if type(self._rewardWaitingMap[value.itemId]) == "function" then
        self._rewardWaitingMap[value.itemId]()
        self._rewardWaitingMap[value.itemId] = nil
    end
end

--[Comment]
--value = {newMails = newMails}
function EmailListCtrl:onNewEmailGot(value)
    -- for _, emailInfo in pairs(value.newMails) do
    --     self:addEmail(emailInfo)
    -- end
    -- 有新邮件的时候，EVENT_EMAILLIST_UPDATED也会触发，我们在那里刷新邮件列表
end

--[Comment]
--value = {emailId = emailId, itemId = itemId}
function EmailListCtrl:onUnableToReward(value)
    local awardInfo = self._emailModel:getAwardInfo(value.emailId, value.itemId)
    local name = awardInfo.ItemName or self._emailConfig.description.commonName
    self:informPluginByName("TipPlugin", {tipString = string.format( self._emailConfig.description.unableToReward, name ), removeTime = 3})
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--视图处理接口
function EmailListCtrl:showEmailDetail(emailInfo, emailList)
    print("showEmailDetail")
--    dump(emailInfo)
    local view, ctrl = self:informPluginByName("EmailDetailPlugin", {emailInfo = emailInfo, emailList = emailList})
    if type(view) == "userdata" then
        self._viewNode:showShade()
        ctrl:setOnExitCallback(function()
            if self._viewNode then
                self._viewNode:removeShade()
            end
        end)
    end
end

function EmailListCtrl:addEmail(emailInfo, emailList)
    local newEmail = EmailViewFactory.newEmailTab(emailInfo)
    local function _showDetail()
        self:playEffectOnPress()
        self:showEmailDetail(emailInfo, emailList)
    end
    newEmail.btnCheckDetail:addClickEventListener(_showDetail)
    newEmail.imgBg:onTouch(function( event )
        if event.name == "began" then
            newEmail:showShade()
        elseif event.name == "cancelled" then
            newEmail:removeShade()
        elseif event.name == "ended" then
            newEmail:removeShade()
            _showDetail()
        end
    end)
    self._viewNode:addEmail(newEmail, emailInfo.EmailId)

end

function EmailListCtrl:setEmailRead(emailId)
    local email = self._viewNode:getEmail(emailId)
    if email then
        email:setEmailReadStatus(self._emailModel:getEmailInfo(emailId))
    end
end

function EmailListCtrl:setEmailRewarded(emailId)
    local email = self._viewNode:getEmail(emailId)
    if email then
        email:setAwardInfo(self._emailModel:getAwardList(emailId))
        email:setEmailReadStatus(self._emailModel:getEmailInfo(emailId))
    end
end

function EmailListCtrl:showRewardedList()
    local rewardedList = self._emailModel:getRewardedList()
    self._emailModel:resetRewardedList()
    local awardlist = {}
    for _, awardInfo in pairs(rewardedList) do
        if awardInfo.ItemTypeID == ItemType.SILVER then
            table.insert( awardlist,{nType = 1,nCount = awardInfo.ItemCount})
        elseif awardInfo.ItemTypeID == ItemType.EXCHANGETICKETS then
            table.insert( awardlist,{nType = 2,nCount = awardInfo.ItemCount})
        elseif awardInfo.ItemTypeID == ItemType.MOBILEBILL then
            local ItemNum = awardInfo.ItemCount
            if awardInfo.ItemName then
                ItemNum = string.match(awardInfo.ItemName, "%d+")
            end
            table.insert( awardlist,{nType = 18,nCount = ItemNum})
        end
    end

    PluginTrailMonitor:pushPluginIntoTrail({pluginName = "RewardTipCtrl", params = {data = awardlist,showOkOnly = true,delayClick = true}, enableMutiPlugin = true})
    PluginTrailMonitor:popPluginInTrail()
end

function EmailListCtrl:deleteEmail(emailId)
    self._viewNode:removeEmail(emailId)
    self:setEmailCount()
end

function EmailListCtrl:showMobileInput(callback, awardInfo)
    PluginTrailMonitor:pushPluginIntoTrail({pluginName = "MobileInputPlugin", params = {
        onInputFinished = function(input, onInputValid)
            callback(input)
            self._rewardWaitingMap[awardInfo.ItemId] = onInputValid
        end,
--        onInputCancelled = function()
--            self:showRewardedList()
--        end,
        jsonFormat = self._emailConfig.itemConfig[ItemType.MOBILEBILL].extendJson,
        awardInfo = {
            path = self._emailConfig.itemConfig[ItemType.MOBILEBILL].localPath,
            name = awardInfo.ItemName,
            url = awardInfo.ItemImageUrl
        }
    },
    enableMutiPlugin = true})
    PluginTrailMonitor:popPluginInTrail()
end

function EmailListCtrl:showAddressInput(callback, awardInfo)
    PluginTrailMonitor:pushPluginIntoTrail({pluginName = "RealItemInputPlugin", params = {
        onInputFinished = function(input, onInputValid)
            callback(input)
            self._rewardWaitingMap[awardInfo.ItemId] = onInputValid
        end,
--        onInputCancelled = function()
--        end,
        jsonFormat = self._emailConfig.itemConfig[ItemType.REALITEM].extendJson,
        awardInfo = {
            path = self._emailConfig.itemConfig[ItemType.REALITEM].localPath,
            name = awardInfo.ItemName,
            url = awardInfo.ItemImageUrl
        }
    },
    enableMutiPlugin = true})
    PluginTrailMonitor:popPluginInTrail()
end

function EmailListCtrl:showEmailList()
    self._viewNode:clearEmails()
    local emailList = {}
    for k, v in pairs(self._emailModel:getLocalEmailList()) do
        emailList[k] = v
    end
    --邮件列表有自己的顺序，如果是引用的话，列表页存的数据也会随着model层改变而改变，但是考虑游戏读领状态得对邮件内容进行引用，所以不能用clone
    for _, emailInfo in pairs(emailList) do
        self:addEmail(emailInfo, emailList)
    end
    self._viewNode:refreshView()
    self:setEmailCount()
end

function EmailListCtrl:setEmailCount()
    local needReadCount = 0
    local emailList = self._emailModel:getLocalEmailList()
    for _, emailInfo in pairs(emailList) do
        if not (emailInfo.isRead and self._emailModel:isEmailRewarded(emailInfo.EmailId)) then
            needReadCount = needReadCount + 1
        end
    end
    self._viewNode:setEmailCount(needReadCount, #emailList)
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--视图切换接口
function EmailListCtrl:onEnter()
    EmailListCtrl.super.onEnter(self)
    --考虑到过期邮件，打开的时候刷新一下
    --需求变更，过期的邮件直接删除
--    self._emailModel:sortEmails()
    self._emailModel:deleteExpiredEmails()
    PluginTrailMonitor:clearTrail()
    self:showEmailList()
end

function EmailListCtrl:onExit()
    EmailListCtrl.super.onExit(self)
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--监听接口
function EmailListCtrl:registWidgetEvents()
    local viewNode = self._viewNode
    local function exit()
        self:playEffectOnPress()
        self:removeSelfInstance()
    end
    viewNode.btnClose:addClickEventListener(exit)
    viewNode.btnEmptyClose:addClickEventListener(exit)
    viewNode.btnClearReadEmails:addClickEventListener(function()
        self:playEffectOnPress()
        self:informPluginByName("ChooseDialog", {
            onOk = function()
                self._emailModel:deleteAllEmailReadAndRewarded()
            end,
            tipContent = self._emailConfig.description.ensureDeleteAllEmail -- 
        })
    end)
    viewNode.btnTakeAll:addClickEventListener(function()
        self:playEffectOnPress()
        if self._emailModel:isAllEmailRewarded() then
            self:informPluginByName("TipPlugin", {tipString = self._emailConfig.description.noReward})
        else
            self._emailModel:takeAllAward()
        end
    end)

end

function EmailListCtrl:initEventHandler()
    local emailModel = self._emailModel
    local function filter(host, interface)
        return function(event)
            interface(host, event.value)
        end
    end
    self:listenTo(emailModel, emailModel.EVENT_EMAILLIST_UPDATED,   filter(self,self.onMailListUpdated))
    self:listenTo(emailModel, emailModel.EVENT_REWARD_GOT,          filter(self,self.onRewardGot))
    self:listenTo(emailModel, emailModel.EVENT_EMAILREWARD_GOT,     filter(self,self.onMailRewardGot))
    self:listenTo(emailModel, emailModel.EVENT_ALLREWARD_GOT,       filter(self,self.onAllRewardGot))
    self:listenTo(emailModel, emailModel.EVENT_EMAIL_READ,          filter(self,self.onMailRead))
    self:listenTo(emailModel, emailModel.EVENT_EMAIL_DELETED,       filter(self,self.onMailDeleted))
    self:listenTo(emailModel, emailModel.EVENT_OPERATE_FAILED,      filter(self,self.onOperateFailed))
    self:listenTo(emailModel, emailModel.EVENT_NEED_INPUT,          filter(self,self.onNeedInput))
    self:listenTo(emailModel, emailModel.EVENT_REWARDED_BEFORE,     filter(self,self.onRewardedBefore))
    self:listenTo(emailModel, emailModel.EVENT_NEWEMAIL_GOT,        filter(self,self.onNewEmailGot))
    self:listenTo(emailModel, emailModel.EVENT_REWAED_DISABLE,      filter(self,self.onUnableToReward))
end
--------------------------------------------------------------------------------------------------------

return EmailListCtrl