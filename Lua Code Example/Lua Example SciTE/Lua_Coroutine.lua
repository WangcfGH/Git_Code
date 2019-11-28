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




-- ԭʼ��
function foo (a)
    print("foo �������", a)
    return coroutine.yield(2 * a) -- ����  2*a ��ֵ
end

co = coroutine.create(function (a , b)
    print("��һ��Эͬ����ִ�����", a, b) -- co-body 1 10
    local r = foo(a + 1)

    print("�ڶ���Эͬ����ִ�����", r)
    local r, s = coroutine.yield(a + b, a - b)  -- a��b��ֵΪ��һ�ε���Эͬ����ʱ����

    print("������Эͬ����ִ�����", r, s)
    return b, "����Эͬ����"                   -- b��ֵΪ�ڶ��ε���Эͬ����ʱ����
end)

print("main", coroutine.resume(co, 1, 10)) -- true, 4
print("--�ָ���----")
print("main", coroutine.resume(co, "r")) -- true 11 -9
print("---�ָ���---")
print("main", coroutine.resume(co, "x", "y")) -- true 10 end
print("---�ָ���---")
print("main", coroutine.resume(co, "x", "y")) -- cannot resume dead coroutine
print("---�ָ���---")


-- �Ż���
function foo (a)
    print("foo �������", a)
    return (2 * a) -- ����  2*a ��ֵ
end

co = coroutine.create(function (a , b)
    print("��һ��Эͬ����ִ�����", a, b) -- co-body 1 10
    local r = foo(a + 1)
	coroutine.yield()

    print("�ڶ���Эͬ����ִ�����", r)
    local r, s = a + b, a - b  -- a��b��ֵΪ��һ�ε���Эͬ����ʱ����
	coroutine.yield()

    print("������Эͬ����ִ�����", r, s)
    return b, "����Эͬ����"                   -- b��ֵΪ�ڶ��ε���Эͬ����ʱ����
end)


print("main", coroutine.resume(co, 1, 10)) -- true, 4
print("--�ָ���----")
print("main", coroutine.resume(co)) -- true 11 -9
print("---�ָ���---")
print("main", coroutine.resume(co)) -- true 10 end
print("---�ָ���---")
print("main", coroutine.resume(co)) -- cannot resume dead coroutine
print("---�ָ���---")




-- ������-����������
local newProductor

function productor()
     local i = 0
     while true do
          i = i + 1
          send(i)     -- ����������Ʒ���͸�������
     end
end

function consumer()
     while true do
          local i = receive()     -- ������������õ���Ʒ
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
     coroutine.yield(x)     -- x��ʾ��Ҫ���͵�ֵ��ֵ�����Ժ󣬾͹����Эͬ����
end

-- ��������
newProductor = coroutine.create(productor)
consumer()














































