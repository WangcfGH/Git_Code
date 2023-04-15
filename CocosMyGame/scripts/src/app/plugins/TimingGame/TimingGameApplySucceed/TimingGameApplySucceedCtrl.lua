local TimingGameApplySucceedCtrl = class('TimingGameApplySucceedCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameApplySucceed.TimingGameApplySucceedView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')
local player=mymodel('hallext.PlayerModel'):getInstance()

function TimingGameApplySucceedCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:bindSomeDestroyButtons(viewNode,{
		'btnConfirm',
		'btnClose',
	})
    
    local bindList={
		'btnConfirm',
	}
	
    self:bindUserEventHandler(viewNode,bindList)
    self:initView()
    self:bindProperty(player, 'PlayerData', self, 'PlayerData')
end

function TimingGameApplySucceedCtrl:initView()
    local applyInfo = TimingGameModel:getApplyInfo()
    if not applyInfo then
         return 
    end
    self._viewNode.txtScore:setString(applyInfo.initialScore)
end

function TimingGameApplySucceedCtrl:btnConfirmClicked()
    local result = TimingGameModel:canStartMatch()
    if result == TimingGameDef.TIMING_GAME_CAN_START_MATCH then
        if TimingGameModel:isAbortBoutTimeNotEnough() then
            TimingGameModel:showTips("因结算需要，最后5分钟停止比赛!")
        else
            if my.isInGame() and PUBLIC_INTERFACE.IsStartAsTimingGame() then
                TimingGameModel:dispatchRestartGame()
            else
                TimingGameModel:gotoTimingGameRoom()
            end
        end
    elseif result == TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD then
        TimingGameModel:showTips("还未到比赛时间，请稍后再试~!")
    elseif result == TimingGameDef.TIMING_GAME_NOT_APPLY then
        TimingGameModel:showTips("请先报名参赛!")
    elseif result == TimingGameDef.TIMING_GAME_BOUT_NUM_OVER_LIMIT then
        TimingGameModel:showTips("对局次数已满，请重新报名!")
    elseif result == TimingGameDef.TIMING_GAME_SCORE_NOT_ENOUGH then
        TimingGameModel:showTips("积分不足，请重新报名!")
    end
end

function TimingGameApplySucceedCtrl:setPlayerData(data)
    if(data.nUserID)then
        self:setPlayerName(data)
    end
end
function TimingGameApplySucceedCtrl:setPlayerName(data)
    local viewNode = self._viewNode
    
    local nickName = NickNameInterface.getNickName()
    local userName = nickName or data.szUtf8Username
    my.fitStringInWidget(userName, viewNode.txtUserName, 176)
end

return TimingGameApplySucceedCtrl