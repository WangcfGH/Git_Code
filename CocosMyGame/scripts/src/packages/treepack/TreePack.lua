
require('pack')

local function stringFillZeroR(value,length)
    value=value..string.char(0):rep(length-#value)
    return value
end

local function stringStripZeroR(data)
    data=data:gfind('[^%z]*')()
    return data
end

local parcelFunctionList={
    matrix2=function (value,length,target)
        assert(#target~=length.maxwidth,'')
        if(type(value)=='nil')then
            value={}
        end
        if(#value<length.maxwidth)then
            for i=#value+1,length.maxwidth do
                local item={}
                if(#item<length.maxlen)then
                    for j=#item+1,length.maxlen do
                        item[j]=0
                    end
                end
                value[i]=item
            end
        end


        for _,recode in ipairs(value) do
            for _,item in ipairs(recode) do
                target[#target+1]=item
            end
        end
    end
}
local function parcelComplexType(value,length,target)
    local func=parcelFunctionList[length.complexType]
    return func(value,length,target)
end

local parseFunctionList={
    matrix2=function (length,deDataMap,start)
        local deitem={}
        for recode=1,length.maxwidth do
            local temp={}
            for index=1,length.maxlen do
                temp[index]=deDataMap[start]
                start=start+1
            end
            deitem[recode]=temp
        end
        return deitem,start
    end
}

local function parseComplexType(length,dedata,start)
    local func=parseFunctionList[length.complexType]
    return func(length,dedata,start)
end

local function parcelExchMap(dataMap,exchMap,target)
    local lengthMap=exchMap.lengthMap
    local nameMap=exchMap.nameMap
    local target=target or {}
    local maxlen=lengthMap.maxlen
    for index = 1,maxlen do
        local name=nameMap[index]
        assert(name,'')
        local value=dataMap[name]
        local length=lengthMap[index]
        if(type(length)~='table')then
            if(length and length>0)then
                value=value or ''
                assert(type(value)=='string',string.format('type of value(%s %s=%s) should only be string',type(value),exchMap.nameMap[index],''..(value or '')))
                value=stringFillZeroR(value,length)
            end

            -- check value
            value=value or 0
            target[#target+1]=value
        elseif(length.complexType)then
            parcelComplexType(value,length,target)
        else
            for i = 1,length.maxlen do
                target[#target+1]=(value and value[i]) or 0
            end
        end
    end
    return target
end

local function parseExchMap(exchMap,deDataMap,start)
    local varMap={}
    local lengthMap=exchMap.lengthMap
    local nameMap=exchMap.nameMap
    local maxlen=lengthMap.maxlen
    local value,length,varname,deitem
    local start=start or 1
    for index = 1,maxlen do
        length=lengthMap[index]
        varname=nameMap[index]
        if(type(length)~='table') then
            deitem=deDataMap[start]
            if(type(deitem)=='string')then
                deitem=stringStripZeroR(deitem)
            end
            start=start+1
        elseif(length.complexType)then
            deitem,start=parseComplexType(length,deDataMap,start)
        else
            deitem={}
            for k = 1,length.maxlen do
                deitem[k]=deDataMap[start]
                start=start+1
            end

        end
        varMap[varname]=deitem
    end

    return varMap,start
end

parseFunctionList.link_refer=function(length,deDataMap,start)
    local deitem={}
    local exchMap=length.refered
    local maxwidth=length.maxwidth or 1
    local maxlen = length.maxlen or 1
    local deformatKey=exchMap.deformatKey
    local subDeDataMap
    for i=1,maxwidth do
        local temp={}
        for j=1,maxlen do
            temp[j],start=parseExchMap(exchMap,deDataMap,start)
        end
        deitem[i]=temp
    end

    if(length.maxwidth==nil)then
        deitem=deitem[1]
    end
    if(length.maxlen==nil)then
        deitem=deitem[1]
    end

    return deitem,start
end

parcelFunctionList.link_refer=function (value,length,target)

    if(value==nil)then
        value={}
        if(length.maxlen~=nil)then
            for i=1,length.maxlen do
                value[i]={}
            end
        end
    end

    local exchMap=length.refered
    local formatKey=exchMap.formatKey
    local data,dataList
    if(length.maxlen==nil)then
        value={value}
    else
        local _,test_value=next(value)
        if(type(test_value)~='table')then
            if(length.maxwidth==nil)then
                printError('unmatched type, need matrix1 at least')
            else
                printError('unmatched type, need matrix2 at least')
            end
            assert(false)
        end
    end
    
    if(length.maxwidth==nil)then
        value={value}
    else
        local _,test_value=next(value)
        if(type(test_value)~='table')then
            printError('unmatched type, need matrix2 at least')
            assert(false)
        end
    end

    for _,recode in ipairs(value) do
        for _,item in ipairs(recode) do
            assert(type(item)=='table', '')
            parcelExchMap(item,exchMap,target)
        end
    end
end

parseFunctionList.string_group=function(length,deDataMap,start)
    local deitem={}
    local maxwidth=length.maxwidth or 1
    local maxlen = length.maxlen or 1
    for i=1,maxwidth do
        deitem[i]=stringStripZeroR(deDataMap[start],maxlen)
        start=start+1
    end
    
    return deitem,start
end

parcelFunctionList.string_group=function (value,length,target)
    if(value==nil)then
        value={}
    end
    local varwidth=length.maxwidth or 1
    for i=#value+1,varwidth do
        value[i]=value[i] or ''
    end
    local varlength=length.maxlen or 1
    local v
    for i=1,varwidth do
        v=value[i]
        assert(type(v)=='string','')
        v=stringFillZeroR(v,varlength)
        target[#target+1]=v
    end
end

local function tree_pack(dataMap,exchMap)
    if(DEBUG==0)then
        if(not (dataMap and exchMap and exchMap.formatKey))then
            return nil
        end
    else
        assert(dataMap and exchMap and exchMap.formatKey,'')
    end
    
    local dataList=parcelExchMap(dataMap,exchMap)
    local data = string.pack(exchMap.formatKey, unpack(dataList))
    return data
end

local function parcelAndWrite(dataMap, exchMap, dataListTotal, formatKeyTotal)
    if not (dataMap and exchMap and dataListTotal and formatKeyTotal) then return end

    local dataListTotalTemp = dataListTotal
    local formatKeyTotalTemp = formatKeyTotal

    local dataList=parcelExchMap(dataMap, exchMap)
            
    for i=1, #dataList do
        dataListTotalTemp[#dataListTotalTemp + 1] = dataList[i]
    end
    formatKeyTotalTemp = formatKeyTotalTemp..string.sub(exchMap.formatKey, 2)

    return dataListTotalTemp, formatKeyTotalTemp
end

local function tree_packs(...)
    local treeData = {}
    for i, v in ipairs{...}  do
        treeData[#treeData + 1] = v
    end
    
    local dataListTotal = {}
    local formatKeyTotal = ""

    for i=1, #treeData do
        if not treeData[i] then break end

        local dataMaps   = treeData[i][1]
        local exchMap   = treeData[i][2]
        local count     = treeData[i][3]
        
        if dataMaps and exchMap then
            if(DEBUG==0)then
                if(not (dataMaps and exchMap))then
                    return nil
                end
            else
                assert(dataMaps and exchMap,'')
            end

            if not (type(count) == 'number' and count > 1) then
                count = 1
            end

            if count==1 then
                dataListTotal, formatKeyTotal = parcelAndWrite(dataMaps, exchMap, dataListTotal, formatKeyTotal)
            else
                for j=1, #dataMaps do
                    dataListTotal, formatKeyTotal = parcelAndWrite(dataMaps[j], exchMap, dataListTotal, formatKeyTotal)
                end
            end        
        end
    end

    local data = string.pack(formatKeyTotal, unpack(dataListTotal))
    return data
end

local function getData(rest,...)
    return {...}
end

local function parseExchMap(exchMap,dedata)
    local varMap={}
    local lengthMap=exchMap.lengthMap
    local nameMap=exchMap.nameMap
    local maxlen=lengthMap.maxlen
    local value,length,varname,deitem
    local start=1
    for index = 1,maxlen do
        length=lengthMap[index]
        varname=nameMap[index]
        if(type(length)~='table') then
            deitem=dedata[start]
            if(type(deitem)=='string')then
                deitem=stringStripZeroR(deitem)
            end
            start=start+1
        elseif(length.complexType)then
            deitem,start=parseComplexType(length,dedata,start)
        else
            deitem={}
            for k = 1,length.maxlen do
                deitem[k]=dedata[start]
                start=start+1
            end

        end
        varMap[varname]=deitem
    end

    return varMap
end

local function parseExchMap_array(exchMap, dedata, count)
    local array         = {}
    local maxsize       = exchMap.maxsize
    local lengthMap     = exchMap.lengthMap
    local nameMap       = exchMap.nameMap
    local maxlen        = lengthMap.maxlen
    local start     = 1
    for arrayIndex = 0, count - 1 do 
        local varMap    = {}
        local value, length, varname, deitem
        for index = 1, maxlen do
            length  = lengthMap[index]
            varname = nameMap[index]
            if(type(length)~='table') then
                deitem=dedata[start]
                if(type(deitem)=='string')then
                    deitem=stringStripZeroR(deitem)
                end
                start=start+1
            elseif(length.complexType)then
                deitem,start=parseComplexType(length, dedata, start)
            else
                deitem = {}
                for k = 1,length.maxlen do
                    deitem[k]=dedata[start]
                    start=start+1
                end

            end
            varMap[varname]=deitem
        end
        table.insert(array, varMap)
    end
    return array
end

local function tree_unpack(data,exchMap)
    if(DEBUG==0)then
        if(not (data and exchMap))then
            return nil
        end
    else
        assert(data and exchMap,'')
    end
    
    local deformatKey=exchMap.deformatKey
    local dedata=getData(string.unpack(data,deformatKey))

    return parseExchMap(exchMap,dedata)
end

local function unpackArray(data, count, exchMap)
    -- local deformatKey = exchMap.deformatKey:sub(2)
    -- deformatKey = "<"..deformatKey:rep(count)
    -- local dedata=getData(string.unpack(data,deformatKey))
    -- return parseExchMap_array(exchMap, dedata, count)
    local array = {}
    local size = exchMap.maxsize
    for i = 1, count do
        table.insert(array, tree_unpack(data:sub(size * i - size + 1 , size * i), exchMap))
    end
    return array
end

local function tree_unpacks(data, ...)
    -- unpacks多个结构体格式解包unpacks(pData, exchMap, {exchMap}, {exchMap, 1}, {exchMap, 2}), 返回一个table, table[1], table[2], table[2][1], table[2][2]
    -- 示例: 服务端数据pData, 结构顺序structA, structB, structB, structC
    -- data1, data2, data3 = treePack.unpacks(pData, {structA, 1}, {structB, 2}, {structC, 1}},		--其中{structA, 1}, {structC, 1}可简写成{structA} 或者 structC
    local exchMaps = { }
    for i, v in ipairs { ...} do
        exchMaps[#exchMaps + 1] = v
    end
    
    local dataMaps = {}
    local dataTemp = data
    for i=1, #exchMaps do
        if not exchMaps[i] then break end

        local exchMap   = exchMaps[i][1]
        local count     = exchMaps[i][2]

        if not exchMap then
            exchMap = exchMaps[i]
            count   = 1
        end
        if not (type(count) == 'number' and count > 1) then
            count = 1
        end

        dataMaps[#dataMaps + 1] = {}
        for k=1, count do
            dataMaps[#dataMaps][k] = tree_unpack(dataTemp, exchMap)
            
            dataTemp = string.sub(dataTemp, exchMap.maxsize + 1)
        end
    end

    return unpack(dataMaps)
end

local function align(data,alignSize)
    if(DEBUG==0)then
        if(not data)then
            return nil
        end
    else
        assert(data,'')
    end
    
    local alignSize=(alignSize and checknumber(alignSize)) or 4
    local n=alignSize-math.fmod(#data,alignSize)
    n=(n==4 and 0) or n
    printInfo('align data size from %d to %d',#data,#data+n)
    data=data..string.char(0):rep(n)
    return data
end

local function tree_pack_and_aligned(dataMap,exchMap,alignSize)
    local data=tree_pack(dataMap,exchMap)
    return align(data,alignSize)
end

local function tree_pack_and_aligneds(...)
    --alignpacks打包多个结构体, alignpacks({dataMap, exchMap}, {dataMap, exchMap, 1}, {dataMap, exchMap, 2})
    --({dataMap, exchMap, count}, ...) count>1时, dataMap必须是table, count=1时可省略
    --	示例 (table1 结构structA),  (table2 结构structB), (table2 结构structB), (table3 结构structC)
    --	local data = treepack.alignpacks({table1, structA, 1}, {table2, structB, 2}, {table3, structC, 1})	--其中{table1, structA, 1}, {table3, structC, 1}的1可省略
    local data=tree_packs(...)
    return align(data,alignSize)
end

local function tree_pack_warning(...)
    printError('%s','pack data without aligned')
    return tree_pack(...)
end

local _treepack={
    pack=tree_pack_warning,
    unpack=tree_unpack,
    unpacks=tree_unpacks,
    alignpack=tree_pack_and_aligned,
    alignpacks=tree_pack_and_aligneds,
    align=align,
    parseListWithInfoHead=parseListWithInfoHead,
    unpackArray=unpackArray
}

return _treepack

