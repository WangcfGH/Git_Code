local ExchangeCenterCtrl = class('ExchangeCenterCtrl',cc.load('BaseCtrl'))
local ExchangeCenterView = import('src.app.plugins.ExchangeCenter.ExchangeCenterView')

local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local player = mymodel('hallext.PlayerModel'):getInstance()

function ExchangeCenterCtrl:onCreate(params,...)
    self._params = params
    local selectTabName = "silver"
    if self._params and self._params.defaultPage then
       selectTabName = self._params.defaultPage
    end
    self:setView(ExchangeCenterView)
    ExchangeCenterView:setCtrl(self)

	local viewNode = self:setViewIndexer(ExchangeCenterView:createViewIndexer())

    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED, handler(self, self.updatePlayerInfo))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.TICKET_ITEM_LIST_UPDATED, handler(self, self.updateExchangeArea))
    --self:listenTo(ExchangeCenterModel, ExchangeCenterModel.MY_TICKET_RECORD_UPDATED, handler(self, self.updateHistoryArea))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EXCHANGE_SILVER_OK, handler(self, self.onExchangeSilverOK))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EXCHANGE_TOOL_OK, handler(self, self.onExchangeToolOK))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EXCHANGE_MOBILE_BILL_OK, handler(self, self.onExchangeMobileBillOK))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EXCHANGE_REAL_ITEM_OK, handler(self, self.onExchangeRealItemOK))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EXCHANGE_CUSTOMPROP_OK, handler(self, self.onExchangeCustomPropOK))
    self:listenTo(player, player.PLAYER_DATA_UPDATED, handler(self,self.updatePlayerInfo))

    ExchangeCenterModel:getTicketNum()
    ExchangeCenterModel:getTicketItemList() --兑换物品信息

    --兑换记录
    ExchangeCenterModel:resetMyTicketRecordList()
    ExchangeCenterModel:getMyTicketsRecord(ExchangeCenterModel.TICKET_RECORD_EXCHANGE)
    ExchangeCenterModel:getMyTicketsRecord(ExchangeCenterModel.TICKET_RECORD_EXPIRE)

    --不用调用showTab，因为ExchangeCenterModel:getTicketItemList()会触发updateExchangeArea->refreshCurTab，否则会连续刷两遍界面
    ExchangeCenterView:_selectTab(self._viewNode, selectTabName)
    --ExchangeCenterView:showTab(self._viewNode, selectTabName)
end

function ExchangeCenterCtrl:onEnter()
    ExchangeCenterCtrl.super.onEnter(self)
    ExchangeCenterView:refreshView(self._viewNode)
end

function ExchangeCenterCtrl:onExit()
    ExchangeCenterView:onExit()
    ExchangeCenterCtrl.super.onExit(self)

    local HallContext = require("src.app.plugins.mainpanel.HallContext"):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_backToMainSceneFromNonSceneFullScreenCtrl"]})
end

function ExchangeCenterCtrl:onClickExchItem(exchItem)
    print("ExchangeCenterCtrl:onClickExchItem")

    if not CenterCtrl:checkNetStatus() then
        print("checkNetStatus fail!!!")
        return
    end

    local itemData = exchItem["itemData"]
    local itemNode = exchItem["itemNode"]
    if ExchangeCenterModel:getTicketNumData() < itemData.price then
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = ExchangeCenterModel.exchConfig["ExchangeNotEnough"], removeTime = 2}})
    else--兑换券足够
        if itemData.nType == ExchangeCenterModel.EXCHANGEITEM_TYPE_ENTITY 
            or itemData.nType == ExchangeCenterModel.EXCHANGEITEM_TYPE_CELLPHONE then --实物与话费
            my.scheduleOnce(function()
                my.informPluginByName({pluginName='ExchangeItemNeedInput', params = itemData})
            end)       
        elseif itemData.nType == ExchangeCenterModel.EXCHANGEITEM_TYPE_SILVER 
            or itemData.nType == ExchangeCenterModel.EXCHANGEITEM_TYPE_CUSTOMPROP then  --银子和道具
            my.scheduleOnce(function()
                my.informPluginByName({pluginName = 'ExchangeItemNormal', params = itemData})
            end) 
        end
    end
end

function ExchangeCenterCtrl:updatePlayerInfo()
    ExchangeCenterView:refreshPanelTop(self._viewNode)
end

function ExchangeCenterCtrl:updateExchangeArea() --显示兑换内容
    ExchangeCenterView:refreshCurTab(self._viewNode)
end

function ExchangeCenterCtrl:onExchangeOK(prizeID)
    self:addMyTicketRecord(prizeID)--添加本地记录
    self:updatePlayerInfo() --刷新用户兑换券以及银子信息
end

function ExchangeCenterCtrl:addMyTicketRecord(prizeID) --只有在进入兑换中心时才请求，兑换物品后 手动添加记录
    local itemList = ExchangeCenterModel:getTicketItemListData()
    for i, n in ipairs(itemList) do
        if tonumber(prizeID) == tonumber(n.prizeID) then
            local record = {}
            record["Count"] = n.price
            record["Description"] = n.prizeName
            local yearMonthDay = os.date("%Y/%m/%d", os.time())
            local hourMinute = os.date("%H:%M", os.time())
            record["YearMonthDay"] = yearMonthDay
            record["HourMinute"] = hourMinute
            ExchangeCenterModel:addMyTicketRecord(record)
            --self:updateHistoryArea()
            break
        end 
    end
end
 
function ExchangeCenterCtrl:onExchangeSilverOK(param)
    print("ExchangeCenterCtrl:onExchangeSilverOK")
    dump(param)
    local data = param.data
    local status = data.status
    local msg = data.message
    local prizeID = data.prizeID   
    if status then    
        self:onExchangeOK(prizeID)
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = ExchangeCenterModel.exchConfig["ExchangeOK"], removeTime = 2}})
    else
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = msg, removeTime = 2}})    
    end
end

function ExchangeCenterCtrl:onExchangeCustomPropOK(param)
    print("ExchangeCenterCtrl:onExchangeCustomPropOK")
    dump(param)
    local data = param.data
    local status = data.status
    local msg = data.message
    local prizeID = data.prizeID   
    if status then
        self:onExchangeOK(prizeID)
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = ExchangeCenterModel.exchConfig["ExchangeOK"], removeTime = 2}})
    else
        print("ExchangeCenterCtrl:onExchangeCustomPropOK fail")
        ExchangeCenterModel:addExchangeCount(prizeID, -1)
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = msg, removeTime = 2}})
    end
end

function ExchangeCenterCtrl:onExchangeToolOK(param)
    print("ExchangeCenterCtrl:onExchangeToolOK")
    dump(param)
    local data = param.data
    local prizeID = data.prizeID
    local status = data.status
    local msg = data.message

    if status then    
        self:onExchangeOK(prizeID)
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = ExchangeCenterModel.exchConfig["ExchangeOK"], removeTime = 2}})      
    else
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = msg, removeTime = 2}})    
    end  
end

function ExchangeCenterCtrl:onExchangeMobileBillOK(param)
    print("ExchangeCenterCtrl:onExchangeMobileBillOK")
    dump(param)
    local data = param.data
    local prizeID = data.prizeID
    local status = data.status
    local msg = data.message
    local title
    local isSuccess = false
    if status then    
        self:onExchangeOK(prizeID)
        msg = ExchangeCenterModel.exchConfig["ExchangeCellphoneOK"]
        title = ExchangeCenterModel.exchConfig["ExchangeSuccessed"]
        isSuccess = true
    else
        title = ExchangeCenterModel.exchConfig["ExchangeFailed"]
    end

     my.scheduleOnce(function()
        my.informPluginByName({pluginName='ExchangeItemResult', params = {title = title, message = msg, isSuccess = isSuccess}})
    end)
end
 
function ExchangeCenterCtrl:onExchangeRealItemOK(param)
    print("ExchangeCenterCtrl:onExchangeRealItemOK")
    dump(param)
    local data = param.data
    local prizeID = data.prizeID
    local status = data.status
    local msg = data.message
    local title
    local isSuccess = false
    if status then    
        self:onExchangeOK(prizeID)
        msg = ExchangeCenterModel.exchConfig["ExchangeEntityOK"]
        title = ExchangeCenterModel.exchConfig["ExchangeSuccessed"]
        isSuccess = true
    else
        title = ExchangeCenterModel.exchConfig["ExchangeFailed"]
    end

     my.scheduleOnce(function()
        my.informPluginByName({pluginName='ExchangeItemResult', params = {title = title, message = msg, isSuccess = isSuccess}})
    end)
end

return ExchangeCenterCtrl
