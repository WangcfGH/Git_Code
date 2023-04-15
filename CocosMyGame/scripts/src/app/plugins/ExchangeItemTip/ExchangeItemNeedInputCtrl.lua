--话费、实物类
local viewCreater = import('src.app.plugins.ExchangeItemTip.ExchangeItemNeedInputView')
local ExchangeItemNeedInputCtrl = class('ExchangeItemNeedInputCtrl', cc.load('BaseCtrl'))
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local ExchangeCenterConfig = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ExchangeCenterConfig.json"))
if BusinessUtils:getInstance():isGameDebugMode() then
    ExchangeCenterConfig = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ExchangeCenterConfig_Debug.json"))
end

--与ExchangeCenterConfig.json中的nType一致.
ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_ENTITY = 3 --实物
ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_CELLPHONE = 2 --话费

ExchangeItemNeedInputCtrl.CELLPHONE_NUMBER_LONGTH = 11

function ExchangeItemNeedInputCtrl:onCreate(...)
	self:setViewIndexer(viewCreater:createViewIndexer())

	local viewNode = self._viewNode

    local param = ...
    self._itemPrice = param.price 
    self._itemName = param.prizeName  
    self._itemType = param.nType 
    self._prizeID = param.prizeID
    self._itemSpriteFramePath = param.itemSpriteFramePath
    self._remainCount = ExchangeCenterModel:getRemainExchangeCount(self._prizeID)

    self:_initView()
    if self._itemSpriteFramePath then
    viewNode.spriteItemIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(self._itemSpriteFramePath))
    end
    viewNode.textTitle:setString(self._itemName)
    viewNode.textCountTip:setString(string.format(viewNode.textCountTip:getString(), self._remainCount))
    if self._itemType == ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_ENTITY then
        self:createEntityInputItem()              
    elseif self._itemType == ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_CELLPHONE then
        self:createCellphoneInputItem()                 
    end 

    self:bindDestroyButton(viewNode.closeBtn)
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))    
    viewNode.submitBtn:addClickEventListener(handler(self, self.exchangeItem))
    viewNode.okBtn:addClickEventListener(function()
        my.playClickBtnSound()
        self:removeSelfInstance()
        my.scheduleOnce(function()
            my.informPluginByName({pluginName='ToastPlugin',params={tipString="该商品已达到今日可兑换上限",removeTime=1}})
        end)
    end)
    viewNode.panelMain:setScale(0.7)
    viewNode.panelMain:setVisible(false)
    viewNode.panelMain:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil)) 
    if self._remainCount > 0 then
        viewNode.submitBtn:setVisible(true)
        viewNode.okBtn:setVisible(false)
    else
        viewNode.submitBtn:setVisible(false)
        viewNode.okBtn:setVisible(true)
    end
end

function ExchangeItemNeedInputCtrl:_initView()
    local viewNode = self._viewNode

    self._viewData = {
        ["inputPanels"] = {
            {["panel"] = viewNode.addressPanel, ["name"] = "addressPanel", ["isAvail"] = true, ["posYRaw"] = 130},
            {["panel"] = viewNode.cellphoneSurePanel, ["name"] = "cellphoneSurePanel", ["isAvail"] = true, ["posYRaw"] = 130},
            {["panel"] = viewNode.cellphonePanel, ["name"] = "cellphonePanel", ["isAvail"] = true, ["posYRaw"] = 130},
            {["panel"] = viewNode.namePanel, ["name"] = "namePanel", ["isAvail"] = true, ["posYRaw"] = 130}
        }
    }
end

function ExchangeItemNeedInputCtrl:_refreshInputPanelArrange()
    local viewNode = self._viewNode
    local inputPanels = self._viewData["inputPanels"]

    local visibleCount = 0
    for i = 1, #inputPanels do
        if inputPanels[i]["isAvail"] == true then
            visibleCount = visibleCount + 1
            inputPanels[i]["panel"]:setVisible(true)
        else
            inputPanels[i]["panel"]:setVisible(false)
        end
    end

    --缩小弹框高度
    local heightOffset = 60 * (#inputPanels - visibleCount)
    viewNode.panelMain:setContentSize(cc.size(viewNode.panelMain:getContentSize().width, 550 - heightOffset))
    ccui.Helper:doLayout(viewNode.panelMain:getRealNode())
    viewNode.panelTitle:setPositionY(viewNode.panelTitle:getPositionY() - heightOffset)

    local curVisibleIndex = 0
    for i = 1, #inputPanels do
        inputPanels[i]["posYRaw"] = inputPanels[i]["panel"]:getPositionY()

        if inputPanels[i]["isAvail"] == true then
            curVisibleIndex = curVisibleIndex + 1

            local posY = inputPanels[curVisibleIndex]["posYRaw"]
            inputPanels[i]["panel"]:setPositionY(posY)
        end
    end
end

function ExchangeItemNeedInputCtrl:createCellphoneInputItem()
    local viewNode = self._viewNode
    --local width = viewNode.panelMain:getContentSize().width
    --local height = viewNode.panelMain:getContentSize().height    

    self:createEditBox("cellphoneInfo", cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self:createEditBox("cellphoneSureInfo", cc.EDITBOX_INPUT_MODE_PHONENUMBER)

    --viewNode.namePanel:setVisible(false)
    --viewNode.addressPanel:setVisible(false)      

    --viewNode.cellphonePanel:setVisible(true)
    --viewNode.cellphonePanel:setPosition(cc.p(width / 2, height * 0.65))
    viewNode.cellphoneInfoClearBtn:addClickEventListener(function()
        viewNode.cellphoneInfo:setText("")
    end)

    --viewNode.cellphoneSurePanel:setVisible(true)
    --viewNode.cellphoneSurePanel:setPosition(cc.p(width / 2, height * 0.45))
    viewNode.cellphoneSureInfoClearBtn:addClickEventListener(function()
        viewNode.cellphoneSureInfo:setText("")
    end)

    if self._remainCount > 0 then
        self._viewData["inputPanels"][1]["isAvail"] = false
        self._viewData["inputPanels"][4]["isAvail"] = false
    else
        self._viewData["inputPanels"][1]["isAvail"] = false
        self._viewData["inputPanels"][2]["isAvail"] = false
        self._viewData["inputPanels"][3]["isAvail"] = false
        self._viewData["inputPanels"][4]["isAvail"] = false
    end
    
    self:_refreshInputPanelArrange()
end

function ExchangeItemNeedInputCtrl:createEntityInputItem()
    local viewNode = self._viewNode
    --local width = viewNode.panelMain:getContentSize().width
    --local height = viewNode.panelMain:getContentSize().height    

    self:createEditBox("nameInfo", cc.EDITBOX_INPUT_MODE_ANY)
    self:createEditBox("cellphoneInfo", cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self:createEditBox("addressInfo", cc.EDITBOX_INPUT_MODE_ANY)  

    --viewNode.cellphoneSurePanel:setVisible(false)

    --viewNode.namePanel:setVisible(true)
    --viewNode.namePanel:setPosition(cc.p(width / 2, height * 0.7))
    viewNode.nameInfoClearBtn:addClickEventListener(function()
        viewNode.nameInfo:setText("")
    end)     

    --viewNode.cellphonePanel:setVisible(true)
    --viewNode.cellphonePanel:setPosition(cc.p(width / 2, height * 0.55))
    viewNode.cellphoneInfoClearBtn:addClickEventListener(function()
        viewNode.cellphoneInfo:setText("")
    end)

    --viewNode.addressPanel:setVisible(true) 
    --viewNode.addressPanel:setPosition(cc.p(width / 2, height * 0.4))
    viewNode.addressInfoClearBtn:addClickEventListener(function()
        viewNode.addressInfo:setText("")
    end)    

    self._viewData["inputPanels"][2]["isAvail"] = false
    self:_refreshInputPanelArrange()
end

function ExchangeItemNeedInputCtrl:checkCellphoneInputItemLegality()
    local viewNode = self._viewNode    
    local phoneNumber =  viewNode.cellphoneInfo:getText()  
    local phoneNumberSure =  viewNode.cellphoneSureInfo:getText() 
        
    local msg
    local cellphoneNumber
    if string.len(phoneNumber) == 0 then            
        msg = ExchangeCenterConfig["InputPhoneNumberEmpty"]  
    elseif tonumber(phoneNumber) == nil or string.len(phoneNumber) ~= ExchangeItemNeedInputCtrl.CELLPHONE_NUMBER_LONGTH then 
        msg = ExchangeCenterConfig["InputPhoneNumberNotLegal"]
    elseif string.len(phoneNumberSure) == 0 then
        msg = ExchangeCenterConfig["InputPhoneNumberSureEmpty"]
    elseif phoneNumber ~= phoneNumberSure then
        msg = ExchangeCenterConfig["InputPhoneNumberNotSame"] 
    else
        cellphoneNumber = tonumber(phoneNumber)      
    end             
                        
    return msg, cellphoneNumber
end

function ExchangeItemNeedInputCtrl:checkEntityInputItemLegality()
    local viewNode = self._viewNode    
    local name = viewNode.nameInfo:getText() 
    local phoneNumber =  viewNode.cellphoneInfo:getText() 
    local address = viewNode.addressInfo:getText()  

    local msg
    local cellphoneNumber
    if string.len(name) == 0 then
        msg = ExchangeCenterConfig["InputNameEmpty"]    
    elseif string.len(phoneNumber) == 0 then            
        msg = ExchangeCenterConfig["InputPhoneNumberEmpty"]  
    elseif tonumber(phoneNumber) == nil or string.len(phoneNumber) ~= ExchangeItemNeedInputCtrl.CELLPHONE_NUMBER_LONGTH then 
        msg = ExchangeCenterConfig["InputPhoneNumberNotLegal"] 
    elseif string.len(address) == 0 then
        msg = ExchangeCenterConfig["InputAddressEmpty"]   
    else
        cellphoneNumber = tonumber(phoneNumber)      
    end             
                        
    return msg, cellphoneNumber, name, address
    
end

function ExchangeItemNeedInputCtrl:exchangeItem()   
    my.playClickBtnSound()     
    if self._itemType == ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_ENTITY then
        local msg, cellphoneNumber, name, address = self:checkEntityInputItemLegality()  
        if msg then
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = msg, removeTime = 1}}) 
        else
            ExchangeCenterModel:exchangeRealItem(self._prizeID, 1, cellphoneNumber, name, address) 
            self:removeSelfInstance()
        end 
    elseif self._itemType == ExchangeItemNeedInputCtrl.EXCHANGE_ITEM_CELLPHONE then
        local msg, phoneNumber = self:checkCellphoneInputItemLegality()
        if msg then
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = msg, removeTime = 1}}) 
        else
            ExchangeCenterModel:exchangeMobileBill(self._prizeID, 1, phoneNumber)   
            self:removeSelfInstance()
        end                        
    end
end

function ExchangeItemNeedInputCtrl:createEditBox(name, mode) --mode：输入类型键盘
    local viewNode = self._viewNode
    local text = viewNode[name]
    text:setVisible(false)

    local editBox = ccui.EditBox:create(text:getContentSize(), "faker.png")

    editBox:setPosition(text:getPosition())
    editBox:setAnchorPoint(text:getAnchorPoint())

    editBox:setFontColor(cc.c3b(255, 255, 255))
    editBox:setFontSize(text:getFontSize())

    editBox:setPlaceHolder(text:getString())
	editBox:setPlaceholderFontSize(text:getFontSize())
	editBox:setPlaceholderFontColor(cc.c3b(255, 255, 255))

    editBox:setFontName(text:getFontName())	
	editBox:setInputMode(mode)

    local parent = text:getParent()
    parent:addChild(editBox)

    viewNode[name] = editBox
end

return ExchangeItemNeedInputCtrl