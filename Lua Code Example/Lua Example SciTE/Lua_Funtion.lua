--[[
-- 函数相关基础
function myAdd( ... )
	local total = 0
	for k,v in pairs({...}) do
		total = total + v
	end
	return total
end

function calcTotalCharsNum( ... )
	local args = {...}
	return #args
end

print(myAdd(5,4,6,8,5))
print(calcTotalCharsNum("abc", "wcf", "wcb"))

function average(...)
   result = 0
   local arg={...}
   for i,v in ipairs(arg) do
      result = result + v
   end
   print("总共传入 " .. #arg .. " 个数")
   return result/select("#",...)
end
print("平均值为",average(10,5,3,4,5,6))

do  
    function foo(...)  
        for i = 1, select('#', ...) do  -- 获取参数总数
            local arg = select(i, ...); -- 读取参数
            print("arg", arg);  
        end  
    end  
 
    foo(1, 2, 3, 4);  
end
--]]

-- 字符串相关基础
local str1 = "双引号字符串"
local str2 = '单引号字符串'
local str3 = [["双括号字符串 带双引号"]]
local str4 = [[双括号字符串]]
print("\"字符串1\" 是 "..str1)
print("字符串2 是 "..str2)
print("字符串3 是 "..str3)
print("字符串4 是 "..str4)



-- 常用基础库函数
print("wcf is boy string.upper is "..string.upper("wcf is boy"))
print("WCF IS BOY string.lower is "..string.lower("WCF IS BOY"))
local strDecBefore = "Wcf is good boy"
print("before string.gsub is "..strDecBefore)
local strDecAfter = string.gsub(strDecBefore, "good", "bad")
print("after string.gsub is "..strDecAfter)
local findBegin, findEnd = string.find("wcf is good boy", "good")
print("findBegin is "..findBegin.."findEnd is "..findEnd)
local strReverse = string.reverse("wcf is good boy")
print("wcf is good boy sting.reverse is "..strReverse)
print(string.format("wcf is %d year", 29))
print(string.char(97,98,99,100))
print(string.byte("AcDb", 2))
print(string.byte("AcDb"))
print(string.len("adga;sdga;sdlg;a"))
print("asdfad".."sadgad")


-- talble常用函数
local fruits = {"apple", "orange", "blanana"}
local fruitsConcat1 = table.concat(fruits)
local fruitsConcat2 = table.concat(fruits, "|")
local fruitsConcat3 = table.concat(fruits, "|", 2, 3)
print(fruits[1].."-"..fruits[2].."-"..fruits[3])
print(fruitsConcat1)
print(fruitsConcat2)
print(fruitsConcat3)

table.insert(fruits, 1, "pear")
table.insert(fruits, "grape")
print(fruits[1].."-"..fruits[2].."-"..fruits[3].."-"..fruits[4].."-"..fruits[5])
table.remove(fruits)
print(fruits[1].."-"..fruits[2].."-"..fruits[3].."-"..fruits[4])
table.remove(fruits, 1)
print(fruits[1].."-"..fruits[2].."-"..fruits[3])
