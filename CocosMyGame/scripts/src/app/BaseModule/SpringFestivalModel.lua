local json = cc.load("json").json
local fileUtils = cc.FileUtils:getInstance()
local cacheFileName = "SpringFestivalCache.json"
local cachePath = fileUtils:getGameWritablePath() .. cacheFileName

local SpringFestivalModel = class("SpringFestivalModel")

local function addInstance(cls)
    local instance = "_instance"
    rawset(cls, instance, nil)
    function cls:getInstance(...)
        if not rawget(self, instance) then
            rawset(self, instance, self:create(...))
        end
        return rawget(self, instance)
    end

    function cls:isInstanceExist()
        return rawget(self, instance) ~= nil
    end

    function cls:removeInstance()
        rawset(self.class, instance, nil)
    end
end

addInstance(SpringFestivalModel)

function SpringFestivalModel:ctor()
    self._enable = false
    self._startDate = 0
    self._endDate = 0
    self._curDate = tonumber(os.date("%Y%m%d", os.time()))
    self._showSpringFestivalView = false
    self._gameSceneDefaultShow = true

    if fileUtils:isFileExist(cachePath) then
        local jsonString = fileUtils:getStringFromFile(cachePath)
        local jsonDate = json.decode(jsonString)
        self._enable = jsonDate.enable
        self._startDate = jsonDate.startDate
        self._endDate = jsonDate.endDate
        self._gameSceneDefaultShow = jsonDate.gameSceneDefaultShow
    end
    return self
end

function SpringFestivalModel:saveCache()
    local jsonData = {
        enable = self._enable,
        startDate = self._startDate,
        endDate = self._endDate,
        gameSceneDefaultShow = self._gameSceneDefaultShow
    }
    local jsonString = json.encode(jsonData)
    local cacheFile = io.open(cachePath, 'w')
    if cacheFile then
        cacheFile:write(jsonString)
        cacheFile:close()
    end
end

function SpringFestivalModel:setSpringFestivalCache(enable, startDate, endDate)
    if not self:isInSpringFestival() and self:isInSpringFestival(enable, startDate, endDate) then
        self._gameSceneDefaultShow = true
    end
    self._enable = enable
    self._startDate = startDate
    self._endDate = endDate
    self:saveCache()
end

function SpringFestivalModel:isInSpringFestival(enable, startDate, endDate)
    enable = enable or self._enable
    startDate = startDate or self._startDate
    endDate = endDate or self._endDate
    return enable and self._curDate >= startDate and self._curDate <= endDate
end

function SpringFestivalModel:setShowSpringFestivalView(show)
    self._showSpringFestivalView = show
end

function SpringFestivalModel:showSpringFestivalView()
    return self._showSpringFestivalView
end

function SpringFestivalModel:gameSceneDefaultShow()
    return self._gameSceneDefaultShow
end

function SpringFestivalModel:setGameSceneDefaultShow(show)
    self._gameSceneDefaultShow = show
    self:saveCache()
end

return SpringFestivalModel

