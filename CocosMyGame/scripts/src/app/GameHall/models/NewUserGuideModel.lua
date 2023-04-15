local NewUserGuideModel = class("NewUserGuideModel", require('src.app.GameHall.models.BaseModel'))
local UserModel = mymodel('UserModel'):getInstance()

my.addInstance(NewUserGuideModel)

NewUserGuideModel.EVENT_SKIP_GUIDE = 'EVENT_SKIP_GUIDE'

function NewUserGuideModel:onCreate()
    self._inGuide = false
    self._skipGuide = nil
end

function NewUserGuideModel:initCache()
    if not UserModel.nUserID or UserModel.nUserID <= 0 then
        return
    end

    local skipGuide = CacheModel:getCacheByKey("SkipGuide_" .. UserModel.nUserID)
    if type(skipGuide) == 'boolean' then
        self._skipGuide = skipGuide
    else
        self._skipGuide = false
    end
end

function NewUserGuideModel:skipGuide()
    self._skipGuide = true
    CacheModel:saveInfoToCache("SkipGuide_" .. UserModel.nUserID, true)
    self:dispatchEvent({name = NewUserGuideModel.EVENT_SKIP_GUIDE})
end

function NewUserGuideModel:isNeedGuide()
    if self._skipGuide == nil then
        self:initCache()
    end
    if self._skipGuide then
        return false
    end
    return self:isNewUser()
end

function NewUserGuideModel:isSkipGuide()
    return self._skipGuide == true
end

function NewUserGuideModel:isNewUser()
    if not cc.exports.isNewUserGuideSupported() then
        return false
    end

    local UserModel = mymodel('UserModel'):getInstance()
    if not UserModel.nCreateDay or not UserModel.nBout then
        return true
    end

    local checkCreateStartDate = cc.exports.getNewUserGuideCheckCreateStartDate()
    local newUserGuideBoutCount = cc.exports.getNewUserGuideBoutCount()
    if UserModel.nCreateDay >= checkCreateStartDate and UserModel.nBout and UserModel.nBout < newUserGuideBoutCount then
        return true
    end
    return false
end

return NewUserGuideModel