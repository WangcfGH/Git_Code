
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/safebox/safeboxpassword.csb',
	{
		_option={prefix='Img_MainBox.'},
		cancelBt='Btn_Cancel',
		sureBt='Btn_Confirm',
		pswInp='Img_EditBox.TextField_EditPassword',
	}
}

function viewCreator:onCreateView(viewNode)
    my.fixTextField(viewNode,'pswInp',viewNode.pswInp,'res/hallcocosstudio/images/box5_shuru_pic.png',cc.c3b(161, 72, 22))
end

return viewCreator
