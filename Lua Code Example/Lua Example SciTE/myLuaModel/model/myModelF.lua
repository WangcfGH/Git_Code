local myModelF = {}

myModelF.name = "myModelF"
myModelF.year = 0

function myModelF:showName()
	print("model name is ",self.name)
end

function myModelF.showYear(self)
	print("model Ope is Ope  "..self.year)
end

function myModelF:addYear()
	self.year = self.year + 1
end

myModelF:showName()
myModelF.showYear(myModelF)
myModelF:addYear()
return myModelF
