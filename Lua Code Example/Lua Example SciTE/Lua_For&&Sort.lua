-- pairs���������ǰ�˳�������������ֵ�������������
local table1 = {100, 50, 6000, 1, 109, 21}
local table2 = {[1] = 100, [2] = 50, [3] = 6000, [4] = 1, [5] = 109, [6] = 21}
print("table1 is {100, 50, 6000, 1, 109, 21}")
print("print k v pairs table1")
for k,v in pairs(table1) do
	print(k.." is "..v)
end
print("\ntable2 is {[1] = 100, [2] = 50, [3] = 6000, [4] = 1, [5] = 109, [6] = 21}")
print("print k v pairs table2")
for k,v in pairs(table2) do
	print(k.." is "..v)
end

-- ipairs���������ǰ�˳�������������ֵ����Ҳ�ǰ�˳�����������ֵ1��ʼ�����������ж�
-- #������Ӽ�ֵ1��ʼ�����ۼƣ������ж�
print("\ntable1 is {100, 50, 6000, 1, 109, 21}")
print("print k v ipairs table1")
for i,v in ipairs(table1) do
	print(i.." is "..v)
end
print("#table1 length is "..#table1)

print("\ntable2 is {[1] = 100, [2] = 50, [3] = 6000, [4] = 1, [5] = 109, [6] = 21}")
print("print k v ipairs table2")
for i,v in ipairs(table2) do
	print(i.." is "..v)
end
print("#table2 length is "..#table2)

local table3 = {[1] = 50, [2] = 25, [3] = 33, [5] = 6, [6] = 96}
print("\ntable3 is {[1] = 50, [2] = 25, [3] = 33, [5] = 6, [6] = 96}")
print("print k v ipairs table3")
for i,v in ipairs(table3) do
	print(i.." is "..v)
end
print("#table5 length is "..#table3)

local table4 = {[1] = 50, [2] = 25, [3] = 33, [5] = 6, [4] = 1, [6] = 96}
print("\n \ntable4 is {[1] = 50, [2] = 25, [3] = 33, [5] = 6, [4] = 1, [6] = 96}")
print("print k v ipairs table4")
for i,v in ipairs(table4) do
	print(i.." is "..v)
end
print("#table4 length is "..#table4)



-- ��������ʽ���ࣺ
-- 1����������
local sortTable1 = {"Lua","swift","python","java","c++"}
print("\nBefore sort, the elements of sortTable1 is:")
for k,v in pairs(sortTable1) do
	print(k.."-"..v)
end

table.sort(sortTable1)

print("\nAfter sort, the elements of sortTable1 is:")
for k,v in pairs(sortTable1) do
	print(k.."-"..v)
end
print("��ע���ַ���ʹ��Ĭ�Ϻ�������(������ĸAscll������)")

-- 2��������
local sortTable2 = {
	{id=1, name="deng"},
    {id=9, name="luo"},
    {id=2, name="yang"},
    {id=8, name="ma"},
    {id=5, name="wu"},
}
print("\nBefore sort, the elements of sortTable2 is:")
for i in pairs(sortTable2) do
   print(sortTable2[i].id.."-"..sortTable2[i].name)
end

table.sort(sortTable2,function(a,b) return a.id<b.id end )

for i in pairs(sortTable2) do
   print(sortTable2[i].id.."-"..sortTable2[i].name)
end

-- 3����ֵ����(��������)
local sortTable3 = {a=1,f=9,d=2,c=8,b=5}
print("\nBefore sort, the elements of sortTable3 is:\na-1\nf-9\nd-2\nc-8\nb-5")
local key_sortTable3 ={}
for i, v in pairs(sortTable3) do
   table.insert(key_sortTable3,i)
end

table.sort(key_sortTable3)

print("\nAfter sort, the elements of sortTable3 is:")
for i,v in pairs(key_sortTable3) do
   print(v.."-"..sortTable3[v])
end


-- sort�����ֵ���߼���������1������ʼ���򣬷����жϣ�
local sortTable4 = {[8] = 4, [1] = 100, [2] = 50, [3] = 6000, [5] = 1, [6] = 2, [7] = 3}
print("\nBefore sort, pairs sortTable4 is:{[8] = 4, [1] = 100, [2] = 50, [3] = 6000, [5] = 1, [6] = 2, [7] = 3}")
print("Before pairs sortTable4 is")
for k,v in pairs(sortTable4) do
	print(k.." is "..v)
end

table.sort(sortTable4, function(a, b)
	return a < b
end)

print("\nAfter sort, pairs sortTable4 is:{[8] = 4, [1] = 50, [2] = 100, [3] = 6000, [5] = 1, [6] = 2, [7] = 3}")
print("Afterpairs sortTable4 is")
for k,v in pairs(sortTable4) do
	print(k.." is "..v)
end
