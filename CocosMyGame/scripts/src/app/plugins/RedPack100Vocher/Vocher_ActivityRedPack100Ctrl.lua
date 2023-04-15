local ActivityRedPack100Ctrl       = import("src.app.plugins.RedPack100.ActivityRedPack100Ctrl")
local Vocher_ActivityRedPack100Ctrl = class("Vocher_ActivityRedPack100Ctrl", ActivityRedPack100Ctrl)
local viewCreater       = import("src.app.plugins.RedPack100Vocher.Vocher_ActivityRedPack100View")
local RedPack100Model = import("src.app.plugins.RedPack100.RedPack100Model"):getInstance()
local RedPack100Def = import('src.app.plugins.RedPack100.RedPack100Def')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
--local RewardTipDef               = import("src.app.plugins.RewardTip.RewardTipDef")

local BTN_REWARD_STATUS = {
    NOMAL_REWARD = 0,
    ALEADY_REWARD = 1
}


function Vocher_ActivityRedPack100Ctrl:ctor(...)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/RedPack100Ani.plist")

    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._RedPackTipConten == nil then
        local FileNameString = "src/app/plugins/RedPack100/RedPack100.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._RedPackTipConten = cc.load("json").json.decode(content)
    end

    self:initialize()
    self:initialBtnClick()
    self:refreshCountDown()
    self:startUpdateTimer()
end

function Vocher_ActivityRedPack100Ctrl:initialize()
    self._viewNode.panelAniShade:setVisible(false)
    self._viewNode.imgTipFight:setVisible(false)        -- 大师房对局提示，底部
    self._viewNode.lodingBarValue:setPercent( 0 )
    local strDiffVocher = string.format(self._RedPackTipConten.DIFF_VOCHERS, 100)
    self._viewNode.txtDiffValue:setString(strDiffVocher)
    self._viewNode.txtMinus:setVisible(false)

    local strLeiji = string.format(self._RedPackTipConten.ACCUMULATE_CAN_EXCHANGE, RedPack100Def.REDPACK_REWARD_NUM)
    self._viewNode.txtLeiji:setString(strLeiji)     -- 累计礼券可以兑换文字

    self._viewNode.imgTipsBg:loadTexture("hallcocosstudio/images/plist/RedPack100Vocher/evetyday_login.png", ccui.TextureResType.plistType)
end

-- 设置进度条
function Vocher_ActivityRedPack100Ctrl:setProcessMoneyValue(nProcnessVocher)
    local viewNode = self._viewNode
    -- 设置进度条进度
    local nAccuPercent = nProcnessVocher/100
    viewNode.lodingBarValue:setPercent( nAccuPercent )

    -- 设置气泡剩余多少
    local diffVocher = RedPack100Def.REDPACK_REWARD_NUM - nProcnessVocher
    local strDiffVocher = string.format(self._RedPackTipConten.DIFF_VOCHERS, diffVocher)
    if diffVocher <= 0 then
        strDiffVocher = string.format(self._RedPackTipConten.EXCHANGE_CAN_TIP)
    end

    viewNode.txtDiffValue:setString(strDiffVocher)

    -- 设置气泡位置
    local StartXInProcess = 90
    local xPos = math.floor(viewNode.lodingBarValue:getContentSize().width/100*nAccuPercent)
    viewNode.imgDiffMoney:setPositionX(StartXInProcess + xPos)
end

function Vocher_ActivityRedPack100Ctrl:playBubbleTextAni(aniViewNode, breakInfo)
    self._BubbleTxtNode = aniViewNode.txtMinus
    local function callbackFunc()
        self._BubbleTxtNode:setVisible(false)
        self:setProcessMoneyValue(breakInfo.nAccumulateMoney)
        self:playBubbleAni(aniViewNode.imgDiffMoney)
    end
    
    local pos = cc.p(aniViewNode.txtDiffValue:getPosition())
    local time = 1
    local firstDelay = 1
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local a1 = cc.FadeTo:create(time, 0)
    local a2 = cc.MoveTo:create(time, cc.p(pos.x+10, pos.y+100))
    local action1_spawn = cc.Spawn:create(a1, a2)
    self._BubbleTxtNode:setOpacity(255)
    self._BubbleTxtNode:setPosition(cc.p(pos.x+10, pos.y+20))
    local strMinus = string.format(self._RedPackTipConten.BREAK_GET_VOCHER, breakInfo.nGetMoney)
    self._BubbleTxtNode:setString(strMinus)
    self._BubbleTxtNode:runAction(cc.Sequence:create(cc.Show:create(), delayAction, action1_spawn, cc.CallFunc:create(callbackFunc)))
end

function  Vocher_ActivityRedPack100Ctrl:QuXianAniCallBack(rewardRsp)
    local viewNode = self._viewNode
    if viewNode then
        local panelShade = viewNode.panelAniShade
        local aniNode = viewNode.nodeQuxian
        if panelShade then
            panelShade:setVisible(false)
        end
        if aniNode then
            aniNode:setVisible(false)
        end

        viewNode.imgTixian:setVisible(false)
        viewNode.btnReward:setEnabled(false)
        viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
        viewNode.nodeTiqu:setVisible(false)
        viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100Vocher/aleady_exchange.png")

        viewNode.txtMinus:setVisible(false)
        local strAleady = string.format(self._RedPackTipConten.EXCHANGE_ALEADY_TIP)
        viewNode.txtDiffValue:setString(strAleady)
        viewNode.txtWaitExchange:setString(strAleady)
        self.bQuxianCalled = true

        local rewardList = {}
        table.insert( rewardList,{nType = 13})
        my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList, showRedPacketVocher = true, showtip = true}})
    end
end


-- 领奖动画 不循环
function Vocher_ActivityRedPack100Ctrl:playQuXianAni(viewNode, rewardRsp)
    local panelShade = viewNode.panelAniShade
    panelShade:setVisible(true) -- 设置取现动画的阴影背景

    -- 播放qq取现声音
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPack100Tixian.mp3'),false)

    local aniNode = viewNode.nodeQuxian
    if not aniNode then return end

--[[    if not self._spBoxEffect then
        local actionName = "box_effect"    
        self._spBoxEffect = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json", "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.atlas",1)
        self._spBoxEffect:setAnimation(0, actionName, false) 
        self._spBoxEffect:setPositionY(80)
        aniNode:addChild(self._spBoxEffect)
    end
]]
    if not self._spBoxOpen then
        local actionName = "box_ani_open"    
        self._spBoxOpen = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json", "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.atlas",1)
        self._spBoxOpen:setAnimation(0, actionName, false) 
        aniNode:addChild(self._spBoxOpen)
    end

    -- 定时器做确保
    local function hideAniQuxianNode()
        if nil  == self.bQuxianCalled then
            self:QuXianAniCallBack(rewardRsp)
        end
    end
    self._CDTimerHideAni = my.scheduleOnce(hideAniQuxianNode, 1.5)
end

function Vocher_ActivityRedPack100Ctrl:onRedPackActivityBtnBreak(data)
    if data and data.value then
        if data.value ~= RedPack100Def.BREAK_COND_BOUT_REACHED and data.value ~= RedPack100Def.BREAK_COND_DAY_TASK then
            return
        end
    end

    local breakInfo = RedPack100Model:GetRedPackInfo()
    if not breakInfo then
        return
    end
    -- 播放拆红包声音
    -- audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPackBreak.mp3'),false)
    -- 通知model层需要播放飘文字动画
    local prevMoney = breakInfo.nAccumulateMoney - breakInfo.nGetMoney
    RedPack100Model:setDataForProcessAni(prevMoney, true)
    -- 先关闭气泡动画
    if self._BubbleNode then
        self._BubbleNode:stopAllActions()
    end

    my.informPluginByName({pluginName='Vocher_RedPack100SimplePlugin', params = {nGetMoney = breakInfo.nGetMoney} })
end

function Vocher_ActivityRedPack100Ctrl:updateUI()
    local viewNode = self._viewNode
    local breakInfo = RedPack100Model:GetRedPackInfo()
    -- 设置获奖用户列表数据
    if breakInfo.szCompleteUsers  and type(breakInfo.szCompleteUsers) == 'table' then
        for k,v in pairs(breakInfo.szCompleteUsers) do  
            if k > 3 then break end
            if v ~= "" then
                local txtName = 'txt'..k
                local strText =  string.format(self._RedPackTipConten.ADD_VOCHERS_LIST_TIP, RedPack100Def.REDPACK_REWARD_NUM)
                viewNode[txtName]:setString(strText)

                local txtName = "txtUserName"..k
                local utf8Name=MCCharset:getInstance():gb2Utf8String(v, string.len(v))
                my.fixUtf8Width(utf8Name, viewNode[txtName], 100)
            end
        end
    end

    -- 累计金额进度条
    local nProcessMoney = 0
    if false == RedPack100Model:isNeedPlayProcessTextAni() then
        if breakInfo.nAccumulateMoney > 0 then
            nProcessMoney = breakInfo.nAccumulateMoney
            if breakInfo.nAccumulateMoney > RedPack100Def.REDPACK_REWARD_NUM  then
                nProcessMoney = RedPack100Def.REDPACK_REWARD_NUM 
            end
            self:playBubbleAni(viewNode.imgDiffMoney)
        end
    else
        if breakInfo.nPrevMoney > 0 then
            nProcessMoney = breakInfo.nPrevMoney
            if breakInfo.nPrevMoney > RedPack100Def.REDPACK_REWARD_NUM then
                nProcessMoney = RedPack100Def.REDPACK_REWARD_NUM
            end
        end
    end

    self:setProcessMoneyValue(nProcessMoney)

    -- 按钮显示
    viewNode.btnJump:setVisible(false)
    viewNode.btnBreak:setVisible(false)
    viewNode.btnReward:setVisible(false)
    viewNode.btnLogin:setVisible(false)
    viewNode.imgTipFight:setVisible(false)

    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)       -- 服务器今日时间
            
    local strStartDate = string.format("%s000000", breakInfo.nStartDate)
    local strBtnShowDate = cc.exports.getNewDate(strStartDate, breakInfo.nBtnStartShowDay, "Day") -- 往后加x天,
    local nBtnShowDate = tonumber(strBtnShowDate)   -- 对局按钮显示日期
    if nTodayDate < nBtnShowDate then
        -- 达到了对局按钮显示日期
        if breakInfo.nAccumulateMoney >= RedPack100Def.REDPACK_REWARD_NUM then
            -- 显示领奖100元了
            viewNode.btnReward:setVisible(true)
            viewNode.lodingBarValue:setPercent( 100 )
            local strDiffMoney = string.format(self._RedPackTipConten.EXCHANGE_CAN_TIP)
            viewNode.txtDiffValue:setString(strDiffMoney)

            if breakInfo.nRewardDate > 0 then
                viewNode.imgTixian:setVisible(false)
                viewNode.btnReward:setEnabled(false)
                viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
                viewNode.nodeTiqu:setVisible(false)
                viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100Vocher/aleady_exchange.png")
                
                viewNode.txtMinus:setVisible(false)
                local strAleady = string.format(self._RedPackTipConten.EXCHANGE_ALEADY_TIP, 0)
                viewNode.txtDiffValue:setString(strAleady)
                viewNode.txtWaitExchange:setString(strAleady)
            else
                self:playTiquBtnAni(viewNode.nodeTiqu)
            end
            return 
        end

        if breakInfo.nCurrentDay <= 4 then
            --第四天不能参加惊喜夺宝活动，不要显示任务
            local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
            if breakInfo.nCurrentData == -1  or breakInfo.nDestData == 0 or (breakInfo.nCurrentDay ==4 and not ExchangeLotteryModel:GetActivityOpen())then   --配置为0表示当前任务活动关闭
                -- 未达到对局按钮显示器日期
                local diffVocher= RedPack100Def.REDPACK_REWARD_NUM - breakInfo.nAccumulateMoney
                viewNode.btnLogin:setVisible(true)
                local strHopeVocher = string.format(self._RedPackTipConten.BTN_LOGIN_HOPE_VOCHER, diffVocher)
                viewNode.txtBMFontTip:setString(strHopeVocher)
            elseif breakInfo.nCurrentData < breakInfo.nDestData then
                viewNode.btnJump:setVisible(true)
                local strJumpBoutTip = string.format(self._RedPackTipConten.BTN_JUMP_BOUT_TIP, breakInfo.nCurrentData, breakInfo.nDestData)
                viewNode.txtBMFont:setString(strJumpBoutTip)
                -- 最后一行对局提示

                if breakInfo.nDestData > 0 then
                    local stTip = string.format(self._RedPackTipConten["FIGHT_DEST_VOCHER_DAY_TASK"..breakInfo.nCurrentDay], breakInfo.nDestData)
                    viewNode.txtTipFight:setString(stTip)
                    viewNode.imgTipFight:setVisible(true)
                end

                if not self._aniBtnJump then
                    self._aniBtnJump = viewNode.btnJump
                    local repeatForever = self:createAnimationRepeat(0.1)
                    self._aniBtnJump:runAction(repeatForever)
                end
            elseif breakInfo.nCurrentData >= breakInfo.nDestData then
                viewNode.btnBreak:setVisible(true)
                self:playBreakBtnAni(viewNode.nodeBreak)
            end
        end
    else
        -- 达到了对局按钮显示日期
        if breakInfo.nAccumulateMoney >= RedPack100Def.REDPACK_REWARD_NUM then
            -- 显示领奖100元了
            viewNode.btnReward:setVisible(true)
            viewNode.lodingBarValue:setPercent( 100 )
            local strDiffMoney = string.format(self._RedPackTipConten.EXCHANGE_CAN_TIP)
            viewNode.txtDiffValue:setString(strDiffMoney)

            if breakInfo.nRewardDate > 0 then
                viewNode.imgTixian:setVisible(false)
                viewNode.btnReward:setEnabled(false)
                viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
                viewNode.nodeTiqu:setVisible(false)
                viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100Vocher/aleady_exchange.png")
                
                viewNode.txtMinus:setVisible(false)
                local strAleady = string.format(self._RedPackTipConten.EXCHANGE_ALEADY_TIP, 0)
                viewNode.txtDiffValue:setString(strAleady)
                viewNode.txtWaitExchange:setString(strAleady)
            else
                self:playTiquBtnAni(viewNode.nodeTiqu)
            end
        else
            if breakInfo.nAvailableBout >= breakInfo.nDestBout then
                viewNode.btnBreak:setVisible(true)
                self:playBreakBtnAni(viewNode.nodeBreak)
            else
                viewNode.btnJump:setVisible(true)
                local strJumpBoutTip = string.format(self._RedPackTipConten.BTN_JUMP_BOUT_TIP, breakInfo.nAvailableBout, breakInfo.nDestBout)
                viewNode.txtBMFont:setString(strJumpBoutTip)
                -- 最后一行对局提示

                if breakInfo.nDestBout > 0 then
                    local stTip = string.format(self._RedPackTipConten.FIGHT_DEST_BOUT_VOCHER_TIP, breakInfo.nDestBout)
                    viewNode.txtTipFight:setString(stTip)
                    viewNode.imgTipFight:setVisible(true)
                end

                if not self._aniBtnJump then
                    self._aniBtnJump = viewNode.btnJump
                    local repeatForever = self:createAnimationRepeat(0.1)
                    self._aniBtnJump:runAction(repeatForever)
                end
            end
        end
    end
end

function Vocher_ActivityRedPack100Ctrl:onClickBtnHelp()
    my.playClickBtnSound()
    -- 弹窗说明提示
    my.informPluginByName({pluginName='Vocher_RedPack100ExplainPlugin'})
end


return Vocher_ActivityRedPack100Ctrl