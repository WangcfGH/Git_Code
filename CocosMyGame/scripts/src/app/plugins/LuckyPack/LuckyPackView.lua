local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/LuckyPack/LuckyPack.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
				nodeHbbg ='node_hbbg',
				{
					_option={prefix='node_hbbg.'},
					btnClose ='Btn_Close',
					btnBuy = 'but.btn_buy',
					imgChouJi = 'but.btn_buy.chouquhongb_21',
					txtBuyyed = 'but.btn_buy.Txt_Buyyed',
					panelCancelLine = 'but.btn_buy.Panel_CancelLine',
					txtOriginalPrice = 'but.btn_buy.Txt_OriginalPrice',
					txtSpecialPrice = 'but.btn_buy.Txt_SpecialPrice',
					imgTitleBuy = 'bg.pmddt_21.gxhd_22',
					txtTitleOpen1 = 'bg.pmddt_21.Txt_1',
					txtTitleOpen2 = 'bg.pmddt_21.Txt_2',
					txtTitleOpen3 = 'bg.pmddt_21.Txt_3',
					imgXylb = 'bg.xyhb_20',
					imgCjlb = 'bg.xyhb_21',
				},
				nodeBg ='node_hb',
				imgGx = 'img_gx',
				txtLotterySiliver = 'txt_LotterySiliver',
				imDiscount = 'Img_Discount',
				{
					_option={prefix='Img_Discount.'},
					txtDiscount = 'Txt_Discount',					
				},
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator