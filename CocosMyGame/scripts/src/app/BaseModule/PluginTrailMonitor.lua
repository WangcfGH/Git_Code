local PluginTrailMonitor = {
    _pluginTrail = {}
}
cc.exports.PluginTrailMonitor = PluginTrailMonitor

local blackList = import('src.app.HallConfig.PluginConfig').PluginTrailBlackList
--如果想要拒绝某插件被推送入队列，填充blackList即可

local function _isPluginStillRequired(params)
    if type(params.condition) == "function" then
        return params.condition()
    else
        return true
    end
end

--部分插件需要支持同个插件多次弹出
local function _isPluginMultiEnabled(params)
    return params.enableMutiPlugin
end

function PluginTrailMonitor:pushPluginIntoTrail(params, order)
    for _, pluginName in pairs(blackList) do
        --拒绝黑名单用户加入队列
        if params.pluginName == pluginName then return end
    end
    if not _isPluginMultiEnabled(params) then
        for i, _params in pairs(self._pluginTrail) do
            if _params.pluginName == params.pluginName then return end
        end
    end
    if (not order) or (#self._pluginTrail < order) then
        table.insert(self._pluginTrail, params)
    else
        for i = #self._pluginTrail, 1, -1 do
            if i >= order then
                self._pluginTrail[i + 1] = self._pluginTrail[i]
                if i == order then
                    self._pluginTrail[i] = params
                    break
                end
            end
        end
    end
end

function PluginTrailMonitor:popPluginInTrail()
    local _onPluginExit, _popPlugin
    function _popPlugin()
        if #self._pluginTrail > 0 and (not PluginTrailMonitor.isPluginDisplaying) then
            if _isPluginStillRequired(self._pluginTrail[1]) then
                local view, ctrlInstance = my.informPluginByName(self._pluginTrail[1])
                if type(view) == "userdata" then
                    if ctrlInstance and ctrlInstance.setOnExitCallback then
                        ctrlInstance:setOnExitCallback(_onPluginExit)
                    else
                        view:onNodeEvent("exit", _onPluginExit)
                    end
                    PluginTrailMonitor.isPluginDisplaying = true
                end
            else
                table.remove(self._pluginTrail, 1)
                _popPlugin()
            end
        end
    end
    function _onPluginExit()
        table.remove(self._pluginTrail, 1)
        PluginTrailMonitor.isPluginDisplaying = false
        _popPlugin()
    end
    _popPlugin()
end

function PluginTrailMonitor:clearTrail()
    self._pluginTrail = {}
end

--判断下队列里是否已经有该插件
function PluginTrailMonitor:isPluginInTrail( pluginName )
    for i, _params in pairs(self._pluginTrail) do
        if _params.pluginName == pluginName then return true end
    end
    return false
end

return PluginTrailMonitor