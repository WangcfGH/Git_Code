local SafeboxModel  = class('SafeboxModel', require('src.app.GameHall.models.BaseModel'))
local SafeboxDef    = require('src.app.plugins.safebox.SafeboxDef')
local AssistModel   = mymodel('assist.AssistModel'):getInstance()
my.addInstance(SafeboxModel)
protobuf.register_file('src/app/plugins/safebox/pbSafebox.pb')

function SafeboxModel:onCreate()
    self._support = false
    self._infoDate = self:getTodayDate()
    self._saveTimes = 0
    self._saveCount = 0
    self._inWhiteList = false
    self._inBlackList = false
    self._dataReady = false
    self:initAssistResponse()
end

function SafeboxModel:initAssistResponse()
    self._assistResponseMap = {
        [SafeboxDef.GR_SAFEBOX_QUERY_INFO] = handler(self, self.onQuerySafeboxResp),
        [SafeboxDef.GR_SAFEBOX_SAVE_OK] = handler(self, self.onSaveDepositOKResp)
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function SafeboxModel:querySafeboxInfo()
    local UserModel = mymodel('UserModel'):getInstance()

    local needRegist = false
    local support = true
    if cc.exports.isSafeboxNeedCheckCreateInfo() then
        needRegist = true
        local checkCreateStartDate = cc.exports.getSafeboxCheckCreateStartDate()
        if UserModel.nCreateDay >= checkCreateStartDate and UserModel.nBout <= 0 then
            support = false
        end
    end

    local data = {
        userid = UserModel.nUserID,
        needregist = needRegist,
        support = support
    }

    local pdata = protobuf.encode('pbSafebox.QuerySafeboxInfo', data)
    AssistModel:sendData(SafeboxDef.GR_SAFEBOX_QUERY_INFO, pdata, false)
end

function SafeboxModel:saveDepositOK(saveCount)
    if type(saveCount) ~= 'number' or saveCount <= 0 then
        return
    end

    if not cc.exports.isSafeboxSaveFuncEnableLimit() then
        return
    end

    local UserModel = mymodel('UserModel'):getInstance()
    local data = {
        userid = UserModel.nUserID,
        savecount = saveCount
    }
    local pdata = protobuf.encode('pbSafebox.SaveDepositOK', data)
    AssistModel:sendData(SafeboxDef.GR_SAFEBOX_SAVE_OK, pdata, false)
end

function SafeboxModel:onQuerySafeboxResp(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbSafebox.SafeboxInfo', data)
    protobuf.extract(pdata)
    dump(pdata)

    self._support = pdata.support
    self._infoDate = pdata.infodate
    self._saveTimes = pdata.savetimes
    self._saveCount = pdata.savecount
    self._inWhiteList = false
    self._inBlackList = false
    self._dataReady = true
    self:dispatchEvent({name = SafeboxDef.EVENT_QUERY_SAFEBOX_INFO_OK})
end

function SafeboxModel:onSaveDepositOKResp(data)
    if string.len(data) == nil then return nil end
    
    local pdata = protobuf.decode('pbSafebox.SaveDepositOKResp', data)
    protobuf.extract(pdata)
    dump(pdata)

    self._infoDate = pdata.infodate
    self._saveTimes = pdata.savetimes
    self._saveCount = pdata.savecount
end

function SafeboxModel:getTodayDate()
    local todayDate = os.date('%Y%m%d',os.time())
    return tonumber(todayDate)
end

function SafeboxModel:isSafeboxSupported()
    return self._support
end

function SafeboxModel:getSaveTimes()
    if self._infoDate ~= self:getTodayDate() then
        self._saveTimes = 0
        return 0
    end
    return self._saveTimes
end

function SafeboxModel:getSaveCount()
    if self._infoDate ~= self:getTodayDate() then
        self._saveCount = 0
        return 0
    end
    return self._saveCount
end

function SafeboxModel:isSaveTimesEnough()
    if self:isSafeboxSupported() then
        local saveTimes = self:getSaveTimes()
        local saveTimesLimit = cc.exports.getSafeboxSaveTimesLimit()
        return saveTimes < saveTimesLimit
    end
    return false
end

function SafeboxModel:isSaveCountEnough()
    if self:isSafeboxSupported() then
        local saveCount = self:getSaveCount()
        local saveCountLimit = cc.exports.getSafeboxSaveCountLimit()
        return saveCount < saveCountLimit
    end
    return false
end

function SafeboxModel:isDataReady()
    return self._dataReady
end

return SafeboxModel