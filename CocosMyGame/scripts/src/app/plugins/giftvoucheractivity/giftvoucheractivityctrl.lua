
local viewCreater=import('src.app.plugins.giftvoucheractivity.giftvoucheractivityview')
local GiftVoucherActivityCtrl=class('DailyActivitysCtrl',cc.load('BaseCtrl'))
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

function GiftVoucherActivityCtrl:onCreate( ActivityCenterCtrl )
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:init(ActivityCenterCtrl)
end

function GiftVoucherActivityCtrl:init(ActivityCenterCtrl)
    local RoomExchangeConfig = cc.exports._gameJsonConfig.ExchangeRoomConfig
    if RoomExchangeConfig then
        local str = ""
        local mainPanel = self._viewNode.Panel_Main
        for key, var in pairs(RoomExchangeConfig) do
            if var and var.ShowOrder and var.ShowOrder > 0 and var.ShowOrder <= 8 then
                if type(var.BoutCount )=="number" and type(var.RewardNum ) =="number" then
                    
                    local string = ""
                    if var.RewardNum <= 0 then
                        string = require("src.app.Game.mMyGame.GamePublicInterface"):getGameString("G_GAME_ROOM_BOUT_NO_EXCHANGE")
                    else
                        string = require("src.app.Game.mMyGame.GamePublicInterface"):getGameString("G_GAME_ROOM_BOUT_EXCHANGE")
                    end
                    local content = string.format(string, var.BoutCount, var.RewardNum)
                    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content)) 
                    mainPanel:getChildByName("Text_" .. var.ShowOrder):setString(utf8Content)
                end
            end
        end
    end

    self._viewNode.Button_go:addClickEventListener(function()
        self:playEffectOnPress()
        if not CenterCtrl:checkNetStatus() then
            return false
        end
        
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:notifyClosePlugin()

        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end)
end

function GiftVoucherActivityCtrl:onKeyBack()
    --
end
return GiftVoucherActivityCtrl
