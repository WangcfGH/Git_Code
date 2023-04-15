local ImageCtrl = class("ImageCtrl")
--等待重构 代码评审 陈添泽
--ImageCtrl.callFucArray={}

local imageLoaderPlugin
local userPlugin
local tcyFriendPlugin

if cc.exports.isSocialSupported() then 	
    imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()
    tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
end

--网站保存的图片只有一下三种尺寸
local availableSize = {}
availableSize[1] = 60
availableSize[2] = 100
availableSize[3] = 400

--default Params
--**状态枚举
ImageCtrl.AUDITSTATUS_PENDING = 0
ImageCtrl.AUDITSTATUS_APPROVED = 1
ImageCtrl.AUDITSTATUS_DENIED = 2

--显示模式（**中是否显示）
ImageCtrl.SHOWSET_HIDE = 0
ImageCtrl.SHOWSET_SHOW = 1

--判断显示模式和**状态之后，转译出来的**状态
ImageCtrl.TRANSSTATUS_AUDITTING = 0
ImageCtrl.TRANSSTATUS_DENIED = 1
ImageCtrl.TRANSSTATUS_NORMAL = 2 

ImageCtrl.__isWaitingForPortraitInfoByUserIDs = false --考虑使用local 陈添泽
ImageCtrl.PERSONALTABLE_GET='personalTable get' --事件定义

--同步获取本地图片返回的code定义
ImageCtrl.IMAGELOAD_GETLOCAL_SUCCESS_SYNC = 100 
ImageCtrl.IMAGELOAD_GETLOCAL_FAILED_SYNC = 101

local event = cc.load('event')
event:create():bind(ImageCtrl)

local personalTable     = {}
local callbackCollector = {}
local callbackTags      = {}
local pathCache         = nil
local imageDataUpdating = false

local function getAvailableSize(sizeWanted)
    --正则匹配出字符串“60-60”中的数字60
    local sizeWantedNum = tonumber(string.sub(sizeWanted,string.find(sizeWanted,'%d+')))

    for i = 1, #availableSize do 
        if availableSize[i]>=sizeWantedNum then 
            return string.format(availableSize[i]..'-'..availableSize[i])
        end
    end
    print('~~~~no size available, offer the max size we got~~')
    return availableSize(#availableSize)
end

--转译显示开关和**状态为本地是否显示的code
local function statusDistribution(status, pendingAuditShow)
    if status == ImageCtrl.AUDITSTATUS_PENDING and pendingAuditShow == ImageCtrl.SHOWSET_HIDE  then 
        return ImageCtrl.TRANSSTATUS_AUDITTING
    elseif status == ImageCtrl.AUDITSTATUS_APPROVED or
        (status == ImageCtrl.AUDITSTATUS_PENDING  and pendingAuditShow ==ImageCtrl.SHOWSET_SHOW ) then 
        return ImageCtrl.TRANSSTATUS_NORMAL
    elseif status == ImageCtrl.AUDITSTATUS_DENIED then 
        return ImageCtrl.TRANSSTATUS_DENIED
    end
    return false
end

local function getSelfTransStatus()

    local imageStatus
    if personalTable.portraiturl == '' then 
        imageStatus = ImageCtrl.TRANSSTATUS_NORMAL
        print('personalTable get not url, offer default imageStatus normal:2')
        return imageStatus
    end
    if personalTable.status and personalTable.pendingauditshow then  
        imageStatus = statusDistribution(personalTable.status, personalTable.pendingauditshow)
    else 
        imageStatus = ImageCtrl.TRANSSTATUS_NORMAL
        print('personalTable not ready, offer default imageStatus normal:2')
    end
    return imageStatus

end

local function checkUsersTable(usersTable, callbackFunc)
    for k,v in pairs(usersTable) do
    	print(k,v)
    	dump(v)
    	if v == {} then --不能这样判断空表 陈添泽
    		print('v == {}')

    		return 
    	end
    	if not v.userID then 
    		print('userID not ready')
    		return 
    	end
    end
   -- ImageCtrl:dispatchEvent({name = ImageCtrl.PORTRAITINFO_BYUSERIDS_GET})
   callbackFunc(usersTable)
end

local function getLocalImage(userID, size, callbackFunc, usersTable)
    if not usersTable then 
        print("usersTable not exist, proccess as selfPortrait")
    
        local imageStatus = getSelfTransStatus()
--        if imageStatus == ImageCtrl.TRANSSTATUS_DENIED then
--            imageLoaderPlugin:deleteImageData(userID)
--        end

        local imageData = imageLoaderPlugin:getLocalImage_sync(userID, size)
        if not imageData then
            imageData = imageLoaderPlugin:getLocalImage_sync(userID, "500-500")
        end
        if imageData then
            printf("userid is " .. imageData.userid)
            printf("url is " .. imageData.url)
            printf("path is " .. imageData.path)
            printf("size " .. imageData.size)

            if imageData.path and imageData.path ~= "" then                
                callbackFunc(ImageCtrl.IMAGELOAD_GETLOCAL_SUCCESS_SYNC,imageData.path,imageStatus)
            else
                callbackFunc(ImageCtrl.IMAGELOAD_GETLOCAL_FAILED_SYNC,imageData.path,imageStatus)
            end
        else
            printf("imageData is nil")
			callbackFunc(ImageCtrl.IMAGELOAD_GETLOCAL_FAILED_SYNC, "", imageStatus)
            
        end
    else 
        print("usersTable exist")
        local imageData = imageLoaderPlugin:getLocalImage_sync(userID, size)
        if not imageData then
            imageData = imageLoaderPlugin:getLocalImage_sync(userID, "500-500")
        end
        if (imageData and imageData.userid and imageData.path and imageData.path ~= "") then
            printf("userid is " .. imageData.userid)
            printf("url is " .. imageData.url)
            printf("path is " .. imageData.path)
            printf("size " .. imageData.size)
                        
            usersTable[userID].userID = imageData.userid
            usersTable[userID].path = imageData.path
            usersTable[userID].size = imageData.size
            print('local image get, start table check')
            checkUsersTable(usersTable,callbackFunc)
        else
            printf("imageData is nil, getlocal failed")
            usersTable[userID] = {}
            usersTable[userID].userID = userID
            usersTable[userID].path = ''
            --checkUsersTable(usersTable,callbackFunc)
        end
    end
end

local function isLocalImageExist(userID, url, size)

    if size == "400-400" then 
        if imageLoaderPlugin:isLocalImageExist(userID, url, size) or imageLoaderPlugin:isLocalImageExist(userID, url, '500-500') then 
            print("localImageExist")
            return true
        else
            print("localImageNotExist")
            return false
        end
    else
        if imageLoaderPlugin:isLocalImageExist(userID, url, size) then 
            print("localImageExist")
            return true
        else
            print("localImageNotExist")
            return false
        end
    end
end

local function getOnlineImage(userID, size, callbackFunc, url, usersTable)
    print('getOnlineImage', userID, size, callbackFunc, url, usersTable)

    if usersTable then
    
        if not isLocalImageExist(userID, url, size) then
            imageLoaderPlugin:loadOnlineImage(userID, url, size, function(code,path)

                usersTable[userID].userID = userID
                usersTable[userID].path = path
                usersTable[userID].size = size
                print('online image get, start table check')
                checkUsersTable(usersTable,callbackFunc)

            end)
        else
            print("local image exist already, online operation off.")
        end

    elseif userID == personalTable.userid then
        local imageStatus = getSelfTransStatus()
        if imageStatus == ImageCtrl.TRANSSTATUS_DENIED then

--            imageLoaderPlugin:deleteImageData(userID)
--            print('asyn denied')
--            if url and string.len(url) > 0 then
--                imageLoaderPlugin:loadOnlineImage(userID, url, size, function(code,path)
--                    callbackFunc(code, path, imageStatus)
--                end)
--            end
            if url and string.len(url) > 0 then
                if isLocalImageExist(userID, url, size) then
                    local imageData = imageLoaderPlugin:getLocalImage_sync(userID, size)
                    callbackFunc(ImageLoadActionResultCode.kImageLoadOnlineSuccess, imageData.path, imageStatus)
                else
                    imageLoaderPlugin:loadOnlineImage(userID, url, size, function(code,path)
                        callbackFunc(code, path, imageStatus)
                    end)
                end
            else
                imageLoaderPlugin:deleteImageData(userID)
            end
            
        elseif imageStatus == ImageCtrl.TRANSSTATUS_NORMAL then

            if not isLocalImageExist(userID, url, size) then     
                imageLoaderPlugin:loadOnlineImage(userID, url, size, function(code,path)
                    callbackFunc(code, path, imageStatus)
                end)
            else
                print('image exist already, download operation off')
            end
            print('asyn normal')

        elseif imageStatus == ImageCtrl.TRANSSTATUS_AUDITTING then 
        
            if ((not isLocalImageExist(userID, url, size)) and userID == mymodel('UserModel'):getInstance().nUserID) then     
                imageLoaderPlugin:loadOnlineImage(userID, url, size,function(code,path)
                    callbackFunc(code, path, imageStatus)
                end)
            else
                print('image exist already, download operation off')
            end
            print('asyn pending')
        
        else
    
            print("unexpected imageStatus, online operation off")

        end

    else
    
        print("other player with no usersTable or new player, online operation off")
            
    end
end

local function getSelfPortraitInfo()
    
    local accToken = userPlugin:getAccessToken()
    if tcyFriendPlugin==nil then return end
    if (imageDataUpdating) then 
    	print('imageDataUpdatingnow please wait.')
    	return
    end
    imageDataUpdating = true

    local function tcyFriendGetSelfPortraitInfo()
        tcyFriendPlugin:getSelfPortraitInfo(function(code, b, pendingauditshow, table)
            printf("getSelfPortraitInfo")
            printf("code = %d", code)
            printf("b = %s", b)
            
            if code == 0 then 
                print('~~~~~~get personalTable~~~~~~~~')
                personalTable = table
                personalTable.pendingauditshow=pendingauditshow
                dump(personalTable)               
                print('eventdispatched')
                ImageCtrl:dispatchEvent({name = ImageCtrl.PERSONALTABLE_GET})
            else 
                print('code ='..code)
                print('message='..b)
            end
        end)
        my.scheduleOnce(function()
            if (imageDataUpdating and cc.Application:getInstance():getTargetPlatform() 
                ~= cc.PLATFORM_OS_WINDOWS) then 
                print("getTcyFriendGetSelfPortraitInfo no response, recalling")
                tcyFriendGetSelfPortraitInfo()
            end
        end, 20)
    end

    tcyFriendGetSelfPortraitInfo()


end

local function getPortraitInfoByUserIDs(userIDs, size, callback)

    if not tcyFriendPlugin then return end
    tcyFriendPlugin:getPortraitInfoByUserIDs(userIDs, #userIDs, function(code, msg, pendingauditshow, portraitdatas)

        print("code:"..code)
        print("msg:"..msg)
        dump(portraitdatas)
        callback(pendingauditshow,portraitdatas)

    end)

end

local function callbackDecorator(callbackFunc, tag)
    if tag then
        callbackTags[tag] = true
        return function( ... )
            if callbackTags[tag] then
                callbackFunc( ... )
            end
            callbackTags[tag] = nil
        end
    else
        return callbackFunc
    end
end

function ImageCtrl:getSelfImage(sizeWanted, callbackFunc, mode, tag)
    local callbackFuncDecorator = callbackDecorator(callbackFunc, tag)

    if not cc.exports.isSocialSupported() then 
    	return 
    end 
    local size = getAvailableSize(sizeWanted)
    local userID = tonumber(userPlugin:getUserID())

    if (personalTable.userid and personalTable.userid == userID) then --and personalTable.status ~= ImageCtrl.AUDITSTATUS_DENIED) then 
        print('personalTable ready, ')
        local imageStatus = getSelfTransStatus()

        if mode and mode == "cache" then
             getLocalImage(userID, size, callbackFuncDecorator, nil)
             return
        end

        getLocalImage(userID, size, callbackFunc, nil)
       
        getSelfPortraitInfo()
        table.insert(callbackCollector, function() 
            getOnlineImage(userID, size, callbackFuncDecorator, personalTable.portraiturl, nil)
        end)
        
    else
        print('personalTable not ready, waiting for event')
        getSelfPortraitInfo()
        table.insert(callbackCollector,function ( )
 
            print('personalTable ready, event caught')
            getLocalImage(userID, size, callbackFunc, nil)
            getOnlineImage(userID, size, callbackFuncDecorator, personalTable.portraiturl, nil)
     
        end) 
    end 

end

function ImageCtrl:getImageByUserIDs(userIDs, sizeWanted, callbackFunc, tag)
    local callbackFunc = callbackDecorator(callbackFunc, tag)

    if not cc.exports.isSocialSupported() then 
        return 
    end
    
    local usersTable = {}
    for i = 1,#userIDs do 
        usersTable[tonumber(userIDs[i])]={} 
        getLocalImage(tonumber(userIDs[i]), sizeWanted, callbackFunc, usersTable)
    end
     
    local pendingAuditShow = nil
    local portraitDatas = {}
    local usersTable = {}
    local size = getAvailableSize(sizeWanted)

    --added by zhangqi2231 for ios设备都使用本地图片
    if device.platform == 'ios' then
        if not my.isEngineSupportVersion("v1.3.20170401") then
            return
        end
    end

    getPortraitInfoByUserIDs(userIDs, size, function(pendingauditshow,portraitdatas)

        pendingAuditShow =  pendingauditshow
        portraitDatas = portraitdatas

        for i = 1, #userIDs do
            usersTable[tonumber(userIDs[i])]={}
            if portraitDatas[tonumber(userIDs[i])]  then
                printf("userid = "..portraitDatas[tonumber(userIDs[i])].userid)
                printf("status = "..portraitDatas[tonumber(userIDs[i])].status)
                printf("fromappid = "..portraitDatas[tonumber(userIDs[i])].fromappid)
                printf("updatetimestamp = "..portraitDatas[tonumber(userIDs[i])].updatetimestamp)
                printf("portraitkey = "..portraitDatas[tonumber(userIDs[i])].portraitkey)
                printf("portraiturl = "..portraitDatas[tonumber(userIDs[i])].portraiturl)

                --judge the imageStatus
                local imageStatus = statusDistribution(portraitDatas[tonumber(userIDs[i])].status, pendingAuditShow)
                if imageStatus ~=  ImageCtrl.TRANSSTATUS_NORMAL then 
                    print("userid:"..userIDs[i].."imageStatus auditting or denied, imageStatus:"..imageStatus)
                    usersTable[tonumber(userIDs[i])].userID = tonumber(userIDs[i])
                    usersTable[tonumber(userIDs[i])].path = ''
                    checkUsersTable(usersTable,callbackFunc)
                    break
                end

                getLocalImage(tonumber(userIDs[i]), size, callbackFunc, usersTable)
                getOnlineImage(tonumber(userIDs[i]), size, callbackFunc, portraitDatas[tonumber(userIDs[i])].portraiturl, usersTable)
            else
                usersTable[tonumber(userIDs[i])] = {}
                usersTable[tonumber(userIDs[i])].userID = tonumber(userIDs[i])
                usersTable[tonumber(userIDs[i])].path = ''
                checkUsersTable(usersTable,callbackFunc)

            end 
        end
    end)
end

function ImageCtrl:getImageForGameScene( data,sizeWanted, callbackFunc, tag)
    local callbackFunc = callbackDecorator(callbackFunc, tag)

    if not cc.exports.isSocialSupported() then 
    	return 
    end 	
	local usersTable={}
	local size = getAvailableSize(sizeWanted)
    for k,v in pairs(data) do usersTable[data[k].userID]={} end
    for k,v in pairs(data) do

    	if data[k].url ~= '' then 

            getLocalImage(data[k].userID, size, callbackFunc, usersTable)
            getOnlineImage(data[k].userID, size, callbackFunc, data[k].url, usersTable)

    	else

    	   usersTable[data[k].userID].userID = data[k].userID
    	   usersTable[data[k].userID].path = ''
    	   checkUsersTable(usersTable,callbackFunc)

    	end

    end

end

function ImageCtrl:getPortraitCacheForGS(  )
	local offerTable = {}
    if(user==nil)then
    	return offerTable
    end
	if personalTable.userid == tonumber(userPlugin:getUserID()) and getSelfTransStatus() ~= ImageCtrl.TRANSSTATUS_AUDITTING then
	    offerTable.userID = personalTable.userid
	    offerTable.url = personalTable.portraiturl
	else 
		offerTable.userID = tonumber(userPlugin:getUserID())
		offerTable.url = ''
	end

	return offerTable
end

function ImageCtrl:removeCallbackByTag(tag)
    callbackTags[tag] = nil
end

ImageCtrl:addEventListener(ImageCtrl.PERSONALTABLE_GET,function ( )

    print('personalTable ready, event caught')

    imageDataUpdating = false
    for i = 1,#callbackCollector do 
    	print(callbackCollector[i]())
    end
    if #callbackCollector == 0 then
    	print('collector is empty')
    end
    callbackCollector = {}
end)



return ImageCtrl
