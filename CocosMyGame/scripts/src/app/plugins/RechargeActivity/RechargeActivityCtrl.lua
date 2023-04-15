local RechargeActivityCtrl      = class("RechargeActivityCtrl", cc.load('BaseCtrl'))
local viewCreater       	    = import("src.app.plugins.RechargeActivity.RechargeActivityView")
local RechargeActivityModel     = import("src.app.plugins.RechargeActivity.RechargeActivityModel"):getInstance()
local Def                       = import('src.app.plugins.RechargeActivity.RechargeActivityDef')
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local GamePublicInterface                       = cc.exports.GamePublicInterface
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

RechargeActivityCtrl.DELAY_TABLE = {0.6,0.5,0.4,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.4,0.5,0.6,0.7,0.8}
RechargeActivityCtrl.JUMP_TABLE = {}
RechargeActivityCtrl.JUMP_COUNT = 20


-- RechargeActivityCtrl.ctrlConfig = {
--     ["pluginName"] = "RechargeActivityCtrl",
--     ["isAutoRemoveSelfOnNoParent"] = true
-- }
function RechargeActivityCtrl:onCreate(...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    if self._viewNode and self._viewNode.btnClose then
        self:bindDestroyButton(self._viewNode.btnClose)
    end
    self:registWidgetEvents()

    RechargeActivityModel:rechargeInfoReq()
    self:freshView()
end

function RechargeActivityCtrl:registWidgetEvents()
  
    if self._viewNode and self._viewNode.btnDraw then
        handler(self, self.onClickBtnDraw)
        self._viewNode.btnDraw:addClickEventListener(handler(self, self.onClickBtnDraw))
    end

    if self._viewNode and self._viewNode.btnDrawImmditely then
        self._viewNode.btnDrawImmditely:addClickEventListener(handler(self, self.onClickBtnDraw))
        self._viewNode.btnDrawImmditely:setVisible(false)
    end

    self:listenTo(RechargeActivityModel,Def.EVENT_RECHARGE_INFO_UPDATE,handler(self,self.freshView))
    self:listenTo(RechargeActivityModel,Def.EVENT_GET_LOTTERY_RESULT,handler(self,self.showLotteryResult))
    self:listenTo(RechargeActivityModel,Def.EVENT_GET_LOTTERY_FAILED,handler(self,self.onGetRewardFailed))
    self:listenTo(PluginProcessModel,PluginProcessModel.NOTIFY_CLOSE_ALL_PLUGIN,handler(self,self.onNotifyClose))
end

--购买按钮的时机
function RechargeActivityCtrl:onClickBtnDraw()
    --播放音乐
    my.playClickBtnSound()
    -- if not cc.load('MainCtrl'):getInstance():isNetworkCheck() then
    --     self:removeSelfInstance()
    --     return
    -- end

    BroadcastModel:stopInsertMessage()
    if self._playingResultAni then return end
    
    --通过充值金额和今日抽奖次数进入三种情况 1.有抽奖次数 2.没抽奖次数，但已抽奖次数超过上限 3.没抽奖次数，点击按钮抽奖
    local config = RechargeActivityModel:GetConfig()
    if not config then return end

    local info = RechargeActivityModel:GetInfo()
    if not info then return end

    --获得充值总金额的数量
    local nTotalPay = info.nTotalPay 
    --获得了已经抽奖的次数
    local nDraw = info.nDraw
    --获得配置信息档位
    local GearTable = config["Gear"]
    if not checktable(GearTable) then return end
   
    --通过档位规则和该功能的充值总数判断目前的档位
    local NewGear = self:SelectGear(GearTable,nTotalPay)

    --抽奖次数存在---------已抽奖次数小于可抽奖次数---可抽奖次数 = 目前档位-1
    --即存在抽奖次数的情况
    if nDraw >= 1 then
        RechargeActivityModel:rechargeLotteryReq()   
    else
        --抽奖次数不存在，且已抽奖次数已经满6次（上限是6次，但是还是用最大值）
        if nTotalPay >=GearTable[#GearTable] then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="您已经获得全部奖励，请等待下次活动开启",removeTime=1.0}})
            self:freshView()
        --抽奖次数不存在，直接开启sdk
        else
            --在model中添加输入的金额和商品id
            local price = config["Gear"]
            local exID = config["LotteryConfig"]
            RechargeActivityModel:setspecialPrice(price[NewGear])
            RechargeActivityModel:setexchangeID(exID[NewGear])
            --触发充值的sdk
            self:onClickLotteryOrBuy()
            self:freshView()
        end
    end
    self:freshView()
end


-- 由商品id和价格构成购买的sdk
function RechargeActivityCtrl:onClickLotteryOrBuy()
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

    --幸运礼包状态：待购买
    self:payForProduct()

end

function RechargeActivityCtrl:payForProduct()
    --获取充值有礼的sdk接口信息
    local lotteryInfo = RechargeActivityModel:getLotteryInfo()

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
            print("RechargeActivityCtrl single app")
        end
        --个人id 游戏id
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

        print("RechargeActivityCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    --
    param["Product_Name"] = "充值有礼"
    param["Product_Id"] = ""
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)
    --
    local price, exchangeid = lotteryInfo.specialPrice, lotteryInfo.exchangeID
    print("------ price and exchangeid:",price,exchangeid)
    
    if apptype == Def.RECHARGE_APPTYPE_AN_TCY then
        print("RECHARGE_APPTYPE_AN_TCY")
    elseif apptype == Def.RECHARGE_APPTYPE_AN_SINGLE then
        print("RECHARGE_APPTYPE_AN_SINGLE")
    elseif apptype == Def.RECHARGE_APPTYPE_AN_SET then
        print("RECHARGE_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.RECHARGE_APPTYPE_IOS_TCY then
        print("RECHARGE_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.RECHARGE_APPTYPE_IOS_SINGLE then
        print("RECHARGE_APPTYPE_IOS_SINGLE")
        param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
    end

    --修改
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)    --价格
    param["Exchange_Id"]  = tostring(4)         --物品ID  1是银子 2是会员 3是积分 4是钻石
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
        --重点
        iapPlugin:payForProduct(param)
    end
end

-- 获取包类型
function RechargeActivityCtrl:AppType()
    local type = Def.RECHARGE_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.RECHARGE_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.RECHARGE_APPTYPE_AN_TCY
            else
                type = Def.RECHARGE_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.RECHARGE_APPTYPE_AN_TCY
            else
                type = Def.RECHARGE_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.RECHARGE_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.RECHARGE_APPTYPE_IOS_TCY
        else
            type = Def.RECHARGE_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function RechargeActivityCtrl:freshView()
    if not RechargeActivityModel._info or not RechargeActivityModel._config then
        return
    end

    local info = RechargeActivityModel:GetInfo()
    if info.open ==0 then
        return
    end

    local config = RechargeActivityModel:GetConfig()

    self:setBtn()
    self:freshAward()
    self:setAwardSatus(info.AwardStatus)
    self:setRechargeForNextLottery()
    self:setActivityDate()
end

function RechargeActivityCtrl:freshAward()
    local config = RechargeActivityModel:GetConfig()
    if not config.Gift then return end

    local awards = config["Gift"]

    for i,v in pairs(awards) do
        self:setAwardItem(i,v["type"],v["count"],v["bgcolor"],v["effect"])
    end
end

function RechargeActivityCtrl:setAwardItem(index,type,count,bgColor,effect)
    local node = self._viewNode["node" .. index]
    local imgItem = node:getChildByName("Img_Item")
    local textCount = node:getChildByName("Text_Count")

    local ticketPath = self:GetTicketPath()
    local silverPath = self:GetPathBySilverCount(count)
    if ticketPath and silverPath then
        if type == Def.TYPE_SILVER then
            imgItem:loadTexture(silverPath,ccui.TextureResType.plistType)
            if textCount then
                textCount:setString(string.format( "%d两",count))
            end
        elseif type ==  Def.TYPE_TICKET then
            imgItem:loadTexture(ticketPath,ccui.TextureResType.plistType)
            if textCount then
                textCount:setString(string.format( "%d张",count))
            end
        end
    end

    local purpleBGPath = "hallcocosstudio/images/plist/RechargeActivity/jp_bg_1.png"
    local redBGPath = "hallcocosstudio/images/plist/RechargeActivity/jp_bg_2.png"
    if bgColor == Def.COLOR_PURPLE then
        node:loadTexture(purpleBGPath,ccui.TextureResType.plistType)
    elseif bgColor == Def.COLOR_RED then
        node:loadTexture(redBGPath,ccui.TextureResType.plistType)
    end

    local node_effet = node:getChildByName("Ani_Bingo")
    if effect~=0 then
        node_effet:setVisible(true)
        local aniPath = "res/hallcocosstudio/RechargeActivity/gd_chouzhong.csb"
        if node_effet then
            local aniEffect = cc.CSLoader:createTimeline(aniPath)
            node_effet:runAction(aniEffect)
            aniEffect:play("animation0", true)
        end
    else
        node_effet:setVisible(false)
    end

end

function RechargeActivityCtrl:setAwardSatus(status)
    local flag = 0x00000001;
    for i = 1,6 do
        local node = self._viewNode["node" .. i]
        local imgRewarded = node:getChildByName("Img_Rewarded")
        local imgShade = node:getChildByName("Img_Shade")
        local imgDraw = node:getChildByName("Ani_Draw")
        if imgRewarded and imgShade then
            if GamePublicInterface:IS_BIT_SET(status, flag) then
                imgRewarded:setVisible(true)
                imgShade:setVisible(true)
            else
                imgRewarded:setVisible(false)
                imgShade:setVisible(false)
            end
        end
        if imgDraw then 
            imgDraw:stopAllActions()
            imgDraw:setVisible(false)
        end
        flag = bit.lshift(flag,4)
    end
end

--通过传入抽奖的档位和该抽奖的总数判断档位
function RechargeActivityCtrl:SelectGear(Gear,nTotalPay)
    local NewCount = 0
    for i, v in pairs(Gear) do
        local diff = v - nTotalPay
        NewCount = NewCount + 1
        if diff > 0 then 
            return NewCount
        end
    end
end


function RechargeActivityCtrl:setRechargeForNextLottery_old()
    local config = RechargeActivityModel:GetConfig()
    if not config then return end
    local info = RechargeActivityModel:GetInfo()
    if not info then return end
    local nTotalPay = info.nTotalPay  
    --获得了已经抽奖的次数
    local nDraw = info.nDraw
    --获得档位
    local GearTable = config["Gear"]
    if not checktable(GearTable) then return end

    local textRecharge = self._viewNode.textRecharge
    local textLeftCount = self._viewNode.textLeftCount

    --旧版会剩余抽奖次数，所以有剩余抽奖次数和没有时需要显示还需抽奖多少次
    if nDraw and nDraw>0 then
        local textString = textLeftCount:getChildByName("Text_Count")
        textString:setString(string.format( "%d",nDraw))
        textLeftCount:setVisible(true)
        textRecharge:setVisible(false)
        return
    else
        textLeftCount:setVisible(false)
        local bShowRecharge = false
        for i, v in pairs(GearTable) do
            local diff = v - nTotalPay
            if diff > 0 then
                bShowRecharge = true
                local textString = textRecharge:getChildByName("Text_Count")
                textString:setString(string.format("%d元", diff))
                textRecharge:setVisible(true)
                break
            end
        end

        if not bShowRecharge then
            textRecharge:setVisible(false)
        end
    end 
end



function RechargeActivityCtrl:setRechargeForNextLottery()
    local config = RechargeActivityModel:GetConfig()
    if not config then return end
    local info = RechargeActivityModel:GetInfo()
    if not info then return end
    local nTotalPay = info.nTotalPay 

    --获得了已经抽奖的次数
    local nDraw = info.nDraw
    --获得档位信息
    local GearTable = config["Gear"]
    if not checktable(GearTable) then return end

    local textRecharge = self._viewNode.textRecharge
    local textLeftCount = self._viewNode.textLeftCount

    --通过档位规则和该功能的充值总数判断目前的档位
    local NewGear = self:SelectGear(GearTable,nTotalPay)

    --通过目前的档位和已经抽奖次数判断目前有没有可以抽的
    if nDraw < 1 then
        --没有抽奖次数的情况
        textLeftCount:setVisible(false)
        self._viewNode.btnDraw:setVisible(true)
        self._viewNode.btnDrawImmditely:setVisible(false)
        local bShowRecharge = false
        if nTotalPay <  GearTable[#GearTable]  then
            local diff = GearTable[NewGear]
            if diff > 0 then
                bShowRecharge = true
                local textString = textRecharge:getChildByName("Text_Count")
                textString:setString(string.format("%d元", diff))
                textRecharge:setVisible(true)
            end
        else
            --如果存在抽满上限显示
            local diff = GearTable[#GearTable]
            local textString = textRecharge:getChildByName("Text_Count")
            textString:setString(string.format("%d元", diff))
            textRecharge:setVisible(true)
        end
        
    else
        --有抽奖次数的情况
        --显示立即抽奖，隐藏普通抽奖按钮，按钮在开始时都绑定了函数
        --[[
        local textString = textLeftCount:getChildByName("Text_Count")
        textString:setString(string.format( "%d",1))
        textLeftCount:setVisible(true)
        textRecharge:setVisible(false)
        ]]
        self._viewNode.btnDraw:setVisible(false)
        self._viewNode.btnDrawImmditely:setVisible(true)
    end
    if not bShowRecharge then
        --textRecharge:setVisible(false)
    end
end





function RechargeActivityCtrl:setActivityDate()
    local config = RechargeActivityModel:GetConfig()
    if not config then return end

    local beginDate = config["beginDate"]
    local endDate = config["endDate"]

    if not beginDate or not endDate then return end
    local beginDay = string.sub(beginDate, -2)
    local beginMon = string.sub(beginDate, -4,-3)
    local endDay = string.sub(endDate, -2)
    local endMon = string.sub(endDate, -4,-3)

    local strDate = string.format( "活动时间：%d月%d日-%d月%d日",beginMon,beginDay,endMon,endDay)
    if self._viewNode.textTime then
        self._viewNode.textTime:setString(strDate)
    end
end

function RechargeActivityCtrl:GetPathBySilverCount(count)
    local silverPath = "hallcocosstudio/images/plist/RechargeActivity/Img_Silver"
    local Path
    if count>=300000 then 
        Path = silverPath .. "7.png"
    elseif count>=50000 and count<300000 then
        Path = silverPath .. "6.png"
    elseif count>=25000 and count<50000 then
        Path = silverPath .. "5.png"
    else
        Path = silverPath .. "4.png"
    end
    return Path
end

function RechargeActivityCtrl:GetTicketPath()
    return "hallcocosstudio/images/plist/RechargeActivity/Img_Ticket.png"
end

function RechargeActivityCtrl:showLotteryResult(data)
    if(type(data)~='table' or type(data.value)~='table')then
        return
    end

    if self._playingResultAni then return end
    if not data then return end
    local index = data.value.nIndex
    local awardStatus = data.value.nStatus
    local valueTable = {1,2,3,4,5,6}
    local flag = 0x00100000;
    for i = 6,1,-1 do
        if GamePublicInterface:IS_BIT_SET(awardStatus, flag) then
            table.remove( valueTable,i)
        end
        flag = bit.rshift(flag,4)
    end

    if table.maxn(valueTable) == 1 then
        self:Jump(index,RechargeActivityCtrl.JUMP_COUNT+1)
        return
    end

    local tempIndex = index
    local drawTable = {}
    table.insert(drawTable, tempIndex)
    for i = 1,RechargeActivityCtrl.JUMP_COUNT do
        local tab = clone(valueTable)
        for k,v in pairs(tab) do
            if v == tempIndex then
                table.remove(tab,k)
                break
            end
        end
        tempIndex = tab[math.random(1,table.maxn(tab))];
        table.insert( drawTable,1, tempIndex);
    end
    RechargeActivityCtrl.JUMP_TABLE = clone(drawTable)

    self:Jump(RechargeActivityCtrl.JUMP_TABLE[1],1)
    self._playingResultAni = true

end

function RechargeActivityCtrl:Jump(nIndex,nCount)
    if nIndex<1 or nIndex>6 then return end
    --play audio
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/Lottery.WAV'),false)
    for i = 1,6 do
        local node = self._viewNode["node" .. i]
        local aniDrawFile= "res/hallcocosstudio/RechargeActivity/gd_choujiangkuang.csb"
        local imgDraw = node:getChildByName("Ani_Draw")
        imgDraw:stopAllActions()
        if i == nIndex and imgDraw then
            local aniDraw = cc.CSLoader:createTimeline(aniDrawFile)
                if not tolua.isnull(aniDraw) then
                    imgDraw:runAction(aniDraw)
                    aniDraw:play("animation0", true)
                end
            imgDraw:setVisible(true)
        else
            imgDraw:setVisible(false)
        end
    end
    if nCount < RechargeActivityCtrl.JUMP_COUNT+1 then
        self._showResultAniID = my.scheduleOnce(function()
            self._showResultAniID = nil
            self:Jump(RechargeActivityCtrl.JUMP_TABLE[nCount+1],nCount+1)
        end,RechargeActivityCtrl.DELAY_TABLE[nCount]) 
    else
        --抽奖动画结束，显示已抽取标签
        --刷新用户银子
        self._showResultEndID = my.scheduleOnce(function()
            self._showResultEndID = nil
            self._playingResultAni = false
            local itemInfo = RechargeActivityModel:GetItemInfoByIndex(nIndex)
            itemInfo = checktable(itemInfo);
            local type = itemInfo.type
            local count = itemInfo.count
            local rewardList = {}
            if type == Def.TYPE_SILVER then
                table.insert(rewardList, {nType = 1,nCount = count})
            elseif type == Def.TYPE_TICKET then
                table.insert(rewardList, {nType = 2,nCount = count})
            end
            --弹出奖励界面
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
            RechargeActivityModel:updateUserInfo(itemInfo)
            --刷新充值有礼界面
            self:freshView()
            --刷新大厅按钮
            -- local mainCtrl = cc.load('MainCtrl'):getInstance()
            -- mainCtrl:updateBtnRechargeActivity(true)
            RechargeActivityModel:notifyRewardStatus()

            BroadcastModel:ReStartInsetMessage()
        end,1)

    end
end

function RechargeActivityCtrl:onExit()
    if self._showResultAniID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._showResultAniID)
        self._showResultAniID = nil
    end

    if self._showResultEndID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._showResultEndID)
        self._showResultEndID = nil
    end

    self._playingResultAni = false
    local ExchangeCenterModel   = import("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
    if ExchangeCenterModel then
        ExchangeCenterModel:getTicketNum()
    end
    local PlayerModel           = mymodel('hallext.PlayerModel'):getInstance()
    PlayerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    BroadcastModel:ReStartInsetMessage()
    -- local mainCtrl = cc.load('MainCtrl'):getInstance()
    -- mainCtrl:updateBtnRechargeActivity(true)
    RechargeActivityModel:notifyRewardStatus()

    --每日登录弹框
    PluginProcessModel:PopNextPlugin()
end

function RechargeActivityCtrl:setBtn()
    if self._viewNode and self._viewNode.btnDraw then
        self._viewNode.btnDraw:setEnabled(true)
        if RechargeActivityModel:isRewardedAll() then
            self._viewNode.btnDraw:setColor(cc.c3b(0x4D,0x4D,0x4D))
            if self._viewNode.aniBtn then
                self._viewNode.aniBtn:stopAllActions()
            end
        else
            self._viewNode.btnDraw:setColor(cc.c3b(0xFF,0xFF,0xFF))
        end
    end
    
end

function RechargeActivityCtrl:onGetRewardFailed()
    if self._showResultAniID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._showResultAniID)
        self._showResultAniID = nil
    end

    if self._showResultEndID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._showResultEndID)
        self._showResultEndID = nil
    end
    self._playingResultAni = false
    self:freshView()
    --刷新大厅按钮
    -- local mainCtrl = cc.load('MainCtrl'):getInstance()
    -- mainCtrl:updateBtnRechargeActivity(true)
    RechargeActivityModel:notifyRewardStatus()

    BroadcastModel:ReStartInsetMessage()
end

function RechargeActivityCtrl:onNotifyClose()
    self:removeSelfInstance()
end

function RechargeActivityCtrl:onKeyBack()
    PluginProcessModel:stopPluginProcess()
    RechargeActivityCtrl.super.onKeyBack(self)
end

return RechargeActivityCtrl