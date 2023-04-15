local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    "res/hallcocosstudio/mail/mail.csb",
    {
        panelMain = "Panel_Main",
        {
            _option={prefix = 'Panel_Main.Panel_Animation.'},
            btnClose = "Btn_Close",
            panelEmpty = "Panel_Empty",
            btnEmptyClose = "Panel_Empty.Btn_Close",
            panelEmailList = "Panel_MailList",
            {
                _option={prefix = "Panel_MailList."},
                listEmailList = "List_MailList",
                btnClearReadEmails = "Btn_Clear",
                btnTakeAll = "Btn_RewardAll",
                textEmailNum = "Text_NumMail",
                panelScroller = "Panel_Scrollbar",
                sroller = "Panel_Scrollbar.Img_Dot"
            }
        }
    }
}

function viewCreator:onCreateView(viewNode)
    self:wrapViewNode(viewNode)
    viewNode:showNoEmail()
end

function viewCreator:wrapViewNode(viewNode)
    function viewNode:addEmail(email, emailId)
        self.listEmailList:addChild(email:getRealNode(), 0, emailId)
        local a = self.listEmailList:getInnerContainerSize()
        local b = self.listEmailList:getContentSize()
        self:resetScrollBar()
        self:showEmailList()
    end

    function viewNode:getEmail(emailId)
        return EmailViewFactory.wrapEmailTab(self.listEmailList:getChildByTag(emailId))
    end

    function viewNode:clearEmails()
        self:showNoEmail()
        self.listEmailList:removeAllChildren()
    end

    function viewNode:removeEmail(emailId)
        local email = self.listEmailList:getChildByTag(emailId)
        if email then self.listEmailList:removeChild(email) end
        self:resetScrollBar()
        self.listEmailList:requestRefreshView()
        if #self.listEmailList:getItems() == 0 then
            self:showNoEmail()
        end
    end

    function viewNode:setEmailCount(notRead, total)
        --数量暂不设置
        if not self.textEmailNum then return end
        self.textEmailNum:setString(tostring(notRead).."/"..tostring(total))
    end

    function viewNode:showEmailList()
        self.panelEmailList:show()
        self.panelEmpty:hide()
    end

    function viewNode:showNoEmail()
        self.panelEmailList:hide()
        self.panelEmpty:show()
    end

    function viewNode:resetScrollBar()
        local defaultEmailContain = 3.5
        local a = self.listEmailList:getItems()
        self.scrollBar:setWindowZonePercent(#self.listEmailList:getItems()/defaultEmailContain)
    end

    function viewNode:showShade()
        self.panelMain:setColor(cc.c3b(0x7a,0x7a,0x7a))
    end

    function viewNode:removeShade()
        self.panelMain:setColor(cc.c3b(0xff,0xff,0xff))
    end

    function viewNode:refreshView()
        if self.listEmailList.refreshView then
            self.listEmailList:refreshView()
        end
    end
    viewNode.scrollBar = cc.load("myccui").ScrollBar:create(viewNode.panelScroller, viewNode.sroller, viewNode.listEmailList)
end

return viewCreator