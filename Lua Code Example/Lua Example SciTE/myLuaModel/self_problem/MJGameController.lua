local BaseGameController = require("BaseGameController")
local MJGameController = {}

MJGameController.super = BaseGameController
setmetatable(MJGameController, {__index = MJGameController.super})

function MJGameController:ntfGameStart()
	self.super:ntfGameStart()
	print("MJGameController ntfGameStart")
end

function MJGameController:ntfGameThrow()
	MJGameController.super.ntfGameThrow(self)
	print("MJGameController ntfGameThrow")
end

function MJGameController:ntfGameWin()
	self.super.ntfGameWin(self)
	print("MJGameController ntfGameWin")
end

return MJGameController

