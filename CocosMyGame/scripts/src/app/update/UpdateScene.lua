local UpdateScene = class('UpdateScene', require('src.app.update.UpdateBaseScene'))

UpdateScene.VIEW = 'update_download.csb'
UpdateScene.CSBDIR = 'res/hallcocosstudio/update/'

function UpdateScene:bindView()
    UpdateScene.super.bindView(self)
    self:initSceneStatus()
end

function UpdateScene:bindViewNode()
    local panel = self._viewNode:getChildByName('Panel_UpdateMain')
    if panel then
        self._textTip = panel:getChildByName('Text_Detail')
        self._imageTip = panel:getChildByName('Img_DetailBG')
        self._btnInstall = panel:getChildByName('Btn_Update')
        self._progressBar = panel:getChildByName('Loading_Update')
        self._progressDot = panel:getChildByName('Img_ProgressDot')
    end
    self._panelCopyRight = self._viewNode:getChildByName('Panel_AttentionWords')
end

function UpdateScene:bindButtonEvent()
    if self._btnInstall then
        self._btnInstall:addClickEventListener(handler(self._ctrl, self._ctrl.install))
    end
end

function UpdateScene:initSceneStatus()
    self:setTipText()
    self:showInstallButton(false)
    self:setUpdateProgress(0)
end

function UpdateScene:setUpdateProgress(percent)
    if self._progressBar then
        self._progressBar:setPercent(percent)
    end

    if self._progressDot then
        self._progressDot:setVisible(percent == 0 and false or true)
    end
end

function UpdateScene:setTipText(text)
    local bShow = type(text) == 'string'

    if self._textTip then
        self._textTip:setVisible(bShow)
        self._textTip:setString(bShow and text or '')
    end

    if self._imageTip then
        self._imageTip:setVisible(bShow)
    end
end

function UpdateScene:showInstallButton(bShow)
    if self._btnInstall then
        self._btnInstall:setVisible(bShow)
    end
end

return UpdateScene