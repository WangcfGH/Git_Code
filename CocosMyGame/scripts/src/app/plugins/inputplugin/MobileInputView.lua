local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    "res/hallcocosstudio/mail/rewardtip_info2.csb",
    {
        _option = {prefix = "Panel_Main.Panel_Animation."},
        {
           _option = {prefix = "Panel_PhoneNum."}, 
           editBoxPhoneNum = "Input_PhoneNum",
           tickRight = "Img_PhoneNumRight",
           tickWrong = "Img_PhoneNumWrong",
           inputBg1 = "Img_EditBox"
        },
        {
           _option = {prefix = "Panel_PhoneNum_Commit."}, 
           editBoxPhoneNumCheck = "Input_PhoneNum",
           checkTickRight = "Img_PhoneNumRight",
           checkTickWrong = "Img_PhoneNumWrong",
           inputBg2 = "Img_EditBox"
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
    my.fixTextField(viewNode, 'editBoxPhoneNumCheck', viewNode.editBoxPhoneNumCheck, "res/hallcocosstudio/images/png/Hall_Box_EditBox.png")

    viewNode.tickRight:setLocalZOrder(viewNode.tickRight:getLocalZOrder() + 2)
    viewNode.tickWrong:setLocalZOrder(viewNode.tickWrong:getLocalZOrder() + 2)
    viewNode.checkTickRight:setLocalZOrder(viewNode.checkTickRight:getLocalZOrder() + 2)
    viewNode.checkTickWrong:setLocalZOrder(viewNode.checkTickWrong:getLocalZOrder() + 2)
    
    function viewNode:setPhoneNumValid(bValid)
       self.tickRight:setVisible(bValid)
       self.tickWrong:setVisible(not bValid)
    end

    function viewNode:setCheckPhoneNumValid(bValid)
       self.checkTickRight:setVisible(bValid)
       self.checkTickWrong:setVisible(not bValid)
    end

    function viewNode:isCheckRight()
        return self.checkTickRight:isVisible() and self.tickRight:isVisible()
    end
end

return viewCreator