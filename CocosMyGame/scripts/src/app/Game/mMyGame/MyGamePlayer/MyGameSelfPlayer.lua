local SKGameSelfPlayer = import("src.app.Game.mSKGame.SKGameSelfPlayer")
local MyGameSelfPlayer = class("MyGameSelfPlayer", SKGameSelfPlayer)

function MyGameSelfPlayer:init()
    MyGameSelfPlayer.super.init(self)
    self._nodeJingBao = self._playerPanel:getChildByName("Node_JingBao")

    --屏蔽自己的名字和点赞数
    local img_info_bg = self._playerInfoHead:getChildByName("Img_InfoBG") --自己新增姓名板  不用原来那套
    img_info_bg:setVisible(false)
end

function MyGameSelfPlayer:initPlayer()
    MyGameSelfPlayer.super.initPlayer(self)
end

function MyGameSelfPlayer:setAlarm(isHaveAlarm)
    self._haveAlarm = isHaveAlarm
end

function MyGameSelfPlayer:tipJingBao()
    --do nothing
end

--重载：屏蔽等级
function MyGameSelfPlayer:updataUserLevelInfo(msgLevelData)
    MyGameSelfPlayer.super.updataUserLevelInfo(self,msgLevelData)

    self._playerLevelImage:setVisible(false)
end

--重载：屏蔽头像旁边的点赞按钮
function MyGameSelfPlayer:updataOtherUpInfo(upData, index)
    MyGameSelfPlayer.super.updataOtherUpInfo(self,upData, index)

    self._playerInfoHead:getChildByName("Btn_Praise"):setVisible(false)
end
--重载：屏蔽头像旁边的点赞按钮
function MyGameSelfPlayer:setShowUpInfo(upInfo)
    MyGameSelfPlayer.super.setShowUpInfo(self,upInfo)

    self._playerInfoHead:getChildByName("Btn_Praise"):setVisible(false) 
end


--重载：屏蔽动画
function MyGameSelfPlayer:onShrinkHeadAnimation()
end

function MyGameSelfPlayer:onStretchHeadAnimation()
end

--屏蔽自己的名字和点赞数
function MyGameSelfPlayer:hideAllChildren()
    MyGameSelfPlayer.super.hideAllChildren(self)

    local img_info_bg = self._playerInfoHead:getChildByName("Img_InfoBG")
    img_info_bg:setVisible(false)
end

--获取点赞信息
function MyGameSelfPlayer:showPraiseTextInfo() 
    local playerUpNum = self._playerInfoHead:getChildByName("Img_InfoBG"):getChildByName("Value_Praise"):getString()
    local praiseText = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_praise")
    if praiseText then
        praiseText:setString(playerUpNum)
    end
end

--获取地理位置
function MyGameSelfPlayer:showPositionTextInfo()
    ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Value_position"):setVisible(false)
    ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_position"):setVisible(false)
end

--重载：显示详情界面的点赞信息
function MyGameSelfPlayer:showPlayerInfo(bShow)
    MyGameSelfPlayer.super.showPlayerInfo(self, bShow)
    if self._playerInfoPanel then
        if bShow then
            self:showPraiseTextInfo()
            self:showPositionTextInfo()
        end
    end
end

function MyGameSelfPlayer:showPlayerName(playerInfo)
    local name = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Name")
    if name then
        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
        local utf8nickname = userPlugin:getNickName()
        if utf8nickname then
            my.fitStringInWidget(utf8nickname, name, 267)
        end
    end
end

-- function MyGameSelfPlayer:showPlayerName(playerInfo)
--     local name = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Text_Name")
--     if name then
--         local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
--         local utf8nickname = userPlugin:getNickName()

--         local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()  
--         if tcyFriendPlugin then
--            if(tcyFriendPlugin:isFriend(playerInfo.nUserID))then
--                local remark = tcyFriendPlugin:getRemarkName(playerInfo.nUserID)
--                if(remark~="")then
--                     local gbkName = MCCharset:getInstance():utf82GbString(remark, string.len(remark))         
--                     userName = gbkName
--                end
--            end
--         end

--         if utf8nickname then
--             --[[if 10 < string.len(userName) then
--                 userName = string.sub(userName, 1, 8).."..."
--             end]]
--             --local utf8Name = MCCharset:getInstance():gb2Utf8String(userName, string.len(userName))
--             my.fixUtf8Width(utf8nickname, name, 192)
--             --name:setString(utf8Name)
--         end
--     end
-- end

--不显示自己的牌张数
function MyGameSelfPlayer:setCardsCount(cardsCount, bSound)
    self._playerCards:setVisible(false)
end

--使用新头像
function MyGameSelfPlayer:setNickSex(nNickSex)
    self._nickSex = nNickSex
    if self._playerHead then
        local resName = ""
        if 1 == nNickSex then
            resName = "res/Game/GamePic/GameContents/touxiang_girl.png"
        else
            resName = "res/Game/GamePic/GameContents/touxiang_boy.png"
        end
        self._playerHead:setTexture(resName)
    end

    --显示自己的头像框
    self._playerInfoHead:getChildByName("touxiangkuang"):setVisible(true)
end

--原来是imag，现在是sprite，换成setTexture
function MyGameSelfPlayer:showRobot(bRobot)
    if self._playerInfoHead then
        if bRobot then
            self._playerInfoHead:getChildByName("Icon_Robot"):setVisible(true)
            local resName = "res/Game/GamePic/GameContents/Role_Robot.png"
            self._playerInfoHead:getChildByName("Icon_Robot"):setTexture(resName)
        else
            self._playerInfoHead:getChildByName("Icon_Robot"):setVisible(false)
        end
    end
end

--重载：屏蔽控件显示
function MyGameSelfPlayer:setLbs(nUserID, lbs)
    MyGameSelfPlayer.super.setLbs(self, nUserID,lbs)

    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    for i = 1, self._gameController:getTableChairCount() do
        if playerManager._players[i] and playerManager._players[i]._playerUserID == nUserID then
            local label = playerManager._players[i]._playerLbs
            if label then
                local parent = label:getParent():getParent()
                if parent then
                    label:setVisible(false)
                    parent:setVisible(false)
                end
            end
        end
    end
end

return MyGameSelfPlayer
