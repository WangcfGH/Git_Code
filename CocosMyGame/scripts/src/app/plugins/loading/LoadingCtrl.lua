local LoadingCtrl = class('LoadingCtrl', cc.load('BaseCtrl'))

LoadingCtrl.VIEW_PATH = 'src.app.plugins.loading.LoadingView'

function LoadingCtrl:ctor( ... )
    self:onCreate( ... )
end

function LoadingCtrl:onCreate( ... )

end

function LoadingCtrl:createViewNode( ... )
    local instance = LoadingCtrl:getInstance( ... )
    return instance:_getLoadingLayer()
end

function LoadingCtrl:_getLoadingLayer()
    self._view = self._view or require(self.VIEW_PATH):create(self)
    self._view:onUpdate(handler(self, self._onUpdate))
    return self._view
end

function LoadingCtrl:stopLoading()
    if self._view then
        self._view:removeSelf()
    end
end

function LoadingCtrl:onGetCenterCtrlNotify(params)
    LoadingCtrl.super.onGetCenterCtrlNotify(self, params)
    if params.message == 'stopLoading' then
        self:stopLoading()
    end
end

function LoadingCtrl:onExit()
end

function LoadingCtrl:onCleanup()
--    self._view = nil
--    self:removeInstance()
end

function LoadingCtrl:_onUpdate()
    local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
    local currentNetStatus = netProcess:getCurrentNetStatus()
    local progress = 0
    for i = 1, 8 do
--        print(bit.band(currentNetStatus, math.pow(16, i - 1)),  math.pow(16, i - 1))
        if bit.band(currentNetStatus, math.pow(16, i - 1)) == math.pow(16, i - 1) then
            progress = progress + 1
        end
    end
    self._view:showProgress(progress + 1, 8)
end

return  LoadingCtrl
