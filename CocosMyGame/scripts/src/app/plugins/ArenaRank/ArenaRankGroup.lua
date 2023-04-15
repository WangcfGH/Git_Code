local PropertyBinder = cc.load('coms').PropertyBinder
local ArenaRankGroup = class("ArenaRankGroup")
local ArenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local User = mymodel('UserModel'):getInstance()
local TimeCalculator = require("src.app.Game.mCommon.TimeCalculator")
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))

local ArenaRankTakeRewardModel = require("src.app.plugins.ArenaRankTakeReward.ArenaRankTakeRewardModel"):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

my.setmethods(ArenaRankGroup, PropertyBinder)

ArenaRankGroup.AREA_INFO = "AREA_INFO"
ArenaRankGroup.AREA_RANK = "AREA_RANK"

function ArenaRankGroup:ctor()
    self._isDestroyed = false
    self._buyPropBtnTime = nil

    if self._itemProp == nil then
        local itemPropNode = cc.CSLoader:createNode("res/hallcocosstudio/ArenaRank/Node_Prop.csb")
        local itemProp = itemPropNode:getChildByName("Img_Prop")
        itemPropNode:removeChild(itemProp, true)
        self._itemProp = itemProp
        self._itemProp:retain()
        local numTxt = self._itemProp:getChildByName("Text_Num")
        self._NumTxtColor = numTxt:getTextColor()
        local describeTxt = self._itemProp:getChildByName("Text_PropDescribe")
        self._DescribeTxtColor = describeTxt:getTextColor()
    end
end

function ArenaRankGroup:destroy()
    self:removeEventHosts()
    self._isDestroyed = true

    self:stopDeadlineTimer()

    if self._itemProp then
        self._itemProp:release()
        self._itemProp = nil
    end
end

function ArenaRankGroup:isDestroyed()
    return self._isDestroyed
end

function ArenaRankGroup:generate()  
    local node = cc.CSLoader:createNode("res/hallcocosstudio/ArenaRank/ArenaRankGroup.csb")
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
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_RANK_SIGN_UP_OK, handler(self, self.signUpOK))
    self:listenTo(ArenaRankTakeRewardModel, ArenaRankTakeRewardModel.TAKE_REWARD_OK, handler(self, self.takeRewardOK))
    
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_PROP_GET_LIST_OK, handler(self, self.updatePropList))
    self:listenTo(ArenaRankData, ArenaRankData.ARENA_PROP_BUY_OK, handler(self, self.buyPropOk))
      
    return self._rankPanel
end

function ArenaRankGroup:setViewIndexer()
    local map = {
        panelRankContent="Panel_Content_Bk",
        panelPropContent="Panel_Prop",
        {
            propCheck = "CheckBox_Prop",
            rankCheck = "CheckBox_Rank", 
        },
        {
            _option = {prefix = 'Panel_Prop.'}, 
            propList = "ScrollView_Prop",
        },
        {
            _option = {prefix = 'Panel_Content_Bk.'}, 
            panelBottom = "Panel_Bottom",
            panelInfo = "Panel_Info",
            panelRank = "Panel_Rank",
            rankGroupCheck = "CheckBox_Group",
            infoCheck = "CheckBox_Friends",
            {
                {
                    _option = {prefix = 'Panel_Rank.'}, 
                    panelNeedSignUp = "Panel_NeedSignUp",
                    panelConnectError = "Panel_Connect_Error",
                    panelDetail = "Panel_Detail",
                    panelNotOpen = "Panel_Not_Open",
                    {
                        _option = {prefix = 'Panel_Detail.'},
                        rankList = "ScrollView_Rank"
                    },
                },
            },
            {
                _option = {prefix = 'Panel_Bottom.'},
                panelButton = "Panel_Button",    
                {
                    _option = {prefix = 'Panel_Button.'}, 
                    signUpBtn = "Button_SignUp",
                    takeRewardBtn = "Button_TakeReward"
                },
                panelDeadline = "Panel_Deadline",
                {
                    _option = {prefix = 'Panel_Deadline.'}, 
                    {
                        deadline = "Text_Deadline"
                    },
                },
                panelError = "Panel_Error",
            }, 
        },   
    }

    self._viewNode = my.NodeIndexer(self._rankPanel, map)
end

function ArenaRankGroup:hideAllArea()
    local viewNode = self._viewNode 

    viewNode.panelInfo:setVisible(false)
    viewNode.panelRank:setVisible(false)
end

function ArenaRankGroup:showAreaByName(name)
    local viewNode = self._viewNode 

    self:hideAllArea()
    viewNode.panelBottom:setVisible(true)

    if name == ArenaRankGroup.AREA_INFO then
        viewNode.panelInfo:setVisible(true)        
        self:setAreaButtonFocus(viewNode.infoCheck)
    elseif name == ArenaRankGroup.AREA_RANK then
        viewNode.panelRank:setVisible(true)        
        self:setAreaButtonFocus(viewNode.rankGroupCheck)
    end       
end

function ArenaRankGroup:setAreaButtonFocus(checkBtn) 
    local viewNode = self._viewNode 

    viewNode.rankGroupCheck:setSelected(false)
    viewNode.infoCheck:setSelected(false)

    checkBtn:setSelected(true)
end

function ArenaRankGroup:isNeedShowRank()
    local status = ArenaRankData:getStatus()
    if status == ArenaRankData.STATUS_SIGN_UP or status == ArenaRankData.STATUS_NOT_REWARD then
        return true
    else
        return false
    end
end

function ArenaRankGroup:hideBottomArea()
    local viewNode = self._viewNode

    viewNode.panelButton:setVisible(false)
    viewNode.panelDeadline:setVisible(false)
    viewNode.panelError:setVisible(false)
end

function ArenaRankGroup:hideBottomButton()
    local viewNode = self._viewNode

    viewNode.signUpBtn:setVisible(false)
    viewNode.takeRewardBtn:setVisible(false)
end

function ArenaRankGroup:showBottomAreaByStatus(status)
    local viewNode = self._viewNode

    self:hideBottomArea()

    if status == ArenaRankData.STATUS_NOT_SIGN_UP then
        viewNode.panelButton:setVisible(true)
        self:hideBottomButton()
        viewNode.signUpBtn:setVisible(true)
    elseif status == ArenaRankData.STATUS_SIGN_UP then
        viewNode.panelDeadline:setVisible(true)
    elseif status == ArenaRankData.STATUS_NOT_REWARD then        
        viewNode.panelButton:setVisible(true)
        self:hideBottomButton()
        viewNode.takeRewardBtn:setVisible(true)
    elseif status == ArenaRankData.STATUS_REWARD then
        viewNode.panelButton:setVisible(true)
        self:hideBottomButton()
        viewNode.signUpBtn:setVisible(true)
    elseif status == ArenaRankData.STATUS_ERROR then --错误信息
        viewNode.panelError:setVisible(true)
    end    
end

function ArenaRankGroup:createRankList()
    self._rankListConfig = {
        ["startPosOffset"] = {x = 0, y = 0}, --左上角开始位置
        ["itemWidth"] = 439,
        ["itemHeight"] = 70,
        ["viewOffset"] = 70,
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20 --每次增加数量
    }
end

function ArenaRankGroup:createSelfRankItem(rank, score)
    local item = cc.Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/Arena/Arena_rank_selfbg.png")
    item:setAnchorPoint(cc.p(0.5, 1))

    local width = item:getContentSize().width
    local height = item:getContentSize().height

    local rankLabel = cc.Label:createWithBMFont("hallcocosstudio/images/font/Arena/Arena_rank_ming.fnt", "")  
    rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
    rankLabel:setString(rank)
    rankLabel:setPosition(cc.p(width / 8, height / 2))
    item:addChild(rankLabel)

    local girlPic = "res/hall/hallpic/Game/GamePic/PlayerRole/ArenaRankHeadGirl.png"
    local boyPic = "res/hall/hallpic/Game/GamePic/PlayerRole/ArenaRankHeadBoy.png"
    local girl = 1  -- 0:boy, 1:girl, -1:unknown
    local sexPic = boyPic
    if plugin.AgentManager:getInstance():getUserPlugin():getUserSex() == girl then
        sexPic = girlPic
    end    
    --local headPic = cc.Sprite:createWithSpriteFrameName(sexPic)
    local headPic = cc.Sprite:create(sexPic)
    headPic:setPosition(cc.p(width * 0.45, height * 0.62))
    headPic:setScale(0.8)
    item:addChild(headPic)

    local nameLabel = cc.Label:createWithSystemFont("", "黑体", 20, cc.size(0,0))    
    nameLabel:setTextColor(cc.c3b(157, 97, 37))
    nameLabel:setPosition(cc.p(width * 0.45, height * 0.23))  
    local userName = User.szUsername
    userName = MCCharset:getInstance():gb2Utf8String(userName, string.len(userName)) 
    nameLabel:setString(userName) 
    item:addChild(nameLabel)

    local scoreLabel = cc.Label:createWithBMFont("hallcocosstudio/images/font/Arena/Arena_rank_score.fnt", "")  
    scoreLabel:setString(score)
    scoreLabel:setPosition(cc.p(width * 0.8, height / 2))
    item:addChild(scoreLabel)

    return item
end

function ArenaRankGroup:createRankItem(rank, score, name)
    local item = cc.Sprite:create()
    item:setAnchorPoint(cc.p(0.5, 1))

    local width = self._rankListConfig["itemWidth"]
    local height = self._rankListConfig["itemHeight"]
    item:setContentSize(cc.size(width, height))
        
    local rankFirst = 1
    local rankSecond = 2
    local rankThird = 3
    local scoreLabel
    local rankLabel
    if rank >= rankFirst and rank <= rankThird then
        local rankPic = string.format("hallcocosstudio/images/plist/Arena/Arena_ranking_M%d.png", rank)
        rankLabel = cc.Sprite:createWithSpriteFrameName(rankPic)
        rankLabel:setPosition(cc.p(0, height / 2))
        scoreLabel = cc.Label:createWithBMFont("hallcocosstudio/images/font/Arena/Arena_rank_score.fnt", "")          
    else
        rankLabel = cc.Label:createWithBMFont("hallcocosstudio/images/font/Arena/Arena_rank_ming.fnt", "")        
        rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
        rankLabel:setString(rank)
        rankLabel:setPosition(cc.p(width * 0.07, height / 2))        
        scoreLabel = cc.Label:createWithBMFont("hallcocosstudio/images/font/Arena/Arena_rank_score.fnt", "")
    end
        
    item:addChild(rankLabel)

    local nameLabel = cc.Label:createWithSystemFont("", "黑体", 20, cc.size(0,0))
    nameLabel:setTextColor(cc.c3b(157, 97, 37))
    nameLabel:setPosition(cc.p(width * 0.45, height / 2))
    nameLabel:setString(name)
    item:addChild(nameLabel)

    scoreLabel:setString(score)
    scoreLabel:setAnchorPoint(cc.p(0.5, 0.5))
    scoreLabel:setPosition(cc.p(width * 0.84, height / 2))
    item:addChild(scoreLabel) 
    
    return item
end

function ArenaRankGroup:addItemToRankListView(item)
    local viewNode = self._viewNode

    local width = viewNode.rankList:getInnerContainerSize().width
    local height = viewNode.rankList:getInnerContainerSize().height 
    local lineOffset = 0
    if self._nextRankItemPosY == self._rankListConfig["startPosOffset"].y then
        lineOffset = 3
    else
        local line = cc.Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/Arena/Arena_img_line.png")
        line:setPosition(cc.p(width / 2, height - self._nextRankItemPosY))
        viewNode.rankList:addChild(line)
    end
    item:setAnchorPoint(cc.p(0.5, 1))
    item:setPosition(cc.p(width / 2, height - self._nextRankItemPosY))

    viewNode.rankList:addChild(item)

    self._visibleRankItemCount = self._visibleRankItemCount + 1
    self._nextRankItemPosY = self._nextRankItemPosY + item:getContentSize().height + lineOffset
end

function ArenaRankGroup:onRankListScrolled(sender, state)
    if not (self._nextRankItemPosY and self._visibleRankItemCount) then
        return 
    end    
    
    local viewNode = self._viewNode
        
    local posY = viewNode.rankList:getInnerContainer():getPositionY() * -1
    local innerHeight = viewNode.rankList:getInnerContainerSize().height
    local visibleHeight = viewNode.rankList:getContentSize().height 
    local invisibleHeight = innerHeight - visibleHeight
    local moveLength =  invisibleHeight - posY --滚动距离

    local selfItemCount = 1
    if self._nextRankItemPosY - moveLength <= visibleHeight then 
        local list = ArenaRankData:getGroupRankList() or {}
        local visibleItemCount = self._visibleRankItemCount
        local addCount = 0
        for i, itemData in ipairs(list) do
            if i > visibleItemCount - selfItemCount and addCount <= self._rankListConfig["addItemCount"] then
                local item = self:createRankItem(itemData.rank, itemData.score, itemData.userName)
                self:addItemToRankListView(item)   
                addCount = addCount + 1        
            end
        end         
    end
end

function ArenaRankGroup:update()
    if self._viewNode == nil or tolua.isnull(self._viewNode:getRealNode()) then
        print("ArenaRankGroup:update, but viewNode is invalid!!!")
        return
    end

    self:updateWithoutReward()
    self:updatePropList()
end

function ArenaRankGroup:updateWithoutReward()
    self:updateRankArea()
    self:updateRankList()
    self:updateBottomArea()
    self:updateDeadline()
end

function ArenaRankGroup:hideRankArea()
    local viewNode = self._viewNode

    viewNode.panelDetail:setVisible(false)
    viewNode.panelNeedSignUp:setVisible(false)
    viewNode.panelConnectError:setVisible(false)
    viewNode.panelNotOpen:setVisible(false) 
end

function ArenaRankGroup:updateRankArea()
    if self:isDestroyed() then
        return 
    end

    local viewNode = self._viewNode

    self:hideRankArea()

    if not ArenaRankData:isOpen() then
        viewNode.panelNotOpen:setVisible(true)        
    else
        local isShowRank = self:isNeedShowRank()
        if isShowRank then
            viewNode.panelDetail:setVisible(true)
        else
            viewNode.panelNeedSignUp:setVisible(true)
        end
    end
end

function ArenaRankGroup:updateRankList()
    if not ArenaRankData:isDataAvailable() or self:isDestroyed() then
        return 
    end

    if not ArenaRankData:isOpen() then
        return 
    end

    local viewNode = self._viewNode

    --重置 
    viewNode.rankList:removeAllChildren()

    --滚动区域
    local list = ArenaRankData:getGroupRankList() or {}
    local selfItemCount = 1
    local totalItemCount = #list + selfItemCount
    local listWidth = viewNode.rankList:getContentSize().width
    local listHeight = viewNode.rankList:getContentSize().height
    local itemHeight = self._rankListConfig["itemHeight"]
    local selfItemHeight = itemHeight * 2
    local offset = self._rankListConfig["viewOffset"]
    listHeight = math.max(listHeight, (totalItemCount - selfItemCount) * itemHeight + selfItemHeight + offset)
    viewNode.rankList:setInnerContainerSize(cc.size(listWidth, listHeight))
    self._nextRankItemPosY = self._rankListConfig["startPosOffset"].y
    self._visibleRankItemCount = 0

    --添加自己的排行
    local selfRank = ArenaRankData:getSelfRank()
    local selfScore = ArenaRankData:getSelfScore()    
    local selfItem = self:createSelfRankItem(selfRank, selfScore)  
    self:addItemToRankListView(selfItem)

    --selfItem以外的初始可见条目
    local initVisibleItemCount = math.min(#list + selfItemCount, self._rankListConfig["visibleItemCount"])
    for i, itemData in ipairs(list) do
        if i > initVisibleItemCount - selfItemCount then
            break
        end        
        local item = self:createRankItem(itemData.rank, itemData.score, itemData.userName)
        self:addItemToRankListView(item)
    end    
end

function ArenaRankGroup:updateBottomArea()
    if not ArenaRankData:isDataAvailable() or self:isDestroyed() then
        return 
    end

    if not ArenaRankData:isOpen() then
        self:hideBottomArea()
    else
        self:showBottomAreaByStatus(ArenaRankData:getStatus())
    end   
end

function ArenaRankGroup:createDeadline()
    local viewNode = self._viewNode
    viewNode.deadline:setString(string.format(ArenaRankConfig["DeadlineWithHours"], 0, 0))

    self:updateDeadline()
    --[[ 
    --要是倒计时为分或者秒的时候，可以用下面的代码。小时的倒计时没必要这么做
    local function onTimeInterval()
        self:updateDeadline()
    end
    local interval = 30 --[0, 60]均匀分布,期望30
    self._dealineTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimeInterval, interval, false)
    ]]
end

function ArenaRankGroup:stopDeadlineTimer()
    --[[
    if self._dealineTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dealineTimer)
        self._dealineTimer = nil
    end
    ]]
end

function ArenaRankGroup:updateDeadline()
    if not ArenaRankData:isDataAvailable() or self:isDestroyed() then
        return 
    end

    if not ArenaRankData:isOpen() then
        return 
    end

    local viewNode = self._viewNode

    local days = 0
    local hours = 0

    local endDate = ArenaRankData:getEndDate()
    local leftTimeInHours = 0
    if type(endDate) == "table" then
        leftTimeInHours = self:calculateDeadlineInHours(endDate)
    end

    local dayInHours = 24
    if leftTimeInHours >= 0 then
        hours = leftTimeInHours % dayInHours
        local leftTimeInDays = math.floor(leftTimeInHours / dayInHours)
        days = leftTimeInDays
    end

    viewNode.deadline:setString(string.format(ArenaRankConfig["DeadlineWithHours"], days, hours))
end

function ArenaRankGroup:calculateDeadlineInHours(endDate)
    local curDate = os.date("*t", os.time())
    local hours
    if endDate.year and endDate.month and endDate.day and endDate.hour then
        hours = TimeCalculator:getHoursBetweenTwoDate(curDate, endDate)
    end   

    if hours == nil or hours < 0 then
        hours = 0
    end

    return hours
end

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

function ArenaRankGroup:createControls()
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

    viewNode.signUpBtn:addTouchEventListener(handler(self, self.onSignUpButtonClicked))
    viewNode.takeRewardBtn:addTouchEventListener(handler(self, self.onTakeRewardButtonClicked))
end

function ArenaRankGroup:onTabEvent(widgt, TabEventMap, callfunc)
    local viewNode = self._viewNode
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

function ArenaRankGroup:onSignUpButtonClicked(sender, state)
    if state == 0 then  --began
        my.playClickBtnSound()
        sender:setScale(cc.exports.GetButtonScale(sender))
    elseif state == 1 then --moved        
    elseif state == 2 then --ended
        sender:setScale(1.0)
        self:signUpArenaRank()        
    else    --cancelled    
        sender:setScale(1.0)  
    end 
end

function ArenaRankGroup:signUpArenaRank()    
    if not self._isSignUpReqBack then --等消息回来,防止重复点击
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = ArenaRankConfig["SignUpProcessing"], removeTime = 1}})
        return 
    end

    self._isSignUpReqBack = false

    local ArenaModel = require('src.app.plugins.arena.ArenaModel'):getInstance()
    ArenaModel:sendSignUpArenaRank()    
end

function ArenaRankGroup:signUpOK()
    if not ArenaRankData:isDataAvailable() or self:isDestroyed() then 
        return 
    end

    if not ArenaRankData:isOpen() then
        return 
    end

    local status = ArenaRankData:getStatus()
    if status == ArenaRankData.STATUS_SIGN_UP then --成功        
        self:updateWithoutReward()         
        self:showAreaByName(ArenaRankGroup.AREA_RANK)
        my.scheduleOnce(function()
            my.informPluginByName({pluginName = "ArenaRankSignUpOK"})
        end)
        ArenaRankData:addSignUpCount(1)
        ArenaRankData:save()
    else --未知情况
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = ArenaRankConfig["SignUpFailed"], removeTime = 3}})
    end   

    self._isSignUpReqBack = true
end

function ArenaRankGroup:onTakeRewardButtonClicked(sender, state)
    if state == 0 then  --began
        my.playClickBtnSound()
        sender:setScale(cc.exports.GetButtonScale(sender))
    elseif state == 1 then --moved        
    elseif state == 2 then --ended
        sender:setScale(1.0)
        self:takeRewardArenaRank()      
    else    --cancelled    
        sender:setScale(1.0)  
    end     
end

function ArenaRankGroup:takeRewardArenaRank()    
    if not self._isTakeRewardReqBack then --等消息回来,防止重复点击
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = ArenaRankConfig["TakeRewardProcessing"], removeTime = 1}})
        return 
    end

    self._isTakeRewardReqBack = false

    local ArenaModel = require('src.app.plugins.arena.ArenaModel'):getInstance()
    ArenaModel:sendTakeArenaRankReward()    
end

function ArenaRankGroup:takeRewardOK()
    if not ArenaRankTakeRewardModel:isDataAvailable() or self:isDestroyed() then 
        return 
    end

    local status = ArenaRankTakeRewardModel:getStatus()
    if status == ArenaRankTakeRewardModel.STATUS_SUCCESSED then --成功 
        my.scheduleOnce(function()
            my.informPluginByName({pluginName = "ArenaRankTakeReward"})
        end)
    else --未知情况
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = ArenaRankConfig["TakeRewardError"], removeTime = 3}})
    end   

    ArenaRankData:setStatus(ArenaRankData.STATUS_NOT_SIGN_UP)
    self:showAreaByName(ArenaRankGroup.AREA_INFO)
    self:updateWithoutReward()

    self._isTakeRewardReqBack = true
end

--道具
function ArenaRankGroup:createPropList()
    self._propListConfig = {
        ["startPosOffset"] = {x = 0, y = 0}, --左上角开始位置
        ["itemWidth"] = 534,
        ["itemHeight"] = 113,
        ["itemOffset"] = 5,
        ["viewOffset"] = 0,
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20 --每次增加数量
    }
end

function ArenaRankGroup:updatePropList()
    if not ArenaRankData:isPropDataAvailable() or self:isDestroyed() then
        return 
    end

    local viewNode = self._viewNode

    --重置 
    viewNode.propList:removeAllChildren()

    --滚动区域
    local list = ArenaRankData._propList or {}
    local totalItemCount = #list
    local listWidth = viewNode.propList:getContentSize().width
    local listHeight = viewNode.propList:getContentSize().height
    local itemHeight = self._propListConfig["itemHeight"]
    local itemOffset = self._propListConfig["itemOffset"]
    local viewOffset = self._propListConfig["viewOffset"]    
    listHeight = math.max(listHeight, totalItemCount * (itemHeight + itemOffset) + viewOffset)
    viewNode.propList:setInnerContainerSize(cc.size(listWidth, listHeight))
    self._nextPropItemPosY = self._propListConfig["startPosOffset"].y
    self._visiblePropItemCount = 0
    self._nextPropInList = 1

    --初始可见条目
    local initVisibleItemCount = math.min(totalItemCount, self._propListConfig["visibleItemCount"])
    local validItemCount = 0
    local nextInList = 1
    for i, itemData in ipairs(list) do
        if validItemCount >= initVisibleItemCount then
            break
        end 
        local item = self:createPropItem(itemData)
        if item then
            self:addItemToPropListView(item)
            validItemCount = validItemCount + 1
        end
        nextInList = nextInList + 1
    end
    self._nextPropInList = nextInList
end

function ArenaRankGroup:addItemToPropListView(item)
    local viewNode = self._viewNode

    local width = viewNode.propList:getInnerContainerSize().width
    local height = viewNode.propList:getInnerContainerSize().height 
    local itemHeight = self._propListConfig["itemHeight"]
    local itemOffset = self._propListConfig["itemOffset"]

    item:setPosition(cc.p(width / 2, height - self._nextPropItemPosY))

    item:setAnchorPoint(cc.p(0.5, 1))
    viewNode.propList:addChild(item)

    self._visiblePropItemCount = self._visiblePropItemCount + 1
    self._nextPropItemPosY = self._nextPropItemPosY + itemHeight + itemOffset
end

function ArenaRankGroup:createPropItem(itemData)
    local width = self._propListConfig["itemWidth"]
    local height = self._propListConfig["itemHeight"]
  
    local item = self._itemProp:clone()
    
    local numTxt = self._itemProp:getChildByName("Text_Num")

    local itemChildren = item:getChildren()
    for i = 1, item:getChildrenCount() do
        local child = itemChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    local iconTitle = item:getChildByName("Img_PropIcon"..itemData.nType)
    if iconTitle then
        iconTitle:setVisible(true)
    end

    local numTxt = item:getChildByName("Text_Num")
    numTxt:setVisible(true)
    numTxt:setString("X"..(itemData.num or "0"))
    numTxt:setTextColor(self._NumTxtColor)

    local descTxt = item:getChildByName("Text_PropDescribe")
    descTxt:setVisible(true)
    descTxt:setString(itemData.desc)
    descTxt:setTextColor(self._DescribeTxtColor)
    
    local buyBtn = item:getChildByName("Btn_Buy")
    buyBtn:setVisible(true)

    local function buyItem()
        my.playClickBtnSound()
        if itemData.nType == 4 then --记牌器
            if cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
                local config = cc.exports.GetShopTipsConfig()
				my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_HAVE_RMB"],removeTime=2}})
            else
                local user=mymodel('UserModel'):getInstance()
                if user.nDeposit < itemData.price then
                    local config = cc.exports.GetShopTipsConfig()
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=config["EXPRESSION_CLICK_TIPS"],removeTime=2}})
                    
                    return
                end
                if self._buyPropBtnTime ~= nil and ( os.time() - self._buyPropBtnTime) <= 3 then return else self._buyPropBtnTime = os.time() end
	            ArenaRankData:requestBuyPropItem(itemData.nType)
            end
        else
            local user=mymodel('UserModel'):getInstance()
            
            if cc.exports.isSafeBoxSupported() then
                local boxSilver = user:getSafeboxDeposit() or 0
                if boxSilver < itemData.price then
                    local config = cc.exports.GetShopTipsConfig()
                    if cc.exports.isSafeBoxSupported() then
                        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["BUY_PROP_FAIL_ANDROID"],removeTime=2}})
                    elseif cc.exports.isBackBoxSupported() then
                        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["BUY_PROP_FAIL_IOS"],removeTime=2}})
                    end
                    return
                end
            else
                if user.nDeposit < itemData.price then
                    my.informPluginByName({pluginName = "TipPlugin", params = {tipString = "您的银两不足~", removeTime = 2}})
                end
            end
            if self._buyPropBtnTime ~= nil and ( os.time() - self._buyPropBtnTime) <= 3 then return else self._buyPropBtnTime = os.time() end
	        ArenaRankData:requestBuyPropItem(itemData.nType)
        end
    end
    buyBtn:addClickEventListener(buyItem)

    if itemData.disable then
        buyBtn:setBright(false)
        buyBtn:setTouchEnabled(false)
    end

    local priceTxt = buyBtn:getChildByName("Text_SilverValue")
    priceTxt:setString(itemData.price)
    
    return item
end

function ArenaRankGroup:buyPropOk()
    self._buyPropBtnTime = nil
end

return ArenaRankGroup