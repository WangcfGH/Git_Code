local viewCreater=import('src.app.plugins.ArenaModel.ArenaChangeRoomView')
local ArenaChangeRoomCtrl=class('ArenaChangeRoomCtrl',cc.load('BaseCtrl'))
local ArenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local config = cc.exports.GetRoomConfig()
local ArenaModel = require("src.app.plugins.arena.ArenaModel"):getInstance()

local function newItemButton(resPath, nodeName)
    local nodeResource = cc.CSLoader:createNode(resPath)
    local itemBtn = nodeResource:getChildByName(nodeName)
    nodeResource:removeChild(itemBtn, true)
    return itemBtn
end

local function secondItemsPositonCalculate( count , RoomPanel)
    local posList = {}
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    if( count == 1 ) then
        local startX = visibleSize.width/2
        local startY = visibleSize.height/4 + origin.y

        posList[1]={x=startX, y=startY }
        
    elseif( count == 2 )then
        
        local startX = visibleSize.width/4 + 45
        local startY = visibleSize.height/4 + origin.y - 40
        local gap = visibleSize.width/2 - 90

        for i=1,count do
            posList[i]={x=startX+(i-1)*gap, y=startY }
        end
    elseif (count >= 3 and count <= 6 and RoomPanel ~= nil) then
        local RoomSize = RoomPanel:getSize()
        local startX = RoomSize.width/4 + 45
        local startY = RoomSize.height/2 + 150
        local gapX = RoomSize.width/2 -55
        local gapY = 200

        for i=1,count do
            posList[i]={x=startX + gapX*((i-1)%2), y=startY-gapY*math.floor((i-1)/2) }
        end
        
    else
        local startX = visibleSize.width/4
        local startY = visibleSize.height/3 + origin.y
        local gapX = visibleSize.width/2
        local gapY = visibleSize.height/4

        for i=1,count do
            posList[i]={x=startX+math.modf((i-1)/2)*gapX, y=startY-((i-1)%2)*gapY }
        end
    end

    return posList
end

function ArenaChangeRoomCtrl:onCreate(params)
    self._params = params
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    
    local matchesInfo = params.matchesInfo
    local roomsInfo = params.roomsInfo

    local count = 0
    local resPath = "res/hallcocosstudio/room/roommodel3.csb"
    for i = 1, #roomsInfo do
        local roomBtn = newItemButton(resPath, "Btn_Room")
        self:showArenaRoomItem(roomBtn, matchesInfo[i], roomsInfo[i], i)
        viewNode.changePanel:addChild(roomBtn)
        count = count + 1
        roomBtn:setTag(1000 + count)
    end

    local posList = secondItemsPositonCalculate( count , viewNode.changePanel)

    for i = 1, count do
        local node = viewNode.changePanel:getChildByTag(1000 + i)
        node:setPosition(posList[i])
    end
end

local ArenaImageForMinDeposit = {"hallcocosstudio/images/plist/Arena/Arena_img_figure1.png","hallcocosstudio/images/plist/Arena/Arena_img_figure2.png",
                                    "hallcocosstudio/images/plist/Arena/Arena_img_figure3.png","hallcocosstudio/images/plist/Arena/Arena_img_figure4.png",
                                        "hallcocosstudio/images/plist/Arena/Arena_img_figure5.png"}

function ArenaChangeRoomCtrl:showArenaRoomItem(roomBtn, arenaData, arenaRoom, index)
    if arenaRoom["isDepositRoom"] == true then
        local image = roomBtn:getChildByName("Img_Icon_Score")
        if image then
	        image:setVisible(false)
        end
	else
        local image = roomBtn:getChildByName("Img_Icon_Silver")
        if image then
	        image:setVisible(false)
        end
	end

    for i = 1, 4 do
        roomBtn:getChildByName("Img_Plus"..i):setVisible(false)
    end
    
    local matchGradeIndex = math.max(ArenaModel:getMatchGradeIndex(arenaData.nMatchID) - 1, 1)
    roomBtn:getChildByName("Img_SceneIcon"):loadTexture(ArenaImageForMinDeposit[matchGradeIndex], 1)
	--set text
	local text
	if arenaRoom["isDepositRoom"] == true then
	    text = roomBtn:getChildByName("Text_Condition_Liang")
	    roomBtn:getChildByName("Text_Condition_Feng"):setVisible(false)
	    text:setString( text:getString()..arenaRoom["nMinDeposit"] )
	else
	    text = roomBtn:getChildByName("Text_Condition_Feng")
	    roomBtn:getChildByName("Text_Condition_Liang"):setVisible(false)
        text:setString(config["ROOM_SCORE_UNLIMITED"])
	end

	text = roomBtn:getChildByName("Text_Online")
    local onlineUserCount = arenaRoom["nUsers"]
    if onlineUserCount and onlineUserCount ~= "" then
        text:setString(onlineUserCount)
    end
    local matchConfig = ArenaRankData:getMatchConfig()
    local addScore = matchConfig["RoomAddition_" .. arenaRoom.nRoomID]
    local roomNameImg = roomBtn:getChildByName("Img_RoomName")
    
    --竞技场名字
    if string.find(arenaData.szMatchName, config['ARENA_XINSHOU_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi1.png", 1)
    elseif string.find(arenaData.szMatchName, config['ARENA_CHUJI_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi2.png", 1)
    elseif string.find(arenaData.szMatchName, config['ARENA_ZHONGJI_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi3.png", 1)
        roomBtn:getChildByName("Img_Plus1"):setVisible(true)
        if addScore then
            roomBtn:getChildByName("Img_Plus1"):getChildByName("Text_describe"):setString(addScore .. '%')
        end    
    elseif string.find(arenaData.szMatchName, config['ARENA_GAOJI_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi4.png", 1)
        roomBtn:getChildByName("Img_Plus2"):setVisible(true)
        if addScore then
            roomBtn:getChildByName("Img_Plus2"):getChildByName("Text_describe"):setString(addScore .. '%')
        end
    elseif string.find(arenaData.szMatchName, config['ARENA_DASHI_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi5.png", 1)
        roomBtn:getChildByName("Img_Plus3"):setVisible(true)
        if addScore then
            roomBtn:getChildByName("Img_Plus3"):getChildByName("Text_describe"):setString(addScore .. '%')
        end
    elseif string.find(arenaData.szMatchName, config['ARENA_ZHIZHUN_ROOM']) then
        roomNameImg:loadTexture("hallcocosstudio/images/plist/Arena/Arena_hc_zi6.png", 1)
        roomBtn:getChildByName("Img_Plus4"):setVisible(true)
        if addScore then
            roomBtn:getChildByName("Img_Plus4"):getChildByName("Text_describe"):setString(addScore .. '%')
        end
    end

    local function callBack()
        if self._params.callback then
            self._params.callback(index)
        end
        self:removeSelfInstance()
    end
    roomBtn:addClickEventListener(callBack)
end

return ArenaChangeRoomCtrl