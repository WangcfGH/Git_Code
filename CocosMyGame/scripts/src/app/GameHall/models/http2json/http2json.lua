
local json=cc.load('json').json
local dataCollector = cc.load('datacollector'):getInstance()
local HttpJsonRequestConfig=require('src.app.GameHall.models.http2json.HttpJsonRequestUtils')
require('src.app.HallConfig.HttpJsonConfig')
local httpjson=class('httpjson')
local HttpSender=cc.XMLHttpRequest

my.jhttp=httpjson

function httpjson:ctor( ... )
-- body
end

function httpjson:generateUrl(requestId,params)
	params=checktable(params)
	local baseUrl,additionPath,exchMap,privateData,method= self:getRequestInfoByName(requestId)
	local dataList=self:collectDataByName(exchMap,params,privateData)
	local urlParamsString=self:parcelDataList(dataList)

	local url
	if(method=='POST')then
		url=string.format('%s%s',baseUrl,(additionPath or ''))
	elseif(method=='GET')then
		url=string.format('%s%s%s%s',baseUrl,(additionPath or ''),'?',urlParamsString)
	end
	return url,urlParamsString
end

function httpjson:send(requestId,params)

	--KPI start
    --获取KPI数据是否上报的标识needKPIData=1表示需要上报
    local baseUrl,additionPath,exchMap,privateData,method,needKPIData= self:getRequestInfoByName(requestId)
	--KPI end
	
	local url,urlParamsString=self:generateUrl(requestId,params)
	
	local httpSender=HttpSender:new()
	httpSender.responseType=cc.XMLHTTPREQUEST_RESPONSE_JSON
	httpSender:open(method,url,true)

	httpSender:registerScriptHandler(function()
		if(self._requestCallback)then
			local jsonobj=self:parseJsonResponseText(httpSender.responseText)
			self._requestCallback(httpSender,jsonobj)
		end
	end)

    --KPI start
    if needKPIData and needKPIData == 1 then
        local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
		if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
			local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
			if gsClient then
				httpSender:setRequestHeader("GsClientData", gsClient);
			end
		end
    end	
    --KPI end

	if(method=='POST')then
		httpSender:setRequestHeader("Content-Type","application/x-www-form-urlencoded;");
		httpSender:send(urlParamsString)
		print('request data is : ',urlParamsString)
	elseif(method=='GET')then
		httpSender:send()
	end
	print('send request ',url)

end

--------------------------
-- callback(httpSender,jsonobj)
-- httpSender
-- jsonobj
function httpjson:setCallback(callback)
	self._requestCallback=callback
end

function httpjson:parseJsonResponseText(jsontext)
	-- body
	print(jsontext)
	--过滤并转码unicode编码
	jsontext = string.gsub(jsontext, '\\u(%x%x%x%x)', function ( h )
		return string.char(tonumber(h, 16)) 
	end)
	local jsonobj=jsontext:len()>0 and json.decode(jsontext) or {}
	--	dump(jsonobj)
	return jsonobj
end

function httpjson:setCallback(callback)
	-- body
	self._requestCallback=callback
end

function httpjson:getRequestInfoByName(requestName)
	local requestConfig=HttpJsonRequestConfig.getConfigByName(requestName)
	local baseUrl=requestConfig.baseUrl
	local additionPath=requestConfig.addition
	local exchMap=requestConfig.exchangeMap
	local privateData=requestConfig.privateData
	local method=requestConfig.method or 'GET'
	
	--KPI start
    --获取KPI数据是否上报的标识needKPIData=1表示需要上报
    local needKPIData = requestConfig.needKPIData
	return baseUrl,additionPath,exchMap,privateData,method,needKPIData
    --KPI end
end

function httpjson:collectDataByName(exchMap,params,privateData)
	local varNameArrayIn=table.values(exchMap)
	dataCollector:addIndex(params)
	local dataList=dataCollector:convert(varNameArrayIn)
	dataCollector:removeIndex(params)

	local realDataList=clone(checktable(privateData))

	for k,v in pairs(exchMap) do
		realDataList[k]=dataList[v]
	end

	for k,v in pairs(realDataList) do
		if(type(v)=='function')then
			realDataList[k]=v(realDataList)
		end
	end

	for k,v in pairs(exchMap) do
		realDataList[k]=dataList[v]
	end

    for k,v in pairs(realDataList) do
        if(type(v)=='string')then
            if (privateData and privateData.action=="submit_message" and k=='msg') then
            else
                realDataList[k]=urlescape(v)
            end
        end
    end
    return realDataList
end

function httpjson:parcelDataList(dataList)

	return my.convertParamsToUrlStyle(dataList)
end

return httpjson
