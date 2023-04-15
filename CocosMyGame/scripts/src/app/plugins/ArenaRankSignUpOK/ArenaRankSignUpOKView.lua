local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/ArenaRank/ArenaRankGroupSignUpOK.csb',
	{
        bottomPanel = "Panel_Bottom",
        theBkList = 'Image_Bk',
	}
}

return viewCreator