
local MainView = cc.load('ViewAdapter'):create()

local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local GoldSilverModel = import("src.app.plugins.goldsilver.GoldSilverModel"):getInstance()
local GoldSilverModelCopy = import("src.app.plugins.goldsilverCopy.GoldSilverModelCopy"):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local user = mymodel('UserModel'):getInstance()
local FirstRechargeModel      = import("src.app.plugins.firstrecharge.FirstRechargeModel"):getInstance()
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()

local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

local MainViewConfig = require('src.app.HallConfig.MainViewConfig')
MainView.viewConfig = MainViewConfig.ViewNodeConfig or {}

local roleSkeletonAniInfo = {
    ["girl"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/role_girl/gdnv.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/role_girl/gdnv.atlas",
        ["aniNames"] = {"gd_nv001"}
    },
    ["boy"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/role_boy/gdnan.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/role_boy/gdnan.atlas",
        ["aniNames"] = {"gd_nan001"}
    },
    ["springfestival"] = {
        ["jsonPath"] = "res/hallcocosstudio/images/skeleton/role_springfestival/guandan_nv.json",
        ["atlasPath"] = "res/hallcocosstudio/images/skeleton/role_springfestival/guandan_nv.atlas",
        ["aniNames"] = {"zhayan"}
    },
}

function MainView:onCreateView(viewNode)
    self.viewNode = viewNode
    self:setSpringFestivalView()

    function viewNode:setSex(isGirl)
        printLog("viewNode", isGirl)
        if self._unableSetSex then return end
        if self.girlHeadPic then
            self.girlHeadPic:loadTexture(cc.exports.getHeadResPath(isGirl), 0)
        end
    end

    function viewNode:hideSex()
        if self.girlHeadPic then
            self.girlHeadPic:setVisible(false)
        end
    end

    function viewNode:unableSetSex()
        self._unableSetSex = true
    end

    function viewNode:enableSetSex()
        self._unableSetSex = false
    end

    self._pluginBtnPanels = {
        ["panelTop"] = viewNode.panelTop,
        ["leftBar"] = viewNode.panelLeftBar,
        ["packSet"] = viewNode.panelPackSet,
        ["bottomBar"] = viewNode.panelBottomBar,
        ["panelMore"] = viewNode.panelMoreBtns
    }
    self._pluginViewData = require("src.app.plugins.mainpanel.PluginViewData")
    self:initView(viewNode)
    self._ctrl.subManager.subRoomManager:initView(viewNode)
end

function MainView:runEnterAni(viewNode)
    local nodeTarget = viewNode.panelAreas
    if nodeTarget.posXRaw == nil then
        nodeTarget.posXRaw = nodeTarget:getPositionX()
    end

    local curPosX = nodeTarget:getPositionX()
    if curPosX > nodeTarget.posXRaw then
        return --动画正在进行中
    end

    --先设定好初始位置和透明度，下一帧再执行帧动画，可以更流畅
    nodeTarget:setPositionX(nodeTarget.posXRaw + 500)
    nodeTarget:setOpacity(10)

    my.scheduleOnce(function()
        local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTarget.posXRaw, nodeTarget:getPositionY()))
        local fadeAction = cc.FadeTo:create(0.4, 255)
        local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
        nodeTarget:runAction(spawnAction)
    end, 0)
end

function MainView:initView(viewNode)
    if viewNode == nil then return end

    viewNode.panelLeftBar:setVisible(false)
    for itemName, itemData in pairs(self._pluginViewData) do
        local belongedPanel = self._pluginBtnPanels[itemData["belongedPanel"]]
        itemData["pluginBtn"] = belongedPanel:getChildByName(itemData["nodeName"])
        if itemData["pluginName"] then
            SubViewHelper:bindPluginToBtn(itemData["pluginBtn"], itemData["pluginName"])
        end
    end

    self:refreshRoleAni(viewNode)
    self:_initPanelTop(viewNode)
    self:_initLeftBar(viewNode)
    self:_initBottomBar(viewNode)

end

function MainView:showPacketSetAni()
        --延时是为了等截面刷新完成再展示出来，否则会看到一个变化的过程
        my.scheduleOnce(function() self:showExtendedBtnPanelForAWhile(viewNode) end, 0.5)
end
function MainView:refreshRoleAni(viewNode)
    local nodeMount = viewNode.nodeRoleAni
    local nodeName = "nodeSkeletonAni"
    local aniConfigKey = 'boy'
    
    local sexName = mymodel('UserModel'):getInstance():getSexName()
    if sexName == "girl" then
        aniConfigKey = 'girl'
    end

    -- 春节换人物
    if SpringFestivalModel:showSpringFestivalView() then
        aniConfigKey = 'springfestival'
    end

    local aniConfig = roleSkeletonAniInfo[aniConfigKey]
    local nodeAni = nodeMount:getChildByName(nodeName)
    if nodeAni ~= nil then
        if nodeAni.roleSexName == sexName then
            return --相同则不需要再刷新
        end
        nodeAni:removeFromParentAndCleanup()
    end
	if nodeMount:getChildByName(nodeName) == nil then
		nodeAni = sp.SkeletonAnimation:create(aniConfig["jsonPath"], aniConfig["atlasPath"], 1)  
		nodeAni:setAnimation(0, aniConfig["aniNames"][1], true)
		nodeAni:setDebugBonesEnabled(false)
		nodeAni:setName(nodeName)
        nodeAni:setPosition(cc.p(-100, -220))
        nodeAni.roleSexName = sexName
        nodeMount:addChild(nodeAni, 0)

        local tipNode = viewNode.nodeRoleAni:getChildByName("Img_TipBG")
        if tipNode then
            tipNode:setLocalZOrder(nodeAni:getLocalZOrder() + 1)
        end
	end
end

function MainView:_initPanelTop(viewNode)
    SubViewHelper:initTopBar(viewNode.panelTop, handler(self._ctrl, self._ctrl.onClickExit))
    SubViewHelper:bindPluginToBtn(viewNode.personalInfoBtn, "PersonalInfoCtrl")
    
    SubViewHelper:bindPluginToBtn(viewNode.nobilityPrivilegeBtn, "NobilityPrivilegeCtrl")

    SubViewHelper:initLuckyCatBtn(viewNode.BtnLuckyCat, handler(self._ctrl, self._ctrl.onClickLuckyCat))

    viewNode.memberPic:setPosition(cc.p(300, 38))
end

function MainView:_initLeftBar(viewNode)
    local panelPackSet = viewNode.panelPackSet
    local btnPackSet = self._pluginViewData["packSet"]["pluginBtn"]
    local btnGameCity = self._pluginViewData["gameCity"]["pluginBtn"]

    panelPackSet:setVisible(false)
    self:adjustLeftBtnPos(false)

    UIHelper:setTouchByOpacityForObjWithSpineAni(btnPackSet, function()
        my.playClickBtnSound()
        TimerManager:stopTimer("Timer_ShowExtendedBtnPanelForAWhile_PackSet")
        panelPackSet:setVisible(not panelPackSet:isVisible())
        self:adjustLeftBtnPos(panelPackSet:isVisible())
    end, btnPackSet, "Node_BtnAni")
    UIHelper:setTouchByOpacityForObjWithSpineAni(btnGameCity, handler(self, self._onClickBtnGameCity), btnGameCity, "Node_BtnAni")

    --首冲
    SubViewHelper:bindPluginToBtn(self._pluginViewData["firstRechargePack"]["pluginBtn"], "FirstRecharge", nil, function()
        if self._pluginViewData["firstRechargePack"]["isNeedReddot"] == true then
            CommonData:setUserData("firstRecharge_lastNoticeTime", os.time())
            CommonData:saveUserData()
            self:refreshPluginBtnReddotDirectly("firstRechargePack", false)
        end
    end)

    SubViewHelper:bindPluginToBtn(self._pluginViewData["firstRechargePack_LeftBar"]["pluginBtn"], "FirstRecharge", nil, function()
        if self._pluginViewData["firstRechargePack_LeftBar"]["isNeedReddot"] == true then
            CommonData:setUserData("firstRecharge_lastNoticeTime", os.time())
            CommonData:saveUserData()
            self:refreshPluginBtnReddotDirectly("firstRechargePack_LeftBar", false)
        end
    end)

    --限时特惠
    SubViewHelper:bindPluginToBtn(self._pluginViewData["limitTimeSpecialPack_LeftBar"]["pluginBtn"], "LimitTimeSpecial", nil, function()
        if self._pluginViewData["limitTimeSpecialPack_LeftBar"]["isNeedReddot"] == true then
            CommonData:setUserData("limitTimeSpecial_lastNoticeTime", os.time())
            CommonData:saveUserData()
            self:refreshPluginBtnReddotDirectly("limitTimeSpecialPack_LeftBar", false)
        end
    end)
    

    --巅峰榜
    SubViewHelper:bindPluginToBtn(self._pluginViewData["topRank"]["pluginBtn"], "NationalDayActivityPlugin", nil, function()
        if self._pluginViewData["topRank"]["isNeedReddot"] == true then
            CommonData:setUserData("topRank_lastNoticeTime", os.time())
            CommonData:saveUserData()
            self:refreshPluginBtnReddotDirectly("topRank", false)
        end
    end)

    --传奇来了
    SubViewHelper:bindPluginToBtn(self._pluginViewData["legendCome"]["pluginBtn"], "OutlayGame", {gameName='outgame1'}, function()
        my.dataLink(cc.exports.DataLinkCodeDef.ENTER_CHUAN_QI)
    end)

    --电玩城的动画总是播放，所以只需要init的时候设置好播放动画即可
    self:refreshPluginBtnAni(self._pluginViewData["gameCity"])


    --新金银杯
    self._pluginViewData["goldSilver"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        if GoldSilverModel:NeedPopGoldSilverBuyLayer() then
            my.informPluginByName({ pluginName = 'GoldSilverBuyLayer' })
        else
            my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
        end
    end)

    --新金银杯副本
    self._pluginViewData["goldSilverCopy"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        if GoldSilverModelCopy:NeedPopGoldSilverBuyLayer() then
            my.informPluginByName({ pluginName = 'GoldSilverBuyLayerCopy' })
        else
            my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
        end
    end)

    --碰碰乐
    self._pluginViewData["PPL"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        if user.nSafeboxDeposit then
            if cc.exports.getPPLDepositLimit() and user.nSafeboxDeposit + user.nDeposit < cc.exports.getPPLDepositLimit() then
                local tipString = string.format("抱歉，您的银两低于%d银两，无法进入",cc.exports.getPPLDepositLimit())
                my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = tipString, removeTime = 3}})
                return 
            end
            my.informPluginByName({ pluginName = 'xyxz' })
        end
    end)

    -- 超级大奖池
    local rechargePoolBtn = self._pluginViewData["rechargepool"]["pluginBtn"]
    if rechargePoolBtn then
        rechargePoolBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'RechargePool' })
        end)
    end

    -- 看视频领奖励
    local watchVideoBtn = self._pluginViewData["WatchVideo"]["pluginBtn"]
    if watchVideoBtn then
        watchVideoBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'WatchVideoTakeReward' })
        end)
    end

    -- 充值翻翻乐
    local rechargeFlopCardBtn = self._pluginViewData["rechargeFlopCard"]["pluginBtn"]
    if rechargeFlopCardBtn then
        rechargeFlopCardBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'RechargeFlopCard' })
        end)
    end

    -- 周月至尊卡
    local weekMonthSuperCardBtn = self._pluginViewData["weekMonthSuperCard"]["pluginBtn"]
    if weekMonthSuperCardBtn then
        weekMonthSuperCardBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'WeekMonthSuperCardCtrl' })
        end)
    end

    -- 连充送话费
    local continueRechargeBtn = self._pluginViewData["continueRecharge"]["pluginBtn"]
    if continueRechargeBtn then
        continueRechargeBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'ContinueRechargeCtrl' })
        end)
    end

    -- 幸运大礼包
    local luckyPackBtn = self._pluginViewData["luckyPack"]["pluginBtn"]
    if cc.exports.isSpringFestivalType() == 1 then
        luckyPackBtn:getChildByName("Image_title_cjlb"):setVisible(false)
        luckyPackBtn:getChildByName("Image_title_xylb"):setVisible(false)
    else
        luckyPackBtn:getChildByName("Image_title_cjlb"):setVisible(false)
        luckyPackBtn:getChildByName("Image_title_xylb"):setVisible(false)
    end
    if luckyPackBtn then
        luckyPackBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'LuckyPackCtrl' })
        end)
    end

    -- Vivo特权活动
    local vivoPrivilegeStartUpBtn = self._pluginViewData["vivoPrivilegeStartUp"]["pluginBtn"]
    if vivoPrivilegeStartUpBtn then
        vivoPrivilegeStartUpBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if not CenterCtrl:checkNetStatus() then return end
            my.informPluginByName({ pluginName = 'VivoPrivilegeStartUpCtrl' })
        end)
    end

    -- 超值连购
    self._pluginViewData["valuablePurchase"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        my.informPluginByName({pluginName = "ValuablePurchase"})
    end)
end

function MainView:_initBottomBar(viewNode)
    local panelBottomBar = viewNode.panelBottomBar
    local panelMoreBtns = viewNode.panelMoreBtns
    
    panelMoreBtns:setVisible(false)
    self._pluginViewData["more"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        TimerManager:stopTimer("Timer_ShowExtendedBtnPanelForAWhile_MoreBtns")
        panelMoreBtns:setVisible(not panelMoreBtns:isVisible())
    end)
    self._pluginViewData["friendRoom"]["pluginBtn"]:addClickEventListener(function()
        --my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        my.scheduleOnce(function()
            self._ctrl.subManager.subRoomManager:onClickAreaBtn("team") --不延迟加载csb界面，按钮点击状态变化会有点卡顿
        end, 0)
    end)
    self._pluginViewData["friend"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        mymodel('PluginEventHandler.TcyFriendPlugin'):getInstance():showFriendListDialog()
    end)
    self._pluginViewData["yuleRoom"]["pluginBtn"]:addClickEventListener(function()
        if not CenterCtrl:checkNetStatus() then return end
        my.scheduleOnce(function()
            self._ctrl.subManager.subRoomManager:onClickAreaBtn("joy") --不延迟加载csb界面，按钮点击状态变化会有点卡顿
        end, 0)
    end)
    self._pluginViewData["share"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        local ShareCtrl = import('src.app.plugins.sharectrl.ShareCtrl')
        ShareCtrl:loadShareConfig()
        ShareCtrl:shareToFriendsCornerClicked()
    end)
    --兑换码
    self._pluginViewData["giftexchange"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        my.informPluginByName({pluginName = "GiftExchange"})
    end)
    self._pluginViewData["shop"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        
        my.informPluginByName({pluginName = "ShopCtrl"})
    end)

    --主播福袋
    self._pluginViewData["anchorLuckyBag"]["pluginBtn"]:addClickEventListener(function()
        my.playClickBtnSound()
        if not CenterCtrl:checkNetStatus() then return end
        my.informPluginByName({pluginName = "AnchorLuckyBagCtrl"})
    end)

    if cc.exports.isIosALONE() == true then
        local btnSafebox = self._pluginViewData["safeBox"]["pluginBtn"]
        btnSafebox:loadTextureNormal("hallcocosstudio/images/plist/hall_img/btn_backbox.png", ccui.TextureResType.plistType)
        btnSafebox:loadTexturePressed("hallcocosstudio/images/plist/hall_img/btn_backbox.png", ccui.TextureResType.plistType)
    end

    -- 邀请有礼
    SubViewHelper:bindPluginToBtn(viewNode.yqylBtn, "InviteGiftAwardCtrl")

    SubViewHelper:bindPluginToBtn(viewNode.redPacketBtn, "OldUserInitGiftCtrl")
end

function MainView:refreshView(viewNode)
    if viewNode == nil then return end

    self:refreshPanelTop(viewNode)
    self:refreshPanelPackSet(viewNode)
    self:refreshLeftBar(viewNode)
    self:refreshPanelMoreBtns(viewNode)
    self:refreshBottomBar(viewNode)
    self:refreshTimingGameTips(viewNode)
    self:refreshMoreGameEntry(viewNode)    
    self:refreshPeakRankBtn(viewNode)

    self._ctrl.subManager.subRoomManager:refreshView()
end

--根据开关刷新一遍
function MainView:_refreshAvailBySwith(itemDataList)
    for itemName, itemData in pairs(itemDataList) do
        if itemData["checkSupport"] then
            if itemData["isAvailOnlyByCheckSupport"] == true then
                itemData["isAvail"] = itemData["checkSupport"]()
            else
                itemData["isAvail"] = itemData["isAvail"] and itemData["checkSupport"]()
            end
        end
    end
end

function MainView:refreshViewOnDepositChange(viewNode)
    self._ctrl.subManager.subRoomManager:refreshViewOnDepositChange()
end

function MainView:refreshPanelTop(viewNode)
    if viewNode == nil then return end

    viewNode.imgIconTcy:setVisible(false)
    viewNode.imgIconWechat:setVisible(false)

    local UserModel = mymodel('UserModel'):getInstance()
	viewNode.memberPic:setVisible(false)

    viewNode.userDepositTxt:setMoney(UserModel.nDeposit or 0)

    --有贵族特权系统不显示会员
    viewNode.nobilityPrivilegeBtn:setVisible(false)
    if NobilityPrivilegeModel:isAlive() then
        viewNode.nobilityPrivilegeBtn:setVisible(true)
    end

    --主播微信信息
    if cc.exports.isAnchorWeiXinSupported() then
        local anchorWeiXinTitle = cc.exports.getAnchorWeiXinTitle()
        local anchorWeiXinName = cc.exports.getAnchorWeiXinName()
        if anchorWeiXinTitle and anchorWeiXinName and anchorWeiXinTitle ~= "" and anchorWeiXinName ~= "" then
            if viewNode.panelTop then
                local txtWxTitle = viewNode.panelTop:getChildByName("Image_WeiXin"):getChildByName("Text_wxTitle")
                local txtWxName = viewNode.panelTop:getChildByName("Image_WeiXin"):getChildByName("Text_wxName")
                if txtWxTitle and txtWxName then
                    txtWxTitle:setString(anchorWeiXinTitle)
                    txtWxName:setString(anchorWeiXinName)
                end
            end            
        end

        local clickAnchorWXBtn = nil
        if user.nUserID then
            clickAnchorWXBtn = CacheModel:getCacheByKey("ClickAnchorWXBtn"..user.nUserID)
            if clickAnchorWXBtn and toint(clickAnchorWXBtn) == 1 then
                -- 停止动效
                local aniWeiXin = viewNode.panelTop:getChildByName("Ani_weixin")
                if aniWeiXin then
                    aniWeiXin:setVisible(false)
                    aniWeiXin:stopAllActions()
                    -- aniWeiXin:removeAllChildren()  
                end                              
            else
                -- 开始动效
                local action = cc.CSLoader:createTimeline("res/hallcocosstudio/activitycenter/Ani_WX.csb")
                local aniWeiXin = viewNode.panelTop:getChildByName("Ani_weixin")
                if action and aniWeiXin  then
                    aniWeiXin:runAction(action)
                    action:play("animation0", true)
                end
            end
        end

        if viewNode.panelTop then
            local imgWX = viewNode.panelTop:getChildByName("Image_WeiXin")            
            if imgWX then
                if cc.exports.anchorWXShow then
                    imgWX:setVisible(true)
                else
                    imgWX:setVisible(false)
                end

                if user.nUserID then
                    clickAnchorWXBtn = CacheModel:getCacheByKey("ClickAnchorWXBtn"..user.nUserID)
                    if not clickAnchorWXBtn or toint(clickAnchorWXBtn) ~= 1 then
                        imgWX:setVisible(true)
                        cc.exports.anchorWXShow = true
                    end
                end                                
            end            

            local btnWX = viewNode.panelTop:getChildByName("Button_weixin")
            if btnWX then
                btnWX:addClickEventListener(function()
                    my.playClickBtnSound()
                    if user.nUserID then
                        if not clickAnchorWXBtn or (clickAnchorWXBtn and toint(clickAnchorWXBtn) ~= 1) then
                            CacheModel:saveInfoToCache("ClickAnchorWXBtn" .. tostring(user.nUserID), 1)
                        end 
                    end                   
                    local imgWX = viewNode.panelTop:getChildByName("Image_WeiXin")
                    if imgWX then
                        if cc.exports.anchorWXShow then
                            imgWX:setVisible(false)
                            cc.exports.anchorWXShow = false
                        else
                            imgWX:setVisible(true)
                            cc.exports.anchorWXShow = true
                        end
                    end
                    -- 停止动效
                    local aniWeiXin = viewNode.panelTop:getChildByName("Ani_weixin")
                    if aniWeiXin then
                        aniWeiXin:setVisible(false)
                        aniWeiXin:stopAllActions()
                        -- aniWeiXin:removeAllChildren()     
                    end         
                end)
            end

        end
    else
        if viewNode.panelTop then
            -- 隐藏微信信息
            viewNode.panelTop:getChildByName("Image_WeiXin"):setVisible(false)
            viewNode.panelTop:getChildByName("Button_weixin"):setVisible(false)
            -- 停止动效
            local aniWeiXin = viewNode.panelTop:getChildByName("Ani_weixin")
            aniWeiXin:setVisible(false)
            aniWeiXin:stopAllActions()
            -- aniWeiXin:removeAllChildren()
        end
    end

    --主播海报信息
    if cc.exports.isAnchorPosterSupported() then
        viewNode.panelTop:getChildByName("Button_Anchor"):setVisible(true)
        local btnAnchor = viewNode.panelTop:getChildByName("Button_Anchor")
        if btnAnchor then
            btnAnchor:addClickEventListener(function()
                my.playClickBtnSound()
                my.informPluginByName({pluginName = "AnchorPosterCtrl"})
            end)
        end
    else
        viewNode.panelTop:getChildByName("Button_Anchor"):setVisible(false)
    end

    local btnsInfo = {
        self._pluginViewData["anchorLuckyBag"]
    }
    self:_refreshAvailBySwith(btnsInfo)
    for i = 1, #btnsInfo do
        btnsInfo[i]["pluginBtn"]:setVisible(btnsInfo[i]["isAvail"] == true)
    end
end

function MainView:refreshPanelPackSet(viewNode)
    if viewNode == nil then return end

    local panelBtns = viewNode.panelPackSet
    local imgBk = panelBtns:getChildByName("Image_Bk")

    local btnsInfo = {
        self._pluginViewData["loginPack"],
        self._pluginViewData["firstRechargePack"],
        self._pluginViewData["monthCardPack"],
        self._pluginViewData["bankruptcyPack"],
        self._pluginViewData["NobilityPrivilegeGift"],
        self._pluginViewData["limitTimeSpecialPack"]
    }
    self:_refreshAvailBySwith(btnsInfo)

    local availBtns = {}
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            table.insert(availBtns, btnsInfo[i]["itemName"])
        end
        btnsInfo[i]["pluginBtn"]:setVisible(btnsInfo[i]["isAvail"] == true)
    end
    local visibleCount = #availBtns
    
    local posXStart = 90
    local distanceX = 120
    local curIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            curIndex = curIndex + 1
            btnsInfo[i]["pluginBtn"]:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end
    end

    local itemViewDataPackset = self._pluginViewData["packSet"]
    if visibleCount > 1 then
        for i = 2, visibleCount do
            panelBtns:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(true)
        end
        for i = visibleCount + 1, #btnsInfo do
            panelBtns:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(false)
        end
        local newBkWidth = 755 - 120 * (#btnsInfo - visibleCount)
        imgBk:setContentSize(cc.size(newBkWidth, imgBk:getContentSize().height))

        itemViewDataPackset["isAvail"] = true
        viewNode.panelPackSet:setVisible(true)  --伟刚需求，每次登陆都显示
        self:adjustLeftBtnPos(true)

        for i, itemName in ipairs(availBtns) do
            self._pluginViewData[itemName.."_LeftBar"]["isAvail"] = false
        end

        -- 刷新限时特惠时间
        self:refresSpecialLimitTime(panelBtns, 1)
    else

        for i, itemName in ipairs(availBtns) do
            self._pluginViewData[itemName.."_LeftBar"]["isAvail"] = true
        end

        itemViewDataPackset["isAvail"] = false
        viewNode.panelPackSet:setVisible(false) --如果礼包合集按钮都没了，扩展面板也需要隐藏掉
        self:adjustLeftBtnPos(false)
    end
    self:refreshLeftBar(viewNode)
end

function MainView:refresLuckyPackBtn(viewNode)
    -- 幸运大礼包
    local luckyPackBtn = self._pluginViewData["luckyPack"]["pluginBtn"]
    if cc.exports.isSpringFestivalType() == 1 then
        luckyPackBtn:getChildByName("Image_title_cjlb"):setVisible(false)
        luckyPackBtn:getChildByName("Image_title_xylb"):setVisible(false)
    else
        luckyPackBtn:getChildByName("Image_title_cjlb"):setVisible(false)
        luckyPackBtn:getChildByName("Image_title_xylb"):setVisible(false)
    end
end

--刷新限时特惠的时间 从FirstRechargeModel中获取新的计时器的值
function MainView:refresSpecialLimitTime(viewNode, belongType)
    -- 刷新限时特惠时间
    local remainTime = FirstRechargeModel:getFirstLimitLeftTime()
    --由于被放入到刷新模块中，部分模块开启时从FirstRechargeModelmodel中的值还没获取，可能是空值，所有要加入条件过滤
    if(remainTime) then
        viewNode:getChildByName("Btn_LimitTimeSpecial"):getChildByName("BF_Countdown"):setVisible(false)
        if remainTime then
            remainTime = remainTime - 86400 * 2         -- 为了保证兼容性，客户端手动减去两天的时间
            if remainTime > 0 then
                viewNode:getChildByName("Btn_LimitTimeSpecial"):getChildByName("BF_Countdown"):setVisible(true)
                self:updateTimeInterval(remainTime, viewNode, belongType)
            end
        end
    end
end

function MainView:refreshLeftBar(viewNode)
    print("refreshLeftBar")
    if viewNode == nil then return end

    local panelBtns = viewNode.panelLeftBar
    panelBtns:setVisible(true)
    
    local btnsInfo = {
        self._pluginViewData["loginPack_LeftBar"],
        self._pluginViewData["firstRechargePack_LeftBar"],
        self._pluginViewData["monthCardPack_LeftBar"],
        self._pluginViewData["bankruptcyPack_LeftBar"],
        self._pluginViewData["NobilityPrivilegeGift_LeftBar"],
        self._pluginViewData["limitTimeSpecialPack_LeftBar"],

        self._pluginViewData["packSet"],
        self._pluginViewData["PPL"],
        self._pluginViewData["luckyPack"],
        self._pluginViewData["gameCity"],
        self._pluginViewData["rechargeAct"],
        self._pluginViewData["topRank"],
        self._pluginViewData["legendCome"],
        self._pluginViewData["rechargepool"],
        self._pluginViewData["continueRecharge"],
        --对局送门票功能图标不显示
        --self._pluginViewData["timingGameTicketTask"],
        self._pluginViewData["vivoPrivilegeStartUp"],
        self._pluginViewData["WatchVideo"],
        self._pluginViewData["rechargeFlopCard"],
        self._pluginViewData["gratitudeRepay"],
        self._pluginViewData["goldSilver"],
        self._pluginViewData["goldSilverCopy"],
        self._pluginViewData["weekMonthSuperCard"],
        self._pluginViewData['valuablePurchase']
    }
    self:_refreshAvailBySwith(btnsInfo)
    self:refresLuckyPackBtn()
    self:refresSpecialLimitTime(panelBtns, 2)
    -- 刷新周月至尊卡包按钮
    self:refreshWeekMonthSuperCardBtn()
    --dump(btnsInfo, "btnsInfo")
    local visibleCount = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visibleCount = visibleCount + 1
        end
        btnsInfo[i]["pluginBtn"]:setVisible(btnsInfo[i]["isAvail"] == true)
    end

    local posYStart = 446
    local itemDistanceY = 100 * panelBtns:getContentSize().height / 500
    itemDistanceY = math.max(math.min(itemDistanceY, 120), 100)
    local curPosX = 54
    local curPosY = posYStart + itemDistanceY
    local prevAvailItem = nil
    local curColIndex = 1
    local firstColPosY = {}
    local visIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visIndex = visIndex + 1
            if curColIndex == 1 then
                curPosY = curPosY - itemDistanceY
                if btnsInfo[i]["itemName"] == "packSet" then
                    curPosY = curPosY + 5 --微调
                end
                if prevAvailItem and prevAvailItem["itemName"] == "goldSilver" then
                    curPosY = curPosY - 30 --金银杯由于有说明文字，需要一些额外空间
                end
                if prevAvailItem and prevAvailItem["itemName"] == "goldSilverCopy" then
                    curPosY = curPosY - 30 --金银杯由于有说明文字，需要一些额外空间
                end
                firstColPosY[visIndex] = curPosY                
            else                
                local num = table.nums(firstColPosY)
                local rowIndex = (visIndex - 1) % num + 1
                if viewNode.panelPackSet:isVisible() then
                    rowIndex = (visIndex - num - 1) % (num - 1) + 2
                end
                
                curPosY = firstColPosY[rowIndex]
                if btnsInfo[i]["itemName"] == "luckyPack" then
                    curPosY = curPosY - 10 --微调
                end
            end
            btnsInfo[i]["pluginBtn"]:setPosition(cc.p(curPosX, curPosY))
            btnsInfo[i]["leftBarColIndex"] = curColIndex
            btnsInfo[i]["selfPosY"] = curPosY

            --如果第一列没有空余位置了，则换到第二列
            if curColIndex == 1 then
                local leftSpace = display.height - 220 - (posYStart - curPosY) - itemDistanceY + 50
                if leftSpace < itemDistanceY then
                    curPosX = curPosX + 100
                    curColIndex = 2
                end
            elseif curColIndex == 2 then
                local leftSpace = display.height - 280 - (posYStart - curPosY) - itemDistanceY + 50
                if leftSpace < itemDistanceY - 20 then
                    curPosX = curPosX + 100
                    curColIndex = 3
                end
            end

            prevAvailItem = btnsInfo[i]
        end
        self:refreshPluginBtnAni(btnsInfo[i])
    end
    self:adjustLeftBtnPos(viewNode.panelPackSet:isVisible())
end

function MainView:adjustLeftBtnPos(bExpand)
    local btnsInfo = {
        self._pluginViewData["loginPack_LeftBar"],
        self._pluginViewData["firstRechargePack_LeftBar"],
        self._pluginViewData["monthCardPack_LeftBar"],
        self._pluginViewData["bankruptcyPack_LeftBar"],
        self._pluginViewData["NobilityPrivilegeGift_LeftBar"],
        self._pluginViewData["limitTimeSpecialPack_LeftBar"],

        self._pluginViewData["packSet"],
        self._pluginViewData["PPL"],
        self._pluginViewData["luckyPack"],
        self._pluginViewData["gameCity"],
        self._pluginViewData["rechargeAct"],
        self._pluginViewData["topRank"],
        self._pluginViewData["legendCome"],
        self._pluginViewData["rechargepool"],
        self._pluginViewData["continueRecharge"],
        --对局送门票功能图标不显示
        --self._pluginViewData["timingGameTicketTask"],
        self._pluginViewData["vivoPrivilegeStartUp"],
        self._pluginViewData["WatchVideo"],
        self._pluginViewData["rechargeFlopCard"],
        self._pluginViewData["gratitudeRepay"],
        self._pluginViewData["goldSilver"],
        self._pluginViewData["goldSilverCopy"],
        self._pluginViewData["weekMonthSuperCard"],
        self._pluginViewData['valuablePurchase']
    }

    local panelBtns = self._pluginBtnPanels.leftBar

    local posYStart = 446
    local itemDistanceY = 100 * panelBtns:getContentSize().height / 500
    itemDistanceY = math.max(math.min(itemDistanceY, 120), 100)
    local curPosX = 54
    local curPosY = posYStart + itemDistanceY
    local prevAvailItem = nil
    local curColIndex = 1
    local firstColPosY = {}
    local visIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visIndex = visIndex + 1
            if curColIndex == 1 then
                curPosY = curPosY - itemDistanceY
                if btnsInfo[i]["itemName"] == "packSet" then
                    curPosY = curPosY + 5 --微调
                end
                if prevAvailItem and prevAvailItem["itemName"] == "goldSilver" then
                    curPosY = curPosY - 30 --金银杯由于有说明文字，需要一些额外空间
                end
                if prevAvailItem and prevAvailItem["itemName"] == "goldSilverCopy" then
                    curPosY = curPosY - 30 --金银杯由于有说明文字，需要一些额外空间
                end
                firstColPosY[visIndex] = curPosY                
            else                
                local num = table.nums(firstColPosY)
                local rowIndex = (visIndex - 1) % num + 1
                if bExpand then
                    rowIndex = (visIndex - num - 1) % (num - 1) + 2
                end
                
                curPosY = firstColPosY[rowIndex]
                if btnsInfo[i]["itemName"] == "luckyPack" then
                    curPosY = curPosY - 10 --微调
                end
            end
            btnsInfo[i]["pluginBtn"]:setPosition(cc.p(curPosX, curPosY))
            btnsInfo[i]["leftBarColIndex"] = curColIndex
            btnsInfo[i]["selfPosY"] = curPosY

            --如果第一列没有空余位置了，则换到第二列
            if curColIndex == 1 then
                local leftSpace = display.height - 220 - (posYStart - curPosY) - itemDistanceY + 50
                if leftSpace < itemDistanceY then
                    curPosX = curPosX + 100
                    curColIndex = 2
                end
            elseif curColIndex == 2 then
                local leftSpace = display.height - 280 - (posYStart - curPosY) - itemDistanceY + 50
                if leftSpace < itemDistanceY - 20 then
                    curPosX = curPosX + 100
                    curColIndex = 3
                end
            end

            prevAvailItem = btnsInfo[i]
        end
        self:refreshPluginBtnAni(btnsInfo[i])
    end
end

function MainView:refreshBottomBar(viewNode)
    if viewNode == nil then return end

    local panelBtns = viewNode.panelBottomBar
    local panelMoreBtns = viewNode.panelMoreBtns
    local btnMore = self._pluginViewData["more"]["pluginBtn"]

    local btnsInfo = {
        self._pluginViewData["shop"],
        self._pluginViewData["more"],
        self._pluginViewData["safeBox"],
        self._pluginViewData["lottery"],
        self._pluginViewData["exchange"],
        self._pluginViewData["task"],
        self._pluginViewData["activity"],
        self._pluginViewData["yuleRoom"]        
    }
    self:_refreshAvailBySwith(btnsInfo)

    local visibleCount = 1
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visibleCount = visibleCount + 1
        end
        btnsInfo[i]["pluginBtn"]:setVisible(btnsInfo[i]["isAvail"] == true)
    end

    local posXStart = 53
    local distanceX = 100 * panelBtns:getContentSize().width / 860
    distanceX = distanceX * #btnsInfo / (visibleCount > 0 and visibleCount or 1)
    distanceX = math.max(math.min(distanceX, 150), 110)
    distanceX = distanceX - 5
    local curIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            curIndex = curIndex + 1
            btnsInfo[i]["pluginBtn"]:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end

        if i == #btnsInfo then
            curIndex = curIndex + 1
            self._viewNode.redPacketNode:setPositionX(posXStart + (curIndex - 1) * distanceX)
            self._viewNode.yqylNode:setPositionX(posXStart + (curIndex - 1) * distanceX)
            self._viewNode.redbagPanel:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end

        self:refreshPluginBtnAni(btnsInfo[i])
    end

    panelMoreBtns:setPositionX(panelBtns:getPositionX() + btnMore:getPosition() - 60)    
end

function MainView:refreshPanelMoreBtns(viewNode)
    local panelBtns = viewNode.panelMoreBtns
    local imgBk = panelBtns:getChildByName("Image_Bk")

    local btnsInfo = {
        self._pluginViewData["mail"],
        self._pluginViewData["friendRoom"],
        self._pluginViewData["friend"],
        self._pluginViewData["share"],
        self._pluginViewData["giftexchange"], --兑换码
    }
    self:_refreshAvailBySwith(btnsInfo)

    local visibleCount = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visibleCount = visibleCount + 1
        end
        btnsInfo[i]["pluginBtn"]:setVisible(btnsInfo[i]["isAvail"] == true)
    end

    local posXStart = 60
    local distanceX = 120
    local curIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            curIndex = curIndex + 1
            btnsInfo[i]["pluginBtn"]:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end
    end
    for i = visibleCount + 1, #btnsInfo do
        panelBtns:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(false)
    end
    local newBkWidth = 600 - 120 * (#btnsInfo - visibleCount)
    imgBk:setContentSize(cc.size(newBkWidth, imgBk:getContentSize().height))
end

function MainView:onLogoff(viewNode)
end

function MainView:onLogon(viewNode)
    self:refreshView(viewNode)
end

function MainView:_onClickBtnGameCity()
    if not CenterCtrl:checkNetStatus() then
        return
    end

    if (my.isEngineSupportVersion('1.5.20181015') or device.platform == 'ios') then
        --策划需求加限制 20200103
        if cc.exports.getDWCDepositLimit() and user.nSafeboxDeposit + user.nDeposit < cc.exports.getDWCDepositLimit() then
            local tipString = string.format("抱歉，您的银两低于%d银两，无法进入电玩城",cc.exports.getDWCDepositLimit())
            my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = tipString, removeTime = 3}})
            return 
        end
        my.informPluginByName({pluginName = "SmallGamePlugin"})
    else
        my.informPluginByName({pluginName = "SureDialog", params = {
            tipContent = "您的同城游版本过低，请下载最新版本进行游戏",
            onOk = function()
                DeviceUtils:getInstance():openBrowser("https://www.tcy365.com")
            end,
            closeBtVisible = true
        }})
    end
end

function MainView:refreshPluginBtnReddotDirectly(itemName, isNeedReddot)
    if itemName == nil then return end
    local itemViewData = self._pluginViewData[itemName]
    if itemViewData == nil then return end

    itemViewData["isNeedReddot"] = isNeedReddot
    self:refreshPluginBtnReddot(itemViewData)
end

function MainView:refreshPluginBtnReddotByModel(itemName, pluginModel)
    if itemName == nil or pluginModel == nil then return end
    local itemViewData = self._pluginViewData[itemName]
    if itemViewData == nil then return end

    itemViewData["isNeedReddot"] = (pluginModel:getStatusDataExtended("isNeedReddot") == true)
    if itemViewData["btnAniCondition"] == "onNeed" then
        itemViewData["isNeedBtnAni"] = (pluginModel:getStatusDataExtended("isNeedBtnAni") == true)
    end
    self:refreshPluginBtnReddot(itemViewData)
end

function MainView:refreshPluginBtnReddot(itemViewData)
    if itemViewData == nil then return end

    local belongedPanel = itemViewData["belongedPanel"]
    local btnNode = itemViewData["pluginBtn"]
    local isNeedReddot = itemViewData["isNeedReddot"]
    if btnNode and btnNode:getChildByName("Img_Dot") then
        btnNode:getChildByName("Img_Dot"):setVisible(isNeedReddot == true)
        if itemViewData["reddotVal"] and itemViewData["reddotVal"] > 0 then
            local labelReddotVal = btnNode:getChildByName("Img_Dot"):getChildByName("Text_Num")
            if labelReddotVal then
                labelReddotVal:setString(itemViewData["reddotVal"])
            end
        end
    end

    --packSet和panelMore面板中的子按钮状态发生变化，则也要刷新改面板的状态和显示
    if belongedPanel == "packSet" or belongedPanel == "panelMore" then
        local btnsCollect = {"loginPack", "firstRechargePack", "monthCardPack", "bankruptcyPack", "limitTimeSpecialPack"}
        if belongedPanel == "panelMore" then
            btnsCollect = {"mail", "friendRoom", "friend", "share"}
        end
        local isNeedReddot = false
        for i = 1, #btnsCollect do
            local item = self._pluginViewData[btnsCollect[i]]
            if item and item["isAvail"] == true and item["isNeedReddot"] == true then
                isNeedReddot = true
                break
            end
        end
        if belongedPanel == "packSet" then
            self._pluginViewData["packSet"]["isNeedReddot"] = isNeedReddot
            self._pluginViewData["packSet"]["pluginBtn"]:getChildByName("Img_Dot"):setVisible(isNeedReddot)
            self:refreshPluginBtnAni(self._pluginViewData["packSet"])
        elseif belongedPanel == "panelMore" then
            self._pluginViewData["more"]["isNeedReddot"] = isNeedReddot
            self._pluginViewData["more"]["pluginBtn"]:getChildByName("Img_Dot"):setVisible(isNeedReddot)
            --self:refreshPluginBtnAni(self._pluginViewData["more"])
        end
    end

    self:refreshPluginBtnAni(itemViewData)
end

function MainView:refreshPluginBtnAvailDirectly(viewNode, itemName, isAvail)
    if itemName == nil  then return end
    local itemViewData = self._pluginViewData[itemName]
    if itemViewData == nil then return end

    local belongedPanel = itemViewData["belongedPanel"]

    itemViewData["isAvail"] = isAvail
    if belongedPanel == "packSet" then
        self:refreshPanelPackSet(viewNode)
    elseif belongedPanel == "leftBar" then
        self:refreshLeftBar(viewNode)
    end

    self:refreshPluginBtnAni(itemViewData)
end

function MainView:refreshPluginBtnAvail(viewNode, itemName, pluginModel)
    if itemName == nil or pluginModel == nil then return end
    local itemViewData = self._pluginViewData[itemName]
    if itemViewData == nil then return end

    local belongedPanel = itemViewData["belongedPanel"]

    itemViewData["isAvail"] = (pluginModel:getStatusDataExtended("isPluginAvail") == true)
    if belongedPanel == "packSet" then
        self:refreshPanelPackSet(viewNode)
    elseif belongedPanel == "leftBar" then
        self:refreshLeftBar(viewNode)
    end

    self:refreshPluginBtnAni(itemViewData)
end

--spineAni由代码动态添加；frameAni在cocosstudio中静态添加
function MainView:refreshPluginBtnAni(itemViewData)
    if itemViewData == nil then
        return 
    end

    if itemViewData["btnAniType"] == nil then
        return
    end

    local pluginBtn = itemViewData["pluginBtn"]
    local nodeBtnAni = pluginBtn:getChildByName("Node_BtnAni")
    local spriteBtn = pluginBtn:getChildByName("Sprite_Btn")

    local isShowAni = false
    if itemViewData["btnAniCondition"] == "onAvail" then
        isShowAni = itemViewData["isAvail"]
    elseif itemViewData["btnAniCondition"] == "onReddot" then
        isShowAni = itemViewData["isNeedReddot"]
    elseif itemViewData["btnAniCondition"] == "onNeed" then
        isShowAni = itemViewData["isNeedBtnAni"]
    end

    if isShowAni == true then
        if itemViewData["btnAniType"] == "spineAni" then
            if nodeBtnAni == nil then
                SubViewHelper:setButtonSkeletonAni(pluginBtn, SubViewHelper.btnSpineAni[itemViewData["itemName"]])
                nodeBtnAni = pluginBtn:getChildByName("Node_BtnAni")
            end
        elseif itemViewData["btnAniType"] == "frameAni" then
            SubViewHelper:setButtonFrameAni(itemViewData["btnAniCsbPath"], nodeBtnAni)
        end

        if nodeBtnAni then nodeBtnAni:setVisible(true) end
        if spriteBtn then spriteBtn:setVisible(false) end
    else
        if nodeBtnAni then
            nodeBtnAni:stopAllActions()
            nodeBtnAni:setVisible(false)
        end
        if spriteBtn then spriteBtn:setVisible(true) end
    end
end

function MainView:showExtendedBtnPanelForAWhile()
    local viewNode = self.viewNode
    local panelPackSet = viewNode.panelPackSet
    local panelMoreBtns = viewNode.panelMoreBtns

    if self._pluginViewData["packSet"]["isAvail"] == true then
        panelPackSet:setVisible(true)
        self:adjustLeftBtnPos(true)
        TimerManager:scheduleOnceUnique("Timer_ShowExtendedBtnPanelForAWhile_PackSet", function()
            panelPackSet:setVisible(false)
            self:adjustLeftBtnPos(false)
        end, 3.0)
    end

    panelMoreBtns:setVisible(true)
    TimerManager:scheduleOnceUnique("Timer_ShowExtendedBtnPanelForAWhile_MoreBtns", function()
        panelMoreBtns:setVisible(false)
    end, 3.0)
end

function MainView:refreshBtnGoldSilverCountdown(viewNode, pluginModel)
    print("refreshBtnGoldSilverCountdown")
    local itemViewData = self._pluginViewData["goldSilver"]
	local btnNode = itemViewData["pluginBtn"]
	local labelDesc = btnNode:getChildByName("Text_Desc")

    local GoldSilverDef = import('src.app.plugins.goldsilver.GoldSilverDef')
    local goldsilverinfo = pluginModel:GetGoldSilverInfo()
    local endDate = pluginModel:GetEndData()
    dump(goldsilverinfo)
    dump(endDate)

    local function callback()
        GoldSilverModel:GoldSilverInfoReq()
    end
	if goldsilverinfo ~= nil and (goldsilverinfo.nStatusCode == GoldSilverDef.GOLDSILVER_SUCCESS) then
		if self._passcheckcoutndown == nil then
			self._passcheckcoutndown = import("src.app.plugins.timecalc.TimeCountDown").new(labelDesc, 0, endDate, 000000, 000000,callback)
			self._passcheckcoutndown:startcountdown()
		else
			self._passcheckcoutndown:resettime(0, endDate, 000000, 000000,callback)
		end
        itemViewData["isAvail"] = true
	else
        itemViewData["isAvail"] = false
	end

    self:refreshLeftBar(viewNode)
end

function MainView:refreshBtnGoldSilverCountdownCopy(viewNode, pluginModel)
    print("refreshBtnGoldSilverCountdownCopy")
    local itemViewData = self._pluginViewData["goldSilverCopy"]
	local btnNode = itemViewData["pluginBtn"]
	local labelDesc = btnNode:getChildByName("Text_Desc")

    local GoldSilverDefCopy = import('src.app.plugins.goldsilverCopy.GoldSilverDefCopy')
    local goldsilverinfo = pluginModel:GetGoldSilverInfo()
    local startDate = pluginModel:GetStartData()
    local endDate = pluginModel:GetEndData()
    dump(goldsilverinfo)
    dump(endDate)

    local function callback()
        GoldSilverModelCopy:GoldSilverInfoReq()
    end
	if goldsilverinfo ~= nil and (goldsilverinfo.nStatusCode == GoldSilverDefCopy.GOLDSILVER_SUCCESS) then
		if self._passcheckcoutndownCopy == nil then
			self._passcheckcoutndownCopy = import("src.app.plugins.timecalc.TimeCountDown").new(labelDesc, startDate, endDate, 000000, 000000,callback)
			self._passcheckcoutndownCopy:startcountdown()
		else
			self._passcheckcoutndownCopy:resettime(0, endDate, 000000, 000000,callback)
		end
        itemViewData["isAvail"] = true
	else
        itemViewData["isAvail"] = false
	end

    self:refreshLeftBar(viewNode)
end

function MainView:refreshBankruptcy(viewNode, pluginModel)
    local itemViewData = self._pluginViewData["bankruptcyPack"]
    local itemViewDataLeftBar = self._pluginViewData["bankruptcyPack_LeftBar"]

    local btnNode = itemViewData["pluginBtn"]
    local btnNodeLeftBar = itemViewDataLeftBar["pluginBtn"]

    local bShow = pluginModel:isBankruptcyBagShow()
    local leftTime = pluginModel:getLeftTimeStr()
    if not bShow or leftTime == "" then
        itemViewData["isAvail"] = false
        itemViewDataLeftBar["isAvail"] = false
        itemViewData["isNeedReddot"] = false
        itemViewDataLeftBar["isNeedReddot"] = false
        self:refreshPanelPackSet(viewNode)
        self:refreshLeftBar(viewNode)
        self:refreshPluginBtnReddot(itemViewData) --刷新红点
        self:refreshPluginBtnReddot(itemViewDataLeftBar)
        return
    end

    itemViewData["isAvail"] = true
    itemViewData["isNeedReddot"] = true --可见，则同时加上红点提示
    itemViewDataLeftBar["isNeedReddot"] = true
    btnNode:getChildByName("BF_Countdown"):setString(leftTime)
    btnNodeLeftBar:getChildByName("BF_Countdown"):setString(leftTime)
    self:refreshPanelPackSet(viewNode) --刷新是否可见和位置
    self:refreshPluginBtnReddot(itemViewData) --刷新红点
    self:refreshPluginBtnReddot(itemViewDataLeftBar)
end

function MainView:refreshBankruptcyTime(viewNode, pluginModel)
    local itemViewData = self._pluginViewData["bankruptcyPack"]
    local itemViewDataLeftBar = self._pluginViewData["bankruptcyPack_LeftBar"]
    local btnNode = itemViewData["pluginBtn"]
    local btnNodeLeftBar = itemViewDataLeftBar["pluginBtn"]

    local bShow = pluginModel:isBankruptcyBagShow()
    local leftTime = pluginModel:getLeftTimeStr()
    if not bShow or leftTime == "" then
        return
    end
    btnNode:getChildByName("BF_Countdown"):setString(leftTime)
    btnNodeLeftBar:getChildByName("BF_Countdown"):setString(leftTime)
end


function MainView:refreshRechargeBtn()
    local itemViewData = self._pluginViewData["firstRechargePack"]
    local itemViewDataLeftBar = self._pluginViewData["firstRechargePack_LeftBar"]

    itemViewData["isAvail"] = ShopModel:getStatusDataExtended("isFirstRechargeAvail") and FirstRechargeModel:isShowFirstRecharge()
    itemViewDataLeftBar["isAvail"] = itemViewData["isAvail"]
    itemViewData["isNeedReddot"] = false
    itemViewDataLeftBar["isNeedReddot"] = false
    if FirstRechargeModel:isNeedReddot() then
        itemViewData["isNeedReddot"] = true
        itemViewDataLeftBar["isNeedReddot"] = true
    end


    local itemViewDataSpecialGift = self._pluginViewData["limitTimeSpecialPack"]
    local itemViewDataSpecialGift_LeftBar = self._pluginViewData["limitTimeSpecialPack_LeftBar"]

    itemViewDataSpecialGift["isAvail"] = FirstRechargeModel:isShowSpecialGift()
    itemViewDataSpecialGift_LeftBar["isAvail"] = itemViewDataSpecialGift["isAvail"]
    itemViewDataSpecialGift["isNeedReddot"] = false
    itemViewDataSpecialGift_LeftBar["isNeedReddot"] = false
    if FirstRechargeModel:isSpecialGiftNeedReddot() then
        itemViewDataSpecialGift["isNeedReddot"] = true
        itemViewDataSpecialGift_LeftBar["isNeedReddot"] = true
    end

    self:refreshPanelPackSet(self.viewNode )
    self:refreshPluginBtnReddot(itemViewData)
    self:refreshPluginBtnReddot(itemViewDataSpecialGift)
    self:refreshPluginBtnReddot(itemViewDataLeftBar)
    self:refreshPluginBtnReddot(itemViewDataSpecialGift_LeftBar)
end

function MainView:refreshMailBtnReddot(viewNode, mailCount)
    local itemViewData = self._pluginViewData["mail"]
    itemViewData["isNeedReddot"] = (mailCount > 0)
    itemViewData["reddotVal"] = math.min(mailCount, 99)
    self:refreshPluginBtnReddot(itemViewData)
end

function MainView:refreshRechargePoolBtnRedDot()
    local itemViewData = self._pluginViewData["rechargepool"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local pluginBtn = itemViewData["pluginBtn"]
    if pluginBtn then
        local redDotNode = pluginBtn:getChildByName("Image_Dot")
        if redDotNode then
            local rechargePoolModel = require("src.app.plugins.rechargepool.RechargePoolModel"):getInstance()
            redDotNode:setVisible(rechargePoolModel:isHasAward())
        end
    end
end 

function MainView:refreshWatchVideoBtn()
    local itemViewData = self._pluginViewData["WatchVideo"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local btn = itemViewData["pluginBtn"]
    if btn then
        local leftCountNode = btn:getChildByName("Text_LeftCount")
        if leftCountNode then
            local WatchVideoTakeRewardModel = require("src.app.plugins.watchvideotakereward.WatchVideoTakeRewardModel"):getInstance()
            local str = WatchVideoTakeRewardModel:getLeftCountStr()
            leftCountNode:setString(str)
        end
    end
end

function MainView:refreshRechargeFlopCardBtn()
    local itemViewData = self._pluginViewData["rechargeFlopCard"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local btn = itemViewData["pluginBtn"]
    if btn then
        local imgDot = btn:getChildByName("Image_Dot")
        if imgDot then
            local rechargeFlopCard = require("src.app.plugins.RechargeFlopCard.RechargeFlopCardModel"):getInstance()
            imgDot:setVisible(rechargeFlopCard:isNeedShowRedDot())
        end
    end
end

function MainView:refreshWeekMonthSuperCardBtn()
    local itemViewData = self._pluginViewData["weekMonthSuperCard"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local btn = itemViewData["pluginBtn"]
    if btn then
        local imgDot = btn:getChildByName("Img_Dot")
        if imgDot then
            local WeekMonthSuperCardModel = require("src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel"):getInstance()
            imgDot:setVisible(WeekMonthSuperCardModel:isNeedReddot())
        end
    end
end

function MainView:refreshContinueRechargeBtnRedDot()
    local itemViewData = self._pluginViewData["continueRecharge"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local pluginBtn = itemViewData["pluginBtn"]
    if pluginBtn and itemViewData["checkSupport"]() then
        local redDotNode = pluginBtn:getChildByName("Image_Dot")
        if redDotNode then
            local continueRechargeModel = require("src.app.plugins.continuerecharge.ContinueRechargeModel"):getInstance()
            redDotNode:setVisible(continueRechargeModel:canExchange())
        end
    end
end

function MainView:updateTimeInterval(nTimeInterval, panelBtns, belongType)          -- belongType是左侧按钮和礼包按钮启动不同的计时器
    if tonumber(nTimeInterval) > 0 then
        if belongType == 1 then
            self._timeCount = nTimeInterval
            if self._giftTimer == nil then
                self:refreshGiftTime(self._timeCount, panelBtns)
                self._giftTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                    self._timeCount = self._timeCount - 1
                    self:refreshGiftTime(self._timeCount, panelBtns)
                end, 1.0, false)
            end
        else
            self._timeCount2 = nTimeInterval
            if self._giftTimer2 == nil then
                self:refreshGiftTime(self._timeCount2, panelBtns)
                self._giftTimer2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                    self._timeCount2 = self._timeCount2 - 1
                    self:refreshGiftTime(self._timeCount2, panelBtns)
                end, 1.0, false)
            end
        end
    else
        FirstRechargeModel:gc_GetSpecialGiftInfo()
        self:unRegisterGiftTimer()
    end
end

function MainView:refreshGiftTime(time, panelBtns)
    if time <= 0 then
         self:unRegisterGiftTimer()
         FirstRechargeModel:gc_GetSpecialGiftInfo()
    else
        local dayNum, hourNum, minutesNum, secondNum = self:formatSeconds(time)
        if not self.viewNode then return end
        panelBtns:getChildByName("Btn_LimitTimeSpecial"):getChildByName("BF_Countdown"):setString(dayNum*24+hourNum..":"..minutesNum..":"..secondNum)
    end
end

function MainView:unRegisterGiftTimer()
    if self._giftTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._giftTimer)
        self._giftTimer = nil
    end
    if self._giftTimer2 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._giftTimer2)
        self._giftTimer2 = nil
    end
end


function MainView:formatSeconds(time)
    if not time then return end

    local daySpan    = 24*60*60
    local hourSpan   = 60*60
    local dayNum     = math.floor(time / daySpan)
    local hourNum    = math.floor((time - dayNum * daySpan) / hourSpan)
    local minutesNum = math.floor((time - dayNum * daySpan - hourNum * hourSpan) / 60)
    local secondNum  = time - dayNum * daySpan - hourNum * hourSpan - minutesNum * 60
    
    if dayNum < 0     then dayNum     = 0 end
    if hourNum < 0    then hourNum    = 0 end
    if minutesNum < 0 then minutesNum = 0 end
    if secondNum < 0  then secondNum  = 0 end

    return dayNum, hourNum, minutesNum, secondNum
end

function MainView:refreshNobilityPrivilegeGiftBtn()
    local itemViewData = self._pluginViewData["NobilityPrivilegeGift"]
    local itemViewDataLeftBar = self._pluginViewData["NobilityPrivilegeGift_LeftBar"]

    itemViewData["isAvail"] = NobilityPrivilegeGiftModel:getStatusDataExtended("isNobilityPrivilegeGiftAvail")
    itemViewData["isNeedReddot"] = false
    itemViewDataLeftBar["isNeedReddot"] = false
    if NobilityPrivilegeGiftModel:isNeedReddot() then
        itemViewData["isNeedReddot"] = true
        itemViewDataLeftBar["isNeedReddot"] = true
    end

    self:refreshPanelPackSet(self.viewNode )
    self:refreshPluginBtnReddot(itemViewData)
    self:refreshPluginBtnReddot(itemViewDataLeftBar)
end

local timerSetTimingGameTip = nil
function MainView:stopRefreshTimgGameTipsTimer()
    if timerSetTimingGameTip then
        my.removeSchedule(timerSetTimingGameTip)
        timerSetTimingGameTip = nil
    end
end

function MainView:refreshTimingGameTips(viewNode)
    self:stopRefreshTimgGameTipsTimer()

    local tipNode = viewNode.nodeRoleAni:getChildByName("Img_TipBG")
    if tipNode then
        tipNode:setVisible(false)
        if cc.exports.isTimingGameSupported() then
            local tipStrings = cc.exports.getTimmingGameHallTips()
            if tipStrings ~= nil then
                local tipStringsLen = #tipStrings
                if tipStringsLen > 0 then
                    local labelNode = tipNode:getChildByName("Label_Tip")

                    local function setTipString()
                        local tipString = tipStrings[math.random(1, tipStringsLen)]
                        if not tolua.isnull(labelNode) then
                            labelNode:setString(tipString)
                        end
                    end

                    setTipString()
                    tipNode:setVisible(true)
                    timerSetTimingGameTip = my.scheduleFunc(setTipString, 5)
                end
            end
        end
    end
end

function MainView:onExit()
    self:stopRefreshTimgGameTipsTimer()
end

function MainView:setSpringFestivalView()
    if SpringFestivalModel:showSpringFestivalView() then
        if self.viewNode then
            -- 春节换大厅背景
            local imgHallBg = self.viewNode.imageHallBg
            imgHallBg:loadTexture('res/hallcocosstudio/images/jpg/Hall_MainBG_SpringFestival.jpg')
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local bgSize = cc.size(1600, 1000)
            if visibleSize.height / visibleSize.width > bgSize.height / bgSize.width then
                bgSize.width = visibleSize.height * bgSize.width / bgSize.height
                bgSize.height = visibleSize.height
            else
                bgSize.height = visibleSize.width * bgSize.height / bgSize.width
                bgSize.width = visibleSize.width
            end
            imgHallBg:setContentSize(bgSize)
        end
    end
end

function MainView:showRechargePoolBtnAni()
    local viewNode = self.viewNode
    if not viewNode then return end
    local rechargePoolBtn = self._pluginViewData["rechargepool"]["pluginBtn"]
    if not rechargePoolBtn then
        return
    end
    local action = cc.CSLoader:createTimeline("res/hallcocosstudio/rechargepool/Node_baoxiang.csb")
    if not action then return end
    rechargePoolBtn:stopAllActions()
    rechargePoolBtn:runAction(action)
    action:play("animation0", true)
end

function MainView:refreshMoreGameEntry(viewNode)
    self._pluginViewData["moregame"]["pluginBtn"]:setVisible(cc.exports.isMoreGameConfigSupported())
end

-- 刷新单个按钮显隐
function MainView:refreshPluginBtnView(viewNode, nodeName)
    local itemData = self._pluginViewData[nodeName]
    if not itemData then return end
    if itemData["checkSupport"] then
        if itemData["isAvailOnlyByCheckSupport"] == true then
            itemData["isAvail"] = itemData["checkSupport"]()
        else
            itemData["isAvail"] = itemData["isAvail"] and itemData["checkSupport"]()
        end
    end
    local visible = itemData["pluginBtn"]:isVisible()
    local needVisible = itemData["isAvail"] == true
    if visible ~= needVisible then
        itemData["pluginBtn"]:setVisible(itemData["isAvail"] == true)
        return true
    end
    return false
end

function MainView:refreshBottomBarBtnPos(viewNode)
    if viewNode == nil then return end

    local panelBtns = viewNode.panelBottomBar
    local panelMoreBtns = viewNode.panelMoreBtns
    local btnMore = self._pluginViewData["more"]["pluginBtn"]

    local btnsInfo = {
        self._pluginViewData["shop"],
        self._pluginViewData["more"],
        self._pluginViewData["safeBox"],
        self._pluginViewData["lottery"],
        self._pluginViewData["exchange"],
        self._pluginViewData["task"],
        self._pluginViewData["activity"],
        self._pluginViewData["yuleRoom"]
    }
    
    local visibleCount = 1
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            visibleCount = visibleCount + 1
        end
    end
    
    local posXStart = 53
    local distanceX = 100 * panelBtns:getContentSize().width / 860
    distanceX = distanceX * #btnsInfo / (visibleCount > 0 and visibleCount or 1)
    distanceX = math.max(math.min(distanceX, 150), 110)
    distanceX = distanceX - 5
    local curIndex = 0
    for i = 1, #btnsInfo do
        if btnsInfo[i]["isAvail"] == true then
            curIndex = curIndex + 1
            btnsInfo[i]["pluginBtn"]:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end

        if i == #btnsInfo then
            curIndex = curIndex + 1
            self._viewNode.redPacketNode:setPositionX(posXStart + (curIndex - 1) * distanceX)
            self._viewNode.yqylNode:setPositionX(posXStart + (curIndex - 1) * distanceX)
            self._viewNode.redbagPanel:setPositionX(posXStart + (curIndex - 1) * distanceX)
        end
    end

    panelMoreBtns:setPositionX(panelBtns:getPositionX() + btnMore:getPosition() - 60)
end

function MainView:refreshValuablePurchaseBtnRedDot(viewNode, isNeedRedDot)
    local itemViewData = self._pluginViewData["valuablePurchase"]
    if type(itemViewData) ~= 'table' then
        return
    end
    local pluginBtn = itemViewData["pluginBtn"]
    if pluginBtn then
        local redDotNode = pluginBtn:getChildByName("Img_Dot")
        if redDotNode then
            redDotNode:setVisible(isNeedRedDot)
        end
    end
end

function MainView:refreshPeakRankBtn(viewNode)
    local btn = viewNode.btnPeakRank
    if not btn then
        return
    end
    if not cc.exports.isPeakRankSupported() then
        btn:setVisible(false)
        return
    end
    local PeakRankModel = import('src.app.plugins.PeakRank.PeakRankModel'):getInstance()
    if not PeakRankModel:isEnable() then
        btn:setVisible(false)
        return
    end

    local redDot = btn:getChildByName('Img_Dot')
    redDot:setVisible(PeakRankModel:isNewRound())

    SubViewHelper:bindPluginToBtn(btn, 'PeakRankCtrl')
    local spriteBtn = btn:getRealNode():getChildByName('Sprite_Btn')
    spriteBtn:setVisible(false)
    local nodeAni = btn:getRealNode():getChildByName('Node_BtnAni')
    SubViewHelper:setButtonSkeletonAni(nodeAni, SubViewHelper.btnSpineAni['peakRank'])
    btn:setVisible(true)
end

function MainView:updatePeakRankBtnRedDot(viewNode)
    local btn = viewNode.btnPeakRank
    if not btn then
        return
    end
    if not cc.exports.isPeakRankSupported() then
        return
    end

    local PeakRankModel = import('src.app.plugins.PeakRank.PeakRankModel'):getInstance()
    if not PeakRankModel:isEnable() then
        return
    end

    local redDot = btn:getChildByName('Img_RedDot')
    redDot:setVisible(PeakRankModel:isNewRound())
end

return MainView