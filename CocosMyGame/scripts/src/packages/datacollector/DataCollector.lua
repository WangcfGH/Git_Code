
local dataSourceList={}

local DataCollector=class('DataCollector')

my.addInstance(DataCollector)

function DataCollector:ctor( ... )
	-- body
	self._indexTables={}
	self._realnameTable={}

	for k,dataSource in ipairs(dataSourceList) do
		self:addIndex(dataSource)
	end
end

function DataCollector:select(varname)
	local value
	for k,v in ipairs(self._indexTables) do
		if(v[varname])then
			value=v[varname]
			break
		end
	end
	return value
end

--input pure name list
--output vardata map
function DataCollector:convert(varNameArrayIn)
	-- body
	local varDataMapIn={}
	for _,name in ipairs(varNameArrayIn) do
		varDataMapIn[name]=self:select(name)
	end
	return varDataMapIn
end

function DataCollector:registVar(varname,host,realname)

end

function DataCollector:addIndex(indexTable)
	table.insert(self._indexTables,1,indexTable)
end

function DataCollector:removeIndex(indexTable)
	table.removebyvalue(self._indexTables,indexTable,true)
end

return DataCollector
