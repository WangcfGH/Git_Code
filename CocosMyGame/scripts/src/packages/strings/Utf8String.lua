-- @param str
-- @return number
local function dump(input)
  if type(input) == "table" then
    print("{")
    for i = 1, #input do
      dump(input[i])
    end
    print("}")
  else
    print(input)
  end
end

local function transPosition(first, last, strLen)
  local function transer(input)
    local output = 1
    if not input or type(input) ~= "number" then
      return strLen
    elseif input < 0 then
      output = strLen + input + 1
    elseif input > strLen then
      output = strLen
    else
      output = input
    end
    return output
  end
  local function pairCheck(first, last, extra)
    local exchangeTable = {
      [true] = {
        first, last
      },
      [false] = {
        [true] = {
          1, first
        },
        [false] = {
          first, strLen
        }
      }
    }
    local table = (exchangeTable[last>first] and exchangeTable[last>first][extra]) or exchangeTable[last>first]
    return table[1], table[2]
  end
  return pairCheck(transer(first), transer(last), first > 0)
end

local function stringCharByTable(byteTable)
  local len = #byteTable
  local stringChar = {
    [1] = function() return string.char(byteTable[1]) end;
    [2] = function() return string.char(byteTable[2], byteTable[1]) end;
    [3] = function() return string.char(byteTable[3], byteTable[2], byteTable[1]) end;
    [4] = function() return string.char(byteTable[4], byteTable[3], byteTable[2], byteTable[1]) end;
    [5] = function() return string.char(byteTable[5], byteTable[4], byteTable[3], byteTable[2], byteTable[1]) end;
    [6] = function() return string.char(byteTable[6], byteTable[5], byteTable[4], byteTable[3], byteTable[2], byteTable[1]) end 
  }
  return stringChar[len]()
end

local utf8String = {}
local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}

function utf8String.chop(str)
  if type(str) ~= "string" then return false end
  local splitTable = {}
  local left = #str
  while left ~= 0 do
    local tmp=string.byte(str,-left)
    local i=#arr
    while arr[i] do
      if tmp>=arr[i] then
        left=left-i
        table.insert(splitTable, string.sub(str, -left-i, -left-1))
        break
      end
      i=i-1
    end
  end
  return splitTable
end

function utf8String.len(str)
  return #utf8String.chop(str)
end

function utf8String.sub(str, first, last)
  local splitTable = utf8String.chop(str)
  if not splitTable then
    return false
  end
  local first_trans, last_trans = transPosition(first, last, #splitTable)
  return table.concat(splitTable, "", first_trans, last_trans)
end

function utf8String.find(str, subStr)
  local splitTable    = utf8String.chop(str)
  local subSplitTable = utf8String.chop(subStr)
  if not (splitTable and subSplitTable) then
    return false
  end

  for i = 1, #splitTable do
    if splitTable[i] == subSplitTable[1] then
      for iSub = 1, #subSplitTable do
        if splitTable[i+iSub-1] ~= subSplitTable[iSub] then
          break
        end
        if iSub == #subSplitTable then return i, i+iSub-1 end
      end
    end
  end
  return false
end

function utf8String.unicode(str, pos)
  local function power2(n) return math.pow(2,n) end
  
  local char = utf8String.chop(str)[pos] or utf8String.chop(str)[1] or false
  if not char then return false end
  
  local len = string.len(char)
  local unicode = 0x00000000 
  
  local bytes = {}
  for i = 1, len do table.insert(bytes, string.byte(char,i)) end
  
  table.foreachi(bytes, function(i,v) 
    local byte = v
    if i == 1 then 
      byte = bit.band(byte, power2(7-len)-1)
    else 
      byte = bit.band(byte, power2(6) -1)
    end
    byte = bit.lshift(byte, 6*(len - i))
    unicode = unicode + byte
  end)

  return unicode
end

function utf8String.toUnicode(str)
  local unicodeTable = {}
  for i = 1, string.len(str) do
    table.insert(unicodeTable, utf8String.unicode(str, i))
  end
  return unicodeTable
end

function utf8String.char(unicode)
  local function power2(n) return math.pow(2,n) end
  
  local num = unicode
  local counter = 1
  local byteTable = {}
  while(num~=0) do
    if unicode < power2(8) then
        table.insert(byteTable, unicode)
        break
    end
    --当字符串长度是一个字节的时候，编码占用7位， 和其他情况不同，20170209_ctz
    local bander = power2(6*counter) - power2(6*counter-6)
    local byte = bit.band(num, bander)
    num = num - byte
    
    byte = bit.rshift(byte, 6*counter-6)
    if num == 0 then 
      byte = bit.bor(byte, power2(8)-power2(8-counter))
    else
      byte = bit.bor(byte, power2(7))
    end
    
    table.insert(byteTable, byte)
    counter = counter +1
  end
  local char = stringCharByTable(byteTable)
  return char
end

--local str = "你好我叫陈添泽"
--print(utf8String.char(20320))

return utf8String