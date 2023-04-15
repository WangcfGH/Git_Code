
local BaseGameSafeBox = class("BaseGameSafeBox")

function BaseGameSafeBox:ctor(safeBoxPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._safeBoxPanel          = safeBoxPanel

    self._textSafeBoxDeposit    = nil
    self._textGameDeposit       = nil
    self._safeBoxEdit           = nil

    self._bHaveSecurePwd        = false
    self._securePwd             = 0
    self._transferDeposit       = 0

    self._safeBoxPasswordPanel  = nil
    self._safeBoxPasswordEdit   = nil

    self:init()
end

function BaseGameSafeBox:init()
    if not self._safeBoxPanel then return end
    local safeBoxFrame = self._safeBoxPanel:getChildByName("Panel_frame")
    if not safeBoxFrame then return end

    self:setVisible(false)

    local function onSave()
        self:onSave()
    end
    local buttonSave = safeBoxFrame:getChildByName("safebox_btn_save")
    if buttonSave then
        buttonSave:addClickEventListener(onSave)
    end

    local function onTake()
        self:onTake()
    end
    local buttonTake = safeBoxFrame:getChildByName("safebox_btn_take")
    if buttonTake then
        buttonTake:addClickEventListener(onTake)
    end

    local function onClose()
        self:onClose()
    end
    local buttonClose = safeBoxFrame:getChildByName("safebox_btn_close")
    if buttonClose then
        buttonClose:addClickEventListener(onClose)
    end

    local boxDepositBG = safeBoxFrame:getChildByName("safebox_boxDepositBG")
    if boxDepositBG then
        self._textSafeBoxDeposit = boxDepositBG:getChildByName("deposit")
    end

    local gameDepositBG = safeBoxFrame:getChildByName("safebox_gameDepositBG")
    if gameDepositBG then
        self._textGameDeposit = gameDepositBG:getChildByName("deposit")
    end

    local editBG = safeBoxFrame:getChildByName("Panel_editBG")
    if editBG then
        local editBox = editBG:getChildByName("safebox_edit")

        local depositAmoutInp = editBox
        depositAmoutInp:setVisible(false)
        self._safeBoxEdit = ccui.EditBox:create(editBG:getContentSize(), "res/GameCocosStudio/safebox/frame/safebox_editframe.png")
        self._safeBoxEdit:setPosition(editBG:getPosition())
        self._safeBoxEdit:setAnchorPoint(depositAmoutInp:getAnchorPoint())
        self._safeBoxEdit.setTextColor = editBox.setFontColor
        self._safeBoxEdit:setFontColor(display.COLOR_BLACK)
        self._safeBoxEdit:setFontSize(depositAmoutInp:getFontSize())
        self._safeBoxEdit:setPlaceHolder(depositAmoutInp:getPlaceHolder())
        self._safeBoxEdit:setPlaceholderFontSize(depositAmoutInp:getFontSize())
        self._safeBoxEdit:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
        self._safeBoxEdit:setFontName(depositAmoutInp:getFontName())
        self._safeBoxEdit:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
        self._safeBoxEdit:setMaxLength(10)
        safeBoxFrame:addChild(self._safeBoxEdit)
        self._safeBoxEdit.getString = editBox.getText
        self._safeBoxEdit.setString = editBox.setText
    end

    self._safeBoxPasswordPanel = self._safeBoxPanel:getChildByName("Panel_PasswordCanvas")
    if self._safeBoxPasswordPanel then
        self:showSafeBoxPassword(false)

        local passwordFrame = self._safeBoxPasswordPanel:getChildByName("Panel_PasswordFrame")
        if passwordFrame then
            local function onPasswordOK()
                self:onPasswordOK()
            end
            local buttonPasswordOK = passwordFrame:getChildByName("safebox_btn_ok")
            if buttonPasswordOK then
                buttonPasswordOK:addClickEventListener(onPasswordOK)
            end

            local function onPasswordCancel()
                self:onPasswordCancel()
            end
            local buttonCancel = passwordFrame:getChildByName("safebox_btn_cancel")
            if buttonCancel then
                buttonCancel:addClickEventListener(onPasswordCancel)
            end

            local editBG = passwordFrame:getChildByName("Panel_editBG")
            if editBG then
                local editBox = editBG:getChildByName("safebox_edit")

                local depositAmoutInp = editBox
                depositAmoutInp:setVisible(false)
                self._safeBoxPasswordEdit = ccui.EditBox:create(editBG:getContentSize(), "res/GameCocosStudio/safebox/frame/safebox_editframe.png")
                self._safeBoxPasswordEdit:setPosition(editBG:getPosition())
                self._safeBoxPasswordEdit:setAnchorPoint(depositAmoutInp:getAnchorPoint())
                self._safeBoxPasswordEdit.setTextColor = editBox.setFontColor
                self._safeBoxPasswordEdit:setFontColor(display.COLOR_BLACK)
                self._safeBoxPasswordEdit:setFontSize(depositAmoutInp:getFontSize())
                self._safeBoxPasswordEdit:setPlaceHolder(depositAmoutInp:getPlaceHolder())
                self._safeBoxPasswordEdit:setPlaceholderFontSize(depositAmoutInp:getFontSize())
                self._safeBoxPasswordEdit:setPlaceholderFontColor(depositAmoutInp:getPlaceHolderColor())
                self._safeBoxPasswordEdit:setFontName(depositAmoutInp:getFontName())
                self._safeBoxPasswordEdit:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
                passwordFrame:addChild(self._safeBoxPasswordEdit)
                self._safeBoxPasswordEdit.getString = editBox.getText
                self._safeBoxPasswordEdit.setString = editBox.setText
            end
        end
    end
end

function BaseGameSafeBox:getTransferDeposit()
    return self._transferDeposit
end

function BaseGameSafeBox:onSave()
    self._gameController:playBtnPressedEffect()
    print("onSave")
    if self._safeBoxEdit then
        local editDeposit = tonumber(self._safeBoxEdit:getText())
        if "" ~= editDeposit and editDeposit and 0 < editDeposit then
            self._transferDeposit = editDeposit
            self._gameController:onSaveDeposit(editDeposit)
            self:setVisible(false)
        else
            
        end
    end
end

function BaseGameSafeBox:onTake()
    self._gameController:playBtnPressedEffect()
    print("onTake")
    if self._safeBoxEdit then
        local editDeposit = tonumber(self._safeBoxEdit:getText())
        if "" ~= editDeposit and editDeposit and 0 < editDeposit then
            self._transferDeposit = editDeposit
            if self._bHaveSecurePwd then
                self:showSafeBoxPassword(true)
            else
                self._gameController:onTakeDeposit(editDeposit, 0)
                self:setVisible(false)
            end
        else
            
        end
    end
end

function BaseGameSafeBox:onClose()
    self._gameController:playBtnPressedEffect()
    print("onClose")
    self:setVisible(false)
end

function BaseGameSafeBox:onPasswordOK()
    self._gameController:playBtnPressedEffect()
    print("onPasswordOK")
    local password = tonumber(self._safeBoxPasswordEdit:getText())
    if "" ~= password and password and 0 < password then
        self._securePwd = password
        self._gameController:onGetRndKey()
        self:showSafeBoxPassword(false)
    end
end

function BaseGameSafeBox:onPasswordCancel()
    self._gameController:playBtnPressedEffect()
    print("onPasswordCancel")
    self:showSafeBoxPassword(false)
end

function BaseGameSafeBox:setVisible(bVisible)
    if self._safeBoxPanel then
        self._safeBoxPanel:setVisible(bVisible)
    end
end

function BaseGameSafeBox:isVisible()
    if self._safeBoxPanel then
        return self._safeBoxPanel:isVisible()
    end
    return false
end

function BaseGameSafeBox:showSafeBox(bShow)
    self:setVisible(bShow)

    if bShow then
        if self._safeBoxEdit then
            self._safeBoxEdit:setText("")
        end
        if self._safeBoxEdit then
            self._safeBoxEdit:setText("")
        end
        self._securePwd = 0
        self._transferDeposit = 0
        self._bHaveSecurePwd = false
    end
end

function BaseGameSafeBox:setGameDeposit(gameDeposit)
    if self._textGameDeposit then
        self._textGameDeposit:setString(tostring(gameDeposit))
    end
end

function BaseGameSafeBox:setSafeBoxDeposit(safeBoxDeposit)
    if self._textSafeBoxDeposit then
        self._textSafeBoxDeposit:setString(tostring(safeBoxDeposit))
    end
end

function BaseGameSafeBox:onLookSafeDeposit(safeBoxDeposit, bHaveSecurePwd)
    self:setSafeBoxDeposit(safeBoxDeposit)

    if bHaveSecurePwd then
        self._bHaveSecurePwd = bHaveSecurePwd
    end
end

function BaseGameSafeBox:onSaveSafeDepositSucceed()
    local gameDeposit = 0
    local safeBoxDeposit = 0
    if self._textGameDeposit then
        gameDeposit = tonumber(self._textGameDeposit:getString())
    end
    if self._textSafeBoxDeposit then
        safeBoxDeposit = tonumber(self._textSafeBoxDeposit:getString())
    end

    self:setGameDeposit(gameDeposit - self._transferDeposit)
    self:setSafeBoxDeposit(safeBoxDeposit + self._transferDeposit)

    self._transferDeposit = 0
end

function BaseGameSafeBox:onTakeSafeDepositSucceed()
    local gameDeposit = 0
    local safeBoxDeposit = 0
    if self._textGameDeposit then
        gameDeposit = tonumber(self._textGameDeposit:getString())
    end
    if self._textSafeBoxDeposit then
        safeBoxDeposit = tonumber(self._textSafeBoxDeposit:getString())
    end

    self:setGameDeposit(gameDeposit + self._transferDeposit)
    self:setSafeBoxDeposit(safeBoxDeposit - self._transferDeposit)

    self._transferDeposit = 0
end

function BaseGameSafeBox:showSafeBoxPassword(bShow)
    if self._safeBoxPasswordPanel then
        self._safeBoxPasswordPanel:setVisible(bShow)
    end
end

local MIN_SECUREPWD_LEN = 8
local DEF_SECUREPWD_LEN = 16

function BaseGameSafeBox:calculateKeyResult(rndKey)
    local strSecurePwd = tostring(self._securePwd)
 
    if string.len(strSecurePwd) > DEF_SECUREPWD_LEN then
        return -1
    end
    if string.len(strSecurePwd) < MIN_SECUREPWD_LEN then
        return -1
    end
 
    local result = 0

    local a = math.modf(rndKey / 10000,1)
    local b = math.modf(rndKey % 10000,1)

    result = a + b

    local str = strSecurePwd
    while str:len() >= MIN_SECUREPWD_LEN / 2 do
        local add = str:sub(0,MIN_SECUREPWD_LEN / 2)
        local key = math.modf(checknumber(add), 1)
        result =result + key
        str = str:sub(MIN_SECUREPWD_LEN / 2 + 1)
    end
    if str:len() > 0 then
        local key = math.modf(checknumber(str), 1)
        result =result + key
    end

    return result
end

function BaseGameSafeBox:onTakeSafeRndkey(rndKey)
    local result = self:calculateKeyResult(rndKey)
    self._gameController:onTakeDeposit(self._transferDeposit, result)
    self:setVisible(false)
end

return BaseGameSafeBox
