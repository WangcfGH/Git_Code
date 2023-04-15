
local SKHandCards = import("src.app.Game.mSKGame.SKHandCards")
local SKShownCards = class("SKShownCards", SKHandCards)

local SKCardShown               = import("src.app.Game.mSKGame.SKCardShown")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

function SKShownCards:ctor(drawIndex, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._panelShowCards        = nil
    self._panelBackGroud        = nil
    self._moveBtn               = nil
    self._showText              = nil

    self._bMoveOut              = false
    self._isMoving              = false
    self._moveTimerID           = nil

    self._drawIndex             = drawIndex
    self._cards                 = {}
    self._cardsCount            = 0

    self:init()
end

function SKShownCards:init()
    --[[local gameNode = self._gameController._baseGameScene._gameNode
    if gameNode then
        self._panelShowCards = gameNode:getChildByName("Node_seencard_"..tostring(self._drawIndex))
        if self._panelShowCards then
            self._panelShowCards:setLocalZOrder(SKGameDef.SK_ZORDER_CARD_SHOWN)

            self._panelBackGroud    = self._panelShowCards:getChildByName("Panel_animation")
            if self._panelBackGroud then
                self._moveBtn           = self._panelBackGroud:getChildByName("Btn_seencard")
                self._showText          = self._panelBackGroud:getChildByName("Node_text_animation")
            end
            local function onMoveBtnClick()
                self:movePanel(not self._bMoveOut)
            end
            if self._moveBtn then
                self._moveBtn:addClickEventListener(onMoveBtnClick)
            end
        end
    end--]]

    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = SKCardShown:create(self._drawIndex, self, i)
    end

    self:setVisible(false)
end

function SKShownCards:movePanel(bMoveOut)
    if self._isMoving then return end
    local function setDontMove()
        self:setDontMove()
    end
    self._moveTimerID   = cc.Director:getInstance():getScheduler():scheduleScriptFunc(setDontMove, 0.6, false)
    self._isMoving      = true

    self._gameController:playBtnPressedEffect()

    self:moveHandCards(bMoveOut)
end

function SKShownCards:setDontMove()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._moveTimerID)
    self._moveTimerID   = nil
    self._isMoving      = false
end

function SKShownCards:moveHandCards(bMoveOut)
    if self._bMoveOut == bMoveOut then
        return
    end

    self._bMoveOut      = bMoveOut

    if self._panelBackGroud then
        local csbPath = "res/GameCocosStudio/csb/Node_seencards_L.csb"
        if self:isRightPlayer() then
            csbPath = "res/GameCocosStudio/csb/Node_seencards_R.csb"
        end

        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            self._panelBackGroud:runAction(action)
            if bMoveOut then
                action:gotoFrameAndPlay(1, 11, false)
            else
                action:gotoFrameAndPlay(11, 22, false)
            end
        end
    end
end

function SKShownCards:isMiddlePlayer()
    return self._gameController:isMiddlePlayer(self._drawIndex)
end

function SKShownCards:isLeftPlayer()
    return self._gameController:isLeftPlayer(self._drawIndex)
end

function SKShownCards:isRightPlayer()
    return self._gameController:isRightPlayer(self._drawIndex)
end

function SKShownCards:getMyDrawIndex()
    return self._gameController:getMyDrawIndex()
end

function SKShownCards:getStartPoint()
    local node = self._gameController._baseGameScene._gameNode
    if node then
        local thrownPosition = node:getChildByName("Panel_Card_thrown"..tostring(self._drawIndex))
        if thrownPosition then
            local startX, startY = thrownPosition:getPosition()
            if self:isRightPlayer() then
                startX = startX + thrownPosition:getContentSize().width
            end
            return startX, startY
        end
    end
    return 0, 0
end

function SKShownCards:getCardSize()
    if self._cards[1] then
        return self._cards[1]:getContentSize()
    end

    return cc.size(0, 0)
end

function SKShownCards:getOtherHandCardsPosition(index)
    local startX, startY = self:getStartPoint()

    if self:isMiddlePlayer() then       --居中
        --startX = startX - (self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        if SKGameDef.SK_CARD_SHOWN_PER_LINE > self._cardsCount then
            startX = startX - (self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        else
        startX = startX - (self:getCardSize().width + (SKGameDef.SK_CARD_SHOWN_PER_LINE - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        end
    elseif self:isRightPlayer() then    --右对齐
        if SKGameDef.SK_CARD_SHOWN_PER_LINE > self._cardsCount then
            startX = startX - self:getCardSize().width - SKGameDef.SK_CARD_THROWN_INTERVAL * (self._cardsCount - 1)
        else
            startX = startX - self:getCardSize().width - SKGameDef.SK_CARD_THROWN_INTERVAL * (SKGameDef.SK_CARD_SHOWN_PER_LINE - 1)
        end
        --startX = startX - self:getCardSize().width - (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
    end
    startX = startX + ((index - 1) % SKGameDef.SK_CARD_SHOWN_PER_LINE)  * SKGameDef.SK_CARD_THROWN_INTERVAL

    startY = startY - SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL * math.floor((index - 1) / SKGameDef.SK_CARD_SHOWN_PER_LINE)

    return cc.p(startX, startY)
end

function SKShownCards:resetSKHandCards()
    if not self._cards then return end

    for i = 1, self._gameController:getChairCardsCount() do
        local card = self._cards[i]
        if card then
            card:resetCard()
        end
    end

    self._cardsCount = 0
    self._gameController:setCardsCount(self._drawIndex, self._cardsCount, false)
end

function SKShownCards:setHandCards(handCards)
    for i = 1, self._cardsCount do
        if not self._cards[i] or not handCards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(handCards[i])
        self._cards[i]:setPosition(self:getHandCardsPosition(i))
    end

    if self:isCardsFaceShow() then
        self:setVisible(true)

        self:moveHandCards(true)
    end
end

function SKShownCards:setHandCardsWin(handCards)
    --self:setVisible(true)

    for i = 1, self._cardsCount do
        if not self._cards[i] or not handCards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(handCards[i])
        self._cards[i]:setPosition(self:getHandCardsPosition(i))
    end

    --[[if self:isCardsFaceShow() then
        self:setVisible(true)
        self:moveHandCards(true)
        
        if self._moveBtn and self._showText then
            self._moveBtn:setVisible(false)
            self._showText:setVisible(false)
        end
    end--]]
end

function SKShownCards:removeHandCards(cardIDs, cardsCount)
    SKShownCards.super.removeHandCards(self, cardIDs, cardsCount)

    if not self:isCardsFaceShow() then
        self:setVisible(false)
    end
end

function SKShownCards:showHandCards()
    for i = 1, self._cardsCount do
        if not self._cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setVisible(true)
    end

    self:setVisible(true)
end

function SKShownCards:hideHandCards()
    SKShownCards.super.hideHandCards(self)

    self:setVisible(false)
end

function SKShownCards:setVisible(bVisible)
    if self._panelBackGroud then
        self._panelBackGroud:setVisible(bVisible)
    end

    if self._moveBtn and self._showText then
        self._moveBtn:setVisible(bVisible)
        self._showText:setVisible(bVisible)
    end
end

function SKShownCards:sortHandCards()
    self.bNeedResetArrageNo = true

    local CardID = {}

    local nCount = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]:getSKID() ~= -1 then
            CardID[nCount+1]=self._cards[i]:getSKID()
            nCount = nCount + 1
        end
    end
   
    self:RUL_SortCard(CardID)
    
    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(CardID[i])
            local point = self:getHandCardsPosition(i)            
            self._cards[i]:setPosition(point)
            count = count + 1
        end
    end
end

return SKShownCards