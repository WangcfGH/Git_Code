-- 打印require搜索路径
print(package.path)
-- require路径引入.\model\路径
package.path = package.path ..';.\\model\\?.lua'
-- 打印require搜索路径
print(package.path)
-- 加载模块model_local
local model_local = require("model_local")
model_local:funcPub()
print(model_local.name)
-- 加载模块model_global
local model_global = require("model_global")