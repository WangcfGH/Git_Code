local SecondLayerTeam2V2RuleCtrl  = class('SecondLayerTeam2V2RuleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.mainpanel/room/SecondLayerTeam2V2Rule.SecondLayerTeam2V2RuleView")
local Team2V2Model      = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()

my.addInstance(SecondLayerTeam2V2RuleCtrl)

function SecondLayerTeam2V2RuleCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}

	self:bindUserEventHandler(viewNode,bindList)

    self._listConfig = {
        ["itemWidth"]   = 600,  --itemWidth
        ["fontSize"]    = 26,   --itemHeight
    }

    self._viewNode = viewNode

    self:initUI()
end

function SecondLayerTeam2V2RuleCtrl:onEnter( ... )

end

function SecondLayerTeam2V2RuleCtrl:initUI()
    if not self._viewNode then return end

    local team2V2Config = Team2V2Model:getConfig()
    if not team2V2Config then return end

    self:initRuleListView(team2V2Config)  
end

function SecondLayerTeam2V2RuleCtrl:initRuleListView(config)
    local viewNode = self._viewNode
    local initCount = #config.RuleDescription
    for i = 1, initCount do
        local item = self:createRuleItem(config.RuleDescription[i]["Rule" .. i])
        viewNode.listview:pushBackCustomItem(item)
    end
end

function SecondLayerTeam2V2RuleCtrl:createRuleItem(strRule)

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

function SecondLayerTeam2V2RuleCtrl:onExit()

end


return SecondLayerTeam2V2RuleCtrl