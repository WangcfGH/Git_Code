local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/GratitudeRepay/GratitudeRepay.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
				imgBg = 'Image_Bg',
				titleAniNode = 'TitleAniNode',
				panelItem1 = 'Panel_Item1',
				{
					_option={prefix='Panel_Item1.'},
					imgSelect1 = 'Img_Select',
					imgRationBg1 = 'Img_RatioBg',
                    txtRatioValue1 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver1 = 'Img_Sliver',                    
					txtSliver1 = 'Text_Sliver',
					itemAniNode1 = 'ItemAniNode',
				},
				panelItem2 = 'Panel_Item2',
				{
					_option={prefix='Panel_Item2.'},
					imgSelect2 = 'Img_Select',
					imgRationBg2 = 'Img_RatioBg',
                    txtRatioValue2 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver2 = 'Img_Sliver',                    
					txtSliver2 = 'Text_Sliver',
					itemAniNode2 = 'ItemAniNode',
				},
				panelItem3 = 'Panel_Item3',
				{
					_option={prefix='Panel_Item3.'},
					imgSelect3 = 'Img_Select',
					imgRationBg3 = 'Img_RatioBg',
                    txtRatioValue3 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver3 = 'Img_Sliver',                    
					txtSliver3 = 'Text_Sliver',
					itemAniNode3 = 'ItemAniNode',
				},
                panelItem4 = 'Panel_Item4',
				{
					_option={prefix='Panel_Item4.'},
					imgSelect4 = 'Img_Select',
					imgRationBg4 = 'Img_RatioBg',
                    txtRatioValue4 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver4 = 'Img_Sliver',                    
					txtSliver4 = 'Text_Sliver',
					itemAniNode4 = 'ItemAniNode',
				},
                panelItem5 = 'Panel_Item5',
				{
					_option={prefix='Panel_Item5.'},
					imgSelect5 = 'Img_Select',
					imgRationBg5 = 'Img_RatioBg',
                    txtRatioValue5 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver5 = 'Img_Sliver',                    
					txtSliver5 = 'Text_Sliver',
					itemAniNode5 = 'ItemAniNode',
				},
                panelItem6 = 'Panel_Item6',
				{
					_option={prefix='Panel_Item6.'},
					imgSelect6 = 'Img_Select',
					imgRationBg6 = 'Img_RatioBg',
                    txtRatioValue6 = 'Img_RatioBg.Text_RatioValue',
                    imgSliver6 = 'Img_Sliver',                    
					txtSliver6 = 'Text_Sliver',
					itemAniNode6 = 'ItemAniNode',
				},
				txtBaseSliver = 'Text_BaseSliver',
				openDateAniNode = 'OpenDateAniNode',
				{
					_option={prefix='OpenDateAniNode.'},
					txtOpenDate ='pao_9.Text_OpenDateValue',
				},
				enterAniNode = 'EnterAniNode',
				enterSpineNode = 'EnterSpineNode',
				btnLotteryOneOnly = 'Btn_LotteryOneOnly',
                txtLotteryOneOnly = 'Btn_LotteryOneOnly.Text_PriceOne',
                btnLotteryOne = 'Btn_LotteryOne',
                txtLotteryOne = 'Btn_LotteryOne.Text_PriceOne',
                btnLotteryMult = 'Btn_LotteryMult',
				btnMultAni = 'Btn_LotteryMult.BtnMultAni',
                txtLotteryMult = 'Btn_LotteryMult.Text_PriceMult',
                txtRemainCount = 'Text_RemainCount',
	            btnClose ='Btn_Close',
			},
			helpBt='Btn_Help',
		},
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator