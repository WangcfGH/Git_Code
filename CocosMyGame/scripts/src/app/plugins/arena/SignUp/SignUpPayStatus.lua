--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local SignUpPayStatus = class("SignUpPayStatus")
local user=mymodel('UserModel'):getInstance()
--local TimeCalculator = require('src.app.Common.TimeCalculator.TimeCalculator')

my.addInstance(SignUpPayStatus)

function SignUpPayStatus:ctor()
    self._data = {}
end

function SignUpPayStatus:getSignUpItemStatusFromFile()
    self._data = self:getSignUpCacheFile() 
end

function SignUpPayStatus:getSignUpCacheFileName()
    local cacheFile= "SignUpPayStatus.xml"
    local id = user.nUserID
    cacheFile = id.."_"..cacheFile
    return cacheFile 
end

function SignUpPayStatus:getSignUpCacheFile() 

    local dataMap = {signUpCount=0, timeName="2016_01_01", isSignUped=false}

    local filename = self:getSignUpCacheFileName()

    if(false == my.isCacheExist(filename))then
        return dataMap
    end

    dataMap = my.readCache(filename)
    dataMap = checktable(dataMap)

    return dataMap
end

function SignUpPayStatus:saveSignUpItemStatus()
    print("SignUpPayStatus:saveSignUpItemStatus()")
    if user.nUserID == nil or user.nUserID <= 0 then
        print("userID  error ---SignUpPayStatus")
        return
    end    
    my.saveCache(self:getSignUpCacheFileName(), self._data)
end                       

function SignUpPayStatus:setMySignUpDatas(count)
    if nil == self._data then 
        self._data = {}          
    end
    self._data = count    
    self:saveSignUpItemStatus() --立马存储
end

function SignUpPayStatus:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

return SignUpPayStatus
--endregion
