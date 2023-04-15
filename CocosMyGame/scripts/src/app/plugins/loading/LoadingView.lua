local LoadingView = class('LoadingView', cc.Node)

LoadingView.RESOURCE_PATH = 'res/hallcocosstudio/hallcommon/connect.csb'

function LoadingView:ctor(ctrl)
    self._ctrl = ctrl
    self._networkCheckTimer = nil
    self:onCreate()
end

function LoadingView:onCreate()
    self:createResourceNode()
    self:hideProgress()
    self:enableNodeEvents()
end

function LoadingView:createResourceNode()
    local view      = cc.CSLoader:createNode(self.RESOURCE_PATH)
    self:addChild(view)
--    timeline:gotoFrameAndPlay(1, 26, true)
    view:getChildByName("Panel_Shade"):setContentSize(display.size)
    self:setPosition(display.center)
    self._view = view
    return view
end

function LoadingView:onEnter()
    local timeline  = cc.CSLoader:createTimeline(self.RESOURCE_PATH)
    self._view:runAction(timeline)
    timeline:play('ani_connect', true)

    local panelMain = self._view:getChildByName("Panel_Main")
    local networkCheckTxt = panelMain:getChildByName("Img_Text2")
    networkCheckTxt:setVisible(false)
    if DeviceUtils:getInstance().ping then
        self._networkCheckTimer = my.scheduleOnce(function()
            self._networkCheckTimer = nil
            networkCheckTxt:setVisible(true)
            local examBtn = networkCheckTxt:getChildByName("Btn_Exam")
            examBtn:addClickEventListener(function ()
                my.informPluginByName({pluginName='NetworkCheckCtrl'})
            end)
        end, 10)
    end
end

function LoadingView:onExit()
    self:hideProgress()
    self:stopAutoCatchTimer()
    self._ctrl:onExit()
end

function LoadingView:onCleanup()
    self._ctrl:onCleanup()
end

function LoadingView:showProgress(progress, total)
    local panelMain = self._view:getChildByName("Panel_Main")
    local textProgresss = panelMain:getChildByName("Text_Connect")
    textProgresss:setString(string.format("%s/%s", tostring(progress), tostring(total)))
    textProgresss:show()
end

function LoadingView:hideProgress()
    local panelMain = self._view:getChildByName("Panel_Main")
    local textProgresss = panelMain:getChildByName("Text_Connect")
    textProgresss:hide()
end

function LoadingView:stopAutoCatchTimer()
    if not self._networkCheckTimer then return end

    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._networkCheckTimer)
    self._networkCheckTimer = nil
end

return  LoadingView
