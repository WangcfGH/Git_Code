local ShopToolsSelectCtrl=class('ShopToolsSelectCtrl',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.shop.ShopToolSelectView')
local config = cc.exports.GetShopTipsConfig()

local player = mymodel('hallext.PlayerModel'):getInstance()

function ShopToolsSelectCtrl:onCreate(itemInfo)
	self:setViewIndexer(viewCreater:createViewIndexer())
    self:init(itemInfo)

    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onViewClose))
end

function ShopToolsSelectCtrl:init(itemInfo)
    local viewNode = self._viewNode
    local btn = viewNode.closeBt
    self:bindDestroyButton(viewNode.closeBt)

    local TextNum = viewNode.mainPanel:getChildByName("Num_text")
    local BtnSub = viewNode.mainPanel:getChildByName("Button_SUB")
    local BtnAdd5 = viewNode.mainPanel:getChildByName("Button_ADD5")
    local BtnAdd = viewNode.mainPanel:getChildByName("Button_ADD")
    local BtnBuy = viewNode.mainPanel:getChildByName("Button_Buy")
    local TextSliver = BtnBuy:getChildByName("Num_sliver")

    self.ToolsCount = 1
    self.LimitNum = 20
    local sliver = itemInfo["price"]
    TextNum:setString(self.ToolsCount) --个数
    TextSliver:setString(self.ToolsCount *sliver) --银子

    BtnSub:addClickEventListener(function()
        my.playClickBtnSound()
        if self.ToolsCount > 1 then
            self.ToolsCount = self.ToolsCount - 1
            TextNum:setString(self.ToolsCount)
            TextSliver:setString(self.ToolsCount *sliver)
        end
    end)

    BtnAdd5:addClickEventListener(function()
        my.playClickBtnSound()
		if self.ToolsCount == 20 then
			my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_NUM_OUT"],removeTime=1}})
		elseif self.ToolsCount + 5 > 20 then
			local sliverTemp = self.LimitNum*sliver
			local result = self:checkSliver(sliverTemp)
			if result then
				self.ToolsCount = self.LimitNum
				TextNum:setString(self.ToolsCount)
				TextSliver:setString(sliverTemp)
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_NUM_OUT"],removeTime=1}})
			else
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["EXPRESSION_CLICK_TIPS"],removeTime=1}})
			end
		else
			local sliverTemp = (self.ToolsCount + 5)*sliver
			local result = self:checkSliver(sliverTemp)
			if result then
				self.ToolsCount = self.ToolsCount + 5
				TextNum:setString(self.ToolsCount)
				TextSliver:setString(sliverTemp)
			else
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["EXPRESSION_CLICK_TIPS"],removeTime=1}})
			end
		end
    end)

    BtnAdd:addClickEventListener(function()
        my.playClickBtnSound()
		if self.ToolsCount == 20 then
			my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_NUM_OUT"],removeTime=1}})
		else
			local sliverTemp = (self.ToolsCount + 1)*sliver
			local result = self:checkSliver(sliverTemp)
			if result then
				self.ToolsCount = self.ToolsCount + 1
				TextNum:setString(self.ToolsCount)
				TextSliver:setString(sliverTemp)
			else
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["EXPRESSION_CLICK_TIPS"],removeTime=1}})
			end
		end
    end)

    BtnBuy:addClickEventListener(function()
        my.playClickBtnSound()
		if self.ToolsCount > 0 then
			if cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
				local config = cc.exports.GetShopTipsConfig()
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_HAVE_RMB"],removeTime=2}})
			else
				local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
				PropModel:sendBuyUserProp(4, self.ToolsCount)
			end
		end
		
		if(self:informPluginByName(nil,nil))then
			self:removeSelfInstance()
		end
    end)
end

function ShopToolsSelectCtrl:checkSliver(Sliver)
    local user = mymodel('UserModel'):getInstance()
    if user.nDeposit == nil then
        user.nDeposit = 0
    end

    if user.nDeposit >= Sliver then
        return true
    else
        return false
    end
end

function ShopToolsSelectCtrl:onViewClose()
    if(self:informPluginByName(nil,nil))then
        self:removeSelfInstance()
    end
end

return ShopToolsSelectCtrl
