--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TreePack= import("src.packages.treepack.TreePack")

--------------------------------
-- @function [parent=#] parseListWithInfoHead
-- @param binary data
-- @param head{struct,length=struct_length}
-- @param unit{struct,length=struct_length}
-- @return {headMap,unitList}
local function parseListWithInfoHead(data,head,unit)
	local headMap=TreePack.unpack(data,head.struct)

	local unitsData=data:sub(head.length+1)
	local function getUnit(index)
		if(index*unit.length>unitsData:len())then
			return nil
		end
		local unitData=unitsData:sub(unit.length*(index-1)+1,unit.length*index)
		local unitMap=TreePack.unpack(unitData,unit.struct)
		return unitMap
	end

	local unitsList={}
	local iter=0
	for unit in function() iter=iter+1;return getUnit(iter) end do
		table.insert(unitsList,unit)
	end

	return {headMap,unitsList}
end

local function  resolveReference(ss,...)
	local ssl = {...}
    	table.insert(ssl, 1, ss)
	local lengthMap,refered_struct
	for name,tstruct in pairs(ss) do
		lengthMap=tstruct.lengthMap
		if type(lengthMap) == "table" then
			for index,value in pairs(lengthMap) do
				if(type(value)=='table' 
					and value.complexType and value.complexType=='link_refer' 
					and type(value.refered)=='string'
				)then
					local refer_name=value.refered
					for _,sst in ipairs(ssl) do
						refered_struct=sst[refer_name]
						if(refered_struct)then
							break
						end
					end
					assert(refered_struct~=nil,'struct '..value.refered..' dosen\'t exist')
					value.refered=refered_struct
				end
			end
		end
	end
end

--[Comment]
--只需要带去掉头部后的有效字符串，内容理论上是（count1 + struct1*count1）+ （count2 + struct2*count2）+...
local function parseAsCountStruct(data, ...)
	local tick = socket.gettime()
	if not (type(data) == "string" and string.len(data) > 0) then
		return {}
	end
	local structs = {...}
	local ret = {}
	for _, struct in ipairs(structs) do
		local _, count = string.unpack(data, "<i")
		data = data:sub(5)
		-- local subResult = {}
		-- for index = 1, count do
		-- 	table.insert(subResult, TreePack.unpack(data, struct))
		-- 	data = data:sub(struct.maxsize + 1)
		-- end
		-- table.insert(ret, subResult)
		table.insert(ret, TreePack.unpackArray(data, count, struct))
		data = data:sub(struct.maxsize * count + 1)
	end
	print("parseAsCountStruct", socket.gettime()-tick)
	--扣玩家币start--
    if string.len(data) > 0 then
        table.insert(ret, data)
    end
	--扣玩家币end--
	return unpack(ret)
end

local function parseAsHeadCountStruct(data, headStruct, ... )
	local head = TreePack.unpack(data, headStruct)
	return head, parseAsCountStruct(data:sub(headStruct.maxsize + 1), ...)
end

local _M = {
	parseListWithInfoHead = parseListWithInfoHead,
	resolveReference=resolveReference,
	parseAsCountStruct=parseAsCountStruct,
	parseAsHeadCountStruct=parseAsHeadCountStruct
}

return _M
