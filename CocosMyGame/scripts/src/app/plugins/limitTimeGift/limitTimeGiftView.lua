local LimitTimeGiftView = cc.load('ViewAdapter'):create()

LimitTimeGiftView.EVENT_PAY = "LimitTimeGift button_pay underpress!"
LimitTimeGiftView.itemRecommended = nil
local LimitTimeGiftModel = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance()

LimitTimeGiftView.viewConfig={
	"res/hallcocosstudio/shop/node_limitTimeGift.csb",
	{
        panelShade = "Panel_shade",
        panelMain = "Panel_Main",
        {
            _option = {prefix = "Panel_Main."},
            panelAnimation = "Panel_Animation",
            {
                _option = {prefix = "Panel_Animation."},
		        closeBt = "Btn_Close",
	            rewardBt = "Btn_Purchase"
            }
        }
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Main",
        ["isPlayAni"] = true
    }
}

function LimitTimeGiftView:onCreateView(viewNode)
    self:_initView(viewNode)
    self:_playPopAni(viewNode)
end

function LimitTimeGiftView:_playPopAni(viewNode)
    -- local action = cc.CSLoader:createTimeline("res/hallcocosstudio/shop/node_limitTimeGift.csb")
    -- viewNode:getRealNode():runAction(action)
    -- action:play('open', false)

    -- local funcAfterOpen = cc.CallFunc:create(function() action:play("round", true) end)
    -- viewNode:getRealNode():runAction(cc.Sequence:create(cc.DelayTime:create(0.15), funcAfterOpen))
end

function LimitTimeGiftView:_initView(viewNode)
    --由于根节点是Node（不是Layer或Scene，Node没有宽度和高度，无法传递自动适配位置和大小），需要手动刷新下适配方案
    --会独立弹出的插件窗体，根节点建议使用Layer或Scene
    viewNode:setPosition(display.center)
    viewNode.panelShade:setContentSize(cc.Director:getInstance():getVisibleSize())
    ccui.Helper:doLayout(viewNode.panelMain:getRealNode())

    viewNode.closeBt:addClickEventListener(function()
        my.playClickBtnSound()
        self._ctrl:removeSelfInstance()
    end)
    viewNode.rewardBt:addClickEventListener(function()
        my.playClickBtnSound()
        self._ctrl:buyItem()
    end)
end

function LimitTimeGiftView:refreshView(viewNode, itemData)
    print("LimitTimeGiftView:refreshView")
    if viewNode == nil or itemData == nil then
        print("viewNode or itemData is nil, itemData "..tostring(itemData))
        return
    end

    local panelShade = viewNode.panelShade
    local spritePrice = viewNode.panelAnimation:getChildByName("priceIcon")
    local labelValue = viewNode.panelAnimation:getChildByName("numLab")
    local imgFlagDiscount5 = viewNode.panelAnimation:getChildByName("discount5")
    local imgFlagDiscount8 = viewNode.panelAnimation:getChildByName("discount8")
    local imgFlagSpecial = viewNode.panelAnimation:getChildByName("discountte")
    local imgFlagDiscounts = {
        [5] = imgFlagDiscount5, [8] = imgFlagDiscount8
    }

    labelValue:setString(itemData['productnum'] + itemData['firstpay_rewardnum'])
    if  cc.exports.IsHejiPackage() then
        spritePrice:setSpriteFrame("hallcocosstudio/images/plist/limitTimeGift_Img/title_"..itemData['price'].."yuanHJ.png")
        imgFlagSpecial:setVisible(true)
    else
        spritePrice:setSpriteFrame("hallcocosstudio/images/plist/limitTimeGift_Img/title_"..itemData['price'].."yuan.png")
        imgFlagDiscounts[itemData['icondesplayno']]:setVisible(true)
    end

    UIHelper:setPanelTouch(panelShade, function() self._ctrl:removeSelfInstance() end)

    self:refreshLimitTime(viewNode)
end

function LimitTimeGiftView:refreshLimitTime(viewNode)
    local labelTimeLimit = viewNode.panelAnimation:getChildByName("timeLab")

    if cc.exports.limitTimeGiftInfo.nCountdown and cc.exports.limitTimeGiftInfo.nCountdown > 0 then
        labelTimeLimit:setString(LimitTimeGiftModel:getTime(cc.exports.limitTimeGiftInfo.nCountdown))
    else
        self._ctrl:removeSelfInstance()
    end
end

return LimitTimeGiftView

