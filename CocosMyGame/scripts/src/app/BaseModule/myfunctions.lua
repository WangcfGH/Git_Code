cc.exports.my={}

local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
function my.mxpcall(f,x)

	local status, msg = xpcall(f,x)
	if not status then
		if analyticsPlugin then
			analyticsPlugin:logError("errorid", msg)
		end
	end

	return status,msg
end

function my.setmethods(target, component)
	table.merge(target,component)
end

function my.unsetmethods(target, component)
	for name,_ in ipairs(component) do
		target[name] = nil
	end
end

function my.finish()
    my.scheduleOnce(function ()
        if(mc and mc.createClient)then
            local mclient=mc.createClient()
            mclient:destroy('hall')
            mclient:destroy('room')
        end
        local agent = MCAgent:getInstance()
        agent:endToLua()
    end,0.2)

    local mclient=mc.createClient()
    mclient:sendRequest(mc.LOGOFF_USER, {}, 'hall', false)

    my.dataLink(cc.exports.DataLinkCodeDef.APP_QUIT_MB, {connectStatus = my.getNetworkTypeString(), ui = 'Main'})
end

--note: expected to be renamed to addSingleInstance
function my.addInstance(cls)
	local instance = '_instance'
    rawset(cls, instance, nil)
	function cls:getInstance(...)
		if not rawget(self, instance) then
            rawset(self, instance, self:create(...))
		end
		return rawget(self, instance)
    end
    
    function cls:isInstanceExist()
        return rawget(self, instance) ~= nil
    end

	function cls:removeInstance()
        rawset(self.class, instance, nil)
	end
end

local oldAddClickEventListener = ccui.Widget.addClickEventListener
local function newAddClickEventListener(...)
    local sender, callback = ...

    oldAddClickEventListener(sender, function(...)
        if sender:isVisible() then
            callback(...)
        else
            if sender.getName then
                local name = sender:getName()
                my.dataLink(cc.exports.DataLinkCodeDef.CLICK_EVENT_LISTENER, {sendName = name})
            end
        end
    end)
end
ccui.Widget.addClickEventListener = newAddClickEventListener

local Button=ccui.Button

local function _getButtonOnClickScale(button)
	-- body
	local size = button:getContentSize()
	local length=size.width+size.height
	local d = 15+1.043*length-32/(1+length)
	local scale=d/(1+length)
	return scale
end

assert(Button.___type==nil,'')
function my.presetAllButton(root)
	Button.___type='Button'
	local children=root:getChildren()
	for _,v in pairs(children)do
		if(v.___type and v.___type=='Button')then
			--v:setZoomScale(0.15)
			--v:setPressedActionEnabled(true)
			v:onTouch(function(e)
				if(e.name=='began')then
                    e.target:setColor(cc.c3b(166,166,166))
					--e.target:setScale(_getButtonOnClickScale(e.target))
				elseif(e.name=='ended' or e.name=='cancelled')then
					--e.target:setScale(1.0)
                    e.target:setColor(cc.c3b(255,255,255))
				end
			end)
		end
		my.presetAllButton(v)
		Button.___type='Button'
	end
	Button.___type=nil
	return root
end

local cc_loaded_packages=cc.loaded_packages
local function getmodel(modelname)
	local model=cc_loaded_packages[modelname]
	if(model)then
		return model
	else
		model=import('src.app.GameHall.models.'..modelname)
		cc.register(modelname,model)
		return model
	end
end

local function getctrl(ctrlname)
	return import('src.app.GameHall.ctrls.'..ctrlname)
end

local function getview(viewname)
	return import('src.app.GameHall.views.'..viewname)
end

cc.exports.mymodel=getmodel
cc.exports.myctrl=getctrl
cc.exports.myview=getview

local scheduler=cc.Director:getInstance():getScheduler()
function my.scheduleOnce(f,delay)
	local id
	id=scheduler:scheduleScriptFunc(function()
		scheduler:unscheduleScriptEntry(id)
        my.mxpcall(f, __G__TRACKBACK__)
	end,delay or 0,false)
    return id
end

local scheduleList={}
function my.scheduleFunc(f,delay,bupdate)
	if(scheduleList[f])then
        if bupdate then
            scheduler:unscheduleScriptEntry(scheduleList[f])
        else
            return scheduleList[f]
        end
	end
	scheduleList[f]=scheduler:scheduleScriptFunc(function()
		f()
	end,delay or 0,false)
    return scheduleList[f]
end

function my.unscheduleFunc(f)
	local id=scheduleList[f]
	if(id)then
		scheduler:unscheduleScriptEntry(id)
		scheduleList[f]=nil
	end
end

function my.playClickBtnSound()
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/KeypressStandard.mp3'),false)
end

local scheduleIDArray = {}
function my.createSchedule(f, delay)
    local id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(f, delay or 0, false)
    table.insert(scheduleIDArray, id)
    return id
end

function my.createOnceSchedule(f, delay)
    local id = nil
    local function callfunc()
        my.removeSchedule(id)
        if f then
            f()
        end
    end

    id = my.createSchedule(callfunc, delay)
    return id
end

function my.removeSchedule(id)
    if id then
        table.removebyvalue(scheduleIDArray, id)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
    end
end

function my.removeAllSchedule()
    local array = clone(scheduleIDArray)
    for _, scheduleID in ipairs(array) do
        my.removeSchedule(scheduleID)
    end
end

function my.stringToTable(str)
    local tb = {}
    --[[
    UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00-0x7F(0-127),或者 0xC2-0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5-0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
    3. 0x80-0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
    ]]
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end
    return tb
end
--str：原字符串， length:最大显示文字数(默认12)，suffix:后缀（默认...）
function my.getStringByLength(str, length, suffix)
    local lengthTmp = length or 9
    local suffixTmp = suffix or "..."
    local strTable = my.stringToTable(str)
    if lengthTmp >= #strTable then
        return str
    end
    return table.concat(strTable, "", 1, lengthTmp) .. suffixTmp
end

-- 用于判断是否显示联运游戏，由于ios和android获取平台的接口不一致，所以需要先区分平台
function my.isShowOutlayGameForTcyApp(isPrintLog)
    if device.platform == 'android' then
        if my.isEngineSupportVersion("v1.5.20180530") then
            if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
                local launchMode = MCAgent:getInstance():getLaunchMode()
                local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
                return launchMode == cc.exports.LaunchMode.PLATFORM and launchSubMode ~= cc.exports.LaunchSubMode.PLATFORMSET
            else
                if DEBUG > 0 then
                    printf("MCAgent getLaunchSubMode or getLaunchMode is nil")
                end
                return false
            end
        else
            return true
        end
    elseif device.platform == 'ios' then
        if my.isEngineSupportVersion("v1.5.20180530") then
            if MCAgent:getInstance().getLaunchMode then
                local launchMode = MCAgent:getInstance():getLaunchMode()
                if launchMode == cc.exports.LaunchMode.PLATFORM then
                    return true
                end
            else
                if DEBUG > 0 then
                    printf("MCAgent getLaunchMode is nil")
                end
                return false
            end
        else
            return true
        end
    elseif device.platform == 'windows' then
        return true
    end

    return false
end

function my.setOnlinePic(url, iconTemp, index, callbackSuccess, callbackFailed)
    local thirdPartyImageCtrl = require('src.app.BaseModule.YQWImageCtrl')
    if not thirdPartyImageCtrl then return end
    thirdPartyImageCtrl:getUserhuodongImage(url, function(code, path)
        print("my.setOnlinePic url is ", url)
        print("my.setOnlinePic path is ",  path)

        if code ==cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess then
            callbackSuccess(iconTemp, path)
            print('~~~~~kImageLoadOnlineSuccess~~~~~')
        else
            print('~~~~~kImageLoadOnlineFailed~~~~~')
            -- 如果失败了去设置本地图片
            callbackFailed(iconTemp, index)
        end
    end)
end

--代码评审 杨美玲
local loadingNode, loadingTimer
function my.startLoading(msg, timeoutVal)
    if loadingTimer or loadingNode or cc.exports.jumpHighRoom == true then
        return
    end

    local curScene = cc.Director:getInstance():getRunningScene()
    loadingNode = cc.CSLoader:createNode( "res/hallcocosstudio/hallcommon/loading.csb")
    local panelMain = loadingNode:getChildByName("Panel_Main")
    if panelMain then
        local textLoading = panelMain:getChildByName("Text_Loading")
        if textLoading then
            textLoading:setString(msg or "游戏加载中,请稍等")
        end
        panelMain:setPosition(display.center)
    end
	loadingNode:setContentSize(cc.Director:getInstance():getVisibleSize())
    curScene:addChild(loadingNode)
    local timeLine = cc.CSLoader:createTimeline('res/hallcocosstudio/hallcommon/loading.csb')
    loadingNode:runAction(timeLine)
    timeLine:gotoFrameAndPlay(0, 60, true)
    ccui.Helper:doLayout(loadingNode)

    loadingNode:onNodeEvent("exit", function()
        my.stopLoading()
    end)

    timeoutVal = timeoutVal or 8
    loadingTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(my.stopLoading, timeoutVal, false)
end

function my.isLoading()
    if loadingNode ~= nil then
        return true
    end

    if my.isProcessing() == true then
        return true
    end

    return false
end

function my.stopLoading()
    if loadingTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(loadingTimer)
        loadingTimer = nil
    end

    if loadingNode then
        local temp  = loadingNode
        loadingNode = nil
        temp:removeFromParent()
    end
end

--代码评审 杨美玲
function my.getNeglectedString(gbString, maxLen, limitLen)
    if not gbString or 'string' ~= type(gbString) then return end
    maxLen = (maxLen and 'number' == type(maxLen)) and maxLen or 10
    limitLen = (limitLen and 'number' == type(limitLen)) and limitLen or 8

    if string.len(gbString) > maxLen then
        local nCount = 0
        for i = 1, limitLen do
            if 0x80 >= string.byte(gbString, i) then
                nCount = nCount + 1
            end
        end
        if 0 ~= nCount % 2 then
            limitLen = limitLen + 1
        end 
        if maxLen < string.len(gbString) then
            gbString = string.sub(gbString, 1, limitLen)..".."
        end
    end

    return MCCharset:getInstance():gb2Utf8String(gbString, string.len(gbString))
end

--[Comment]
--参数依次是 str:内容字符串 widget:文本控件 limit:像素长度限制（单位是像素）
--效果是将字符串超出像素限制的内容用".."来表示
function my.fitStringInWidget(str, widget, limit)   
    local utf8String = cc.load('strings').Utf8String
    local _str = str
    widget:setString(_str)
    local contentSize = widget:getContentSize()
    if not limit then return end
    local lastWidth = -1
    while(contentSize.width > limit) do
        if utf8String.sub(_str, -2) == '..' then _str = utf8String.sub(_str, 1, -3) end
         --重新加个判断来判断
        if utf8String.len(_str) <= 1 then
            break
        end
        _str = utf8String.sub(_str, 1, utf8String.len(_str)-1)..'..'
        widget:setString(_str)
        contentSize = widget:getContentSize()       
--这个判断存在问题  当str为"horning早睡早起@音你   "截取存在问题，这一段空格是emoji表情，我们获取到的就是空格
--        --短得不能再短了, 则break
--        if contentSize.width == lastWidth then
--            break
--        else
--            lastWidth = contentSize.width
--        end
    end
end

function my.getStringInNumber(str, limit)
    local lenInByte = #str
    local count = 0
    local i = 1
    local needTail = false
    if not limit then return end
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
        if limit == count then
            needTail = true
            break
        end
    end
    local string = string.sub(str,1,i-1) .. (needTail and ".." or "")
    return string
end

function my.fitStringInNumber(str, widget, limit)
    local lenInByte = #str
    local count = 0
    local i = 1
    if not limit then return end
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
        if limit == count then
            break
        end
    end
    local string = string.sub(str,1,i-1)
    widget:setString(string)
end

function my.subContentToTableByNum(str, rowNumber)
    if not str or not rowNumber then return end
    local lenInByte = #str
    local strTbale = {}
    local i = 1
    local num = 0 
    local preSubPosition = 1
    while true do
        local curByte = string.byte(str, i)
        local byteCount = 1
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<=223 then
            byteCount = 2
        elseif curByte>=224 and curByte<=239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
     
        i = i + byteCount  
        --英文只占半个字符宽度  
        if byteCount == 1 then
            num = num + 0.5  
        else
            num = num + 1 
        end
        if math.ceil(num) == rowNumber then
            table.insert(strTbale, string.sub(str, preSubPosition, i-1))
            num = 0
            preSubPosition = i
        end 
        if i >= lenInByte then
            break
        end
    end
    if preSubPosition <= lenInByte then
        table.insert(strTbale, string.sub(str, preSubPosition, lenInByte))
    end
    return strTbale 
end

function my.fitStringInWidget_font(str, widget, limit)
    str = str or ''
    --先粗略估计大小， 减少循环
    local utf8Len = cc.load('strings').Utf8String.len(str)
    local newSize = math.floor(limit/utf8Len)
    local originalSize = widget.getFontSize and widget:getFontSize()

    if originalSize <= newSize then
        widget:setString(str)
        return 
    end

    widget:setFontSize(newSize)
    widget:setString(str)

    local contentSize = widget:getContentSize()
    while(contentSize.width + newSize < limit and newSize <= originalSize) do
        widget:setFontSize(newSize)
        newSize = newSize + 2
        contentSize = widget:getContentSize()
    end
end

--[Comment]
--存在cc.exports. 代码评审 周斌 目前游戏模板及大厅都用到了这个全局的变量，暂时不改
--function my.getLBSInfo()
--    local agentManager = plugin.AgentManager:getInstance()
--    local lbsPlugin, userPlugin = agentManager:getLBSPlugin(), agentManager:getUserPlugin()
--    if not lbsPlugin then return end

--    lbsPlugin:getSelfLBSInfo(
--        userPlugin:getUserID(),
--        my.getGameID(),
--        userPlugin:getAccessToken(),
--        function(code, msg, id, lbsInfo)
--            if LBSActionResultCode.kLBSGetLBSInfoSuccess == code and lbsInfo then
--                cc.exports.lbsInfo = lbsInfo
--            else
--                print('code: ' .. code .. ' msg: ' .. msg .. ' id: ')
--            end
--        end
--    )

--    -- for test
----    cc.exports.lbsInfo = {}
----    lbsInfo.cityName = '杭州市'
----    lbsInfo.townShip = '滨江区'
----    lbsInfo.streetName = '江陵路88号'
--end
function my.checkTcyVersion(version)
    if not DeviceUtils:getInstance().getTcyVersion then return false end

    local curTcyVersion = DeviceUtils:getInstance():getTcyVersion()
    local curTcyMajor, curTcySub, curTcyRevised = unpack(string.split(curTcyVersion, "."))
    local curTcyVersionNum = tonumber(curTcyMajor) * 1000 * 1000 + tonumber(curTcySub) * 1000 + curTcyRevised

    local targetTcyMajor, targetTcySub, targetTcyRevised = unpack(string.split(version, "."))
    local targetTcyVersionNum = tonumber(targetTcyMajor) * 1000 * 1000 + tonumber(targetTcySub) * 1000 + targetTcyRevised


    if curTcyVersionNum >= targetTcyVersionNum then
        return true
    else
        return false
    end
end

function my.dataLink(eventCode, eventMap)
    local params = {
        dataLinkVersion =   '2.0',
        eventCode       =   eventCode,
        eventStartTs    =   tostring(os.time()*1000),
        eventEndTs      =   tostring(os.time()*1000),
        statusCode      =   '200',
        gameId          =   tostring(BusinessUtils:getInstance():getGameID()),
        gameCode        =   BusinessUtils:getInstance():getAbbr(),
        gameVers        =   BusinessUtils:getInstance().getAppVersion and BusinessUtils:getInstance():getAppVersion() or "",
        appId           =   tostring(1880081),
        appCode         =   BusinessUtils:getInstance():getAbbr(),
        appVers         =   BusinessUtils:getInstance().getAppVersion and BusinessUtils:getInstance():getAppVersion() or "",
        uid             =   '-1',
    }
    local user = mymodel('UserModel'):getInstance();
    if user.nUserID then
        params['uid'] = tostring(user.nUserID);
    end    

    local intIndex = 1
    local strIndex = 1
    if eventMap then
        for k,v in pairs(eventMap) do
            if type(v) == "number" and intIndex <= 9 then
                local strKey = 'extendNum'..intIndex
                params[strKey] = tostring(v)
                intIndex = intIndex + 1
            elseif type(v) == "string" and strIndex <= 9 then
                local strKey = 'extendStr'..strIndex
                params[strKey] = v
                strIndex = strIndex + 1
            end
        end
    end
    
    if my.checkTcyVersion("5.9.9") and analyticsPlugin and analyticsPlugin.addEventFlow then
        analyticsPlugin:addEventFlow(eventCode, params)
    end
end

function my.logForNetResearch(timeStampType, operateType, processType, ping, requestID, port, session, respondID)
    return LogCtrl:logForNetResearch(timeStampType, operateType, processType, ping, requestID, port, session, respondID)
end

function my.logForNetResearch_Game(timeStampType, operateType, ping, requestID, session, respondID)
    return my.logForNetResearch(timeStampType, operateType, NR_ProcessType.kOperate, ping, requestID, nil, session, respondID)
end

function my.logForNetResearch_Hall(timeStampType, requestID, port, session, respondID)
    return LogCtrl:logForNetResearch_Hall(timeStampType, requestID, port, session, respondID)
end

function my.logForNetResearch_EnterRoom(timeStampType, ping, requestID, session, respondID)
    return my.logForNetResearch(timeStampType, nil, NR_ProcessType.kEnterRoom, ping, requestID, nil, session, respondID)
end

function my.logBackgroundEvent(eventMap)
    my.dataLink(cc.exports.DataLinkCodeDef.APP_ONPAUSE_MB, eventMap)
end

function my.getNetworkTypeString()
    return require('src.app.BaseModule.LogCtrl'):getInstance():getNetworkTypeString()
end

function my.convertTimestampToString(timestamp)
    local timeStr = os.date('%Y-%m-%d %H:%M:%S', timestamp)
    return timeStr
end

--[Comment]
--onnodeevent注入会覆盖，要注意传入的node没有被监听过
function my.scheduleOnceWithNodeExit(node, func, delay)
    local _bExit = false
    node:onNodeEvent("exit", function()
        _bExit = true
    end)
    my.scheduleOnce(function()
        if not _bExit then
            func()
        end
    end, delay or 0)
end

--[Comment] 
--获取指定长度的guid串
function my.getRandomUnsignedCharString(len)
     math.newrandomseed()
     local buffer = {}
     for i = 1, len do
        local num = math.random(0, 127)
        table.insert( buffer, string.char(num))
     end
     return table.concat(buffer)
end

--如果>=1000，则转化到万单位
function my.convertMoneyToTenThousand(nMoney)
    if nMoney == nil then
        return ""
    end

    if nMoney >= 10000 then
        return (nMoney / 10000).."万"
    else
        return tostring(nMoney)
    end
end

--[[function: 获取数字数量字符串，默认保留四位]]
function my.convertMoneyFormat(nMoney, nDigit)
    if not nMoney then return "" end
    if nDigit and 'number' ~= type(nDigit) then return nMoney end
    if 'string' ~= type(nMoney) and 'number' ~= type(nMoney) then return "" end

    local sFormat, nCount = string.gsub(nMoney, "%d+", "%%s")
    if 0 >= nCount then return nMoney end

    local function format_func(func, count, digit)
        local nNumber, nResult = func(), nil
        if string.len(tostring(nNumber)) <= 5 then
            nResult = (tostring(nNumber))
        elseif string.len(tostring(nNumber)) <= 8 then
            local nInteger = tostring(math.floor(nNumber / 10000))
            if string.len(nInteger) >= digit then
                nResult = (tostring(nInteger).."万")
            else
                local nTemp = string.sub(tostring(nNumber / 10000), 1, digit + 1)
                nResult = (tostring(tonumber(nTemp)).."万")
            end
        else
            local nInteger = tostring(math.floor(nNumber / 100000000))
            if string.len(nInteger) >= digit then
                nResult = (tostring(nInteger).."亿")
            else
                local nTemp = string.sub(tostring(nNumber / 100000000), 1, digit + 1)
                nResult = (tostring(tonumber(nTemp)).."亿")
            end
        end
        count = count - 1
        if 0 >= count then
            return nResult
        else
            return nResult, format_func(func, count, digit)
        end
    end
    local match_itor = string.gmatch(nMoney, "%d+")
    return string.format(sFormat, format_func(match_itor, nCount, nDigit or 4))
end
ccui.Text.setMoney = function(self, nMoney, nDigit)
    self:setString(my.convertMoneyFormat(nMoney, nDigit))
end
ccui.TextBMFont.setMoney = function(self, nMoney, nDigit)
    self:setString(my.convertMoneyFormat(nMoney, nDigit))
end

--[Comment]
--把包含换行或者不包含换行的字符串切割成长短适中的段落
function my.cutStrIntoParagraphs(str, delimiter, maxLen)
    local utf8String = cc.load('strings').Utf8String
    local paragraphs = {}
    local chopResult = utf8String.chop(str)
    local startPos   = 1
    local delimiter  = delimiter or "\r\n"

    for index, utf8Word in pairs(chopResult) do
        if utf8Word == delimiter then
            local paragraph = table.concat( chopResult, "", startPos, index - 1)
            startPos = index + 1
            table.insert( paragraphs, paragraph)
        end
    end

    if next(paragraphs) == nil then
        table.insert( paragraphs, str)
    end
    
    local buffer = {}
    maxLen = maxLen or 100
    for index, paragraph in pairs(paragraphs) do
        local chars = utf8String.chop(paragraph)
        if #chars > maxLen then
            local nextPos = 1
            repeat
                table.insert(buffer, table.concat( chars, "", nextPos, nextPos + maxLen < #chars and nextPos + maxLen or #chars))
                nextPos = (nextPos + maxLen < #chars and nextPos + maxLen or #chars) + 1
            until nextPos > #chars
        else
            table.insert(buffer, paragraph)
        end
    end
    return buffer
end

--[Comment]
--此函数适用于：使用滚动容器和文本结合的情况
--使用此函数之后可以达到：文本和滚动容器大小适应，滚动到底部后文本刚好也在末尾；可以正确处理换行等操作符
--参数依次为：text:文本控件，str：内容，scrollpanel：滚动容器
function my.autoWrapToFitTextField(text, str, scrollPanel, delimiter)
    --之所以创建替身是因为文本只有在刚创建之后才能正确地获取到其渲染大小，从而正确地自适应
    text:show()
    local substitute = text:clone()
    substitute:setName("substitute")
    substitute:setTextColor(text:getTextColor())

    local textSize = substitute:getContentSize()
    local paragraphs = my.cutStrIntoParagraphs(str, delimiter)
    local countHeight = 0
    for _, paragraph in pairs(paragraphs) do
        substitute:setString(paragraph)
        local renderSize = substitute:getVirtualRendererSize()
        local paraHeight = math.ceil(renderSize.width / textSize.width) * renderSize.height
        countHeight = countHeight + paraHeight
    end
    substitute:setString(str)
    if countHeight + 50 > scrollPanel:getContentSize().height then
        substitute:setContentSize( { width = textSize.width, height = countHeight + 50 })
        local innerContainer = scrollPanel:getInnerContainer()
        local innerSize = innerContainer:getContentSize()
        innerContainer:setContentSize( { width = innerSize.width, height = countHeight + 50 })
        substitute:setPositionY(innerContainer:getContentSize().height)
        scrollPanel:jumpToTop()
    else
        scrollPanel:setInnerContainerSize(scrollPanel:getContentSize())
    end
    
    local last = text:getParent():getChildByName("substitute")
    if last then last:removeSelf() end
    text:getParent():addChild(substitute)
    text:hide()
end

function my.forbidKey(target, keys)
    local mt = getmetatable(target)
    mt = mt or {}
    mt.__newindex = function ( t, k, v )
        for _, key in ipairs(keys) do
            if key == k then
                print("write "..key.. " is not allowed")
                return
            end
        end
        rawset(target, k, v)
    end
    setmetatable(target, mt)
end

function my.isEngineSupport3D()

end

function my.seekNodeByName(root, name)
    if not root then return end
 
    if root:getName() == name then return root end
 
    local allChildren = root:getChildren()
 
    for k,v in pairs(allChildren) do
         if v then
             local node = my.seekNodeByName(v, name)
             if node then return node end
         end
    end
 
    return nil
 end
 
 function my.seekNodeByPath(root, path, splitChar)
     if not root then return end
 
     local nameTable = string.split(path, splitChar or '.')
 
     local node = root
 
     for k,v in ipairs(nameTable) do
         node = node:getChildByName(v)
 
         if not node then return end
     end
 
     return node
 end
 
--[Comment]
--保证加载图片的安全性
--widget:需要加载纹理的控件
--url:图片的url
--nUserID:选参，表示是玩家头像
--tag:选参，用来取消回调
function my.setImageByUrl(widget, url, nUserID, tag)
    if type(url) == "string" and string.len(url) > 0 then
        local bExit = false
        widget:onNodeEvent("cleanup", function()
            bExit = true
        end)
        local function onGetImage(code, path)
            if type(path) == "string" and string.len(path) > 0 then
                if not bExit then
                    if widget.loadTexture then
                        widget:loadTexture(path)
                    elseif widget.loadTextureNormal then
                        widget:loadTextureNormal(path)
                    end
                    widget:show()
                end
            end
        end
        if nUserID then
            local thirdPartyImageCtrl = import('src.app.BaseModule.YQWImageCtrl')
            thirdPartyImageCtrl:getUserImage(nUserID, url, onGetImage, tag)
        else
            local thirdPartyImageCtrl = import('src.app.BaseModule.YQWImageCtrl')
            thirdPartyImageCtrl:getUserhuodongImage(url, onGetImage, tag)
        end
    else
        printError("get no url in setImage")
    end
end

--ip int to string
function my.ipIntToString(nIp)
    if not nIp then return "0.0.0.0" end
    local ip = {bit.band(0xFF, nIp),
                bit.rshift(bit.band(0xFF00, nIp), 8),
                bit.rshift(bit.band(0xFF0000, nIp), 16),
                bit.rshift(bit.band(0xFF000000, nIp), 24)}


    return table.concat(ip, ".")
end

function my.loadHallPlist(fileName)
    local folder = "hallcocosstudio/images/plist/"
    local plistFile = string.format("%s%s.plist", folder, fileName)
    local pngFile = string.format("%s%s.png", folder, fileName)
    cc.load("reshelper").ResHelper:loadSpriteFrames(plistFile, pngFile, function (plistFileName, pngName)
        print(fileName, "loaded")
    end)
end

function my.onMoreGameDownload(content, freshDownloadBar) 
    if not content then return end

    local code                  = content.code      
    local ext                   = content.ext
    local gameCode              = content.destcode                      
    local gameID                = content.destid    
    local constStrings          = cc.load('json').loader.loadFile('MainSceneStrings.json')

    if code     == GAME_DOWNLOAD.GAME_CAN_START then
        MoreGame:startGame(gameCode, gameID)
    elseif code == GAME_DOWNLOAD.USER_CANCEL_DOWNLOAD then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = constStrings["GAME_DOWNLOADCANCEL"] } })
        my.dataLink(cc.exports.DataLinkCodeDef.MORE_GAME_EVENT_CODE, {eventCode = code, strTip = str})
    elseif code == GAME_DOWNLOAD.GET_GAMEINFO_ERROR then   
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = constStrings["GAME_GETINFO_ERROR"] } })
        my.dataLink(cc.exports.DataLinkCodeDef.MORE_GAME_EVENT_CODE, {eventCode = code, strTip = str})
    elseif code == GAME_DOWNLOAD.GAME_DOWNLOAD_START then
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = constStrings["GAME_DOWNLOAD_START"] } })
    elseif code == GAME_DOWNLOAD.GAME_DOWNLOAD_PROGRESS then
        local info      = json.decode(ext)
        local total     = info.total
        local current   = info.current 
        if freshDownloadBar and type(freshDownloadBar) == "function" then
            freshDownloadBar(current/total*100, gameCode)
        end
    elseif code == GAME_DOWNLOAD.GAME_DOWNLOAD_ERROR then      
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = ext } })
        my.dataLink(cc.exports.DataLinkCodeDef.MORE_GAME_EVENT_CODE, {eventCode = code, strTip = ext})
    elseif code == GAME_DOWNLOAD.GAME_DOWNLOAD_SUCCESS then               
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = constStrings["GAME_DOWNLOAD_SUCCESS"] } })
    elseif code == GAME_DOWNLOAD.GAME_DOWNLOAD_PAUSE then    
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = constStrings["GAME_DOWNLOAD_PAUSE"] } })

    elseif code == GAME_DOWNLOAD.IS_DOWNLOAD_CURRENT_NOT_WIFI then         
        local downloadGameCode = MoreGame:getCurrentDownloadGameCode()
        local downloadGameID   = MoreGame:getCurrentDownloadGameID() 
        my.informPluginByName({ pluginName = 'ChooseDialog', params = { 
            onOk = function()
                MoreGame:startDownload(downloadGameCode, downloadGameID, my.onMoreGameDownload(), true)
            end,
            tipContent = constStrings["GAME_DOWNLOAD_RESURE_UNDER4G"] }
        })

    elseif code == GAME_DOWNLOAD.WIFI_CHANGE_4G then  
        local downloadGameCode = MoreGame:getCurrentDownloadGameCode()
        local downloadGameID   = MoreGame:getCurrentDownloadGameID() 
        my.informPluginByName({ pluginName = 'ChooseDialog', params = { 
            onOk = function()
                MoreGame:startDownload(downloadGameCode, downloadGameID, my.onMoreGameDownload(), true)
            end,
            tipContent = constStrings["GAME_DOWNLOAD_RESURE_CHANGETO4G"] }
        })
    end

    if code == GAME_DOWNLOAD.GAME_DOWNLOAD_SUCCESS or code == GAME_DOWNLOAD.GAME_DOWNLOAD_PAUSE then   
        if freshDownloadBar and type(freshDownloadBar) == "function" then
            freshDownloadBar(0, gameCode)
        end               
    end 
end  







function my.fixUtf8Width(szText, nodeText, nWidth)--传入和返回utf8编码格式
	local szOrignalText = nodeText:getString()
	local szOrignal = cc.size(0, 0)
	local gbName = MCCharset:getInstance():utf82GbString(szText, string.len(szText))
	local utf8Name = MCCharset:getInstance():gb2Utf8String(gbName, string.len(gbName))
	nodeText:setString(utf8Name)

	szOrignal = nodeText:getContentSize()
	local sz = szOrignal
	while sz.width > nWidth do
		gbName = string.sub(gbName, 1, string.len(gbName) - 1)
		utf8Name = MCCharset:getInstance():gb2Utf8String(gbName, string.len(gbName))
        local TempName = utf8Name.."..."
		nodeText:setString(TempName)
		sz = nodeText:getContentSize()
        if sz.width <= nWidth then
            utf8Name = TempName
        end
	end

	--[[if szOrignal.width > sz.width then
		gbName = MCCharset:getInstance():utf82GbString(utf8Name, string.len(utf8Name))
		utf8Name = MCCharset:getInstance():gb2Utf8String(gbName, string.len(gbName))
		utf8Name = utf8Name.."..."
	end

	nodeText:setString(szOrignalText)]]

	return utf8Name
end   







function my.AddStranger(param)
    local strangerManager = require("src.app.BaseModule.StrangerManager")
    strangerManager:AddStranger(param)
end

function my.DeleteStranger(userId)
    local strangerManager = require("src.app.BaseModule.StrangerManager")
	strangerManager:DeleteStranger(userId)
end

function my.GetAllStranger()
    local strangerManager = require("src.app.BaseModule.StrangerManager")
	return strangerManager:GetAllStranger()
end

function my.initCheckButtonEvent(viewNode, TabEventMap, callfunc)
    local function onTabEvent(widgt, TabEventMap, callfunc)
        local selectIndex = -1
        for index, table in pairs(TabEventMap.TabButtons) do
            viewNode[table.checkBtn]:setSelected(false)
            viewNode[table.checkBtn]:setLocalZOrder(0)
            if viewNode[table.checkBtn]._realnode[1] == widgt then
                viewNode[table.checkBtn]:setLocalZOrder(1)
                selectIndex = index
            end
        end
        if selectIndex < 0  then
            return
        end
        for widgtName, func in pairs(TabEventMap.NeedHideNode) do
            viewNode[widgtName]:setVisible(false)
        end
        for widgtName, func in pairs(TabEventMap.TabButtons[selectIndex].showNode) do
            viewNode[widgtName]:setVisible(true)
        end

        if callfunc then
            callfunc(selectIndex)
        end
    end

    local function onTempTabEvent(widget)
		onTabEvent(widget, TabEventMap, callfunc)
	end
    for index, table in pairs(TabEventMap.TabButtons) do
        if viewNode[table.checkBtn] then
            viewNode[table.checkBtn]:addClickEventListener(onTempTabEvent)
            if table.defaultShow then
                onTabEvent(viewNode[table.checkBtn]._realnode[1], TabEventMap, callfunc)
                viewNode[table.checkBtn]:setSelected(true)
            end
        end
    end
end



--显示转圈动画Loading界面，注意此Loading界面总是唯一的；存在的情况下第二次调用只是刷新界面
--loadingTip：提示信息；autoCloseTimeout：超过此时间自动关闭，注意其有一个最大值10s；为空则默认5s
function my.startProcessing(loadingTip, autoCloseTimeout)
    local curScene = cc.Director:getInstance():getRunningScene()
    local loadingNode = curScene:getChildByName("Node_MyLayerProcessing")
    if loadingNode == nil then
        local csbPath = "res/hallcocosstudio/hallcommon/layer_processing.csb"
        loadingNode = cc.CSLoader:createNode(csbPath)
        loadingNode:setName("Node_MyLayerProcessing")
        loadingNode:setContentSize(cc.Director:getInstance():getVisibleSize())
        curScene:addChild(loadingNode)
        ccui.Helper:doLayout(loadingNode)

        local timeLine = cc.CSLoader:createTimeline(csbPath)
        loadingNode:runAction(timeLine)
        timeLine:play("Animation_Loading", true)
    end

    local panelShade = loadingNode:getChildByName("Panel_Shade")
    local panelMain = loadingNode:getChildByName("Panel_Main")
    local labelInstruction = panelMain:getChildByName("Text_Instruction")

    if loadingTip then
        labelInstruction:setVisible(true)
        labelInstruction:setString(loadingTip)
    else
        labelInstruction:setVisible(false)
    end

    autoCloseTimeout = math.min(10, autoCloseTimeout or 5)
    TimerManager:scheduleOnceUnique("Timer_MyStartProcessing_AutoClose", function()
        my.stopProcessing()
    end, autoCloseTimeout)
end

function my.stopProcessing()
    TimerManager:stopTimer("Timer_MyStartProcessing_AutoClose")

    local curScene = cc.Director:getInstance():getRunningScene()
    local loadingNode = curScene:getChildByName("Node_MyLayerProcessing")
    if loadingNode ~= nil then
        loadingNode:removeFromParent()
    end
end

function my.isProcessing()
    local curScene = cc.Director:getInstance():getRunningScene()
    local loadingNode = curScene:getChildByName("Node_MyLayerProcessing")
    if loadingNode ~= nil then
        return true
    end
    return false
end

-- 劫持引擎获取sdkName接口，防止频繁调用导致游戏崩溃闪退
local _sdkName = nil
local _userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
local _userPlugin_getUsingSDKName = nil
if _userPlugin:isFunctionSupported('getUsingSDKName') then
    _userPlugin_getUsingSDKName = _userPlugin.getUsingSDKName
    _userPlugin.getUsingSDKName = function(self)
        if _sdkName ~= nil then
            return _sdkName
        end
        _sdkName = _userPlugin_getUsingSDKName(self)
        return _sdkName
    end
end

function my.getSelfSdkName()
    local sdkName = "unknown"
    if device.platform == "windows" then
        sdkName = "tcyapp"
    else
        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
        if userPlugin:isFunctionSupported('getUsingSDKName') then
            sdkName = string.lower(userPlugin:getUsingSDKName())
            if sdkName == "tcy" then
                if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
                    sdkName = "tcyapp"
                end
            end
        end
    end

    return sdkName
end

-- 劫持引擎获取tcyChannel接口，防止频繁调用导致游戏崩溃闪退
local _tcyChannelID = nil
local _businessUtils_getTcyChannel = BusinessUtils.getTcyChannel
BusinessUtils.getTcyChannel = function(self)
    if _tcyChannelID ~= nil then
        return _tcyChannelID
    end
    _tcyChannelID = _businessUtils_getTcyChannel(self)
    return _tcyChannelID
end

--返回的是string
function my.getTcyChannelId()
    local tcyChannel = nil
	if BusinessUtils:getInstance().getTcyChannel then
		tcyChannel = BusinessUtils:getInstance():getTcyChannel()
	end
	return tcyChannel
end

--联运游戏url组装
local oscodeDefault = 0
local oscodeAndroid = 1
local oscodeIOS   = 2
local oscodeWindows = 3
function my.packageGameUrl(gameUrl)
    if not gameUrl then return end
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local userId = userPlugin:getUserID()
    local accessToken = userPlugin:getAccessToken()
    print('accessToken', accessToken)
    local oscode = oscodeDefault
    if device.platform == 'android' then
        oscode = oscodeAndroid
    elseif device.platform == 'ios' then
        oscode = oscodeIOS
    elseif device.platform == 'windows' then
        oscode = oscodeWindows
    end
    local horizontal = 1    --1表示竖屏，非1表示横屏
    local imei = DeviceUtils:getInstance():getIMEI()
    local appversion = '0.0.0'
    if DeviceUtils:getInstance().getAppVersion and       DeviceUtils:getInstance():getAppVersion('com.uc108.mobile.gamecenter') then
     appversion=DeviceUtils:getInstance():getAppVersion('com.uc108.mobile.gamecenter')
    end
    local tcyChannelId = ''
    if BusinessUtils:getInstance().getTcyChannel then
        tcyChannelId = BusinessUtils:getInstance():getTcyChannel()
    end
    local gameWebUrl = string.format(gameUrl, tostring(accessToken), tostring(userId), tostring(appversion),tostring(imei), tostring(oscode), tostring(tcyChannelId))
    return gameWebUrl
end

function my.runPopupAction( panelPopup, popEndCallback )
    if not tolua.isnull(panelPopup) then
        panelPopup:setVisible(true)
        panelPopup:setScale(0.6)
        panelPopup:setOpacity(255)
        local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
        local scaleTo2 = cc.ScaleTo:create(0.09, 1)
        local callback = cc.CallFunc:create(function()
            if popEndCallback then
                popEndCallback()
            end
        end)

        local ani = cc.Sequence:create(scaleTo1, scaleTo2, callback)
        panelPopup:runAction(ani)
    end
end

-- common proxy begin
-- judge ip is legal
function my.judgeIPString(ipStr)
    if type(ipStr) ~= "string" then
        return false;
    end
    
    --判断长度
    local len = string.len(ipStr);
    if len < 7 or len > 15 then --长度不对
        return false;
    end

    --判断出现的非数字字符
    local point = string.find(ipStr, "%p", 1); --字符"."出现的位置
    local pointNum = 0; --字符"."出现的次数 正常ip有3个"."
    while point ~= nil do
        if string.sub(ipStr, point, point) ~= "." then --得到非数字符号不是字符"."
            return false;
        end
        pointNum = pointNum + 1;
        point = string.find(ipStr, "%p", point + 1);
        if pointNum > 3 then
            return false;
        end
    end
    if pointNum ~= 3 then --不是正确的ip格式
        return false;
    end

    --判断数字对不对
    local num = {};
    for w in string.gmatch(ipStr, "%d+") do
        num[#num + 1] = w;
        local kk = tonumber(w);
        if kk == nil or kk > 255 then --不是数字或超过ip正常取值范围了
            return false;
        end
    end

    if #num ~= 4 then --不是4段数字
        return false;
    end

    return true;
end
-- common proxy end


-- common proxy begin
--[[
    enum
    {
        KEY_TYPE_HALL = 1,
        KEY_TYPE_ROOM = 3,   
        KEY_TYPE_GAME2 = 4,
        KEY_TYPE_GAME1 = 5,
        KEY_TYPE_ASSIST = 6,
        KEY_TYPE_MAX = 32,
    };
--]]

function my.convertToConnectInfo(ip, port, type)
    if type == 6 then
        -- assist获取到的port都是代理的，真实端口一般都是 -1
        port = port - 1
    elseif type == 3 then
        -- 房间代理服务器port -1000
        port = port - 1000
    elseif type == 4 or type == 5 then
        -- 游戏代理服务器端口 -20000
        port = port - 20000
    end
    return string.format( "%s %s %s", tostring(ip), tostring(port), tostring(type) )
end

-- return true/false[是否使用commomMP], client[客户端连接], connectstr["ip port type"]
-- 返回成功的话，就在下一次 connect ok时候，发送#define UR_CONNECT_SERVER        (UR_REQ_BASE + 110),
-- "192.168.1.55 35000 3" 这样的消息给commonMP
function my.commonMPConnect(ip, port, type)
    local ServerConfig = require('src.app.HallConfig.ServerConfig')
    local commonMPIP = ServerConfig.commonmp[1]
    local commonMPPort = ServerConfig.commonmp[2]

    if not commonMPIP or not commonMPPort or not type then
        return false, MCAgent:getInstance():createClient(ip, port)
    end

    local client = MCAgent:getInstance():createClient(commonMPIP, commonMPPort)
    return true, client, my.convertToConnectInfo(ip, port, type)
end
-- common proxy end

--判断字符串是否是纯数字
function my.isNumberByString( words )
    if string.len(words) < 1 then
        return false
    end
    for i=1,string.len(words) do
        if string.byte(string.sub(words,i,i)) < 48 or string.byte(string.sub(words,i,i)) > 57 then
            return false
        end
    end
    
    return true
end