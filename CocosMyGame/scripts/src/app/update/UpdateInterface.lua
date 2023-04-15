local UpdateInterface = {}

local instance = require('src.app.update.UpdateCtrl'):create()
UpdateInterface.instance = instance

require('src.app.update.UpdateDefine')

function UpdateInterface:setCallback(...)
    UpdateInterface.instance:setCallback(...)
end

function UpdateInterface:startUpdateWithScene(...)
    UpdateInterface.instance:startUpdateWithScene(...)
end

function UpdateInterface:startUpdate(...)
    UpdateInterface.instance:startUpdate(...)
end

return UpdateInterface