local LimitTimeGiftCtrl = class("LimitTimeGiftCtrl", cc.load('BaseCtrl'))

local LimitTimeGiftView = require("src.app.plugins.limitTimeGift.limitTimeGiftView")
local LimitTimeGiftModel = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

LimitTimeGiftCtrl.EVENT_PAY_OK = "LimitTimeGift pay ok!"

function LimitTimeGiftCtrl:onCreate()
    self:setView(LimitTimeGiftView)
    LimitTimeGiftView:setCtrl(self)
	local viewNode = self:setViewIndexer(LimitTimeGiftView:createViewIndexer())
    self._viewNode = viewNode

    self:_addListeners()

    LimitTimeGiftModel:calcLimitTimeGiftItem()
    LimitTimeGiftView:refreshView(self._viewNode, LimitTimeGiftModel._giftItemData)
end

function LimitTimeGiftCtrl:_addListeners()
    self:listenTo(LimitTimeGiftModel, LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"], handler(self, self.onLimitTimeUpdated))
    self:listenTo(LimitTimeGiftModel, LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_purchaseSucceeded"], handler(self, self.onPurchaseSucceeded))
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE,handler(self,self.onClose))
end

function LimitTimeGiftCtrl:onLimitTimeUpdated()
    LimitTimeGiftView:refreshLimitTime(self._viewNode)
end

function LimitTimeGiftCtrl:buyItem()
    local itemData = LimitTimeGiftModel._giftItemData
    print("LimitTimeGiftCtrl:buyItem, price "..tostring(itemData and itemData["Product_Price"] or "nil"))
    if itemData == nil then
        print("itemData is nil")
        return
    end

    LimitTimeGiftModel:payCurrentGiftItem(false)
end

function LimitTimeGiftCtrl:onPurchaseSucceeded()
    --[[
    local config = cc.exports.GetShopConfig()
    local showText = ""
    local transType = 2 --当前所有的充值项目都是充值到游戏
    if transType == 0 then
        showText = config["BuyDepositInboxOK"]
    elseif transType == 2 then
        showText = config["BuyDepositOK"]
    else
        showText = config["BuyScoreOK"]
    end
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if userPlugin:getUsingSDKName() == "uconline" then
        showText = config["UConlineAccountOK"]
    end
    my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = showText, removeTime = 3}})
    --]]
    self:removeSelfInstance()
end

function LimitTimeGiftCtrl:onClose()
    self:removeSelfInstance()
end
return LimitTimeGiftCtrl