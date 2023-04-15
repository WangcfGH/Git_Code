local viewCreator = cc.load('ViewAdapter'):create()
local config      = import("src.app.HallConfig.EmailConfig")

viewCreator.viewConfig={
    "res/hallcocosstudio/mail/maildetail.csb",
    {
        _option={prefix = 'Panel_Main.Panel_Animation.'},
        emailTag = "Text_Title",
        deadLine = "Text_DeadLine",
        btnPre   = "Btn_PreMail",
        btnNext  = "Btn_NextMail",
        btnClose = "Btn_Close",
        btnDelete = "Btn_Delete",
        panelReward = "Panel_Detail2",
        {
             _option={prefix = 'Panel_Detail2.'},
             rewardTitle = "Text_Title2",
             rewardDetail = "Scroll_TextDetail.Text_Detail",
             rewardDate = "Text_Date",
             rewardScroll = "Scroll_TextDetail",
             listItems = "List_Items",
             btnReward = "Btn_Reward",
             btnRewardClose = "Btn_CloseMail"
        },
        panelNotice = "Panel_Detail1",
        {
             _option={prefix = 'Panel_Detail1.'},
             noticeTitle = "Text_Title2",
             noticeScroll = "Scroll_TextDetail",
             noticeDetail = "Scroll_TextDetail.Text_Detail",
             noticeDate = "Text_Date",
             btnNoticeClose = "Btn_CloseMail"
        },
    }
}

function viewCreator:onCreateView(viewNode, emailInfo)
    self:wrapViewNode(viewNode)
    if type(emailInfo) == "table" then
        viewNode:setEmailInfo(emailInfo)
    end
end

function viewCreator:wrapViewNode(viewNode)
    function viewNode:setEmailInfo(emailInfo)
        self:setAwardInfo(emailInfo.EmailAwardList)
        self:setTitle(emailInfo.EmailTitle)
        self:setDeadline(emailInfo.OverDueTime)
        self:setDetail(emailInfo.EmailContent)
        self:setSentDate(emailInfo.SentTime)
        self:setDeleteBtn(emailInfo.EmailAwardList)
    end

    function viewNode:setAwardInfo(awardList)
        if type(awardList) == "table" and table.nums(awardList) > 0 then
            self.panelNotice:hide()
            self.panelReward:show()
            self.listItems:removeAllChildren()
            self:addAwardItemByAwardList(awardList)
        else
            self.panelNotice:show()
            self.panelReward:hide()
        end
    end

    function viewNode:setTag(title)
        local tag = string.find(title, "——") and string.gsub(title, "——.*", "") or config.description.defaultTag
        local tagSize = self.emailTag:getVirtualRendererSize()
        self.emailTag:setString(tag)
        local diffWidth = self.emailTag:getVirtualRendererSize().width - tagSize.width
        self.deadLine:setPosition(cc.p(self.deadLine:getPositionX() + diffWidth, self.deadLine:getPositionY()))
    end

    function viewNode:setTitle(emailTitle)
        self.rewardTitle:setString(emailTitle)
        self.noticeTitle:setString(emailTitle)
        self:setTag(emailTitle)
    end

    function viewNode:setDeadline(unixTime)
        self.deadLine:setString(os.date(config.description.deadlineTip, unixTime))
    end

    function viewNode:setDetail(detail)
        if self.panelNotice:isVisible() then
            my.autoWrapToFitTextField(self.noticeDetail, detail, self.noticeScroll, "\n")
        else
            my.autoWrapToFitTextField(self.rewardDetail, detail, self.rewardScroll, "\n")
        end
    end

    function viewNode:setSentDate(unixTime)
        self.rewardDate:setString(os.date("%Y-%m-%d", unixTime))
        self.noticeDate:setString(os.date("%Y-%m-%d", unixTime))
    end

    function viewNode:addAwardItem(awardItem, itemId)
        self.listItems:addChild(awardItem:getRealNode(), 0, itemId)
    end

    function viewNode:addAwardItemByAwardList(awardList)
        local isNeedReward = false
        --占住0号位，控件居中显示
        local emptyAward = EmailViewFactory.newAwardItem()
        self.listItems:addChild(emptyAward:getRealNode())
        emptyAward:getRealNode():removeFromParent()
        for _, awardInfo in pairs(awardList) do
            if not awardInfo.isRewarded then isNeedReward = true end
            local newAwardItem = EmailViewFactory.newAwardItem(awardInfo)
            self:addAwardItem(newAwardItem, awardInfo.ItemId)
        end
        local contentWidth = self.panelReward:getContentSize().width
        local itemWidth = emptyAward:getContentSize().width
        local itemCount = #self.listItems:getItems() - 1
        local margin = (contentWidth - itemCount * itemWidth)/(itemCount + 1)
        self.listItems:setContentSize(cc.size(contentWidth + itemWidth + margin, self.listItems:getContentSize().height))
        self.listItems:setItemsMargin(margin)
        self.btnReward:setVisible(isNeedReward)
        self.btnRewardClose:setVisible(not isNeedReward)
    end

    function viewNode:setItemAwardStatus(itemId, status)
        local awardItem = EmailViewFactory.wrapAwardItem(self.listView:getChildByTag(itemId))
        awardItem:setAwardStatus(status)
    end

    function viewNode:setDeleteBtn(awardList)
        local bShow = true
        if type(awardList) == "table" then
            for _, awardInfo in pairs(awardList) do
                if not awardInfo.isRewarded then
                    bShow = false
                    break
                end
            end
        end
        self.btnDelete:setVisible(bShow)
    end
end

return viewCreator