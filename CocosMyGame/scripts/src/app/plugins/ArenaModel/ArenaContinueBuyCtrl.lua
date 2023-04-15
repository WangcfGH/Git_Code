local viewCreater=import('src.app.plugins.ArenaModel.ArenaContinueBuyView')
local ArenaContinueBuyCtrl=class('ArenaContinueBuyCtrl',cc.load('BaseCtrl'))

function ArenaContinueBuyCtrl:onCreate(params)
    self._launchParams = params
    self._arenaRoomInfo = params.arenaRoomsData
    self._arenaData = params.arenaData

    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)


    local bindList={
		'buyBt',
	}
	
	self:bindUserEventHandler(viewNode,bindList)
    self:bindSomeDestroyButtons(viewNode,bindList)
    
    if self._arenaData.nSignUpPayType == 2 then
        viewNode.sliverNumText:setString(self._arenaData.nSilverNum)
    end

    viewNode.signUpText:setString( string.format(viewNode.signUpText:getString(), params.maxSignUpCount, params.signUpCount))
end

function ArenaContinueBuyCtrl:buyBtClicked( ... )
    --local RoomModel =  require("src.app.plugins.roomspanel.RoomListModel"):getInstance()
    if self._launchParams["callbackOnBuy"] then
        self._launchParams["callbackOnBuy"](self._arenaRoomInfo, self._arenaData)
    end
end

return ArenaContinueBuyCtrl