local SecondLayerTiming = class("SecondLayerTiming", import(".SecondLayerBase"))


function SecondLayerTiming:ctor(layerNode, roomManager)
    SecondLayerTiming.super.ctor(self, layerNode, roomManager)
    self.layerName = "timing"
    self._areaEntryByLayer = "timing"

end

function SecondLayerTiming:initView()
    local layerNode = self._layerNode
end

function SecondLayerTiming:refreshView()
end

function SecondLayerTiming:onKeyback()
    self._roomManager:closeSecondeLayer(true)
    return true
end

function SecondLayerTiming:dealOnClose()
end

return SecondLayerTiming