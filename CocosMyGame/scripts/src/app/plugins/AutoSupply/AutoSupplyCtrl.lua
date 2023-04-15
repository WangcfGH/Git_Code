local AutoSupplyCtrl = class("AutoSupplyCtrl", cc.load('BaseCtrl'))
local AutoSupplyView = import('src.app.plugins.AutoSupply.AutoSupplyView')
local AutoSupplyModel      = import("src.app.plugins.AutoSupply.AutoSupplyModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

function AutoSupplyCtrl:onCreate(params, ...)
	local viewNode = self:setViewIndexer(AutoSupplyView:createViewIndexer())
    self._viewNode = viewNode
    if params and params.data then 
        self._roomInfo = params.data 
    end

    --点击空白处关闭界面
    self._baseLayer = cc.Layer:create()
    if self._baseLayer then
        viewNode:addChild(self._baseLayer)
    end
    self._baseLayer:setTouchEnabled(true)
    local listener = function(eventType, x, y)
            if eventType == "began" then
                if not self:containsTouchLocation(x, y) then
                    self:goBack()
                end
                return true
            elseif eventType == "moved" then
                return false
            elseif eventType == "ended" then
                return false
            end
        end
    self._baseLayer:registerScriptTouchHandler(listener, false, -1, false)


    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    AutoSupplyModel:setAlive(true)
end

function AutoSupplyCtrl:containsTouchLocation(x, y)
    local viewNode = self._viewNode
    local position = viewNode.PanelAnimation:convertToWorldSpace(cc.p(viewNode.PanelAnimation:getChildByName("Image_Bg"):getPosition()))

    local s = viewNode.PanelAnimation:getChildByName("Image_Bg"):getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

function AutoSupplyCtrl:initialListenTo( )
    
end

function AutoSupplyCtrl.createEditbox(node,inputMode, viewNode, imgBg, textFieldInput)
    if not viewNode then return nil end

    imgBg = imgBg or viewNode:getChildByName("Img_Bg")
    textFieldInput = textFieldInput or viewNode:getChildByName("TextField_Input")

    textFieldInput:setVisible(false)

    local editBox = ccui.EditBox:create(textFieldInput:getContentSize(), "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")

    editBox.getString       = editBox.getText
    editBox.setString       = editBox.setText
    editBox.setTextColor    = editBox.setFontColor

    editBox:setPosition(imgBg:getPosition())
    editBox:setAnchorPoint(imgBg:getAnchorPoint())

    local fontName = textFieldInput:getFontName() == '' and 'Arial' or textFieldInput:getFontName()
    local color = textFieldInput:getColor()
    editBox:setFontName(fontName)
    editBox:setFontColor(color)
    editBox:setFontSize(textFieldInput:getFontSize())

    editBox:setPlaceHolder(textFieldInput:getPlaceHolder())
    editBox:setPlaceholderFontName(fontName)
    editBox:setPlaceholderFontSize(textFieldInput:getFontSize())
    editBox:setPlaceholderFontColor(cc.c4b(color.r, color.g, color.b, 127))

    editBox:setMaxLength(textFieldInput:getMaxLength())
    editBox:setInputMode(inputMode)

    local parent = textFieldInput:getParent()
    parent:addChild(editBox)

    editBox:setLocalZOrder(imgBg:getLocalZOrder() + 1)

    return editBox
end

function AutoSupplyCtrl:initialBtnClick( )
    local viewNode = self._viewNode

    viewNode.BtnPlus:addClickEventListener(handler(self, self.onBtnPlus))
    viewNode.BtnMinus:addClickEventListener(handler(self, self.onBtnMinus))
    viewNode.BtnAutoSupply:addClickEventListener(handler(self, self.BtnAutoSupply))
    self._editBox = self:createEditbox(2,viewNode.PanelEdit)
    if self._editBox then
        self._editBox:registerScriptEditBoxHandler(handler(self, self.onEditBoxChanged))
    end
end

function AutoSupplyCtrl:onEditBoxChanged(event, sender)
    print("============================", event)
    if event == "began" then
        -- 安卓收不到“取消”消息，故安卓不做清空处理
        if device.platform ~= "android" then
            self._editBox:setString("")
        end
    elseif event == "ended" then
        local strInput = sender:getString()
        if strInput == "" then
            self:freshSupplyCount()
            return
        end

        self._supplyCount = tonumber(strInput)
        if tonumber(strInput) > self._roomInfo.nMaxDeposit then
            self._supplyCount = self._roomInfo.nMaxDeposit
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = '不能设置超过房间上限的值', removeTime = 2}})
        elseif tonumber(strInput) < self._roomInfo.nMinDeposit then
            self._supplyCount = self._roomInfo.nMinDeposit
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = '不能设置超过房间下限的值', removeTime = 2}})
        end
        self:freshSupplyCount()
    end

end
function AutoSupplyCtrl:BtnAutoSupply( )
    my.playClickBtnSound()
    local viewNode = self._viewNode

    local bStartSupply = false
    bStartSupply = CacheModel:getCacheByKey("StartSupply" .. tostring(user.nUserID))
    if type(bStartSupply) == "boolean" then
        self._bStartSupply = bStartSupply
    else
        bStartSupply = false
    end
    bStartSupply = not bStartSupply
    CacheModel:saveInfoToCache("StartSupply" .. tostring(user.nUserID), bStartSupply)

    self:freshBubble(bStartSupply)

    local silverAutoOpeInfo = {
        ["clickTime"]       = os.date("%Y%m%d%H%M%S", os.time()),
        ["userID"]          = user.nUserID,
        ["platFormType"]    = device.platform,
        ["tcyChannel"]      = tostring(my.getTcyChannelId()),
        ["roomID"]          = self._roomInfo.nRoomID,
        ["depositValue"]    = self._supplyCount,
        ["autostatus"]      = bStartSupply
    }
    
    my.dataLink(cc.exports.DataLinkCodeDef.SILVER_AUTO_BTN_OPE_CLICK, silverAutoOpeInfo)

    local tipString
    local name = cc.exports.isAutoSupplySaveSupported() and "自动存取银" or "自动取银"
    if not bStartSupply then
        tipString = name .. "已关闭，期待您再次开启"
    else
        tipString = name .. "设置成功"
    end
    my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = tipString, removeTime = 2}})
end

function AutoSupplyCtrl:freshBubble(bStartSupply)
    local viewNode = self._viewNode
    viewNode.ImgBubble:setVisible(not bStartSupply)
end

function AutoSupplyCtrl:onBtnMinus( )
    my.playClickBtnSound()
    my.playClickBtnSound()
    local viewNode = self._viewNode

    self._supplyCount = self._supplyCount - self._roomInfo.nMinDeposit/5

    if self._supplyCount <= self._roomInfo.nMinDeposit then
        self._supplyCount = self._roomInfo.nMinDeposit
    end

    self:freshSupplyCount()
end

function AutoSupplyCtrl:freshSupplyCount( )
    local viewNode = self._viewNode
    self._editBox:setString(self._supplyCount)
    if self._supplyCount <= self._roomInfo.nMinDeposit then
        viewNode.BtnMinus:setTouchEnabled(false)
        viewNode.BtnMinus:setBright(false)
        viewNode.BtnPlus:setTouchEnabled(true)
        viewNode.BtnPlus:setBright(true)

    elseif self._supplyCount >= self._roomInfo.nMaxDeposit then
        viewNode.BtnMinus:setTouchEnabled(true)
        viewNode.BtnMinus:setBright(true)
        viewNode.BtnPlus:setTouchEnabled(false)
        viewNode.BtnPlus:setBright(false)
    else
        viewNode.BtnMinus:setTouchEnabled(true)
        viewNode.BtnMinus:setBright(true)
        viewNode.BtnPlus:setTouchEnabled(true)
        viewNode.BtnPlus:setBright(true)
    end
    CacheModel:saveInfoToCache("SupplyCount" .. self._roomInfo.nRoomID .. tostring(user.nUserID), tostring(self._supplyCount))
end

function AutoSupplyCtrl:onBtnPlus( )
    my.playClickBtnSound()
    local viewNode = self._viewNode

    self._supplyCount = self._supplyCount + self._roomInfo.nMinDeposit/5

    if self._supplyCount >= self._roomInfo.nMaxDeposit then
        self._supplyCount = self._roomInfo.nMaxDeposit
    end

    self:freshSupplyCount()
    
--    if cc.exports.isSafeBoxSupported() then
--        if(player:isSafeboxHasSecurePwd() and not player:hasSafeboxGotRndKey())then
--            self:informPluginByName('SafeboxPswPlaneCtrl',{})
--        else
--            player:moveSafeDeposit(1000)
--        end
--    else
--        if cc.exports.isBackBoxSupported() then
--            player:moveSafeDeposit(1000)
--        end
--    end

end

function AutoSupplyCtrl:updateUI()
    local viewNode = self._viewNode
    if not viewNode then return end
    if not self._roomInfo then return end 

    local bShow = cc.exports.isAutoSupplySaveSupported()
    viewNode.TextExplain:setVisible(bShow)
    viewNode.TextExplain1:setVisible(not bShow)
    viewNode.ImgTitleBg:setVisible(bShow)
    viewNode.ImgTitleBg1:setVisible(not bShow)

    local str = cc.exports.isAutoSupplySaveSupported() and "存补银金额" or "补银金额"
    viewNode.TextSupplyDeposit:setString(str)

    if user.nSafeboxDeposit then
        viewNode.TextSafeBox:setMoney(user.nSafeboxDeposit)
    end

    local bStartSupply = CacheModel:getCacheByKey("StartSupply" .. tostring(user.nUserID))
    if type(bStartSupply) ~= "boolean" then
        bStartSupply = false
    end

    viewNode.BtnAutoSupply:setSelected(bStartSupply)
    self:freshBubble(bStartSupply)

    local ratioInfo = cc.exports.getAutoSupplyRatioValue()

    local supplyCount = CacheModel:getCacheByKey("SupplyCount" .. self._roomInfo.nRoomID .. tostring(user.nUserID))
    if type(supplyCount) == "string" and tonumber(supplyCount) > 0 then
        self._supplyCount = tonumber(supplyCount)
    else
        self._supplyCount =  self._roomInfo.nMinDeposit * ratioInfo[tostring(self._roomInfo.nRoomID)]
    end

    self:freshSupplyCount()
    --不在活动范围冿
--    if not AutoSupplyModel:isAlive() then
--        self:goBack()
--        return
--    end
end

function AutoSupplyCtrl:goBack()
    CacheModel:saveInfoToCache("SupplyCount" .. self._roomInfo.nRoomID .. tostring(user.nUserID), tostring(self._supplyCount))
    self:removeSelf()
end

function AutoSupplyCtrl:removeSelf()
    AutoSupplyModel:setAlive(false)
    AutoSupplyCtrl.super.removeSelf(self)
end

function AutoSupplyCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()
end

function AutoSupplyCtrl:onGetCenterCtrlNotify()
    printLog('AutoSupplyCtrl', 'onGetCenterCtrlNotify')

    self:goBack()
end

return AutoSupplyCtrl