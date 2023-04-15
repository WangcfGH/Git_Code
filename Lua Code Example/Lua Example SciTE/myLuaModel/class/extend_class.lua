-- Meta class
Shape = {area = 0}
-- 基础类方法 new
function Shape:new (o,side)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if side then
	self.area = side*side;
  end
  return o
end
-- 基础类方法 printArea
function Shape:printArea ()
  print("面积为 ",self.area)
end

-- 创建对象
myshape = Shape:new(nil,10)
myshape:printArea()

Square = Shape:new()
-- 派生类方法 new
function Square:new (o,side)
  o = o or Shape:new(o)
  setmetatable(o, self)
  self.__index = self
  if side then
	self.area = side*side;
  end
  return o
end

-- 派生类方法 printArea
function Square:printArea ()
  print("正方形面积为 ",self.area)
end

-- 创建对象
mysquare = Square:new(nil,20)
mysquare:printArea()

myshape:printArea()

Rectangle = Shape:new()
-- 派生类方法 new
function Rectangle:new (o,length,breadth)
  o = o or Shape:new(o)
  setmetatable(o, self)
  self.__index = self
  self.area = length * breadth
  return o
end

-- 派生类方法 printArea
function Rectangle:printArea ()
  print("矩形面积为 ",self.area)
end

-- 创建对象
myrectangle = Rectangle:new(nil,10,20)
myrectangle:printArea()


YuanXing = Square:new()
-- 派生类方法 new
function YuanXing:new(o, side)
	o = o or Square:new(o)
	setmetatable(o, self)
	self.__index = self
	self.area = 3.4*side*side
	return o
end

function YuanXing:printArea()
	print("圆形面积为 ", self.area)
end

-- 创建对象
myyuanxing = YuanXing:new(nil, 2)
myyuanxing:printArea()

mysquare:printArea()
