print(package.path)

package.path = package.path ..';.\\model\\?.lua'

print(package.path)

local function testRequireLocal()
	local model_local = require("model_local")
	model_local:funcPub()
	print(model_local.name)
end

local function testRequireLocal2()
	local model_local2 = require("model_local")
	model_local2:funcPubPrint()
	print(model_local2.name)
end

testRequireLocal2()

testRequireLocal()
--model_local:funcPub()

testRequireLocal2()

local function testRequireGlobal()
	local model_global = require("model_global")
	model_global:funcPub()
end

testRequireGlobal()

model_global:funcPub()
