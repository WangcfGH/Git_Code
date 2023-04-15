local RankRewardCtrl    = class("RankRewardCtrl", cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RankReward.RankRewardView")
local tipString         = import("src.app.plugins.RankReward.RankRewardConfig").tipstring

function RankRewardCtrl:onCreate(params, ...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if params and params.callback then self._callBack = params.callback end
    if params and params.data then self._rankData = params.data end
    self._viewNode.btnOk:addClickEventListener(function()
        if self._rankData and self._rankData.rank and tonumber(self._rankData.rank)<=100 then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString.tip4,removeTime=1}})
        end
        if self._callBack then
            self._callBack()
        end
        self:removeSelfInstance()
    end)
    self:init()
end

--初始化发奖界面
function RankRewardCtrl:init()
    if not self._rankData then return end
    if not self._rankData.rankType or not self._rankData.rank then return end
    
    if self._rankData.rankType then 
        if self._rankData.rankType == 3 then
            self._viewNode.fntTip:setString(string.format(tipString.tip2,self._rankData.rank))
        elseif self._rankData.rankType == 1 then
            self._viewNode.fntTip:setString(string.format(tipString.tip3,self._rankData.rank))
        else
            self._viewNode.fntTip:setString(string.format(tipString.tip1,self._rankData.rank))
        end
    end

    local path = "res/hallcocosstudio/RankReward/node_reward.csb"
    local itemCount = 0
    local perWidth = 138
    local gap = 20
    if self._rankData.reward then 
        if self._rankData.reward.silver and self._rankData.reward.silver >0 then
            itemCount = itemCount + 1
        end
        if self._rankData.reward.vochers and self._rankData.reward.vochers >0 then
            itemCount = itemCount + 1
        end
        if self._rankData.reward.gift then
            itemCount = itemCount + 1
        end
    end

    
    local startX =(self._viewNode.listReward:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
    if self._rankData.reward then
        local index = 1
        if self._rankData.reward.silver and self._rankData.reward.silver > 0 then
            local item = cc.CSLoader:createNode(path)
            local panel = item:getChildByName("Panel_Main")
            panel:getChildByName("Img_Silver"):setVisible(true)
            panel:getChildByName("Img_Vocher"):setVisible(false)
            panel:getChildByName("Img_Gift"):setVisible(false)
            panel:getChildByName("Fnt_Num"):setString(tostring(self._rankData.reward.silver))
            self._viewNode.listReward:addChild(item)
            item:setPosition(cc.p(startX + index *(perWidth + gap) - perWidth / 2 - gap, 90))
            index = index + 1
        end
        if self._rankData.reward.vochers and self._rankData.reward.vochers > 0 then
            local item = cc.CSLoader:createNode(path)
            local panel = item:getChildByName("Panel_Main")
            panel:getChildByName("Img_Silver"):setVisible(false)
            panel:getChildByName("Img_Vocher"):setVisible(true)
            panel:getChildByName("Img_Gift"):setVisible(false)
            panel:getChildByName("Fnt_Num"):setString(tostring(self._rankData.reward.vochers))
            self._viewNode.listReward:addChild(item)
            item:setPosition(cc.p(startX + index *(perWidth + gap) - perWidth / 2 - gap, 90))
            index = index + 1
        end
        if self._rankData.reward.gift then
            local item = cc.CSLoader:createNode(path)
            local panel = item:getChildByName("Panel_Main")
            panel:getChildByName("Img_Silver"):setVisible(false)
            panel:getChildByName("Img_Vocher"):setVisible(false)
            panel:getChildByName("Img_Gift"):setVisible(true)
            panel:getChildByName("Fnt_Num"):setString("1")
            self._viewNode.listReward:addChild(item)
            item:setPosition(cc.p(startX + index *(perWidth + gap) - perWidth / 2 - gap, 90))
            index = index + 1
        end
    end

    if self._rankData.rank then 
        self._viewNode.fntRank:setString(string.format(tipString.tip5,self._rankData.rank))
    end

end

return RankRewardCtrl