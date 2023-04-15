
local NodeIndexer=cc.load('myui').NodeIndexer

cc.exports.toint=checkint

if(DEBUG > 0)then
	function table.merge(dest, src)
		assert(type(src)=='table' and type(dest)=='table','')
		for k, v in pairs(src) do
			dest[k] = v
		end
	end
end

function table.sub(dataList,pstart,pend)
	local effectiveDataList={}
	for i=1,pend do
		effectiveDataList[i]=dataList[i+pstart-1]
	end
	return effectiveDataList
end

function cc.exports.mergeTable(t1,tsrc)
	assert(type(tsrc)=='table' and type(t1)=='table','')
	for k,_ in pairs(tsrc) do
		t1[k]=tsrc[k]
	end
end

local CSLoader=cc.CSLoader
function CSLoader:createMyNode(filename)
	local node=self:createNode(filename)
	my.presetAllButton(node)			--手动增加按钮点击放缩效果
	return node
end

function CSLoader:createMyIndexer(filename,exchangeMap)
	return NodeIndexer(CSLoader:createMyNode(filename),exchangeMap)
end

function cc.sizeadd(size1,size2)
	return {width=size1.width+size2.width,height=size1.height+size2.height}
end

----------------------
--	objName: name of textfield node
--  手动修改textfield为editbox，用来设置文本的输入类型：纯数字等
function my.fixTextField(viewNode,objName,imageView,image,fontColor)
	local depositAmoutInp=viewNode[objName]
	depositAmoutInp:setVisible(false)
	local editBox=ccui.EditBox:create(imageView:getContentSize(),image)

    editBox.getString=editBox.getText
	editBox.setString=editBox.setText
	editBox.setTextColor=editBox.setFontColor

	editBox:setPosition(imageView:getPosition())
	editBox:setAnchorPoint(depositAmoutInp:getAnchorPoint())

    local fontName = depositAmoutInp:getFontName() == '' and 'Arial' or depositAmoutInp:getFontName()
	editBox:setFontName(fontName)
	editBox:setFontColor(fontColor or cc.c3b(0x33, 0x33, 0x33))--display.COLOR_BLACK)--cc.c3b(0x33, 0x33, 0x33)是美术的建议
	editBox:setFontSize(depositAmoutInp:getFontSize())

    editBox:setPlaceholderFontName(fontName)
	editBox:setPlaceHolder(depositAmoutInp:getPlaceHolder())
	editBox:setPlaceholderFontSize(depositAmoutInp:getFontSize())
	editBox:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
    
	editBox:setMaxLength(depositAmoutInp:getMaxLength())
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

	local parent=(depositAmoutInp:getParent()~=imageView and depositAmoutInp:getParent()) or depositAmoutInp:getParent():getParent()
	parent:addChild(editBox)

	viewNode[objName]=editBox

	editBox:setLocalZOrder(imageView:getLocalZOrder()+1)
end

function my.createEditBox(depositAmoutInp,imageView,image,fontColor)
	depositAmoutInp:setVisible(false)
	local editBox=ccui.EditBox:create(imageView:getContentSize(),image)

    editBox.getString=editBox.getText
	editBox.setString=editBox.setText
	editBox.setTextColor=editBox.setFontColor

	editBox:setPosition(imageView:getPosition())
	editBox:setAnchorPoint(depositAmoutInp:getAnchorPoint())

    local fontName = depositAmoutInp:getFontName() == '' and 'Arial' or depositAmoutInp:getFontName()
	editBox:setFontName(fontName)
	editBox:setFontColor(fontColor or cc.c3b(0x33, 0x33, 0x33))--display.COLOR_BLACK)--cc.c3b(0x33, 0x33, 0x33)是美术的建议
	editBox:setFontSize(depositAmoutInp:getFontSize())

    editBox:setPlaceholderFontName(fontName)
	editBox:setPlaceHolder(depositAmoutInp:getPlaceHolder())
	editBox:setPlaceholderFontSize(depositAmoutInp:getFontSize())
	editBox:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
    
	editBox:setMaxLength(depositAmoutInp:getMaxLength())
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

	local parent=(depositAmoutInp:getParent()~=imageView and depositAmoutInp:getParent()) or depositAmoutInp:getParent():getParent()
	parent:addChild(editBox)
	editBox:setLocalZOrder(imageView:getLocalZOrder()+1)
    return editBox
end

local listenerList={}
local freezed = false
--[Comment]
-- 禁用堆栈中的上一个键盘监听器，并且启用自己
function my.autoBlockKeyboardListener(listener)
	print("autoBlockKeyboardListener", listener)
	dump(listenerList)
	if freezed then
		if #listenerList > 0 then
			for index = listenerList[#listenerList], 1, -1 do
				if listener == listenerList[#listenerList] then
					break
				else
					table.remove(listenerList, index)
				end
			end
			my.unfreezeKeyboardListener()
		end
		return
	end
	local lastListener = listenerList[#listenerList]
	if (lastListener) then
		lastListener:setEnabled(false)
	end
	listenerList[#listenerList+1]=listener
    listener:retain()
	my.scheduleOnce(function()
		listener:setEnabled(true)
	end)
end

--[Comment]
-- 启用堆栈中的上一个键盘监听器，并且移除自己
function my.removeKeyboardListener(listener)
	print("removeKeyboardListener", listener)
	dump(listenerList)
	local index = table.indexof(listenerList,listener)
	if index then
		listenerList[index]:setEnabled(false)
		table.remove(listenerList,index)
		local lastListener=listenerList[#listenerList]
		if freezed then
			listener:release()
		else
			my.scheduleOnce(function()
				if(lastListener)then
					lastListener:setEnabled(true)
					my.scheduleOnce(function()
						--这么写的原因是lastListener有可能比listener先释放
						listener:release()
					end, 0.1)
				end
			end)
		end
	end
end

function my.freezeKeyboardListener()
	print("freezeKeyboardListener")
	dump(listenerList)
	local lastListener=listenerList[#listenerList]
	if (lastListener) then
		lastListener:setEnabled(false)
	end
	freezed = true
end

function my.unfreezeKeyboardListener()
	print("unfreezeKeyboardListener")
	dump(listenerList)
	local lastListener = listenerList[#listenerList]
	if (lastListener) then
		lastListener:setEnabled(true)
	end
	freezed = false
end

--[Comment]
--启用后台监听器，并且将之前该监听器加入栈中
local backgroundListener = {}
function my.enableBackgroundListener(listener)
    backgroundListener[#backgroundListener + 1] = listener
    AppUtils:getInstance():removePauseCallback('Hall_LogEvent_setBackgroundCallback')
    AppUtils:getInstance():addPauseCallback(listener, 'Hall_LogEvent_setBackgroundCallback')
end

--[Comment]
--启用上一个后台监听器
function my.enableLastBackgroundListener()
    backgroundListener[#backgroundListener] = nil
    local prelistener = backgroundListener[#backgroundListener]
    AppUtils:getInstance():removePauseCallback('Hall_LogEvent_setBackgroundCallback')
    if prelistener then
        AppUtils:getInstance():addPauseCallback(prelistener, 'Hall_LogEvent_setBackgroundCallback')
    end
end

--[[KPI start]]
--函数返回KPI需要的数据
local _kpiClientDataCache = nil
function my.getKPIClientData()
    if _kpiClientDataCache then
        return _kpiClientDataCache
    end
    local gamemodel   = mymodel('GameModel'):getInstance()
    local deviceUtils = DeviceUtils:getInstance()
    local device = mymodel('DeviceModel'):getInstance()

    local kpiHardInfo = {
        ImeiId = deviceUtils:getIMEI(),                 --ImeiId
        WifiId = deviceUtils:getMacAddress(),           --WifiId
        ImsiId = deviceUtils:getIMSI(),                 --ImsiId
        SimSerialNo = deviceUtils:getSimSerialNumber(), --SimSerialNo
        SystemId = deviceUtils:getSystemId()            --SystemId
    }

    local recommGameID = 0
    local recommGameCode = ''
    local recommGamevers = ''
    local content = launchParamsManager:getContent()
    if content and content.sourcecode and content.sourceid then
        local id = tonumber(content.sourceid)
        if id then
            recommGameID   = id
        end
        recommGameCode = content.sourcecode
    end
    
    if content and content.sourcever then
        recommGamevers = content.sourcever
    end

    --[[
    packageType数值含义:
    100:移动游戏单包 
    110:移动游戏平台包 
    200:移动电玩城单包 
    1000:游戏合集包
    300:微信小游戏
    0:pc
    ]]
    local packageType = -1
    local model = MCAgent:getInstance():getLaunchMode()
    if model then
        if model == 1 then
            packageType = 100
        elseif model == 2 then
            packageType = 110
        end
    end

    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        packageType = 1000
    end

    local channel = 0
    if BusinessUtils:getInstance():getTcyChannel() then
        channel = tonumber(BusinessUtils:getInstance():getTcyChannel())
        if not channel then
            channel = -1
        end
    end
    local kpiData = {
        GameId  = my.getGameID(),           --客户端游戏id
        GameCode = my.getGameShortName(),   --客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
        GameVers = my.getGameVersion(),	    --客户端游戏版本
        RecomGameId = recommGameID,         --推荐客户端游戏id
        RecomGameCode = recommGameCode,     --推荐客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
        RecomGameVers = recommGamevers,                 --推荐客户端游戏版本
        GroupId = gamemodel.nAgentGroupID,  --客户端大厅组号
        Channel = channel,                  --客户端渠道号
        HardId = device.szHardID,           --客户端设备号
        MobileHardInfo = kpiHardInfo,       --移动客户端硬件信息结构体
		PkgType = packageType,               --客户端包体类型(100:移动游戏单包\110:移动游戏平台包\200:移动电玩城单包\1000:游戏合集包\300:微信小游戏\0:pc)
		CUID    = BusinessUtils:getInstance().getTcyCUID and BusinessUtils:getInstance():getTcyCUID() or ''
    }
    print("kpiData")
    dump(kpiData)

    _kpiClientDataCache = kpiData;
	return kpiData
end
--[[KPI end]]