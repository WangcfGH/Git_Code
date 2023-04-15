local AutoSupplyView = cc.load('ViewAdapter'):create()

AutoSupplyView.viewConfig={
	"res/hallcocosstudio/AutoSupply/AutoSupply.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option = {prefix ='Panel_Main.Panel_Animation.'},
            
            TextSafeBox  = "Value_Safebox",
            PanelEdit = "Panel_Edit",
            imgEditBox ='Panel_Edit.Img_Bg',
            depositAmoutInp ='Panel_Edit.TextField_Input',
            TextExplain = "Text_Explain",
            TextExplain1 = "Text_Explain_1",
            ImgTitleBg = "Img_TitleBg",
            ImgTitleBg1 = "Img_TitleBg_1",
            TextSupplyDeposit = "Text_SupplyDeposit",
            BtnAutoSupply = "Btn_AutoSupply",
            BtnPlus = "Btn_Plus",
            BtnMinus = "Btn_Minus",
            ImgBubble = "Img_Bubble",
        }
    }
}

function AutoSupplyView:onCreateView(viewNode)
--    viewNode.depositAmoutInp:setTouchAreaEnabled(false)
--    local depositAmoutInp=viewNode.depositAmoutInp
--    local imageView=viewNode.imgEditBox
--    local image='./images/Hall_Box_EditBox.png'
--    my.fixTextField(viewNode,'depositAmoutInp',imageView,image)
--    viewNode.depositAmoutInp:setPositionX(viewNode.depositAmoutInp:getPositionX() + 8)
--    viewNode.depositAmoutInp:setPositionY(viewNode.depositAmoutInp:getPositionY() + 7)
end

return AutoSupplyView

