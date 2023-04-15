local ExchangeRecordView = cc.load('ViewAdapter'):create()

local UserModel = mymodel('UserModel'):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()  

ExchangeRecordView.scrollItemsLayoutConfig = {
    ["itemWidth"] = 940,
    ["itemHeight"] = 63,
    ["scrollDirection"] = "y",
    ["paddingX"] = 0,
    ["paddingY"] = 0,

    ["visibleWidth"] = 940,
    ["visibleHeight"] = 400,
    ["visibleCols"] = 1,
    ["visibleRows"] = 6,

    ["gapX"] = 0,
    ["gapXMax"] = 0,
    ["gapY"] = 5,
    ["gapYMax"] = 10,

    ["posXStartRaw"] = -1,
    ["posYStartRaw"] = -1,
    ["posXStart"] = -1,
    ["posYStart"] = -1,
}

ExchangeRecordView.SCROLL_ITEM_CSBPATH = "res/hallcocosstudio/ExchangeCenter/Node_History.csb"

ExchangeRecordView.viewConfig = {
	'res/hallcocosstudio/ExchangeCenter/ExchangeRecord.csb',
	{
        panelMain = 'Panel_Main',
        {
            _option = {prefix = 'Panel_Main.'},
            panelNoRecord = 'Panel_NoRecord',
            scrollView = 'ScrollView_Records'
        }
	}
}

function ExchangeRecordView:onCreateView(viewNode)
    self._viewData = {
        ["scrollItems"] = {
            --[1] = {["itemNode"] = nil, ["itemData"] = nil}
        }
    }

    self:_initView(viewNode)
end

function ExchangeRecordView:_initView(viewNode)
    UIHelper:calcGridLayoutConfig(viewNode.scrollView, ExchangeRecordView.scrollItemsLayoutConfig, nil, nil)

    local btnClose = viewNode.panelMain:getChildByName("Button_Close")
    btnClose:addClickEventListener(function()
        my.playClickBtnSound()
        self._ctrl:closeSelf()
    end)
end

function ExchangeRecordView:refreshView(viewNode)
    local itemList = ExchangeCenterModel:getMyTicketRecordData() or {} 

    --测试代码
    --[[for i = 1, 20 do
        itemList[i] = {}
        itemList[i]["Description"] = "111"
        itemList[i]["Count"] = "111"
        itemList[i]["YearMonthDay"] = "111"
    end]]--

    local itemNum = table.maxn(itemList)
    if itemNum <= 0 then
        viewNode.panelNoRecord:setVisible(true)
        viewNode.scrollView:setVisible(false)
    else
        viewNode.panelNoRecord:setVisible(false)
        viewNode.scrollView:setVisible(true)
        self:_createScrollItems(viewNode, itemList)
    end
end

function ExchangeRecordView:_createScrollItems(viewNode, itemDataList)
    if itemDataList == nil then return end

    local scrollView = viewNode.scrollView
    local layoutConfig = ExchangeRecordView.scrollItemsLayoutConfig

    TimerManager:stopTimer("Timer_ExchangeRecordView_CreateNextScrollItem")
    scrollView:removeAllChildren()
    self._viewData["scrollItems"] = {}

    local rowsCount = math.floor((#itemDataList - 1) / layoutConfig["visibleCols"]) + 1
    UIHelper:initInnerContentSizeForVerticalScrollView(scrollView, layoutConfig, rowsCount)

    local curItemIndex = 0
    TimerManager:scheduleLoop("Timer_ExchangeRecordView_CreateNextScrollItem", function()
        curItemIndex = curItemIndex + 1
        if curItemIndex > #itemDataList then
            TimerManager:stopTimer("Timer_ExchangeRecordView_CreateNextScrollItem")
            return
        end

        self:_createNextScrollItem(scrollView, layoutConfig, itemDataList[curItemIndex], self._viewData["scrollItems"])
    end, 0.04)
end

function ExchangeRecordView:_createNextScrollItem(scrollView, layoutConfig, itemData, itemsList)
	local itemNode = cc.CSLoader:createNode(ExchangeRecordView.SCROLL_ITEM_CSBPATH)

	local itemIndex = #itemsList + 1
	itemNode:setName("scrollItem_"..itemIndex)
	local pos = cc.exports.UIHelper:calcGridItemPosEx(layoutConfig, itemIndex)
	itemNode:setPosition(pos)
	scrollView:addChild(itemNode)

	itemsList[itemIndex] = {
		["itemNode"] = itemNode,
		["itemData"] = itemData
	}
    self:_initScrollItem(itemsList[itemIndex])
    self:refreshScrollItem(itemsList[itemIndex])
end

function ExchangeRecordView:_initScrollItem(scrollItem)
    
end

function ExchangeRecordView:refreshScrollItem(scrollItem)
    print("ExchangeRecordView:refreshExchItem")
    if scrollItem == nil then
        print("scrollItem is nil")
        return
    end
    local itemData = scrollItem["itemData"]
    local itemNode = scrollItem["itemNode"]

    local labelItemName = itemNode:getChildByName("Text_HistoryName")
    local labelItemCout = itemNode:getChildByName("Text_HistoryCounts")
    local labelItemTime = itemNode:getChildByName("Text_HistoryTime")

    labelItemName:setString(itemData["Description"])
    labelItemCout:setString(itemData["Count"])
    labelItemTime:setString(itemData["YearMonthDay"])
end

function ExchangeRecordView:onExit()
    TimerManager:stopTimer("Timer_ExchangeRecordView_CreateNextScrollItem")
end

return ExchangeRecordView
