-- Meta class
Shape = {area = 0}
-- �����෽�� new
function Shape:new (o,side)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if side then
	self.area = side*side;
  end
  return o
end
-- �����෽�� printArea
function Shape:printArea ()
  print("���Ϊ ",self.area)
end

-- ��������
myshape = Shape:new(nil,10)
myshape:printArea()

Square = Shape:new()
-- �����෽�� new
function Square:new (o,side)
  o = o or Shape:new(o)
  setmetatable(o, self)
  self.__index = self
  if side then
	self.area = side*side;
  end
  return o
end

-- �����෽�� printArea
function Square:printArea ()
  print("���������Ϊ ",self.area)
end

-- ��������
mysquare = Square:new(nil,20)
mysquare:printArea()

myshape:printArea()

Rectangle = Shape:new()
-- �����෽�� new
function Rectangle:new (o,length,breadth)
  o = o or Shape:new(o)
  setmetatable(o, self)
  self.__index = self
  self.area = length * breadth
  return o
end

-- �����෽�� printArea
function Rectangle:printArea ()
  print("�������Ϊ ",self.area)
end

-- ��������
myrectangle = Rectangle:new(nil,10,20)
myrectangle:printArea()


YuanXing = Square:new()
-- �����෽�� new
function YuanXing:new(o, side)
	o = o or Square:new(o)
	setmetatable(o, self)
	self.__index = self
	self.area = 3.4*side*side
	return o
end

function YuanXing:printArea()
	print("Բ�����Ϊ ", self.area)
end

-- ��������
myyuanxing = YuanXing:new(nil, 2)
myyuanxing:printArea()

mysquare:printArea()
