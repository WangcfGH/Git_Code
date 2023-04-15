
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/relief/relief.csb',
	{
		_option={prefix='Panel_Relief.'},
		closeBt='Btn_Close',
		takeBt='Btn_TakeRelief',
		buyBt='Btn_Buy',
		videoadTip = 'Panel_VideoAdReliefTip',
		boxPanel='Panel_Box',
		{
			_option={prefix='Panel_Box.'},
			itemBox1='Item_Box1',
			{
				_option={prefix='Item_Box1.'},
				itemCountTxt1='Text_Count'
			},
			itemBox2='Item_Box2',
			{
				_option={prefix='Item_Box2.'},
				tip2Txt='Text_Tip',
				itemCountTxt2='Text_Count'
			},
			itemBox3='Item_Box3',
			{
				_option={prefix='Item_Box3.'},
				tip3Txt='Text_Tip',
				itemCountTxt3='Text_Count'
			},
		},
		buyTipTxt='Btn_Buy.BitmapFontLabel_1',
		countTipTxt='Text_Count_Tip',
        extraCountTipTxt='Text_ExtraCount_Tip',
	}
}

function viewCreator:onCreateView(viewNode)
	function viewNode:refreshInfo(videoAdRelief, reliefCount, nobilityLevel, nobilityCount, bNobilityVisible, reliefShopPrice, reliefSilver, buyExtraSilver)
		viewNode.itemCountTxt1:setString("银子x"..reliefSilver)

		viewNode.tip2Txt:setString(reliefShopPrice.."元即得")
		viewNode.itemCountTxt2:setString("银子x"..buyExtraSilver)
		
		if videoAdRelief then
			viewNode.videoadTip:setVisible(true)
			viewNode.countTipTxt:setVisible(false)
			viewNode.extraCountTipTxt:setVisible(false)
			viewNode.takeBt:loadTextureNormal('hallcocosstudio/images/plist/PromptRelief/TakeBtn_VideoAD.png', ccui.TextureResType.plistType)
		else
			viewNode.videoadTip:setVisible(false)
			viewNode.countTipTxt:setVisible(true)
			viewNode.takeBt:loadTextureNormal('hallcocosstudio/images/plist/PromptRelief/TakeBtn.png', ccui.TextureResType.plistType)

			local str = "每日可领"..reliefCount.."次"
			if nobilityLevel and nobilityCount and bNobilityVisible then 
				str = str .. ','
			end
			viewNode.countTipTxt:setString(str)
			viewNode.extraCountTipTxt:setVisible(bNobilityVisible)
			if nobilityLevel and nobilityCount  then
				if bNobilityVisible then
					viewNode.extraCountTipTxt:setString("贵族"..nobilityLevel.."提升至"..nobilityCount.."次")
				end
			end
			if bNobilityVisible then  
				viewNode.countTipTxt:setPositionX(663.18)
			else
				viewNode.countTipTxt:setPositionX(748.91)
			end
		end
		

		
		viewNode.buyTipTxt:setString(reliefShopPrice.."·元全部领取")
    end
end

return viewCreator
