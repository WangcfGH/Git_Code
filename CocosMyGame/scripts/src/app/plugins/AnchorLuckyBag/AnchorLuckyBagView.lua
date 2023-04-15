local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorLuckyBag/Layer_AnchorLuckyBag.csb',
    {
        panelShade = 'Panel_Shade',
        panelMain = 'Panel_Main',
        {
            _option = {
                prefix = 'Panel_Main.'
            },
            panelAnimation = 'Panel_Animation',
            {
                _option = {
                    prefix = 'Panel_Animation.',
                },
                btnClose = 'Btn_Close',
                btnUnlock = 'Btn_Unlock',
                btnCheckAccount = 'Btn_CheckAccount',
                btnPasteTiktok = 'Btn_Paste_Tiktok',
                btnPasteAnchor= 'Btn_Paste_Anchor',
                btnCommit = 'Btn_Commit',
                btnRewardList = 'Btn_RewardList',
                
                editboxTiktokAccount = 'TextField_TiktokAccount',
                editboxAnchorAccount = 'TextField_AnchorAccount',

                btnChooseYear = 'Btn_ChooseYear',
                btnChooseMonth = 'Btn_ChooseMonth',
                btnChooseDay = 'Btn_ChooseDay',
                btnChooseHour = 'Btn_ChooseHour',
                panelChooseYear = 'Panel_ChooseYear',
                panelChooseMonth = 'Panel_ChooseMonth',
                panelChooseDay = 'Panel_ChooseDay',
                panelChooseHour = 'Panel_ChooseHour',
                listViewYear = 'Panel_ChooseYear.ListView',
                listViewMonth = 'Panel_ChooseMonth.ListView',
                listViewDay = 'Panel_ChooseDay.ListView',
                listViewHour = 'Panel_ChooseHour.ListView',
                textRewardYear = 'Text_RewardYear',
                textRewardMonth = 'Text_RewardMonth',
                textRewardDay = 'Text_RewardDay',
                textRewardHour = 'Text_RewardHour'
            }
        }
    }
}

function viewCreator:onCreateView(viewNode)

    local function fixTextField(viewNode, textfiledName, fontColor)
        local oldTextFiled = viewNode[textfiledName]
        oldTextFiled:setVisible(false)
        local editBox = ccui.EditBox:create(oldTextFiled:getContentSize(), 'res/hallcocosstudio/images/png/Hall_Box_EditBox.png')
        
        editBox.getString = editBox.getText
        editBox.setString = editBox.setText
        editBox.setTextColor = editBox.setFontColor
    
        editBox:setAnchorPoint(oldTextFiled:getAnchorPoint())
        editBox:setPosition(oldTextFiled:getPosition())
    
        local ttfConfig = {
            fontFilePath = oldTextFiled:getFontName(),
            fontSize = oldTextFiled:getFontSize()
        }

        local children = editBox:getChildren()
        for __, child in pairs(children) do
            if child and child.setTTFConfig then
                child:setTTFConfig(ttfConfig)
            end
        end

        editBox:setFontColor(fontColor or cc.c3b(0x33, 0x33, 0x33))
        editBox:setPlaceholderFontColor(oldTextFiled:getPlaceHolderColor())

        editBox:setPlaceHolder(oldTextFiled:getPlaceHolder())
        
        editBox:setMaxLength(oldTextFiled:getMaxLength())
        editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    
        oldTextFiled:getParent():addChild(editBox)
        viewNode[textfiledName] = editBox
        editBox:setLocalZOrder(oldTextFiled:getLocalZOrder()+1)
    end

    fixTextField(viewNode, 'editboxTiktokAccount', cc.c3b(255, 181, 123))
    fixTextField(viewNode, 'editboxAnchorAccount', cc.c3b(255, 181, 123))
end

return viewCreator
