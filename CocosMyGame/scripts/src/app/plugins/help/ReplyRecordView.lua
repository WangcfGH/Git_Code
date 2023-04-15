
local viewCreator=clone(require('src.app.plugins.help.QuestRecordView'))

viewCreator.viewConfig={
	'res/hallcocosstudio/help/replymsg.csb',
	{
		{
			_option={
				prefix='Img_ChatPapo.'
			},
			msgTxt='Text_Chat',
		},
		timeTxt='Text_Date',
		bottomNode='Img_IconSevice',
		topNode='Img_ChatPapo',
	}
}

return viewCreator
