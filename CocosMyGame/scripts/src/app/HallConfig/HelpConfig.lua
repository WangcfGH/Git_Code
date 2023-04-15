
local TitleIndexList={
    FEEDBACK=1,
    GAMERULE=2,
    FAQ=3,
    ABOUT=4,
}

local UrlList={
	[TitleIndexList.GAMERULE]='res/hall/webpages/help/GameRules.html',
	[TitleIndexList.FAQ]='res/hall/webpages/help/FAQ.html',
	[TitleIndexList.ABOUT]='res/hall/webpages/help/About.html',
}

local UseRuleDescription = true

return {
	titleIndexList=TitleIndexList,
	urlList=UrlList,
	useRuleDescription=UseRuleDescription
}
