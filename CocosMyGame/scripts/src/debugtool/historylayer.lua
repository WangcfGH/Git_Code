local HistoryLayer  = class("HistoryLayer")

HistoryLayer.RES_LINE    = "res/gmtool/filelistline.csb"

function HistoryLayer:ctor(resNode, gmLayer)
    resNode:setLocalZOrder(1)
    self._resNode = resNode
    self._gmLayer = gmLayer

    self:initChildName()
    self:registEvent()

    self.nodes.tfMonth:setString(os.date("%m"))
    self.nodes.tfDay:setString(os.date("%d"))
    self:onBtnGo()
    self:initMCLineItem()
end

function HistoryLayer:initChildName()
    local panel         = self._resNode:getChildByName("Panel")
    local datePanel     = panel:getChildByName("Panel_Date")
    local panelMCLog    = panel:getChildByName("Panel_MCLog")
    self.nodes = {
        panel           = panel,
        datePanel       = datePanel,
        tfMonth         = datePanel:getChildByName("TF_Month"),
        tfDay           = datePanel:getChildByName("TF_Day"),
        btnGo           = panel:getChildByName("Btn_Go"),
        btnBack         = panel:getChildByName("Btn_Back"),
        lvFileList      = panel:getChildByName("LV_Filelist"),
        lvTouchPanel    = panel:getChildByName("LV_TouchPanel"),
        panelMCLog      = panel:getChildByName("Panel_MCLog"),
        nodeMCLog       = panelMCLog:getChildByName("Node_MCLog"),
    }
end

function HistoryLayer:registEvent()
    self.nodes.btnGo:addClickEventListener(function()
        self:onBtnGo()
    end)

    self.nodes.btnBack:addClickEventListener(function()
        self._gmLayer:closeHisory()
    end)
end

function HistoryLayer:onBtnGo()
    local nMonth = tonumber(self.nodes.tfMonth:getString())
    local nDay = tonumber(self.nodes.tfDay:getString())
    if not nMonth or not nDay then
        return
    end
    if nMonth <= 0 or nMonth > 12 then
        return
    end
    if nDay <= 0 or nDay > 31 then
        return
    end

    local date = string.format("%s%02d%02d", os.date("%Y"), nMonth, nDay)
    self:showFileList(date)
end

function HistoryLayer:showFileList(date)
    if DEBUG <= 0 then
        date = "release"
    end
    self._logdir = device.writablePath .. "/pntlog/" .. date .. "/"
    self.nodes.lvFileList:removeAllChildren()
    local _filelist = getFileListByDate(date)
    local filelist = {}
    for i=#_filelist, 1, -1 do
        table.insert(filelist, _filelist[i])
    end

    for _, szFileName in ipairs(filelist) do
        self.nodes.lvFileList:pushBackCustomItem(self:creatLineItem(szFileName))
    end
end

function HistoryLayer:addBtnTouchEvent(btn, fnCallback, touchPanel)
    local function onTouchEvent(sender, eventType)
        if eventType == TOUCH_EVENT_BEGAN then
            local begin_p = btn:getTouchBeganPosition()
            btn._ok = false
            if cc.rectContainsPoint(touchPanel:getBoundingBox(), touchPanel:getParent():convertToNodeSpace(begin_p)) then
                btn._ok = true
            end
        elseif eventType == TOUCH_EVENT_MOVED then

        elseif eventType == TOUCH_EVENT_ENDED then
            if btn._ok then
                local end_p = btn:getTouchEndPosition()
                if cc.rectContainsPoint(touchPanel:getBoundingBox(), touchPanel:getParent():convertToNodeSpace(end_p)) then
                    fnCallback()
                end
            end
        elseif eventType == TOUCH_EVENT_CANCELED then

        end
    end
    btn:addTouchEventListener(onTouchEvent)
end

function HistoryLayer:showFile(path)
    self._gmLayer:showHistoryFile(path)
    self._gmLayer:closeHisory()
end

function HistoryLayer:uploadFile(node, path)
    local oldNode = self._uploadingNode
    self._uploadingNode = node
    if not DbgInterface:uploadFile(path, handler(self, self.onUploadEvent)) then
        self._uploadingNode = oldNode
    end
end

function HistoryLayer:onUploadEvent(event)
    writeTestLog("onUploadEvent", tostr(event))
    if not self._uploadingNode then
        return
    end
    local uploadPanel   = self._uploadingNode:getChildByName("Panel"):getChildByName("Panel_Upload")
    local txtPercent    = uploadPanel:getChildByName("Text_Percent")
    local lbProcess     = uploadPanel:getChildByName("LB_Process")
    
    if event.state == "start" then
        uploadPanel:show()
        lbProcess:setPercent(0)
    elseif event.state == "uploading" then
        txtPercent:setString(event.percent .. "%")
        lbProcess:setPercent(event.percent)
    elseif event.state == "finish" then
        uploadPanel:hide()
        if event.success then
            DbgInterface:showMsg("UpLoad File Success!")
        else
            DbgInterface:showMsg("UpLoad File Failed!", display.COLOR_RED)
        end
    end
end

function HistoryLayer:creatLineItem(fileName)
    local filepath = self._logdir .. fileName
    local node = cc.CSLoader:createNode(self.RES_LINE)
    local panel = node:getChildByName("Panel")
    panel:getChildByName("Text_FileName"):setString(fileName)

    self:addBtnTouchEvent(panel:getChildByName("Btn_Show"), function()
        self:showFile(filepath)
    end, self.nodes.lvTouchPanel)

    self:addBtnTouchEvent(panel:getChildByName("Btn_Upload"), function()
        self:uploadFile(node, filepath)
    end, self.nodes.lvTouchPanel)

    node:setPosition(cc.p(0, 2))

    local custom_item = ccui.Layout:create()
    custom_item:addChild(node)
    custom_item:setAnchorPoint(0, 0)
    custom_item:setSwallowTouches(false)
    custom_item:setContentSize(cc.size(500, 70))

    return custom_item
end

function HistoryLayer:initMCLineItem()
    if not MCAgent:getInstance().getLogPath or not MCAgent:getInstance():getLogPath() then
        self.nodes.panelMCLog:hide()
        return
    end
    local playerID = DbgInterface:getPlayerId()
    local fileName = tostring(playerID)
    if playerID <= 0 then
        fileName = "unlogin"
    end
    fileName = "tcy_" .. fileName .. "_" .. os.date("%H%M%S") .. ".txt"
    local node = self.nodes.nodeMCLog
    local panel = node:getChildByName("Panel")
    panel:getChildByName("Text_FileName"):setString(fileName)

    self:addBtnTouchEvent(panel:getChildByName("Btn_Show"), function()
        self:showFile(MCAgent:getInstance():getLogPath())
    end, self.nodes.panelMCLog)

    self:addBtnTouchEvent(panel:getChildByName("Btn_Upload"), function()  
        local oldNode = self._uploadingNode
        self._uploadingNode = node  
        if not DbgInterface:uploadMCLogFile(fileName, handler(self, self.onUploadEvent)) then
            self._uploadingNode = oldNode
        end
    end, self.nodes.panelMCLog)
end

return HistoryLayer
