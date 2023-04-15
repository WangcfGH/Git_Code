local MJGameController = require("MJGameController")
local MyGameController = {}

MyGameController.super = MJGameController
setmetatable(MyGameController, {__index = MyGameController.super})

function MyGameController:ntfGameStart()
	self.super:ntfGameStart()
	print("MyGameController ntfGameStart")
end

function MyGameController:ntfGameThrow()
	MyGameController.super.ntfGameThrow(self)
	print("MyGameController ntfGameThrow")
end

function MyGameController:ntfGameWin()
	self.super.ntfGameWin(self)
	print("MyGameController ntfGameWin")
end

return MyGameController
