local RuleChooseModel = class("RuleChooseModel")

my.addInstance(RuleChooseModel)
RuleChooseModel.EVENT_FREETRIAL_UPDATED = "EVENT_FREETRIAL_UPDATED"

function RuleChooseModel:ctor()
    self._cache = self:readCacheData() or {}

    cc.load('event'):create():bind(self)
end

function RuleChooseModel:writeCaheData(tabName, categoryName, data, payMode)
    local cache = self._cache

    cache[tabName] = cache[tabName] or {}

    cache[tabName] = {
        name        = tab,
        bigcategory = category,
        key         = table.keys(data),
        value       = table.values(data)
    }
    cache["lastchoostab"] = tabName
--    cache["AAMode"]       = bAAMode
    cache["payMode"]       = payMode
    my.saveCache(self:getCacheName(), cache)
end

function RuleChooseModel:readCacheData()
    local filename = self:getCacheName()
    if (not my.isCacheExist(filename)) then return {} end

    return my.readCache(filename)
end

function RuleChooseModel:getCacheName()
    return string.format("%s_rulechoose2.xml", UserPlugin:getUserID())
end

function RuleChooseModel:getCacheTabName()
    return self._cache["lastchoostab"]
end

function RuleChooseModel:getCachePayMode()
    return self._cache["payMode"]
end

function RuleChooseModel:getCacheTabInfo(tabName)
    return self._cache[tabName]
end

function RuleChooseModel:queryFreeTrialInfo(callback)
    local baseUrl = myhttp.getGameResBaseUrl()
    local function _onGetFreeTrialInfo(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local ret = cc.load('json').json.decode(xhr.response)
            local freeData = ret.Data
            if(0 == ret.Status ) then
                if freeData.GameCode ~= my.getAbbrName() then
                    print("current free trial info is the other game code = "..tostring(freeData.GameCode))
                end
                self._freeData = freeData
            elseif freeData then
                print("query free trial info failed msg = "..tostring(freeData.Message))
            end
            if type(callback) == "function" then callback(self:isFreeTrialSupported()) end
            self:dispatchEvent({name=RuleChooseModel.EVENT_FREETRIAL_UPDATED, value = self:isFreeTrialSupported()})
        else
            print("queryFreeTrialInfo failed ~~~~~~~")
        end
    end
    HttpUtils.httpGet(baseUrl, {gameCode = my.getAbbrName()}, _onGetFreeTrialInfo, 'restrictions/isrestrictions?')
end

function RuleChooseModel:isFreeTrialSupported()
    if type(self._freeData) == "table" 
    and self._freeData.StartTime    < socket.gettime() * 1000 
    and self._freeData.EndTime      >socket.gettime() * 1000  then
        return true
    else
        return false
    end
end

--扣玩家币start--
function RuleChooseModel:setDisplayRulejson(ruleTab)
    self._cache = ruleTab
end
--扣玩家币end--

return RuleChooseModel