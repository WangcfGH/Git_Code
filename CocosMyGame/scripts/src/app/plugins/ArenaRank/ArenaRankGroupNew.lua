local PropertyBinder = cc.load('coms').PropertyBinder
local ArenaRankGroup = require("src.app.plugins.ArenaRank.ArenaRankGroup")
local ArenaRankGroupNew = class("ArenaRankGroupNew", ArenaRankGroup)
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))
local ArenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()

my.setmethods(ArenaRankGroup, PropertyBinder)

ArenaRankGroup.AREA_INFO = "AREA_INFO"
ArenaRankGroup.AREA_RANK = "AREA_RANK"

local MainTabEventMap = {
        NeedHideNode                   = {    --tab切换时需要隐藏的控件 于TabButtons.showNode配合
            ["panelPropContent"]           = {},
            ["panelRankContent"]           = {},
        },
        TabButtons                                 = {
            [1]      = {defaultShow = true, checkBtn = "rankCheck", showNode = {["panelRankContent"]={}} },
            [2]      = {checkBtn = "propCheck", showNode = {["panelPropContent"]={}} },
        }
    }
local RankTabEventMap = {
        NeedHideNode                   = {    --tab切换时需要隐藏的控件 于TabButtons.showNode配合
            ["panelInfo"]           = {},
            ["panelRank"]           = {},
        },
        TabButtons                                 = {
            [1]      = {defaultShow = true, checkBtn = "rankGroupCheck", showNode = {["panelRank"]={}} },
            [2]      = {checkBtn = "infoCheck", showNode = {["panelInfo"]={}} },
        }
    }

function ArenaRankGroupNew:generate()  
    local node = cc.CSLoader:createNode("res/hallcocosstudio/ArenaRank/ArenaRankGroup_New.csb")
    self._rankPanel = node:getChildByName("Panel_ArenaRank")
    node:removeChild(self._rankPanel, true)

    self._isSignUpReqBack = true
    self._isTakeRewardReqBack = true

    self:setViewIndexer()
    self:createControls()

    self:createRankList()
    self:createPropList()

    self:createDeadline()

    self:hideBottomArea()

    self:update()
    
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_RANK_INFO_UPDATED, handler(self, self.updateWithoutReward))
    -- 掼蛋十三期需求：去掉了报名、领奖操作
    --self:listenTo(ArenaRankData, ArenaRankData.ARENA_RANK_SIGN_UP_OK, handler(self, self.signUpOK))
    --self:listenTo(ArenaRankTakeRewardModel, ArenaRankTakeRewardModel.TAKE_REWARD_OK, handler(self, self.takeRewardOK))
    
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_PROP_GET_LIST_OK, handler(self, self.updatePropList))
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_PROP_BUY_OK, handler(self, self.buyPropOk))
      
    return self._rankPanel
end

function ArenaRankGroup:hideBottomArea()
    local viewNode = self._viewNode

    viewNode.panelError:setVisible(false)
end
function ArenaRankGroupNew:createDeadline()
    -- 掼蛋十三期需求：去掉了时钟倒计时
end

function ArenaRankGroupNew:updateDeadline()
    -- 掼蛋十三期需求：去掉了时钟倒计时
end

function ArenaRankGroupNew:createControls()
    local viewNode = self._viewNode

    local function onTabEvent(widget)
        my.playClickBtnSound()
		self:onTabEvent(widget, MainTabEventMap)
	end
    for index, table in pairs(MainTabEventMap.TabButtons) do
        if viewNode[table.checkBtn] then
            viewNode[table.checkBtn]:addClickEventListener(onTabEvent)
            if table.defaultShow then
                self:onTabEvent(viewNode[table.checkBtn]._realnode[1], MainTabEventMap)
                viewNode[table.checkBtn]:setSelected(true)
            end
        end
    end

    local function onRankTabEvent(widget)
        my.playClickBtnSound()
		self:onTabEvent(widget, RankTabEventMap)
	end

    for index, table in pairs(RankTabEventMap.TabButtons) do
        if viewNode[table.checkBtn] then
            viewNode[table.checkBtn]:addClickEventListener(onRankTabEvent)
            if table.defaultShow then
                self:onTabEvent(viewNode[table.checkBtn]._realnode[1], RankTabEventMap)
                viewNode[table.checkBtn]:setSelected(true)
            end
        end
    end

    viewNode.rankList:addEventListener(handler(self, self.onRankListScrolled))

end

function ArenaRankGroupNew:startAranaRankFrushTimer()
    local function onTimeInterval()
        ArenaRankData:request()
        self:update()
    end
    local interval = 300 -- 300s 刷新一次
    self._ArenaRankTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimeInterval, interval, false)
end

function ArenaRankGroupNew:stopAranaRankFrushTimer()
    if self._ArenaRankTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ArenaRankTimer)
        self._ArenaRankTimer = nil
    end
end


return ArenaRankGroupNew