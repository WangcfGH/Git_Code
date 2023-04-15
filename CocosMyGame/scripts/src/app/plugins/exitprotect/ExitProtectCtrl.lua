local ExitProtectCtrl=class('ExitProtectCtrl', myctrl('BaseTipCtrl'))
local viewCreater=import('src.app.plugins.exitprotect.ExitProtectView')
local player=mymodel('hallext.PlayerModel'):getInstance()
local constStrings=cc.load('json').loader.loadFile('ReliefStrings.json')
--local LoginLotteryCtrl = import("src.app.plugins.loginlottery.LoginLotteryCtrl")
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local relief=mymodel('hallext.ReliefActivity'):getInstance()
local user = mymodel('UserModel'):getInstance()

my.addInstance(ExitProtectCtrl)

function ExitProtectCtrl:onCreate(...)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self._viewNode = viewNode
    self:bindDestroyButton(viewNode.closeBt)

    local moduleList={
		checkinCtrl='CheckinCtrl',
	}

	local bindList={
		'checkin',
	}

--	self:bindSomeButtonsToPlugin({
--		bindList=bindList,
--		moduleList=moduleList
--	})

    self:bindSomeDestroyButtons(viewNode,{
		'closeBt',
		'checkinBt',
		'lotteryBt',
        'continueBt',
        'reliefBt',
	})
    
    bindList={
		'exitBt',
		'lotteryBt',
        'reliefBt',
	}
	
    self:bindUserEventHandler(viewNode,bindList)
    
    self:listenTo(relief,relief.RELIEF_DATA_UPDATED,handler(self,self.onTakeReliefSuccess))

    relief:checkAndUpdateReliefProtectData()

    viewNode.checkinEndImage:setVisible(false)
    viewNode.lotteryEndImage:setVisible(false)
    viewNode.reliefEndImage:setVisible(false)

--    local checkinMoney = cc.exports.gameProtectData.checkinMoney
    if viewNode.checkinBt then
        viewNode.checkinBt:setTouchEnabled(false)
        viewNode.checkinBt:setVisible(false)
    end
    
--    if player.bNeedCheckIn then   
--        viewNode.checkinEndImage:setVisible(false)
--    else
--        viewNode.checkinBt:setTouchEnabled(false)
--        viewNode.checkinEndImage:setVisible(true)
--        checkinMoney = 0
--    end

--    viewNode.silverNumText:setString(tostring(cc.exports.gameProtectData.checkinMoney))

--    viewNode.lotteryNumText:setString(viewNode.lotteryNumText:getString()..tostring(cc.exports.gameProtectData.lotteryCount))



--    if cc.exports.gameProtectData.lotteryCount <= 0 then        
--        viewNode.lotteryEndImage:setVisible(true)
--        viewNode.lotteryBt:setTouchEnabled(false)
--    end
    
    -- ÿ�ճ齱
    --local loginLottery = LoginLotteryCtrl:getInstance()
    local loginRewardMoney = 0
    local loginLotteryCount = 0
    --if loginLottery then
        loginRewardMoney = LoginLotteryModel:getAvailableRewardMoney()
        loginLotteryCount = LoginLotteryModel:getLotteryCount()
    --end
    viewNode.lotteryNumText:setString(viewNode.lotteryNumText:getString()..tostring(loginLotteryCount))
    if loginLotteryCount <= 0 then
        viewNode.lotteryEndImage:setVisible(true)
        viewNode.lotteryBt:setTouchEnabled(false)
    else
        viewNode.lotteryEndImage:setVisible(false)
        viewNode.lotteryBt:setTouchEnabled(true)
    end

    local protectData = cc.exports.gameProtectData

    --贵族系统赠送低保
    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status,reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief"..user.nUserID..os.date('%Y%m%d',os.time())))
    if not reliefUsedCount then reliefUsedCount = 0 end
    if status then   --使用低保缓存
        protectData.reliefCount =  reliefCount - reliefUsedCount
    end
    if protectData.reliefCount == nil or protectData.reliefCount <= 0 then        
        viewNode.reliefEndImage:setVisible(true)
        viewNode.reliefBt:setTouchEnabled(false)
    end

    viewNode.reliefNumText:setString(viewNode.reliefNumText:getString()..tostring(protectData.reliefCount or 0))
    viewNode.reliefMoneyText:setString(tostring(protectData.reliefMoney or 0))

--    viewNode.GetMoneyText:setString(tostring(checkinMoney + cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))
    --viewNode.GetMoneyText:setString(tostring(loginRewardMoney + cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))
    --viewNode.GetMoneyText:setString(tostring(cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))

    viewNode.lotteryBt:setVisible(cc.exports.gameProtectData.showLottery or false)
end

function ExitProtectCtrl:exitBtClicked( ... )
    my.finish()
end

function ExitProtectCtrl:lotteryBtClicked( ... )
    my.informPluginByName({pluginName='LoginLotteryCtrl'})
end

function ExitProtectCtrl:reliefBtClicked( ... )
    if player.bNeedRelief then
        my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_EXIT}})
    else
        my.informPluginByName({pluginName='TipPlugin',params={tipString=constStrings['RELIEF_FAIL']}})
    end
end

function ExitProtectCtrl:onTakeReliefSuccess()
    if not self._viewNode then return end
    local viewNode = self._viewNode

    if cc.exports.gameProtectData.reliefCount <= 0 then        
        viewNode.reliefEndImage:setVisible(true)
        viewNode.reliefBt:setTouchEnabled(false)
    end

    viewNode.reliefNumText:setString("补助*" .. tostring(cc.exports.gameProtectData.reliefCount))
    viewNode.reliefMoneyText:setString(tostring(cc.exports.gameProtectData.reliefMoney))

--    viewNode.GetMoneyText:setString(tostring(checkinMoney + cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))
    --viewNode.GetMoneyText:setString(tostring(loginRewardMoney + cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))
    --viewNode.GetMoneyText:setString(tostring(cc.exports.gameProtectData.reliefCount*cc.exports.gameProtectData.reliefMoney ))

end

return ExitProtectCtrl
