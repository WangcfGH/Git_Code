local EmailModel = class("EmailModel")

if BusinessUtils:getInstance():isGameDebugMode() then
    EmailModel.DOMAIN_NAME = "http://emailawardapi.tcy365.org:1505"
else
    EmailModel.DOMAIN_NAME = "https://emailawardapi.tcy365.net"
end
EmailModel.URL_GETEMAIL      = "/api/Email/GetEmail"
EmailModel.URL_GETAWARD      = "/api/Award/GetAward"
EmailModel.URL_READEMAIL     = "/api/Email/ReadEmail"
EmailModel.URL_DELETEEMAIL   = "/api/Email/DeleteEmail"

EmailModel.EVENT_EMAILLIST_UPDATED  = "EVENT_EMAILLIST_UPDATED"             --邮件列表更新
EmailModel.EVENT_REWARD_GOT         = "EVENT_REWARD_GOT"                    --物品领取成功
EmailModel.EVENT_EMAIL_READ         = "EVENT_EMAIL_READ"                    --邮件读取成功
EmailModel.EVENT_EMAIL_DELETED      = "EVENT_EMAIL_DELETED"                 --邮件删除成功
EmailModel.EVENT_EMAILREWARD_GOT    = "EVENT_EMAILREWARD_GOT"               --单邮件所有物品领取成功
EmailModel.EVENT_ALLREWARD_GOT      = "EVENT_ALLREWARD_GOT"                 --所有奖励领取完毕
EmailModel.EVENT_OPERATE_FAILED     = "EVENT_OPERATE_FAILED"                --操作失败
EmailModel.EVENT_NEED_INPUT         = "EVENT_NEED_INPUT"                    --需要额外的输入（电话号码 地址等）
EmailModel.EVENT_REWARDED_BEFORE    = "EVENT_REWARDED_BEFORE"               --该物品已经奖励过了
EmailModel.EVENT_NEWEMAIL_GOT       = "EVENT_NEWEMAIL_GOT"                  --收到新邮件
EmailModel.EVENT_REWAED_DISABLE     = "EVENT_REWAED_DISABLE"                --无法领奖
--EmailModel.EVENT_EMAIL_NOTREAD      = "EVENT_EMAIL_NOREAD"
--EmailModel.EVENT_AWARD_EXIST        = "EVENT_AWARD_EXIST"

my.addInstance(EmailModel)
local userModel = mymodel('UserModel'):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

function EmailModel:ctor()
    local event = cc.load('event')
    event:create():bind(self)

    self._emailList      = {}
    self._rewardedList   = {}
    self._emailStatus    = {}

    self._emailConfig    = import("src.app.HallConfig.EmailConfig")
    local mclient = mc.createClient()
    mclient:registHandler(mc.GR_MAILSYS_NOTIFY,handler(self,self.onMailSystemNotify),'hall')
end

--------------------------------------------------------------------------------------------------------
--消息接口
function EmailModel:getEmailList()
    local function _onGetEmailList(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            if result.StatusCode == 0 then
                self:onEmailListGot(result.Data)
            else
                self:onOperateFailed(result.StatusCode, result.Message)
            end
        end
    end
    local params = self:getEmailListPostParams()
    local url = string.format("%s%s", self.DOMAIN_NAME, self.URL_GETEMAIL)
    self:httpPost(url, params, _onGetEmailList)
end

function EmailModel:takeAward(emailId, itemId, extend)
    local function _onTakeAward(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            if result.StatusCode == 0 then
                 self:onRewardGot(emailId, itemId)
            else
                self._isTakingAllAward = false
                if result.StatusCode == Email_StatusCode.RECEIVED_AWARD then
                    self:onRewardedAlready(emailId, itemId)
                end
                self:onOperateFailed(result.StatusCode, result.Message)
            end
        end
    end
    local params = self:getTakeAwardPostParams(emailId, itemId, extend)
    local url = string.format("%s%s", self.DOMAIN_NAME, self.URL_GETAWARD)
    self:httpPost(url, params, _onTakeAward)
end

function EmailModel:readEmail(emailId)
    local function _onReadEmail(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            if result.StatusCode == 0 then
                 self:onEmailRead(emailId)
            else
                self:onOperateFailed(result.StatusCode, result.Message)
            end
        end
    end
    local url = string.format("%s%s?emailId=%d&userId=%d", self.DOMAIN_NAME, self.URL_READEMAIL, emailId, userModel.nUserID)
    self:httpPost(url, nil, _onReadEmail)
end

function EmailModel:deleteEmail(emailId)
    local function _onDeleteEmail(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            if result.StatusCode == 0 then
                 self:onEmailDeleted(emailId)
            else
                self:onOperateFailed(result.StatusCode, result.Message)
            end
        end
    end
    local url = string.format("%s%s?emailId=%d&userId=%d", self.DOMAIN_NAME, self.URL_DELETEEMAIL, emailId, userModel.nUserID)
    self:httpPost(url, nil, _onDeleteEmail)
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--收到回应的处理接口
function EmailModel:onEmailRead(emailId)
    self._emailStatus[emailId]           = self._emailStatus[emailId] or {}
    self._emailStatus[emailId]["isRead"] = true
    local emailInfo = self:getEmailInfo(emailId)
    emailInfo["isRead"]                  = true
    self:writeCache()
    self:sortEmails()
    self:dispatchEvent({name = self.EVENT_EMAIL_READ, value = {emailId = emailId}})
end

function EmailModel:onRewardGot(emailId, itemId)
    self._emailStatus[emailId]                       = self._emailStatus[emailId] or {}
    self._emailStatus[emailId][itemId]               = self._emailStatus[emailId][itemId] or {}
    self._emailStatus[emailId][itemId]["isRewarded"] = true
    --设置已领取状态，顺便检查1.单个邮件是不是所有物品都奖励了，2.是不是所有邮件都奖励了
    local awardInfo = self:getAwardInfo(emailId, itemId)
    awardInfo["isRewarded"] = true
    self:sortEmails()
    self:collectRewardedItem(awardInfo)
    self:updateUserInfo(awardInfo)

    if self:isEmailRewarded(emailId) then
        self:dispatchEvent({name = self.EVENT_EMAILREWARD_GOT, value = {emailId = emailId}})
        if self._isTakingAllAward then
            self:takeAllAward()
        end
        if self:isAllEmailRewarded() then
            self:dispatchEvent({name = self.EVENT_ALLREWARD_GOT, value = {}})
        end
    end
    self:writeCache()
    self:dispatchEvent({name = self.EVENT_REWARD_GOT, value = {emailId = emailId, itemId = itemId}})
end

function EmailModel:onRewardedAlready(emailId, itemId)
    self._emailStatus[emailId]                       = self._emailStatus[emailId] or {}
    self._emailStatus[emailId][itemId]               = self._emailStatus[emailId][itemId] or {}
    self._emailStatus[emailId][itemId]["isRewarded"] = true
    local awardInfo = self:getAwardInfo(emailId, itemId)
    awardInfo["isRewarded"] = true
    self:writeCache()
    self:sortEmails()
    self:dispatchEvent({name = self.EVENT_REWARDED_BEFORE, value = {emailId = emailId, itemId = itemId}})
end

function EmailModel:onEmailDeleted(emailId)
    self._emailStatus[emailId] = nil
    table.filter(self._emailList, function(v, k)
        return v.EmailId ~= emailId
    end)
    self._emailList = table.unique(self._emailList, true)
    self:sortEmails()
    self:writeCache()
    self:dispatchEvent({name = self.EVENT_EMAIL_DELETED, value = {emailId = emailId}})
end

function EmailModel:onEmailListGot(emailList)
    local newMails = {}
    for _, email in pairs(emailList) do
        if table.nums(self:getEmailInfo(email.EmailId)) == 0 then
            table.insert(newMails, email)
        end
    end

    self._emailList = emailList
    --把已读，已领取的缓存输入到邮件数据中
    table.walk(self._emailList, function(email, k)
        email["isRead"] = self._emailStatus[email.EmailId] and self._emailStatus[email.EmailId]["isRead"]
        if not email.EmailAwardList then return end
        table.walk(email.EmailAwardList, function(award, k)
            award["isRewarded"] = self._emailStatus[email.EmailId] and self._emailStatus[email.EmailId][award.ItemId] and self._emailStatus[email.EmailId][award.ItemId]["isRewarded"]
        end)
    end)
    self:sortEmails()
    if #newMails > 0 then self:dispatchEvent({name = self.EVENT_NEWEMAIL_GOT, value = {newMails = newMails}}) end
    self:dispatchEvent({name = self.EVENT_EMAILLIST_UPDATED, value = {emailList = self._emailList}})
end

function EmailModel:onOperateFailed(code, msg)
    self:dispatchEvent({name = self.EVENT_OPERATE_FAILED, value = {code = code, msg = msg}})
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--参数接口
function EmailModel:getEmailListPostParams()
    local params = {
        SourceId = Email_SourceId.MOBILEGAME,
        UserBaseInfo = {
            UserId = userModel.nUserID,
            Time = 0,
            GameCode = my.getAbbrName(),
            GameVersion = my.getGameVersion(),
            ChannelId = BusinessUtils:getInstance():getRecommenderId()
        }
    }
    return json.encode(params)
end

function EmailModel:getTakeAwardPostParams(emailId, itemId, extend)
    local params = {
        UserId = userModel.nUserID,
        EmailId = emailId,
        ItemId = itemId,
        ExtendJson = string.len(extend) > 0 and json.decode(extend) or extend
    }
    return json.encode(params)
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--工具接口
function EmailModel:httpPost(url, params, callback)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')
    xhr:setRequestHeader('SourceType', Email_SourceType.MOBILEGAME_EX)
    local authInfo = device.platform == "windows" and "appid=3003&userid=72643&accesstoken=3SI-2EkO2dx8XAqJLp7XfSqyB7niLz_U4xEz-oBXjf7-ylB_Dap5Bdjtr1qnAJuQrN3Lq3w0fMXZeFfUcUwvGbK9p_NtguHpPuzr9ah1TjgPCsjbYe5wTyNhRAxN2lLaGMtDnOjDRbTi0eqiQhYdeg" or UserPlugin:getAuthInfo()
    xhr:setRequestHeader('Code',authInfo)
    print(UserPlugin:getAuthInfo())
    
    --[[KPI start]]
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    --[[KPI end]]
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
        printLog(self.__cname, 'status: %s, response: %s', xhr.status, xhr.response)
        local function urlDecode(s)
            s = string.gsub(s, '\\u(%x%x%x%x)', function(h) return string.char(tonumber(h, 16)) end)
            return s  
        end 
        xhr.response = urlDecode(xhr.response)
        callback(xhr)
    end )
    xhr:send(params)
    printLog(self.__cname, 'http post url: %s, params: %s', url, params)
end

function EmailModel:readCache()
    self._emailStatus = self:convertTableKeyToNum(CacheModel:getCacheByKey(self.__cname) or {})
    return self._emailStatus
end

function EmailModel:writeCache()
    CacheModel:saveInfoToUserCache(self.__cname, self:convertTableKeyToString(self._emailStatus))
end

function EmailModel:collectRewardedItem(award)
    if self._rewardedList[award.ItemId] then
        self._rewardedList[award.ItemId]["ItemCount"] = self._rewardedList[award.ItemId]["ItemCount"] + award["ItemCount"]
    else
        --警告 这里必须使用clone 因为直接加上去会影响原数据
        self._rewardedList[award.ItemId] = clone(award)
    end
end

function EmailModel:convertTableKeyToString(tab)
    local newTable = {}
    local function _convert(tab, des)
        for k, v in pairs(tab) do
            if type(k) == "number" then
                des[tostring(k)] = clone(v)
                des[k] = nil
            end
            if type(v) == "table" then
                _convert(v, des[type(k) == "number" and tostring(k) or k])
            end
        end
    end
    _convert(tab, newTable)
    return newTable
end

function EmailModel:convertTableKeyToNum(tab)
    local newTable = {}
    local function _convert(tab, des)
        for k, v in pairs(tab) do
            if type(tonumber(k)) == "number" then
                des[tonumber(k)] = clone(v)
                des[k] = nil
            end
            if type(v) == "table" then
                _convert(v, des[type(tonumber(k)) == "number" and tonumber(k) or k])
            end
        end
    end
    _convert(tab, newTable)
    return newTable
end

function EmailModel:sortEmails()
    table.sort( self._emailList, function(a, b)
        local function isRewarded( emailInfo )
            if not emailInfo.EmailAwardList then return true end
            for _, awardInfo in pairs(emailInfo.EmailAwardList) do
                if not awardInfo.isRewarded then return false end
            end
            return true
        end
        local function isRead( emailInfo )
            return emailInfo.isRead
        end
--        local function isOutOfDate( emailInfo )
--            return os.time() > emailInfo.OverDueTime
--        end
--·       需求变更， 过期邮件直接删除
--        需求变更， 没奖励过的邮件当未读来处理， 直接把有奖励的放在前面就行了
        local classA, classB = 0, 0
        classA = classA + ((not isRewarded(a)) and 2 or 0) + ((not isRead(a)) and 1 or 0)-- - (isOutOfDate(a) and 4 or 0)
        classB = classB + ((not isRewarded(b)) and 2 or 0) + ((not isRead(b)) and 1 or 0)-- - (isOutOfDate(b) and 4 or 0)
--        print(a.EmailId, b.EmailId)
--        print(classA, classB)
        return classA > classB
    end )
end

function EmailModel:updateUserInfo(awardInfo)
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    if awardInfo.ItemTypeID == ItemType.JF then
        playerModel:addGameScore(awardInfo.ItemCount)
    elseif awardInfo.ItemTypeID == ItemType.SILVER then
        if self._emailConfig.itemConfig[ItemType.SILVER].rewardTo == "directgame" then
            -- playerModel:addGameDeposit(awardInfo.ItemCount)
        else 
            playerModel:addSafeboxDeposit(awardInfo.ItemCount)
        end
    elseif awardInfo.ItemTypeID == ItemType.EXCHANGETICKETS then
        ExchangeCenterModel:addTicketNum(awardInfo.ItemCount)
    elseif awardInfo.ItemTypeID == ItemType.HAPPYCOIN then
        -- playerModel:addHappyCoin(awardInfo.ItemCount)
        --***变化服务端都会通知过来的，就不手动加了，否则容易先收到通知并且刷新了***之后又加上，导致数量显示错误
    end
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--响应接口
function EmailModel:onMailSystemNotify(respondType, data, msgType, dataMap)
    if type(dataMap) == "table" and type(dataMap.szGameVers) == "string" and string.len(dataMap.szGameVers) > 0 then
        local versionList = string.split(dataMap.szGameVers, ",")
        if table.indexof(versionList, my.getGameVersion()) then
            self:getEmailList()
        end
    else
        self:getEmailList()
    end
end
--------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------
--业务拓展接口
function EmailModel:takeAwardWithFixExtendJson(emailId, itemId, extendJson)
    extendJson = extendJson or  self:getItemExtendJson(emailId, itemId, function(_extendJson)
        return self:takeAward(emailId, itemId, _extendJson)
    end)
    if extendJson then return self:takeAward(emailId, itemId, extendJson) end
end

function EmailModel:takeAwardByEmailID(emailId)
    local emailInfo = self:getEmailInfo(emailId)
    if not emailInfo.EmailAwardList then return end

    --领取成功话费实物等需要输入的物品之前先不领取其他的物品
    for _, award in pairs(emailInfo.EmailAwardList) do
        if not award.isRewarded then
            if award.ItemTypeID == ItemType.REALITEM
            or award.ItemTypeID == ItemType.MOBILEBILL then
                self:takeAwardWithFixExtendJson(emailId, award.ItemId)
                if not emailInfo.isRead then
                    self:readEmail(emailInfo.EmailId)
                end
                return 
            end
        end
    end

    local isAward  = false
    for _, award in pairs(emailInfo.EmailAwardList) do
        if not award.isRewarded then
            self:takeAwardWithFixExtendJson(emailId, award.ItemId)
            isAward = true
        end
    end
    if isAward and (not emailInfo.isRead) then
        --如果触发了领取物品，那么需要把这个邮件设置为已读
        self:readEmail(emailInfo.EmailId)
    end
end

function EmailModel:takeAllAward()
    self._isTakingAllAward = true
    for _, emailInfo in pairs(self._emailList) do
        if not self:isEmailRewarded(emailInfo.EmailId) then
            self:takeAwardByEmailID(emailInfo.EmailId)
            return 
        end
    end
    self._isTakingAllAward = false
    return
end

function EmailModel:deleteAllEmailReadAndRewarded()
    for _, emailInfo in pairs(self._emailList) do
        if emailInfo.isRead and self:isEmailRewarded(emailInfo.EmailId) then
            self:deleteEmail(emailInfo.EmailId)
        end
    end
end

function EmailModel:readAllMail()
    for _, emailInfo in pairs(self._emailList) do
        if not emailInfo.isRead then
            self:readEmail(emailInfo.EmailId)
        end
    end
end

function EmailModel:getLocalEmailList()
    return self._emailList or {}
end

function EmailModel:getEmailInfo(emailId)
    for _, emailInfo in pairs(self._emailList) do
        if emailInfo.EmailId == emailId then
            return emailInfo
        end
    end
    return {}
end

function EmailModel:getAwardList(emailId)
    return self:getEmailInfo(emailId).EmailAwardList or {}
end

function EmailModel:getAwardInfo(emailId, itemId)
    for _, award in pairs(self:getAwardList(emailId)) do
        if award.ItemId == itemId then
            return award
        end
    end
    return {}
end

function EmailModel:getItemExtendJson(emailId, itemId, callback)
    local awardInfo = self:getAwardInfo(emailId, itemId)
    local itemConfig = self._emailConfig.itemConfig
    if awardInfo.ItemTypeID == ItemType.JF
    or awardInfo.ItemTypeID == ItemType.HAPPYCOIN
    or awardInfo.ItemTypeID == ItemType.EXCHANGETICKETS
    or awardInfo.ItemTypeID == ItemType.MATCHTICKETS
    or awardInfo.ItemTypeID == ItemType.HAPPYCOINTIKET then
        return string.format(itemConfig[awardInfo.ItemTypeID].extendJson, my.getGameID())
    elseif awardInfo.ItemTypeID == ItemType.SILVER then
        local itemInfo = itemConfig[awardInfo.ItemTypeID]
        return string.format(itemInfo.extendJson[itemInfo.rewardTo], my.getGameID())
    elseif awardInfo.ItemTypeID == ItemType.REALITEM
        or awardInfo.ItemTypeID == ItemType.MOBILEBILL
        or awardInfo.ItemTypeID == ItemType.VIRTUALITEM then
        self:dispatchEvent({name = self.EVENT_NEED_INPUT, value = {emailId = emailId, itemId = itemId, callback = callback}})
        return
    else
        self:dispatchEvent({name = self.EVENT_REWAED_DISABLE, value = {emailId = emailId, itemId = itemId}})
        return
    end
end

function EmailModel:resetRewardedList()
    self._rewardedList = {}
end

--[Comment]
--RewardedList 是指已经收到的奖励列表
function EmailModel:getRewardedList()
    return self._rewardedList
end

function EmailModel:isItemRewarded(emailId, itemId)
    return self:getAwardInfo(emailId, itemId).isRewarded
end

function EmailModel:isEmailRewarded(emailId)
    for _, award in pairs(self:getEmailInfo(emailId).EmailAwardList or {}) do
        if not award.isRewarded then return false end
    end
    return true
end

function EmailModel:isAllEmailRewarded()
    for _, email in pairs(self._emailList) do
        if not self:isEmailRewarded(email.EmailId) then return false end
    end
    return true
end

function EmailModel:readEmailIfNotRead(emailId)
    if not self:isEmailRead(emailId) then
        self:readEmail(emailId)
    end
end

function EmailModel:isEmailRead(emailId)
    return self:getEmailInfo(emailId).isRead
end

function EmailModel:isAllEmailRead()
    for _, email in pairs(self._emailList) do
        if not self:isEmailRead(email.EmailId) then return false end
    end
    return true
end

function EmailModel:deleteExpiredEmails()
--    table.filter(self._emailList, function(v, k)
--        return os.time() < v.OverDueTime
--    end)
    local isUpdated = false
    for k, v in pairs(self._emailList) do
        if os.time() > v.OverDueTime then
            self._emailList[k] = nil
            isUpdated = true
        end
    end
    if isUpdated then
        self._emailList = table.unique(self._emailList, true)
        self:dispatchEvent({name = self.EVENT_EMAILLIST_UPDATED, value = {emailList = self._emailList}})
    end
end

function EmailModel:updateEmailList()
    self:getEmailList()
    self:readCache()
end

function EmailModel:getNoticeMailCount()
    local count = 0
    for _, email in pairs(self._emailList) do
        if not self:isEmailRead(email.EmailId) then
            count = count + 1
        elseif not self:isEmailRewarded(email.EmailId) then
            count = count + 1
        end
    end
    return count
end
--------------------------------------------------------------------------------------------------------

return EmailModel