
local viewCreater       = import('src.app.plugins.sharectrl.ShareView')
local ShareCtrl         = class('ShareCtrl',cc.load('BaseCtrl'))
--local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()

require('src.app.TcyCommon.MCConst')
local shareObj  = nil
local json      = cc.load("json").json

local config = cc.exports.GetRoomConfig()

local deviceUtils = DeviceUtils:getInstance()

local event=cc.load('event')
event:create():bind(ShareCtrl)

ShareCtrl.SHARE_SUCCESS_RET = "SHARE_TASK_SUCCESS"

local function getType( type )
    local index = 0
    local ta = cc.exports.C2DXContentType
    for i,v in pairs(ta) do
        if( i == type ) then
            index = v
            break
        end
    end
    
    return tostring(index)
end

function ShareCtrl:loadShareConfig()

    self._enableClicked = true

    local content = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ShareConfig.json")
    shareObj = json.decode(content)
    shareObj["ToWeiBo"]["type"] =  getType( shareObj["ToWeiBo"]["type"] )

    shareObj["ToWeiXin"]["type"] =  getType( shareObj["ToWeiXin"]["type"] )
    
    shareObj["ToWeiXinFriend"]["type"] =  getType( shareObj["ToWeiXinFriend"]["type"] )
    
    shareObj["ToGameShare"]["type"] =  getType( shareObj["ToGameShare"]["type"] )
    
    local imageName = shareObj["ToWeiXinFriend"]["image"]
    local defaultPath = shareObj["DefaulteImagePath"]
    local pic = cc.FileUtils:getInstance():getStringFromFile(defaultPath..imageName)
    local targetPath = BusinessUtils:getInstance():getUpdateDirectory() .. imageName
    local file = io.open(targetPath,"wb+")
    file:write( pic )
    file:close()
    shareObj["ToWeiXinFriend"]["image"] = targetPath
    shareObj["ToWeiXinFriend"]["imagePath"] = targetPath

    local imageName1 = shareObj["ToWeiXin"]["image"]
    local defaultPath2 = shareObj["DefaulteImagePath"]
    targetPath = BusinessUtils:getInstance():getUpdateDirectory() .. imageName1
    if( (imageName1 ~= imageName)or(defaultPath2 ~= defaultPath) )then
        pic = cc.FileUtils:getInstance():getStringFromFile(defaultPath2..imageName1)
        file = io.open(targetPath,"wb+")
        file:write( pic )
        file:close()
    end
    shareObj["ToWeiXin"]["image"] = targetPath
    shareObj["ToWeiXin"]["imagePath"] = targetPath
    
    local imageName2 = shareObj["ToGameShare"]["image"]
    local defaultPath3 = cc.FileUtils:getInstance():getGameWritablePath()
    local pic2 = cc.FileUtils:getInstance():getStringFromFile(defaultPath3..imageName2)
    local filePath = BusinessUtils:getInstance():getUpdateDirectory()
    targetPath = filePath .. imageName2
    file = io.open(targetPath,"wb+")
    file:write( pic2 )
    file:close()

    shareObj["ToGameShare"]["image"] = targetPath
    shareObj["ToGameShare"]["imagePath"] = targetPath

end

function ShareCtrl:onCreate( ... )
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
	self:bindDestroyButton(viewNode.closeBt)

	self:bindUserEventHandler(viewNode)
    
    self:loadShareConfig()
    
    if viewNode.qrCodeBg then
        viewNode.qrCodeBg:setVisible(true)
    end
    if viewNode.codeBg then
        viewNode.codeBg:setVisible(true)
    end
end

function ShareCtrl:shareToMicroBlogBtClicked( ... )
    if( require('src.app.plugins.tip.TipCtrl'):IsShow() )then
        return
    end
    
    if( self._enableClicked == false )then
        printInfo("not share enable")
        return
    end
    
    self:startShareWaitTimer()
    
    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if( sharePlugin == nil )then
        local tt = MCCharset:getInstance():gb2Utf8String( config["FunctionLess"],string.len(config["FunctionLess"]) )
        ShareCtrl:ShowTips( config["FunctionLess"] )
        return
    end
    sharePlugin:setCallback(function(code, msg)
        printInfo("~~~~~~~~~~share failed %d~~~~~~~~~~~~~~~",code)
        printInfo("~~~~~~~~~~share failed %s~~~~~~~~~~~~~~~~~~~~~~~",msg)
        self._enableClicked = true
  
        local tt = MCCharset:getInstance():gb2Utf8String( config["ShareFailed"],string.len(config["ShareFailed"]) )
        ShareCtrl:ShowTips( config["ShareFailed"] )
    end)
    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(
        cc.exports.C2DXPlatType.C2DXPlatTypeSinaWeibo,
        true,
        shareObj["ToWeiBo"]
    )

    print("execute share to weibo")
end

function ShareCtrl:shareToWechatClicked( ... )
    if not deviceUtils:isAppInstalled("com.tencent.mm") then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipNotInstalledWeChat"],removeTime=1}})
        return
    else
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipGoToWeChatShare"],removeTime=1}})
    end

    if( self._enableClicked == false )then
        printInfo("not share enable")
        return
    end

    self:startShareWaitTimer()
    
	local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if( sharePlugin == nil )then
        local tt = MCCharset:getInstance():gb2Utf8String( config["FunctionLess"],string.len(config["FunctionLess"]) )
        ShareCtrl:ShowTips( config["FunctionLess"] )
        return
    end
    sharePlugin:setCallback(function(code, msg)
        printInfo("%d",code)
        printInfo("%s",msg)
        self:stopShareWaitTimer()
        
        if code == cc.exports.ShareResultCode.kShareSuccess then
            self:changeTaskShare()
        else
            local tt = MCCharset:getInstance():gb2Utf8String( config["ShareFailed"],string.len(config["ShareFailed"]) )
            ShareCtrl:ShowTips( config["ShareFailed"] )
        end
    end)
    
    math.randomseed(os.time())
    local num = math.random(1,4)
    shareObj["ToWeiXin"]["content"] = shareObj["ToWeiXin"]["content"..num]
    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(
        cc.exports.C2DXPlatType.C2DXPlatTypeWeixiSession,
        true,
        shareObj["ToWeiXin"]
        )

    print("execute share to weixi")
end

function ShareCtrl:shareToFriendsCornerClicked(isNeedBoutLimit)
    if not deviceUtils:isAppInstalled("com.tencent.mm") then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipNotInstalledWeChat"],removeTime=1}})
        return
    else
        local nTodayPlayedBouts = 0
        --local mainctrl = cc.load('MainCtrl'):getInstance()
        local user=mymodel('UserModel'):getInstance()
        local myGameData = user:getMyGameDataXml(user.nUserID) or {}
        if myGameData then
            -- 先从缓存取值，取不到从每日任务取
            if myGameData.nTodayBouts and myGameData.nTodayBouts > 0 then
                nTodayPlayedBouts = myGameData.nTodayBouts
            else
                local list = cc.exports._GameTaskList
                -- 如果缓存没有今日对局数记录，就从每日任务中获取
                if list and next(list) ~= nil and list[1]._progress then
                    local valueTab = {}
                    valueTab = cc.exports.string_split(list[1]._progress[1]._text,'/')
                    nTodayPlayedBouts= tonumber(valueTab[1])    -- 取每日任务1/20的分子，也就是今日对局数
                end
            end            
             
            if nTodayPlayedBouts < 1 then
                if not isNeedBoutLimit or isNeedBoutLimit == 1 then
                    my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipNeedPlayFirst"],removeTime=1}})
                    return
                end   
            end
        end
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipGoToWeChatShare"],removeTime=1}})
    end    
    
    if( self._enableClicked == false )then
        printInfo("not share enable")
        return
    end

    self:startShareWaitTimer()

    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if( sharePlugin == nil )then
        local tt = MCCharset:getInstance():gb2Utf8String( config["FunctionLess"],string.len(config["FunctionLess"]) )
        ShareCtrl:ShowTips( config["FunctionLess"] )
        return
    end
    
    sharePlugin:setCallback(function(code, msg)
        printInfo("%d",code)
        printInfo("%s",msg)
        self:stopShareWaitTimer()
        
        if code == cc.exports.ShareResultCode.kShareSuccess then
            self:changeTaskShare()
            self:dispatchEvent( { name = ShareCtrl.SHARE_SUCCESS_RET })
        else
            local tt = MCCharset:getInstance():gb2Utf8String( config["ShareFailed"],string.len(config["ShareFailed"]) )
            ShareCtrl:ShowTips( config["ShareFailed"] )
        end
    end)
    
    math.randomseed(os.time())
    local num = math.random(1,4)
    shareObj["ToWeiXinFriend"]["content"] = shareObj["ToWeiXinFriend"]["content"..num]
    shareObj["ToWeiXinFriend"]["title"] = shareObj["ToWeiXinFriend"]["content"..num]
    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(
        cc.exports.C2DXPlatType.C2DXPlatTypeWeixiTimeline,
        true,
        shareObj["ToWeiXinFriend"]
    )

    print("execute share to Wei Xi Friend")
end

function ShareCtrl:ShowTips(text)  
	my.scheduleOnce(function()
		my.informPluginByName({pluginName='ToastPlugin',params={tipString=text,removeTime=1}})
	end, 0.2)
end

function ShareCtrl:shareToWechatInGame( ... )
    if not deviceUtils:isAppInstalled("com.tencent.mm") then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipNotInstalledWeChat"],removeTime=1}})
        return
    else
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipGoToWeChatShare"],removeTime=1}})
    end    
    
    if( self._enableClicked == false )then
        printInfo("not share enable")
        return
    end
    
    self:startShareWaitTimer()

    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if( sharePlugin == nil )then
        local tt = MCCharset:getInstance():gb2Utf8String( config["FunctionLess"],string.len(config["FunctionLess"]) )
        ShareCtrl:ShowTips( config["FunctionLess"] )
        return
    end
    sharePlugin:setCallback(function(code, msg)
        printInfo("%d",code)
        printInfo("%s",msg)
        self:stopShareWaitTimer()

        if code == cc.exports.ShareResultCode.kShareSuccess then
            self:changeTaskShare()
        else
            local tt = MCCharset:getInstance():gb2Utf8String( config["ShareFailed"],string.len(config["ShareFailed"]) )
            ShareCtrl:ShowTips( config["ShareFailed"] )
        end
    end)
    
    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(
        cc.exports.C2DXPlatType.C2DXPlatTypeWeixiSession,
        true,
        shareObj["ToGameShare"]
    )

    print("execute share to weichat")
end

function ShareCtrl:shareToMomentsInGame( ... )
    if not deviceUtils:isAppInstalled("com.tencent.mm") then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipNotInstalledWeChat"],removeTime=1}})
        return
    else
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=shareObj["TipGoToWeChatShare"],removeTime=1}})
    end    
    

    if( self._enableClicked == false )then
        printInfo("not share enable")
        return
    end
    
    self:startShareWaitTimer()

    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if( sharePlugin == nil )then
        local tt = MCCharset:getInstance():gb2Utf8String( config["FunctionLess"],string.len(config["FunctionLess"]) )
        ShareCtrl:ShowTips( config["FunctionLess"] )
        return
    end
    sharePlugin:setCallback(function(code, msg)
        print("%d",code)
        print("%s",msg)
        self:stopShareWaitTimer()

        if code == cc.exports.ShareResultCode.kShareSuccess then
            self:changeTaskShare()
        else
            local tt = MCCharset:getInstance():gb2Utf8String( config["ShareFailed"],string.len(config["ShareFailed"]) )
            ShareCtrl:ShowTips( config["ShareFailed"] )
        end
    end)

    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(
        cc.exports.C2DXPlatType.C2DXPlatTypeWeixiTimeline,
        true,
        shareObj["ToGameShare"]
    )

    print("execute share to weichat friend")
end

--留空 要实现任务的 要和任务接口做一个定义 到时候这里写上就可以不改代码了
function ShareCtrl:changeTaskShare()
    local tt = MCCharset:getInstance():gb2Utf8String( config["ShareOK"],string.len(config["ShareOK"]) )
    ShareCtrl:ShowTips( config["ShareOK"] )

    --AssistConnect:SendChangeTaskParamReq(AssistDef.TASK_GAME_SHARE)
    local TaskModel = import("src.app.plugins.MyTaskPlugin.TaskModel"):getInstance()
    TaskModel:SendChangeTaskParamReq(TaskModel.TaskDef.TASK_GAME_SHARE)
    --[[AssistConnect:SendChangeLotteryShareReq()
    my.scheduleOnce(function()
            print("ShareCtrl:changeTaskShare")
            AssistConnect:SendLotteryCountReq()   --抽奖红点问题 服务器不会reponse  SendChangeLotteryShareReq
        end , 0.5)]]--
    
    local MyGameController = import('src.app.Game.mMyGame.MyGameController')
    MyGameController:ChangeParamTask(5,1)
end

function ShareCtrl:startShareWaitTimer()
    
    self._enableClicked = false
    local function callbackClick()
        if self._shareEnableWaitTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareEnableWaitTimer)
            self._shareEnableWaitTimer = nil
        end
        self._enableClicked = true
    end
    self._shareEnableWaitTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callbackClick, 2.0, false)
end

function ShareCtrl:stopShareWaitTimer()
    self._enableClicked = true
end


function ShareCtrl:onKeyBack()
    if self._shareWaitTimer then
        return
    end
    self:playEffectOnPress()
    self._shareWaitTimer = my.scheduleOnce(function()
--    self._toDestroySelf=true
--    self:respondDestroyEvent()
        self._shareWaitTimer = nil
    if(self:informPluginByName(nil,nil))then
      self:removeSelfInstance()
    end
  end)  
end


function ShareCtrl:onExit()
    if self._shareWaitTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareWaitTimer)
        self._shareWaitTimer = nil
    end

    if self._shareEnableWaitTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareEnableWaitTimer)
        self._shareEnableWaitTimer = nil
    end
end

return ShareCtrl
