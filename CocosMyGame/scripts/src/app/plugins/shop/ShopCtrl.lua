local ShopView = import('src.app.plugins.shop.ShopView')
local ShopCtrl = class('ShopCtrl', cc.load('BaseCtrl'))
local ShopModel = mymodel("ShopModel"):getInstance()
local player = mymodel('hallext.PlayerModel'):getInstance()
local UserModel = mymodel('UserModel'):getInstance() 
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local NobilityPrivilegeDef = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')
local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

ShopCtrl.LOGUI = 'Shop'
function ShopCtrl:onCreate(params)
    self._params = params
    local selectTabName = "silver"
    if self._params and self._params.defaultPage then
       selectTabName = self._params.defaultPage
    end

    ShopModel._nobilityUniqueFlag = self._params.uniqueFlag

    self:setView(ShopView)
    ShopView:setCtrl(self)
    self._shopTipsConfig = ShopModel:GetShopTipsConfig()
	self._viewNode = self:setViewIndexer(ShopView:createViewIndexer())

    self:bindProperty(player, 'PlayerData', self, 'PlayerData')
    self:listenTo(ShopModel,ShopModel.EVENT_UPDATE_RICH,handler(self,self.onUpdateRich))    
    self:listenTo(ShopModel, ShopModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onUpdateFirstCharge))
    self:listenTo(ShopModel, ShopModel.EVENT_UPDATE_EXPRESSION_TIPS, handler(self, self.onUpdateExpressionTips))
    self:listenTo(NobilityPrivilegeModel, NobilityPrivilegeDef.NobilityPrivilegeInfoRet, handler(self,self.freshNobilityPrivilege))
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_SHOP_CTRL, handler(self, self.onClose))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_refresh_shop_item"], handler(self, self.onUpdateTimingGameFirstItem))
    
    self._viewNode.btnChargeAgreement:addClickEventListener(function()
        my.informPluginByName({pluginName = 'ChargeAgreement'})
    end)
    
    ShopView:showTab(self._viewNode, selectTabName)
    
    player:update({'WealthInfo'})
end

function ShopCtrl:freshNobilityPrivilege()
    ShopView:refreshCurTab(self._viewNode)
end

function ShopCtrl:setPlayerData(data)
    ShopView:refreshView(self._viewNode)
end

function ShopCtrl:onUpdateRich()
    if not tolua.isnull(self._viewNode) then
        print("ShopCtrl:onUpdateRich view is null")
        return
    end
    ShopView:refreshView(self._viewNode)
    --ShopView:refreshLastBuyItem(ShopModel:GetLastBuyItem())
end

function ShopCtrl:onUpdateFirstCharge()
    if not tolua.isnull(self._viewNode) then
        print("ShopCtrl:onUpdateFirstCharge view is null")
        return
    end

    local curTabName = ShopView._viewData["curTabName"]
    if curTabName == "" or curTabName == "silver" then
        --ShopView:createShopItems(self._viewNode, "silver")
        ShopView:refreshCurTab(self._viewNode)
    end
end

function ShopCtrl:onUpdateTimingGameFirstItem()    
    if not tolua.isnull(self._viewNode) then
        print("ShopCtrl:onUpdateTimingGameFirstItem view is null")
        return
    end

    local curTabName = ShopView._viewData["curTabName"]
    if curTabName == "" or curTabName == "prop" then
        ShopView:refreshCurTab(self._viewNode)
    end
end

function ShopCtrl:onExit()
    my.dataLink(cc.exports.DataLinkCodeDef.HALL_SHOP_CLOSE)

    ShopView:onExit()
    ShopCtrl.super.onExit(self)

    local HallContext = require("src.app.plugins.mainpanel.HallContext"):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_backToMainSceneFromNonSceneFullScreenCtrl"]})
end

--[[function ShopCtrl:DealPayResult(payResult)
    local user=mymodel('UserModel'):getInstance()
    if( (payResult['nPayTo']==0)and (payResult['nPayFor']==0) )then--box
        user.nSafeboxDeposit=payResult['nOperateAmount']
    elseif( (payResult['nPayTo']==2)and (payResult['nPayFor']==0) )then--yingzi
        user.nDeposit=payResult['nOperateAmount']
    elseif( (payResult['nPayTo']==2)and (payResult['nPayFor']==1) )then--score
        user.nScore=payResult['nOperateAmount']
    end

    ShopModel:DealPayResult(payResult)
end]]--

function ShopCtrl:onClickShopItem(shopItem)
    print("ShopCtrl:onClickShopItem")

    if not CenterCtrl:checkNetStatus() then
        print("checkNetStatus fail!!!")
        return
    end

    if ShopModel._nobilityUniqueFlag then
        local shopLogSdkInfo = {
            ["productID"]       = shopItem["itemData"].exchangeid,
            ["behaviorUnique"]  = ShopModel._nobilityUniqueFlag
        }
        my.dataLink(cc.exports.DataLinkCodeDef.NOBILITY_SHOP_ITEM_BTN_CLICK, shopLogSdkInfo)
    end

    ShopModel:tryBuyShopItem(shopItem["itemData"])
end

function ShopCtrl:onUpdateExpressionTips()
    if not tolua.isnull(self._viewNode) then
        print("ShopCtrl:onUpdateExpressionTips view is null")
        return
    end
    ShopView:refreshExpressionTips(self._viewNode)
end

function ShopCtrl:onClose( )
    self:removeSelfInstance()
end
return ShopCtrl