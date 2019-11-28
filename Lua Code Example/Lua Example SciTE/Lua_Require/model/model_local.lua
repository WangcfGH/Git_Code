local model_local = {}

model_local.name = "model_local"
model_local.tb = {1,2,3}

function model_local:funcPub()
	print("do model_local.funcPub")
	--[[
	local tb1 = self.tb
	tb1[2] = 5
	for k,v in pairs(self.tb) do
		print(k,v)
	end
	--]]
end

local function funcPri()
	print("do model_local.funcPri")
end

return model_local