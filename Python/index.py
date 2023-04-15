#!/usr/bin/env python

def haha(a:int, b:int) -> str:
    """
    Arg:
        a(int):number first
        b(int):number second
    """
    return f"{a}+{b}={a+b}"

print("Hello Word!")
print("Wangcf is a smart person")

import keyword
print(keyword.kwlist)
"""
['False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await', 
'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 
'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 
'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 
'while', 'with', 'yield'] 
"""


if True:
    print ("Answer")
    print ("True")
else:
    print ("Answer")
print ("False")    # 缩进不一致，会导致运行错误


print('hello\nrunoob')      # 使用反斜杠(\)+n转义特殊字符
print(r'hello\nrunoob')     # 在字符串前面添加一个 r，表示原始字符串，不会发生转义

print(issubclass(bool, int))

print(True is 1)

print(type(False))


str = 'Runoob'
print (str[0:3])    #Run
print (str[:2])     #Ru   
print (str[2:])     #noob  
print (str[:-1])    #Runoo
print (str[-1:])    #b
print (str[:0])     #b


t = ['a', 'b', 'c', 'd', 'e']
subt1 = t[1:3]      #subt1 = ['a', 'b']
subt2 = t[:3]       #subt2 = ['a', 'b', 'c']
subt3 = t[3:]       #subt3 = ['d', 'e']
subt4 = t[:-1]      #subt4 = ['a', 'b', 'c', 'd']
subt5 = t[-1:]      #subt5 = ['e']
subt6 = t[:0]
print("end")

str1 = 'second'
s = ('first', str1, 'third')
str1 = 'secondChange'
print(s)


print(dict([('Runoob', 1), ('Google', 2), ('Taobao', 3)]))

dict1 = {x: x**2 for x in (2, 4, 6) if x % 2 == 0}
print(dict1)

"""
    列表推导式：
    [表达式 for 变量 in 列表] 
    [out_exp_res for out_exp in input_list]
    或者 
    [表达式 for 变量 in 列表 if 条件]
    [out_exp_res for out_exp in input_list if condition]
"""
names = ['Bob','Tom','alice','Jerry','Wendy','Smith']
new_names = [name.upper()for name in names if len(name)>3]
print(new_names)

multiples = [i for i in range(30) if i % 3 == 0]
print(multiples)

"""
    字典推导式
    字典推导基本格式：
    { key_expr: value_expr for value in collection }
    { key_expr: value_expr for value in collection if condition }
"""
listdemo = ['Google','Runoob', 'Taobao']
newdict = {key:len(key) for key in listdemo}
print(newdict)

"""
    集合推导式
    { expression for item in Sequence }
    或
    { expression for item in Sequence if conditional }
"""
setnew = {i**2 for i in (1,2,3)}
print(setnew)

"""
    元组推导式（生成器表达式）
    (expression for item in Sequence )
    或
    (expression for item in Sequence if conditional )
"""
a = (x for x in range(1,10))
# 使用 tuple() 函数，可以直接将生成器对象转换成元组
print(tuple(a))

s = "sdfas"
if (n:=len(s))>10:
    print(f"n")

print(id(s))

print("line1 \
... line2 \
... line 3")



a = "Hello"
b = "Python"
 
print("a + b 输出结果：", a + b)
print("a * 2 输出结果：", a * 2)
print("a[1] 输出结果：", a[1])
print("a[1:4] 输出结果：", a[1:4])
 
if( "H" in a) :
    print("H 在变量 a 中")
else :
    print("H 不在变量 a 中")
 
if( "M" not in a) :
    print("M 不在变量 a 中")
else :
    print("M 在变量 a 中")
 
print (r'\n')
print (R'\n')


x = 1
print(f'{x+1=}')   # Python 3.8
print("1 + 1 =")   # Python 3.8

site = {"name": "菜鸟教程", "url": "www.runoob.com"}
print("网站名：{name}, 地址 {url}".format(**site))


class AssignValue(object):
    def __init__(self, value):
        self.value = value
my_value = AssignValue(6)
print('value 为: {0.value}'.format(my_value))  # "0" 是可选的


for x in (1, 2, 3): 
    print (x, end=" ")

tup = ('r', 'u', 'n', 'o', 'o', 'b')
id(tup)     # 查看内存地址
tup = (1,2,3)
id(tup)


emptyDict = {}
# 打印字典
print(emptyDict)


tinydict = {'Name': 'Runoob', 'Age': 7, 'Class': 'First'}
 
del tinydict['Name'] # 删除键 'Name'
#tinydict.clear()     # 清空字典
#del tinydict         # 删除字典
 
print ("tinydict['Age']: ", tinydict['Age'])
#print ("tinydict['School']: ", tinydict['School'])


def change(a):
    print(id(a))   # 指向的是同一个对象
    a=10
    print(id(a))   # 一个新对象
 
a=1
print(id(a))
change(a)
print(id(a))


import sys
 
print('命令行参数如下:')
for i in sys.argv:
   print(i)
 
print('\n\nPython 路径为：', sys.path, '\n')

freshfruit = ['  banana', '  loganberry ', 'passion fruit  ']
tds = [weapon.strip() for weapon in freshfruit]
print(tds)

sA = set('fapameradjwaojlj')
print(sA)

if True: print("test geshi")

for x in range(2, 3):
    print("range", x)
else:
    print("not range", x)

for letter in 'Runoob': 
   if letter == 'o':
      pass
      print ('执行 pass 块')
   print ('当前字母 :', letter)
 
print ("Good bye!")

for n in range(2, 10):
    for x in range(2, n):
        if n % x == 0:
            print(n, '等于', x, '*', n//x)
            break
    else:
        # 循环中没有找到元素
        print(n, ' 是质数')

age = int(input("请输入你家狗狗的年龄: "))
print("")
if age <= 0:
    print("你是在逗我吧!")
elif age == 1:
    print("相当于 14 岁的人。")
elif age == 2:
    print("相当于 22 岁的人。")
elif age > 2:
    human = 22 + (age -2)*5
    print("对应人类年龄: ", human)
 
### 退出提示
input("点击 enter 键退出")

var = 1
while var == 1 :  # 表达式永远为 true
   num = int(input("输入一个数字  :"))
   print ("你输入的数字是: ", num)
 
print ("Good bye!")


