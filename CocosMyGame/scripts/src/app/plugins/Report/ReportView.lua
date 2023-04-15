local viewCreator=cc.load('ViewAdapter'):create()

--由于显示的三个人顺序为顺时针，所以要对换第一个人和第三人显示名字和银子的控件
viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/Report/Layer_Report.csb',
    {
        Panel_Main  = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            Panel_Animation = 'Panel_Animation',
            {
                _option={prefix='Panel_Animation.'},      
        
                Node_1_1 = 'Panel_Player_2',
                {
                    _option={prefix='Panel_Player_2.'},
                    CheckBox_1_3 = "CheckBox",         
                    Txt_1_3 = "Text_UserName",
                    Img_DepositIcon_1 = "Img_DepositIcon",
                    Txt_SilverNum_3 = "Text_Deposit",
                },

                Node_1_2 = 'Panel_Player_3',
                {
                    _option={prefix='Panel_Player_3.'},
                    CheckBox_1_2 = "CheckBox",         
                    Txt_1_2 = "Text_UserName",
                    Img_DepositIcon_2 = "Img_DepositIcon",
                    Txt_SilverNum_2 = "Text_Deposit",
                },

                Node_1_3 = 'Panel_Player_4',
                {
                    _option={prefix='Panel_Player_4.'},
                    CheckBox_1_1 = "CheckBox",         
                    Txt_1_1 = "Text_UserName",
                    Img_DepositIcon_3 = "Img_DepositIcon",
                    Txt_SilverNum_1 = "Text_Deposit",
                },

                CheckBox_2_1 = 'Report_CheckBox_1',
                {
                    _option={prefix='Report_CheckBox_1.'},
                    Txt_2_1 = "Text_ReportInfo",
                },

                CheckBox_2_2 = 'Report_CheckBox_2',
                {
                    _option={prefix='Report_CheckBox_2.'},
                    Txt_2_2 = "Text_ReportInfo",
                },

                Img_Field_Inform = "Img_InputBG",
                Txt_Field_Inform = "EditBox",
                Btn_Commit = "Btn_Commit",
                Btn_Close  = "Btn_Close",
                Txt_DescribeObject = "Text_ReportPlayer",
                Txt_DescribeBehvior = "Text_ReportInfo",
                Txt_DescribeObject = "Text_AddDescribe",
            }
        }
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end

    local function fixTextField(viewNode, textfiledName, fontColor, placeHolderColor)
        local oldTextFiled = viewNode[textfiledName]
        oldTextFiled:setVisible(false)
        local contentSize = oldTextFiled:getContentSize()
        local editBox = ccui.EditBox:create(contentSize, 'res/hallcocosstudio/images/png/Hall_Box_EditBox.png')
        
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
                local name = child:getName()
                child:setDimensions(contentSize.width, contentSize.height)
                child:setTTFConfig(ttfConfig)
            end
        end

        editBox:setFontColor(fontColor or cc.c3b(0x33, 0x33, 0x33))
        editBox:setPlaceholderFontColor(placeHolderColor or oldTextFiled:getPlaceHolderColor())

        editBox:setPlaceHolder(oldTextFiled:getPlaceHolder())
        
        editBox:setMaxLength(oldTextFiled:getMaxLength())
        editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)

        oldTextFiled:getParent():addChild(editBox)
        viewNode[textfiledName] = editBox
        editBox:setLocalZOrder(oldTextFiled:getLocalZOrder()+1)
    end

    fixTextField(viewNode, 'Txt_Field_Inform', cc.c3b(0x5A, 0x5A, 0x5A), cc.c3b(0xB3, 0xB3, 0xB3))
end

return viewCreator