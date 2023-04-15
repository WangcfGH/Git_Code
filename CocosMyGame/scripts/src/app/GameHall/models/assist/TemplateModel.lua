local TemplateModel = class('TemplateModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(TemplateModel)

local TemplateReq = import('src.app.plugins.xxx.TemplateModel')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local TemplateDef = {
    GR_GET_USER_PROP = 404120, --获取道具数据
}

TemplateModel.EVENT_MAP = {
}

function TemplateModel:onCreate()
    self._assistResponseMap = {
        [TemplateDef.GR_GET_USER_PROP] = handler(self, self.onGetUserProp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

return TemplateModel