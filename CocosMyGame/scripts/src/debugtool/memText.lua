local MEMText = class("MEMText")

MEMText.RES_PATH = "res/gmtool/memtext.csb"

function MEMText:ctor()
    self:createResNode()
end

function MEMText:createResNode()
    local node = cc.CSLoader:createNode(self.RES_PATH)    
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(0, 0)
    node:setLocalZOrder(998)
    local curScene = display.getRunningScene()
    curScene:addChild(node)
    self._resNode = node
    self._label = node:getChildByName("Text_Info")
end

function MEMText:refresh()
    if not DeviceUtils:getInstance().getRuntimeMemoryInfo then
        return
    end
    local memoryInfo = DeviceUtils:getInstance():getRuntimeMemoryInfo()
    if not memoryInfo then return end

    local function fmtNum(num)
        return tostring(math.floor(num / 1024)) .. 'kb'
    end
    if self._label then
        local str = string.format(' availbytes:%s\n totalbytes:%s\n threshold:%s\n lowMemory:%s\n luaMemory:%s',
            fmtNum(memoryInfo.availbytes),
            fmtNum(memoryInfo.totalbytes),
            fmtNum(memoryInfo.threshold),
            tostring(memoryInfo.lowMemory),
            fmtNum(collectgarbage('count')*1024))
        self._label:setString(str)
    end
end

function MEMText:close()
    if self._resNode then
        self._resNode:removeSelf()
    end
    if self._label then
        self._label = nil
    end
end

return MEMText