
local matrix2=class('DynamicMatrix2')

function matrix2.foreachBySecondKey(data,key,handler)
	local value
	for _,bindList in pairs(data) do
		value=bindList[key]
		handler(value,handler)
	end
end

function matrix2:create()

	local data={}
	setmetatable(data,{__index=function(t,k)
		-- if not exist, then set value as new table for the key
		if(rawget(t,k)==nil)then
			rawset(t,k,{})
		end
		return rawget(t,k)
	end})
	return data
	
end


return matrix2
