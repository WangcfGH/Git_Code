local BaseRadio = class("BaseRadio")

BaseRadio.RadioBtnState = {
    began = 'began',
    cancelled = 'cancelled',
    moved = 'moved',
    ended = 'ended',
    selected = 'selected',
    unselected = 'unselected'
}

function BaseRadio:ctor(panelParent, nRadioNum, nChoose, pCallBackList, pRadioBtnStateCallback)
    if not panelParent then
        return nil
    end

    if (not nRadioNum) or (nRadioNum <= 0) then
        return nil
    end

    if not pCallBackList then
        return nil
    end

    self._panelParent = panelParent
    self._nRadioNum = nRadioNum
    self._pCallBackList = pCallBackList
    self._pRadioBtnStateCallback = pRadioBtnStateCallback
    self._nChoose = nChoose
    self._radios = {}

    if self:initRadios() then
        return self
    end

    return nil
end

function BaseRadio:initRadios()
    local pRadio = nil
    for i = 1, self._nRadioNum do
        pRadio = self._panelParent:getChildByName("Radio_" .. tostring(i))

        pRadio:onTouch(function(e)
            if self._pRadioBtnStateCallback and self._pRadioBtnStateCallback[i] then
                self._pRadioBtnStateCallback[i](e.name, e)
            end
        end)

        if pRadio and self._pCallBackList[i] then
            table.insert(self._radios, pRadio)
            if i == self._nChoose then
                self:setRadioChoose(i, pRadio, true)
                self._pCallBackList[i]()
            else
                self:setRadioChoose(i, pRadio, false)
            end
            pRadio:addClickEventListener(
                function()
                    self:setRadioStatus(i)
                    self._pCallBackList[i]()
                end
            )
        end
    end
    return true
end

function BaseRadio:setRadioChoose(index, pRadio, selected)
    if pRadio then
        if not selected then --这里对于radio 选中的不能再设置 再设置就变为非选中了
            pRadio:setSelected(selected)
        end
        pRadio:setEnabled(not selected)

        if self._pRadioBtnStateCallback and self._pRadioBtnStateCallback[index] then
            if selected then
                self._pRadioBtnStateCallback[index]('selected', nil)
            else
                self._pRadioBtnStateCallback[index]('unselected', nil)
            end
        end
    end
end

function BaseRadio:setRadioStatus(index)
    for i = 1, #self._radios do
        if self._radios[i] then
            if index == i then
                self:setRadioChoose(i, self._radios[i], true)
            else
                self:setRadioChoose(i, self._radios[i], false)
            end
        end
    end
end

return BaseRadio
