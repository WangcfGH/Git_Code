local RealItemInputCtrl = class("RealItemInputCtrl", import("src.app.plugins.inputplugin.BaseInputCtrl"))

RealItemInputCtrl.viewCreater = import('src.app.plugins.inputplugin.RealItemInputView')

-- params = {
--     jsonFormat = "{\"mobile\":%s,\"address\":%s,\"recipients\":%s,\"remark\"}"
--     onInputFinished = function(jsonResult)
--         print(jsonResult)
--     end
-- }
function RealItemInputCtrl:replaceNRT(str)
    str = string.gsub(str, "\r", " ")
    str = string.gsub(str, "\n", " ")
    str = string.gsub(str, "\t", " ")
    return str
end

function RealItemInputCtrl:commitPhoneNum()
    local viewNode = self._viewNode
    local phoneNum = viewNode.editBoxPhoneNum:getString()
    local address = self:replaceNRT(viewNode.editBoxAddress:getString())
    local recipients = self:replaceNRT(viewNode.editBoxName:getString())
    local remark = self:replaceNRT(viewNode.editBoxRemark:getString())
    if self._viewNode:isCheckRight() then
        self._onInputFinished(string.format(self._jsonFormat, phoneNum, address, recipients, remark), handler(self, self.removeSelfInstance))
    else
        self:informPluginByName("TipPlugin", {tipString = "请确认填写正确"})
    end
end

function RealItemInputCtrl:registEditBoxEvent()
    self._viewNode.editBoxPhoneNum:onEditHandler(handler(self, self.onPhoneNumInput))
    self._viewNode.editBoxAddress:onEditHandler(handler(self, self.onAddressInput))
end

function RealItemInputCtrl:onAddressInput(event)
    print(event.name)
    if event.name == "changed" then
--        local targetString = event.target:getString()
--        targetString:gsub("&#xA;", "")
--        print(targetString)
--        local utf8String = cc.load('strings').Utf8String
--        local paragraphs = {}
--        local fontSize = 32--event.target:getFontSize()
--        local contentWidth = event.target:getContentSize().width
--        local lineWordCount = math.floor(contentWidth/fontSize) - 2
--        local strLen = utf8String.len(targetString)
--        for i = 1, math.floor(strLen/lineWordCount) do
--            table.insert(paragraphs, utf8String.sub(targetString, (i-1)*lineWordCount+1, i*lineWordCount) )
--        end
--        if math.floor(strLen/lineWordCount)*lineWordCount+1 <= strLen then
--            table.insert(paragraphs, utf8String.sub(targetString, math.floor(strLen/lineWordCount)*lineWordCount+1, strLen ))
--        end
--        local ret = table.concat(paragraphs, "\n")
--        print(ret)
--        event.target:setString("adsffffffffffffffffff\r\ndfffffff")

        local targetStr = event.target:getString()
        if targetStr == "" then
            self._viewNode.textAddress:setString("请输入您的地址")
            self._viewNode.textAddress:setColor(cc.c3b(255, 255, 255))
        else
            self._viewNode.textAddress:setColor(cc.c3b(0x33, 0x33, 0x33))
            self._viewNode.textAddress:setString(targetStr)
        end
    end
end

return RealItemInputCtrl