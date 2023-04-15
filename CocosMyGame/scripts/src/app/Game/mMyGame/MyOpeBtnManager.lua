
local SKOpeBtnManager = import("src.app.Game.mSKGame.SKOpeBtnManager")
local MyOpeBtnManager = class("MyOpeBtnManager", SKOpeBtnManager)

local MyGameDef                               = import("src.app.Game.mMyGame.MyGameDef")
local BaseGameDef                             = import("src.app.Game.mBaseGame.BaseGameDef")

local MY_OPEBTNS_INDEX = {                  --前面3个和SK模板保持一致
    MY_OPEBTNS_INDEX_THROW      = 1,
    MY_OPEBTNS_INDEX_PASS       = 2,
    MY_OPEBTNS_INDEX_HINT       = 3,
    MY_OPEBTNS_INDEX_TRIBUTE       = 4,
    MY_OPEBTNS_INDEX_RETURN   = 5,
    MY_OPEBTNS_INDEX_SHOWN      = 6,
    MY_OPEBTNS_INDEX_NOSHOWN    = 7,
    MY_OPEBTNS_INDEX_NOBIGGER   = 8,        -- 要不起按钮
}

function MyOpeBtnManager:ctor(opeBtnPanel, gameController)
    MyOpeBtnManager.super.ctor(self, opeBtnPanel, gameController)
end

function MyOpeBtnManager:init()
    MyOpeBtnManager.super.init(self)
end

function MyOpeBtnManager:setOpeBtns()
    if not self._opeBtnPanel then return end
    
    local function onTribute()
        self:onTribute()
    end
    local buttonTribute = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_Tribute")
    if buttonTribute then
        buttonTribute:addClickEventListener(onTribute)

        local index = MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE
        self._opeBtns[index] = buttonTribute
    end
    
    local function onReturn()
        self:onReturn()
    end
    local buttonReturn = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_PayOff")
    if buttonReturn then
        buttonReturn:addClickEventListener(onReturn)

        local index = MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN
        self._opeBtns[index] = buttonReturn
    end
       
    -- 设置要不起按钮
    local function onNoBiggerPass()
        self:onNoBiggerPass()
    end
    local noBiggerBtn = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_NoBigger")
    if noBiggerBtn then
        noBiggerBtn:addClickEventListener(onNoBiggerPass)

        local index = MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOBIGGER
        self._opeBtns[index] = noBiggerBtn
    end
    MyOpeBtnManager.super.setOpeBtns(self)
end

function MyOpeBtnManager:onNoBiggerPass()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onPressNoBigger()
    end
end

function MyOpeBtnManager:onTribute()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onTribute()
    end
end

function MyOpeBtnManager:onReturn()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onReturn()
    end
end

function MyOpeBtnManager:onShown()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onShown(true)
    end
end

function MyOpeBtnManager:onNoShown()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onShown(false)
    end
end

function MyOpeBtnManager:showNoBiggerBtn()
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOBIGGER] then
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOBIGGER]:setVisible(true)
    end
end

function MyOpeBtnManager:showOperationBtns(status, bFirstHand)
    if self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE] then
            self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setVisible(true)
        end       
        return
    end
    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_CALL)
            and self._gameController:getMyDrawIndex() == self._gameController:getBankerDrawIndex() then
        if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE] then
            self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setVisible(true)
        end
        if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN] then
            self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN]:setVisible(true)
        end
        
        return
    end

    local bFinishShow = false
    local myChairNO = self._gameController:getMyChairNO() + 1
    if self._gameController._baseGameUtilsInfoManager:getFinishShow(myChairNO) == 1 then
        bFinishShow = true
    end
    if (self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_BANKSHOW)
            or self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_SHOW)) then
        if bFinishShow
                or (self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_BANKSHOW)
                and self._gameController:getMyDrawIndex() ~= self._gameController:getBankerDrawIndex())then
            if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_SHOWN] then
                self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_SHOWN]:setVisible(false)
            end
            if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOSHOWN] then
                self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOSHOWN]:setVisible(false)
            end
        else
            if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_SHOWN] then
                self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_SHOWN]:setVisible(true)
            end
            if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOSHOWN] then
                self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_NOSHOWN]:setVisible(true)
            end
        end

        return
    end
    
    MyOpeBtnManager.super.showOperationBtns(self, status, bFirstHand)
end

function MyOpeBtnManager:isTributeVisible()
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE] then
        return self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:isVisible()
    end
    return false
end

function MyOpeBtnManager:setTributeVisible(bVisible)
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE] then
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setVisible(bVisible)
        --self._opeBtns[SK_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setBright(bEnable)
    end
end

function MyOpeBtnManager:setTributeEnable(bEnable)
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE] then
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setTouchEnabled(bEnable)
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setBright(bEnable)
    end
end

function MyOpeBtnManager:isReturnVisible()
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN] then
        return self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN]:isVisible()
    end
    return false
end

function MyOpeBtnManager:setReturnVisible(bVisible)
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN] then
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN]:setVisible(bVisible)
        --self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_TRIBUTE]:setBright(bEnable)
    end
end

function MyOpeBtnManager:setReturnEnable(bEnable)
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN] then
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN]:setTouchEnabled(bEnable)
        self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_RETURN]:setBright(bEnable)
    end
end

function MyOpeBtnManager:containsTouchLocation(x, y)
    if not self._opeBtnPanel then return false end

    local opeBtnChildren = self._opeBtnPanel:getChildren()
    for i = 1, self._opeBtnPanel:getChildrenCount() do
        local child = opeBtnChildren[i]
        if child and child:isVisible() and child:isTouchEnabled() then
            --local position = self._opeBtnPanel:convertToWorldSpace(cc.p(child:getPosition()))
            local btnPosWorld = child:getParent():convertToWorldSpace(cc.p(child:getPosition()))
            local operatePanel = child:getParent():getParent():getParent()
            local btnPosLocalInOperatePanel = operatePanel:convertToNodeSpace(btnPosWorld)
            local position = btnPosLocalInOperatePanel

            local s = child:getContentSize()
            local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
            local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
            if b then
                return b
            end
        end
    end

    return false
end

function MyOpeBtnManager:isThrowVisible()
    if self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_THROW] then
        return self._opeBtns[MY_OPEBTNS_INDEX.MY_OPEBTNS_INDEX_THROW]:isVisible()
    end
    return false
end

return MyOpeBtnManager