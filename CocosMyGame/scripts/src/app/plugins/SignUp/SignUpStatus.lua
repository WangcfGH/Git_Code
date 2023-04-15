--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local SignUpStatus = class("SignUpStatus")
local user=mymodel('UserModel'):getInstance()
--local TimeCalculator = require('src.app.Common.TimeCalculator.TimeCalculator')

my.addInstance(SignUpStatus)

function SignUpStatus:ctor()
    self._data = {}
end

function SignUpStatus:getSignUpItemStatusFromFile()
    self._data = self:getSignUpCacheFile() 
end

function SignUpStatus:getSignUpCacheFileName()
    local cacheFile= "SignUpStatus.xml"
    local id = user.nUserID
    cacheFile = id.."_"..cacheFile
    return cacheFile 
end

function SignUpStatus:getSignUpCacheFile() 

    local dataMap = {signUpCount=0, timeName="2016_01_01", isSignUped=false}

    local filename = self:getSignUpCacheFileName()

    if(false == my.isCacheExist(filename))then
        return dataMap
    end

    dataMap = my.readCache(filename)
    dataMap = checktable(dataMap)

    return dataMap
end

function SignUpStatus:saveSignUpItemStatus()
    print("SignUpStatus:saveSignUpItemStatus()")
    if user.nUserID == nil or user.nUserID <= 0 then
        print("userID  error ---SignUpStatus")
        return
    end    
    my.saveCache(self:getSignUpCacheFileName(), self._data)
end                       

function SignUpStatus:setMySignUpDatas(count)
    if nil == self._data then 
        self._data = {}          
    end
    self._data = count    
    self:saveSignUpItemStatus() --立马存储
end

function SignUpStatus:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

return SignUpStatus
--endregion
