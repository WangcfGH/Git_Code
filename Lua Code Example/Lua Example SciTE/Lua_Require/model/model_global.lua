model_global = {}

model_global.name = "model_global"

function model_global.funcPub()
	print("do model_global.funcPub")	
end

local function funcPri()
	print("do model_global.funcPri")
end

return model_global