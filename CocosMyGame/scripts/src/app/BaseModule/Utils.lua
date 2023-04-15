--[Comment]
--将dataList拼成"key1=value1&key2=value2"形式的字符串     
local function convertParamsToUrlStyle(dataList)
	local varNameList={}
	local targetNameList={}
	for k,v in pairs(dataList) do
		varNameList[#varNameList+1] =k
		targetNameList[#targetNameList+1] =string.urlencode(tostring(v))
	end
	local exchFormatStringIn = table.concat(varNameList,'=%s&')..'=%s'
	local datastring=exchFormatStringIn:format(unpack(targetNameList))
	return datastring
end

my.convertParamsToUrlStyle=convertParamsToUrlStyle
--代码评审 杨美玲 整理到单独的文件
function my.md5(str)
	return MCCrypto:md5(str,str:len())
end
                                  
--代码评审 杨美玲 
my.MCCharset={}
local mccharset=MCCharset:getInstance()   
function my.MCCharset.gb2Utf8String(s,len)
	return mccharset:gb2Utf8String(s,len or s:len())
end
  
--[Comment]
-- URL 编码,
-- 这种编码将一些特殊字符（比  '=' '&' '+'）转换为"%XX"形式的编码，
-- XX是字符的16进制表示，空白为'+'。
-- 如，将"a+b = c"  编码为 "a%2Bb+%3D+c" 
function cc.exports.urlescape (s)
	s = string.gsub(s, "([&=+%c])", function (c)
		return string.format("%%%02X", string.byte(c))
	end)
	s = string.gsub(s, " ", "+")
	return s
end

function my.extractInfo(str,reg)
	assert(str,'')
	local tmpList={}
	for shortline in string.gfind(str,reg) do
		table.insert(tmpList,shortline)
	end

	local tmp=table.concat(tmpList)
	return tmp
end

function my.makeLong(a,b)
	return bit.bor(
		bit.band(checkint(a,0xffff)),
		bit.lshift(bit.band(checkint(b),0xffff),16)
	)
end

function my.splitStringByLen(gbkMsg,len)
	assert(gbkMsg,'')
	len=checkint(len)-1

	local msgList={}
	local curPos=1
	local endPos=1

	while(endPos<=gbkMsg:len()-len) do
		local count=0
		local i=curPos
		while(i<curPos+len)do
			if(gbkMsg:byte(i)<128)then
				count=count+1
			else
				i=i+1
			end
			i=i+1
		end
		endPos=i-1
		msgList[#msgList+1]=gbkMsg:sub(curPos,endPos)
		curPos=endPos+1

	end

	msgList[#msgList+1]=gbkMsg:sub(curPos)

	return msgList
end

function my.utfstrlen(str)
    if str == nil or str == "" then
        return 0
    end

	local len = #str
	local left = len
	local cnt = 0
	local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
	while left ~= 0 do
		local tmp=string.byte(str,-left)
		local i=#arr
		while arr[i] do
			if tmp>=arr[i] then 
                left=left-i
                break
            end
			i=i-1
		end
		cnt=cnt+1
	end
	return cnt
end