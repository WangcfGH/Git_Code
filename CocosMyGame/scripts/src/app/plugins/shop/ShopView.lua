local ShopView = cc.load('ViewAdapter'):create()
local UserModel = mymodel('UserModel'):getInstance()     
--local shopResConfig = import('src.app.HallConfig.ResConfig')
local ShopModel = mymodel("ShopModel"):getInstance()
local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

ShopView.shopItemsLayoutConfig = {
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
--虽然相同，但暂不做修改，防止以后需要扩展
ShopView.shopViewConfig = {
    ["silver"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
    ["vip"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
    ["prop"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
    ["expression"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
    ["tongbao"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
    ["exchange"] = {
        ["csbPath"] = "res/hallcocosstudio/shop/node_items_pay.csb"
    },
}

ShopView.viewConfig={
	'res/hallcocosstudio/shop/shop.csb',
	{
        _option = {prefix='Operate_Panel.'},
        panelTab = 'Panel_Tab',
        {
            _option = {
                prefix = 'Panel_Tab.'
            },
            btnChargeAgreement = 'Btn_ChargeAgreement'
        },

        scrollView = 'Scroll_PayItemsContainer',
        textAttention = 'Text_Attention',
        panel_topbar = 'Panel_TopBar',
        {
            _option = {
                prefix = 'Panel_TopBar.'
            },
            
            panelDeposit = 'Panel_Deposit',
            panelTongbao = 'Panel_Tongbao',
            valueDeposit = 'Panel_Deposit.Bmf_Value',
            valueTongbao = 'Panel_Tongbao.Bmf_Value'
        },

        panel_vipinfo = "Panel_VIPInfo",
    }
}

function ShopView:onCreateView(viewNode)
    self._viewData = {
        ["tabItemsMap"] = {
            ["silver"] = {
                ["itemNode"] = nil,
                ["itemName"] = "silver",
                ["isAvail"] = true,

                ["tabIndex"] = 1 --用于索引shopitems
            },
            ["vip"] = {
                ["itemNode"] = nil,
                ["itemName"] = "vip",
                --["isAvail"] = cc.exports.isVIPSupported(),
                ["isAvail"] = false,

                ["tabIndex"] = 2 
            },
            ["prop"] = {
                ["itemNode"] = nil,
                ["itemName"] = "prop",
                ["isAvail"] = true,

                ["tabIndex"] = 3
            },
            ["expression"] = {
                ["itemNode"] = nil,
                ["itemName"] = "expression",
                ["isAvail"] = true,

                ["tabIndex"] = 4
            },
            ["tongbao"] = {
                ["itemNode"] = nil,
                ["itemName"] = "tongbao",
                ["isAvail"] = cc.exports.isShopTongbaoSupport(),
                ["tabIndex"] = 5
            },
            ["exchange"] = {
                ["itemNode"] = nil,
                ["itemName"] = "exchange",
                ["isAvail"] = cc.exports.isShopTongbaoExchangeSupported(),
                ["tabIndex"] = 6
            }
        },
        ["tabPriority"] = {"silver", "vip", "prop", "expression", "tongbao", "exchange"}, --顶对齐
        ["tabPosY"] = {},
        ["tabItemsList"] = {},
        ["curTabName"] = -1,

        ["shopItems"] = {
            --[1] = {["itemNode"] = nil, ["itemData"] = nil}
        }
    }

    if self._ctrl._params and self._ctrl._params["NoBoutCardRecorder"] == true then --游戏内屏蔽表情
        self._viewData["tabItemsMap"]["expression"]["isAvail"] = false
    end
    viewNode.panel_topbar:getChildByName("Button_Setting"):setVisible(false)
    self:_initView(viewNode)
    self:refreshTabAvail(viewNode)
end

function ShopView:_initView(viewNode)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/Shop_Img.plist")

    if SpringFestivalModel:showSpringFestivalView() then
        viewNode:getChildByName("Img_BG"):setVisible(false)
        viewNode:getChildByName("Img_BG_1"):setVisible(true)
    else
        viewNode:getChildByName("Img_BG"):setVisible(true)
        viewNode:getChildByName("Img_BG_1"):setVisible(false)
    end

    UIHelper:calcGridLayoutConfig(viewNode.scrollView, ShopView.shopItemsLayoutConfig, "fillInitColumsAndAveragePaddingGap", nil)
    self:_initPanelTop(viewNode)
    self:_initPanelTab(viewNode)
    self:_initPanelVipInfo(viewNode)
    self._discountNode = nil
    self._viewData["curTabName"] = ""
end

function ShopView:_initPanelTop(viewNode)
    local panelTop = viewNode.panel_topbar
    local panelVipInfo = viewNode.panel_vipinfo
    local btnBack = panelTop:getChildByName("Button_Back")
    local btnSetting = panelTop:getChildByName("Button_Setting")

    btnBack:addClickEventListener(function()
        my.playClickBtnSound()
        self._ctrl:removeSelfInstance()
    end)

    btnSetting:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName = "SettingsPlugin"})
    end)

    panelVipInfo:setVisible(false)
end

function ShopView:_initPanelTab(viewNode)
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

function ShopView:_initPanelVipInfo(viewNode)

    local panelVipInfo = viewNode.panel_vipinfo
    local panelPrivileges = panelVipInfo:getChildByName("Panel_PrivilegeContainer")

    --会员特权说明
    local nodeRaw = cc.CSLoader:createNode("res/hallcocosstudio/shop/node_bluemen_detail.csb")
    local panelTip = nodeRaw:getChildByName("Panel_bluemen_detail")
    panelTip:removeFromParent()
    panelTip:setName("panelPrivilegeTip")
    --panelPrivileges:setLocalZOrder(2)
    panelPrivileges:addChild(panelTip)
    panelTip:setVisible(false)
    local labelDesc = panelTip:getChildByName("Text_VIP_detail")

    local privilegesConfig = self._ctrl._shopTipsConfig["VIPRightDesConfig"]
    for i = 1, #privilegesConfig do
        local btnPrivilege = panelPrivileges:getChildByName(privilegesConfig[i]["icon_name"])
        btnPrivilege:onTouch(function(e)
            if e.name == "began" then
                e.target:setColor(cc.c3b(166, 166, 166))

                panelTip:setVisible(true)
                panelTip:setPosition(cc.p(btnPrivilege:getPositionX(), btnPrivilege:getPositionY() + 50))
                local tipStr = privilegesConfig[i]["icon_des"]
                if i == 3 then
                    local diff = cc.exports.reliefVipConfig.Limit.DailyLimitNum - cc.exports.reliefConfig.Limit.DailyLimitNum
                    local count = cc.exports.reliefVipConfig.Limit.DailyLimitNum
                    tipStr = string.format(tipStr, diff, count)
                end
                labelDesc:setString(tipStr)
            elseif e.name == "moved" then
            else
                e.target:setColor(cc.c3b(255, 255, 255))

                panelTip:setVisible(false)
            end
        end)
    end
end

function ShopView:refreshTabAvail(viewNode)
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

function ShopView:refreshView(viewNode)
    self:refreshPanelTop(viewNode)
    self:refreshVIPInfo(viewNode)
    self:refreshExpressionTips(viewNode)
end

function ShopView:refreshPanelTop(viewNode)
    viewNode.valueDeposit:setMoney(UserModel.nDeposit)
    viewNode.valueTongbao:setMoney(UserModel.dWealth)
end

function ShopView:showTab(viewNode, tabName)
    ShopView:_selectTab(viewNode, tabName)
    ShopView:createShopItems(viewNode, tabName)
end

function ShopView:refreshCurTab(viewNode)
    local curTabName = self._viewData["curTabName"]
    if curTabName == nil then return end

    ShopView:_selectTab(viewNode, curTabName)
    ShopView:createShopItems(viewNode, curTabName)
end

function ShopView:_selectTab(viewNode, tabName)
    self._viewData["curTabName"] = tabName
    local imgAttention = viewNode.img_attendtion
    local panelVipInfo = viewNode.panel_vipinfo 

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

    --设置title的文字图片
    local panel_topbar = viewNode.panel_topbar
    local titlePic = {
        ["silver"] = "title_silver.png",
        ["vip"] = "title_vip.png",
        ["prop"] = "title_tool.png",
        ["expression"] = "title_dress.png",
        ["tongbao"] = "title_tongbao.png",
        ["exchange"] = "title_exchange.png",
    }
    panel_topbar:getChildByName("title_select"):setSpriteFrame("hallcocosstudio/images/plist/Shop_Img/" .. titlePic[tabName])

    panelVipInfo:setVisible(tabName == "vip")

    local strAttention = ''
    if tabName == 'silver' then
        strAttention = '银子由通宝兑换获得'
        --充值是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
        local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        local enable,status,nLevel,add = NobilityPrivilegeModel:isRechargeGive()
        if enable then
            if status then
                strAttention = "银子由通宝兑换获得    贵族"..nLevel.."加赠"..add.."%"
            else
                strAttention = "银子由通宝兑换获得    贵族"..nLevel.."加赠"..add.."%"
            end
        end
    elseif tabName == 'expression' then
        strAttention = string.format(self._ctrl._shopTipsConfig["EXPRESSION_PANEL_TIPS"], cc.exports._gameJsonConfig.ExpressionTools.ExpressionSilverLimit)
    elseif tabName == 'tongbao' then
        strAttention = '购买通宝不增加贵族经验，不计入任何活动。'
    elseif tabName == 'exchange' then
        -- strAttention = '1元=100通宝'
    end

    viewNode.textAttention:setString(strAttention)
end

function ShopView:refreshVIPInfo(viewNode)
    local panelTop = viewNode.panel_topbar

    local panelVipInfo = viewNode.panel_vipinfo
    local panelAnnouncement = panelVipInfo:getChildByName("Panel_Announcement")
    local labelAnnouncement = panelAnnouncement:getChildByName("Text_Announcement")

    if cc.exports.isVIPSupported() then
        local vipTitleDes
        vipTitleDes = self._ctrl._shopTipsConfig["NotVIPDes"]
        labelAnnouncement:setString(vipTitleDes)
    end
end

function ShopView:refreshExpressionTips(viewNode)
    if viewNode.panel_Expression then
    else
        return
    end

    local panel = viewNode.panel_Expression:getChildByName("Panel_Announcement_Expre")
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.ExpressionTools and cc.exports._gameJsonConfig.ExpressionTools.ExpressionSilverLimit > 0 then
        panel:setVisible(true)
        local str = string.format( self._ctrl._shopTipsConfig["EXPRESSION_PANEL_TIPS"], cc.exports._gameJsonConfig.ExpressionTools.ExpressionSilverLimit)
        panel:getChildByName("Text_Announcement_Expre"):setString(str)
    else
        panel:setVisible(false)
    end
end

function ShopView:createShopItems(viewNode, tabName)
    local scrollView = viewNode.scrollView
    local layoutConfig = ShopView.shopItemsLayoutConfig

    TimerManager:stopTimer("Timer_ShopView_CreateNextShopItem")
    if not tolua.isnull(self._discountNode) then
        self._discountNode:stopAllActions()
    end
    scrollView:removeAllChildren()
    self._viewData["shopItems"] = {}

    local tabItem = self._viewData["tabItemsMap"][tabName]
    local itemIds = ShopModel:GetIDsByTabs(tabItem["tabIndex"])

    --特殊处理
    if tabName == "prop" and self._ctrl._params and self._ctrl._params["NoBoutCardRecorder"] == true then
        table.remove(itemIds, 1) --对记牌器道具，如果是游戏内触发，需要移除局数记牌器购买，仅提供人民币购买

        --同时去除银子购买定时赛门票
        local index = -1
        for i = 1, #itemIds do
            local config = ShopModel:GetItemByID(itemIds[i])
            if config.proptype == "prop_timinggame_ticket_deposit" then
                index = i
            end
        end
        table.remove(itemIds, index)
    end

    local rowsCount = math.floor((#itemIds - 1) / layoutConfig["visibleCols"]) + 1
    UIHelper:initInnerContentSizeForVerticalScrollView(scrollView, layoutConfig, rowsCount)

    local curItemIndex = 0
    TimerManager:scheduleLoop("Timer_ShopView_CreateNextShopItem", function()
        curItemIndex = curItemIndex + 1
        if curItemIndex > #itemIds then
            TimerManager:stopTimer("Timer_ShopView_CreateNextShopItem")
            return
        end

        self:_createNextShopItem(scrollView, layoutConfig, tabName, itemIds[curItemIndex], self._viewData["shopItems"])
    end, 0.04)
end

function ShopView:_createNextShopItem(scrollView, layoutConfig, tabName, itemId, itemsList)
    local itemData = ShopModel:GetItemByID(itemId)
    if itemData == nil then return end

    local tabViewConfig = ShopView.shopViewConfig[tabName]
    local nodeRaw = cc.CSLoader:createNode(tabViewConfig["csbPath"])
	local itemNode = nodeRaw:getChildByName("btn_item")
	itemNode:removeFromParent()

	local itemIndex = #itemsList + 1
	itemNode:setName("shopItem_"..itemIndex)
	local pos = cc.exports.UIHelper:calcGridItemPosEx(layoutConfig, itemIndex)
	itemNode:setPosition(pos)
	scrollView:addChild(itemNode)

	itemsList[itemIndex] = {
		["itemNode"] = itemNode,
		["itemData"] = itemData,
		["tabName"] = tabName
	}
    self:_initShopItem(itemsList[itemIndex])
    self:refreshShopItem(itemsList[itemIndex])
end

function ShopView:_initShopItem(shopItem)
    UIHelper:setTouchByScale(shopItem["itemNode"], function()
        my.playClickBtnSound()
        self._ctrl:onClickShopItem(shopItem)
    end, shopItem["itemNode"], 1.05)
end

function ShopView:refreshShopItem(shopItem)
    if shopItem["tabName"] == "silver" then
        self:refreshSilverItem(shopItem)
    elseif shopItem["tabName"] == "vip" then
        self:refreshVIPItem(shopItem)
    elseif shopItem["tabName"] == "prop" then
        self:refreshPropItem(shopItem)
    elseif shopItem["tabName"] == "expression" then
        self:refreshExpressionItem(shopItem)
    elseif shopItem.tabName == "tongbao" then
        self:refreshTongbaoItem(shopItem)
    elseif shopItem.tabName == "exchange" then
        self:refresgExchangeItem(shopItem)
    end
end

function ShopView:refreshSilverItem(shopItem)
    print("ShopView:refreshSilverItem")
    if shopItem == nil then
        print("shopItem is nil")
        return
    end
    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local labelPrice = itemNode:getChildByName("text_price")
    --local labelDesc = itemNode:getChildByName("Text_item_detail")
    local iconSilver = itemNode:getChildByName("Sprite_ItemIcon")
    local iconFlag = itemNode:getChildByName("icon_conner")
    local iconFlagFirstCharge = itemNode:getChildByName("icon_conner_firstcharge")

    iconSilver:setVisible(true)
    labelName:setString(itemData["title"])
    labelPrice:setVisible(true)
    labelPrice:setMoney(itemData["price"].."元")

    local shopImgFilePrefix = "hallcocosstudio/images/plist/Shop_Img/"
    if itemData["First_Support"] == 1 then
        iconFlagFirstCharge:setVisible(true)
        iconFlag:setVisible(false)
        local discount_bg = itemNode:getChildByName("discount_bg")
        discount_bg:setVisible(true)
        discount_bg:getChildByName("discount_num"):setVisible(true)
        discount_bg:getChildByName("discount_num"):setString(itemData["fristpay_description"])
        --labelDesc:setString(itemData["fristpay_description"])
    else
        iconFlagFirstCharge:setVisible(false)
        
        local flagImgNames = {[1] = "shop_conner_hot.png", [2] = "shop_conner_weigh.png", [3] = "shop_conner_onlyone.png"}
        if flagImgNames[itemData["labeltype"]] then
            iconFlag:setVisible(true)
            iconFlag:loadTexture(shopImgFilePrefix..flagImgNames[itemData["labeltype"]], ccui.TextureResType.plistType)
        else
            iconFlag:setVisible(false)
        end
        --labelDesc:setString(itemData["description"])
    end

    --充值是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local enable,status,nLevel,add = NobilityPrivilegeModel:isRechargeGive()
    if enable then
        if status then
            local discount_bg = itemNode:getChildByName("discount_bg")
            discount_bg:setVisible(true)
            discount_bg:getChildByName("discount_num"):setVisible(true)
            local depositNum = shopItem.itemData.productnum * tonumber(add)/100
            discount_bg:getChildByName("discount_num"):setString("加赠"..depositNum.."两")
        end
    end

    local checkinImgFilePrefix = "hallcocosstudio/images/plist/CheckIn_IconDeposit/"
    local silverImgNames = {
        [1] = "yz1_bg_pic.png", [2] = "yinzi_6bg.png", [3] = "yz2_bg_pic.png", 
        [4] = "yz3_bg_pic.png", [5] = "yz4_bg_pic.png", [6] = "yz5_bg_pic.png"
    }
    iconSilver:setSpriteFrame(checkinImgFilePrefix..silverImgNames[itemData["icontype"]])
end

function ShopView:refreshVIPItem(shopItem)
    print("ShopView:refreshVIPItem")
    if shopItem == nil then
        print("shopItem is nil")
        return
    end
    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local labelPrice = itemNode:getChildByName("text_price")
    local iconVIP = itemNode:getChildByName("Sprite_ItemIcon")
    --local iconFlag = itemNode:getChildByName("icon_conner")

    iconVIP:setVisible(true)
    labelName:setString(itemData["title"])
    labelPrice:setMoney(itemData["price"].."元")
    labelPrice:setVisible(true)
    iconVIP:setVisible(true)
    --iconFlag:setVisible(false)

    local shopImgFilePrefix = "hallcocosstudio/images/plist/Shop_Img/"
    local vipImgNames = {
        [1] = "icon_Vip_yue_lz_pic.png", [2] = "icon_Vip_ji_lz_pic.png", [3] = "icon_Vip_nian_lz_pic.png"
    }
    iconVIP:setSpriteFrame(shopImgFilePrefix..vipImgNames[itemData["icontype"]])
end

function ShopView:refreshPropItem(shopItem)
    print("ShopView:refreshPropItem")    

    if shopItem == nil then
        print("shopItem is nil")
        return
    end
    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    if itemData["proptype"] == "prop_timinggame_ticket_rmb_first" and TimingGameModel:getTimingGameFirstBuyState() then
        print("prop_timinggame_ticket_rmb_first is buyyed")
        itemNode:setVisible(false)
        return
    end

    if itemData["proptype"] == "prop_timinggame_ticket_rmb" and not TimingGameModel:getTimingGameFirstBuyState() then
        print("prop_timinggame_ticket_rmb need first item buyyed then show")
        itemNode:setVisible(false)
        return
    end

    local labelName = itemNode:getChildByName("Text_item_name")
    local iconProp = itemNode:getChildByName("Sprite_ItemIcon")
    local iconPropType = itemNode:getChildByName("icon_tool_day")
    local iconFlag = itemNode:getChildByName("icon_conner")

    iconProp:setVisible(true)
    labelName:setString(itemData["title"])
    iconProp:setSpriteFrame("hallcocosstudio/images/plist/Shop_Img/card_maker.png")
    if itemData["proptype"] == "prop_timinggame_ticket_deposit" 
    or itemData["proptype"] == "prop_timinggame_ticket_rmb"
    or itemData["proptype"] == "prop_timinggame_ticket_rmb_first" then
        iconProp:setSpriteFrame("hallcocosstudio/images/plist/Shop_Img/timinggame_ticket.png")
        local lotteryBg = itemNode:getChildByName("lotteryBg")
        local labelLottery = lotteryBg:getChildByName("lottery")

        --预留接口
        lotteryBg:setVisible(false)
        labelLottery:setVisible(false)
        if TimingGameModel:getConfig() then
            if #itemData.description > 0 then
                lotteryBg:setVisible(true)
                labelLottery:setVisible(true)
                labelLottery:setString(itemData.description)
            end
        end
    end

    if itemData["proptype"] == "prop_cardrecorder_bout"
    or itemData["proptype"] == "prop_timinggame_ticket_deposit" then
        local labelPrice = itemNode:getChildByName("text_price_silver")
        local imgPrice = itemNode:getChildByName("price_silver_img")
        labelPrice:setMoney(itemData["price"])
        labelPrice:setVisible(true)
        imgPrice:setVisible(true)

    else
        local labelPrice = itemNode:getChildByName("text_price")
        labelPrice:setMoney(itemData["price"].."元")
        labelPrice:setVisible(true)
    end

    if itemData["proptype"] == "prop_cardrecorder_bout" 
    or itemData["proptype"] == "prop_timinggame_ticket_deposit"
    or itemData["proptype"] == "prop_timinggame_ticket_rmb"
    or itemData["proptype"] == "prop_timinggame_ticket_rmb_first" then
        iconPropType:setVisible(false)
    else
        iconPropType:setVisible(true)
        local shopImgFilePrefix = "hallcocosstudio/images/plist/Shop_Img/"
        local propImgNames = {
            [1] = "1day.png", [7] = "7day.png", [30] = "30day.png"
        }
        iconPropType:loadTexture(shopImgFilePrefix..propImgNames[itemData["productnum"]], ccui.TextureResType.plistType)
    end

    iconFlag:setVisible(false)        
    local shopImgFilePrefix = "hallcocosstudio/images/plist/Shop_Img/"
    local flagImgNames = {[1] = "shop_conner_hot.png", [2] = "shop_conner_weigh.png", [3] = "shop_conner_onlyone.png"}
    if flagImgNames[itemData["labeltype"]] then
        iconFlag:setVisible(true)
        iconFlag:loadTexture(shopImgFilePrefix..flagImgNames[itemData["labeltype"]], ccui.TextureResType.plistType)
    else
        iconFlag:setVisible(false)
    end
end
function ShopView:refreshExpressionItem(shopItem)
    print("ShopView:refreshPropItem")
    if shopItem == nil then
        print("shopItem is nil")
        return
    end
    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local iconProp = itemNode:getChildByName("Sprite_ItemIcon")
    local discount_bg = itemNode:getChildByName("discount_bg")
    local lotteryBg = itemNode:getChildByName("lotteryBg")
    local labelLottery = lotteryBg:getChildByName("lottery")

    iconProp:setVisible(true)
    if itemData["proptype"] == "LightingX" or itemData["proptype"] == "Lighting100" then
        discount_bg:setVisible(true)
        discount_bg:getChildByName("discount_9_img"):setVisible(true)
        
        self._discountNode = discount_bg

        local time = 0.3
        local scaleto1 = cc.ScaleTo:create(time, 0.9, 0.9)
        local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
        local scaleto3 = cc.ScaleTo:create(time, 1, 1)
        local actMoveBy1 = cc.MoveBy:create(time, cc.p(0, 10))
        local actMoveBy2 = cc.MoveBy:create(time, cc.p(0, -10))
        local delayAction     = cc.DelayTime:create(3)

        --local callFuncAction1 = cc.CallFunc:create(function() print("1111111111111111111111111111111") end)
        
            --序列
        local sequenceAction  = cc.Sequence:create(scaleto1, scaleto2, scaleto1, scaleto2, scaleto3, actMoveBy1,actMoveBy2, actMoveBy1,actMoveBy2, delayAction)
            --重复
        local repeatForever = cc.RepeatForever:create(sequenceAction)
        if not tolua.isnull(self._discountNode) then
            self._discountNode:runAction(repeatForever)
        end
    else
        discount_bg:setVisible(false)
    end

    local labelPrice = itemNode:getChildByName("text_price_silver")
    local imgPrice = itemNode:getChildByName("price_silver_img")
    labelPrice:setMoney(itemData["price"])
    labelPrice:setVisible(true)
    imgPrice:setVisible(true)

    iconProp:setSpriteFrame("hallcocosstudio/images/plist/Shop_Img/".. itemData["proptype"] .. ".png")
    labelName:setString(itemData["title"])

    --预留接口
    lotteryBg:setVisible(false)
    labelLottery:setVisible(false)
    local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
    if ExchangeLotteryModel:GetActivityOpen() then
        if #itemData.description > 0 then
            lotteryBg:setVisible(true)
            labelLottery:setVisible(true)
            labelLottery:setString(itemData.description)
        end
    end
end

function ShopView:refreshTongbaoItem(shopItem)
    print("ShopView:refreshTongbaoItem")
    if shopItem == nil then
        print("shopItem is nil")
        return
    end

    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local labelPrice = itemNode:getChildByName("text_price_tongbao")
    local imgItemIcon = itemNode:getChildByName("Img_ItemIcon")

    imgItemIcon:setVisible(true)
    labelName:setString(itemData["title"])
    labelPrice:setVisible(true)
    labelPrice:setMoney(itemData["price"] .. "元")

    local itemIconFilePrefix = "res/common/common_itemicon/"
    local itemIconNames = {
        [1] = "ItemIcon_Tongbao_1.png",
        [2] = "ItemIcon_Tongbao_2.png",
        [3] = "ItemIcon_Tongbao_3.png",
        [4] = "ItemIcon_Tongbao_4.png",
        [5] = "ItemIcon_Tongbao_5.png",
        [6] = "ItemIcon_Tongbao_6.png",
        [7] = "ItemIcon_Tongbao_7.png",
        [8] = "ItemIcon_Tongbao_8.png",
        [9] = "ItemIcon_Tongbao_9.png"
    }
    imgItemIcon:loadTexture(itemIconFilePrefix .. itemIconNames[itemData["icontype"]])
end

function ShopView:refresgExchangeItem(shopItem)
    print("ShopView:refreshTongbaoItem")
    if shopItem == nil then
        print("shopItem is nil")
        return
    end

    local itemData = shopItem["itemData"]
    local itemNode = shopItem["itemNode"]

    local labelName = itemNode:getChildByName("Text_item_name")
    local labelPrice = itemNode:getChildByName("text_price_tongbao")
    local imgItemIcon = itemNode:getChildByName("Sprite_ItemIcon")

    imgItemIcon:setVisible(true)
    labelName:setString(itemData["title"])
    labelPrice:setVisible(true)
    labelPrice:setMoney(itemData["price"] .. "通宝")

    -- local itemIconFilePrefix = "res/common/common_itemicon/"
    -- local itemIconNames = {
    --     [1] = "ItemIcon_Deposit_2.png",
    --     [2] = "ItemIcon_Deposit_3.png",
    --     [3] = "ItemIcon_Deposit_4.png",
    --     [4] = "ItemIcon_Deposit_5.png",
    --     [5] = "ItemIcon_Deposit_6.png",
    --     [6] = "ItemIcon_Deposit_7.png"
    -- }
    -- imgItemIcon:loadTexture(itemIconFilePrefix .. itemIconNames[itemData["icontype"]])

    local itemIconFilePrefix = "hallcocosstudio/images/plist/CheckIn_IconDeposit/"
    local itemIconNames = {
        [1] = "yz1_bg_pic.png", [2] = "yinzi_6bg.png", [3] = "yz2_bg_pic.png", 
        [4] = "yz3_bg_pic.png", [5] = "yz4_bg_pic.png", [6] = "yz5_bg_pic.png"
    }
    imgItemIcon:setSpriteFrame(itemIconFilePrefix .. itemIconNames[itemData["icontype"]])
end

function ShopView:onExit()
    if not tolua.isnull(self._discountNode) then
        self._discountNode:stopAllActions()
    end
    TimerManager:stopTimer("Timer_ShopView_CreateNextShopItem")
end

return ShopView