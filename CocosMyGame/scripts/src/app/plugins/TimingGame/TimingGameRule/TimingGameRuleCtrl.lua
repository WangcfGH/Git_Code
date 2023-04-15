local TimingGameRuleCtrl = class('TimingGameRuleCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameRule.TimingGameRuleView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

function TimingGameRuleCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:bindSomeDestroyButtons(viewNode,{
		'btnConfirm',
    })

    self._listConfig = {
        ["itemWidth"] = 580, --itemWidth
        ["fontSize"] = 26, --itemHeight
    }

    self:initListener()
    self:updateUI()
end

function TimingGameRuleCtrl:initListener()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getConfigFromSvr"], handler(self, self.updateUI))
end

function TimingGameRuleCtrl:updateUI()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then 
        self:goBack()
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    self:initRankListView(config, infoData)
end

function TimingGameRuleCtrl:initRankListView(config, infoData)
    local viewNode = self._viewNode
    local initCount = #config.RuleDescription
    for i = 1, initCount do
        local strIndex = string.format("%d、", i) 
        local item = self:createRankItem(strIndex .. config.RuleDescription[i]["Rule" .. i])
        viewNode.listview:pushBackCustomItem(item)
    end
end

function TimingGameRuleCtrl:createRankItem(strRule)

    local width = self._listConfig.itemWidth
    local fontSize = self._listConfig.fontSize

    local fontPath = "res/common/font/mainfont.TTF"
    local color = cc.c3b(161,74,22)
    local label = ccui.Text:create(strRule, fontPath, fontSize)
    label:setTextColor(color)
    label:ignoreContentAdaptWithSize(false)

    local size = label:getContentSize()
    if size.width > width then
        local lineNum = math.floor(size.width / width) + 1
        label:setContentSize(cc.size(width, lineNum * fontSize))
        label:setText(strRule)
    end
    
    return label
end

return TimingGameRuleCtrl