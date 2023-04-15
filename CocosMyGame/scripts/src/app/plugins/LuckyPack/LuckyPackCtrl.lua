local LuckyPackCtrl = class('LuckyPackCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.LuckyPack.LuckyPackView')
local LuckyPackModel = import('src.app.plugins.LuckyPack.LuckyPackModel'):getInstance()
local LuckyPackDef = require('src.app.plugins.LuckyPack.LuckyPackDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

-- 创建实例
function LuckyPackCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:initialListenTo()
    self:initialUI()
    self:initialBtnClick()
    self:playInitAnimation()
end

-- 注册监听
function LuckyPackCtrl:initialListenTo()
    self:listenTo(LuckyPackModel, LuckyPackDef.LUCKY_PACK_QUERY_STATE_RSP, handler(self,self.updateState))
    self:listenTo(LuckyPackModel, LuckyPackDef.LUCKY_PACK_SAVE_LOTTERY_INFO_RSP, handler(self,self.OnSaveLotteryInfo))
    self:listenTo(LuckyPackModel, LuckyPackDef.LUCKY_PACK_AWARD_RSP, handler(self,self.buySuccess))
end

-- 初始化界面
function LuckyPackCtrl:initialUI()
    if self._viewNode == nil then return end

    local viewNode = self._viewNode
    local lotteryInfo = LuckyPackModel:getLotteryInfo()
    local buyTotalSliver = LuckyPackModel:getTotalSliver()
    local discount = LuckyPackModel:getDiscount()

    if cc.exports.isSpringFestivalType() == 1 then
        viewNode.imgCjlb:setVisible(true)
        viewNode.imgXylb:setVisible(false)
    else
        viewNode.imgCjlb:setVisible(false)
        viewNode.imgXylb:setVisible(true)
    end

    viewNode.imgGx:setVisible(false)
    viewNode.txtLotterySiliver:setVisible(false)
    viewNode.imDiscount:setVisible(false)
    viewNode.imgChouJi:setVisible(false)
    viewNode.txtBuyyed:setVisible(false)
    viewNode.panelCancelLine:setVisible(false)
    viewNode.txtOriginalPrice:setVisible(false)
    viewNode.txtSpecialPrice:setVisible(false)
    viewNode.imgTitleBuy:setVisible(false)
    viewNode.txtTitleOpen1:setVisible(false)
    viewNode.txtTitleOpen2:setVisible(false)
    viewNode.txtTitleOpen3:setVisible(false)

    local status = self:getStatus()
    if status == LuckyPackDef.LUCKY_PACK_STATUS_BUYYED then
        --幸运礼包状态：已购买
        viewNode.imgGx:setVisible(true)
        viewNode.txtLotterySiliver:setVisible(true)
        viewNode.imDiscount:setVisible(true)
        viewNode.txtBuyyed:setVisible(true)
        viewNode.imgTitleBuy:setVisible(true)
        viewNode.btnBuy:setTouchEnabled(false)
        viewNode.btnBuy:setBright(false)
        if lotteryInfo then
            local totalSiliver = lotteryInfo.buySliver + lotteryInfo.awardSliver
            viewNode.txtLotterySiliver:setString(totalSiliver.."两")            
        elseif buyTotalSliver and buyTotalSliver ~= 0 then
            viewNode.txtLotterySiliver:setString(buyTotalSliver.."两")
        end

        if lotteryInfo then
            local disC1, disC2= math.modf(lotteryInfo.discount / 10)
            disC2 = disC2 * 10
            viewNode.txtDiscount:setString(disC1.."."..disC2.."折")
        elseif discount and discount ~= 0 then
            local disC1, disC2= math.modf(discount / 10)
            disC2 = disC2 * 10
            viewNode.txtDiscount:setString(disC1.."."..disC2.."折")
        end
    else
        viewNode.btnBuy:setTouchEnabled(true)
        viewNode.btnBuy:setBright(true)
        if status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_LOTTERY then
            --幸运礼包状态：待抽取
            viewNode.imgChouJi:setVisible(true)
            viewNode.txtTitleOpen1:setVisible(true)
            viewNode.txtTitleOpen2:setVisible(true)
            viewNode.txtTitleOpen3:setVisible(true)
        else
            --幸运礼包状态：待购买
            viewNode.imgGx:setVisible(true)
            viewNode.txtLotterySiliver:setVisible(true)
            viewNode.imDiscount:setVisible(true)
            viewNode.panelCancelLine:setVisible(true)
            viewNode.txtOriginalPrice:setVisible(true)            
            viewNode.txtSpecialPrice:setVisible(true)
            viewNode.imgTitleBuy:setVisible(true)
            local totalSiliver = lotteryInfo.buySliver + lotteryInfo.awardSliver
            local disC1, disC2= math.modf(lotteryInfo.discount / 10)
            disC2 = disC2 * 10
            viewNode.txtLotterySiliver:setString(totalSiliver.."两")
            viewNode.txtDiscount:setString(disC1.."."..disC2.."折")
            viewNode.txtOriginalPrice:setString("原价："..lotteryInfo.originalPrice.."元")
            viewNode.txtSpecialPrice:setString(lotteryInfo.specialPrice.."元购买")
        end
    end    
end

-- 注册点击事件
function LuckyPackCtrl:initialBtnClick()
    local viewNode = self._viewNode
    viewNode.btnBuy:addClickEventListener(handler(self, self.onClickLotteryOrBuy))
    viewNode.btnClose:addClickEventListener(handler(self, self.onClickClose))
end

-- 播放主界面进入出现动画
function LuckyPackCtrl:playHbbgEnterAnimation()
    if self._viewNode == nil or self._viewNode.nodeHbbg == nil then return end

    local aniFileHbbg = "res/hallcocosstudio/LuckyPack/hbbg.csb"
    local aniNodeHbbg = self._viewNode.nodeHbbg
    aniNodeHbbg:stopAllActions()
    local actionHbbg = cc.CSLoader:createTimeline(aniFileHbbg)
    if not tolua.isnull(actionHbbg) then
        aniNodeHbbg:runAction(actionHbbg)
        actionHbbg:play("chuxian", false)
    end
end

-- 播放主界面循环动画
function LuckyPackCtrl:playHbbgRunningAnimation()
    if self._viewNode == nil or self._viewNode.nodeHbbg == nil then return end

    local aniFileHbbg = "res/hallcocosstudio/LuckyPack/hbbg.csb"
    local aniNodeHbbg = self._viewNode.nodeHbbg
    aniNodeHbbg:stopAllActions()
    local actionHbbg = cc.CSLoader:createTimeline(aniFileHbbg)
    if not tolua.isnull(actionHbbg) then
        aniNodeHbbg:runAction(actionHbbg)
        actionHbbg:play("xunhuan", true)
    end
end

-- 播放主界面退出动画
function LuckyPackCtrl:playHbbgExitAnimation()
    if self._viewNode == nil or self._viewNode.nodeHbbg == nil then return end

    local aniFileHbbg = "res/hallcocosstudio/LuckyPack/hbbg.csb"
    local aniNodeHbbg = self._viewNode.nodeHbbg
    aniNodeHbbg:stopAllActions()
    local actionHbbg = cc.CSLoader:createTimeline(aniFileHbbg)
    if not tolua.isnull(actionHbbg) then
        aniNodeHbbg:runAction(actionHbbg)
        actionHbbg:play("guanbi", false)
    end
end

-- 播放红包进入动画
function LuckyPackCtrl:playHbEnterAnimation()
    if self._viewNode == nil or self._viewNode.nodeBg == nil then return end

    local aniFileHb = "res/hallcocosstudio/LuckyPack/hb.csb"
    local aniNodeHb = self._viewNode.nodeBg
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("chuxian", false)
    end
end

-- 播放红包停留循环动画
function LuckyPackCtrl:playHbStayAnimation()
    if self._viewNode == nil or self._viewNode.nodeBg == nil then return end

    local aniFileHb = "res/hallcocosstudio/LuckyPack/hb.csb"
    local aniNodeHb = self._viewNode.nodeBg
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("hb1xh", true)
    end
end

-- 播放红包拆开动画
function LuckyPackCtrl:playHbOpenAnimation()
    if self._viewNode == nil or self._viewNode.nodeBg == nil then return end

    local aniFileHb = "res/hallcocosstudio/LuckyPack/hb.csb"
    local aniNodeHb = self._viewNode.nodeBg
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("hb1t2", false)
    end
end

-- 播放红包拆开后循环动画
function LuckyPackCtrl:playHbShowAnimation()
    if self._viewNode == nil or self._viewNode.nodeBg == nil then return end

    local aniFileHb = "res/hallcocosstudio/LuckyPack/hb.csb"
    local aniNodeHb = self._viewNode.nodeBg
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("hb3cx", true)
    end
end

-- 播放红包退出动画
function LuckyPackCtrl:playHbExitAnimation()
    if self._viewNode == nil or self._viewNode.nodeBg == nil then return end

    local aniFileHb = "res/hallcocosstudio/LuckyPack/hb.csb"
    local aniNodeHb = self._viewNode.nodeBg
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("guanbi", false)
    end
end

-- 播放打开插件初始化动画
function LuckyPackCtrl:playInitAnimation()
    local dtDelay = 0
    local status = self:getStatus()

    self._viewNode.btnBuy:setTouchEnabled(false)
    self._viewNode:stopAllActions()

    -- 播放主界面进入出现动画
    self:playHbbgEnterAnimation()

    -- 播放红包进入动画
    if status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_LOTTERY then
        self:playHbEnterAnimation()
        dtDelay = 0.8
    end

    -- 播放主界面循环动画
    my.scheduleOnce(function()
        self:playHbbgRunningAnimation()
    end, 1.2)

    -- 播放红包拆开后循环动画或者拆开前停留动画
    my.scheduleOnce(function()
        if status == LuckyPackDef.LUCKY_PACK_STATUS_BUYYED or status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_BUY then
            self:playHbShowAnimation()
        else
            self:playHbStayAnimation()
        end
        if self._viewNode and self._viewNode.btnBuy then
            self._viewNode.btnBuy:setTouchEnabled(true)
        end
    end, dtDelay)    
end

-- 获取幸运礼包状态
function LuckyPackCtrl:getStatus()
    local lotteryInfo = LuckyPackModel:getLotteryInfo()
    local curBuyState = LuckyPackModel:getCurBuyState()
    local maxLotteryTime = LuckyPackModel:getMaxLotteryTime()

    if LuckyPackModel:getState() >= maxLotteryTime or curBuyState == 1 then
        --幸运礼包状态：已购买
        return LuckyPackDef.LUCKY_PACK_STATUS_BUYYED
    else        
        if lotteryInfo ~= nil then
            --幸运礼包状态：待购买
            return LuckyPackDef.LUCKY_PACK_STATUS_WAIT_BUY
        else
            --幸运礼包状态：待抽取
            return LuckyPackDef.LUCKY_PACK_STATUS_WAIT_LOTTERY
        end
    end
end

-- 更新抽奖状态
function LuckyPackCtrl:updateState()
    -- 重新刷新UI
    self:initialUI()

    -- 播放红包拆开后循环动画或者拆开前停留动画
    local status = self:getStatus()
    if status == LuckyPackDef.LUCKY_PACK_STATUS_BUYYED or status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_BUY then
        self:playHbShowAnimation()
    else
        self:playHbStayAnimation()
    end
end

-- 响应保存抽奖信息成功
function LuckyPackCtrl:OnSaveLotteryInfo()    
    local status = self:getStatus()
    if status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_BUY then        
        -- 播放拆红包动画再播放拆开后循环动画
        self:playHbOpenAnimation()
        my.scheduleOnce(function()
            -- 重新刷新UI
            self:initialUI()
            -- 播放拆开后循环动画
            self:playHbShowAnimation()
        end, 1.8)
    end
end

-- 购买幸运礼包成功则关闭
function LuckyPackCtrl:buySuccess()
    self:goBack()
end

-- 抽取幸运礼包或购买幸运礼包
function LuckyPackCtrl:onClickLotteryOrBuy()
    my.playClickBtnSound()
    
    -- 校验时间间隔
    local ClickInterval = 3
    local nowTime = os.time()
    self._lastClickTime = self._lastClickTime or 0
    if nowTime - self._lastClickTime > ClickInterval then
        self._lastClickTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请3秒后再操作", removeTime = 3}})
        return
    end    

    local deviceBuyCount = LuckyPackModel:getBuyCount()
    if deviceBuyCount >= LuckyPackDef.LUCKY_PACK_DIVICE_MAX_BUY_COUNT then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "当日设备已达到购买上限", removeTime = 3}})
        return
    end

    -- 获取当前状态
    local status = self:getStatus()

    --幸运礼包状态：已购买
    if status == LuckyPackDef.LUCKY_PACK_STATUS_BUYYED then return end    
        
    if status == LuckyPackDef.LUCKY_PACK_STATUS_WAIT_LOTTERY then
        --幸运礼包状态：待抽取
        LuckyPackModel:LotteryLuckyPack()
        LuckyPackModel:reqSaveLotteryInfo()
    else
        --幸运礼包状态：待购买
        self:payForProduct()    
    end
end

-- 获取包类型
function LuckyPackCtrl:AppType()
    local type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_TCY
            else
                type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_TCY
            else
                type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_SINGLE
            end
        else 
            type = LuckyPackDef.LUCKYPACK_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = LuckyPackDef.LUCKYPACK_APPTYPE_IOS_TCY
        else
            type = LuckyPackDef.LUCKYPACK_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function LuckyPackCtrl:payForProduct()
    local lotteryInfo = LuckyPackModel:getLotteryInfo()

    local szWifiID, szImeiID, szSystemID = DeviceModel.szWifiID, DeviceModel.szImeiID, DeviceModel.szSystemID
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
            print("LuckyPackCtrl single app")
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

        print("LuckyPackCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "幸运礼包"
    param["Product_Id"] = ""
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price, exchangeid = lotteryInfo.specialPrice, lotteryInfo.exchangeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == LuckyPackDef.LUCKYPACK_APPTYPE_AN_TCY then
        print("LUCKYPACK_APPTYPE_AN_TCY")
    elseif apptype == LuckyPackDef.LUCKYPACK_APPTYPE_AN_SINGLE then
        print("LUCKYPACK_APPTYPE_AN_SINGLE")
    elseif apptype == LuckyPackDef.LUCKYPACK_APPTYPE_AN_SET then
        print("LUCKYPACK_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == LuckyPackDef.LUCKYPACK_APPTYPE_IOS_TCY then
        print("LUCKYPACK_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == LuckyPackDef.LUCKYPACK_APPTYPE_IOS_SINGLE then
        print("LUCKYPACK_APPTYPE_IOS_SINGLE")
        param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
    end

    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)    --价格
    param["Exchange_Id"]  = tostring(1)         --物品ID  1是银子 2是会员 3是积分 4是钻石
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();

    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "LuckyPackCtrl:payForProduct param")
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        local function payCallBack(code, msg)
            if code == PayResultCode.kPaySuccess then
                
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
        dump(param, "LuckyPackCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
    end
end

function LuckyPackCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

function LuckyPackCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    LuckyPackCtrl.super.removeSelf(self)
end

return LuckyPackCtrl