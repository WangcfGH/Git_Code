local viewCreator = cc.load('ViewAdapter'):create()
local config      = import("src.app.HallConfig.EmailConfig")

viewCreator.viewConfig={
    "res/hallcocosstudio/mail/mail_unit.csb",
    {
        btnCheckDetail = "Btn_CheckDetail",
        textTitle = "Text_MailTitle",
        panelAttachment = "Panel_Attachment",
        textDescription = "Panel_Attachment.Text_Attachment",
        iconNode = "Node_Item",
        imgDot = "Img_Dot",
        imgTagExpiring = "Img_TagExpire",
        imgTagExpired = "Img_TagExpired",
        textDate = "Text_Date",
        imgBg = "Img_BG"
    }
}

function viewCreator:onCreateView(viewNode, emailInfo)
    self:wrapViewNode(viewNode)

    if type(emailInfo) == "table" then
        viewNode:setEmailInfo(emailInfo)
    end
end

function viewCreator:createViewNode(filename)
    local root = cc.CSLoader:createMyNode(filename)
    self._viewNode = root:getChildByName("Panel_Main")
    self._viewNode:removeFromParent()
	return self._viewNode
end

function viewCreator:_createViewIndexer(filename,exchMap)
	self._viewNode=my.NodeIndexer(self:createViewNode(filename),exchMap)
    self:_setActionCall()
	return self._viewNode
end

function viewCreator:wrapViewNode(viewNode)
    function viewNode:setEmailInfo(emailInfo)
        self:setTitle(emailInfo.EmailTitle)
        self:setExpiredDate(emailInfo.OverDueTime)
        self:setAwardInfo(emailInfo.EmailAwardList)
        self:setEmailReadStatus(emailInfo)--emailInfo.isRead)
    end

    --设置邮件标题
    function viewNode:setTitle(title)
        --最长500像素，防止遮盖按钮
        my.fitStringInWidget(title, self.textTitle, 500)
        -- self.textTitle:setString(title)
    end

    --设置邮件图标
    function viewNode:setAwardIcon(icon)
        icon:setName("icon")
        self.iconNode:addChild(icon:getRealNode())
    end

    function viewNode:getAwardIcon()
        return self.iconNode:getChildByName("icon")
    end

    --设置邮件发送时间
    function viewNode:setSentDate(unixTime)
--        self.sendDateText:setString(os.date("%Y-%m-%d", unixTime))
    end

    --设置邮件过期时间
    function viewNode:setExpiredDate(unixTime)
        self.textDate:setString(os.date(config.description.deadlineTip, unixTime))
        self.imgTagExpired:setVisible(os.time() > unixTime)
        --一周604800s，提前一周显示即将过期
        self.imgTagExpiring:setVisible(os.time() > unixTime - 604800 and os.time() <= unixTime)
    end

    --设置邮件图标
    function viewNode:setIconByAwardInfo(awardInfo)
        if not self:getAwardIcon() then
            local icon = EmailViewFactory.newAwardItem(awardInfo)
            if icon then
                icon:setSwallowTouches(false)
                self:setAwardIcon(icon)
            end
        else
            local awardIcon = EmailViewFactory.wrapAwardItem(self:getAwardIcon())
            awardIcon:setAwardInfo(awardInfo)
        end
    end

    --设置邮件描述
    function viewNode:setDescription(description)
        if type(description) == "string" and string.len(description) > 0 then
            self.textDescription:setString(description)
        else
            self.panelAttachment:hide()
        end
    end

    --设置奖励信息
    function viewNode:setAwardInfo(awardList)
        local firstAward, awardCount = nil, 0

        local multiItemRewarded = true
        if type(awardList) == "table" then
            for _, awardInfo in pairs(awardList) do
                --需求变更，邮件的图标不需要因为物品的领取而改变
                firstAward = firstAward or awardInfo
                awardCount = awardCount + 1
                if not awardInfo.isRewarded then
                    multiItemRewarded = false
                end
            end
        end
        self:setDescription(multiItemRewarded and "" or string.format(config.description.awardExist, awardCount))
        if awardCount <= 1 then 
            self:setIconByAwardInfo(firstAward)
        else
            --超过一个物品的时候不显示第一个物品，而是直接显示大礼包
            self:setIconByAwardInfo({
                ItemCount = 0,
                ItemTypeID = "MultiItem",
                isRewarded = multiItemRewarded
            })
        end
    end

    --设置邮件读取状态
    function viewNode:setEmailReadStatus(emailInfo)
        --还有奖励的邮件也要显示红点
        local bShow = not emailInfo.isRead
        if not bShow then
            if type(emailInfo.EmailAwardList) == "table" then
                for _, awardInfo in pairs(emailInfo.EmailAwardList) do
                    if not awardInfo.isRewarded then
                        bShow = true
                        break
                    end
                end
            end
        end
        self.imgDot:setVisible(bShow)
    end

    function viewNode:showShade()
        self.imgBg:setColor(cc.c3b(0xd3,0xc7,0xb9))
    end

    function viewNode:removeShade()
        self.imgBg:setColor(cc.c3b(0xff,0xff,0xff))
    end

    return viewNode
end

function viewCreator:wrapUserdataNode( node )
    self._viewNode = my.NodeIndexer(node, self.viewConfig[2])
    return self:wrapViewNode(self._viewNode)
end

return viewCreator