--[[
    paramsTable example
    paramsTable = {
        NoBlock   =   true or false
        TextTitle   = '',
        TextSubTitle = '',
        TextContent = '', with '\n'
        TextTips    = '', can be nil
        ButtonTable = { -- count == 1 or 2
            {
                -- both are option param, but need one
                ButtonTitle = '',
                ButtonImage = {normal, pressed, disable},
                Callback,
                Remove = true
            }
            {
                ButtonTitle = '',
                ButtonImage = {normal, pressed, disable},
                Callback,
                Remove = false
            }
        }
    }
]]

local PopupDialog = class('PopupDialog', ccui.Layout)

PopupDialog.CSBPATH = 'res/hallcocosstudio/update/updatedialog.csb'
PopupDialog.BACKGROUNDCOLOR = cc.c4b(90, 90, 90, 200)
PopupDialog.BUTTONNAME = { 'Btn_Cancel', 'Btn_Commit' }
PopupDialog.CHAILDTAG = UPDATEDIALOG_TAG

PopupDialog.VIEWNODENAME = {    -- if you don`t need member, set ''
    PANEL       = 'Img_MainBox',
    TITLE       = 'Text_Title',
    SUBTITLE    = 'Text_WifiCondition',
    TIPS        = 'Text_UpdateSize',
}

function PopupDialog:ctor(paramsTable)
    self._paramsTable = paramsTable
    self:onCreate()
end

function PopupDialog:onCreate()
    if self._paramsTable.NoBlock ~= true then
        self:setBackGroundLayer()
    end
    self:createViewNode()
    self:setViewNode()
end

function PopupDialog:createViewNode()
    local viewNode = cc.CSLoader:createNode(self.CSBPATH)
    viewNode:addTo(self)
    viewNode:setAnchorPoint(0.5, 0.5)
    viewNode:setPosition(display.size.width/2, display.size.height/2)
    self._viewNode = viewNode
end

function PopupDialog:setBackGroundLayer()
    local backGroundLayer = cc.LayerColor:create(self.BACKGROUNDCOLOR, display.size.width, display.size.height)
    backGroundLayer:setTouchEnabled(true)

    local listener = cc.EventListenerTouchOneByOne:create() 
    listener:registerScriptHandler(function() 
        return true 
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function()end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function()end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function()end, cc.Handler.EVENT_TOUCH_CANCELLED)
    listener:setSwallowTouches(true)
   
    backGroundLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, backGroundLayer) 
    backGroundLayer:addTo(self)
end

function PopupDialog:setViewNode()
    self._panel = self._viewNode:getChildByName(self.VIEWNODENAME.PANEL)
    local params = self._paramsTable

    self:setTitle(params.TextTitle)
    self:setSubTitle(params.TextSubTitle)
    self:setContent(params.TextContent)
    self:setTips(params.TextTips)
    self:setButtons(params.ButtonTable)
end

function PopupDialog:setTitle(title)
    local textTitle = self._panel:getChildByName(self.VIEWNODENAME.TITLE)
    if textTitle then
        textTitle:setString(title)
    end
end

function PopupDialog:setSubTitle(subTitle)
    local textSubTitle = self._panel:getChildByName(self.VIEWNODENAME.SUBTITLE)
    if textSubTitle then
        textSubTitle:setString(subTitle)
    end
end

function PopupDialog:setContent(content)
    local mainPanel = self._panel:getChildByName('Panel_UpdateDetail')

    local scrollPanel = mainPanel and mainPanel:getChildByName('Scroll_UpdateDetail')
    local textContent = scrollPanel and scrollPanel:getChildByName('Text_UpdateDetail')

    if textContent then
        self:autoWrapToFitTextField(textContent, content, scrollPanel)
    end
end

function PopupDialog:setTips(tips)
    local textTips = self._panel:getChildByName(self.VIEWNODENAME.TIPS)
    if textTips then
        if tips then
            textTips:setString(tips)
        else
            textTips:setVisible(false)
        end
    end
end

function PopupDialog:setButtons(buttonTable)
    local visibleButton = {}
    for index = 1, #self.BUTTONNAME do
        local button = self._panel:getChildByName(self.BUTTONNAME[index])
        local params = buttonTable[index]
        if button then
            if params then
                self:setButton(button, params)
                visibleButton[#visibleButton + 1] = button
            else
                button:setVisible(false)
            end
        end
    end

    self:fitButtonPosition(visibleButton)
end

function PopupDialog:setButton(button, params)
    if params.ButtonTitle then
        button:setTitleText(params.ButtonTitle)
    end

    if type(params.ButtonImage) == 'table' and table.nums(params.ButtonImage) == 3 then
        button:loadTextureNormal(params.ButtonImage[1])
        button:loadTexturePressed(params.ButtonImage[2])
        button:loadTextureDisabled(params.ButtonImage[3])
    end

    if params.Callback then
        button:addClickEventListener(function ()
            local tempParams = params
            if tempParams.Remove then
                self:removeSelf()
            end
            tempParams.Callback()
        end)
    end

    button:onTouch(function(e)
        if e.name == 'began' then
            self:playButtonSound()
        end
    end)
end

function PopupDialog:fitButtonPosition(buttons)
    if #buttons == 1 then
        local content = self._panel:getContentSize()
        buttons[1]:setPositionX(content.width/2)
    end
end

function PopupDialog:show(scene)
    local curScene = scene or cc.Director:getInstance():getRunningScene()
    local lastDialog = curScene:getChildByTag(self.CHAILDTAG)
    if lastDialog then
        lastDialog:removeFromParent()
    end

    curScene:addChild(self, 0, self.CHAILDTAG)
end

function PopupDialog:playButtonSound()
    audio.playSound('res/hall/sounds/KeypressStandard.mp3')
end


function PopupDialog:autoWrapToFitTextField(text, str, scrollPanel)
    local textSize = text:getContentSize()
    local paragraphs = UpdateUtils.cutStrIntoParagraphs(str)
    local countHeight = 0
    for _, paragraph in pairs(paragraphs) do
        text:setString(paragraph)
        local renderSize = text:getVirtualRendererSize()
        local paraHeight = math.ceil(renderSize.width / textSize.width) * renderSize.height
        countHeight = countHeight + paraHeight
    end
    text:setString(str)
    if countHeight > scrollPanel:getContentSize().height then
        text:setContentSize( { width = textSize.width, height = countHeight + 10 })
        local innerContainer = scrollPanel:getInnerContainer()
        local innerSize = innerContainer:getContentSize()
        innerContainer:setContentSize( { width = innerSize.width, height = countHeight + 10 })
        text:setPositionY(innerContainer:getContentSize().height)
        scrollPanel:jumpToTop()
    end
end

return PopupDialog