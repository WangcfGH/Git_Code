
local TitleRadio=class('TitleRadio',cc.load('myui').Radio)

function TitleRadio:ctor(params)

	local host=params.host
	local radioList={}

	if(params.nodelist)then
		for k,v in pairs(params.nodelist) do
			radioList[k]=(host and host[v]) or v
		end
	end

	local radioNamePrefix=params.name
	if(radioNamePrefix)then
		local i=1
		local name=radioNamePrefix..i
		local target=host and host[name]
		while(target)do
			radioList[#radioList+1]=target
			i=i+1
			name=radioNamePrefix..i
			target=host[name]
		end
	end

	if(#radioList==0)then
		printError('radio list is empty','')
		assert(false,'')
	end

	local default=params.default or 1
	TitleRadio.super.ctor(
		self,
		radioList,
		default
	)

	self._imagePrefix=params.image
	local selected,defaultIndex=self:getSelected()
--	selected:getParent()[self._imagePrefix..defaultIndex]:setVisible(true)

	self:_setDefaultStyle(radioList)

end

function TitleRadio:_setDefaultStyle(radioList)

	for _,v in pairs(radioList) do
		v:onTouch(function(e)
			if(e.name=='began' and e.target:isSelected()==false)then
				e.target:setScale(1.0)
			elseif(e.name=='ended' or e.name=='cancelled')then
				e.target:setScale(1.0)
			end
		end)
	end

	return self
end

function TitleRadio:onClick(callback)
	local imagePrefix=self._imagePrefix
	TitleRadio.super.onClick(self,function (e)
		if(imagePrefix)then
--			e.last:getParent()[imagePrefix..e.lastIndex]:setVisible(false)
--			e.target:getParent()[imagePrefix..e.index]:setVisible(true)
		else
			printInfo('image prefix is nil')
		end
		callback(e)
	end)
end

return TitleRadio
