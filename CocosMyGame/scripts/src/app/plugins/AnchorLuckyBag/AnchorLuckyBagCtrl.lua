local viewCreater = import('src.app.plugins.AnchorLuckyBag.AnchorLuckyBagView')
local AnchorLuckyBagCtrl = class('AnchorLuckyBagCtrl', cc.load('BaseCtrl'))
local AnchorLuckyBagModel = import('src.app.plugins.AnchorLuckyBag.AnchorLuckyBagModel'):getInstance()

AnchorLuckyBagCtrl.RUN_ENTERACTION = true

function AnchorLuckyBagCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self._startYear = tonumber(os.date('%Y', os.time())) - 1
    self._textHourTbl = {}
    self._textYearTbl = {}
    self._textMonthTbl = {}
    self._textDayTbl = {}
    self._chooseYear = nil
    self._chooseMonth = nil
    self._chooseDay = nil
    self._chooseHour = nil

    self:initEventListeners()
    self:initBtnsEvent()
    self:initUI()
    AnchorLuckyBagModel:queryTiktokAcount()
end

function AnchorLuckyBagCtrl:initEventListeners()
    self:listenTo(AnchorLuckyBagModel, AnchorLuckyBagModel.EVENT_QUERY_TIKTOKACCOUNT_OK, handler(self, self.onQueryTiktokAccountOK))
    self:listenTo(AnchorLuckyBagModel, AnchorLuckyBagModel.EVENT_COMMIT_REWARDINFO_OK, handler(self, self.onCommitRewardInfoOK))
end

function AnchorLuckyBagCtrl:removeEventListeners()
    AnchorLuckyBagModel:removeEventListenersByTag(self:getEventTag())
end

function AnchorLuckyBagCtrl:initBtnsEvent()
    local bindList = {
        'btnUnlock',
        'btnCheckAccount',
        'btnPasteTiktok',
        'btnPasteAnchor',
        'btnCommit',
        'btnRewardList',
        'btnChooseYear',
        'btnChooseMonth',
        'btnChooseDay',
        'btnChooseHour',
    }
    self:bindUserEventHandler(self._viewNode, bindList)
    self:bindDestroyButton(self._viewNode.btnClose)
end

function AnchorLuckyBagCtrl:initUI()
    self:freshTiktokAccount()
    self:initCurDateTime()
    self:initPanelChooseDateTime()
end

function AnchorLuckyBagCtrl:freshTiktokAccount()
    local tiktokAccount = AnchorLuckyBagModel:getTiktokAccount()
    if tiktokAccount and tiktokAccount ~= '' then
        self._viewNode.editboxTiktokAccount:setString(tiktokAccount)
        self:enableBtnUnlock(true)
        self:enablePasteBtnTiktokAccount(false)
        self:enableInputTiktokAccount(false)
    else
        self:enableBtnUnlock(false)
        self:enablePasteBtnTiktokAccount(true)
        self:enableInputTiktokAccount(true)
    end
end

function AnchorLuckyBagCtrl:initPanelChooseDateTime()
    -- 年月时相对固定，直接初始化，日根据月变化而变化
    self:initPanelChooseYear()
    self:initPanelChooseMonth()
    self:initPanelChooseHour()
end

function AnchorLuckyBagCtrl:initPanelChooseYear()
    local listViewYear = self._viewNode.listViewYear

    local textYear = listViewYear:getChildByName('Text_0')
    table.insert(self._textYearTbl, textYear)

    for i = 1, 2 do
        local textYear = textYear:clone()
        if textYear then
            table.insert(self._textYearTbl, textYear)
            textYear:setName('Text_' .. tostring(i))
            listViewYear:insertCustomItem(textYear, i)
        end
    end

    for i, textYear in ipairs(self._textYearTbl) do
        textYear:setTouchEnabled(true)
        textYear:onTouch(
            function(e)
                if (e.name == 'began') then
                    e.target:setColor(cc.c3b(255, 255, 0))
                elseif (e.name == 'cancelled') then
                    if self._startYear + i - 1 ~= self._chooseYear then
                        e.target:setColor(cc.c3b(255, 255, 255))
                    end
                elseif (e.name == 'ended') then
                    self:onYearChoosed(self._startYear + i - 1)
                end
            end
        )
    end
end

function AnchorLuckyBagCtrl:initPanelChooseMonth()
    local listViewMonth = self._viewNode.listViewMonth

    local textMonth = listViewMonth:getChildByName('Text_0')
    table.insert(self._textMonthTbl, textMonth)

    for i = 1, 11 do
        local textMonth = textMonth:clone()
        if textMonth then
            table.insert(self._textMonthTbl, textMonth)
            textMonth:setName('Text_' .. tostring(i))
            listViewMonth:insertCustomItem(textMonth, i)
        end
    end

    for i, textMonth in ipairs(self._textMonthTbl) do
        textMonth:setTouchEnabled(true)
        textMonth:onTouch(
            function(e)
                if (e.name == 'began') then
                    e.target:setColor(cc.c3b(255, 255, 0))
                elseif (e.name == 'cancelled') then
                    if i ~= self._chooseMonth then
                        e.target:setColor(cc.c3b(255, 255, 255))
                    end
                elseif (e.name == 'ended') then
                    self:onMonthChoosed(i)
                end
            end
        )
    end
end

function AnchorLuckyBagCtrl:isLeapYear(year)
    if year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then
        return true
    end
    return false
end

function AnchorLuckyBagCtrl:initPanelChooseDay()

    local totalDays = 0
    local largeMonth = {1, 3, 5, 7, 8, 10, 12}
    local smallMonth = {4, 6, 9, 11}
    if table.indexof(largeMonth, self._chooseMonth) then
        totalDays = 31
    elseif table.indexof(smallMonth, self._chooseMonth) then
        totalDays = 30
    elseif self._chooseMonth == 2 then
        if self:isLeapYear(self._chooseYear) then
            totalDays = 29
        else
            totalDays = 28
        end
    end

    local listViewDay = self._viewNode.listViewDay

    local textDay = listViewDay:getChildByName('Text_0')
    table.insert(self._textDayTbl, textDay)

    for i = 1, totalDays - 1 do
        local textDay = textDay:clone()
        if textDay then
            table.insert(self._textDayTbl, textDay)
            textDay:setName('Text_' .. tostring(i))
            listViewDay:insertCustomItem(textDay, i)
        end
    end

    for i, textDay in ipairs(self._textDayTbl) do
        textDay:setTouchEnabled(true)
        textDay:onTouch(
            function(e)
                if (e.name == 'began') then
                    e.target:setColor(cc.c3b(255, 255, 0))
                elseif (e.name == 'cancelled') then
                    if i ~= self._chooseDay then
                        e.target:setColor(cc.c3b(255, 255, 255))
                    end
                elseif (e.name == 'ended') then
                    self:onDayChoosed(i)
                end
            end
        )
    end
end

function AnchorLuckyBagCtrl:initPanelChooseHour()
    local listViewHour = self._viewNode.listViewHour

    local textHour = listViewHour:getChildByName('Text_0')
    table.insert(self._textHourTbl, textHour)

    for i = 1, 23 do
        local textHour = textHour:clone()
        if textHour then
            table.insert(self._textHourTbl, textHour)
            textHour:setName('Text_' .. tostring(i))
            listViewHour:insertCustomItem(textHour, i)
        end
    end

    for i, textHour in ipairs(self._textHourTbl) do
        textHour:setTouchEnabled(true)
        textHour:onTouch(
            function(e)
                if (e.name == 'began') then
                    e.target:setColor(cc.c3b(255, 255, 0))
                elseif (e.name == 'cancelled') then
                    if i ~= self._chooseHour then
                        e.target:setColor(cc.c3b(255, 255, 255))
                    end
                elseif (e.name == 'ended') then
                    self:onHourChoosed(i - 1)
                end
            end
        )
    end
end

function AnchorLuckyBagCtrl:initCurDateTime()
    local curTime = os.time()

    -- 年
    local curYear = os.date('%Y', curTime)
    local strYear = string.format('%04d年', curYear)
    self._viewNode.textRewardYear:setString(strYear)
    self._chooseYear = tonumber(curYear)

    -- 月
    local curMonth = os.date('%m', curTime)
    local strMonth = string.format('%02d月', curMonth)
    self._chooseMonth = tonumber(curMonth)
    self._viewNode.textRewardMonth:setString(strMonth)

    -- 日
    local curDay = os.date('%d', curTime)
    local strDay = string.format('%02d日', curDay)
    self._chooseDay = tonumber(curDay)
    self._viewNode.textRewardDay:setString(strDay)

    -- 时
    local curHour = os.date('%H', curTime)
    local strHour = string.format('%02d:00', curHour)
    self._chooseHour = tonumber(curHour)
    self._viewNode.textRewardHour:setString(strHour)
end

function AnchorLuckyBagCtrl:enablePasteBtnTiktokAccount(enable)
    self._viewNode.btnPasteTiktok:setBright(enable)
    self._viewNode.btnPasteTiktok:setTouchEnabled(enable)
end

function AnchorLuckyBagCtrl:enableBtnUnlock(enable)
    self._viewNode.btnUnlock:setBright(enable)
    self._viewNode.btnUnlock:setTouchEnabled(enable)
end

function AnchorLuckyBagCtrl:enableInputTiktokAccount(enable)
    self._viewNode.editboxTiktokAccount:setBright(enable)
    self._viewNode.editboxTiktokAccount:setTouchEnabled(enable)
end

function AnchorLuckyBagCtrl:btnUnlockClicked()
    self._viewNode.editboxTiktokAccount:setString('')
    self:enableBtnUnlock(false)
    self:enablePasteBtnTiktokAccount(true)
    self:enableInputTiktokAccount(true)
end

function AnchorLuckyBagCtrl:btnCheckAccountClicked()
    my.informPluginByName({pluginName = 'CheckTiktokAccountCtrl'})
end

function AnchorLuckyBagCtrl:btnPasteTiktokClicked()
    local clipboardString = DeviceUtils:getInstance():getClipboardContent()
    if clipboardString and string.len(clipboardString) > 0 then
        cc.exports.clipboardContent = clipboardString
        self._viewNode.editboxTiktokAccount:setString(string.sub(clipboardString, 1, 16))
    end
    if DeviceUtils:getInstance().copyToClipboard then
        DeviceUtils:getInstance():copyToClipboard('')
    end
end

function AnchorLuckyBagCtrl:btnPasteAnchorClicked()
    local clipboardString = DeviceUtils:getInstance():getClipboardContent()
    if clipboardString and string.len(clipboardString) > 0 then
        cc.exports.clipboardContent = clipboardString
        self._viewNode.editboxAnchorAccount:setString(string.sub(clipboardString, 1, 16))
    end
    if DeviceUtils:getInstance().copyToClipboard then
        DeviceUtils:getInstance():copyToClipboard('')
    end
end

function AnchorLuckyBagCtrl:btnChooseYearClicked()
    local visible = self._viewNode.panelChooseYear:isVisible()
    self:showPanelChooseYear(not visible)
    self:showPanelChooseMonth(false)
    self:showPanelChooseDay(false)
    self:showPanelChooseHour(false)
end

function AnchorLuckyBagCtrl:btnChooseMonthClicked()
    local visible = self._viewNode.panelChooseMonth:isVisible()
    self:showPanelChooseYear(false)
    self:showPanelChooseMonth(not visible)
    self:showPanelChooseDay(false)
    self:showPanelChooseHour(false)
end

function AnchorLuckyBagCtrl:btnChooseDayClicked()
    local visible = self._viewNode.panelChooseDay:isVisible()
    self:showPanelChooseYear(false)
    self:showPanelChooseMonth(false)
    self:showPanelChooseDay(not visible)
    self:showPanelChooseHour(false)
end

function AnchorLuckyBagCtrl:btnChooseHourClicked()
    local visible = self._viewNode.panelChooseHour:isVisible()
    self:showPanelChooseYear(false)
    self:showPanelChooseMonth(false)
    self:showPanelChooseDay(false)
    self:showPanelChooseHour(not visible)
end

function AnchorLuckyBagCtrl:btnCommitClicked()
    local tiktokAccount = self._viewNode.editboxTiktokAccount:getString()
    if tiktokAccount == '' then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '您还未输入您的抖音号，请重新输入'}})
        return
    elseif string.find(tiktokAccount, '[^a-zA-Z0-9_.]') then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '抖音号只包含字母数字下划线和点，请检查后重新输入'}})
        return
    end

    local anchorAccount = self._viewNode.editboxAnchorAccount:getString()
    if anchorAccount == '' then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '您还未输入主播抖音号，请重新输入'}})
        return
    elseif string.find(anchorAccount, '[^a-zA-Z0-9_.]') then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '抖音号只包含字母数字下划线和点，请检查后重新输入'}})
        return
    end
    
    local strDateTime = string.format('%04d%02d%02d-%02d:00', self._chooseYear, self._chooseMonth, self._chooseDay, self._chooseHour)
    AnchorLuckyBagModel:commitRewardInfo(tiktokAccount, anchorAccount, strDateTime)
end

function AnchorLuckyBagCtrl:btnRewardListClicked()
    my.informPluginByName({pluginName = 'LuckyBagRewardListCtrl'})
end

function AnchorLuckyBagCtrl:onQueryTiktokAccountOK()
    self:freshTiktokAccount()
end

function AnchorLuckyBagCtrl:onCommitRewardInfoOK(data)
    if data.value and data.value.commitSuccess then
        self:enableBtnUnlock(true)
        self:removeSelfInstance()
    end
end

function AnchorLuckyBagCtrl:showPanelChooseYear(show)
    self._viewNode.panelChooseYear:setVisible(show)
    if show then
        for i, textYear in ipairs(self._textYearTbl) do
            if self._startYear + i - 1 == self._chooseYear then
                local strYear = string.format('%04d年 ★', self._startYear + i - 1)
                textYear:setString(strYear)
                textYear:setColor(cc.c3b(255, 255, 0))
            else
                local strYear = string.format('%04d年', self._startYear + i - 1)
                textYear:setString(strYear)
                textYear:setColor(cc.c3b(255, 255, 255))
            end
        end
    end
end

function AnchorLuckyBagCtrl:showPanelChooseMonth(show)
    self._viewNode.panelChooseMonth:setVisible(show)
    if show then
        for i, textMonth in ipairs(self._textMonthTbl) do
            if i == self._chooseMonth then
                local strMonth = string.format('%02d月 ★', i)
                textMonth:setString(strMonth)
                textMonth:setColor(cc.c3b(255, 255, 0))
            else
                local strMonth = string.format('%02d月', i)
                textMonth:setString(strMonth)
                textMonth:setColor(cc.c3b(255, 255, 255))
            end
        end
        if self._chooseMonth <= 4 then
            self._viewNode.listViewMonth:jumpToTop()
        elseif self._chooseMonth >= 9 then
            self._viewNode.listViewMonth:jumpToBottom()
        else
            local percent = (self._chooseMonth - 4) / 5 * 100
            my.scheduleOnce(function()
                self._viewNode.listViewMonth:jumpToPercentVertical(percent)
            end)
        end
    end
end

function AnchorLuckyBagCtrl:showPanelChooseDay(show)
    self._viewNode.panelChooseDay:setVisible(show)
    if show then
        for i = #self._textDayTbl, 1, -1 do
            if i > 1 then
                self._viewNode.listViewDay:removeItem(i - 1)
                table.remove( self._textDayTbl, i )
            elseif i == 1 then
                table.remove( self._textDayTbl, i )
            end
        end

        self:initPanelChooseDay()
        for i, textDay in ipairs(self._textDayTbl) do
            if i == self._chooseDay then
                local strDay = string.format('%02d日 ★', i)
                textDay:setString(strDay)
                textDay:setColor(cc.c3b(255, 255, 0))
            else
                local strDay = string.format('%02d日', i)
                textDay:setString(strDay)
                textDay:setColor(cc.c3b(255, 255, 255))
            end
        end

        local totalDays = #self._textDayTbl
        if self._chooseDay <= 4 then
            self._viewNode.listViewDay:jumpToTop()
        elseif self._chooseDay >= totalDays - 3 then
            self._viewNode.listViewDay:jumpToBottom()
        else
            local percent = (self._chooseDay - 4) / (totalDays - 7) * 100
            my.scheduleOnce(function()
                self._viewNode.listViewDay:jumpToPercentVertical(percent)
            end)
        end
    end
end

function AnchorLuckyBagCtrl:showPanelChooseHour(show)
    self._viewNode.panelChooseHour:setVisible(show)
    if show then
        for i, textHour in ipairs(self._textHourTbl) do
            if i - 1 == self._chooseHour then
                local strHour = string.format('%02d:00 ★', i - 1)
                textHour:setString(strHour)
                textHour:setColor(cc.c3b(255, 255, 0))
            else
                local strHour = string.format('%02d:00', i - 1)
                textHour:setString(strHour)
                textHour:setColor(cc.c3b(255, 255, 255))
            end
        end
        if self._chooseHour <= 3 then
            self._viewNode.listViewHour:jumpToTop()
        elseif self._chooseHour >= 20 then
            self._viewNode.listViewHour:jumpToBottom()
        else
            local percent = (self._chooseHour - 3) / 17 * 100
            my.scheduleOnce(function()
                self._viewNode.listViewHour:jumpToPercentVertical(percent)
            end)
        end
    end
end

function AnchorLuckyBagCtrl:onYearChoosed(year)
    self._chooseYear = year
    self._viewNode.textRewardYear:setString(string.format('%04d年', year))
    self:showPanelChooseYear(false)

    if self._chooseMonth == 2 and self._chooseDay == 29 then
        if not self:isLeapYear(self._chooseYear) then
            self:chooseDay(28)
        end
    end
end

function AnchorLuckyBagCtrl:onMonthChoosed(month)
    self._chooseMonth = month
    self._viewNode.textRewardMonth:setString(string.format('%02d月', month))
    self:showPanelChooseMonth(false)

    local largeMonth = {1, 3, 5, 7, 8, 10, 12}
    local smallMonth = {4, 6, 9, 11}

    if self._chooseMonth == 2 then
        if self:isLeapYear(self._chooseYear) then
            if self._chooseDay > 29 then
                self:chooseDay(29)
            end
        else
            if self._chooseDay > 28 then
                self:chooseDay(28)
            end
        end
    elseif table.indexof(smallMonth, self._chooseMonth) then
        if self._chooseDay > 30 then
            self:chooseDay(30)
        end
    end
end

function AnchorLuckyBagCtrl:onDayChoosed(day)
    self:chooseDay(day)
    self:showPanelChooseDay(false)
end

function AnchorLuckyBagCtrl:chooseDay(day)
    self._chooseDay = day
    self._viewNode.textRewardDay:setString(string.format('%02d日', day))
end

function AnchorLuckyBagCtrl:onHourChoosed(hour)
    self._chooseHour = hour
    self._viewNode.textRewardHour:setString(string.format('%02d:00', hour))
    self:showPanelChooseHour(false)
end

function AnchorLuckyBagCtrl:onExit()
    self:removeEventListeners()
end

return AnchorLuckyBagCtrl
