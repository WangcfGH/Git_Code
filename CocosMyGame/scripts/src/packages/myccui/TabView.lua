
local TitleRadio = import('.TitleRadio')
local TabView = class('TabView')

-- params:
--
-- host
-- name
-- image
-- defalut
-- pageList
-- titleList
-- titles
--
-- @function bind titles with pages
function TabView:ctor(params)
	-- body
	self._pageList=params.pageList
	assert(#self._pageList>=1,'length of TabView params.pageList < 1')
	-- current page
	local curPage = params.default
	if(type(curPage)=='table' and curPage.setVisible)then
		curPage=table.keyof(params.pageList,curPage)
	end
	params.default=curPage
	curPage=params.pageList[curPage]
	self._curPage=curPage
	assert(self._curPage.setVisible,'current page incompatible')
	self._curPage:setVisible(true)
	local titleRadio= params.titles or TitleRadio:create(params)
	titleRadio:onClick(handler(self,self._onPageSelected))
end

function TabView:_onPageSelected(e)
	self._curPage:setVisible(false)
	self._curPage=self._pageList[e.index]
	self._curPage:setVisible(true)

	local callback=self._callback
	if(callback)then
		callback(e)
	end
end

function TabView:onClick(handler)
	self._callback=handler
	return self
end

TabView.noneview={
	setVisible=function (visible)
		
	end
}

return TabView
