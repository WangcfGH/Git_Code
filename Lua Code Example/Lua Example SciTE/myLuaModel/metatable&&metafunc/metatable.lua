--__index元方法
--这是 metatable 最常用的key。
--当你通过key来访问 table 的时候，如果这个key没有值，那么Lua就会寻找该table的metatable（假定有metatable）中的__index key。如果__index包含一个table，Lua会在该table中查找相应的key。
local class_a =  { a = 1 }
local class_b = setmetatable({}, { __index = class_a }) 
print(class_b.a)
--如果__index包含一个函数的话，Lua就会调用那个函数，table和键会作为参数传递给函数。
--__index 元方法查看表中元素是否存在，如果不存在，返回结果为 nil；如果存在则由 __index 返回结果。
local class_a =  function (table,key)
   if key=="a" then
       return 1
   end
end
local class_b = { b = 2 }
class_b = setmetatable( class_b, { __index = class_a }) 
print(class_b.a)
print(class_b.b)
--所以
--1.在表中查找，如果找到，返回该元素，找不到则继续
--2.判断该表是否有元表，如果没有元表，返回nil，有元表则继续。
--3.判断元表有没有__index方法，如果__index方法为nil，则返回nil；如果__index方法是一个表，则重复1、2、3；如果__index方法是一个函数，则返回该函数的返回值。



--__newindex 元方法
--__newindex 元方法用来对表更新，__index则用来对表访问 。
--当你给表的一个缺少的key赋值，解释器就会查找__newindex 元方法：如果存在则调用这个函数而不进行赋值操作。
local class_a =  {}
local class_b = { b = 2 }
class_b = setmetatable( class_b, { __newindex  = class_a }) 
print(class_b.b)
class_b.a = "a"
print(class_b.a)
print(class_a.a)
class_b.b = "b"
print(class_b.b)
print(class_a.b)



--rawset(table,key,value) 函数
local class_a =  function (table,key,value)
   rawset(table, key, "\""..value.."\"")
end
local class_b = { b = 2 }
class_b = setmetatable( class_b, { __newindex  = class_a }) 
print(class_b.b)
class_b.a = "a"
print(class_b.a)



--rawget(table, index)函数
--解释：根据参数table和index获得真正的值table[index]，也就是说根本不会调用到元表，其中参数table必须是一个表，而参数index可以使是任何值。
--  定义一个table
local class_b = { b=2 }
--  定义元表
local class_a = { a=1 }
-- 先打印没有元表的情况
print("class_b.b =",class_b.b)
print("class_b.a =",class_b.a)
-- 设置元表
setmetatable(class_b, {__index = class_a})
-- 打印有元表的情况
print("class_b.b =",class_b.b)
print("class_b.a =",class_b.a)
-- 打印不使用元表的情况
print("class_b.b =",rawget(class_b,"b"))
print("class_b.a =",rawget(class_b,"a"))