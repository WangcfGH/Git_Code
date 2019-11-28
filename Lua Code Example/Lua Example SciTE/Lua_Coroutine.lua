local co1 = coroutine.create(
	function(person)
		if type(person) == "table" then
			print("this person name is "..person.name)
			print("this person year is "..person.year)
		else
			print("this is not a person")
		end
	end
)

local co2 = coroutine.wrap(
	function(person)
		if type(person) == "table" then
			print("this person name is "..person.name)
			print("this person year is "..person.year)
		else
			print("this is not a person")
		end
	end
)

co3 = coroutine.create(
	function()
		for i=1,10 do
			print(i)
			if i == 3 then
				print(coroutine.status(co3))
				print(coroutine.running())
			end
			coroutine.yield()
		end
	end
)

local per1 = {name = "wcf", year = 29}
print("per1 type is "..type(per1))
coroutine.resume(co1, per1)
co2({name = "fm", year = 28})

print(coroutine.status(co3))
print(coroutine.running())

coroutine.resume(co3)
coroutine.resume(co3)
coroutine.resume(co3)

print("end")




-- 原始版
function foo (a)
    print("foo 函数输出", a)
    return coroutine.yield(2 * a) -- 返回  2*a 的值
end

co = coroutine.create(function (a , b)
    print("第一次协同程序执行输出", a, b) -- co-body 1 10
    local r = foo(a + 1)

    print("第二次协同程序执行输出", r)
    local r, s = coroutine.yield(a + b, a - b)  -- a，b的值为第一次调用协同程序时传入

    print("第三次协同程序执行输出", r, s)
    return b, "结束协同程序"                   -- b的值为第二次调用协同程序时传入
end)

print("main", coroutine.resume(co, 1, 10)) -- true, 4
print("--分割线----")
print("main", coroutine.resume(co, "r")) -- true 11 -9
print("---分割线---")
print("main", coroutine.resume(co, "x", "y")) -- true 10 end
print("---分割线---")
print("main", coroutine.resume(co, "x", "y")) -- cannot resume dead coroutine
print("---分割线---")


-- 优化版
function foo (a)
    print("foo 函数输出", a)
    return (2 * a) -- 返回  2*a 的值
end

co = coroutine.create(function (a , b)
    print("第一次协同程序执行输出", a, b) -- co-body 1 10
    local r = foo(a + 1)
	coroutine.yield()

    print("第二次协同程序执行输出", r)
    local r, s = a + b, a - b  -- a，b的值为第一次调用协同程序时传入
	coroutine.yield()

    print("第三次协同程序执行输出", r, s)
    return b, "结束协同程序"                   -- b的值为第二次调用协同程序时传入
end)


print("main", coroutine.resume(co, 1, 10)) -- true, 4
print("--分割线----")
print("main", coroutine.resume(co)) -- true 11 -9
print("---分割线---")
print("main", coroutine.resume(co)) -- true 10 end
print("---分割线---")
print("main", coroutine.resume(co)) -- cannot resume dead coroutine
print("---分割线---")




-- 生产者-消费者问题
local newProductor

function productor()
     local i = 0
     while true do
          i = i + 1
          send(i)     -- 将生产的物品发送给消费者
     end
end

function consumer()
     while true do
          local i = receive()     -- 从生产者那里得到物品
          print(i)
		  if i == 100 then
			break
		  end
     end
end

function receive()
     local status, value = coroutine.resume(newProductor)
     return value
end

function send(x)
     coroutine.yield(x)     -- x表示需要发送的值，值返回以后，就挂起该协同程序
end

-- 启动程序
newProductor = coroutine.create(productor)
consumer()














































