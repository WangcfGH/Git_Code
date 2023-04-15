
local NetworkCheckCtrl = class('NetworkCheckCtrl',cc.load('BaseCtrl'))

local NetworkCheckModel = import('src.app.plugins.networkcheck.NetworkCheckModel'):getInstance()
local deviceUtils       = DeviceUtils:getInstance()
local RichText          = import("src.app.GameHall.ctrls.RichText")

NetworkCheckCtrl.LOGUI = 'NetworkCheck'
NetworkCheckCtrl.RUN_ENTERACTION = true

NetworkCheckCtrl.NetworkName = {
    [0] = "无网络",
    [1] = "2G",
    [2] = "3G",
    [3] = "wifi",
    [4] = "4G",
    [5] = "未知类型",
}

NetworkCheckCtrl.NetworkCheckTxt = {
    HallNet = "hallCheckTxt",
    RoomNet = "roomCheckTxt",
    GameNet = "gameCheckTxt",
    ThirdNet = "thiredCheckTxt",
}

function NetworkCheckCtrl:getViewCreater()
    return import('src.app.plugins.networkcheck.NetworkCheckView')
end

function NetworkCheckCtrl:onCreate( params )
    local viewNode=self:setViewIndexer(self:getViewCreater():createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    
    self:listenTo(NetworkCheckModel, NetworkCheckModel.EVENT_START, handler(self, self.startCheckEvent))
    self:listenTo(NetworkCheckModel, NetworkCheckModel.EVENT_PING_FINSIH, handler(self, self.pingCheckEvent))
    self:listenTo(NetworkCheckModel, NetworkCheckModel.EVENT_CONNECT_FINSIH, handler(self, self.connectCheckEvent))
    self:listenTo(NetworkCheckModel, NetworkCheckModel.EVENT_OVER, handler(self, self.overCheckEvent))
    self:listenTo(NetworkCheckModel, NetworkCheckModel.EVENT_IP_ERROR, handler(self, self.ipErrorEvent))

    self:createRichTxt()

    self:initBasicsInfo()
    self:initNetworkInfo()
    self:initResultInfo()
    self:initNetworkResultIcon()
    self:setNetworkResultPos()
end

function NetworkCheckCtrl:onEnter()
    NetworkCheckCtrl.super.onEnter(self)

    self:startCheckNetwork()
end

function NetworkCheckCtrl:onExit()
    NetworkCheckCtrl.super.onExit(self)

    NetworkCheckModel:stopCheckNetwork()
end

function NetworkCheckCtrl:stopAutoCatchTimer()
    if not self._timerStartCheckNetwork then return end

    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerStartCheckNetwork)
    self._timerStartCheckNetwork = nil
end

function NetworkCheckCtrl:onKeyBack()
    NetworkCheckCtrl.super.onKeyBack(self)
end

function NetworkCheckCtrl:initBasicsInfo()
    local viewNode = self._viewNode
    viewNode.operatorTxt:setString("运营商:暂无数据")
    if DeviceUtils:getInstance().getSPN then
        local simOperator, simOperatorName = DeviceUtils:getInstance():getSPN()
        if simOperatorName then
            viewNode.operatorTxt:setString("运营商:" .. simOperatorName)
        end
    end
    viewNode.networkTypeTxt:setString("网络类型:" .. NetworkCheckCtrl.NetworkName[deviceUtils:getNetworkType()])
    viewNode.gameVersionTxt:setString("游戏版本:" .. my.getGameVersion())
    viewNode.systemTimeTxt:setString("系统时间:" .. os.date("%Y-%m-%d %H:%M:%S") .. "(请确认您的时间是否正确)")
end

function NetworkCheckCtrl:initNetworkInfo()
    local viewNode = self._viewNode
    viewNode.hallCheckTxt:setString("服务器1:等待检测")
    viewNode.roomCheckTxt:setString("服务器2:等待检测")
    viewNode.gameCheckTxt:setString("服务器3:等待检测")
    viewNode.thiredCheckTxt:setString("第三方:等待检测")
    for i, v in pairs(self._networkCheckTxt) do
        v.RichTxt:setColorString(v.defaultTxt:getString())
    end
end

function NetworkCheckCtrl:createRichTxt()
    local viewNode = self._viewNode
    self._networkCheckTxt = {}
    for i, v in pairs(NetworkCheckModel.NetworrkEnum) do
        local txtNode = viewNode[NetworkCheckCtrl.NetworkCheckTxt[i]]
        local RichTxt = RichText:create(txtNode:getTextColor(), txtNode:getFontSize())
        RichTxt:setPosition(cc.p(txtNode:getPositionX(), txtNode:getPositionY()-txtNode:getFontSize()))
        txtNode:getParent():addChild(RichTxt)
        txtNode:setVisible(false)
        local icon = txtNode:getChildByName("Result")
        local posInNode = txtNode:getParent():convertToNodeSpace( txtNode:convertToWorldSpace(cc.p(icon:getPosition())) )
        icon:setPosition(posInNode)
        icon:removeFromParent()
        txtNode:getParent():addChild(icon)
        --RichTxt:setColorString(txtNode:getString())
        self._networkCheckTxt[i] = {RichTxt = RichTxt, icon = icon, defaultTxt = txtNode}
    end
end

function NetworkCheckCtrl:initNetworkResultIcon()
    local viewNode = self._viewNode
    for i, v in pairs(self._networkCheckTxt) do
        v.icon:setVisible(false)
    end
end

function NetworkCheckCtrl:setNetworkResultPos()
    local viewNode = self._viewNode
    for i, v in pairs(self._networkCheckTxt) do
        v.icon:setPosition(cc.p(v.RichTxt:getContentSize().width + 40, v.RichTxt:getPositionY() + v.RichTxt.m_nDefSize / 2 + 2))
    end
end

function NetworkCheckCtrl:initResultInfo()
    local viewNode = self._viewNode
    viewNode.resultTxt:setString("等待结果")
end

function NetworkCheckCtrl:startCheckNetwork()
    self:initNetworkInfo()
    self:initNetworkResultIcon()
    self:setNetworkResultPos()
    NetworkCheckModel:startCheckNetwork()
end

function NetworkCheckCtrl:startCheckEvent(data)
    if not data or not data.value then return end
    local viewNode = self._viewNode
    local tipString = "检测中..."
    local iconNode = nil
    if data.value.enum == NetworkCheckModel.NetworrkEnum.HallNet then
        tipString = "服务器1:"..tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.RoomNet then
        tipString = "服务器2:"..tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.GameNet then
        tipString = "服务器3:"..tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.ThirdNet then
        tipString = "第三方:"..tipString
    end
    local checkNodeTable = self._networkCheckTxt[data.value.enum]
    if checkNodeTable then
        checkNodeTable.RichTxt:setColorString(tipString)
        checkNodeTable.defaultTxt:setString(tipString)
        self:showLoading(checkNodeTable.icon)
    end

    self:setNetworkResultPos()
end

function NetworkCheckCtrl:showLoading(iconNode)
    if not iconNode then return end
    iconNode:stopAllActions()
    iconNode:setVisible(true)
    local children=iconNode:getChildren()
    for _,v in pairs(children)do
        v:setVisible(false)
    end
    local waitLoading = iconNode:getChildByName("Sprite_Loading")
    waitLoading:setVisible(true)
    local timeLine = cc.CSLoader:createTimeline('res/hallcocosstudio/exam/examicon.csb')
    iconNode:runAction(timeLine)
    timeLine:play("ani_loading", true)
end

function NetworkCheckCtrl:pingCheckEvent(data)
    if not data or not data.value then return end
    local viewNode = self._viewNode
    local tipString = ""
    local isError = false
    if data.value.delay > NetworkCheckModel.DELAY_ERROR_VALUE then
        tipString = "延迟<c=255>%d<>毫秒 "
        isError = true
    else
        tipString = "延迟%d毫秒 "
    end
    if data.value.packetloss > NetworkCheckModel.PACKETLOSS_ERROR_VALUE then
        tipString = tipString .. "丢包:<c=255>%d<>%% "
        isError = true
    else
        tipString = tipString .. "丢包:%d%% "
    end
    local tipString = string.format( tipString, data.value.delay, data.value.packetloss )
    if data.value.enum == NetworkCheckModel.NetworrkEnum.HallNet then
        tipString = "服务器1:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.RoomNet then
        tipString = "服务器2:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.GameNet then
        tipString = "服务器3:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.ThirdNet then
        tipString = "第三方:" .. tipString
    end
    local checkNodeTable = self._networkCheckTxt[data.value.enum]
    if checkNodeTable then
        checkNodeTable.RichTxt:setColorString(tipString)
        checkNodeTable.defaultTxt:setString(tipString)
        checkNodeTable.isError = isError
    end
    self:setNetworkResultPos()
end

function NetworkCheckCtrl:connectCheckEvent(data)
    if not data or not data.value then return end
    local viewNode = self._viewNode
    local isError = false
    local tipString = "连接"
    if data.value.delay == NetworkCheckModel.TIME_OUT_CODE then
        tipString = tipString .. "<c=255>超时<>"
        isError = true
    elseif data.value.delay then
        if data.value.delay > NetworkCheckModel.DELAY_ERROR_VALUE then
            tipString = tipString .. string.format("成功,用时<c=255>%d<>毫秒", data.value.delay)
            isError = true
        else
            tipString = tipString .. string.format("成功,用时%d毫秒", data.value.delay)
        end
    else
        tipString = ""
    end
    if data.value.enum == NetworkCheckModel.NetworrkEnum.HallNet then
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.RoomNet then
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.GameNet then
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.ThirdNet then
    end
    local checkNodeTable = self._networkCheckTxt[data.value.enum]
    if checkNodeTable then
        local oldString = checkNodeTable.defaultTxt:getString()
        local beginIndex, endIndex = string.find( oldString, "检测中..." )
        if beginIndex then
            oldString = string.sub(oldString, 1, beginIndex - 1)
        end
        tipString = oldString .. tipString
        checkNodeTable.RichTxt:setColorString(tipString)
        checkNodeTable.defaultTxt:setString(tipString)
        checkNodeTable.isError = checkNodeTable.isError or isError
        self:showResult(checkNodeTable.icon, checkNodeTable.isError)
    end
    self:setNetworkResultPos()
end

function NetworkCheckCtrl:showResult(iconNode, isError)
    if not iconNode then return end
    iconNode:stopAllActions()
    iconNode:setVisible(true)
    local children=iconNode:getChildren()
    for _,v in pairs(children)do
        v:setVisible(false)
    end
    local resultNode = nil
    if isError then
        resultNode = iconNode:getChildByName("Img_PhoneNumWrong")
    else
        resultNode = iconNode:getChildByName("Img_PhoneNumRight")
    end
    resultNode:setVisible(true)
end

function NetworkCheckCtrl:overCheckEvent(data)
    local viewNode = self._viewNode
    local isNormal = true
    for i, v in pairs(self._networkCheckTxt) do
        if v.isError then
            isNormal = false
        end
    end
    if isNormal then
        viewNode.resultTxt:setString("您的网络一切正常")
    elseif self._networkCheckTxt[NetworkCheckModel.NetworrkEnum.ThirdNet].isError then
        viewNode.resultTxt:setString("您的网络质量异常,请切换更稳定的网络")
    else
        viewNode.resultTxt:setString("与服务器连接异常,请退出游戏重新尝试连接")
    end

    local logInfo = NetworkCheckModel:getLogInfo()
    print(logInfo)
    if DbgInterface then
        DbgInterface:updateLogToSeverForName("networkcheck", true)
    end
end

function NetworkCheckCtrl:ipErrorEvent(data)
    if not data or not data.value then return end
    local viewNode = self._viewNode

    local tipString = "未获取到域名"
    if data.value.enum == NetworkCheckModel.NetworrkEnum.HallNet then
        tipString = "服务器1:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.RoomNet then
        tipString = "服务器2:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.GameNet then
        tipString = "服务器3:" .. tipString
    elseif data.value.enum == NetworkCheckModel.NetworrkEnum.ThirdNet then
        tipString = "第三方:" .. tipString
    end

    local checkNodeTable = self._networkCheckTxt[data.value.enum]
    if checkNodeTable then
        checkNodeTable.RichTxt:setColorString(tipString)
        checkNodeTable.defaultTxt:setString(tipString)
        checkNodeTable.isError = true
        self:showResult(checkNodeTable.icon, checkNodeTable.isError)
    end
end

return NetworkCheckCtrl
