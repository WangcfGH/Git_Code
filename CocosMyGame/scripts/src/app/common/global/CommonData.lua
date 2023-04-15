--公共数据
local CommonData = class("CommonData", import(".UniqueObject"))

CommonData.USER_CACHENAME = "commonuserdata.xml"

function CommonData:ctor()
    self._commonData = {
        ["nUserID"] = -1,

        --用户依赖数据，数据属于某个用户
        ["theUserData"] = {
        },

        --应用数据，数据属于此应用
        ["theAppData"] = {
            ["DoubleExchangeConfig"] = {}
        }             
    }

    self._userDataKeysToSave = {
        "firstRecharge_lastNoticeTime",
        "topRank_lastNoticeTime",
        "scoreRoom_lastNoticeTime",
        "limitTimeSpecial_lastNoticeTime"
    }
end

--存放数据
function CommonData:setUserData(key, value)
    if key ==nil then return end
    self:_checkUserData()

    self._commonData["theUserData"][key] = value
end

--取出数据
function CommonData:getUserData(key)
    if key == nil then return nil end
    self:_checkUserData()

    return self._commonData["theUserData"][key]
end

--核查数据的正确性
function CommonData:_checkUserData()
    local user = mymodel('UserModel'):getInstance()
    local dataOwner = self._commonData["nUserID"]
    if dataOwner ~= user.nUserID then 
        --用户id不符，则重置
        self._commonData["nUserID"] = user.nUserID 
        self._commonData["theUserData"] = {}
    end
end

--保存用户数据到缓存
function CommonData:saveUserData()
    print("CommonData:saveUserData")

    self:_checkUserData()

    local dataMap = {}
    local dataKeys = self._userDataKeysToSave
    for _, keyName in pairs(dataKeys) do
        dataMap[keyName] = self._commonData["theUserData"][keyName]
    end
    my.saveCache(self:_getUserDataCacheFileName(), dataMap)
end

--从缓存读取用户数据
function CommonData:readUserData()
    print("CommonData:readUserData")

    self:_checkUserData()

    local dataMap = my.readCache(self:_getUserDataCacheFileName())
    if dataMap ~= nil then
        for key, val in pairs(dataMap) do
            self._commonData["theUserData"][key] = val
        end
    end
end

function CommonData:_getUserDataCacheFileName()
    local fileName = ""
    local user = mymodel('UserModel'):getInstance()
    if user and user.nUserID then
        fileName = user.nUserID.."_"..CommonData.USER_CACHENAME
    else
        fileName = "default_"..CommonData.USER_CACHENAME
    end
    return fileName
end

--存放数据
function CommonData:setAppData(key, value)
    if key ==nil then return end

    self._commonData["theAppData"][key] = value
end

--取出数据
function CommonData:getAppData(key)
    if key == nil then return nil end

    return self._commonData["theAppData"][key]
end

return CommonData