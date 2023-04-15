local RechargeFlopCardCtrl = class("RechargeFlopCardCtrl", cc.load("BaseCtrl"))
local RechargeFlopCardView = require("src.app.plugins.RechargeFlopCard.RechargeFlopCardView")
local RechargeFlopCardModel = require("src.app.plugins.RechargeFlopCard.RechargeFlopCardModel"):getInstance()
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

function RechargeFlopCardCtrl:onCreate(...)
    self:setViewIndexer(RechargeFlopCardView:createViewIndexer(self))

    if not self:_checkViewNode() then
        return
    end

    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_STATUS_UPDATE, handler(self, self.updateUI))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_RSP_FLOP, handler(self, self.showFLopAni))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_RSP_OPEN_BOX, handler(self, self.updateUI))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_RSP_PAY_OK, handler(self, self.updateUI))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_RSP_TAKE_SILVER, handler(self, self.playTakeSilverAni))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_CTRL_RSP_TAKE_SILVER, handler(self, self.updateUI))

    local viewNode = self:getViewNode()
    self:bindUserEventHandler(viewNode, {
        'closeBtn',
        'btnNormalBox',
        'btnBigBox',
        'btnSuperBox',
        'btnOneKey',
        'btnRecharge',
        'btnTakeSilver'
    })

    self:bindOtherEventHandler()

    RechargeFlopCardModel:reqStatus(1)
end

function RechargeFlopCardCtrl:bindOtherEventHandler()
    local viewNode = self:getViewNode()
    if not viewNode then return end
    local btnList = {"panelCard1","panelCard2","panelCard3","panelCard4","panelCard5"}
    for i,v in ipairs(btnList) do
        if viewNode[v] then
            viewNode[v]:setTouchEnabled(true)
            viewNode[v]:addClickEventListener(function ()
                print("click RechargeFlopCardCtrl btn ",i)
                local status = RechargeFlopCardModel:getCardStatusByIndex(i)
                if status == RechargeFlopCardModel.Def.CAN_NOT_UNLOCK then
                    if self:isInClickGap() then return end
                    self:rechargeFunc()
                elseif status == RechargeFlopCardModel.Def.CAN_UNLOCK then
                    if self:isInFlopGap() then return end
                    RechargeFlopCardModel:reqFlop(i)
                elseif status >= RechargeFlopCardModel.Def.CARD_10 then
                    
                end
            end)
        end
    end
end

function RechargeFlopCardCtrl:onEnter()
    self:updateUI()
end

function RechargeFlopCardCtrl:closeBtnClicked()
    self:onKeyBack()
end

function RechargeFlopCardCtrl:onExit()
    if self.aniTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.aniTimer)
        self.aniTimer = nil
    end
    RechargeFlopCardCtrl.super.onExit(self)
end

function RechargeFlopCardCtrl:onKeyBack()
    if self.aniTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.aniTimer)
        self.aniTimer = nil
    end
    RechargeFlopCardCtrl.super.onKeyBack(self)
end

function RechargeFlopCardCtrl:_checkViewNode()
    local viewNode = self:getViewNode()
    if not viewNode then
        return false
    end
    if viewNode.getRealNode and tolua.isnull(viewNode:getRealNode()) then
        return false
    end
    return true
end

function RechargeFlopCardCtrl:updateUI()
    if not self:_checkViewNode() then
        return
    end
    if not RechargeFlopCardModel:isOpen() then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "获取数据中，请稍后再试!", removeTime = 3}})
        self:onKeyBack()
        return
    end
    local status = RechargeFlopCardModel:getStatus()
    local viewNode = self:getViewNode()

    self:updateCurReward(viewNode, status)
    self:updateCurRecharge(viewNode, status)
    self:updateBoxReward(viewNode, status)
    self:updateTypeRule(viewNode, status)
    self:updateValueRule(viewNode, status)
    self:updateMainView(viewNode, status)
    self:updateSingleRechargeBtn(viewNode)
    self:updateOtherTip(viewNode, status)
end

--当前奖励
function RechargeFlopCardCtrl:updateCurReward(viewNode, status)
    if not viewNode or not status then return end
    local baseSilver = RechargeFlopCardModel:getBaseSilver()
    if viewNode.txtBaseSilver then
        viewNode.txtBaseSilver:setString(baseSilver)
    end

    local typeMul, valueMul, finalMul = RechargeFlopCardModel:getCurMultiply()
    if viewNode.txtTypeMultiply then
        local str = "一"
        if typeMul > 0 then
            str = string.format("%d", typeMul)
        end
        viewNode.txtTypeMultiply:setString(str)
    end

    if viewNode.txtValueMultiply then
        local str = "一"
        if valueMul > 0 then
            str = string.format("%d", valueMul)
        end
        viewNode.txtValueMultiply:setString(str)
    end

    if viewNode.txtFinalMultiply then
        local str = "一"
        if finalMul > 0 then
            str = string.format("x%d", finalMul)
        end
        viewNode.txtFinalMultiply:setString(str)
    end
    
    local curRewardSilver = RechargeFlopCardModel:getCurRewardSilver()
    if viewNode.txtTotalSilver then
        local str = "一"
        if curRewardSilver > 0 then
            str = string.format("%d", curRewardSilver)
        end
        viewNode.txtTotalSilver:setString(str)
    end
end

--当前充值
function RechargeFlopCardCtrl:updateCurRecharge(viewNode, status)
    if not viewNode or not status then return end
    local curRecharge = RechargeFlopCardModel:getCurRecharge()
    if viewNode.txtTotalRecharge then
        viewNode.txtTotalRecharge:setString(curRecharge.."元")
    end

    local collectedRewardSilver = RechargeFlopCardModel:getCollectedRewardSilver()                              -- 已领取银两数量
    local toBeCollectedRewardSilver = RechargeFlopCardModel:getCurRewardSilver() - collectedRewardSilver        -- 待领取银两数量   

    if viewNode.txtCollectedBoxReward then
        local str = ""
        if collectedRewardSilver >= 0 then
            str = string.format("%d", collectedRewardSilver)
        end
        viewNode.txtCollectedBoxReward:setString(str)
    end

    if viewNode.txtToBeCollectedBoxReward then
        local str = "0"
        if toBeCollectedRewardSilver > 0 then
            str = string.format("%d", toBeCollectedRewardSilver)
            if viewNode.btnTakeSilver then
                viewNode.btnTakeSilver:setEnabled(true)
                viewNode.btnTakeSilver:setColor(cc.c3b(255,255,255))
             end
        else
            if viewNode.btnTakeSilver then 
                viewNode.btnTakeSilver:setEnabled(false) 
                viewNode.btnTakeSilver:setColor(cc.c3b(191,191,191))
            end
        end
        viewNode.txtToBeCollectedBoxReward:setString(str)
    end
end

--宝箱奖励
function RechargeFlopCardCtrl:updateBoxReward(viewNode, status)
    if not viewNode or not status then return end

    -- 根据档位配置设置普通宝箱显隐
    if viewNode.btnNormalBox then
        if status.box_status[1] ~= -1 then
            viewNode.btnNormalBox:setVisible(true)
            local txt = viewNode.btnNormalBox:getChildByName("Text_Desc")
            if txt then
                txt:setString(string.format("需翻开2张牌"))
            end
            viewNode.btnNormalBox:setScale9Enabled(false)
            local nodeAni = viewNode.btnNormalBox:getChildByName("Ani_NormalBox")
            if nodeAni then
                nodeAni:stopAllActions()
                nodeAni:setVisible(false)
            end
            local imgOpened = viewNode.btnNormalBox:getChildByName("Img_Opened")
            if imgOpened then
                imgOpened:setVisible(false)
            end
            local boxStatus = RechargeFlopCardModel:getBoxStatusByIndex(1)

            if boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
                viewNode.btnNormalBox:loadTextureNormal("hallcocosstudio/images/plist/RechargeFlopCard/img_box0.png",ccui.TextureResType.plistType)
                viewNode.btnNormalBox:loadTexturePressed("hallcocosstudio/images/plist/RechargeFlopCard/img_box0.png",ccui.TextureResType.plistType)
            elseif boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
                local aniPath = "res/hallcocosstudio/activitycenter/Ani_NormalBox.csb"
                local ani = cc.CSLoader:createTimeline(aniPath)
                if nodeAni and ani then
                    nodeAni:setVisible(true)
                    ani:setTimeSpeed(0.6)
                    nodeAni:runAction(ani)
                    ani:play("animation0", true)
                end
            elseif boxStatus == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
                viewNode.btnNormalBox:loadTextureNormal("Game/png/transparency.png",ccui.TextureResType.localType)
                viewNode.btnNormalBox:loadTexturePressed("Game/png/transparency.png",ccui.TextureResType.localType)
                if imgOpened then
                    imgOpened:setVisible(true)
                end    
            end
        else
            viewNode.btnNormalBox:setVisible(false)
        end
    end

    if viewNode.btnBigBox then
        local txt = viewNode.btnBigBox:getChildByName("Text_Desc")
        if txt then
            txt:setString(string.format("需翻开3张牌"))
        end
        viewNode.btnBigBox:setScale9Enabled(false)
        local nodeAni = viewNode.btnBigBox:getChildByName("Ani_BigBox")
        if nodeAni then
            nodeAni:stopAllActions()
            nodeAni:setVisible(false)
        end
        local imgOpened = viewNode.btnBigBox:getChildByName("Img_Opened")
        if imgOpened then
            imgOpened:setVisible(false)
        end
        local boxStatus = RechargeFlopCardModel:getBoxStatusByIndex(2)
        if boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
            viewNode.btnBigBox:loadTextureNormal("hallcocosstudio/images/plist/RechargeFlopCard/img_box1.png",ccui.TextureResType.plistType)
            viewNode.btnBigBox:loadTexturePressed("hallcocosstudio/images/plist/RechargeFlopCard/img_box1.png",ccui.TextureResType.plistType)
        elseif boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
            local aniPath = "res/hallcocosstudio/activitycenter/Ani_BigBox.csb"
            local ani = cc.CSLoader:createTimeline(aniPath)
            if nodeAni and ani then
                nodeAni:setVisible(true)
                ani:setTimeSpeed(0.6)
                nodeAni:runAction(ani)
                ani:play("animation0", true)
            end
        elseif boxStatus == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
            viewNode.btnBigBox:loadTextureNormal("Game/png/transparency.png",ccui.TextureResType.localType)
            viewNode.btnBigBox:loadTexturePressed("Game/png/transparency.png",ccui.TextureResType.localType)
            if imgOpened then
                imgOpened:setVisible(true)
            end    
        end

        -- 根据档位配置设置大宝箱位置
        if status.box_status[1] ~= -1 then
            viewNode.btnBigBox:setPosition(cc.p(680, 120))
        else
            viewNode.btnBigBox:setPosition(cc.p(560, 120))
        end
    end
    if viewNode.btnSuperBox then
        local txt = viewNode.btnSuperBox:getChildByName("Text_Desc")
        if txt then
            txt:setString(string.format("需翻开5张牌"))
        end
        viewNode.btnSuperBox:setScale9Enabled(false)
        local nodeAni = viewNode.btnSuperBox:getChildByName("Ani_SuperBox")
        if nodeAni then
            nodeAni:stopAllActions()
            nodeAni:setVisible(false)
        end
        local imgOpened = viewNode.btnSuperBox:getChildByName("Img_Opened")
        if imgOpened then
            imgOpened:setVisible(false)
        end
        local boxStatus = RechargeFlopCardModel:getBoxStatusByIndex(3)
        if boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
            viewNode.btnSuperBox:loadTextureNormal("hallcocosstudio/images/plist/RechargeFlopCard/img_box2.png",ccui.TextureResType.plistType)
            viewNode.btnSuperBox:loadTexturePressed("hallcocosstudio/images/plist/RechargeFlopCard/img_box2.png",ccui.TextureResType.plistType)
        elseif boxStatus == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
            local aniPath = "res/hallcocosstudio/activitycenter/Ani_SuperBox.csb"
            local ani = cc.CSLoader:createTimeline(aniPath)
            if nodeAni and ani then
                nodeAni:setVisible(true)
                ani:setTimeSpeed(0.6)
                nodeAni:runAction(ani)
                ani:play("animation0", true)
            end
        elseif boxStatus == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
            viewNode.btnSuperBox:loadTextureNormal("Game/png/transparency.png",ccui.TextureResType.localType)
            viewNode.btnSuperBox:loadTexturePressed("Game/png/transparency.png",ccui.TextureResType.localType)
            if imgOpened then
                imgOpened:setVisible(true)
            end
        end
        -- 根据档位配置设置超级宝箱位置
        if status.box_status[1] ~= -1 then
            viewNode.btnSuperBox:setPosition(cc.p(820, 120))
        else
            viewNode.btnSuperBox:setPosition(cc.p(740, 120))
        end
    end
end

--牌型规则
function RechargeFlopCardCtrl:updateTypeRule(viewNode, status)
    if not viewNode or not status then return end
    local typeMulRule = RechargeFlopCardModel:getTypeMultiplyRule()
    if not typeMulRule then
        return 
    end
    if viewNode.txtThree then
        viewNode.txtThree:setString(string.format("x%d倍", typeMulRule[2]))
    end
    if viewNode.txtThreeTwo then
        viewNode.txtThreeTwo:setString(string.format("x%d倍", typeMulRule[3]))
    end
    if viewNode.txtFour then
        viewNode.txtFour:setString(string.format("x%d倍", typeMulRule[4]))
    end
    if viewNode.txtFive then
        viewNode.txtFive:setString(string.format("x%d倍", typeMulRule[5]))
    end
    if viewNode.txtTongHua then
        viewNode.txtTongHua:setString(string.format("x%d倍", typeMulRule[6]))
    end

    local finalMulMin, finalMulMax = RechargeFlopCardModel:getFinalMultiplyRange()
    if viewNode.txtFinal then
        viewNode.txtFinal:setString(string.format("随机再翻%d-%d倍奖励", finalMulMin, finalMulMax))
    end
end

--牌值规则
function RechargeFlopCardCtrl:updateValueRule(viewNode, status)
    if not viewNode or not status then return end

    local typeMulRule = RechargeFlopCardModel:getValueMultiplyRule()
    if not typeMulRule then
        return 
    end
    if viewNode.txt10 then
        viewNode.txt10:setString(string.format("x%d倍", typeMulRule[1]))
    end
    if viewNode.txtJ then
        viewNode.txtJ:setString(string.format("x%d倍", typeMulRule[2]))
    end
    if viewNode.txtQ then
        viewNode.txtQ:setString(string.format("x%d倍", typeMulRule[3]))
    end
    if viewNode.txtK then
        viewNode.txtK:setString(string.format("x%d倍", typeMulRule[4]))
    end
    if viewNode.txtA then
        viewNode.txtA:setString(string.format("x%d倍", typeMulRule[5]))
    end
end

--牌型显示界面
function RechargeFlopCardCtrl:updateMainView(viewNode, status)
    if not viewNode or not status then return end
    local btnList = {"panelCard1","panelCard2","panelCard3","panelCard4","panelCard5"}

    local curCardIndex = RechargeFlopCardModel:getCurCardIndex()
    for i,v in ipairs(btnList) do
        if viewNode[v] then
            --先隐藏下动画节点            
            local aniFlop = viewNode[v]:getChildByName("Node_AniFlop")
            if aniFlop then aniFlop:setVisible(false) end

            local panelCanNot = viewNode[v]:getChildByName("Panel_CanNot")
            --[[
            -- 显示选中特效
            if panelCanNot then
                local nodeAni = panelCanNot:getChildByName("Node_SelectAni")
                if curCardIndex == i then
                    -- 充值按钮流光特效
                    local aniLiuGuangFile = "res/hallcocosstudio/RechargeFlopCard/guang2.csb"
                
                    if nodeAni then
                        nodeAni:stopAllActions()
                        nodeAni:setVisible(true)
                        local liuguangAni = cc.CSLoader:createTimeline(aniLiuGuangFile)
                        nodeAni:runAction(liuguangAni)
                        liuguangAni:play("animation0", true)
                    end
                else
                    if nodeAni then
                        nodeAni:setVisible(false)
                    end
                end
            end
            --]]

            -- 显示选中特效
            if panelCanNot then
                local imgGuang = panelCanNot:getChildByName("Img_Guang")
                if curCardIndex == i then
                    -- 充值按钮流光特效
                    if imgGuang then
                        imgGuang:setVisible(true)
                    end
                else
                    if imgGuang then
                        imgGuang:setVisible(false)
                    end
                end
            end

            -- 当档位置最低档时第二张牌多一个宝箱
            if i == 2 then

                if panelCanNot then
                    if status.box_status[1] ~= -1 then
                        panelCanNot:getChildByName("Img_Tip"):setVisible(true)
                    else
                        panelCanNot:getChildByName("Img_Tip"):setVisible(false)
                    end
                end
            end
            local cardStatus = RechargeFlopCardModel:getCardStatusByIndex(i)
            if cardStatus == RechargeFlopCardModel.Def.CAN_NOT_UNLOCK then
                local panelCanUnlock = viewNode[v]:getChildByName("Panel_CanUnlock")
                if panelCanUnlock then
                    panelCanUnlock:setVisible(true)
                    local imgGuang = panelCanUnlock:getChildByName("Img_Guang")
                    if imgGuang then
                        imgGuang:setVisible(false)
                    end
                    local aniGuang = panelCanUnlock:getChildByName("Node_AniGuang")
                    if aniGuang then
                        aniGuang:setVisible(false)
                    end
                end

                if panelCanNot then
                    panelCanNot:setVisible(true)
                    local txtDesc = panelCanNot:getChildByName("Text_Desc")
                    local rechargeNeed = RechargeFlopCardModel:getRechargeNeed()
                    local curRecharge = RechargeFlopCardModel:getCurRecharge()
                    if txtDesc and rechargeNeed then
                        local config = RechargeFlopCardModel:getSingleItemConfigByIndex(i)
                        txtDesc:setString(string.format("充值%d元解锁", config.exchange_price))
                    end
                    if i == RechargeFlopCardModel.Def.CARD_COUNT then
                        local finalMulMin, finalMulMax = RechargeFlopCardModel:getFinalMultiplyRange()
                        local txtDesc2 = panelCanNot:getChildByName("Text_Desc2")
                        if txtDesc2 then
                            txtDesc2:setString(string.format("额外再翻%d-%d倍", finalMulMin, finalMulMax))
                        end
                    end
                end
            elseif cardStatus == RechargeFlopCardModel.Def.CAN_UNLOCK then
                local panelCanUnlock = viewNode[v]:getChildByName("Panel_CanUnlock")
                if panelCanUnlock then
                    panelCanUnlock:setVisible(true)
                    local aniGuang = panelCanUnlock:getChildByName("Node_AniGuang")
                    local aniGuangPath = "res/hallcocosstudio/RechargeFlopCard/guang.csb"
                    local guangAni = cc.CSLoader:createTimeline(aniGuangPath)
                    if not aniGuang then
                        aniGuang = cc.CSLoader:createNode(aniGuangPath)
                        aniGuang:setName("Node_AniGuang")
                        panelCanUnlock:addChild(aniGuang)
                    else
                        aniGuang:stopAllActions()
                    end
                    if aniGuang and guangAni then
                        aniGuang:setVisible(true)
                        guangAni:setTimeSpeed(0.6)
                        aniGuang:runAction(guangAni)
                        guangAni:play("animation0", true)
                    end
                end

                if panelCanNot then
                    panelCanNot:setVisible(false)
                end
            elseif cardStatus >= RechargeFlopCardModel.Def.CARD_10 and cardStatus <= RechargeFlopCardModel.Def.CARD_A then
                local panelCanUnlock = viewNode[v]:getChildByName("Panel_CanUnlock")
                if panelCanUnlock then
                    panelCanUnlock:setVisible(false)
                end

                if panelCanNot then
                    panelCanNot:setVisible(false)
                end
                local imgCard = viewNode[v]:getChildByName("Img_Card")
                if imgCard then
                    local str = string.format("hallcocosstudio/images/plist/RechargeFlopCard/card_ht_1%d.png", cardStatus)
                    imgCard:loadTexture(str, ccui.TextureResType.plistType)
                    imgCard:setVisible(true)
                end
                --设置倍数
                local fontBeiShu = imgCard:getChildByName("fnt_beishu")
                local path, mul = RechargeFlopCardModel:getValueMulFontPathAndMul(i, cardStatus)
                if fontBeiShu and path and mul then
                    fontBeiShu:setFntFile(path)
                    fontBeiShu:setString(string.format("x%d倍", mul))
                end
            end
            if i == RechargeFlopCardModel.Def.CARD_COUNT then
                local finalMul = status.final_multiply
                local panelClip = viewNode.panelClip
                if not panelClip then break end
                local nodeImg = panelClip:getChildByName("Node_Img")
                if not nodeImg then break end

                local fontPath = "hallcocosstudio/images/font/RechargeFlopCard/fzdahei_1.fnt"
                local minMul, maxMul = RechargeFlopCardModel:getFinalMultiplyRange()

                local round = 1
                local nums = {}
                for i = 1, round do
                    for j = 1, maxMul do
                        table.insert(nums, j)
                    end
                end
                table.insert(nums, 1)
                table.insert(nums, 2)

                local childCount = nodeImg:getChildrenCount()
                if childCount < #nums then  
                    for i = childCount + 1, #nums do
                        local node = ccui.TextBMFont:create()
                        node:setFntFile(fontPath)
                        nodeImg:addChild(node)
                    end
                end
                local dis = 50
                local children = nodeImg:getChildren()
                for i = 1, #nums do
                    local node = children[i]
                    local posX ,posY = 30.60, 18 + dis * (i - 1)
                    node:setString(nums[i])
                    node:setPosition(cc.p(posX, posY))
                end

                if finalMul and finalMul > 0 then
                    local dis = 50
                    local posDiff = (finalMul - 2) * dis
                    if finalMul == 1 then
                        posDiff = (maxMul - 1) * dis
                    end
                    nodeImg:setPosition(cc.p(6.36, 1.04 - posDiff))
                else
                    nodeImg:setPosition(cc.p(6.36, 1.04))
                end
            end
        end
    end
end 

-- 单次充值按钮
function RechargeFlopCardCtrl:updateSingleRechargeBtn(viewNode)
    if viewNode.btnRecharge then
        local curCardIndex = RechargeFlopCardModel:getCurCardIndex()
        local nodeAni = viewNode.btnRecharge:getChildByName("Node_LiuGuang")
        if curCardIndex > RechargeFlopCardModel.Def.CARD_COUNT then                  -- 当全部解锁后按钮置灰
            viewNode.btnRecharge:setEnabled(false)
            viewNode.btnRecharge:setColor(cc.c3b(191,191,191))

            if nodeAni then
                nodeAni:stopAllActions()
                nodeAni:setVisible(false)
            end
        else
            -- 充值按钮流光特效
            local aniLiuGuangFile = "res/hallcocosstudio/RechargeFlopCard/jsfx.csb"
        
            if nodeAni then
                nodeAni:stopAllActions()
                nodeAni:setVisible(true)
                local liuguangAni = cc.CSLoader:createTimeline(aniLiuGuangFile)
                liuguangAni:setTimeSpeed(0.6)
                nodeAni:runAction(liuguangAni)
                liuguangAni:play("animation0", true)
            end
        end
        local config = RechargeFlopCardModel:getSingleItemConfig()
        viewNode.btnRecharge:getChildByName("Money"):setString(config.exchange_price)
    end
end
--主界面提示
function RechargeFlopCardCtrl:updateOtherTip(viewNode, status)
    if not viewNode or not status then return end
    if viewNode.btnOneKey then
        local txtDesc = viewNode.btnOneKey:getChildByName("Text_Desc")
        local shopItem = RechargeFlopCardModel:getShopItemConfig()
        if txtDesc and shopItem then
            txtDesc:setString(string.format("%d", shopItem[1]))
        end

        local bEnable = RechargeFlopCardModel:isOneKeyRechargeEnable()
        viewNode.btnOneKey:setTouchEnabled(bEnable)
        viewNode.btnOneKey:setBright(bEnable)

        local nodeAni = viewNode.btnOneKey:getChildByName("Node_LiuGuang")
        if bEnable and nodeAni then 
            nodeAni:stopAllActions()
            nodeAni:setVisible(true)
            -- 充值按钮流光特效
            local aniLiuGuangFile = "res/hallcocosstudio/RechargeFlopCard/jsfx.csb"

            local liuguangAni = cc.CSLoader:createTimeline(aniLiuGuangFile)
            liuguangAni:setTimeSpeed(0.6)
            nodeAni:runAction(liuguangAni)
            liuguangAni:play("animation0", true)
        elseif nodeAni then 
            nodeAni:stopAllActions()
            nodeAni:setVisible(false)
        end
    end

    local maxRewardNum = RechargeFlopCardModel:getMaxRewardNum()
    local num = math.floor(maxRewardNum / 10000)
    if viewNode.txtTitle and num > 0 then
        viewNode.txtTitle:setString(num)
    end
end

--播放翻牌动画
function RechargeFlopCardCtrl:showFLopAni(data)
    if not data or not data.value or not data.value.index or not data.value.card then return end
    if not self:_checkViewNode() then
        return
    end
    local status = RechargeFlopCardModel:getStatus()
    local viewNode = self:getViewNode()

    local btnList = {"panelCard1","panelCard2","panelCard3","panelCard4","panelCard5"}
    local panelName = btnList[data.value.index]
    if not viewNode[panelName] then return end
    local panel = viewNode[panelName]
    panel:setVisible(true)
    local aniFlop = panel:getChildByName("Node_AniFlop")
    local aniFlopPath = "res/hallcocosstudio/RechargeFlopCard/fanpai.csb"
    local flopAni = cc.CSLoader:createTimeline(aniFlopPath)
    if not aniFlop then
        aniFlop = cc.CSLoader:createNode(aniFlopPath)
        aniFlop:setName("Node_AniFlop")
        aniFlop:setPosition(cc.p(79, 102))
        panel:addChild(aniFlop)
    else
        aniFlop:setVisible(true)
        aniFlop:stopAllActions()
    end
    if aniFlop and flopAni then
        --设置牌张
        local imgCard = aniFlop:getChildByName("zmp_11")
        if imgCard then
            local str = string.format("hallcocosstudio/images/plist/RechargeFlopCard/card_ht_1%d.png", data.value.card)
            imgCard:setSpriteFrame(str)
        end
        --设置倍数
        local fontBeiShu = aniFlop:getChildByName("fnt_beishu")
        local path, mul = RechargeFlopCardModel:getValueMulFontPathAndMul(data.value.index, data.value.card)
        if fontBeiShu and path and mul then
            fontBeiShu:setFntFile(path)
            fontBeiShu:setString(string.format("x%d倍", mul))
        end

        local imgNodeCard = panel:getChildByName("Img_Card")
        if imgNodeCard then
            imgNodeCard:setVisible(false)
        end
        local panelCanUnlock = panel:getChildByName("Panel_CanUnlock")
        if panelCanUnlock then
            panelCanUnlock:setVisible(false)
        end
        local panelCanNot = panel:getChildByName("Panel_CanNot")
        if panelCanNot then
            panelCanNot:setVisible(false)
        end
        
        --播放最终倍数滚动动画
        repeat
            if data.value.index == RechargeFlopCardModel.Def.CARD_COUNT
            and data.value.final > 0 then
                local panelClip = viewNode.panelClip
                if not panelClip then break end
                local nodeImg = panelClip:getChildByName("Node_Img")
                if not nodeImg then break end

                local fontPath = "hallcocosstudio/images/font/RechargeFlopCard/fzdahei_1.fnt"
                local minMul, maxMul = RechargeFlopCardModel:getFinalMultiplyRange()

                math.newrandomseed()
                local round = math.random(2, 4) --转多少圈
                local nums = {}
                for i = 1, round do
                    for j = 1, maxMul do
                        table.insert(nums, j)
                    end
                end
                table.insert(nums, 1)
                table.insert(nums, 2)

                local childCount = nodeImg:getChildrenCount()
                if childCount < #nums then  
                    for i = childCount + 1, #nums do
                        local node = ccui.TextBMFont:create()
                        node:setFntFile(fontPath)
                        nodeImg:addChild(node)
                    end
                end
                local dis = 50
                local children = nodeImg:getChildren()
                for i = 1, #nums do
                    local node = children[i]
                    local posX ,posY = 30.60, 18 + dis * (i - 1)
                    node:setString(nums[i])
                    node:setPosition(cc.p(posX, posY))
                end
                nodeImg:setPosition(cc.p(6.36, 1.04))
                local posDiff = (data.value.final - 2) * dis
                if data.value.final == 1 then
                    posDiff = (maxMul - 1) * dis
                end
                local mov = cc.EaseSineInOut:create(cc.MoveTo:create(1.6, cc.p(6.36, 1.04 - dis * maxMul - posDiff)))
                
                local callback = cc.CallFunc:create(function ()
                    if not panelClip or not panel then return end
                    local aniFinal = panelClip:getChildByName("Node_AniFinal")
                    local aniFinalPath = "res/hallcocosstudio/RechargeFlopCard/final.csb"
                    local finalAni = cc.CSLoader:createTimeline(aniFinalPath)
                    if not aniFinal then
                        aniFinal = cc.CSLoader:createNode(aniFinalPath)
                        aniFinal:setName("Node_AniFinal")
                        aniFinal:setPosition(cc.p(38, 50))
                        panelClip:addChild(aniFinal)
                    else
                        aniFinal:setVisible(true)
                        aniFinal:stopAllActions()
                    end
                    aniFinal:runAction(finalAni)
                    finalAni:play("animation0", false)
                end)
                nodeImg:runAction(cc.Sequence:create({mov, callback}))
            end
        until(true)

        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RechargeFlopCardFlop.mp3'),false)

        aniFlop:runAction(flopAni)
        my.scheduleOnce(function()
            if not self:_checkViewNode() then
                return
            end
            local status = RechargeFlopCardModel:getStatus()
            local viewNode = self:getViewNode()
            self:updateCurReward(viewNode, status)
            self:updateCurRecharge(viewNode, status)
            self:updateBoxReward(viewNode, status)
        end, 2)  
        flopAni:play("kai", false)
    end
    
end

function RechargeFlopCardCtrl:isInFlopGap()
    local GAP_SCHEDULE = 0.5 --间隔时间0.5秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end


function RechargeFlopCardCtrl:isInClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function RechargeFlopCardCtrl:btnNormalBoxClicked()
    local status = RechargeFlopCardModel:getBoxStatusByIndex(1)
    if status == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "翻开2张牌后可领取", removeTime = 3}})
        return true
    elseif status == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
        if self:isInClickGap() then return end
        RechargeFlopCardModel:reqOpenBox(1)
    elseif status == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "奖励已领取，请明天再来", removeTime = 3}})
        return true
    end
end

function RechargeFlopCardCtrl:btnBigBoxClicked()
    local status = RechargeFlopCardModel:getBoxStatusByIndex(2)
    if status == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "翻开3张牌后可领取", removeTime = 3}})
        return true
    elseif status == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
        if self:isInClickGap() then return end
        RechargeFlopCardModel:reqOpenBox(2)
    elseif status == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "奖励已领取，请明天再来", removeTime = 3}})
        return true
    end
end

function RechargeFlopCardCtrl:btnSuperBoxClicked()
    local status = RechargeFlopCardModel:getBoxStatusByIndex(3)
    if status == RechargeFlopCardModel.Def.STATUS_CAN_NOT_TAKE then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "翻开5张牌后可领取", removeTime = 3}})
        return true
    elseif status == RechargeFlopCardModel.Def.STATUS_CAN_TAKE then
        if self:isInClickGap() then return end
        RechargeFlopCardModel:reqOpenBox(3)
    elseif status == RechargeFlopCardModel.Def.STATUS_HAS_TAKEN then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "奖励已领取，请明天再来", removeTime = 3}})
        return true
    end
end

function RechargeFlopCardCtrl:AppType()
    local Def = RechargeFlopCardModel.Def
    local type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_TCY
            else
                type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_TCY
            else
                type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.RECHARGE_FLOP_CARD_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.RECHARGE_FLOP_CARD_APPTYPE_IOS_TCY
        else
            type = Def.RECHARGE_FLOP_CARD_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function RechargeFlopCardCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = RechargeFlopCardModel.Def
 
    local szWifiID,szImeiID,szSystemID=DeviceModel.szWifiID,DeviceModel.szImeiID,DeviceModel.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    local function getPayExtArgs()
        local strPayExtArgs = "{"
        if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
            if (cc.exports.GetShopConfig()['platform_app_client_id'] and cc.exports.GetShopConfig()['platform_app_client_id'] ~= "") then 
                strPayExtArgs = strPayExtArgs..string.format("\"platform_app_client_id\":\"%d\",", 
                    cc.exports.GetShopConfig()['platform_app_client_id'])
            end
            if (cc.exports.GetShopConfig()['platform_cooperate_way_id'] and cc.exports.GetShopConfig()['platform_cooperate_way_id'] ~= "") then 
                strPayExtArgs = strPayExtArgs..string.format("\"platform_cooperate_way_id\":\"%d\",", 
                    cc.exports.GetShopConfig()['platform_cooperate_way_id'])
            end
        else
            print("RechargeFlopCardCtrl single app")
        end

        local userID = plugin.AgentManager:getInstance():getUserPlugin():getUserID()
        local gameID = BusinessUtils:getInstance():getGameID()
        if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
            local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
            if type(promoteCodeCache) == "number" then
                strPayExtArgs = strPayExtArgs..string.format("\"promote_code\":\"%s\",", tostring(promoteCodeCache))
            end
        end
        
        if string.sub(strPayExtArgs, string.len(strPayExtArgs)) == "," then 
            strPayExtArgs = string.sub(strPayExtArgs, 1, string.len(strPayExtArgs) - 1)
        end

        if 1 == string.len(strPayExtArgs) then
            strPayExtArgs = ""
        else
            strPayExtArgs = strPayExtArgs .. "}"
        end

        print("RechargeFlopCardCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "充值翻翻乐"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.RECHARGE_FLOP_CARD_APPTYPE_AN_TCY then
        print("RECHARGE_FLOP_CARD_APPTYPE_AN_TCY")
    elseif apptype == Def.RECHARGE_FLOP_CARD_APPTYPE_AN_SINGLE then
        print("RECHARGE_FLOP_CARD_APPTYPE_AN_SINGLE")
    elseif apptype == Def.RECHARGE_FLOP_CARD_APPTYPE_AN_SET then
        print("RECHARGE_FLOP_CARD_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.RECHARGE_FLOP_CARD_APPTYPE_IOS_TCY then
        print("RECHARGE_FLOP_CARD_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.RECHARGE_FLOP_CARD_APPTYPE_IOS_SINGLE then
        print("RECHARGE_FLOP_CARD_APPTYPE_IOS_SINGLE")
        param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
    end

    --local through_data = string.format("{\"GameCode\":\"%s\",\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}", gamecode, deviceId, 0, exchangeid)
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)     --价格
    param["Exchange_Id"]  = tostring(1)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();
    
    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "RechargeFlopCardCtrl:payForProduct param")
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
        self._waitingPayResult = true
        my.scheduleOnce(function()
            self._waitingPayResult = false
        end,3)
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        local function payCallBack(code, msg)
            my.scheduleOnce(function()
                self._waitingPayResult = false
            end,3)
            if code == PayResultCode.kPaySuccess then
                RechargeFlopCardModel:saveOneKeyCache()
            else
                if string.len(msg) ~= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=2}})
                end
                if( code == PayResultCode.kPayFail )then

                elseif( code == PayResultCode.kPayTimeOut )then

                elseif( code == PayResultCode.kPayProductionInforIncomplete )then

                end
            end
        end
        iapPlugin:setCallback(payCallBack)
        dump(param, "RechargeFlopCardCtrl:payForProduct param")        
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function RechargeFlopCardCtrl:btnOneKeyClicked()
    if self:isInClickGap() then return end

    local shopItemConfig = RechargeFlopCardModel:getShopItemConfig()
    local nExchangeID, nPrice = shopItemConfig[3], shopItemConfig[1]
    if not nExchangeID or not nPrice then
        print("RechargeFlopCardCtrl:btnOneKeyClicked date error")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        return 
    end
    self:payForProduct(nExchangeID, nPrice)
end

function RechargeFlopCardCtrl:rechargeFunc()
    local shopItemConfig = RechargeFlopCardModel:getSingleItemConfig()
    local nExchangeID, nPrice = shopItemConfig.exchange_id, shopItemConfig.exchange_price
    if not nExchangeID or not nPrice then
        print("RechargeFlopCardCtrl:btnSingleRechargeClicked date error")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        return 
    end
    self:payForProduct(nExchangeID, nPrice)
end

function RechargeFlopCardCtrl:btnRechargeClicked()
    if self:isInClickGap() then return end
    
    self:rechargeFunc()
end

function RechargeFlopCardCtrl:btnTakeSilverClicked()
    RechargeFlopCardModel:reqTakeSilver()
end

function RechargeFlopCardCtrl:playTakeSilverAni()
    local viewNode = self:getViewNode()

    -- 领取银两动画
    local aniFile = "res/hallcocosstudio/RechargeFlopCard/takeSilver.csb"
    local ani = cc.CSLoader:createTimeline(aniFile)
    local nodeAni = viewNode.takeSilverAni

    if nodeAni and ani then
        nodeAni:setVisible(true)

        nodeAni:runAction(ani)
        ani:play("animation0", false)

        if self.aniTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.aniTimer)
            self.aniTimer = nil
        end

        self.aniTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            if not tolua.isnull(nodeAni) then
                nodeAni:setVisible(false)
            end
            if self.aniTimer then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.aniTimer)
                self.aniTimer = nil
            end
        end, 1.78, false)
    end
end

return RechargeFlopCardCtrl