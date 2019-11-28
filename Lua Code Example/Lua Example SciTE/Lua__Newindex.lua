--这就是__newindex的规则：
--a.如果__newindex是一个函数，则在给table不存在的字段赋值时，会调用这个函数。
--b.如果__newindex是一个table，则在给table不存在的字段赋值时，会直接给__newindex的table赋值。

-- 例子1
local smartMan = {
    name = "none",
    money = 9000000,

    sayHello = function()
        print("大家好，我是聪明的豪。")
    end
}

local t1 = {}

local mt = {
    __index = smartMan,
    __newindex = function(table, key, value)
        print(key .. "字段是不存在的，不要试图给它赋值！")
    end
}

setmetatable(t1, mt)

t1.sayHello = function()
    print("en")
end
t1.sayHello()


-- 例子2
local smartMan = {
    name = "none",
}

local other = {
    name = "大家好，我是很无辜的table"
}

local t1 = {}

local mt = {
    __index = smartMan,
    __newindex = other
}

setmetatable(t1, mt)

print("other的名字，赋值前：" .. other.name)
t1.name = "小偷"
print("other的名字，赋值后：" .. other.name)
print("t1的名字：" .. t1.name)




-- 例子3
--如果把（1）换成（2），在第三个输出结果处报错stack overflow。因为在__newindex中设置 table.wangbin=”yes,i am”，就需要进入到table的元表，也就是又回到 __newindex，这里又要设置table.wangbin，于是进入死循环，爆栈出错。
Window = {}
Window.prototype = {x = 0 ,y = 0 ,width = 100 ,height = 100,}
Window.mt = {}

function Window.new(o)
    setmetatable(o ,Window.mt)
    return o
end

Window.mt.__index = function (t ,key)
    return 1000
end

Window.mt.__newindex = function (table ,key ,value)
    if key == "wangbin" then
        rawset(table ,"wangbin" ,"yes,i am")  --(1)
        -- table.wangbin = "yes,i am"   --(2)反例
    end
end

w = Window.new({x = 10 ,y = 20}  )
print(rawget(w ,w.wangbin))
print(w.wangbin)

w.wangbin = "nVal"
print(w.wangbin)

rawset(w,"wangbin","nVal")
print(w.wangbin)
