local InviteGiftShareView = cc.load('ViewAdapter'):create()

InviteGiftShareView.viewConfig = {
    'res/hallcocosstudio/invitegiftactive/invitegiftshare.csb',
    {
        _option = { prefix = 'Panel_Main.Panel_Animation.' },
        closeBt = 'Btn_Close',
        shareToWechat = 'Btn_Wechat',
        shareToWechat2 = 'Btn_Wechat2',
        imgTitle = "Img_IOSTitle",
        panelShareType = 'Panel_ShareType',
        {
            _option = { prefix = 'Panel_ShareType.' },
            checkBoxWord = 'CheckBox_WordShare',
            checkBoxImg = 'CheckBox_ImgShare',
        },

        panelProgress = 'Panel_Progress',
        {
            _option = { prefix = 'Panel_Progress.' },
            textType = 'Text_Type',
            ImgProgressBg = 'Img_ProgressBg',
            checkBoxPoint1 = 'CheckBox_Point1',
            checkBoxPoint2 = 'CheckBox_Point2',
            checkBoxPoint3 = 'CheckBox_Point3',
            textStage1 = 'Text_Stage1',
            textStage2 = 'Text_Stage2',
            textStage3 = 'Text_Stage3',
        },
    }
}

InviteGiftShareView.SwitchType = {
    WORD = 1,
    IMAGE = 2
}

function InviteGiftShareView:onCreateView(viewNode)
    if not viewNode then return end

    function viewNode:switchShareType(type)
        if type == InviteGiftShareView.SwitchType.WORD then
            self.checkBoxWord:setEnabled(false)
            self.checkBoxImg:setSelected(false)
            self.checkBoxImg:setEnabled(true)
            self.shareToWechat:show()
            self.shareToWechat2:hide()
            self.textType:setString('口令已复制')
            self.textStage1:setString('分享口令')
        elseif type == InviteGiftShareView.SwitchType.IMAGE then
            self.checkBoxWord:setEnabled(true)
            self.checkBoxWord:setSelected(false)
            self.checkBoxImg:setEnabled(false)
            self.shareToWechat:hide()
            self.shareToWechat2:show()
            self.textType:setString('二维码已生成')
            self.textStage1:setString('分享图片')
        end
    end

    function viewNode:setProgress(pointNum)
        print("sdsdsd")
    end

    function viewNode:getShareType()
        if self.checkBoxImg:isSelected() then
            return InviteGiftShareView.SwitchType.IMAGE
        elseif self.checkBoxWord:isSelected() then
            return InviteGiftShareView.SwitchType.WORD
        end
    end
end

return InviteGiftShareView