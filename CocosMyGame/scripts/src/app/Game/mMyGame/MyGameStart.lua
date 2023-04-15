local BaseGameStart = import("src.app.Game.mBaseGame.BaseGameStart")
local MyGameStart = class("MyGameStart", BaseGameStart)
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

function MyGameStart:init()
    if not self._startPanel then return end
    
    local function onStartGame()
        self:onStartGame()

        --17期客户端埋点
        local params = {}
        local curRoom = PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if curRoom and curRoom.nRoomID then
            params["roomID"] = curRoom.nRoomID
        end
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_READY_BTN, params)
    end
    self._btnStart = self._startPanel:getChildByName("Btn_Start")
    if self._btnStart then
        self._btnStart:addClickEventListener(onStartGame)
    end

    local function onChangeTable()
        self:onChangeTable()
    end
    self._btnChange = self._startPanel:getChildByName("Btn_Switch")
    if self._btnChange then
        self._btnChange:addClickEventListener(onChangeTable)        
    end    

    local function onRandomTable()  -- 随机房 匹配按钮
        self:onRandomTable()
        --17期客户端埋点
        local params = {}
        local curRoom = PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if curRoom and curRoom.nRoomID then
            params["roomID"] = curRoom.nRoomID
        end
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_MATCH_TABLE_BTN, params)
    end
    self._btnRandom = self._startPanel:getChildByName("Btn_Match")
    if self._btnRandom then
        self._btnRandom:addClickEventListener(onRandomTable)
    end

    local function onReturnTeamRoom()
        self:onReturnTeamRoom()
    end
    self._btnReturnTeam = self._startPanel:getChildByName("Btn_ReturnTeam")
    if self._btnReturnTeam then
        self._btnReturnTeam:addClickEventListener(onReturnTeamRoom)
    end

    self._waitingTip = self._startPanel:getChildByName("Start_sp_waiting")

    self._btnJump = self._startPanel:getChildByName("Btn_Jump") -- 进阶跳转房间（动态设置图片）
    self._btnJump:setVisible(false)
    
    -- 主播房，隐藏换桌换座房间跳转，准备按钮居中
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then

        self._btnChange:setVisible(false)
        self._btnRandom:setVisible(false)
        self._btnStart:setPositionX(self._startPanel:getContentSize().width / 2)
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        self._btnStart:setVisible(false)
        self._btnChange:setVisible(false)
        self._btnRandom:setVisible(false)
        self._btnJump:setVisible(false)
    end
    self:setVisible(false)
end


function MyGameStart:ope_ShowStart(bShow)
    if self._gameController and self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() and self._gameController._canReturnChartered then
        bShow = false
    end

    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        self:setVisible(bShow)
        if bShow and self._btnStart then
            self._btnStart:setVisible(true)
            self._btnStart:setTouchEnabled(true)
            self._btnStart:setBright(true)
        end
        return
    end

    if bShow then
        if self._gameController then
            if self._gameController:isRandomRoom() then
                if self._btnRandom then
                    self._btnRandom:setVisible(true)
                    if self._btnReturnTeam then
                        self._btnReturnTeam:setVisible(false)
                    end
                    if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
                        self._btnRandom:setVisible(false)
                        if self._btnReturnTeam then
                            self._btnReturnTeam:setVisible(true)
                        end
                    end
                end
                if self._btnChange then
                    self._btnChange:setVisible(false)
                end
            else
                if self._btnChange then
                    self._btnChange:setVisible(true)
                end
                if self._btnRandom then
                    self._btnRandom:setVisible(false)
                end
            end
        end

        if self._waitingTip then
            self._waitingTip:setVisible(false)
        end

        if self._btnStart then
            self._btnStart:setVisible(true)
            self._btnStart:setTouchEnabled(true)
            self._btnStart:setBright(true)
        end

        --添加进阶提示按钮、逻辑
        if self._gameController._promptRoom and not mymodel('NewUserGuideModel'):getInstance():isNeedGuide() then
            local posX = self._btnChange:getPositionX()
            local isShowJumpButton = false
            local imgPath = ""

            local jumpRoomName = self._gameController._promptRoom["targetRoomInfo"]["szRoomName"]
            --[[jumpRoomName = self._gameController._promptRoom.original.szRoomName
            jumpRoomName = MCCharset:getInstance():gb2Utf8String( jumpRoomName, string.len(jumpRoomName) )]]--           

            local roomNameSecond = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SECOND")        -- 初级房
            local roomNameThird = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_THIRD")          -- 中级房
            local roomNameFourth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FOURTH")        -- 高级房
            local roomNameFiveth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_FIVETH")        -- 大师房
            local roomNameSixth = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SIXTH")          -- 至尊房
            local roomNameSeventh = self._gameController:getGameStringByKey("G_GAME_ROOMNAME_SEVENTH")      -- 宗师房

            cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/JumpRoomBtns.plist")
            if jumpRoomName ==  MCCharset:getInstance():gb2Utf8String(roomNameSecond, string.len(roomNameSecond) )then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomLow.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameThird, string.len(roomNameThird)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomMiddle.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFourth, string.len(roomNameFourth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomHigh.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameFiveth, string.len(roomNameFiveth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomMaster.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSixth, string.len(roomNameSixth)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomSupreme.png"
            elseif jumpRoomName == MCCharset:getInstance():gb2Utf8String(roomNameSeventh, string.len(roomNameSeventh)) then
                isShowJumpButton = true
                imgPath = "GameCocosStudio/plist/JumpRoomBtns/Game_Btn_RoomZongShi.png"
            end

            local jumpRoomID = self._gameController._promptRoom["targetRoomInfo"].nRoomID
            local RoomListModel = require("src.app.GameHall.room.model.RoomListModel"):getInstance()
            if RoomListModel:isLimitTimeOpenRoom(jumpRoomID) then
                local curTimeStamp = MyTimeStamp:getLatestTimeStamp()
                local startHour, startMinute, endHour, endMinute = RoomListModel:getOpenTime(jumpRoomID)
                local curYear = os.date("%Y", curTimeStamp)
                local curMonth = os.date("%m", curTimeStamp)
                local curDay = os.date("%d", curTimeStamp)
                local startTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=startHour, min=startMinute, sec=0})
                local endTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=endHour, min=endMinute, sec=0})
                if curTimeStamp < startHour or endTimeStamp < curTimeStamp then
                    isShowJumpButton = false
                end
            end

            if true ==  isShowJumpButton and not PUBLIC_INTERFACE.IsStartAsJiSu() then
                self._btnStart:setPositionX(posX + 220)
                self._btnJump:setPositionX(posX + 440)     
                self._btnJump:setVisible(true)
                self._btnJump:loadTextureNormal(imgPath, 1)
                self._btnJump:addClickEventListener(handler(self, self.onGoToRoom))
            end
        else
            local posX = self._btnChange:getPositionX()
            self._btnStart:setPositionX(posX + 380);   -- 恢复成csb默认的坐标
            self._btnJump:setVisible(false)
	        self._gameController._promptRoom = nil
        end

        self:setVisible(true)
    else
    	self._gameController._promptRoom = nil
        self:setVisible(false)
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        if self._btnChange then
            self._btnChange:setVisible(false)
        end

        if self._btnRandom then
            self._btnRandom:setVisible(false)
        end

        if self._btnJump then
            self._btnJump:setVisible(false)
        end

        if self._btnStart then
            self._btnStart:setVisible(false)
        end
    end
end

function MyGameStart:onReturnTeamRoom()
    if self._gameController and self._gameController._baseGameConnect then
        self._gameController._baseGameConnect:TeamGameRoom_LeaveGame()
    end
end

function MyGameStart:onGoToRoom()
    if self._gameController._promptRoom == nil then
        return
    end

    self._gameController:playBtnPressedEffect()
    self._gameController._baseGameConnect:gc_LeaveGame()
    self._gameController._promptRoom.jumpNewRoom = true -- 用于区分是进阶跳转还是 直接退出
    --self:removeFromParentAndCleanup()  --?
end

function MyGameStart:showWaitArrangeTable(bShow)
    MyGameStart.super.showWaitArrangeTable(self, bShow)
    if bShow then
        if self._btnJump then
            self._btnJump:setVisible(false)
        end
    end
end


function MyGameStart:rspStartGame()
    MyGameStart.super.rspStartGame(self)
    if self._btnStart then
        if self._btnJump and self._btnJump:isVisible() then
            self._btnStart:setVisible(false)
        end
    end

    if self._btnJump then
        self._btnStart:setTouchEnabled(false)
        self._btnStart:setBright(false)
    end
end

return MyGameStart