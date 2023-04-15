local UpdateBaseScene = class('UpdateBaseScene', cc.Scene)

UpdateBaseScene.VIEW = ''
UpdateBaseScene.CSBDIR = ''
UpdateBaseScene.bCreateViewNodeDelay = false

function UpdateBaseScene:ctor(ctrl, ...)
    self._ctrl = ctrl

    self:onCreate(...)
    self:onCreateOver(...)
end

function UpdateBaseScene:onCreate(...)
    if not self.bCreateViewNodeDelay then
        self:createViewNode()
        self:setSpringFestivalView()
        self:bindView()
    end
    self:enableNodeEvents()
end

function UpdateBaseScene:createViewNode()
    local viewNode = cc.CSLoader:createNode(self.CSBDIR .. self.VIEW)
    viewNode:addTo(self)
    viewNode:setContentSize(display.size)
    ccui.Helper:doLayout(viewNode)
    local imgBG = viewNode:getChildByName("Img_BG")
    --imgBG:setScale(display.width/imgBG:getContentSize().width)
    self._viewNode = viewNode
end

function UpdateBaseScene:onCreateOver() end

function UpdateBaseScene:onEnterTransitionFinish()
    if not self._viewNode then
        self:createViewNode()
        self:setSpringFestivalView()
        self:bindView()
    end

    if self._ctrl.onSceneTransitionFinish then
        self._ctrl:onSceneTransitionFinish(self.__cname)
    end
end

function UpdateBaseScene:onExit()
    if self._ctrl.onSceneExit then
        self._ctrl:onSceneExit(self.__cname)
    end
end

function UpdateBaseScene:bindView()
    self:bindViewNode()
    self:bindButtonEvent()
end

function UpdateBaseScene:bindViewNode() end

function UpdateBaseScene:bindButtonEvent() end

function UpdateBaseScene:setTipText(text)
    local bShow = type(text) == 'string'

    if self._textTip then
        self._textTip:setVisible(bShow)
        self._textTip:setString(bShow and text or '')
    end

    if self._imageTip then
        self._imageTip:setVisible(bShow)
    end
end

function UpdateBaseScene:showCopyRight(copyRightConfig)
    if copyRightConfig and self._panelCopyRight then
        if type(copyRightConfig.line) == "number" and copyRightConfig.line > 0 then
            self._panelCopyRight:show()
        else
            self._panelCopyRight:hide()
        end
        local keyName, textInfoName = 'reverseline', 'Text_Info'
        for index = 1, copyRightConfig.line or 0 do
            local textField = self._panelCopyRight:getChildByName(textInfoName .. index)
            local string = copyRightConfig[keyName .. index]
            if textField then 
                if type(string) == 'string' and string.len(string) > 0 then
                    textField:setString(string)
                else
                    textField:setVisible(false)
                end
            end
        end
    else
        printError('StartUp:ShowLogo copy right res is missing.')
    end
end

return UpdateBaseScene