local RollNumberView = import('src.app.plugins.invitegift.oldusergift.RollNumberView')
local RichColorLabel = import("src.app.plugins.broadcast.RichColorLabel")

local RollNumberCtrl = class("RollNumberCtrl", myctrl('BaseShareCtrl'))
local scheduler = cc.Director:getInstance():getScheduler()

RollNumberCtrl.RUN_ENTERACTION = true

-- 此方法中速度方向规定为向下为负，向上为正
local rollMaxVelocity = -1300       -- 最大转速 像素/s
local stopTurns = 1                 -- 停下来的时候至少转的圈数（决定减速度a）
local totalRollNumber = 6           -- 滚轮总数

-- 定时器管理
local scheduleList = {}

local function removeScheByID(id)
    scheduler:unscheduleScriptEntry(id)
    table.removebyvalue(scheduleList, id)
end

local function removeAllSche()
    for _, v in pairs(scheduleList) do
        scheduler:unscheduleScriptEntry(v)
    end

    scheduleList = {}
end

local function scheduleOnce(f, t)
    local id = my.scheduleOnce(function ()
        f()
    end, t)

    table.insert(scheduleList, id)
end

local function schedule(f, t)
    local id = scheduler:scheduleScriptFunc(function (dt)
        f(dt)
    end, t, false)
    table.insert(scheduleList, id)
end

function RollNumberCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(RollNumberView:createViewIndexer())

    if params.callback then
        self._callback = params.callback
    end

    self._info = params.info

    self:initPanels()
    self:initHintText(params.info)
    self:initSound()
end

function RollNumberCtrl:onEnter()
    RollNumberCtrl.super.onEnter(self)

    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/Rolling.mp3'), false)

    my.dataLink(cc.exports.DataLinkCodeDef.ROLL_NUMBER)

    self:initFuzzy()

    self:rollAll()
    scheduleOnce(function ()
        self:stopAll(self._info.targetNums)
        scheduleOnce(function ()
            self:onKeyBack()
        end, 8)
    end, 1)
end

function RollNumberCtrl:runEnterAction()
    self._viewNode:runTimelineAction("animation_appear", false)
end

-- 初始化音效
function RollNumberCtrl:initSound()
    audio.preloadSound('res/sound/hall/RollStop.mp3')
end

-- 初始化提示文字
function RollNumberCtrl:initHintText(info)
    for i = 1, 3 do
        local text = self._viewNode.nodeAniTextShow:getChildByName("Panel_" .. i):getChildByName("Text_Number"):setString(info['hint' .. i].number)
    end
end

-- 初始化模糊效果
function RollNumberCtrl:initFuzzy()
    local viewNode = self._viewNode
    self._fuzzyNodeList = {}

    for i = 1, totalRollNumber do
        local aniInfo = {
            aniName = 'animation_loop',
            resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_fuzzy.csb',
            isLoop = true
        }

        local pos = cc.p((i - 1) * 65, 0)
        local aniNode = AnimationPlayer:playNodeFrameAni(viewNode.nodeFirstFuzzyPos, aniInfo, pos)
        table.insert(self._fuzzyNodeList, aniNode)
    end
end

-- 去除模糊
function RollNumberCtrl:removeFuzzy()
    for _, v in pairs(self._fuzzyNodeList) do
        local action = cc.FadeTo:create(0.5, 0)
        local sequence = cc.Sequence:create(action, cc.CallFunc:create(function ()
            v:setOpacity(255)
            AnimationPlayer:stopNodeFrameAni(v)
        end))
        v:runAction(sequence)
    end

    self._viewNode.panelRollArea:setOpacity(255)
end

-- 初始化每一个数字
function RollNumberCtrl:initPanels()
    local viewNode = self._viewNode
    if not viewNode then return end

    local panelList = viewNode.panelRollArea:getChildren()

    -- 对每个panel设置一些方法和数值
    for _, panel in pairs(panelList) do
        local panelSize = panel:getContentSize()
        local oneNumerSize = panel:getChildren()[1]:getContentSize()

        -- 初始速度
        panel.velocity = 0
        -- 初始加速度
        panel.acceleration = 0
        -- 初始位置
        panel.originPos = cc.p(panel:getPosition())
        -- 一圈的路程
        panel.oneTurnDis = panelSize.height - oneNumerSize.height

        function panel:roll()
            self._status = 1
            self.velocity = rollMaxVelocity
        end

        -- 指定停在哪个数字
        function panel:stop(number)
            
            self._stopNumber = number
            -- 通过现有值计算加速度a
            local p1 = cc.p(self:getPosition())
            -- 当前正在转的这一圈还剩多少路程
            local residueDis = self.oneTurnDis - math.abs(p1.y)
            -- 总路程
            local totalDis = self.oneTurnDis * stopTurns + residueDis + number * oneNumerSize.height
            self.acceleration = -(self.velocity * self.velocity) / (2 * -totalDis) * 0.97   -- 因为位置精度只有小数点后两位，所以会有误差，此处简单乘0.97处理
        end

        function panel:update(dt)
            local currentPos = cc.p(self:getPosition())
            local nextV = self.velocity + self.acceleration * dt
            local judgeNum = nextV * self.velocity                  -- 前后速度相乘来判断是否异号

            if math.abs(nextV) >= math.abs(rollMaxVelocity) then
                -- 达到最大速度后停止速度变化
                self.velocity = rollMaxVelocity
                self.acceleration = 0
            elseif judgeNum < 0 then
                -- 速度方向发生变化的时候停止速度变化
                if self._status == 1 then
                    self._status = 2
                end
            else
                self.velocity = nextV
            end
            
            if self._status == 1 then
                local targetPos = cc.p(currentPos.x, currentPos.y + (self.velocity * dt))
                if targetPos.y <= -self.oneTurnDis then
                    targetPos = self.originPos
                end
                self:setPosition(targetPos)
            elseif self._status == 2 then
                -- 误差修正
                local resPos = cc.p(self.originPos.x, -self._stopNumber * oneNumerSize.height)
                if self._stopNumber == 0 and (currentPos.y <= -(oneNumerSize.height * 9) and currentPos.y >= -(oneNumerSize.height * 10)) then
                    resPos = cc.p(self.originPos.x, -10 * oneNumerSize.height)
                end
                local action = cc.MoveTo:create(0.5, resPos)
                self:runAction(action)
                self._status = 3
            end
        end
        
        schedule(handler(panel, panel.update), 0)
    end
end

function RollNumberCtrl:rollAll()
    for i = 1, totalRollNumber do
        self:rollNumberByIndex(i)
    end
end

function RollNumberCtrl:stopAll(resNumList)
    self:removeFuzzy()
    self._viewNode.panelRollArea:setOpacity(255)
    -- 从右到左依次停止滚轮
    local t1 = 0
    for i = 1, #resNumList do
        if i == 1 then
            t1 = t1
        elseif i == #resNumList then
            t1 = t1 + 1.3
        else
            t1 = t1 + 1
        end
        scheduleOnce(function ()
            if i == (#resNumList - 1) then
                -- 当倒数第二个滚轮开始停止时，播放四下音效
                local timeList = {1.1, 1.3, 1.8, 2.6}
                for _, v in pairs(timeList) do
                    scheduleOnce(function ()
                        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/RollStop.mp3'), false)
                    end, v)
                end
            end
            self:stopNumberByIndex(i, resNumList[#resNumList - i + 1])
        end, t1)
    end
end

function RollNumberCtrl:rollNumberByIndex(index)
    local viewNode = self._viewNode
    local list = viewNode.panelRollArea:getChildren()
    if not list[index] then
        print("roll index not exist index:" .. index)
        return
    end

    list[index]:roll()
end

function RollNumberCtrl:stopNumberByIndex(index, number)
    local viewNode = self._viewNode
    local list = viewNode.panelRollArea:getChildren()
    if not list[index] then
        print("roll index not exist index:" .. index)
        return
    end

    list[index]:stop(number)
end

function RollNumberCtrl:removeFuzzyByIndex(index)
    if self._fuzzyNodeList[index] then
        local action = cc.FadeTo:create(0.5, 0)
        local sequence = cc.Sequence:create(action, cc.CallFunc:create(function ()
            self._fuzzyNodeList[index]:setOpacity(255)
            AnimationPlayer:stopNodeFrameAni(self._fuzzyNodeList[index])
        end))
        self._fuzzyNodeList[index]:runAction(sequence)
    end
end

function RollNumberCtrl:onExit()
    removeAllSche()
    RollNumberCtrl.super.onExit(self)

    if type(self._callback) == 'function' then
        self._callback()
    end
end

return RollNumberCtrl