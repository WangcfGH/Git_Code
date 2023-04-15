--界面工具类，提取和复用一些通用界面操作函数
local SubViewHelper = class("SubViewHelper", import("src.app.common.global.UniqueObject"))

SubViewHelper.skAniInfo_QuickStart = {
    ["jsonPath"] = "res/hallcocosstudio/images/skeleton/Ani_QuickStart/kaishi.json",
    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/Ani_QuickStart/kaishi.atlas",
	["aniNames"] = {"kaishi"},
    ["offsetX"] = 0,
    ["offsetY"] = 1
}

SubViewHelper.btnSpineAni = {
    ["gameCity"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/Ani_SmallGame/dwc_rukou.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/Ani_SmallGame/dwc_rukou.atlas",
	    ["aniNames"] = {"dwc_rukou_zhuan"}
    },
    ["packSet"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/btn_packset/libaoheji.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/btn_packset/libaoheji.atlas",
	    ["aniNames"] = {"libaoheji"},
        ["offsetY"] = -30
    },
    ["luckyPack"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/btn_luckypack/gd_hbtb.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/btn_luckypack/gd_hbtb.atlas",
        ["aniNames"] = {"bj_cjhb", "bj_xyhb"},
        ["offsetX"] = -2,
        ["offsetY"] = -14
    },
    ["weekMonthSuperCard"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/weekmonthsuper/zyk_icon_app.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/weekmonthsuper/zyk_icon_app.atlas",
        ["aniNames"] = {"zyk_icon_app"},
        ["offsetX"] = 0,
        ["offsetY"] = 0
    },
    ["gratitudeRepay"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/gratitudeRepay/gehk_icon.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/gratitudeRepay/gehk_icon.atlas",
        ["aniNames"] = {"gehk_icon"},
        ["offsetX"] = 0,
        ["offsetY"] = 0
    },
    ["valuablePurchase"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/valuablePurchase/czlg_icon.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/valuablePurchase/czlg_icon.atlas",
        ["aniNames"] = {"czlg_icon"},
        ["offsetX"] = 0,
        ["offsetY"] = 0
    },
    ['peakRank'] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/GdIcon/gd_icon.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/GdIcon/gd_icon.atlas",
        ["aniNames"] = {"dianfengpaihang"},
        ["offsetX"] = 0,
        ["offsetY"] = 0
    },
    ["goldSilverCopy"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/goldSilverCopy/gd_icon.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/goldSilverCopy/gd_icon.atlas",
        ["aniNames"] = {"yuedutedian"},
        ["offsetX"] = 0,
        ["offsetY"] = 0
    },
}

function SubViewHelper:setQuickStartRoomInfo(panelQuickStart, findScope)
    if panelQuickStart == nil or findScope == nil then
        return nil
    end

    local btnQuickStart = panelQuickStart:getChildByName("Button_QuickStart")
    local labelDesc = btnQuickStart:getChildByName("Text_Desc")

    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    if RoomListModel:checkAreaEntryAvail("noshuffle") == false then
        findScope = "classic"
    end

    if RoomListModel:checkAreaEntryAvail("jisu") == false then
        findScope = "classic"
    end

    local UserModel = mymodel('UserModel'):getInstance()
    local fitRoomInfo = RoomListModel:findFitRoomByDeposit(UserModel.nDeposit, findScope, UserModel.nSafeboxDeposit)

    if not fitRoomInfo then
        fitRoomInfo = RoomListModel:findFitRoomByDepositEx(UserModel.nDeposit, findScope, UserModel.nSafeboxDeposit)
    end

    if fitRoomInfo and fitRoomInfo["isClassicRoom"] then
        local targetStr = "经典"..fitRoomInfo["szRoomName"]
        labelDesc:setString(targetStr)
    elseif fitRoomInfo and fitRoomInfo["isNoShuffleRoom"] then
        local targetStr = "不洗牌"..fitRoomInfo["szRoomName"]
        labelDesc:setString(targetStr)
    elseif fitRoomInfo and fitRoomInfo["isJiSuRoom"] then
        local targetStr = "血战掼蛋"..fitRoomInfo["szRoomName"]
        labelDesc:setString(targetStr)
    elseif fitRoomInfo and fitRoomInfo["isGuideRoom"] then
        local targetStr = "不洗牌"..fitRoomInfo["szRoomName"]
        labelDesc:setString(targetStr)
    end

    return fitRoomInfo
end

function SubViewHelper:initTopBar(panelTop, exitHandler, helpHandler)
    if panelTop == nil then return end

    local btnExit = panelTop:getChildByName("Button_Exit")
    local btnHelp = panelTop:getChildByName("Button_Help")
    local btnSetting = panelTop:getChildByName("Button_Setting")
    local panelDeposit = panelTop:getChildByName("Panel_Deposit")
    local panelScore = panelTop:getChildByName("Panel_Score")
    local btnBuyDeposit = panelDeposit:getChildByName("Button_Add")

    btnExit:addClickEventListener(function()
        if exitHandler then exitHandler() end
    end)
    
    if helpHandler then
        btnHelp:addClickEventListener(function()
            helpHandler()
        end)
    else
        self:bindPluginToBtn(btnHelp, self:getTargetHelpCtrlName())
    end

    self:bindPluginToBtn(btnSetting, "SettingsPlugin")
    SubViewHelper:bindPluginToBtn(btnBuyDeposit, "ShopCtrl")

    btnBuyDeposit:setVisible(cc.exports.isShopSupported())
    panelScore:setVisible(false)
end

function SubViewHelper:initLuckyCatBtn(btn, handler)
    if btn == nil then return end
    btn:addClickEventListener(function()
        if handler then handler() end
    end)
end

function SubViewHelper:getTargetHelpCtrlName()
    if device.platform == "ios" or (cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
        return "HelpCtrl"
    else
        return "HelpCtrlExpand"
    end
end

function SubViewHelper:setTopBarInfo(panelTop)
    if panelTop == nil then return end

    local UserModel = mymodel('UserModel'):getInstance()

    local panelDeposit = panelTop:getChildByName("Panel_Deposit")
    --local panelScore = panelTop:getChildByName("Panel_Score")
    local labelDeposit = panelDeposit:getChildByName("Bmf_Value")
    --local labelScore = panelScore:getChildByName("Bmf_Value")

    labelDeposit:setMoney(UserModel.nDeposit or 0)
    --labelScore:setString(UserModel.nScore or 0)
end

--优先显示昵称，其次用户名
function SubViewHelper:refreshSelfName(labelPlayerName, lengthLimit)
    if labelPlayerName == nil then return end
    lengthLimit = lengthLimit or 200

    local UserModel = mymodel('UserModel'):getInstance()
    local displayName = UserModel:getSelfDisplayName()
    my.fitStringInWidget(displayName, labelPlayerName, lengthLimit)
end

function SubViewHelper:setQuickStartAni(panelQuickStart)
    self:setButtonSkeletonAni(panelQuickStart, SubViewHelper.skAniInfo_QuickStart)
end

function SubViewHelper:setButtonSkeletonAni(nodeMount, aniConfig)
    print("SubViewHelper:setButtonSkeletonAni")
    if nodeMount == nil or aniConfig == nil then
        print("nodeMount or aniConfig is nil")
        return
    end

    local nodeName = "Node_BtnAni"
    if nodeMount:getChildByName(nodeName) == nil then
        local nodeAni = sp.SkeletonAnimation:create(aniConfig["jsonPath"], aniConfig["atlasPath"], 1.0)  
        if #aniConfig["aniNames"] > 1 then
            if cc.exports.isSpringFestivalType() == 1 then
                nodeAni:setAnimation(0, aniConfig["aniNames"][1], true)
            else
                nodeAni:setAnimation(0, aniConfig["aniNames"][2], true)
            end
        else
            nodeAni:setAnimation(0, aniConfig["aniNames"][1], true)
        end
		nodeAni:setDebugBonesEnabled(false)
		nodeAni:setName(nodeName)

        local posX = nodeMount:getContentSize().width / 2
        if aniConfig["offsetX"] then
            posX = posX + aniConfig["offsetX"]
        end
        local posY = nodeMount:getContentSize().height / 2
        if aniConfig["offsetY"] then
            posY = posY + aniConfig["offsetY"]
        end
        nodeAni:setPosition(cc.p(posX,  posY))
		nodeMount:addChild(nodeAni)
	end
end

function SubViewHelper:setButtonFrameAni(csbPath, nodeAni)
    --print("SubViewHelper:showButtonFrameAni")
    if csbPath == nil or nodeAni == nil then
        print("csbPath or nodeAni is nil")
        return
    end

    nodeAni:stopAllActions()
    local action = cc.CSLoader:createTimeline(csbPath)
    if not tolua.isnull(action) then
        nodeAni:runAction(action)
        action:play("animation0", true)
        nodeAni.isBtnAniOn = true
    end
end

function SubViewHelper:bindPluginToBtn(btn, pluginName, pluginParams, clickCallBack)
    if btn == nil or pluginName == nil or pluginName == "" then
        printError("bindPluginToBtn fail, pluginName "..tostring(pluginName))
        return
    end

    btn:addClickEventListener(function()
        my.playClickBtnSound()

        --幸运红包活动时间判断
        if "redPacketBtn" == realname and not OldUserInviteGiftModel:isRedPacketEnable() then
            my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "活动已结束"} })
            OldUserInviteGiftModel:sendInviteGiftData()
            return 
        end
        
        if not UIHelper:checkOpeCycle("SubViewHelper_onClickPluginBtn_"..pluginName) then
            return
        end
        UIHelper:refreshOpeBegin("SubViewHelper_onClickPluginBtn_"..pluginName)

        my.scheduleOnce(function() my.informPluginByName({pluginName = pluginName, params = pluginParams}) end, 0)

        if clickCallBack then clickCallBack() end
    end)
end

--对根节点是Node（不是Layer或Scene，Node没有宽度和高度，无法传递自适配大小）的插件，需要手动刷新下大小
--需要自适应大小的界面，根节点建议使用Layer、Scene、Layout
function SubViewHelper:adaptNodePluginToScreen(pluginNode, panelShade)
    if pluginNode == nil then return end

    if panelShade then
        panelShade:setContentSize(display.size)
    end
end

return SubViewHelper