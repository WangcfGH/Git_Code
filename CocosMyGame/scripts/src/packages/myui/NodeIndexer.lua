
local function parseExchangeMap(exchMap,dest,option)
	if(exchMap==nil)then
		return {}
	end

	assert(type(dest)=='table','dest is not table')
	dest=dest or {}
	option=(option and clone(option)) or {}
	local exchoption=exchMap._option or {}

	local prefix=(option.prefix or '')..(exchoption.prefix or '')
	local suffix=(exchoption.suffix or '')..(option.suffix or '')
	option.prefix=prefix
	option.suffix=suffix

	exchMap._option=nil
	for k,v in pairs(exchMap)do
		if(type(v)=='string')then
			dest[k]=prefix..v..suffix
		elseif(type(v)=='table')then
			parseExchangeMap(v,dest,option)
		end
	end
	exchMap._option=exchoption

	return dest
end

local _nodeIndexerAliveSpace={}
setmetatable(_nodeIndexerAliveSpace,{__mode='k'})
local function NodeIndexer(node,orgMap)

	if(node._realnode)then
		return node
	end

	local aliveIndexer=_nodeIndexerAliveSpace[node]
	if(aliveIndexer)then
		return aliveIndexer
	end

	local exchangeMap={}
	exchangeMap=parseExchangeMap(orgMap,exchangeMap)

	local indexer={
		_realnode={node},
		_exchange=exchangeMap or {},
	}
	setmetatable(indexer._realnode,{__mode='kv'})

	_nodeIndexerAliveSpace[node]=indexer

	function indexer:getRealNode()
		return rawget(self,'_realnode')[1]
	end

	function indexer:getExchangeMap()
		return self._exchange
	end

	function indexer:parseChildren( ... )
		-- body
		local ret = {}
		for _,v in pairs(names) do
			ret[v]=self[v]
		end
		return ret
	end

	if(node.getParent)then
		function indexer:getParent()
			local parent = self:getRealNode():getParent()
			if parent then
				return NodeIndexer(self:getRealNode():getParent())
			end
			return nil
		end
	end

	setmetatable(indexer,{
		_cname=DEBUG>0 and 'NodeIndexer',
		__index=function (t,key)
			local root=t:getRealNode()
			local exchange=rawget(t,'_exchange')

			local v=root[key]
			if(v)then
				if(type(v)=='function')then
					return function (self,...)
						return v(self:getRealNode() ,...)
					end
				else
					return v
				end
			end

			local childnode
			local indexer
			indexer=rawget(t,'_realnode')[key]
			if(indexer)then
				return indexer
			end

			local realkey=nil
			if(type(exchange)=='table')then
				realkey=exchange[key]
			end

			if(realkey)then
				--return t[realkey]
				childnode=root
				for realchildname in realkey:gmatch('[^.]+') do
					childnode=childnode:getChildByName(realchildname)
                    if childnode == nil then break end
				end
				if(childnode)then
					indexer=NodeIndexer(childnode)
					indexer._realname=key
					indexer._realresname=realkey
					rawget(t,'_realnode')[key]=indexer
					return indexer
				end

			end

			local node=root:getChildByName(key)
			if(node)then
				indexer=NodeIndexer(node)
				indexer._realname=key
				return indexer
			end

			return nil
		end
	})
	return indexer
end

function my.NodeIndexer(node,orgMap)
	return NodeIndexer(node,orgMap)
end

return NodeIndexer
