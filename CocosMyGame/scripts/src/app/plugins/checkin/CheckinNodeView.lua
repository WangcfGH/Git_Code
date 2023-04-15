
local CheckinNodeView=class('CheckinNodeView')

CheckinNodeView.CHECKED_TODAY=1
CheckinNodeView.NOT_CHECK_TODAY=2
CheckinNodeView.CHECKED_BEFORE=3
CheckinNodeView.NOT_CHECKED_FUTURE=4

function CheckinNodeView.setStatu(checkinNode,statu,mode)
	-- body
	local self=checkinNode
	if(type(statu)~='number')then
		statu=CheckinNodeView.NOT_CHECKED_FUTURE
	end

	local viewNode=my.NodeIndexer(checkinNode,
		{
		})
	self._viewNode=viewNode

	local nodenameList={'today','today','before','future'}
	local curNodeName=nodenameList[statu]
	assert(curNodeName,'current node name is nil')
	local curNode=viewNode[curNodeName]
	self.lastNode=self.lastNode or curNode
	self.lastNode:setVisible(true)
	if(self.lastNode~=curNode)then
		self.lastNode:setVisible(false)
		curNode:setVisible(true)
		self.lastNode=curNode
	end

	if(statu==CheckinNodeView.NOT_CHECK_TODAY)then
		curNode.Img_CheckedTips:setVisible(false)
	elseif(statu==CheckinNodeView.CHECKED_TODAY)then
		curNode.Img_CheckedTips:setVisible(true)
		curNode.Btn_CheckInMain:setTouchEnabled(false)
	end

	return curNode

end

function CheckinNodeView.setCurTime(curNode,time)
	assert(type(time)=='number','')
	local timeLable = curNode.lastNode.Text_Day
	if(curNode._timeTipFormat==nil)then
		curNode._timeTipFormat=timeLable:getString()
	end
	local tipString=string.format(curNode._timeTipFormat,time)
	timeLable:setString(tipString)
end

function CheckinNodeView.onClick(checkinNode,callback)
    if checkinNode and checkinNode.today and checkinNode.today.Btn_CheckInMain then
	    checkinNode.today.Btn_CheckInMain:getRealNode():addClickEventListener(function(e)
		    local e={
			    target=e,
			    curNode=e:getParent():getParent(),
		    }
		    callback(e)
	    end)
    end
end

function CheckinNodeView.addSetRewardLableMethod(checkinNode,mode)
	-- body
	function checkinNode:setRewardLable(num)
		-- body
		num=checknumber(num)
		local rewardLabel = nil
		if(mode==1)then
			rewardLabel = self.lastNode.Text_RewardSilver
			self.lastNode.Text_RewardScore:setVisible(false)
		else
			rewardLabel = self.lastNode.Text_RewardScore
			self.lastNode.Text_RewardSilver:setVisible(false)
		end

		if(self._rewardTipFormat==nil)then
			self._rewardTipFormat=rewardLabel:getString()
		end
		local tipString=string.format(self._rewardTipFormat,num)
		rewardLabel:setMoney(tipString)
	end
end

local imageConfig = require("src.app.HallConfig.CheckinConfig")
function CheckinNodeView:setRewardImage(curNode, reward, mode)
	local image
	if(mode==1)then
		image = CheckinNodeView:getImageName(reward, imageConfig['showRewardDeposite'])
		if(image == nil)then
			image = imageConfig['showRewardDepositeDefault']
		end
	else
		image = CheckinNodeView:getImageName(reward, imageConfig['showRewardScore'])
		if(image == nil)then
			image = imageConfig['showRewardScoreDefault']
		end
	end

	curNode.lastNode:getChildByName(image):setVisible(true)

end

function CheckinNodeView:getImageName(reward,imageConfig)
	local key_test ={}
	for i in pairs(imageConfig) do
		table.insert(key_test,i)
	end
	table.sort(key_test)

	for i,v in pairs(key_test)do
		if( (reward <= v) and (reward > 0) )then
			return	imageConfig[v]
		end
	end
	return nil
end

return CheckinNodeView
