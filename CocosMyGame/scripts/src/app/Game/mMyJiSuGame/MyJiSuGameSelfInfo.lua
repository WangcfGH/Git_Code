
local MyJiSuGameSelfInfo = class("MyJiSuGameSelfInfo", import("src.app.Game.mMyGame.MyGameSelfInfo"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")

function MyJiSuGameSelfInfo:init()
    if not self._selfInfoPanel then return end

    self._selfInfoWaittingShow  = self._selfInfoPanel:getChildByName("Node_waitingshown") --MY层

    self._selfInfoPanel:setLocalZOrder(MyJiSuGameDef.SK_ZORDER_SELFINFO)

    --self._selfInfoCancelAuto    = self._selfInfoPanel:getChildByName("Node_gamehosting")
    --self._selfInfoNoBigger      = self._selfInfoPanel:getChildByName("Node_nocardskip")

    self._selfInfoTribute = self._selfInfoPanel:getChildByName("Img_AttentionTribute")
    self._selfInfoTribute:setVisible(false)
    self._selfInfoReturn = self._selfInfoPanel:getChildByName("Img_AttentionPayBack")
    self._selfInfoReturn:setVisible(false)
    self._selfInfoPanel:setVisible(true)

    self._selfInfoCancelAuto:setVisible(false)
   
    --BASE层 start
    self._selfInfoName          = self._selfInfoPanel:getChildByName("SelfInfo_text_name")
    self._selfInfoMoneyIcon     = self._selfInfoPanel:getChildByName("SelfInfo_sp_money")
    self._selfInfoMoney         = self._selfInfoPanel:getChildByName("SelfInfo_text_money")
    self._selfInfoBanker        = self._selfInfoPanel:getChildByName("SelfInfo_sp_banker")
    self._selfInfoReady         = self._selfInfoPanel:getChildByName("SelfInfo_sp_ready")

    self:hideAllChildren()
    --BASE层 end

    self._selfInfoPanel:getChildByName("Img_Dot"):setVisible(true)
    self._selfInfoPanel:getChildByName("Img_Dot_0"):setVisible(true)
    self._selfInfoPanel:getChildByName("Img_Dot_1"):setVisible(true)
    
    local matchingTimeText = self._selfInfoMatching:getChildByName("Panel_animation_matching"):getChildByName("Text_Time")
    if matchingTimeText then
        matchingTimeText:setVisible(false)
    end
end

return MyJiSuGameSelfInfo