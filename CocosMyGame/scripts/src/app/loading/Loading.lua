--loading负责在游戏启动之前播放健康游戏忠告

local Loading = class('Loading', import('src.app.BaseModule.ViewCtrl.lua'))

Loading.RESOURCE_PATH = 'res/hallcocosstudio/healthbulletin/start_healthbulletin.csb'

function Loading:onCreate()
    self._callback = {}
end

function Loading:run()
    local config = self:getHealthTipConfig()
    config = type(config) == "table" and config or {}
    local checkResult = self:checkHealthConfig(config)

    if checkResult then
        self:showHealthDescription()
        local scheduleID
        scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
            self:onLoadingEvents('finished')
        end, config.time, false)
    else
        self:onLoadingEvents('needless')
    end
end

function Loading:setCallback(callback)
    if type(callback) == 'function' then
        table.insert(self._callback, callback)
    end
end

function Loading:checkHealthConfig(config)
    local support = true
    if type(config.support) ~= 'number' then
        config.time = 3
        config.support = 1
    elseif config.support <= 0 then
        support = false
    elseif not config.time or config.time <= 0 then
        config.time = 3
    end

    return support
end

function Loading:getHealthTipConfig()
    local additionConfig = cc.FileUtils:getInstance():getStringFromFile("res/hall/hallstrings/AdditionConfig.json")
    if additionConfig then
        local content = json.decode(additionConfig)
        return content['data']['functions']['healthdescription']
    end
end

function Loading:showHealthDescription()
    local healthScene = cc.CSLoader:createNode(self.RESOURCE_PATH)
    healthScene:setAnchorPoint(0,0)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    healthScene:setContentSize(visibleSize)
	ccui.Helper:doLayout(healthScene)
	local newScene=display.newScene("healthScene"):addChild(healthScene)
    self:showAsScene(newScene)
end

function Loading:onLoadingEvents(event)
    for _, callback in pairs(self._callback) do 
        callback(event)
    end
end

return Loading