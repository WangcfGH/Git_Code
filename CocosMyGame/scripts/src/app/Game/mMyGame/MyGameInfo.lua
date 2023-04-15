
local SKGameInfo = import("src.app.Game.mSKGame.SKGameInfo")
local MyGameInfo = class("MyGameInfo", SKGameInfo)

local MySpecialCard                             = import("src.app.Game.mMyGame.MySpecialCard")
local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")

function MyGameInfo:ctor(gameInfo, gameController, gametableNode)
    self._specialCard   = nil
    self._specialTitle  = nil

    self._tips1VS4      = nil

    self._gametableNode = gametableNode

    MyGameInfo.super.ctor(self, gameInfo, gameController)
end

function MyGameInfo:init()
    self._specialTitle  = ccui.Helper:seekWidgetByName(self._gameInfo, "img_topbar_title")

    self._specialCard   = MySpecialCard:create(1, self, 1)
    if self._specialCard then
        self._specialCard:resetCard()
    end

    self._tips1VS4      = self._gameInfo:getChildByName("icon_1VS4mark")

    --[[local mainBgS = self._gametableNode:getChildByName("Img_MainBG")
    local mainBgN = self._gametableNode:getChildByName("Img_MainBG_Night")
    mainBgS:setVisible(false)
    mainBgN:setVisible(false)
    local tmHour=tonumber(os.date('%H',os.time()))
    if (tmHour>=18 and tmHour<= 23) or (tmHour>=0 and tmHour< 6) then       
        mainBgN:setVisible(true)
    else
        mainBgS:setVisible(true)
    end]]

    MyGameInfo.super.init(self)
end

function MyGameInfo:ope_ShowGameInfo(bShow)
    MyGameInfo.super.ope_ShowGameInfo(self, bShow)

    if not bShow then
        self:hideFriendCard()

        if self._tips1VS4 then
            self._tips1VS4:setVisible(bShow)
        end
    end
end

function MyGameInfo:hideFriendCard()
    if self._specialCard then
        self._specialCard:resetCard()
    end

    if self._specialTitle then
        self._specialTitle:setVisible(false)
    end
end

function MyGameInfo:ope_SetFriendCard(nCardID)
    if -1 == nCardID then
        self:set1VS4(true)
        return
    end

    if not MyCalculator:isValidCard(nCardID) then return end

    self:set1VS4(false)

    if self._specialCard then
        self._specialCard:setSKID(nCardID)
        self._specialCard:setPosition(self:getSpecialCardsPosition())
    end

    if self._specialTitle then
        self._specialTitle:setVisible(true)
    end

    self:hideTimeInfo()
end

function MyGameInfo:getSpecialCardsPosition()
    return cc.p(45, 3)
end

function MyGameInfo:set1VS4(bShow)
    if self._tips1VS4 then
        self._tips1VS4:setVisible(bShow)
    end
end

return MyGameInfo