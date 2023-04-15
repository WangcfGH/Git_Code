
local Radio=class('Radio')

function Radio:ctor(checkboxList,selected)

	self._checkboxList=clone(checkboxList)

	if(type(selected)=='number' or type(selected)=='string')then
		selected=checkboxList[selected]
	end

	self._indexList={}
	setmetatable(self._indexList,{__mode='k'})
	for k,item in pairs(self._checkboxList) do
		self._indexList[item]=k
		if(item.getRealNode)then
			item=item:getRealNode()
			self._indexList[item]=k
		end
		item:setSelected(false)
	end

	self._selected=selected
	self:_setSelected(self._selected,true)

	for _,item in pairs(self._checkboxList) do
		item:onEvent(handler(self,self._onSelect))

		if(item.getRealNode)then
			local item=item:getRealNode()
			function item:onClick(callback)
				self._onSelectedCallback=callback
			end
		end

	end
end

function Radio:_setSelected(selected,statu)
	if(self._checkboxList==nil or #self._checkboxList <= 0 or selected==nil )then
		return
	end
	self._selected=selected
	self._selected:setSelected(statu)
end

function Radio:getSelected( ... )
	local selected = self._selected
	local getRealNode = selected.getRealNode
	local indexNode = (getRealNode and getRealNode(selected)) or selected
	return selected,self._indexList[indexNode]
end

function Radio:select(selected)
	local index=self._indexList[selected]
	if(index==nil)then
		return
	end
	selected=self._checkboxList[index]

	local lastSelected=self._selected
	local lastRealNode=(lastSelected.getRealNode and lastSelected:getRealNode()) or lastSelected
	local lastIndex=self._indexList[lastRealNode]
	self:_setSelected(self._selected,false)
	self:_setSelected(selected,true)

	--select failed
	if(self._selected~=selected)then
		return
	end

	local e={
		name='selected',
		index=index,
		target=selected,
		last=lastSelected,
		lastIndex=lastIndex,
	}
	printInfo(e.target)
	printInfo('(index %d) on Radio %s',e.index,e.name)
	if(self._callback)then
		self._callback(e)
	end

	if(true)then
		local e = clone(e)
		e.selected=e.target
		if(e.last._onSelectedCallback)then
			e.isselected=false
			e.target=e.last
			e.last:_onSelectedCallback(e)
		end
		if(e.selected._onSelectedCallback)then
			e.isselected=true
			e.target=e.selected
			e.selected:_onSelectedCallback(e)
		end
	end

	return self
end

function Radio:onClick(handler)
	self._callback=handler
	return self
end

function Radio:_onSelect( e )
	if(e.name=='selected')then
		self:select(e.target)
	elseif(e.name=='unselected')then
		e.target:setSelected(true)
	end

end

return Radio
