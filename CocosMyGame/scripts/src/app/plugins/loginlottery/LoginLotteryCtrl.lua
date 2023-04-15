local LoginLotteryCtrl      = class("LoginLotteryCtrl", cc.load('BaseCtrl'))
local viewCreater       	= import("src.app.plugins.loginlottery.LoginLotteryView")

local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local ExchangeCenterModel   = import("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

local json = cc.load("json").json
local StringConfig = json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/LoginLotteryString.json"))
local PlayerModel = mymodel('hallext.PlayerModel')
local UserModel = mymodel('UserModel'):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local AdvertModel          = import('src.app.plugins.advert.AdvertModel'):getInstance()

local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()

LoginLotteryCtrl.instance = nil
LoginLotteryCtrl.REWARD_TYPE = {
    SILVER      = 0,                -- 银子
    VOUCHER     = 1,                -- 兑换券
}

LoginLotteryCtrl.REWERD_STATUS = {
	NORMAL          = 0,			-- 能领奖
	HAVE_TAKEN      = 1,		    -- 已领
	NOT_EXIST       = 2,		    -- 没有该奖励
}

LoginLotteryCtrl.LOGIN_LOTTERY_ERROR = {
	LOTTERY_ERROR_USER_DRAWN		= -1,		--用户已抽
	LOTTERY_ERROR_DEVICE_DRAWN		= -2,		--设备已抽
	LOTTERY_ERROR_NO_GAMECOUNT		= -3,		--缺少对局
	LOTTERY_ERROR_CONFIG_ERROR		= -4,		--配置信息错误
	LOTTERY_ERROR_DATABASE_FAILED	= -5,		--数据库错误
	LOTTERY_ERROR_SOAP_FAILED		= -6,		--SOAP失败
	LOTTERY_ERROR_REDIS_ERROR		= -7,		--REDIS错误
    LOTTERY_ERROR_OTHERS			= -8,		--其它错误
    LOTTERY_ERROR_LACK_VIDEO_COUNT = -9 -- 没有看视频次数
}

LoginLotteryCtrl.LOGIN_LOTTERY_REWARD_ERROR = {
	REWARD_ERROR_HAVE_TAKEN		= -1,	--奖励已领
	REWARD_ERROR_NOT_EXIST		= -2,	--没有对应奖励
	REWARD_ERROR_CONFIG_ERROR	= -3,	--配置信息错误
	REWARD_ERROR_DATABASE_FAILED= -4,	--数据库操作失败
	REWARD_ERROR_SOAP_FAILED	= -5,	--SOAP失败
	REWARD_ERROR_REDIS_ERROR	= -6,	--REDIS错误
	REWARD_ERROR_OTHERS			= -7,	--其它错误
}

function LoginLotteryCtrl:onCreate(...)
    self._layerPath = "res/hallcocosstudio/loginlottery/layer_loginlottery.csb"
    self._popPath = "res/hallcocosstudio/loginlottery/node_rewardpop.csb"

    self._aniLight = {}
    
    self:addListeners()
    LoginLotteryModel:checkInfo()

    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self._viewNode = viewNode
    self:initViewNode()

    -- local info = LoginLotteryModel._info
    -- if info then
    --     local leftCount = info.nLotteryCount or 0
    --     if leftCount > 0 and info.nLotteryStatus == LoginLotteryModel.LOTTERY_STATUS.NO_GAMECOUNT then
    --         self:toastByKey("LOTTERY_ONE_MORE_GAME")
    --     end
    -- end
end

function LoginLotteryCtrl:addListeners()
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryConfig"], handler(self, self.dealConfig))
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryInfo"], handler(self, self.dealInfo))
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryDraw"], handler(self, self.onReturnLotteryDraw))
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryViaVideo"], handler(self, self.onReturnLotteryDraw))
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryReward"], handler(self, self.onReturnTakeReward))
end

function LoginLotteryCtrl:initViewNode()
    if ((not self._viewNode) or tolua.isnull(self._viewNode:getRealNode())) then return end
    self._viewNode.closeBt:addClickEventListener(handler(self, self.onClose))
    self._viewNode.helpBt:addClickEventListener(handler(self, self.onHelp))
    -- 弹出窗口
    if self._viewNode.nodePop then
        self._viewNode.nodePop:setVisible(false)
        if self._viewNode.popClose then
            local function hidePop()
                self._viewNode.nodePop:setVisible(false)
            end
            self._viewNode.popClose:addClickEventListener(hidePop)
        end
    end
    if self._viewNode.nodeResultLight then
        self._viewNode.nodeResultLight:setVisible(false)
    end
    -- 转盘按钮
    if self._viewNode.drawBt then
        self:updatePrizeWheel(1)
        local function lotteryDraw()
            my.playClickBtnSound()
            self:lotteryDraw()
        end
        self._viewNode.drawBt:addClickEventListener(lotteryDraw)
    end
    -- 领取奖励
    local function onRewardBtClicked(sender)
        my.playClickBtnSound()
        local index = sender:getTag()
        if LoginLotteryModel._config and LoginLotteryModel._config["continuousLoginConfig"] and LoginLotteryModel._config["continuousLoginConfig"]["extraReward"] then
            local rewardConfig = LoginLotteryModel._config["continuousLoginConfig"]["extraReward"]
            local needPlayBouts = rewardConfig[index]["afterBouts"]

            if self._BoutNum < needPlayBouts then
                if StringConfig and StringConfig["NEED_PLAYED_BOUTS_TIP"] then
                    local tips = string.format(StringConfig["NEED_PLAYED_BOUTS_TIP"], needPlayBouts - self._BoutNum);
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=tips,removeTime=2 }})
                    return
                end
            end
        end

        self:takeReward(index)
    end
    for i = 1, 4 do
        local bt = self._viewNode["reward"..tostring(i).."Bt"]
        repeat
            if not bt then break end
            self:setRewardBt(i, LoginLotteryCtrl.REWERD_STATUS.NOT_EXIST) -- 初始化时设置为不可用
            bt:setTag(i)
            bt:getChildByName("Node_Light"):getChildByName("Panel_5"):setSwallowTouches(false)
            bt:addClickEventListener(onRewardBtClicked)
        until true
    end
    -- 登录天数
    if self._viewNode.loginDays then
        self._viewNode.loginDays:setString(tostring(0))
    end

    -- 灯光动画
    local aniLight = cc.CSLoader:createTimeline(self._layerPath)
    if self._viewNode and not tolua.isnull(aniLight) then
        self._viewNode:runAction(aniLight)
        aniLight:play("animation_light", true)
    end

    if LoginLotteryModel._config and LoginLotteryModel._info then
        self:freshViewNode()
    end

    self._BoutNum = 0   --今天打过的局数，用于连续抽奖
    self._BoutDate = 0
    self:refreshBoutNum()
    if self._BoutDate == 0 then
        WeakenScoreRoomModel:getInstance():sendGetBoutInfoForLottery()
    end
end

function LoginLotteryCtrl:freshViewNode()
    if ((not self._viewNode) or tolua.isnull(self._viewNode:getRealNode())) then return end
    if not (LoginLotteryModel._config and LoginLotteryModel._info) then
        return
    end
    -- 隐藏弹出窗口
    if self._viewNode.nodePop then
        self._viewNode.nodePop:setVisible(false)
    end
    -- 转盘奖励
    local lotteryConfig = LoginLotteryModel._config["lotteryConfig"]
    for i = 1, #lotteryConfig do
        local part = self._viewNode["part"..tostring(i)]
        if part then
            part:setString(lotteryConfig[i]["count"])
        end
    end
    -- 抽奖按钮 次数
    if self._viewNode.drawBt then
        self:updatePrizeWheel(1)
    end
    -- 连续登录提示
    if self._viewNode.loginDays then
        self._viewNode.loginDays:setString(tostring(LoginLotteryModel._info.nContinuousLoginDays))
    end
    -- 连续登录奖励按钮
    local rewardConfig = LoginLotteryModel._config["continuousLoginConfig"]["extraReward"]
    dump(rewardConfig)
    local totalDays = rewardConfig[4].days
    local totalSilver = 0;
    
    for i = 1, 4 do
        local bt = self._viewNode["reward"..tostring(i).."Bt"]
        local status = LoginLotteryCtrl.REWERD_STATUS.NOT_EXIST
        local textCount = bt:getChildByName("Text_Count")
        if textCount then
            textCount:setString(tostring(rewardConfig[i].count))
        end
        totalSilver = totalSilver + rewardConfig[i].count
        local textDay = bt:getChildByName("Text_Days")
        textDay:setString(string.format(StringConfig.LOGIN_DAYS,rewardConfig[i].days))
        repeat
            if not bt then break end
            if (LoginLotteryModel._info.nDays[i] == rewardConfig[i].days) then
                status = LoginLotteryCtrl.REWERD_STATUS.HAVE_TAKEN
                if (LoginLotteryModel._info.bTakes[i] < 1) then
                    status = LoginLotteryCtrl.REWERD_STATUS.NORMAL
                end
            end
            self:setRewardBt(i, status)
        until true
    end
    self._viewNode.loginTip:setString(string.format(StringConfig.LOGIN_REWARD_TIP,totalDays,totalSilver))


    --贵族特权增加
    for i = 1, 4 do
        local bt = self._viewNode["reward"..tostring(i).."Bt"]
        local panelNobilityPrivilege = bt:getChildByName("Panel_NobilityPrivilege")
        panelNobilityPrivilege:setVisible(false)
    end
    self._viewNode.lotteryMainPanel:getChildByName("Panel_Lottery"):getChildByName("Panel_NobilityPrivilege"):setVisible(false)
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end
    if NobilityPrivilegeModel:isAlive() then
        for i = 4, 1,-1 do
            local bt = self._viewNode["reward"..tostring(i).."Bt"]
            local panelNobilityPrivilege = bt:getChildByName("Panel_NobilityPrivilege")
            panelNobilityPrivilege:setVisible(true)

            local  nNobilityLevelList= nobilityPrivilegeConfig.nobilityLevelList
            for u = #nNobilityLevelList,1,-1 do
                local nPrivilegeDetail = nNobilityLevelList[u].privilegeDetail
                for v=1,#nPrivilegeDetail do
                    for x, y in pairs(nobilityPrivilegeConfig.privilegeList) do
                        if nPrivilegeDetail[v].privilegeID == y.privilegeID then
                            if y.privilegeType == 3 and y.showValue[1] and y.showValue[1] == rewardConfig[i].days then
                                local bt = self._viewNode["reward"..tostring(i).."Bt"]
                                bt:getChildByName("Panel_NobilityPrivilege"):getChildByName("Text_NobilityPrivilege"):setString("贵\n族\n"..(u-1).."\n翻\n倍")
                            end
                            if y.privilegeType == 4 then
                                self._viewNode.lotteryMainPanel:getChildByName("Panel_Lottery"):getChildByName("Panel_NobilityPrivilege"):getChildByName("Text_NobilityPrivilege"):setString("贵族"..(u-1).."翻倍")
                            end
                        end
                    end
                end
            end
        end
        self._viewNode.lotteryMainPanel:getChildByName("Panel_Lottery"):getChildByName("Panel_NobilityPrivilege"):setVisible(true)
        
        local bOpen, bUnlock, nLevel, nCount = NobilityPrivilegeModel:isAddLotteryCount()
        local strMsg = ""
        if bOpen then
            strMsg = "贵族" .. tostring(nLevel) .. "可增加每日转盘" .. tostring(nCount) .. "次"
        else
            strMsg = "每日转盘抽大奖~"
        end
        self._viewNode.lotteryMainPanel:getChildByName("Text_3"):setString(strMsg)
    end
end

--[Comment]
-- bDraw bool 转盘是否可用
-- nCount int 转盘可用次数
function LoginLotteryCtrl:setLottery(bDraw, nCount)
    if ((not self._viewNode) or tolua.isnull(self._viewNode:getRealNode())) then return end
    local aniPath = "res/hallcocosstudio/loginlottery/zhuanpan_jingtai.csb"
    if self._viewNode.drawBt then
        local bEnable = nCount>0 and true or false
        self._viewNode.drawBt:setEnabled(bEnable)
        self._viewNode.drawBt:setBright(bEnable)
        if bDraw then
            if self._viewNode.aniGobt then
                self._viewNode.aniGobt:setVisible(true)
            end
            if tolua.isnull(self._aniGobt) then
                self._aniGobt = cc.CSLoader:createTimeline(aniPath)
                self._viewNode:runAction(self._aniGobt)
                self._aniGobt:play("animation0", true)
            end
        else
            if self._viewNode.aniGobt then
                self._viewNode.aniGobt:setVisible(false)
            end
            if not tolua.isnull(self._aniGobt) then
                self._viewNode:stopAction(self._aniGobt)
            end
        end
    end
    if self._viewNode.drawText then
        local nTotalCount = nCount
        if LoginLotteryModel._info.nTotalFreeLotteryCount and LoginLotteryModel._info.nTotalFreeLotteryCount >= nCount then
            nTotalCount = LoginLotteryModel._info.nTotalFreeLotteryCount
        end
        local text = string.format("免费%d/%d", nTotalCount - nCount, nTotalCount)
        self._viewNode.drawText:setString(text)
    end
end

-- nType: 0 - 直接禁用; 非0 - 按配置和数据确定
function LoginLotteryCtrl:updatePrizeWheel(nType)
    if ((not self._viewNode) or tolua.isnull(self._viewNode:getRealNode())) then return end
    local aniPath = "res/hallcocosstudio/loginlottery/zhuanpan_jingtai.csb"
    local bEnable = true
    local bDraw = true
    if self._viewNode.imgWatchVideo then
        self._viewNode.imgWatchVideo:setVisible(false)
    end
    if self._viewNode.drawText then
        self._viewNode.drawText:setVisible(false)
    end
    if nType == 0 then
        bEnable = false
        bDraw = false
    else
        local info = LoginLotteryModel:getInfo()
        local config = LoginLotteryModel:getConfig()
        if type(info) == 'table' and type(config) == 'table' then
            if info.nLotteryCount > 0 then -- 还有免费抽奖次数
                if self._viewNode.drawText then 
                    local diff = info.nTotalFreeLotteryCount - info.nLotteryCount
                    diff = math.min(diff, info.nTotalFreeLotteryCount)
                    self._viewNode.drawText:setString(string.format("免费%d/%d", diff, info.nTotalFreeLotteryCount))
                    self._viewNode.drawText:setVisible(true)
                end
            else
                local videoCount = info.nVideoCount
                local maxVideoCount = config.maxAdvertVideoCount or 0
                if videoCount < maxVideoCount and LoginLotteryModel:isSupportAdvertVideo() then -- 可以通过看视频抽奖
                    if self._viewNode.imgWatchVideo then
                        self._viewNode.imgWatchVideo:setVisible(true)
                    end
                else -- 显示回"免费N/N"
                    if self._viewNode.drawText then 
                        local diff = info.nTotalFreeLotteryCount - info.nLotteryCount
                        diff = math.min(diff, info.nTotalFreeLotteryCount)
                        self._viewNode.drawText:setString(string.format("免费%d/%d", diff, info.nTotalFreeLotteryCount))
                        self._viewNode.drawText:setVisible(true)
                    end
                    bEnable = true -- 让按钮可以点击
                    bDraw = false
                end
            end
        else
            bEnable = false
            bDraw = false
        end
    end
    if self._viewNode.drawBt then
        self._viewNode.drawBt:setEnabled(bEnable)
        self._viewNode.drawBt:setBright(bEnable)
        if bDraw then
            if self._viewNode.aniGobt then
                self._viewNode.aniGobt:setVisible(true)
            end
            if tolua.isnull(self._aniGobt) then
                self._aniGobt = cc.CSLoader:createTimeline(aniPath)
                self._viewNode:runAction(self._aniGobt)
                self._aniGobt:play("animation0", true)
            end
        else
            if self._viewNode.aniGobt then
                self._viewNode.aniGobt:setVisible(false)
            end
            if not tolua.isnull(self._aniGobt) then
                self._viewNode:stopAction(self._aniGobt)
            end
        end
    end
end

--[Comment]
-- nIndex int (1-4)
-- bAvailable bool (true,false)
function LoginLotteryCtrl:setRewardBt(nIndex, nStatus)
    if ((not self._viewNode) or tolua.isnull(self._viewNode:getRealNode())) then return end
    local bt = self._viewNode["reward"..tostring(nIndex).."Bt"]
    if not bt then return end
    local mask = bt:getChildByName("Img_Mask")
    local light = bt:getChildByName("Img_Light")
    local AniNode = bt:getChildByName("Node_Light")
    if (LoginLotteryCtrl.REWERD_STATUS.NORMAL == nStatus) then
        bt:setEnabled(true)
        if light then light:setVisible(true) end
        if mask then mask:setVisible(false) end
        if AniNode then self:showLightAni(AniNode,nIndex,true) end
    elseif (LoginLotteryCtrl.REWERD_STATUS.HAVE_TAKEN == nStatus) then
        bt:setEnabled(false)
        if light then light:setVisible(false) end
        if mask then mask:setVisible(true) end
        if AniNode then self:showLightAni(AniNode,nIndex,false) end
    else
        bt:setEnabled(false)
        if light then light:setVisible(false) end
        if mask then mask:setVisible(false) end
        if AniNode then self:showLightAni(AniNode,nIndex,false) end
    end
end

--[Comment]
-- 配置回调处理
function LoginLotteryCtrl:dealConfig()
    print("LoginLotteryCtrl:dealConfig")
    self:freshViewNode()
end

--[Comment]
-- 信息回调处理
function LoginLotteryCtrl:dealInfo()
    print("LoginLotteryCtrl:dealInfo")
    self:freshViewNode()
    if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) and self._viewNode:getRealNode():getParent() then
        local info = LoginLotteryModel:getInfo()
        local leftCount = info.nLotteryCount or 0
        if leftCount > 0 and info.nLotteryStatus == LoginLotteryModel.LOTTERY_STATUS.NO_GAMECOUNT then
            -- self:toastByKey("LOTTERY_ONE_MORE_GAME")
            self:tipGotoPlay()
        end
    end
end

--[Comment]
-- 抽奖
function LoginLotteryCtrl:lotteryDraw()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = LoginLotteryModel:getInfo()
    local config = LoginLotteryModel:getConfig()
    if (not config) or (not info) then 
        return 
    end

    if self._lotteryWaitServer then
        self:toastByKey("WAITFOR_SERVER", 1)
        return
    end

    local lotteryManner = 0
    if info.nLotteryCount > 0 then
        if info.nLotteryStatus == LoginLotteryModel.LOTTERY_STATUS.NO_GAMECOUNT then
            -- self:toastByKey("LOTTERY_ONE_MORE_GAME")
            self:tipGotoPlay()
            return
        end
        lotteryManner = 1 -- 使用免费次数
    else
        local videoCount = info.nVideoCount
        local maxVideoCount = config.maxAdvertVideoCount or 0
        if videoCount < maxVideoCount and LoginLotteryModel:isSupportAdvertVideo() then -- 可以通过看视频抽奖
            lotteryManner = 2
        end
    end
    if lotteryManner == 0 then
        self:toastByKey("LOTTERY_NOT_AVAILABLE")
        return
    end
    if lotteryManner == 1 then
        self:updatePrizeWheel(0) -- 禁用
        self._lotteryWaitServer = true
        my.scheduleOnce(function()
            if self._lotteryWaitServer then
                self:updatePrizeWheel(1)
            end
            self._lotteryWaitServer = false
        end, 8)
        LoginLotteryModel:onLoginLotteryDraw()
    elseif lotteryManner == 2 then
        ComEvtTrkingModel:initWatchVideoEventInfo(ComEvtTrkingModel.WATCH_VIDEO_SCENE.LOGIN_LOTTERY)
        AdvertModel:ShowVideoAd(function (code, msg)
            print("[INFO] LoginLotteryCtrl, watch-video, code = ", code)
            ComEvtTrkingModel:watchVideoCallback(code, msg)
            if code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then
                LoginLotteryModel:onLoginLotteryViaVideo()
            elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_FAIL then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_DIMISS then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            end
        end)
        -- test
        -- LoginLotteryModel:onLoginLotteryViaVideo()
    end
end

--[Comment]
-- 抽奖回调
function LoginLotteryCtrl:onReturnLotteryDraw(params)
    print("LoginLotteryCtrl:onReturnLotteryDraw")
    local dataMap = params and params.value
    if dataMap == nil then
        print("dataMap is nil")
        return
    end

    -- 播放动画，展示奖励，刷新用户银两数据 或者提示错误
    -- 根据抽奖结果更新info缓存
    if dataMap.nResult >= 0 then
        self:updatePrizeWheel(1)
        self:updateUserGameInfo(5)
        if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) and self._viewNode.lottery then
        
            local lotteryConfig = LoginLotteryModel._config["lotteryConfig"]
            local lotteryType = nil
            local lotteryCount = nil
            local lotteryIsDouble = nil
            for i = 1, #lotteryConfig do
                if lotteryConfig[i]["part"] == dataMap.nResult then
                    lotteryType = lotteryConfig[i]["type"]
                    lotteryCount = lotteryConfig[i]["count"]
                    lotteryIsDouble = dataMap.isDouble > 0
                    break
                end
            end
            local extraRewards = {}
            if LoginLotteryModel._config["extraRewards"] then
                extraRewards = clone(LoginLotteryModel._config["extraRewards"][tostring(dataMap.nExtraRewardIdx)] or {})
            end

            local nAngle = 60 * dataMap.nResult
            local rotate = cc.RotateBy:create(6, 360 * 4 + nAngle)
            local easeSineOut = cc.EaseSineOut:create(cc.EaseSineOut:create(rotate))
            
            local function callback()
                if self._viewNode and not tolua.isnull(self._aniDraw) then
                    self._viewNode:stopAction(self._aniDraw)
                end

                local sequence = cc.Sequence:create(cc.DelayTime:create(0.12),cc.FadeOut:create(0.03),cc.DelayTime:create(0.12),cc.FadeIn:create(0.03))
                local actTwink = cc.RepeatForever:create(sequence)
                if self._viewNode.nodeResultLight then
                    self._viewNode.nodeResultLight:setVisible(true)
                    self._viewNode.nodeResultLight:runAction(actTwink)
                end
                
                local nType = lotteryType == 0 and 1 or 2 
                local nCount = lotteryIsDouble and lotteryCount*2 or lotteryCount
                local rewardList = {}
                table.insert(rewardList, {nType = nType, nCount = nCount})
                if LoginLotteryModel:isSupportAdvertVideo() and #extraRewards > 0 then
                    for k, v in pairs(extraRewards) do -- 一般是两个
                        if k <= 1 then
                            table.insert(rewardList, 1, { nType = v.type, nCount = v.count, extra = true })
                        else
                            table.insert(rewardList, { nType = v.type, nCount = v.count, extra = true })
                        end
                    end
                    my.informPluginByName({pluginName = "RewardTipCtrlEx", params = {data = rewardList, extraRewardIdx = dataMap.nExtraRewardIdx,
                        callback = function ()
                            LoginLotteryModel:clearExtraReward() -- callback 奖励界面退出时调用
                        end
                    }})
                else
                    LoginLotteryModel:clearExtraReward()
                    my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
                end
                self._viewNode.drawBt:setEnabled(true)
                self._isPlayingLotteryAni = false
            end
            local sequence = cc.Sequence:create(easeSineOut, cc.CallFunc:create(callback))
            self._viewNode.lottery:setRotation(0)   -- 转转盘之前先将角度归位
            self._viewNode.lottery:runAction(sequence)
            self._viewNode.drawBt:setEnabled(false)
            self._isPlayingLotteryAni = true
        end
        self._lotteryWaitServer = false
    else
        local ERRORS = LoginLotteryCtrl.LOGIN_LOTTERY_ERROR
        local STATUS = LoginLotteryModel.LOTTERY_STATUS

        if dataMap.nResult == ERRORS.LOTTERY_ERROR_USER_DRAWN then
            self:toastByKey("USER_DRAWN")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_DEVICE_DRAWN then
            self:toastByKey("DEVICE_DRAWN")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_NO_GAMECOUNT then
            -- self:toastByKey("LOTTERY_ONE_MORE_GAME")
            self:tipGotoPlay()
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_CONFIG_ERROR then
            self:toastByKey("CONFIG_ERROR")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_DATABASE_FAILED then
            self:toastByKey("DATABASE_ERROR")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_SOAP_FAILED then
            self:toastByKey("SOAP_FAILED")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_REDIS_ERROR then
            self:toastByKey("REDIS_ERROR")
        elseif dataMap.nResult == ERRORS.LOTTERY_ERROR_LACK_VIDEO_COUNT then
            self:toastByKey("LACK_VIDEO_COUNT")
        else
            self:toastByKey("OTHER_ERROR")
        end
        self._lotteryWaitServer = false
        self._isPlayingLotteryAni = false
    end
end

--[Comment]
-- 显示奖励结果
function LoginLotteryCtrl:showLotteryResult(nType, nCount, bDouble, nTipDays)
    if self._viewNode.nodePop then
        if not tolua.isnull(self._aniPop) then
            self._viewNode.nodePop:stopAction(self._aniPop)
        end
        if tolua.isnull(self._aniPop) then
            self._aniPop = cc.CSLoader:createTimeline(self._popPath)
        end
        if not tolua.isnull(self._aniPop) then
            self._viewNode.nodePop:runAction(self._aniPop)
            self._aniPop:play("animation_popup", false)
        end
        -- ntype deal
        if self._viewNode.popSilverIcon then
            self._viewNode.popSilverIcon:setVisible(nType == 0)
        end
        if self._viewNode.popVoucherIcon then
            self._viewNode.popVoucherIcon:setVisible(nType > 0)
        end
        -- count
        local popText = nil
        popText = string.format(nType > 0 and StringConfig.POP_REWARD_VOUCHER_TEXT or StringConfig.POP_REWARD_SILVER_TEXT , nCount)

        self._viewNode.popText:setString(popText)
        -- double
        self._viewNode.popDouble:setVisible(bDouble)
        -- tip days
        if nTipDays and nTipDays > 0 then
            self._viewNode.popTipImg:setVisible(true)
            self._viewNode.popTipText:setVisible(true)
            self._viewNode.popTipText:setString(string.format(StringConfig.POP_LOGIN_TIP, nTipDays))
        else
            self._viewNode.popTipImg:setVisible(false)
            self._viewNode.popTipText:setVisible(false)
        end
        self._viewNode.nodePop:setVisible(true)
    end
end

--[Comment]
-- 领取奖励
function LoginLotteryCtrl:takeReward(nIndex) -- 参数:领取的哪个奖励
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end
    if (not LoginLotteryModel._config) or (not LoginLotteryModel._info) then return end

    if self._rewardWaitServer then
        self:toastByKey("WAITFOR_SERVER", 1)
        return
    end
    self:setRewardBt(nIndex, LoginLotteryCtrl.REWERD_STATUS.HAVE_TAKEN) -- 设置领取按钮不可用
    self._rewardWaitServer = true
    my.scheduleOnce(function()
        if self._rewardWaitServer then
            self:setRewardBt(nIndex, LoginLotteryCtrl.REWERD_STATUS.NORMAL)
        end
        self._rewardWaitServer = false
    end, 1)

    local rewardConfig = LoginLotteryModel._config["continuousLoginConfig"]["extraReward"]
    local bRewardAvailable = (LoginLotteryModel._info.nDays[nIndex] == rewardConfig[nIndex]["days"]) and (LoginLotteryModel._info.bTakes[nIndex] < 1)

    if bRewardAvailable then
        LoginLotteryModel:onLoginLotteryReward(rewardConfig[nIndex]["days"])
    else
        self:freshViewNode()
        self:toastByKey("REWARD_NOT_AVAILABLE")
    end
end

--[Comment]
-- 领奖回调
function LoginLotteryCtrl:onReturnTakeReward(params)
    print("LoginLotteryCtrl:onReturnTakeReward")
    local dataMap = params and params.value
    if dataMap == nil then
        print("dataMap is nil")
        return
    end

    -- 播放动画，展示奖励，刷新用户银两数据 或者提示错误
    if dataMap.nResult > 0 then
        self:updateUserGameInfo()
        local rewardConfig = LoginLotteryModel._config["continuousLoginConfig"]["extraReward"]
        local rewardType = nil
        local rewardCount = nil
        local rewardIsDouble = nil
        local rewardTipDays = dataMap.nResult
        local nIndex = 0
        for i = 1, 4 do
            if rewardConfig[i]["days"] == dataMap.nResult then
                nIndex = i
                rewardType = rewardConfig[i]["type"]
                rewardCount = rewardConfig[i]["count"]
                rewardIsDouble = dataMap.isDouble > 0
                break
            end
        end
        if rewardCount then
            local nType = rewardType == 0 and 1 or 2 
            local nCount = rewardIsDouble and rewardCount*2 or rewardCount
            local rewardList = {}
            table.insert(rewardList, {nType = nType, nCount = nCount})

            my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
        else
            print("lottery reward is not sync to config!!!!")
        end

        self._rewardWaitServer = false
        self:setRewardBt(nIndex, LoginLotteryCtrl.REWERD_STATUS.HAVE_TAKEN)
    else
        local ERRORS = LoginLotteryCtrl.LOGIN_LOTTERY_REWARD_ERROR

        if dataMap.nResult == ERRORS.REWARD_ERROR_HAVE_TAKEN then
            self:toastByKey("REWARD_HAVE_TAKEN")
        elseif dataMap.nResult == ERRORS.REWARD_ERROR_NOT_EXIST then
            self:toastByKey("REWARD_NOT_EXISTS")
        elseif dataMap.nResult == ERRORS.REWARD_ERROR_CONFIG_ERROR then
            self:toastByKey("CONFIG_ERROR")
        elseif dataMap.nResult == ERRORS.REWARD_ERROR_DATABASE_FAILED then
            self:toastByKey("DATABASE_ERROR")
        elseif dataMap.nResult == ERRORS.REWARD_ERROR_SOAP_FAILED then
            self:toastByKey("SOAP_FAILED")
        elseif dataMap.nResult == ERRORS.REWARD_ERROR_REDIS_ERROR then
            self:toastByKey("REDIS_ERROR")
        else
            self:toastByKey("OTHER_ERROR")
        end
        
        self._rewardWaitServer = false
    end
    
end

--[Comment]
-- toast提示
function LoginLotteryCtrl:toastByKey(strKey, time)
    if StringConfig or StringConfig[strKey] then
        if not time then time = 2 end
        my.informPluginByName({pluginName='TipPlugin',params={tipString=StringConfig[strKey],removeTime=time}})
    end
end

--[Comment]
-- 刷新用户银子
function LoginLotteryCtrl:updateUserGameInfo(nWait)
    local delay = 1.5
    if nWait then
        delay = delay + nWait
    end
    my.scheduleOnce(function()
        ExchangeCenterModel:getTicketNum()
        PlayerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    end, delay)
end

--[Comment]
--转动光线
function LoginLotteryCtrl:showLightAni(btn,index,isShow)
    if self._aniLight[index] then
        btn:stopAction(self._aniLight[index])
    end
    local path = "res/hallcocosstudio/loginlottery/node_anilight.csb"
    if isShow then
        btn:setVisible(true)
        self._aniLight[index] = cc.CSLoader:createTimeline(path)
        btn:runAction(self._aniLight[index])
        self._aniLight[index]:play("animation0",true)
    else
        btn:setVisible(false)
    end
end

function LoginLotteryCtrl:onClose()
    if self._lotteryWaitServer or self._isPlayingLotteryAni then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = '您正在抽奖,请您耐心等待抽奖结果',removeTime=1}})        
        return
    end

    my.playClickBtnSound()
    self:removeSelfInstance()

    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    PluginProcessModel:PopNextPlugin()

    if self._timer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)
        self._timer = nil
    end
end

function LoginLotteryCtrl:onHelp()
    my.informPluginByName({pluginName = "LoginLotteryRuleCtrl"})
end

function LoginLotteryCtrl:refreshBoutNum()
    self._BoutNum, self._BoutDate = WeakenScoreRoomModel:onGetBoutInfo()
end

function LoginLotteryCtrl:onKeyBack()
    if self._lotteryWaitServer or self._isPlayingLotteryAni then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = '您正在抽奖,请您耐心等待抽奖结果',removeTime=1}})        
        return
    end
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    PluginProcessModel:stopPluginProcess()
    LoginLotteryCtrl.super.onKeyBack(self)
end

function LoginLotteryCtrl:tipGotoPlay()
    local tipContent = StringConfig and StringConfig["LOTTERY_ONE_MORE_GAME"] or ""
    my.informPluginByName( {
        pluginName = "SureDialog",
        params =
        {
            tipContent  = tipContent,
            closeBtVisible = true,
            forbidKeyBack  = true,
            okBtTitle = "去游戏",
            onOk = function()
                local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
                HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})        
            end
        }
    } )
end

return LoginLotteryCtrl