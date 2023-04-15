--定义一些共同的接口函数
local SecondLayerBase = class("SecondLayerBase")

function SecondLayerBase:ctor(layerNode, roomManager)
    self.layerName = ""
    self._layerNode = layerNode
    self._roomManager = roomManager
    self._areaEntryByLayer = nil --由secondLayer决定的areaEntry
    self._enterTime = socket.gettime()
end

function SecondLayerBase:_checkEnterAniDone()
    local timeElapsed = socket.gettime() - self._enterTime
    if timeElapsed < 0.51 then
        return false
    end
    return true
end

function SecondLayerBase:_onClickBtnBack()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("SecondLayer_btnBack") then
        return
    end
    UIHelper:refreshOpeBegin("SecondLayer_btnBack")
    self._roomManager:closeSecondeLayer(true)
end

function SecondLayerBase:initView()
end

function SecondLayerBase:refreshView()
end

function SecondLayerBase:refreshViewOnDepositChange()
end

function SecondLayerBase:dealOnClose()
end

function SecondLayerBase:refreshNPLevelLimit()
end

function SecondLayerBase:refreshPanelQuickStart()
end

return SecondLayerBase