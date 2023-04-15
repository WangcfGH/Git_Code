local AnchorRulePasswordCtrl 		= class('AnchorRulePasswordCtrl', cc.load('SceneCtrl'))
local AnchorTableModel 		        = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
local UserModel         	        = mymodel('UserModel'):getInstance()
local AnchorTableDef 		        = require('src.app.plugins.AnchorTable.AnchorTableDef')
local viewCreater 			        = import('src.app.plugins.AnchorTable.AnchorRulePasswordView')
local AnchorTableNodeView 	        = import('src.app.plugins.AnchorTable.AnchorTableNodeView')

-- 创建实例
function AnchorRulePasswordCtrl:onCreate(param)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    
    self._isCreateRoom = param.createRoom
    self._anchorTalbeCtrl = param.anchorTalbeCtrl
    self._tableNO = param.tableNO
    self._chairNO = param.chairNO
    
    self._passwordLen = 0
    self._password = nil
    self._ruleInfo = {
        BoutType        = AnchorTableDef.BOUT_TYPE_ONE_BOUT, 
        PlayType        = AnchorTableDef.PLAY_TYPE_NO_SHUFFLE, 
        EncryptionType  = AnchorTableDef.ENCRYPTION_TYPE_IS, 
        AnchorUserID    = UserModel.nUserID
    }
    
    self:initialListenTo()
    self:createNumBtn()
    self:initialUI()
    self:initialBtnClick()
end

-- 注册监听
function AnchorRulePasswordCtrl:initialListenTo()    
end

-- 创造数字按钮
function AnchorRulePasswordCtrl:createNumBtn()
    if self._viewNode == nil then return end	
        
    local viewNode = self._viewNode

    if viewNode.scrollViewPassword then
        viewNode.scrollViewPassword:removeAllChildren()
    end
        
    local normal = "hallcocosstudio/images/plist/AnchorRoom/img_password_normal_"
    local push = "hallcocosstudio/images/plist/AnchorRoom/img_password_normal_"
    local disable = "hallcocosstudio/images/plist/AnchorRoom/img_password_normal_"
    local path = "hallcocosstudio/images/plist/AnchorRoom/"
    for i=1, 9 do
        local numBtn = ccui.Button:create(normal..i..".png", push..i..".png", disable..i..".png", UI_TEX_TYPE_PLIST) 
        numBtn:setTouchEnabled(true)
        numBtn:setAnchorPoint(0.5, 0.5)
        local pX = 85 + ((i - 1) % 3 ) * 165
        local pY = 260 - math.modf((i - 1) / 3, 1) * 75
        numBtn:setPosition(cc.p(pX, pY))
        viewNode.scrollViewPassword:addChild(numBtn)
        numBtn:addTouchEventListener(function(sender, eventType) 
            if eventType == ccui.TouchEventType.ended then
                self:setPasswordNum(i)
            end
        end)        
    end
    
    local resetBtn = ccui.Button:create(path.."img_password_normal_reset.png", path.."img_password_press_reset.png", path.."img_password_press_reset.png", UI_TEX_TYPE_PLIST)
    my.presetAllButton(resetBtn)
    resetBtn:setTouchEnabled(true)
    resetBtn:setAnchorPoint(0.5, 0.5)
    resetBtn:setPosition(cc.p(85, 35))
    viewNode.scrollViewPassword:addChild(resetBtn)
    resetBtn:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            self:resetPassword()
        end
    end)
    
    local num0Btn = ccui.Button:create(path.."img_password_normal_0.png", path.."img_password_normal_0.png", path.."img_password_normal_0.png", UI_TEX_TYPE_PLIST)
    num0Btn:setTouchEnabled(true)
    num0Btn:setAnchorPoint(0.5, 0.5)
    num0Btn:setPosition(cc.p(250, 35))
    viewNode.scrollViewPassword:addChild(num0Btn)
    num0Btn:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            self:setPasswordNum(0)
        end
    end)

    local backBtn = ccui.Button:create(path.."img_password_normal_back.png", path.."img_password_press_back.png", path.."img_password_press_back.png", UI_TEX_TYPE_PLIST)
    my.presetAllButton(backBtn)
    backBtn:setTouchEnabled(true)
    backBtn:setAnchorPoint(0.5, 0.5)
    backBtn:setPosition(cc.p(415, 35))
    viewNode.scrollViewPassword:addChild(backBtn)
    backBtn:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            self:backPasswordNum()
        end
    end)

    viewNode.scrollViewPassword:setBounceEnabled(false)
end

-- 初始化界面
function AnchorRulePasswordCtrl:initialUI()
    if self._viewNode == nil then return end	
    
    local viewNode = self._viewNode

    viewNode.panelDisOpe:setVisible(false)

    if self._isCreateRoom then
        viewNode.panelSetRule:setVisible(true)
        viewNode.panelSetPassword:setVisible(false)
        viewNode.imgTitleSetPs:setVisible(true)
        viewNode.imgTitleJoinPs:setVisible(false)
    else
        viewNode.panelSetRule:setVisible(false)
        viewNode.panelSetPassword:setVisible(true)
        viewNode.imgTitleSetPs:setVisible(false)
        viewNode.imgTitleJoinPs:setVisible(true)
    end
    viewNode.checkBoxOneBout:setSelected(false)
    viewNode.checkBoxPassEight:setSelected(false)
    viewNode.checkBoxPassA:setSelected(false)
    viewNode.checkBoxNoShuffle:setSelected(false)
    viewNode.checkBoxClassic:setSelected(false)
    viewNode.checkBoxEncryption:setSelected(false)

    if self._ruleInfo.BoutType == AnchorTableDef.BOUT_TYPE_ONE_BOUT then
        viewNode.checkBoxOneBout:setSelected(true)
    elseif self._ruleInfo.BoutType == AnchorTableDef.BOUT_TYPE_PASS_EIGHT then
        viewNode.checkBoxPassEight:setSelected(true)
    else
        viewNode.checkBoxPassA:setSelected(true)
    end

    if self._ruleInfo.PlayType == AnchorTableDef.PLAY_TYPE_NO_SHUFFLE then
        viewNode.checkBoxNoShuffle:setSelected(true)    
    else
        viewNode.checkBoxClassic:setSelected(true)
    end

    if self._ruleInfo.EncryptionType == AnchorTableDef.ENCRYPTION_TYPE_IS then
        viewNode.checkBoxEncryption:setSelected(true)
        viewNode.btnSetPassword:setVisible(true)
        if self._password and self._passwordLen == AnchorTableDef.PASSWORD_LENGTH then
            viewNode.btnSetPassword:setTitleText("****")
            viewNode.txtTipClick:setVisible(false)
            viewNode.txtTipFormat:setVisible(false)
        else
            viewNode.btnSetPassword:setTitleText("")
            viewNode.txtTipClick:setVisible(true)
            viewNode.txtTipFormat:setVisible(true)
        end
    else
        viewNode.checkBoxEncryption:setSelected(false)
        viewNode.btnSetPassword:setVisible(false)
    end
end

-- 注册点击事件
function AnchorRulePasswordCtrl:initialBtnClick()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    viewNode.btnClosePs:addClickEventListener(handler(self, self.onHidePassword))
    viewNode.checkBoxOneBout:addEventListenerCheckBox(handler(self,self.onOneBoutChecked))
    viewNode.checkBoxPassEight:addEventListenerCheckBox(handler(self,self.onPassEightChecked))
    viewNode.checkBoxPassA:addEventListenerCheckBox(handler(self,self.onPassAChecked))
    viewNode.checkBoxNoShuffle:addEventListenerCheckBox(handler(self,self.onNoShuffleChecked))
    viewNode.checkBoxClassic:addEventListenerCheckBox(handler(self,self.onClassicChecked))
    viewNode.checkBoxEncryption:addEventListenerCheckBox(handler(self,self.onEncryptionChecked))
    viewNode.btnSetPassword:addClickEventListener(handler(self,self.onShowPassword))
    viewNode.btnSure:addClickEventListener(handler(self,self.onFinish))
    viewNode.btnClose:addClickEventListener(handler(self,self.onClickClose))
end

-- 隐藏规则界面
function AnchorRulePasswordCtrl:onHidePassword()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode
    if self._isCreateRoom then
        viewNode.panelSetPassword:setVisible(false)
        self:initialUI()
    else
        self:onClickClose()
    end    
end

-- 选择单局
function AnchorRulePasswordCtrl:onOneBoutChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    self._ruleInfo.BoutType = AnchorTableDef.BOUT_TYPE_ONE_BOUT
    viewNode.checkBoxOneBout:setSelected(true)
    viewNode.checkBoxPassEight:setSelected(false)
    viewNode.checkBoxPassA:setSelected(false)
end

-- 选择过八
function AnchorRulePasswordCtrl:onPassEightChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    self._ruleInfo.BoutType = AnchorTableDef.BOUT_TYPE_PASS_EIGHT
    viewNode.checkBoxOneBout:setSelected(false)
    viewNode.checkBoxPassEight:setSelected(true)
    viewNode.checkBoxPassA:setSelected(false)
end

-- 选择过A
function AnchorRulePasswordCtrl:onPassAChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    self._ruleInfo.BoutType = AnchorTableDef.BOUT_TYPE_PASS_A
    viewNode.checkBoxOneBout:setSelected(false)
    viewNode.checkBoxPassEight:setSelected(false)
    viewNode.checkBoxPassA:setSelected(true)
end

-- 选择不洗牌玩法
function AnchorRulePasswordCtrl:onNoShuffleChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    self._ruleInfo.PlayType = AnchorTableDef.PLAY_TYPE_NO_SHUFFLE
    viewNode.checkBoxNoShuffle:setSelected(true)
    viewNode.checkBoxClassic:setSelected(false)
end

-- 选择经典玩法
function AnchorRulePasswordCtrl:onClassicChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    self._ruleInfo.PlayType = AnchorTableDef.PLAY_TYPE_NORMAL
    viewNode.checkBoxNoShuffle:setSelected(false)
    viewNode.checkBoxClassic:setSelected(true)
end

-- 选择加密规则
function AnchorRulePasswordCtrl:onEncryptionChecked(sender,eventType)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    if(eventType == ccui.CheckBoxEventType.selected)then
        self._ruleInfo.EncryptionType = AnchorTableDef.ENCRYPTION_TYPE_IS
        viewNode.checkBoxEncryption:setSelected(true)
        viewNode.btnSetPassword:setVisible(true)
        if self._password then
            viewNode.btnSetPassword:setTitleText("****")
            viewNode.txtTipClick:setVisible(false)
            viewNode.txtTipFormat:setVisible(false)
        else
            viewNode.btnSetPassword:setTitleText("")
            viewNode.txtTipClick:setVisible(true)
            viewNode.txtTipFormat:setVisible(true)
        end
    elseif(eventType == ccui.CheckBoxEventType.unselected)then
        self._ruleInfo.EncryptionType = AnchorTableDef.ENCRYPTION_TYPE_NO
        viewNode.checkBoxEncryption:setSelected(false)
        viewNode.btnSetPassword:setVisible(false)
    end
end

-- 显示规则界面
function AnchorRulePasswordCtrl:onShowPassword()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode    
    viewNode.panelSetPassword:setVisible(true)
end

function AnchorRulePasswordCtrl:isJoinBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastSureBtnTime = self._lastSureBtnTime or 0
    if nowTime - self._lastSureBtnTime > GAP_SCHEDULE then
        self._lastSureBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

-- 完成规则或密码设置
function AnchorRulePasswordCtrl:onFinish()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode  

    if self:isJoinBtnClickGap() then return end

    if self._ruleInfo.EncryptionType == AnchorTableDef.ENCRYPTION_TYPE_IS and self._password == nil then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = "请先输入4位口令", removeTime=3}})
    else
        local limit = nil
        if self._ruleInfo.EncryptionType == AnchorTableDef.ENCRYPTION_TYPE_NO then
            self._password = nil
        else
            limit = {szPassword = self._password}
            if self._passwordLen ~= AnchorTableDef.PASSWORD_LENGTH then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString = "请先输入4位口令", removeTime=3}})
                return
            end
        end
        
        -- 校验下时间
        local curHourMiu = AnchorTableModel:getCurrentHourMiu()
		local bHourMiu, eHourMiu = AnchorTableModel:anchorTime(UserModel.nUserID)
		local bHour = math.modf(bHourMiu / 100) 
		local bMiu = bHourMiu % 100
		local eHour = math.modf(eHourMiu / 100) 
		local eMiu = eHourMiu % 100
        if curHourMiu < bHourMiu or curHourMiu >= eHourMiu then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = "创房时间过期", removeTime=3}})
            if self._anchorTalbeCtrl and self._anchorTalbeCtrl.refreshTableList then
                self._anchorTalbeCtrl:refreshTableList()
            end
            self:onClickClose()
            return	
		end

        AnchorTableModel:setTablePassword(self._password)
        AnchorTableModel:setTableRule(self._ruleInfo)
        local talbeNoBegin, tableNoEnd = AnchorTableModel:anchorTableNO(UserModel.nUserID)
        if self._ruleInfo.PlayType == AnchorTableDef.PLAY_TYPE_NO_SHUFFLE then
            self._tableNO = toint(talbeNoBegin) - 1
        else
            self._tableNO = toint(tableNoEnd) - 1
        end
        self._chairNO = 0
        if self._ruleInfo.EncryptionType == AnchorTableDef.ENCRYPTION_TYPE_NO then
            AnchorTableModel:reqSeatForce(self._tableNO, self._chairNO, limit)
        else
            AnchorTableModel:reqSeat(self._tableNO, self._chairNO, limit)
        end
        
        viewNode.panelDisOpe:setVisible(true)
        my.scheduleOnce(function()
            self:onClickClose()
        end, 0.5)
    end
end

-- 设置密码
function AnchorRulePasswordCtrl:setPasswordNum(num)
    if self._viewNode == nil then return end
    local viewNode = self._viewNode   

    if self._passwordLen >= AnchorTableDef.PASSWORD_LENGTH then return end

    self._passwordLen = self._passwordLen + 1
    if self._password then
        self._password = self._password..tostring(num)
    else
        self._password = tostring(num)
    end
    if viewNode["txtPsValue"..self._passwordLen] then
        viewNode["txtPsValue"..self._passwordLen]:setString("*")
    end

    if self._passwordLen == AnchorTableDef.PASSWORD_LENGTH then
        if self._isCreateRoom then
            self:initialUI()
        else
            local limit = {szPassword = self._password}
            AnchorTableModel:setTablePassword(self._password)
            AnchorTableModel:setLastSeletInfo(self._tableNO, self._chairNO)
            if AnchorTableModel:haveAnchorPlayer(self._tableNO) then
                AnchorTableModel:reqSeat(self._tableNO, self._chairNO, limit)                
            else
                my.informPluginByName({pluginName='TipPlugin',params={tipString="主播已散桌",removeTime=3}})
            end
            viewNode.panelDisOpe:setVisible(true)
            my.scheduleOnce(function()
                self:onClickClose()
            end, 0.5)
        end
    end
end

-- 重置密码
function AnchorRulePasswordCtrl:resetPassword()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode
    self._passwordLen = 0
    self._password = nil
    for i=1, AnchorTableDef.PASSWORD_LENGTH do
        viewNode["txtPsValue"..i]:setString("")
    end
end

-- 回退密码
function AnchorRulePasswordCtrl:backPasswordNum()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode

    if self._passwordLen <= 0 then return end

    if viewNode["txtPsValue"..self._passwordLen] then
        viewNode["txtPsValue"..self._passwordLen]:setString("")
    end

    self._passwordLen = self._passwordLen - 1
    if self._passwordLen == 0 then
        self._password = nil
    else
        self._password = string.sub(self._password, 1, self._passwordLen)
    end
end

-- 关闭插件
function AnchorRulePasswordCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

-- 退出插件
function AnchorRulePasswordCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    AnchorRulePasswordCtrl.super.removeSelf(self)
end

return AnchorRulePasswordCtrl