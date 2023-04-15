local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    "res/hallcocosstudio/mail/rewardtip_info1.csb",
    {
        _option = {prefix = "Panel_Main.Panel_Animation."},
        {
           _option = {prefix = "Panel_PhoneNum."}, 
           editBoxPhoneNum = "Input_PhoneNum",
           phoneRight = "Img_PhoneNumRight",
           phoneWrong = "Img_PhoneNumWrong"
        },
        {
           _option = {prefix = "Panel_Name."}, 
           editBoxName = "Input_Name",
           nameRight = "Img_NameRight",
           nameWrong = "Img_NameWrong"
        },
        {
           _option = {prefix = "Panel_Remarks."}, 
           editBoxRemark = "Input_Remarks",
        },
        {
           _option = {prefix = "Panel_Address."}, 
           editBoxAddress = "Input_Address",
           textAddress = "Text_Address"
        },
        {
           _option = {prefix = "Panel_Item."},
           imgItem = "Img_Items",
           itemName = "Text_ItemName"
        },
        btnCommit = "Btn_Commit",
        btnClose = "Btn_Close"
    }
}

function viewCreator:onCreateView(viewNode, awardInfo)
    my.fixTextField(viewNode, 'editBoxPhoneNum', viewNode.editBoxPhoneNum, "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")
    my.fixTextField(viewNode, 'editBoxName', viewNode.editBoxName, "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")
    viewNode.editBoxName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    my.fixTextField(viewNode, 'editBoxRemark', viewNode.editBoxRemark, "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")
    viewNode.editBoxRemark:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    my.fixTextField(viewNode, 'editBoxAddress', viewNode.editBoxAddress, "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")
    viewNode.editBoxAddress:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    viewNode.editBoxAddress:setFontName('Arial')
    viewNode.editBoxAddress:setFontSize(32)

    viewNode.editBoxAddress:setLocalZOrder(viewNode.editBoxAddress:getLocalZOrder() - 2)
    viewNode.phoneRight:setLocalZOrder(viewNode.phoneRight:getLocalZOrder() + 2)
    viewNode.phoneWrong:setLocalZOrder(viewNode.phoneWrong:getLocalZOrder() + 2)

    function viewNode:isCheckRight()
        return self.phoneRight:isVisible() 
            and string.len(self.editBoxName:getString()) > 0
--            and string.len(self.editBoxRemark:getString()) > 0 备注可以不写
            and string.len(self.editBoxAddress:getString()) > 0
    end   

    function viewNode:setPhoneNumValid(bValid)
       self.phoneRight:setVisible(bValid)
       self.phoneWrong:setVisible(not bValid)
    end 
end

return viewCreator