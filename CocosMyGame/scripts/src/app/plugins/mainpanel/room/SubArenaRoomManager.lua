local SubArenaRoomManager = class("SubArenaRoomManager")

local PlayerModel   = mymodel("hallext.PlayerModel"):getInstance()
local UserModel     = mymodel('UserModel'):getInstance()
local SettingsModel = mymodel("hallext.SettingsModel"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
local mySignUpStatus = require("src.app.plugins.SignUp.SignUpStatus"):getInstance()
local mySignUpPayStatus = require("src.app.plugins.SignUp.SignUpPayStatus"):getInstance()
local arenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()

function SubArenaRoomManager:ctor(roomManager)
    self._mainCtrl = roomManager._mainCtrl
    self._roomManager = roomManager

    self._arenaRoomContext = {
    }
    self._arenaRoomContextOut = HallContext.context["arenaRoomContext"]

    self._mainCtrl:listenTo(ArenaModel, ArenaModel.EVENT_MAP["arenaModel_userArenaInfoUpdatedByGiveUp"], handler(self, self.onUserArenaInfoUpdatedByGiveUp))
end

function SubArenaRoomManager:getSecondLayerArena()
    local secondLayer = self._roomManager._roomContext["secondLayer"]
    if secondLayer and secondLayer.layerName == "arena" then
        return secondLayer
    end

    return nil
end

function SubArenaRoomManager:getArenaData(callback)
    print("SubArenaRoomManager:getAreaConfig")

    ArenaModel:getArenaConfig(function(dataMap, respondType)
        if respondType == mc.UR_OPERATE_SUCCEED or respondType == 'local' then
            print("begin getUserArenaInfo")
            ArenaModel:getUserArenaInfo(function(dataMap2, respondType2)
                self._arenaRoomContextOut["isArenaPlayer"] = true
                self._roomManager:_createAndShowSecondLayer("arena", callback)
            end)
        else
            self._roomManager:_showTip(self._roomManager._roomStrings['NOT_OPEN'])
        end
    end)
end

function SubArenaRoomManager:dealOnBackFromGame()
    if not self:getSecondLayerArena() then return end

    my.scheduleOnce(function()
        if ArenaModel.userArenaData and ArenaModel.userArenaData.nHP <= 0 then
            self:getSecondLayerArena():refreshView()
        else
            if ArenaModel.userMatchInfo and ArenaModel.userArenaData then
                self:getSecondLayerArena():refreshView()
            end
        end
    end, 0.1)
end

function SubArenaRoomManager:goToArenaMatch(matchIndex)
    local matchInfo = ArenaModel.arenaFreeMatchesInfo[matchIndex]
    if matchInfo == nil then
        print("SubArenaRoomManager:goToArenaMatch, but matchInfo is nil, matchIndex "..tostring(matchIndex))
        return
    end
    local roomInfo = ArenaModel.arenaRoomsInfo[matchIndex]

    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local nplevelEnable = NobilityPrivilegeModel:isRoomEnableEnterByNPLevel(roomInfo["nRoomID"])
    if not nplevelEnable then
        local roomNPLevel = NobilityPrivilegeModel:getRoomNPLevelLimit(roomInfo["nRoomID"])
        local tipString = "当前房间需要贵族" .. tostring(roomNPLevel) .. "才能进入"
        my.informPluginByName({ pluginName = 'ChooseDialog', params = {tipContent = tipString }})
        return
    end

    local signUpRemainCount = ArenaModel:GetSignUpCountToday()
    if signUpRemainCount < 0 then
        local signUpPayRemainCount = ArenaModel:GetSignUpPayCountToday()
        if signUpPayRemainCount < 0 then
            local tipStr = self._roomManager._roomStrings['ENOUGH_SIGNUP_TODAY']
            self._roomManager:_showTip(tipStr) 
            return
        else
            local silverMatchInfo = ArenaModel.arenaSilverMatchesInfo[matchIndex]
            local chargingEndDeposit = (UserModel.nDeposit - silverMatchInfo.nSilverNum)
            if chargingEndDeposit < 0 then
                chargingEndDeposit = 0
            end
            if self:checkEnterMatchDeposit(chargingEndDeposit, roomInfo, silverMatchInfo) then
                local params = {
                    arenaRoomsData = roomInfo,
                    arenaData = silverMatchInfo, 
                    signUpCount = signUpPayRemainCount, 
                    maxSignUpCount = ArenaModel.maxSignUpCount,
                    callbackOnBuy = handler(self, self.signUp)
                }
                my.informPluginByName({pluginName = 'ArenaContinueBuyCtrl', params = params})
            end
            return
        end
    end

    if self:checkEnterMatchDeposit(UserModel.nDeposit, roomInfo, matchInfo) then
        if arenaRankData:isOpen() and arenaRankData:getStatus() == arenaRankData.STATUS_NOT_SIGN_UP then
            local params = {
                arenaRoomsData = roomInfo,
                arenaData = matchInfo,
                signUpCount = signUpRemainCount,
                callbackContinue = handler(self, self.signUp)
            }
            my.informPluginByName({pluginName = 'SignUpToArenaCtrl', params = params})
        else
            self:signUp(roomInfo, matchInfo)
        end
    end
end

function SubArenaRoomManager:signUp(roomInfo, matchInfo)
    print("SubArenaRoomManager:signUp")
    if not self:getSecondLayerArena() then
        print("arena secondlayer is nil!!!")
        return
    end

    print("SubArenaRoomManager:signUp")
    if not UIHelper:checkOpeSerial("opeArenaSignUp", 5.0) then
        print("an signuping already exist!!!")
        return
    end
    UIHelper:refreshOpeBegin("opeArenaSignUp")

    my.startLoading("处理中，请稍等...")
    ArenaModel:signUpArenaMatch(matchInfo.nMatchID, matchInfo.nSignUpPayType, function(respondType, data, msgType, dataMap)
        UIHelper:refreshOpeEnd("opeArenaSignUp")

        if respondType ~= mc.UR_OPERATE_SUCCEED then 
            print("sorry, signUp Failed!")
            my.stopLoading()
            return   
        elseif dataMap and dataMap.nError <= 0  then
            local text = dataMap.szDes
            if text == self._roomManager._roomStrings['SIGNUP_ED'] or text == self._roomManager._roomStrings['SIGNUP_ANOTHER'] then
                if ArenaModel.userMatchInfo.nMatchID and ArenaModel.userArenaData.nMatchID then
                    if self:getSecondLayerArena() then self:getSecondLayerArena():refreshView() end
                else
                    ArenaModel:getUserArenaInfo(function(dataMap)
                        if self:getSecondLayerArena() then self:getSecondLayerArena():refreshView() end
                    end)  
                end
            end
            self._roomManager:_showTip(text)  
            my.stopLoading()
        else 
            local signUpCountInfo = {
                signUpCount = mySignUpStatus:getSignUpCacheFile().signUpCount + 1 , 
                timeName = mySignUpStatus:getTodayDate(), 
                isSignUped = true 
            }
            mySignUpStatus:setMySignUpDatas(signUpCountInfo)

            if matchInfo.nSignUpPayType ~= 1 then
                local signUpPayCountInfo = {
                    signUpCount = mySignUpPayStatus:getSignUpCacheFile().signUpCount + 1 , 
                    timeName = mySignUpPayStatus:getTodayDate(), 
                    isSignUped = true 
                }
                mySignUpPayStatus:setMySignUpDatas(signUpPayCountInfo)
            end

            self._roomManager:tryEnterRoom(roomInfo["nRoomID"], false, nil)
            ArenaModel:getUserArenaInfo(function(dataMap)
                ArenaModel:getMatchInfoByMatchIDFromLocal(dataMap.nMatchID)         
            end)
        end
     end)
end

function SubArenaRoomManager:checkEnterMatchDeposit(userDeposit, roomInfo, matchInfo)
    if  userDeposit <= roomInfo.nMaxDeposit and userDeposit >= roomInfo.nMinDeposit then
        return true
    elseif userDeposit > roomInfo.nMaxDeposit then
        local myDeposit = userDeposit
        local minDeposit = cc.exports.GetPlayerMinDeposit()
        local leftDeposit = roomInfo.nMaxDeposit
        if leftDeposit <  minDeposit then
            leftDeposit = minDeposit
        end

        local saveDepositNum = myDeposit - leftDeposit
        if saveDepositNum <= 0 then
            -- 优先满足最少携带银，如果不能满足，使用（下面）的方式计算
            saveDepositNum = myDeposit - roomInfo.nMaxDeposit
        end
        local MyGamePromptMoreMoney = import("src.app.Game.mMyGame.MyGamePromptMoreMoney")
        local prompt = MyGamePromptMoreMoney:create(self._mainCtrl, saveDepositNum, true, true)
        if prompt then
            prompt:setGotoRoomBtnState(false)
            self._mainCtrl._viewNode:addChild(prompt, 100)
            prompt:setPosition(display.center)
        end
    elseif userDeposit < roomInfo.nMinDeposit then
        self._roomManager:checkRelief(userDeposit, roomInfo)
    end
    
    return false
end

function SubArenaRoomManager:continueArenaMatch(userArenaData)
    print("SubArenaRoomManager:continueArenaMatch")
    if not self:getSecondLayerArena() then
        print("arena secondlayer is nil")
        return
    end

    if userArenaData.nHP == 1  then
        my.startLoading("处理中，请稍等...")
        ArenaModel:getUserArenaInfo(function(theUserArenaData)
            if userArenaData.nHP == 0 then
                 local tipStr = self._roomManager._roomStrings['HP_NOT_ENOUGH']
                 self._roomManager:_showTip(tipStr)
                 if self:getSecondLayerArena() then
                    self:getSecondLayerArena():refreshView()
                 end
                 return
             else
                local matchGradeIndex, matchIndex = ArenaModel:getMatchGradeIndex(theUserArenaData.nMatchID)
                local roomInfo = ArenaModel.arenaRoomsInfo[matchIndex]
                if roomInfo then
                    self._roomManager:tryEnterRoom(roomInfo["nRoomID"], false, nil)
                end
             end
        end)
    else
        local matchGradeIndex, matchIndex = ArenaModel:getMatchGradeIndex(userArenaData.nMatchID)
        local roomInfo = ArenaModel.arenaRoomsInfo[matchIndex]
        if roomInfo then
            self._roomManager:tryEnterRoom(roomInfo["nRoomID"], false, nil)
        end
    end         
end

function SubArenaRoomManager:onUserArenaInfoUpdatedByGiveUp(data)
    if self:getSecondLayerArena() then
        self:getSecondLayerArena():refreshView()
    end
end

return SubArenaRoomManager