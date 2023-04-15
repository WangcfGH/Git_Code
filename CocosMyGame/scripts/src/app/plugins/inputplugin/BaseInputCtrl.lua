local BaseInputCtrl = class("BaseInputCtrl", cc.load("BaseCtrl"))

-- params = {
--     jsonFormat = ""
--     onInputFinished = function(jsonResult)
--         print(jsonResult)
--     end
    -- awardInfo = {
    --     path = "",
    --     name = "",
    --     url = ""
    -- }
    -- defaultPhoneNum = "12321321"
-- }
BaseInputCtrl.RUN_ENTERACTION = true
function BaseInputCtrl:onCreate( params )
    self:setViewIndexer(self.viewCreater:createViewIndexer())
    self._jsonFormat = params.jsonFormat
    self._onInputFinished = params.onInputFinished
    self:registWidgetEvent()
    self:setRewardInfo(params.awardInfo)
    self:registEditBoxEvent()
    self:setDefaultPhoneNum(params.defaultPhoneNum)
end

function BaseInputCtrl:registWidgetEvent()
    local viewNode = self._viewNode
    viewNode.btnCommit:addClickEventListener(function()
        self:playEffectOnPress()
        self:commitPhoneNum()
    end)
    viewNode.btnClose:addClickEventListener(function()
        self:playEffectOnPress()
        self:removeSelfInstance()
    end)
end

function BaseInputCtrl:setRewardInfo(info)
    self._viewNode.imgItem:loadTexture(info.path)
    self._viewNode.itemName:setString(info.name)
    self:setItemImgByUrl(info.url)
end

function BaseInputCtrl:setItemImgByUrl(url)
    my.setImageByUrl(self._viewNode.imgItem, url)
end

function BaseInputCtrl:commitPhoneNum()
    print("BaseInputCtrl:commitPhoneNum")
end

function BaseInputCtrl:isPhoneNumInputValid(input)
    return type(input) == "string" and string.len(input) == 11 and type(tonumber(input)) == "number" 
end

function BaseInputCtrl:onPhoneNumInput(event)
    self._viewNode:setPhoneNumValid(self:isPhoneNumInputValid(event.target:getString()))
end

function BaseInputCtrl:registEditBoxEvent()
    print("please overwrite BaseInputCtrl:registEditBoxEvent()")
end

function BaseInputCtrl:setDefaultPhoneNum(defaultPhoneNum)
    if not defaultPhoneNum then return end
    if self._viewNode.editBoxPhoneNum then
        self._viewNode.editBoxPhoneNum:setString(tostring(defaultPhoneNum))
        self._viewNode:setPhoneNumValid(self:isPhoneNumInputValid(self._viewNode.editBoxPhoneNum:getString()))
    end
    if self._viewNode.editBoxPhoneNumCheck then
        self._viewNode.editBoxPhoneNumCheck:setString(tostring(defaultPhoneNum))
        local phoneNum = tonumber(self._viewNode.editBoxPhoneNum:getString())
        self._viewNode:setCheckPhoneNumValid(self:isPhoneNumInputValid(self._viewNode.editBoxPhoneNumCheck:getString())
                                            and phoneNum == tonumber(defaultPhoneNum))
    end
end

return BaseInputCtrl