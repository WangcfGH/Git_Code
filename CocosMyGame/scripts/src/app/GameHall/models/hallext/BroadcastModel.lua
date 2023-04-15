
local BaseModel                 = require('src.app.GameHall.models.BaseModel')
local BroadcastModel            = class("BroadcastModel", BaseModel)

local AssistModel     	        = mymodel('assist.AssistModel'):getInstance()
local treepack                  = cc.load('treepack')

--本地模拟消息
--local testMsg = {
--    "1234567890abcdefghijklmnopqrstuvwxyz1234567890abc",
--    "1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz",
--    "1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnffffffffffffff",
--}

my.addInstance(BroadcastModel)
my.setmethods(BroadcastModel, cc.load('coms').PropertyBinder)

cc.exports.BroadcastDef = {
    BroadcastVersion            = "v1.0.20170316",
	
    GR_BROADCAST_MSG            = 405000,       -- 消息通知
    GR_BROADCAST_CONFIG         = 405001,       -- 获取走马灯配置
--  GR_BROADCAST_FROM_GAMESVR	= 405002,       -- 从游戏服务来的广播消息

    -- 消息来源
    enMsgTypeNormal             = 0,            -- 普通消息
    enMsgTypeRollItem           = 1,            -- 拉霸
    enMsgTypeLottery            = 2,            -- 抽奖
    enMsgTypeImportant          = 3,            -- 紧急消息, 优先级最高
    enMsgTypeNotice             = 4,            -- 网站公告, 网站读取的公告
    enMsgTypeLocal              = 5,            -- 本地消息, 本地公告, 非联网也能播放
    enMsgTypeTask               = 6,            -- 任务
    enMsgTypeGame               = 7,            -- 游戏
    enMsgTypeArena              = 8,            -- 比赛
    enMsgTypeExchange           = 9,            -- 兑换
    enMsgTypeEmail              = 10,           -- 邮件
    enMsgTypeChat               = 11,           -- 聊天
    enMsgTypeNobilityShow       = 12,           -- 贵族显示
    enMsgTypeLuckyCat           = 13,           -- 招财猫升级
    enMsgTypeRechargeFlopCard   = 14,           -- 充值翻翻乐
    enMsgTypeInvite             = 15,           -- 老玩家邀请

    enMsgTypeCustom             = 100,           -- 自定义消息请加在该值之后

    NobilityPrivilegeBroadcastRet        = "NobilityPrivilegeBroadcastRet"
}

local BroadcastReq = {
	BROADCAST_CONFIG={
		lengthMap = {
			[3] = 260,
			[5] = { maxlen = 3 },
			maxlen = 5
		},
		nameMap = {
			'bEnable',		-- [1] ( int )
			'nMoveSpeed',		-- [2] ( int )
			'szNoticeUrl',		-- [3] ( char )
			'nRunType',		-- [4] ( int )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i2Ai4',
		deformatKey = '<i2A260i4',
		maxsize = 284
	},
    
	MESSAGE_INFO={
		lengthMap = {
			[2] = 256,
			[3] = { maxlen = 4 },
			maxlen = 3
		},
		nameMap = {
			'enMsgType',		-- [1] ( int )
			'szMsg',		-- [2] ( char )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<iAi4',
		deformatKey = '<iA256i4',
		maxsize = 276
	},
    
	BROADCAST_MSG={
		lengthMap = {
			[2] = { refered = 'MESSAGE_INFO', complexType = 'link_refer' },
			[6] = { maxlen = 4 },
			maxlen = 6
		},
		nameMap = {
			'nDelaySec',		-- [1] ( int )
			'MessageInfo',		-- [2] ( refer )
			'nRoadID',		-- [3] ( int )
			'nRepeatTimes',		-- [4] ( int )
			'nInterval',		-- [5] ( int )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<i2Ai11',
		deformatKey = '<i2A256i11',
		maxsize = 308
	}	
}
cc.load('treepack').resolveReference(BroadcastReq)

local intervalInGame = 30;      -- 游戏内显示公告跑马灯 间隔 0表示不限制
local timesInGame = 2;          -- 游戏内显示公告跑马灯 每局每条次数

function BroadcastModel:onCreate()
    self._broadcastConfig       = nil   -- 走马灯配置
    self._runningMsgList        = { }   -- 消息滚动队列
    self._broadcastManager      = { }   -- 消息管理
    self._switchAction          = { }

    if self._init then self:_init() end
end

function BroadcastModel:_init()
    --代码评审 周斌 考虑改个名字
    AssistModel:registCtrl(self, self.dealwithResponse)
end

--代码评审 self._switchAction的定义的位置不合理 jj
function BroadcastModel:queryConfig()
    self._switchAction = {
        [BroadcastDef.GR_BROADCAST_CONFIG]    = function(data)
            self:onBroadcastConfig(data)
        end,

        [BroadcastDef.GR_BROADCAST_MSG]       = function(data)
            self:onBroadcastMsg(data)
        end,
    }

    AssistModel:sendData(BroadcastDef.GR_BROADCAST_CONFIG)
end

function BroadcastModel:isResponseID(request)
    return self._switchAction[request] ~= nil
end

function BroadcastModel:dealwithResponse(dataMap)
    local request, data = unpack(dataMap.value)

    if self._switchAction[request] then
        self._switchAction[request](data)
    elseif request then
        print('BroadcastModel received other unknown msg = ' .. request)
    end
end

function BroadcastModel:onBroadcastConfig(data)
    if not data then return end

    self._broadcastConfig = treepack.unpack(data, BroadcastReq["BROADCAST_CONFIG"])

    if self._broadcastConfig.bEnable == 1 and string.len(self._broadcastConfig.szNoticeUrl) > 0 then
        self:getHttpNotice(self._broadcastConfig.szNoticeUrl)
    end

    if BusinessUtils:getInstance():isGameDebugMode() and testMsg then
        for i=1, #testMsg do
            local messageInfo = {}
            messageInfo.szMsg = testMsg[i]
            self:insertRunningMsg(messageInfo)
        end
    end
end

function BroadcastModel:onBroadcastMsg(data)
    if not data then return end

    local broadcastMsg = treepack.unpack(data, BroadcastReq["BROADCAST_MSG"])
    broadcastMsg.MessageInfo.szMsg = MCCharset:getInstance():gb2Utf8String(broadcastMsg.MessageInfo.szMsg, string.len(broadcastMsg.MessageInfo.szMsg))

    if self:isMsgShow(broadcastMsg.MessageInfo.enMsgType) then
        self:insertBroadcastMsg(broadcastMsg)
    else
        print(">>>>>>>>igore one message: msgtype=" .. broadcastMsg.MessageInfo.enMsgType .. ", msginfo=" .. broadcastMsg.MessageInfo.szMsg)
    end
end

--代码评审 增加注释 jj 优化方法（和大师兄讨论）
function BroadcastModel:getHttpNotice(szNoticeUrl)    
    local getNewActivityBaseUrl     = myhttp.getNewActivityBaseUrl
    local activitysConfig           = require('src.app.HallConfig.ActivitysConfig')  
    local url = getNewActivityBaseUrl().."/api/RollNews/getList".. "?GameCode=" .. my.getAbbrName()
    url = url .. "&GroupId="..activitysConfig.NewActivity
    url = url .. "&GameId="..my.getGameID()
    url = url .. "&ChannelId="..BusinessUtils:getInstance():getRecommenderId()
    url = url .. "&VersionNo="..my.getGameVersion()
    url = url .. "&UserTypeId=0"

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", url)

    print("BroadcastModel:getHttpNotice: " .. url)

    local function callBack()
        local json = cc.load("json").json
        if (xhr.status == 200) then
            print("Get Notices Success")
--            local str = xhr.response
--            str = string.gsub(str, "\\u003c", "<")
--            str = string.gsub(str, "\\u003e", ">")
--            local a = json.decode_scanArray(xhr.response, 1)
--            local b = json.decode_scanComment(xhr.response)
--            local c = json.decode_scanConstant(xhr.response)
--            local d = json.decode_scanNumber(xhr.response)
--            local e = json.decode_scanObject(xhr.response)
--            local f = json.decode_scanString(xhr.response)
--            local g = json.decode_scanWhitespace(xhr.response)
--            local h = json.encodeString(xhr.response)
--            local i = json.decode(xhr.response)
--            local j = json.encode(xhr.response)

            local function urlDecode(s)
                s = string.gsub(s, '\\u(%x%x%x%x)', function(h) return string.char(tonumber(h, 16)) end)
                return s  
            end  

            local str = (urlDecode(xhr.response))

            self:noticeFromHttp(json.decode(str))
        end
    end

    xhr:registerScriptHandler(callBack)
    xhr:send()
end

--代码评审 存在原生接口 优化方法 jj（和朱鲁超讨论）
-- 将"2017-12-27 23:59:59"字符串时间转换成时间戳
function BroadcastModel:string2time(timeString)
    -- 非数字字符转成|, (%D表示非数字字符), "2017|12|27|23|59|59"
    local times = string.gsub(timeString, "%D", "|")
    --拆分成table
    times = string.split(times, "|")

    -- 返回1514390399
    return os.time( { year = times[1], month = times[2], day = times[3], hour = times[4], min = times[5], sec = times[6] })
end

--代码评审 jj model触发插件不合理
function BroadcastModel:resetHttpNotice()
    self:noticeFromHttp(nil)
    my.informPluginByName( { pluginName = 'BroadcastCtrl' })
end

--代码评审 函数过长 逻辑过多 jj
-- 插入Http Notice, 如果为空 根据之前缓存下来的插入
-- 此函数会清除之前已存在的Notice
function BroadcastModel:noticeFromHttp(appJsonObj)
    if appJsonObj then
        self._appJsonObj = appJsonObj
    else
        appJsonObj = self._appJsonObj
        if not appJsonObj then return end
    end

    local noticeLists = appJsonObj['Data']    -- 消息列表
    local curTime = os.time()
    if not noticeLists or not curTime then return end

    self._httpNoticeTimes = nil
    self._insertHttpNoticeIndex = nil
    if self._scheduleHttpID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleHttpID)
        self._scheduleHttpID = nil
    end

    -- 清除之前的 Notice
    self:removeBroadcastMsgByType(BroadcastDef.enMsgTypeNotice)

    if intervalInGame > 0 and gameController and gameController:isGameRunning() then       -- 游戏里面公告
        local insertHttpNoticeMsgInGame = function()
            local noticeList = self:getNextHttpNoticeInGame()
            if not noticeList then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleHttpID)
                self._scheduleHttpID = nil
                return
            end

            local broadcastMsg = treepack.alignpack( { }, BroadcastReq["BROADCAST_MSG"])
            broadcastMsg = treepack.unpack(broadcastMsg, BroadcastReq["BROADCAST_MSG"])

            broadcastMsg.MessageInfo.enMsgType = BroadcastDef.enMsgTypeNotice

            
            broadcastMsg.MessageInfo.szMsg = noticeList['Content'] or ""           
            broadcastMsg.nInterval = 0
            broadcastMsg.nRepeatTimes = 0
            
            self:insertBroadcastMsg(broadcastMsg)
        end
        self._scheduleHttpID = my.scheduleFunc(insertHttpNoticeMsgInGame , intervalInGame)
        
        insertHttpNoticeMsgInGame()
    else
        for __, noticeList in pairs(noticeLists) do
            local broadcastMsg = treepack.alignpack( { }, BroadcastReq["BROADCAST_MSG"])
            broadcastMsg = treepack.unpack(broadcastMsg, BroadcastReq["BROADCAST_MSG"])

            broadcastMsg.MessageInfo.enMsgType = BroadcastDef.enMsgTypeNotice
            --broadcastMsg.MessageInfo.szMsg = noticeList['Content'] or ""
            --解析html文本
--            local msg = noticeList['Content'] or ""
--            local iter = string.gfind(msg, "<p>(.-)</p>")
--            local strTable = {}
--            for str in iter do
--                local colorStr = string.gfind(str, "color: #(.-);")()
--                local FORMAT = "<c=%s>%s<>"
--                local textStr 
--                if colorStr then
--                    textStr = string.gfind(str, ">(.-)<")()             
--                else   
--                    colorStr = "000000"
--                    textStr = str 
--                end
--                table.insert(strTable, string.format(FORMAT, colorStr, textStr))
--            end
            local strTable = self:makeHtmlString(noticeList['Content'] or "")
            broadcastMsg.MessageInfo.szMsg = table.concat(strTable)

            broadcastMsg.nInterval = noticeList['Interval'] or 0
            -- 根据结束时间,计算总共滚动次数
            if broadcastMsg.nInterval > 0 then
                local endTime = noticeList["EndTime"]
                local diffTime = os.difftime(endTime / 1000 - curTime)
                broadcastMsg.nRepeatTimes = diffTime / broadcastMsg.nInterval
                if broadcastMsg.nRepeatTimes > 5 then
                    broadcastMsg.nRepeatTimes = 5
                end
            else
                broadcastMsg.nRepeatTimes = 0
            end

            self:insertBroadcastMsg(broadcastMsg)
        end
    end
end

--解析html
function BroadcastModel:makeHtmlString(htmlmsg)
    local utf8String = cc.load('strings').Utf8String
    local strTable = {}
    local FORMAT = "<c=%s>%s<>"
    local iter = string.gfind(htmlmsg, "<p>(.-)</p>")
    for strex in iter do
        while string.len(strex) > 0 do 
            local colorStr, textStr
            local headi, headj = string.find(strex, "<span(.-)>")
            if headi and headj then 
                if headi == 1 then 
                    colorStr = string.gfind(string.sub(strex, headi, headj), "color: #(.-);")()
                    strex = string.sub(strex, headj + 1)
                    local textFinalIndex = string.find(strex, "<")
                    textStr = string.sub(strex, 1, textFinalIndex - 1)
                    strex = string.sub(strex, textFinalIndex)
                    local endi, endj = string.find(strex, "</span>")
                    strex = string.sub(strex, 1, endi - 1)..string.sub(strex, endj + 1)
                else
                    colorStr = "ffffff"
                    textStr = string.sub(strex, 1, headi - 1)
                    strex = string.sub(strex, headi)
                end
            else
                colorStr = "ffffff"
                textStr = strex 
                strex = ""
            end
            if textStr and string.find(textStr, "<br/>") then 
                textStr = string.gfind(textStr, "(.-)<br/>")()
            end
            table.insert(strTable, string.format(FORMAT, colorStr, textStr)) 
        end     
    end
    return strTable
end

function BroadcastModel:getNextHttpNoticeInGame()
    local appJsonObj = self._appJsonObj
    if not self._appJsonObj then return nil end

    local noticeLists = appJsonObj['NoticeList']    -- 消息列表
    if not noticeLists then return nil end

    for i = 1, #noticeLists do
        if not self._insertHttpNoticeIndex or self._insertHttpNoticeIndex > #noticeLists then
            self._insertHttpNoticeIndex = 1
        end

        local insertHttpNoticeIndex = self._insertHttpNoticeIndex
        self._insertHttpNoticeIndex = insertHttpNoticeIndex + 1

        local noticeList = noticeLists[insertHttpNoticeIndex]

        self._httpNoticeTimes = self._httpNoticeTimes or {}
        self._httpNoticeTimes[insertHttpNoticeIndex] = (self._httpNoticeTimes[insertHttpNoticeIndex] or 0) + 1
        if self._httpNoticeTimes[insertHttpNoticeIndex] <= timesInGame then
            if noticeList and noticeList['Interval'] and noticeList['Interval'] > 0 and os.time() < self:string2time(noticeList["EndTime"]) then
                return noticeList
            end
        end
    end

    return nil
end

function BroadcastModel:insertBroadcastMsg(broadcastMsg)
    printf("insert new broadcastMsg: " .. broadcastMsg.MessageInfo.szMsg)

    self:insertRunningMsg(broadcastMsg.MessageInfo)

    if broadcastMsg.nRepeatTimes > 0 then
        table.insert(self._broadcastManager, broadcastMsg)
        broadcastMsg._scheduleID = my.scheduleFunc( function()
            self:insertRunningMsg(clone(broadcastMsg.MessageInfo))
            broadcastMsg.nRepeatTimes = broadcastMsg.nRepeatTimes - 1

            self:updateBroadcastMsg(broadcastMsg)
        end , broadcastMsg.nInterval)

        self:updateBroadcastMsg(broadcastMsg)
    end
end

function BroadcastModel:updateBroadcastMsg(broadcastMsg)
    if broadcastMsg.nRepeatTimes <= 0 then
        table.removebyvalue(self._broadcastManager, broadcastMsg)

        printf("remove broadcast from manager: " .. broadcastMsg.MessageInfo.szMsg)

        if broadcastMsg._scheduleID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(broadcastMsg._scheduleID)
            broadcastMsg._scheduleID = nil
        end
    end
end

function BroadcastModel:removeBroadcastMsgByType(enMsgType)
    local broadcastManager = {}
    for i, broadcastMsg in ipairs(self._broadcastManager) do
        if broadcastMsg.MessageInfo.enMsgType == enMsgType then
            if broadcastMsg._scheduleID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(broadcastMsg._scheduleID)
                broadcastMsg._scheduleID = nil
            end
        else
            table.insert(broadcastManager, broadcastMsg)
        end
    end
    self._broadcastManager = broadcastManager

    local runningMsgList = {}
    for i, messageInfo in ipairs(self._runningMsgList) do
        if messageInfo.enMsgType ~= enMsgType then
            table.insert(runningMsgList, messageInfo)
        end
    end
    self._runningMsgList = runningMsgList

    local function sortMsgType(messageInfo1, messageInfo2)
        if self:calcMsgTypeOrder(messageInfo1.enMsgType) == self:calcMsgTypeOrder(messageInfo2.enMsgType) then
            return messageInfo1.nGetTime < messageInfo2.nGetTime
        end
        return self:calcMsgTypeOrder(messageInfo1.enMsgType) > self:calcMsgTypeOrder(messageInfo2.enMsgType)
    end
    table.sort(self._runningMsgList, sortMsgType)
end


function BroadcastModel:stopAllBroadcastMsgSchedule()
    local tempValue = {}
    for _, v in pairs(self._broadcastManager) do
        if v._scheduleID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(v._scheduleID)
            v._scheduleID = nil
        end
        if v.nRepeatTimes <= 0 then
            table.insert(tempValue, v)
        end
    end
    for _, v in pairs(tempValue) do
        table.removebyvalue(self._broadcastManager, v)
    end
end

function BroadcastModel:startAllBroadcastMsgSchedule()
    for _, v in pairs(self._broadcastManager) do
        if not v._scheduleID then
            v._scheduleID = my.scheduleFunc( function()
                self:insertRunningMsg(clone(v.MessageInfo))
                v.nRepeatTimes = v.nRepeatTimes - 1
                
                self:updateBroadcastMsg(v)
            end , v.nInterval)
        end
    end
end

function BroadcastModel:insertRunningMsg(messageInfo)
    if not self._broadcastConfig then return end
    if self._broadcastConfig.bEnable == 0 then return end



    local curScene = cc.Director:getInstance():getRunningScene()
    
    -- 网站公告：如果当前场景不需要显示， 那么不插入 不需要缓存下来
    if messageInfo.enMsgType == BroadcastDef.enMsgTypeNotice then
        if not curScene or not curScene.ShowBroadcast then return end
    end

    messageInfo.nGetTime = socket.gettime()

    printf("insert new runningMsg: " .. messageInfo.szMsg)

    if self._stoppingInsert == true then
        if not self._tempMessageList then
            self._tempMessageList = {}
        end
        table.insert(self._tempMessageList, messageInfo)
        return
    end
    
    table.insert(self._runningMsgList, messageInfo)
    -- 根据消息类型排序
    local function sortMsgType(messageInfo1, messageInfo2)
        if self:calcMsgTypeOrder(messageInfo1.enMsgType) == self:calcMsgTypeOrder(messageInfo2.enMsgType) then
            return messageInfo1.nGetTime < messageInfo2.nGetTime
        end
        return self:calcMsgTypeOrder(messageInfo1.enMsgType) > self:calcMsgTypeOrder(messageInfo2.enMsgType)
    end
    table.sort(self._runningMsgList, sortMsgType)

    if #self._runningMsgList > 50 then
        self:stopAllBroadcastMsgSchedule()
    end
    -- 触发播放
    if curScene and curScene.ShowBroadcast then
        my.informPluginByName( { pluginName = 'BroadcastCtrl' })
    end
end

function BroadcastModel:getFirstMsg(bRemove)

    local messageInfo = nil

    if #self._runningMsgList > 0 then
        messageInfo = self._runningMsgList[1]

        if bRemove then
            table.remove(self._runningMsgList, 1)           
        end
    end

    if #self._runningMsgList < 10 then
        self:startAllBroadcastMsgSchedule()
    end

    return messageInfo
end

-- 该函数判断是否显示某类型的公告, 比如抽奖公告是否显示由抽奖开关控制
function BroadcastModel:isMsgShow(enMsgType)
    if enMsgType == BroadcastDef.enMsgTypeLottery then -- 抽奖消息
        return cc.exports.isLoginLotterySupported and cc.exports.isLoginLotterySupported()
    end

    return true
end

-- 计算消息的排序值, 越大越靠前
function BroadcastModel:calcMsgTypeOrder(enMsgType)
    local orderValues = {
        [BroadcastDef.enMsgTypeImportant] = 1000,
        [BroadcastDef.enMsgTypeNotice] = 100,
    }

    return orderValues[enMsgType] or 0
end

function BroadcastModel:stopInsertMessage()
    self._stoppingInsert = true
end

function BroadcastModel:ReStartInsetMessage()
    self._stoppingInsert = false
    if self._tempMessageList and next(self._tempMessageList) ~= nil then
        for i = 1,#self._tempMessageList - 1 do
            if self._tempMessageList[i] then
                table.insert(self._runningMsgList, self._tempMessageList[i])
            end
        end
        if self._tempMessageList[#self._tempMessageList] then
            self:insertRunningMsg(self._tempMessageList[#self._tempMessageList])
        end
        self._tempMessageList = {}
    end
end

function BroadcastModel:ReStartInsertMessageEx()
    self._stoppingInsert = false
    self._tempMessageList = {}
end

return BroadcastModel
