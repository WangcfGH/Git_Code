local BaseGameController = {}

function BaseGameController:ntfGameStart()
	print("BaseGameController ntfGameStart")
end

function BaseGameController:ntfGameThrow()
	print("BaseGameController ntfGameThrow")
end

function BaseGameController:ntfGameWin()
	print("BaseGameController ntfGameWin")
end

return BaseGameController
