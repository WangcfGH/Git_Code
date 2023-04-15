local MyTimeStampCtrl = class('MyTimeStampCtrl',require('src.app.GameHall.models.BaseModel'))

local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local treepack  = cc.load('treepack')
local player = mymodel('hallext.PlayerModel'):getInstance()
local coms=cc.load('coms')

local PropertyBinder=coms.PropertyBinder
my.setmethods(MyTimeStampCtrl,PropertyBinder)
my.addInstance(MyTimeStampCtrl)

MyTimeStampCtrl.UPDATE_STAMP = "UpdateStamp"
MyTimeStampCtrl.UPDATE_MONTH = "UpdateMonth"
MyTimeStampCtrl.UPDATE_DAY = "UpdateDay"

local MyTimeStampDef = {
    GR_GET_NOW_TIME_STAMP 	= 410320 -- 定时更新时间
}

local  MyTimeStampReq = {
	TIME_STAMP_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			maxlen = 1
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
	},
	
	TIME_STAMP_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = dwCurrentSec( unsigned long )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'dwCurrentSec',		-- [2] ( unsigned long )
		},
		formatKey = '<iL',
		deformatKey = '<iL',
		maxsize = 8
	},
};

function MyTimeStampCtrl:onCreate()
    self:initAssistResponse()

    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onPlayLoginOff))
    self._notifyUpdateStamp = nil
end

function MyTimeStampCtrl:initAssistResponse()
    self._info = {}
    self._assistResponseMap = {
        [MyTimeStampDef.GR_GET_NOW_TIME_STAMP] = handler(self, self.onTimeStampRecieved)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

-- 定时器开启
function MyTimeStampCtrl:startTimerSchedule()
    self:gc_TimeStampReq()
    
    local function onGetTime()
        self:gc_TimeStampReq()
    end

    if self.onRecieveTimerID then       
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onRecieveTimerID)
        self.onRecieveTimerID = nil
    end

    if not self.onRecieveTimerID then  
        self.onRecieveTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onGetTime, 600, false)  -- 每10分钟获取一次
    end
end

-- 定时器关闭
function MyTimeStampCtrl:onPlayLoginOff()
    if self.onRecieveTimerID then       
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onRecieveTimerID)
        self.onRecieveTimerID = nil
    end

    if self.onTimerID then       
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onTimerID)
        self.onTimerID = nil
    end
end

-- 时间戳请求
function MyTimeStampCtrl:gc_TimeStampReq()
    if user.nUserID == nil or user.nUserID < 0 then
        print("MyTimeStampCtrl userinfo is not ok")
        return
    end

    local data = {
        nUserID = user.nUserID,
    }

    AssistModel:sendRequest(MyTimeStampDef.GR_GET_NOW_TIME_STAMP, MyTimeStampReq.TIME_STAMP_REQ, data, false)
end

function MyTimeStampCtrl:onStampResume()
    self._notifyUpdateStamp = true
    self:gc_TimeStampReq()
end

-- 时间戳响应
function MyTimeStampCtrl:onTimeStampRecieved(data)
    local info = AssistModel:convertDataToStruct(data, MyTimeStampReq["TIME_STAMP_RESP"]);
    if info.nUserID ~= user.nUserID then
        return
    end
    local bCheckMonth = false
    local monthbefore
    if next(self._info)~=nil then
        bCheckMonth = true
        monthbefore = os.date('%m',self._info.dwCurrentSec)
    end
    
    self._info = info
    if self._info.dwCurrentSec and self._info.dwCurrentSec > 0 then
        local function stepStamp()
            self._info.dwCurrentSec = self._info.dwCurrentSec + 1
            if DEBUG and DEBUG > 0 then
            local currTime = os.date("%Y-%m-%d  %H:%M:%S", self._info.dwCurrentSec)
            ----print("current server time : "..currTime)
            end
            local curTimeTbl = os.date("*t", self._info.dwCurrentSec)
            local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
            if (curTimeTbl.min == 0 and curTimeTbl.sec == 30) or (curTimeTbl.min == 30 and curTimeTbl.sec == 30) then --整点过一分或半点过一分重置下定时赛记录请求时间
                print("MyTimeStampCtrl:onTimeStampRecieved Time, min 0 sec 0 st:", self._info.dwCurrentSec)
                TimingGameModel:resetLast2ReqRecordTime()
                TimingGameModel:reqTimingGameConfig() --查询定时赛配置
                TimingGameModel:reqTimingGameInfoData() --查询定时赛状态
            end

            if (curTimeTbl.hour == 0 and curTimeTbl.min == 0 and curTimeTbl.sec == 30) then --整点过半分
                print("MyTimeStampCtrl:onTimeStampRecieved Time, min 0 sec 0 st:", self._info.dwCurrentSec)
                local WeekMonthSuperCardModel       = require("src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel"):getInstance()                
                WeekMonthSuperCardModel:updateDay()
            end

            if (curTimeTbl.hour == 0 and curTimeTbl.min == 0 and curTimeTbl.sec == 30) then --整点过半分
                local RechargePoolModel = require("src.app.plugins.rechargepool.RechargePoolModel"):getInstance()
                RechargePoolModel:reqRechargeActivityInfo()
                local GratitudeRepayModel = require('src.app.plugins.GratitudeRepay.GratitudeRepayModel'):getInstance()
                GratitudeRepayModel:QueryGratitudeRepayInfo()

                local GoldSilverModel = require('src.app.plugins.goldsilver.GoldSilverModel'):getInstance()
                GoldSilverModel:GoldSilverInfoReq()
                local GoldSilverModelCopy = require('src.app.plugins.goldsilverCopy.GoldSilverModelCopy'):getInstance()
                GoldSilverModelCopy:GoldSilverInfoReq()
            end
        end

        if not self.onTimerID then
            self.onTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(stepStamp, 1, false) 
        end
    end
    local monthafter = os.date('%m',self._info.dwCurrentSec)
    
    if true == self._notifyUpdateStamp then
        self:dispatchEvent({name=self.UPDATE_STAMP})
        self._notifyUpdateStamp = nil 
    end

    if bCheckMonth and monthbefore~=monthafter then
        self:dispatchEvent({name=self.UPDATE_MONTH})
    end

    if not self._currentDay then
        self._currentDay = os.date('%d',self._info.dwCurrentSec)
    else
        local tmp = os.date('%d',self._info.dwCurrentSec)
        if tmp ~= self._currentDay then
            self._currentDay = tmp
            self:dispatchEvent({name=self.UPDATE_DAY})
        end
    end
end

-- 获取最近一次拿到的时间戳
function MyTimeStampCtrl:getLatestTimeStamp()
    if self._info and self._info.dwCurrentSec and self._info.dwCurrentSec > 0 then
        return self._info.dwCurrentSec
    end
    return 0
end

return MyTimeStampCtrl