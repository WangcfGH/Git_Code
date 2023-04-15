local PluginProcessModel = class("PluginProcessModel")
local user = mymodel('UserModel'):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

my.addInstance(PluginProcessModel)

PluginProcessModel.PROCSEE_NOT_START = 1
PluginProcessModel.PROCSEE_RUNNING = 2
PluginProcessModel.PROCESS_FINISHED = 3

PluginProcessModel.PLUGIN_PROCESS_FINISHED = "PLUGIN_PROCESS_FINISHED"

PluginProcessModel.NOTIFY_CLOSE_ALL_PLUGIN = "NOTIFY_CLOSE_ALL_PLUGIN"
PluginProcessModel.CLOSE_REWARD_TIP_CTRL = "CLOSE_REWARD_TIP_CTRL"
PluginProcessModel.CLOSE_SHOP_CTRL = "CLOSE_SHOP_CTRL"
PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE = "CLOSE_PLUGIN_ON_GUIDE"

function PluginProcessModel:ctor()
    local event = cc.load('event')
    event:create():bind(self)

    self:init()
end

function PluginProcessModel:init()
    self:reset()
end

--1.初始化弹窗功能
function PluginProcessModel:reset()
    self._processStatus = PluginProcessModel.PROCSEE_NOT_START
    self._needStartPluginProcess = false
    self._pluginList = {}
    self._forcePluginList = {}

    self._readyList = {
    }

    self._switchPopAction = {
        ["NewUserRewardPlugin"] = function()
            self:popUserRewardPlugin()
        end,
        ["ActivityCenterCtrl"] = function()
            self:popActivityCenterCtrl()
        end,
        ["GoldSilverCtrl"] = function()
            self:popGoldSilverCtrl()
        end,
        ["GoldSilverCtrlCopy"] = function()
            self:popGoldSilverCtrlCopy()
        end,
        ["WeekCard"] = function()
            self:popWeekCardCtrl()
        end,
        ["NewUserInviteGiftCtrlEx"] = function()
            self:popNewUserInviteGiftCtrlEx()
        end
    }
end

--得到需要弹出的活动名称列表 ios中不存在NewUserGuideModel
function PluginProcessModel:getPopPluginList()
    local user=mymodel('UserModel'):getInstance()

    if user.nBout and user.nBout == 0 then
        return cc.exports.getNewUserPopPluginList()
    end
    return cc.exports.getNormalUserPopPluginList()
end


function PluginProcessModel:startPluginProcess()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
    
    --若 需要开启 为true 则添加数据
    if not self:isNeedStart() then return end
    if self._processStatus ~= PluginProcessModel.PROCSEE_NOT_START then return end

    local bReady = self:isAllPluginReady()
    if bReady then
        --每天一次登录弹框start
        local user = mymodel('UserModel'):getInstance()
        dump(self._readyList, "startPluginProcess readyList" .. tostring(user.nUserID));
        dump(self._pluginList, "startPluginProcess pluginList" .. tostring(user.nUserID))

        self._needStartPluginProcess = false
        self._processStatus = PluginProcessModel.PROCSEE_RUNNING
        self:PopNextPlugin()
    end
end

function PluginProcessModel:startPluginProcessWhileTimeOut()

    --打印日志信息
    local user = mymodel('UserModel'):getInstance()
    dump(self._readyList, "startPluginProcessWhileTimeOut readyList" .. tostring(user.nUserID));
    dump(self._pluginList, "startPluginProcessWhileTimeOut pluginList" .. tostring(user.nUserID))

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
    if not self:isNeedStart() then return end
    if self._processStatus ~= PluginProcessModel.PROCSEE_NOT_START then return end

    --每天一次登录弹框start
    self._needStartPluginProcess = false
    self._processStatus = PluginProcessModel.PROCSEE_RUNNING
    self:PopNextPlugin()
end

--实例化活动列表的弹窗
function PluginProcessModel:PopNextPlugin()
    if not CenterCtrl:checkNetStatus() then
        return
    end
    
    if  self._processStatus ~= PluginProcessModel.PROCSEE_RUNNING then return end
    local plugin = nil
    if #self._pluginList > 0 then
        plugin = self._pluginList[1]
        table.remove(self._pluginList, 1)
    else
        --ProcessFinish
        self._processStatus = PluginProcessModel.PROCESS_FINISHED
        self:dispatchEvent({name = self.PLUGIN_PROCESS_FINISHED})
        return
    end

    if plugin and self._readyList[plugin] then
        if self._switchPopAction[plugin] then--针对一些需要传递参数的插件
            self._switchPopAction[plugin]()
        else
            self:DefautPopMethod(plugin)
        end
    else
        self:PopNextPlugin()
    end
end

function PluginProcessModel:getTodayDate()
    return os.date('%Y_%m_%d',os.time())
end

function PluginProcessModel:saveMyGameDataXml(gameData, nUserID)
    my.saveCache("MyGameData"..nUserID..".xml", gameData)
end

function PluginProcessModel:getMyGameDataXml(nUserID)
    return my.readCache("MyGameData"..nUserID..".xml")
end

--等待所有的项目都准备完毕
function PluginProcessModel:isAllPluginReady()
    for k,v in pairs(self._pluginList) do
        if self._readyList[v] == nil then
            return false
        end
    end
    return true
end

function PluginProcessModel:DefautPopMethod(pluginName)
    my.informPluginByName({pluginName=pluginName})
end

--2. 各活动模块初始化时，加入到_readyList中
function PluginProcessModel:setPluginReadyStatus(pluginName,nStatus)
    local bForcePop = table.indexof(self._forcePluginList, pluginName)
    if bForcePop ~= false then
        if not self:isNeedStart() then
            self._pluginList = clone(self._forcePluginList)
            self._needStartPluginProcess = true
        end
    end
    self._readyList[pluginName] = nStatus
end

--判断今天是否是第二次登入
function PluginProcessModel:resetNeedStart()
    local myGameData = self:getMyGameDataXml(user.nUserID)
    local date = self:getTodayDate()
    if date ~= myGameData.logindate then
        myGameData.nTodayBouts = 0
        myGameData.nTakeReliefCount = 0
        self:setNeedStart(true)
        self:saveMyGameDataXml(myGameData, user.nUserID)
    else
        self._pluginList = {}
        self:setNeedStart(false)
        --调试使用
        --self:setNeedStart(true)
    end
end

function PluginProcessModel:setNeedStart(needStart)
    self._needStartPluginProcess = needStart
end

function PluginProcessModel:isNeedStart()
    return self._needStartPluginProcess
end

function PluginProcessModel:stopPluginProcess()
    self._needStartPluginProcess = false
    self._processStatus = PluginProcessModel.PROCESS_FINISHED
    self._pluginList  = {}
end

function PluginProcessModel:popUserRewardPlugin()
    local mainCtrl = cc.load('MainCtrl'):getInstance()
    local giftDeposite = user.nDeposit
    local utf8Content = string.format(mainCtrl:getGameStringToUTF8ByKey("G_GAME_NEW_PLAYER_REWARD_DEPOSITE"), giftDeposite)
    my.informPluginByName({pluginName='NewUserRewardPlugin', params={tipString=utf8Content}})
end

function PluginProcessModel:popActivityCenterCtrl()
    my.informPluginByName({pluginName='ActivityCenterCtrl', params={auto=true}})
end

function PluginProcessModel:popGoldSilverCtrl()
    my.informPluginByName({pluginName='GoldSilverCtrl', params={auto=true}})
end 

function PluginProcessModel:popGoldSilverCtrlCopy()
    my.informPluginByName({pluginName='GoldSilverCtrlCopy', params={auto=true}})
end

function PluginProcessModel:popWeekCardCtrl()
    my.informPluginByName({pluginName='WeekCard', params={auto=true}})
end

function PluginProcessModel:popNewUserInviteGiftCtrlEx()
    my.informPluginByName({pluginName='NewUserInviteGiftCtrl', params={isBinding = true}})
end

function PluginProcessModel:notifyClosePlugin( )
    self:dispatchEvent({name = self.NOTIFY_CLOSE_ALL_PLUGIN})
end

function PluginProcessModel:closeRewardTipCtrl( )
    self:dispatchEvent({name = self.CLOSE_REWARD_TIP_CTRL})
end

function PluginProcessModel:closeShopCtrl( )
    self:dispatchEvent({name = self.CLOSE_SHOP_CTRL})
end

function PluginProcessModel:closePluginOnGuide( )
    self:dispatchEvent({name = self.CLOSE_PLUGIN_ON_GUIDE})
end

--把某功能插入到第几位的顺序弹出列表上
function PluginProcessModel:setPluginNameInPluginList(insertName, pos)
    self._processStatus = PluginProcessModel.PROCSEE_NOT_START    
    if pos > 0 and  #self._pluginList >= pos then
        table.insert(self._pluginList,pos,insertName)
    end
end

function PluginProcessModel:removePluginList(removeName)
    self._processStatus = PluginProcessModel.PROCSEE_NOT_START
    if #self._pluginList > 0 then
        for k,v in pairs(self._pluginList) do
            if v == removeName then
                table.remove(self._pluginList, k)
                break
            end
        end
    end
end

function PluginProcessModel:continuePluginProcess()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return false
    end

    local myGameData = PluginProcessModel:getMyGameDataXml(user.nUserID)
    local date = PluginProcessModel:getTodayDate()
    if date ~= myGameData.logindate then
        if #self._pluginList  > 0 then  -- 返回大厅，如果需要继续弹窗，先判断列表里还有没有
            self._processStatus = PluginProcessModel.PROCSEE_RUNNING
            --self:LimitPopCount()
            self:PopNextPlugin()
        else
            self._processStatus = PluginProcessModel.PROCESS_FINISHED
            self._pluginList  = {}
        end
        return true
    end
    return false
end

function PluginProcessModel:LimitPopCount()
    if not cc.exports.isAutoPopCountSupported() then return end

    local count         = 0
    local limitCount    = 0

    if user.nBout and user.nBout > 10 then
        limitCount = cc.exports.isAutoPopNormalPlayerCount()        
    else
        limitCount = cc.exports.isAutoPopNewPlayerCount()
    end

    for k,v in pairs(self._pluginList) do
        if count >= limitCount and self._readyList[v] ~= nil and self._readyList[v] == true then
            self._readyList[v] = false
        end

        if self._readyList[v] ~= nil and self._readyList[v] == true then
            count = count + 1
        end
    end
end


--刷新需要弹出的活动名称列表
function PluginProcessModel:resetPluginList()
    self._pluginList = clone(self:getPopPluginList())
    local user = mymodel('UserModel'):getInstance()
    user:isRoomHost()
    dump(self._pluginList, 'self._pluginList' .. tostring(user.nUserID))
end

return PluginProcessModel

