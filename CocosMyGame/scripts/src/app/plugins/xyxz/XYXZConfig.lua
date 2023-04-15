local AppConfig = {
    ["version"] = "1.0.20200501",
    ["name"] = "休闲游戏",
    ["abbr"] = "xyxz",
    ["gameID"] = 938,
}

local path = "src/xyxz/public/AppConfig.json"

local ChannelConfig = {
    ["recommander_id"] = 1000002031
}

if BusinessUtils:getInstance():isGameDebugMode() then
    ChannelConfig["recommander_id"] = 1000001557
end

local config = {}
local mt = {
    __index = function (t, key)
        if key == "AppConfig" then
            if cc.FileUtils:getInstance():isFileExist(path) then
                return  json.decode(cc.FileUtils:getInstance():getStringFromFile(path))
            else
                return AppConfig
            end
        elseif key == "ChannelConfig" then
            return ChannelConfig
        end
    end
}

setmetatable(config, mt)

return config