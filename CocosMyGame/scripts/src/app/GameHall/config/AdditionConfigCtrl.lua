
local AdditionConfigCtrl = class('AdditionConfigCtrl')

AdditionConfigCtrl.__instance = nil

function AdditionConfigCtrl:getInstance()
    if self.__instance == nil then
        self.__instance = AdditionConfigCtrl:create()
    end
    return self.__instance
end

function AdditionConfigCtrl:removeInstance()
    if AdditionConfigCtrl.__instance == nil then return end

    AdditionConfigCtrl.__instance.__additionConfigModel  = nil
    AdditionConfigCtrl.__instance.__functionKeys         = {}

    AdditionConfigCtrl.__instance = nil
end

function AdditionConfigCtrl:ctor()
    self.__additionConfigModel  = nil
    self.__functionKeys         = {}

    self:init()
end

function AdditionConfigCtrl:init()
    if not self.__additionConfigModel then
        self.__additionConfigModel = import('src.app.GameHall.config.AdditionConfigModel'):create()

        self.__functionKeys = self.__additionConfigModel.FUNCTION_KEYS
    end
end

function AdditionConfigCtrl:getFunctionKeys()
    return self.__functionKeys
end

function AdditionConfigCtrl:isFunctionSupported(...)
    if not self.__additionConfigModel then return false end
    local support = self.__additionConfigModel:getFunctionSupport(...)
    if type(support) ~= 'number' then return false end
    
    local ret = (support > 0)
    if ret then
        local keys = self.__additionConfigModel:getConfigKeysTable(...)
        if keys[1] and keys[1].filter_city then
            if self:isCityOrProvinceFiltered(keys[1]) then
                return false
            end
        end
    end
    return ret
end

function AdditionConfigCtrl:reqLatestConfig()
    if self.__additionConfigModel then
        self.__additionConfigModel:reqLatestConfig()
    end
end

function AdditionConfigCtrl:getConfigKey(...)
    if self.__additionConfigModel then
        return self.__additionConfigModel:getConfigKey(...)
    end
end

-- 传入过滤的城市以及省份列表, 判断自己的城市是否在这个列表中
function AdditionConfigCtrl:isCityOrProvinceFiltered(config)
    if config == nil then return false end
    if config.filter_city == nil and config.filter_province == nil then
        return false
    end
    local platformplugin = plugin.AgentManager:getInstance().getTcyPlatformPlugin and plugin.AgentManager:getInstance():getTcyPlatformPlugin()
	if platformplugin == nil then
		return false
	end
	
    local location = platformplugin:getAppLocation()
    local cityName = location.city
    local provinceName = location.province
    if cityName and cityName ~= "" and config then
        if config.filter_city then
            dump(config.filter_city)
            -- 遍历城市名
            for i = 1, #config.filter_city do
                if self:isSameCityOrProvince(cityName, config.filter_city[i]) then
                    return true
                end
            end
        end
    end
    if provinceName and provinceName ~= "" then
        if config.filter_city then
            -- 用省去遍历城市名, 因为cityName在直辖市的情况是空的
            for i = 1, #config.filter_city do
                if self:isSameCityOrProvince(provinceName, config.filter_city[i]) then
                    return true
                end
            end
            for i = 1, #config.filter_province do
                if self:isSameCityOrProvince(provinceName, config.filter_province[i]) then
                    return true
                end
            end
        end
    end
    return false
end

-- 判断是不是同一个城市
function AdditionConfigCtrl:isSameCityOrProvince(cityName1, cityName2)
    if string.find(cityName1, cityName2, 1, true) then
        return true
    elseif string.find(cityName2, cityName1, 1, true) then
        return true
    end
    return false
end

return AdditionConfigCtrl
