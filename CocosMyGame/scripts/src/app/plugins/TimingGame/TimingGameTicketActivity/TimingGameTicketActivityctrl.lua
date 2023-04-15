--该程序应该与每日活动相对关
local viewCreater=import('src.app.plugins.TimingGame.TimingGameTicketActivity.TimingGameTicketActivityview')
local TimingGameTicketActivityCtrl=class('DailyActivitysCtrl',cc.load('BaseCtrl'))
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance() 

function TimingGameTicketActivityCtrl:onCreate( ActivityCenterCtrl )
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:init(ActivityCenterCtrl)
end

--view的实例作为入参，绑定点击的事件
function TimingGameTicketActivityCtrl:init(ActivityCenterCtrl)

    --获取到定时赛的配置信息
    local config = TimingGameModel:getConfig()

    --获取每个奖励等级最低的房间号
    local tblRooms = TimingGameModel:getTimingGameLowestGradeBoutTicketRoom()

    if (not config or not tblRooms) then
        return
    end
    
    --显示对局送门票的要求等级的text gradeNameZh
    if(tblRooms and type(tblRooms) == "table") then
        self._viewNode.txt1_1:setString(string.format( "%s及以上",tblRooms[1].gradeNameZh))
        self._viewNode.txt1_2:setString(string.format( "%s及以上",tblRooms[2].gradeNameZh))
        self._viewNode.txt1_3:setString(string.format( "%s及以上",tblRooms[3].gradeNameZh))
        self._viewNode.txt1_4:setString(string.format( "%s及以上",tblRooms[4].gradeNameZh))
    end

    --获取对局送门票每个档次的局数
    local num2_1 = config.GradeBoutObtainTickets[1].MinBoutNum
    local num2_2 = config.GradeBoutObtainTickets[2].MinBoutNum
    local num2_3 = config.GradeBoutObtainTickets[3].MinBoutNum
    local num2_4 = config.GradeBoutObtainTickets[4].MinBoutNum
    --获取对局送门票活动每个档次的奖励
    local num3_1 = config.GradeBoutObtainTickets[1].BoutExchangeTicketsNum
    local num3_2 = config.GradeBoutObtainTickets[2].BoutExchangeTicketsNum
    local num3_3 = config.GradeBoutObtainTickets[3].BoutExchangeTicketsNum
    local num3_4 = config.GradeBoutObtainTickets[4].BoutExchangeTicketsNum
    

    --显示对局送门票的局数的text
    self._viewNode.txt2_1:setString(string.format( "%d局",num2_1))
    self._viewNode.txt2_2:setString(string.format( "%d局",num2_2))
    self._viewNode.txt2_3:setString(string.format( "%d局",num2_3))
    self._viewNode.txt2_4:setString(string.format( "%d局",num2_4))
    --显示对局送门票的奖励的text
    self._viewNode.txt3_1:setString(string.format( "%d张门票",num3_1))
    self._viewNode.txt3_2:setString(string.format( "%d张门票",num3_2))
    self._viewNode.txt3_3:setString(string.format( "%d张门票",num3_3))
    self._viewNode.txt3_4:setString(string.format( "%d张门票",num3_4))


    --绑定点击事件，点击后进入不洗牌游戏模式
    self._viewNode.Button_go:addClickEventListener(function()
        self:playEffectOnPress()
        if not CenterCtrl:checkNetStatus() then
            return false
        end
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end)
end


return TimingGameTicketActivityCtrl
