local InviteGiftAwardCtrl    = class('InviteGiftAwardCtrl', cc.load('BaseCtrl'))
local viewCreater   = import('src.app.plugins.invitegift.oldusergift.InviteGiftAwardView')
local InviteGiftUserNodeView  = import('src.app.plugins.invitegift.oldusergift.InviteGiftUserNodeView')
local OldUserInviteGiftModel  = import('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
      
InviteGiftAwardCtrl.RUN_ENTERACTION = true

InviteGiftAwardCtrl.YQYL_ANI_PATH = "res/hallcocosstudio/invitegiftactive/olduser/yqyl_title_ani.csb"

function InviteGiftAwardCtrl:onCreate( ... )
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    self._viewNode = viewNode
    local content = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/InviteGiftAwardConfig.json")
    self._config = cc.load("json").json.decode(content)
    self._userList ={}
    self._awardList = {}
    self.awardLen = 5
    for i = 1, self.awardLen do
        local nodeStr = "Panel_award_"..i
        self._awardList[i] = viewNode.rootNode:getChildByName(nodeStr)
        self._awardList[i].textMoney = self._awardList[i]:getChildByName("Text_money")
        self._awardList[i].textBout = self._awardList[i]:getChildByName("Text_bout")
        self._awardList[i].imgGeted = self._awardList[i]:getChildByName("Img_geted")
        self._awardList[i].btnGet = self._awardList[i]:getChildByName("Btn_get")
        self._awardList[i].ImgBg2 = self._awardList[i]:getChildByName("ImgBg2")
        local function onClickAward()
            self:getAwardByIndex(i)
		end
        self._awardList[i].btnGet:addClickEventListener(onClickAward)
    end
    
    
    self._userlistBt = viewNode.userlistBt
	self._imageListContent = viewNode.imageListContent
    self._inviteBt  = viewNode.inviteBt
    self._helpBt = viewNode.helpBt
    self._panelHelp = viewNode.panelHelp
    self._textActiveTime = viewNode.textActiveTime
    self._listUser = viewNode.listUser
    self._panelClick = viewNode.panelClick
    self._btnHelpclose = viewNode.btnHelpclose

    viewNode.textHelp:setString(self._config.oldTxtHelp)

    self._imageListContent:setVisible(false)
    self._panelHelp:setVisible(false)

    local scaleTo1 = cc.ScaleTo:create(0.5, 0.9)
    local scaleTo2 = cc.ScaleTo:create(0.5, 1)
    local ani = cc.Sequence:create(scaleTo1, scaleTo2)
    local repeatAct = cc.RepeatForever:create(ani)
    viewNode.imageQipao:runAction(repeatAct)

    local action = cc.CSLoader:createTimeline(self.YQYL_ANI_PATH)
    viewNode.titleAni:runAction(action)
    action:play("titleAni", true) 
    


    self:initClickEvent()

    self:refreshShow()
    self:initEvent()
end



function InviteGiftAwardCtrl:initEvent()
    OldUserInviteGiftModel:sendInviteGiftData()
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_UPDATE_CONFIG, handler(self, self.refreshShow))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_UPDATE_DATA, handler(self, self.refreshShow))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_TASKREARD_SUCCEED, handler(self, self.refreshShow))
  
end
--判断字符串是否是纯数字
function InviteGiftAwardCtrl:changeTime( time )
    local year = string.sub(time,1,4)
    local month = string.sub(time,5,6)
    local day = string.sub(time,7,8)
    return string.format("%s.%s.%s",year,month,day)
end

function InviteGiftAwardCtrl:refreshShow()
    local startTime,endTime = OldUserInviteGiftModel:getActiveTime()
    self._textActiveTime:setString(string.format("%s-%s",self:changeTime( startTime ),self:changeTime( endTime )))
    self:updateAwardShow()
    self:updateUserList()
end

function InviteGiftAwardCtrl:initClickEvent()
    if self._panelClick then
        local function onClickClose()
            self:playEffectOnPress()
            self._panelClick:setVisible(false)
            self._panelHelp:setVisible(false)
            self._imageListContent:setVisible(false)
		end
        self._panelClick:setVisible(false)
		self._panelClick:addClickEventListener(onClickClose)
    end
    if self._userlistBt then
		local function onShowList()
            self:playEffectOnPress()
            self._imageListContent:setVisible(true)
            self._panelHelp:setVisible(false)
            self._panelClick:setVisible(true)
            -- self:updateUserList()
		end
		self._userlistBt:addClickEventListener(onShowList)
	end

    if self._inviteBt then
		local function onClickInvite()
            print("显示分享邀请好友界面")  
            self:playEffectOnPress()
            my.informPluginByName({pluginName='InviteGiftShareCtrl'})
		end
		self._inviteBt:addClickEventListener(onClickInvite)
	end
    if self._helpBt then
		local function onClickHelp()
            self:playEffectOnPress()
            self._imageListContent:setVisible(false)
            self._panelHelp:setVisible(true)
            self._panelClick:setVisible(true)
		end
		self._helpBt:addClickEventListener(onClickHelp)
	end

    if self._btnHelpclose then
		local function onClickCloseHelp()
            self:playEffectOnPress()
            self._panelHelp:setVisible(false)
            self._panelClick:setVisible(false)
		end
		self._btnHelpclose:addClickEventListener(onClickCloseHelp)
	end
end


function InviteGiftAwardCtrl:updateAwardShow()
    local modelData = OldUserInviteGiftModel:getSortBindUserList()
    -- self._userList = modelData or {}
    local isShowGet = false --多个可领取时候 每次只显示一个可领取按钮
    local lateSelect = false--选中框选中下一个未领取的奖励项
    local rewardListCfg = OldUserInviteGiftModel:getRewardList()
    local len = #rewardListCfg
    local lateData = rewardListCfg[len]
    self._viewNode.textTipContents:setString(string.format("每邀请一个好友完成%s局你可以领取一份奖励，最高%s两",lateData.boutNum,self:NumbertoString(lateData.deposit)))
    for i = 1, self.awardLen do
        local reward = rewardListCfg[i]
        if not reward then
            self._awardList[i]:setVisible(false)
        else
            self._awardList[i]:setVisible(true)
            local maxBout = reward.boutNum
            self._awardList[i].textMoney:setString(self:NumbertoString(reward.deposit))--setMoney(reward.deposit)
            local data = modelData[i]
            if (not data or string.len(data.szOldRewardDate) <=1 ) and not lateSelect then
                lateSelect = true
                self._awardList[i].ImgBg2:setVisible(true)
            else
                self._awardList[i].ImgBg2:setVisible(false)
            end

            if data then
                local curBout = data.nBoutNum 
                curBout = curBout > maxBout and maxBout or curBout
                self._awardList[i].textBout:setString(string.format("%d/%d局",curBout,maxBout))
                local getTime = string.len(data.szOldRewardDate) > 1 and 1 or 0 
                self._awardList[i].imgGeted:setVisible( getTime ~= 0)
                self._awardList[i].textBout:setVisible( curBout<=maxBout and getTime <= 0)
                if not isShowGet and getTime <= 0 and curBout >= maxBout then
                    isShowGet = true
                    self._awardList[i].btnGet:setVisible(true)
                else 
                    self._awardList[i].btnGet:setVisible(false)
                end
            else
                self._awardList[i].imgGeted:setVisible(false)
                self._awardList[i].btnGet:setVisible(false)
                self._awardList[i].textBout:setString("待邀请")
            end
        end
        
    end
end


--银子数量转换字符串
function InviteGiftAwardCtrl:NumbertoString(nMoney, nDigit)
    if not nMoney then return "" end
    if nDigit and 'number' ~= type(nDigit) then return nMoney end
    if 'string' ~= type(nMoney) and 'number' ~= type(nMoney) then return "" end

    local sFormat, nCount = string.gsub(nMoney, "%d+", "%%s")
    if 0 >= nCount then return nMoney end

    local function format_func(func, count, digit)
        local nNumber, nResult = func(), nil
        if string.len(tostring(nNumber)) <= 3 then
            nResult = (tostring(nNumber))
        else
            local nInteger = math.floor(tostring(nNumber / 10000))
            if string.len(nInteger) >= digit then
                nResult = (tostring(nInteger).."万")
            else
                local nTemp = string.sub(tostring(nNumber / 10000), 1, digit + 1)
                nResult = (tostring(tonumber(nTemp)).."万")
            end
        end
        count = count - 1
        if 0 >= count then
            return nResult
        else
            return nResult, format_func(func, count, digit)
        end
    end
    local match_itor = string.gmatch(nMoney, "%d+")
    return string.format(sFormat, format_func(match_itor, nCount, nDigit or 4))
end


function InviteGiftAwardCtrl:updateUserList()
    self._listUser:removeAllItems()
    local modelData = OldUserInviteGiftModel:getSortBindUserList(1)
    local rewardListCfg = OldUserInviteGiftModel:getRewardList() or {}
    local maxBout =  rewardListCfg[1] and rewardListCfg[1].boutNum or 10
    local node = cc.CSLoader:createNode(InviteGiftUserNodeView.CsbPath)
	local view = my.NodeIndexer(node, InviteGiftUserNodeView.ViewConfig)
    local imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()
    local rankIdx = 1
    for i, v in ipairs(modelData) do
        my.fitStringInWidget(v.szNickName,view.textName,155)
        if string.len(v.szOldRewardDate) <= 1 then
		    view.valueScore:setString(string.format("%d/%d",v.nBoutNum,maxBout))
        else
            view.valueScore:setString("已领取")
        end
        view.imgIcon:setScale(0.8)
        local imageData = imageLoaderPlugin:getLocalImage_sync(v.nNewUserID, "100-100")
        local path = cc.exports.getHeadResPath(0)
        if imageData and imageData.path and imageData.path ~= ""  then
            path = imageData.path
        end
        view.imgIcon:loadTexture(path)
        local panel = view.backUnit:clone()
        self._listUser:pushBackCustomItem(panel)
        rankIdx = rankIdx + 1
	end

    self._listUser:scrollToTop(0.01,false)
end


function InviteGiftAwardCtrl:getAwardByIndex(index)
    self:playEffectOnPress()
    local modelData = OldUserInviteGiftModel:getSortBindUserList()
    local data = modelData[index]
    if not data then return end
  
    local isGet = OldUserInviteGiftModel:isCanGetAwardToday()
    if not isGet then
        self:informPluginByName('TipPlugin',{tipString="今日已领取过请明日再来领取"})
    else
        OldUserInviteGiftModel:requireGetAward(data.nNewUserID)
    end
end

return InviteGiftAwardCtrl
