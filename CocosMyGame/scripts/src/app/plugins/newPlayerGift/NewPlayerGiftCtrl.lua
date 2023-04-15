local NewPlayerGiftCtrl     = class("NewPlayerGiftCtrl", cc.load('BaseCtrl'))
local viewCreater       	   = import("src.app.plugins.newPlayerGift.NewPlayerGiftView")
local NewPlayerGiftModel    = import("src.app.plugins.newPlayerGift.NewPlayerGiftModel"):getInstance()
local json                  = cc.load("json").json
local StringConfig          = json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/NewPlayerGiftString.json"))
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

NewPlayerGiftCtrl.ctrlConfig = {
    ["pluginName"] = "NewPlayerGiftCtrl",
    ["isAutoRemoveSelfOnNoParent"] = true
}
function NewPlayerGiftCtrl:onCreate(...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    local PublicInterface = cc.exports.PUBLIC_INTERFACE
    local playerInfo = PublicInterface.GetPlayerInfo()
    self._nUserID = playerInfo.nUserID

    --注册点击事件
    self:registWidgetEvents()

    if self._viewNode and self._viewNode.btnClose then
    self:bindDestroyButton(self._viewNode.btnClose)
    end
    self:init()

    if DEBUG > 0 then
        NewPlayerGiftModel:newPlayerGiftInfoReq()
    end
end

--------------------------------------------------------------------------------------------------------
--监听接口
function NewPlayerGiftCtrl:registWidgetEvents()
    --设置领取礼包点击事件
    local function onClickBtnTakeGift()
        NewPlayerGiftModel:getNewPlayerGiftReq()
    end
    if self._viewNode and self._viewNode.btnTake then
        self._viewNode.btnTake:addClickEventListener(onClickBtnTakeGift)
    end
    if self._viewNode.nodeGiftPop then
        local function hidePop()
            self._viewNode.nodeGiftPop:setVisible(false)
            if 0 == NewPlayerGiftModel:getGiftIndex() then
                self:removeSelfInstance()
            end
        end
        self._viewNode.btnClosePop:addClickEventListener(hidePop)
    end
    self:listenTo(NewPlayerGiftModel,NewPlayerGiftModel.EVENT_GIFT_REWARD_GOT,handler(self,self.showGiftPop))
    self:listenTo(NewPlayerGiftModel,NewPlayerGiftModel.EVENT_GIFT_INFO_UPDATE,handler(self,self.initView))
    self:listenTo(PluginProcessModel,PluginProcessModel.NOTIFY_CLOSE_ALL_PLUGIN,handler(self,self.onNotifyClose))
end

--------------------------------------------------------------------------------------------------------
--数据层事件处理
--[Comment]
function NewPlayerGiftCtrl:init()
    self:hideGiftPop()

    self:initView()
end

--刷新新手礼包界面
function NewPlayerGiftCtrl:initView()
    if not NewPlayerGiftModel._info or not NewPlayerGiftModel._config then return end
    --如果新手礼包全部领完
    if 0 == NewPlayerGiftModel:getGiftIndex() then
        self:removeSelfInstance()
        return
    end

    local info = NewPlayerGiftModel._info
    if (os.time() > info.nGiftTime) and (os.date('%d',os.time()) ~= os.date('%d',info.nGiftTime)) or info.nGiftTime == 0 then
        self:freshViewNode(info.nGiftIndex,true)
    else
        self:freshViewNode(info.nGiftIndex,false)
    end
end

--显示可领取或不可领取的界面
function NewPlayerGiftCtrl:freshViewNode(nGiftIndex,isTakeEnabel)
    print("NewPlayerGiftCtrl:freshViewNode")
    local config = NewPlayerGiftModel:getGiftConfig()
    if not config and not config.newPlayerGiftConfig then return end
    self._giftConfig = config["newPlayerGiftConfig"]

    local totalDays = config.newPlayerDays

    self:setGiftIcon(nGiftIndex,isTakeEnabel)
    self:setGiftCount(nGiftIndex)
    self:setTotalDays(totalDays)
    self:setCurrentDays(nGiftIndex)
    self:setTakeEnable(isTakeEnabel)
end

--设置礼包图片
function NewPlayerGiftCtrl:setGiftIcon(nGiftIndex,isTakeEnabel)
    if not self._giftConfig then return end
    if nGiftIndex > #self._giftConfig then return end
    if not self._giftConfig[nGiftIndex]  then return end

    if isTakeEnabel then
        self._viewNode.imgReward:setColor(cc.c3b(255,255,255))--置亮
    else
        self._viewNode.imgReward:setColor(cc.c3b(77,77,77))--置灰
    end
    local type = self._giftConfig[nGiftIndex]["type"]
    if type == NewPlayerGiftModel.TYPE_SILVER then
        self._viewNode.imgSilver:setVisible(true)
        self._viewNode.imgTicket:setVisible(false)
    elseif type == NewPlayerGiftModel.TYPE_TICKET then
        self._viewNode.imgSilver:setVisible(false)
        self._viewNode.imgTicket:setVisible(true)
    end
end

--设置礼包数量
function NewPlayerGiftCtrl:setGiftCount(nGiftIndex)
    if not self._giftConfig then return end
    if nGiftIndex > #self._giftConfig then return end
    local type = self._giftConfig[nGiftIndex]["type"]
    local count = self._giftConfig[nGiftIndex]["count"]
    if type == NewPlayerGiftModel.TYPE_SILVER then
        self._viewNode.textGiftCount:setString(string.format(StringConfig.GIFT_SILVER_COUNT,count))
    elseif type == NewPlayerGiftModel.TYPE_TICKET then
        self._viewNode.textGiftCount:setString(string.format(StringConfig.GIFT_TICKET_COUNT,count))
    end   
end

function NewPlayerGiftCtrl:setTotalDays(nTotalDays)
    self._viewNode.fntTotalDay:setString(StringConfig["GIFT_DAY_"..nTotalDays])
end

function NewPlayerGiftCtrl:setCurrentDays(nGiftIndex)
    self._viewNode.fntGiftIndex:setString("第"..StringConfig["GIFT_DAY_"..nGiftIndex].."天")
end

function NewPlayerGiftCtrl:setTakeEnable(isTakeEnabel)
    self._viewNode.btnTake:setVisible(isTakeEnabel)
    self._viewNode.btnRewarded:setVisible(not isTakeEnabel)
end

--隐藏动画节点
function NewPlayerGiftCtrl:hideGiftPop()
    self._viewNode.nodeGiftPop:setVisible(false)
end

--弹出领取动画
function NewPlayerGiftCtrl:showGiftPop(data)
    if not self._viewNode.nodeGiftPop then return end
    if not self._giftConfig then return end
    self._viewNode.nodeGiftPop:setVisible(true)
    local nGiftIndex = data.value
    local ItemInfo = self._giftConfig[nGiftIndex]

    --播放领取动画
    if not tolua.isnull(self._aniPop) then
        self._viewNode.nodeGiftPop:stopAction(self._aniPop)
    end
    local path = "res/hallcocosstudio/newplayergift/node_giftpop.csb"
    self._aniPop = cc.CSLoader:createTimeline(path)
    self._viewNode.nodeGiftPop:runAction(self._aniPop)
    self._aniPop:play("animation0", false)

    --设置弹出动画视图
    if ItemInfo.type == NewPlayerGiftModel.TYPE_SILVER then
        self._viewNode.imgSilverPop:setVisible(true)
        self._viewNode.imgTicketPop:setVisible(false)
        self._viewNode.textRewardPop:setString(string.format(StringConfig["GIFT_SILVER_COUNT"],ItemInfo.count))
    elseif ItemInfo.type == NewPlayerGiftModel.TYPE_TICKET then
        self._viewNode.imgSilverPop:setVisible(false)
        self._viewNode.imgTicketPop:setVisible(true)
        self._viewNode.textRewardPop:setString(string.format(StringConfig["GIFT_TICKET_COUNT"],ItemInfo.count))
    end

end

function NewPlayerGiftCtrl:onExit()
    PluginProcessModel:PopNextPlugin()
end

function NewPlayerGiftCtrl:onNotifyClose()
    self:removeSelfInstance()
end

function NewPlayerGiftCtrl:onKeyBack()
    PluginProcessModel:stopPluginProcess()
    NewPlayerGiftCtrl.super.onKeyBack(self)
end

return NewPlayerGiftCtrl