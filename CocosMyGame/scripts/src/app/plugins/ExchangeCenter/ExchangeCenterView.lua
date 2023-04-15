local ExchangeCenterView = cc.load('ViewAdapter'):create()

local UserModel = mymodel('UserModel'):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()  
local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

ExchangeCenterView.exchItemsLayoutConfig = {
    ["itemWidth"] = 260,
    ["itemHeight"] = 266,
    ["scrollDirection"] = "y",
    ["paddingX"] = 0,
    ["paddingY"] = 40,

    ["visibleWidth"] = 960,
    ["visibleHeight"] = 620,
    ["visibleCols"] = 3,
    ["visibleRows"] = 2,

    ["gapX"] = 20,
    ["gapXMax"] = 150,
    ["gapY"] = 10,
    ["gapYMax"] = 50,

    ["posXStartRaw"] = -1,
    ["posYStartRaw"] = -1,
    ["posXStart"] = -1,
    ["posYStart"] = -1,
}

ExchangeCenterView.EXCH_ITEM_CSBPATH = "res/hallcocosstudio/ExchangeCenter/Node_ExchangeItem.csb"
ExchangeCenterView.EXCH_ITEM_SPRITENAMES = {
    ["Img_Silver1"] = "yz2_bg_pic.png", ["Img_Silver2"] = "yz3_bg_pic.png", ["Img_Silver3"] = "yz4_bg_pic.png", 
    ["Img_Silver4"] = "yz5_bg_pic.png",

    ["Img_Goods_1"] = "Goods1.png", ["Img_Goods_2"] = "Goods2.png", ["Img_Goods_3"] = "Goods3.png",
    ["Img_Goods_4"] = "Goods4.png", ["Img_Goods_5"] = "Goods5.png", ["Img_Goods_6"] = "Goods6.png",
    ["Img_Goods_7"] = "Goods7.png", ["Img_Goods_8"] = "Goods8.png", ["Img_Goods_9"] = "Goods9.png",

    ["Img_Telephonerate1"] = "Exchange_Img_Telephonerate1.png", ["Img_Telephonerate2"] = "Exchange_Img_Telephonerate2.png", 
    ["Img_Telephonerate3"] = "Exchange_Img_Telephonerate5.png", ["Img_Telephonerate4"] = "Exchange_Img_Telephonerate10.png", 
    ["Img_Telephonerate5"] = "Exchange_Img_Telephonerate50.png", ["Img_Telephonerate6"] = "Exchange_Img_Telephonerate100.png",
    ["Img_Telephonerate7"] = "Exchange_Img_Telephonerate500.png",

    ["Img_CardRecorder"] = "Exchange_CardRecorder.png",
    ["Img_Iphone"] = "Exchange_Img_Iphone.png",
}

ExchangeCenterView.viewConfig = {
	'res/hallcocosstudio/ExchangeCenter/ExchangeCenterNew.csb',
	{
        opePanel = 'Operate_Panel',
        {
            _option = {prefix = 'Operate_Panel.'},
            panelTop = 'Panel_Top',
            panelTab = 'Panel_Tab',
            scrollView = 'ScrollView_Items'
        }
	}
}

function ExchangeCenterView:onCreateView(viewNode)
    self._viewData = {
        ["tabItemsMap"] = {
            ["phoneFee"] = {
                ["itemNode"] = nil,
                ["itemName"] = "phoneFee",
                ["itemType"] = ExchangeCenterModel.EXCHANGEITEM_TYPE_CELLPHONE,
                ["isAvail"] = cc.exports.isExchangePhoneFeeSupported(),

                ["tabIndex"] = 1 --用于索引exchItems
            },
            ["silver"] = {
                ["itemNode"] = nil,
                ["itemName"] = "silver",
                ["itemType"] = ExchangeCenterModel.EXCHANGEITEM_TYPE_SILVER,
                ["isAvail"] = true,

                ["tabIndex"] = 2
            },
            ["realItem"] = {
                ["itemNode"] = nil,
                ["itemName"] = "realItem",
                ["itemType"] = ExchangeCenterModel.EXCHANGEITEM_TYPE_ENTITY,
                ["isAvail"] = cc.exports.isExchangeRealItemSupported(),

                ["tabIndex"] = 3
            },
            ["prop"] = {
                ["itemNode"] = nil,
                ["itemName"] = "prop",
                ["itemType"] = ExchangeCenterModel.EXCHANGEITEM_TYPE_CUSTOMPROP,
                ["isAvail"] = true,

                ["tabIndex"] = 4
            }
        },
        ["tabPriority"] = {"phoneFee", "silver", "realItem", "prop"}, --上对齐
        ["tabPosY"] = {},
        ["tabItemsList"] = {},
        ["curTabName"] = nil,

        ["exchItems"] = {
            --[1] = {["itemNode"] = nil, ["itemData"] = nil}
        }
    }

    self:_initView(viewNode)
    self:refreshTabAvail(viewNode)
end

function ExchangeCenterView:_initView(viewNode)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/exchange_img_new.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/CheckIn_IconDeposit.plist")

    if SpringFestivalModel:showSpringFestivalView() then
        viewNode:getChildByName("Img_BG"):setVisible(false)
        viewNode:getChildByName("Img_BG_1"):setVisible(true)
    else
        viewNode:getChildByName("Img_BG"):setVisible(true)
        viewNode:getChildByName("Img_BG_1"):setVisible(false)
    end

    UIHelper:calcGridLayoutConfig(viewNode.scrollView, ExchangeCenterView.exchItemsLayoutConfig, "fillInitColumsAndAveragePaddingGap", nil)
    self:_initPanelTop(viewNode)
    self:_initPanelTab(viewNode)
end

function ExchangeCenterView:_initPanelTop(viewNode)
    local panelTop = viewNode.panelTop
    local btnBack = panelTop:getChildByName("Button_Back")
    local btnRecord = panelTop:getChildByName("Button_Record")
    local panelDeposit = panelTop:getChildByName("Panel_Deposit")
    local btnAdd = panelDeposit:getChildByName("Button_Add")

    btnBack:addClickEventListener(function()
        my.playClickBtnSound()
        self._ctrl:closeSelf()
    end)
    btnRecord:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName = 'ExchangeRecordCtrl'})
    end)
    
    SubViewHelper:bindPluginToBtn(btnAdd, "ShopCtrl")
end

function ExchangeCenterView:_initPanelTab(viewNode)
    local panelTab = viewNode.panelTab

    for i = 1, #self._viewData["tabPriority"] do
        local tabName = self._viewData["tabPriority"][i]
        local tabItem = self._viewData["tabItemsMap"][tabName]
        tabItem["itemNode"] = panelTab:getChildByName("Button_"..i)
        self._viewData["tabPosY"][i] = tabItem["itemNode"]:getPositionY() --保存初始位置

        tabItem["itemNode"]:onTouch(function(e)
		    if e.name=='began' then
                tabItem["itemNode"]:getChildByName("Sprite_Selected"):setVisible(true)
                tabItem["itemNode"]:getChildByName("Sprite_Text_Selected"):setVisible(true)
		    elseif e.name=='ended' or e.name=='cancelled' then
                tabItem["itemNode"]:getChildByName("Sprite_Selected"):setVisible(false)
                tabItem["itemNode"]:getChildByName("Sprite_Text_Selected"):setVisible(false)
                if e.name=='ended' then
                    my.playClickBtnSound()
                    self:showTab(viewNode, tabItem["itemName"])
                end
		    end
	    end)
    end
end

function ExchangeCenterView:refreshTabAvail(viewNode)
    local tabItemsMap = self._viewData["tabItemsMap"]
    local tabItemsList = self._viewData["tabItemsList"]
    for i = 1, #self._viewData["tabPriority"] do
        local tabName = self._viewData["tabPriority"][i]
        local tabItem = tabItemsMap[tabName]
        if tabItem["isAvail"] == true then
            local itemIndex = #tabItemsList + 1
            tabItemsList[itemIndex] = tabItem

            tabItem["itemNode"]:setVisible(true)
            tabItem["itemNode"]:setPositionY(self._viewData["tabPosY"][itemIndex])
        else
            tabItem["itemNode"]:setVisible(false)
        end
    end
end

function ExchangeCenterView:refreshView(viewNode)
    self:refreshPanelTop(viewNode)
end

function ExchangeCenterView:refreshPanelTop(viewNode)
    local panelTop = viewNode.panelTop
    local panelDeposit = panelTop:getChildByName("Panel_Deposit")
    local panelTicket = panelTop:getChildByName("Panel_Ticket")
    local labelUserDeposit = panelDeposit:getChildByName("Bmf_Value")
    local labelUserTicket = panelTicket:getChildByName("Bmf_Value")

    --local ticketNum = string.formatnumberthousands(ExchangeCenterModel:getTicketNumData() or 0) 

    labelUserDeposit:setMoney(UserModel.nDeposit)
    labelUserTicket:setMoney(ExchangeCenterModel:getTicketNumData() or 0)
end

function ExchangeCenterView:showTab(viewNode, tabName)
    ExchangeCenterView:_selectTab(viewNode, tabName)
    ExchangeCenterView:_createExchItems(viewNode, tabName)
end

function ExchangeCenterView:refreshCurTab(viewNode)
    local curTabName = self._viewData["curTabName"]
    if curTabName == nil then return end

    ExchangeCenterView:_selectTab(viewNode, curTabName)
    ExchangeCenterView:_createExchItems(viewNode, curTabName)
end

function ExchangeCenterView:_selectTab(viewNode, tabName)
    if self._viewData["tabItemsMap"][tabName]["isAvail"] == false then
        tabName = "silver" --如果目标tab未开放，则默认选择银两tab
    end
    self._viewData["curTabName"] = tabName

    local setTabSelected = function(tabBtn, isSelect)
        if isSelect ~= tabBtn:getChildByName("Sprite_Selected"):isVisible() then
            tabBtn:getChildByName("Sprite_Selected"):setVisible(isSelect)
            tabBtn:getChildByName("Sprite_Text_Selected"):setVisible(isSelect)
            if isSelect == true then
                tabBtn:setTouchEnabled(false)
            else
                tabBtn:setTouchEnabled(true)
            end
        end
    end

    local targetTabItem = self._viewData["tabItemsMap"][tabName]
    local tabItemsList = self._viewData["tabItemsList"]
    for i = 1, #tabItemsList do
        if tabItemsList[i] == targetTabItem then
            setTabSelected(tabItemsList[i]["itemNode"], true)
        else
            setTabSelected(tabItemsList[i]["itemNode"], false)
        end
    end
end

function ExchangeCenterView:_createExchItems(viewNode, tabName)
    local scrollView = viewNode.scrollView
    local layoutConfig = ExchangeCenterView.exchItemsLayoutConfig

    TimerManager:stopTimer("Timer_ExchangeCenterView_CreateNextExchItem")
    scrollView:removeAllChildren()
    self._viewData["exchItems"] = {}

    local tabItem = self._viewData["tabItemsMap"][tabName]
    local itemDataList = ExchangeCenterModel:getItemDataListByType(tabItem["itemType"])

    local rowsCount = math.floor((#itemDataList - 1) / layoutConfig["visibleCols"]) + 1
    UIHelper:initInnerContentSizeForVerticalScrollView(scrollView, layoutConfig, rowsCount)

    local curItemIndex = 0
    TimerManager:scheduleLoop("Timer_ExchangeCenterView_CreateNextExchItem", function()
        curItemIndex = curItemIndex + 1
        if curItemIndex > #itemDataList then
            TimerManager:stopTimer("Timer_ExchangeCenterView_CreateNextExchItem")
            return
        end

        self:_createNextExchItem(scrollView, layoutConfig, tabName, itemDataList[curItemIndex], self._viewData["exchItems"])
    end, 0.04)

     --兑换是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
    local txtAttention = viewNode.panelTop:getChildByName("Txt_Attention")
    txtAttention:setVisible(false)
    local strMsg = "银子由通宝兑换获得"
    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local enable,status,nLevel,add = NobilityPrivilegeModel:isExchangeGive()
    if tabName== "silver" and enable then
        if status then
            txtAttention:setString(strMsg .. "\n" .."贵族"..nLevel.."加赠"..add.."%")
        else
            txtAttention:setString(strMsg .. "\n" .."贵族"..nLevel.."加赠"..add.."%")
        end
        txtAttention:setVisible(true)
    end
end

function ExchangeCenterView:_createNextExchItem(scrollView, layoutConfig, tabName, itemData, itemsList)
    local nodeRaw = cc.CSLoader:createNode(ExchangeCenterView.EXCH_ITEM_CSBPATH)
	local itemNode = nodeRaw:getChildByName("btn_item")
	itemNode:removeFromParent()

	local itemIndex = #itemsList + 1
	itemNode:setName("exchItem_"..itemIndex)
	local pos = cc.exports.UIHelper:calcGridItemPosEx(layoutConfig, itemIndex)
	itemNode:setPosition(pos)
	scrollView:addChild(itemNode)

	itemsList[itemIndex] = {
		["itemNode"] = itemNode,
		["itemData"] = itemData,
		["tabName"] = tabName
	}
    self:_initExchItem(itemsList[itemIndex])
    self:refreshExchItem(itemsList[itemIndex])
end

function ExchangeCenterView:_initExchItem(exchItem)
    UIHelper:setTouchByScale(exchItem["itemNode"], function()
        my.playClickBtnSound()

        if not UIHelper:checkOpeCycle("ExchangeCenterView_clickExchItem") then
            return
        end
        UIHelper:refreshOpeBegin("ExchangeCenterView_clickExchItem")

        self._ctrl:onClickExchItem(exchItem)
    end, exchItem["itemNode"], 1.05)
end

function ExchangeCenterView:refreshExchItem(exchItem)
    print("ExchangeCenterView:refreshExchItem")
    dump(exchItem)
    if exchItem == nil then
        print("exchItem is nil")
        return
    end
    local itemData = exchItem["itemData"]
    local itemNode = exchItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local labelPrice = itemNode:getChildByName("text_price")
    local spriteItemIcon = itemNode:getChildByName("Sprite_ItemIcon")
    local iconToolDay = itemNode:getChildByName("icon_tool_day")
    local spritePriceIcon = itemNode:getChildByName("Sprite_PriceIcon")

    labelName:setString(itemData["prizeName"])
    labelPrice:setMoney(itemData["price"])
    iconToolDay:setVisible(false)
    spriteItemIcon:setScale(1.0)

    local spriteName = ExchangeCenterView.EXCH_ITEM_SPRITENAMES[itemData["image"]]
    local spriteFramePath = ""
    if exchItem["tabName"] == "silver" then
        spriteFramePath = "hallcocosstudio/images/plist/CheckIn_IconDeposit/"..spriteName
        spriteItemIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFramePath))
    elseif exchItem["tabName"] == "phoneFee" or exchItem["tabName"] == "realItem" then
        spriteFramePath = "hallcocosstudio/images/plist/exchange_img_new/"..spriteName
        spriteItemIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFramePath))
    elseif exchItem["tabName"] == "prop" then
        spriteFramePath = "hallcocosstudio/images/plist/exchange_img_new/Exchange_CardRecorder.png"
        spriteItemIcon:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFramePath))
        spriteItemIcon:setScale(0.8)

        iconToolDay:loadTexture("hallcocosstudio/images/plist/Shop_Img/"..itemData["count"].."day.png", ccui.TextureResType.plistType)
        iconToolDay:setVisible(true)
    end

    --兑换是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local enable,status,nLevel,add = NobilityPrivilegeModel:isExchangeGive()
    if exchItem["tabName"] == "silver" and enable then
        if status then
            local discount_bg = itemNode:getChildByName("discount_bg")
            discount_bg:setVisible(true)
            discount_bg:getChildByName("discount_num"):setVisible(true)
            local depositNum = itemData.count * tonumber(add)/100
            discount_bg:getChildByName("discount_num"):setString("加赠"..depositNum.."两")
        end
    end

    itemData["itemSpriteFramePath"] = spriteFramePath

    UIHelper:adaptElementsToCenterX({labelPrice, spritePriceIcon}, 140) --居中
end

function ExchangeCenterView:onExit()
    TimerManager:stopTimer("Timer_ExchangeCenterView_CreateNextExchItem")
end

return ExchangeCenterView
