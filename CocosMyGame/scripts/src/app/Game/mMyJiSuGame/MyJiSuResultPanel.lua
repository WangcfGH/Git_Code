local MyJiSuResultPanel = class("MyJiSuResultPanel", import("src.app.Game.mMyGame.MyResultPanelEx"))
local SKCardBase = import("src.app.Game.mSKGame.SKCardBase")

function MyJiSuResultPanel:onExit()
    print("MyJiSuResultPanel:onExit")
    self._gameController:hideBannerAdvert()

    self._gameController:IsHaveTaskFinish()
end

function MyJiSuResultPanel:isLose()
    if self._gameWin then     
        local score = self._gameWin.gamewin.nScoreDiffs[self._selfChairNO] --这个值是加过1的
        if score > 0 then
            return false
        else
            return true
        end
    end

    return false
end

function MyJiSuResultPanel:initResultPanel()
    self._oriOrder = 110 --没有点击时的zorder
    self._clickOrder = 115 --点击之后的zorder
    
    local csbPath = "res/GameCocosStudio/csb/Node_Result_Win_Ex_JiSu.csb"
    if self:isLose() then
        csbPath = "res/GameCocosStudio/csb/Node_Result_Lose_Ex_JiSu.csb"
        self._gameController:playGamePublicSound("Snd_lose.mp3")

        self._gamedata.winContinual = 0
    else
        self._gameController:playGamePublicSound("Snd_win.mp3")

        if self._gamedata.winContinual then
            self._gamedata.winContinual = self._gamedata.winContinual + 1
        else
            self._gamedata.winContinual = 1
        end
    end

    if self._gamedata.nTodayBouts == nil then
        self._gamedata.nTodayBouts = 0
    end

    if self._gamedata.logindate == nil then -- 新注册玩家在登陆的时候，（因为新手礼包的问题）时间存缓存被注释了。
        local date = self:getTodayDate()
        self._gamedata.logindate = date
    end
    self._gamedata.nTodayBouts = self._gamedata.nTodayBouts + 1 -- 每结算一次，今日局数加1， 2019年6月4日新增
    
    if DEBUG and DEBUG > 0 then
        print("===============MyJiSuResultPanel:initResultPanel  todayBouts: "..self._gamedata.nTodayBouts)
    end

    self._gameController:saveMyGameDataXml(self._gamedata)
    
    self._resultPanel = cc.CSLoader:createNode(csbPath)
    if self._resultPanel then
        self:addChild(self._resultPanel)
        SubViewHelper:adaptNodePluginToScreen(self._resultPanel, self._resultPanel:getChildByName("Panel_Shade"))

        local panelResult = self._resultPanel:getChildByName("Panel_Result")
        if self:isLose() then
            panelResult = self._resultPanel:getChildByName("Panel_Result")
        end

        if panelResult then
            self:initButtons(panelResult)
            self:initAnimation(panelResult)
            self:initScore(panelResult)
            --self:initSimple(panelResult)
            self:initDetails(panelResult)
            self:initLevel()
        end
    end
   
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._resultPanel:runAction(action)
        if self:isLose() then
            action:gotoFrameAndPlay(1, 35, false)
        else
            action:gotoFrameAndPlay(1, 28, false)
        end
    end

    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.RESULT_VIEW)

    -- 广告模块 start
    local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
    print("AdvertModel:MyResultPanelEx:initResultPanel")
    print("self._hasShowBanner: ", self._hasShowBanner)
    if self._gameController:isShowBanner() and not self._gameController._hasShowBanner then
        AdvertModel:showBannerAdvert()
        self._gameController._hasShowBanner = true
    end
    -- 广告模块 end
end

function MyJiSuResultPanel:getNumberString(num)
    if type(num) == 'number' and num > 0 then
        return "+" .. num
    end
    return tostring(num)
end

function MyJiSuResultPanel:initDetails(panelResult)
    local panelDetails = panelResult:getChildByName("Panel_ResultMain")
    local isMaxMultiple = false
    
    if panelDetails then
    
        self:InitBtnTopBottom(panelDetails)    

        -- 去掉本局消耗xxxx茶水费
        local Text_Tips = panelDetails:getChildByName("Text_Tips")
        if Text_Tips and self._gameController:isNeedDeposit() then       
            Text_Tips:setString(string.format(self._gameController:getGameStringToUTF8ByKey("G_GAME_RESULT_CASHUI_TIP"), self._gameWin.gamewin.nWinFees[self:getMyChairNO()+1]))
        else
            Text_Tips:setVisible(false)
        end

        local imgRank = panelDetails:getChildByName("Img_Ranking")
        if imgRank then
            imgRank:setVisible(false)
        end

        local Panel_Player1 = panelDetails:getChildByName("Panel_Player1")

        local Panel_playerSelf = Panel_Player1 --自己的数据显示在最上面
      
        local Text_ScoreSelf = Panel_playerSelf:getChildByName("Text_ScoreSelf")    
        self:setValueTextWithTopBottom(Panel_playerSelf,  Text_ScoreSelf, self:getMyChairNO()+1)   
        
        local Text_MyselfName = Panel_playerSelf:getChildByName("Text_MyselfName")               
        --local name = self._gameController:getPlayerUserNameByDrawIndex(self._gameController:rul_GetDrawIndexByChairNO(self._gameController:getMyChairNO()))
        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
         --昵称
        local utf8nickname = userPlugin:getNickName()
        local limitLen = Text_MyselfName:getContentSize().width
        Text_MyselfName:setString(utf8nickname)
        my.fitStringInWidget(utf8nickname, Text_MyselfName, limitLen)

        --开枪被打图片初始化
        local setKaiQiangBeiDa = function (panel, kaiqiang, beida)
            if not panel then return end
            local panelExtra = panel:getChildByName("Panel_Extra")
            if panelExtra then
                local imgGun = panelExtra:getChildByName("Img_Gun")
                local textLeft = panelExtra:getChildByName("Text_Left")
                local textRight = panelExtra:getChildByName("Text_Right")
                local nodeRight1 = panelExtra:getChildByName("Node_Right_1")
                local nodeRight2 = panelExtra:getChildByName("Node_Right_2")
                local nodeRight3 = panelExtra:getChildByName("Node_Right_3")
                imgGun:setVisible(false)
                textLeft:setVisible(false)
                textRight:setVisible(false)
                nodeRight1:setVisible(false)
                nodeRight2:setVisible(false)
                nodeRight3:setVisible(false)
                local tblNodeRight = {nodeRight1, nodeRight2, nodeRight3}

                if type(kaiqiang) == 'number' and kaiqiang > 0 and kaiqiang <= 3 then
                    imgGun:loadTexture("GameCocosStudio/plist/Result_Img_JS/qiang_".. kaiqiang .. ".png", ccui.TextureResType.plistType)
                    imgGun:setVisible(true)
                else
                    textLeft:setVisible(true)
                end

                if type(beida) == 'number' and beida > 0 and beida <= 3 then
                    tblNodeRight[beida]:setVisible(true)
                else
                    textRight:setVisible(true)
                end
            end
        end

        local DunCardCounts = {
            MyJiSuGameDef.FIRST_DUN_CARD_COUNT,
            MyJiSuGameDef.SECOND_DUN_CARD_COUNT,
            MyJiSuGameDef.THIRD_DUN_CARD_COUNT,
        }
        local setResultCard = function (panel, dunCardIDs)
            if not panel then return end
            for i = 1, 3 do
                local panelCard = panel:getChildByName("Panel_Card" .. i)
                if #dunCardIDs[i] == DunCardCounts[i] then
                    for j = 1, DunCardCounts[i] do
                        local cardID = dunCardIDs[i][j]
                        local node = panelCard:getChildByName("Node_" .. j)
                        local card = node:getChildByName("Img_Card")
                        if cardID ~= -1 then
                            local numName = SKCardBase:getCardNumName(cardID)
                            local colorName = SKCardBase:getCardShapeName(cardID)
                            if numName == "14" then 
                                if colorName == "5" then
                                    colorName = "black"
                                else
                                    colorName = "red"
                                end
                            end
                            local resName = string.format("GameCocosStudio/plist/Result_Img_JS/card_%s_%s.png", colorName, numName)
                            card:loadTexture(resName, ccui.TextureResType.plistType)
                        end
                    end
                end
            end
        end
        local getDunCardIDs = function (chairNO)
            local dunCardIDs = {{},{},{}}
            if self._gameWin and self._gameWin.dunCards and self._gameWin.dunCards[chairNO + 1] then
                local dunCardsInfo = self._gameWin.dunCards[chairNO + 1]
                for i = 1, 3 do
                    for j = 1, 8 do
                        if dunCardsInfo[i].nCardIDs[j] ~= -1 then
                            table.insert(dunCardIDs[i], dunCardsInfo[i].nCardIDs[j])
                        end
                    end
                end
            end
            return dunCardIDs
        end

        local getKaiQiangBeiDaCount = function (chairNO)
            local kaiqiangCount = 0
            local beidaCount = 0
            local daqiangResult = self._gameWin.nDaQiang
            if daqiangResult then
                for i = 1, 4 do
                    if i ~= chairNO + 1 and daqiangResult[chairNO + 1][i] ~= 0 then
                        kaiqiangCount = kaiqiangCount + 1
                    end
                end
                for i = 1, 4 do
                    if i ~= chairNO + 1 and daqiangResult[i][chairNO + 1] ~= 0 then
                        beidaCount = beidaCount + 1
                    end
                end
            end
            return kaiqiangCount, beidaCount
        end

        do 
            --设置倍率
            local myIndex = self:getMyChairNO()+1
            for j = 1, 3 do 
                local roundText = Panel_playerSelf:getChildByName("Text_Round" .. j)
                local value = self._gameWin.nMultiple[myIndex][j]    
                if roundText then
                    roundText:setString(self:getNumberString(value))
                end
            end
            do
                local extraText = Panel_playerSelf:getChildByName("Text_Extra")
                local value = self._gameWin.nExtraMultiple[myIndex]    
                if extraText then
                    extraText:setString(self:getNumberString(value))
                end
            end

            setKaiQiangBeiDa(Panel_playerSelf, getKaiQiangBeiDaCount(self:getMyChairNO()))
            setResultCard(Panel_playerSelf, getDunCardIDs(self:getMyChairNO()))

            local panelMultiple = panelDetails:getChildByName("Panel_TotalMultiple")
            if panelMultiple then
                local base = panelMultiple:getChildByName("Text_BaseValue")
                local value = self._gameWin.nDunMultiple[myIndex]    
                if base then
                    base:setString(self:getNumberString(value))
                end
                local extra = panelMultiple:getChildByName("Text_ExtraValue")
                local valueExtra = self._gameWin.nExtraMultiple[myIndex]   
                if extra then
                    extra:setString(self:getNumberString(valueExtra))
                end
            end
        end

        for i = 1, 4 do
            if i ~= self:getMyChairNO()+1 then     
                local index = i
                if i == 1 then 
                    index = self:getMyChairNO()+1
                end 
                local Panel_player = panelDetails:getChildByName("Panel_Player"..tostring(index))
                local Text_Score = Panel_player:getChildByName("Text_Score")                       
                self:setValueTextWithTopBottom(Panel_player, Text_Score, i)

                --设置倍率
                for j = 1, 3 do 
                    local roundText = Panel_player:getChildByName("Text_Round" .. j)
                    local value = self._gameWin.nMultiple[i][j]    
                    if roundText then
                        roundText:setString(self:getNumberString(value))
                    end
                end
                do
                    local extraText = Panel_player:getChildByName("Text_Extra")
                    local value = self._gameWin.nExtraMultiple[i]    
                    if extraText then
                        extraText:setString(self:getNumberString(value))
                    end
                end
                
                setKaiQiangBeiDa(Panel_player, getKaiQiangBeiDaCount(i - 1))
                setResultCard(Panel_player, getDunCardIDs(i - 1))

                local Text_Name = Panel_player:getChildByName("Text_PlayerName")   
                if self._gameController._playerInfo and self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)] then
                    local name = self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)].szUserName

                    name = self:getPlayerName(name, self._gameController._playerInfo[self:rul_GetDrawIndexByChairNO(i-1)])
                    if name then
                        local utf8Name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
                        local limitLen = Text_Name:getContentSize().width
                        Text_Name:setString(utf8Name)  
                        my.fitStringInWidget(utf8Name, Text_Name, limitLen)
                    end 
                end
            end
        end
    end 
end

function MyJiSuResultPanel:setValueText(Text_Score, index)
    if self._gameController:isNeedDeposit() then        
        Text_Score:setString(tostring(self._gameWin.gamewin.nDepositDiffs[index] + self._gameWin.gamewin.nWinFees[index]))         
        if (self._gameWin.gamewin.nDepositDiffs[index] + self._gameWin.gamewin.nWinFees[index]) >= 0 then
            Text_Score:setString("+"..tostring(self._gameWin.gamewin.nDepositDiffs[index] + self._gameWin.gamewin.nWinFees[index]))    
        end
    else
        Text_Score:setString(tostring(self._gameWin.gamewin.nScoreDiffs[index]))
        if self._gameWin.gamewin.nScoreDiffs[index]>=0 then
            Text_Score:setString("+"..tostring(self._gameWin.gamewin.nScoreDiffs[index]))    
        end
    end
end

function MyJiSuResultPanel:setValueTextWithTopBottom(Panel_player, Text_Score, index)
    self:setValueText(Text_Score, index)
    local textScorePosX = Text_Score:getPositionX()
    local selfOneScoreSize = 30  -- 经验值
    local OneScoreSize = 30 -- 经验值

    if self._gameController:isNeedDeposit() then
        -- 拿到其他玩家的椅子号
        local otherPlayerChair = {}
        for k, v in pairs(self._gameWin.gamewin.nWinPoints) do 
            if k ~= index and v ~= 0 then
                table.insert(otherPlayerChair, k)
            end
        end

        local totalDeposit = self._gameWin.gamewin.nDepositDiffs[index] + self._gameWin.gamewin.nWinFees[index]
        local digitalCount = #tostring(math.abs(totalDeposit)) + 1  -- 计算得到分数是几位数
        print("textScore positionX and digitalCount ", textScorePosX, digitalCount)
        local offsetPosX = digitalCount * OneScoreSize
        if index == (self:getMyChairNO()+1) then
            offsetPosX = digitalCount * selfOneScoreSize
        end
        local maxDigitalCount = digitalCount
        for i = 1, 4 do
            local tmpDeposit = self._gameWin.gamewin.nDepositDiffs[i] + self._gameWin.gamewin.nWinFees[i]
            local digitalCount = #tostring(math.abs(tmpDeposit)) + 1  -- 计算得到分数是几位数
            if maxDigitalCount < digitalCount then
                maxDigitalCount = digitalCount
            end
        end
        offsetPosX = maxDigitalCount * selfOneScoreSize

        if totalDeposit > 0 then -- 加银子， 判断要不要封顶
        
            --[[ -- 记录输的玩家椅子号
            local loseChair = {}
            for chair=1,4 do 
                if self._gameWin.gamewin.nWinPoints[chair] < 0 then
                    table.insert(loseChair, chair)
                end
            end]]--

            -- 计算本局结算目标分数
            local calcDeposit = math.abs(self._gameWin.gamewin.nWinPoints[index]) * self._gameWin.gamewin.nBaseDeposit + self._gameWin.gamewin.nWinFees[index]
            -- 得到该玩家的携银
            local drawIndex = self:rul_GetDrawIndexByChairNO(index-1)
            local currentDeposit = self._gameController._baseGamePlayerInfoManager:getPlayerDeposit(drawIndex)
            -- 得到该玩加原来的携银
            local oldDeposit = self._gameWin.gamewin.nOldDeposits[index]
            local bMinPlayer = true
            for k, v in pairs(otherPlayerChair) do
                local playerDeposit = self._gameWin.gamewin.nOldDeposits[v]
                if playerDeposit < oldDeposit then
                    bMinPlayer = false  -- 如果输的玩家携银比 当前玩家还要少，则当前玩家不是最少携银玩家，不能作为封顶判断条件
                    break
                end
            end
            
            print("-------1---- oldDeposit ", oldDeposit)
            print("-------1---- calcDeposit ", calcDeposit)
            print("-------1---- bMinPlayer ", bMinPlayer)

            if oldDeposit < calcDeposit and true == bMinPlayer then
            --if true then
                -- 加银两的玩家携银 小于理论值， 输的两个玩家均大于该玩家携银。 判定为封顶
                local Btn_TopBottom = Panel_player:getChildByName("Button_TopBottom")  
                local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
                local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
                local Image_jiantou = Btn_TopBottom:getChildByName("Image_jiantou")  
                local imgPath = "GameCocosStudio/plist/Result_Ex/fengding.png"
                Btn_TopBottom:loadTextureNormal(imgPath, 1)
                local origiPosX = Btn_TopBottom:getPositionX()
                if textScorePosX + offsetPosX > 1121.00 then
                    offsetPosX = 1121 - textScorePosX
                end
                Btn_TopBottom:setPositionX(textScorePosX + offsetPosX)
                local diff = textScorePosX + offsetPosX - origiPosX
                Btn_TopBottom:setVisible(true)

                Text_TopBottom:setPositionX(Text_TopBottom:getPositionX() - diff)
                Image_TopBottom:setPositionX(Image_TopBottom:getPositionX() - diff)

                local content = string.format(self._gameController:getGameStringByKey("G_GAME_RESULT_BTN_TOP_TIP"), oldDeposit, totalDeposit)
                local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                Text_TopBottom:setString(utf8Content)
                local textSize = Text_TopBottom:getSize()
                Image_TopBottom:setContentSize(textSize.width + 20, Image_TopBottom:getSize().height)

                local a2 = cc.DelayTime:create(2)
                local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
                   if Image_TopBottom and Image_TopBottom:isVisible() then
                        Image_TopBottom:setVisible(false)
                        Text_TopBottom:setVisible(false)
                        Image_jiantou:setVisible(false)
                    end
                end))
                Btn_TopBottom:runAction(a4)
            end
        else
            -- 扣银子， 判断要不要破产
            --[[ -- 记录赢的玩家椅子号
            local winChair = {}
            for chair=1,4 do 
                if self._gameWin.gamewin.nWinPoints[chair] > 0 then
                    table.insert(winChair, chair)
                end
            end
            ]]--

            -- 计算本局结算目标分数
            local calcDeposit = math.abs(self._gameWin.gamewin.nWinPoints[index]) * self._gameWin.gamewin.nBaseDeposit + self._gameWin.gamewin.nWinFees[index]
            -- 得到该玩加原来的携银
            local oldDeposit = self._gameWin.gamewin.nOldDeposits[index]
            local bMinPlayer = true
            for k, v in pairs(otherPlayerChair) do
                local playerDeposit = self._gameWin.gamewin.nOldDeposits[v]
                if playerDeposit < oldDeposit then
                    bMinPlayer = false  -- 如果输的玩家携银比 当前玩家还要少，则当前玩家不是最少携银玩家，不能作为封顶判断条件
                    break
                end
            end

            print("-------2---- oldDeposit ", oldDeposit)
            print("-------2---- calcDeposit ", calcDeposit)
            print("-------2---- bMinPlayer ", bMinPlayer)
            if oldDeposit < calcDeposit and true == bMinPlayer then
            --if true then
                -- 扣银两的玩家携银 小于理论值， 输的两个玩家均大于该玩家携银。 判定为封顶
                local Btn_TopBottom = Panel_player:getChildByName("Button_TopBottom")  
                local Text_TopBottom = Btn_TopBottom:getChildByName("Text_TopBottom")  
                local Image_TopBottom = Btn_TopBottom:getChildByName("Image_TopBottom")  
                local Image_jiantou = Btn_TopBottom:getChildByName("Image_jiantou")  
                -- 设置破产图片
                local imgPath = "GameCocosStudio/plist/Result_Ex/pochan.png"
                Btn_TopBottom:loadTextureNormal(imgPath, 1)
                Btn_TopBottom:loadTexturePressed(imgPath, 1)
                local origiPosX = Btn_TopBottom:getPositionX()
                if textScorePosX + offsetPosX > 1121.00 then
                    offsetPosX = 1121 - textScorePosX
                end
                Btn_TopBottom:setPositionX(textScorePosX + offsetPosX)
                local diff = textScorePosX + offsetPosX - origiPosX
                Btn_TopBottom:setVisible(true)

                Text_TopBottom:setPositionX(Text_TopBottom:getPositionX() - diff)
                Image_TopBottom:setPositionX(Image_TopBottom:getPositionX() - diff)

                -- 设置破产提示语
                local content = string.format(self._gameController:getGameStringByKey("G_GAME_RESULT_BTN_BOTTOM_TIP"))
                local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                Text_TopBottom:setString(utf8Content)
                local textSize = Text_TopBottom:getSize()
                Image_TopBottom:setContentSize(textSize.width + 20, Image_TopBottom:getSize().height)

                local a2 = cc.DelayTime:create(2)
                local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
                   if Image_TopBottom and Image_TopBottom:isVisible() then
                        Image_TopBottom:setVisible(false)
                        Text_TopBottom:setVisible(false)
                        Image_jiantou:setVisible(false)
                    end
                end))
                Btn_TopBottom:runAction(a4)
            end
        end
    end
end

return MyJiSuResultPanel