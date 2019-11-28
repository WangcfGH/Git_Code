--�����__newindex�Ĺ���
--a.���__newindex��һ�����������ڸ�table�����ڵ��ֶθ�ֵʱ����������������
--b.���__newindex��һ��table�����ڸ�table�����ڵ��ֶθ�ֵʱ����ֱ�Ӹ�__newindex��table��ֵ��

-- ����1
local smartMan = {
    name = "none",
    money = 9000000,

    sayHello = function()
        print("��Һã����Ǵ����ĺ���")
    end
}

local t1 = {}

local mt = {
    __index = smartMan,
    __newindex = function(table, key, value)
        print(key .. "�ֶ��ǲ����ڵģ���Ҫ��ͼ������ֵ��")
    end
}

setmetatable(t1, mt)

t1.sayHello = function()
    print("en")
end
t1.sayHello()


-- ����2
local smartMan = {
    name = "none",
}

local other = {
    name = "��Һã����Ǻ��޹���table"
}

local t1 = {}

local mt = {
    __index = smartMan,
    __newindex = other
}

setmetatable(t1, mt)

print("other�����֣���ֵǰ��" .. other.name)
t1.name = "С͵"
print("other�����֣���ֵ��" .. other.name)
print("t1�����֣�" .. t1.name)




-- ����3
--����ѣ�1�����ɣ�2�����ڵ�����������������stack overflow����Ϊ��__newindex������ table.wangbin=��yes,i am��������Ҫ���뵽table��Ԫ��Ҳ�����ֻص� __newindex��������Ҫ����table.wangbin�����ǽ�����ѭ������ջ����
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
        -- table.wangbin = "yes,i am"   --(2)����
    end
end

w = Window.new({x = 10 ,y = 20}  )
print(rawget(w ,w.wangbin))
print(w.wangbin)

w.wangbin = "nVal"
print(w.wangbin)

rawset(w,"wangbin","nVal")
print(w.wangbin)
