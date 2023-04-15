
local viewCreator=cc.load('ViewAdapter'):create()

local viewConfig=require('src.app.HallConfig.FeedbackViewConfig')
local MAX_MESSAGE_LENGTH=viewConfig.MAX_MESSAGE_LENGTH or 24

viewCreator.viewConfig={
	'res/hallcocosstudio/help/questmsg.csb',
	{
		{
			_option={
				prefix='Img_ChatPapo.'
			},
			msgTxt='Text_Chat',
		},
		timeTxt='Text_Date',
		bottomNode='Img_IconSevice',
		topNode='Img_ChatPapo',
	}
}

function viewCreator:onCreateView(viewNode)

	function viewNode:setTime(time)
		if(not self._timeTxtFormat)then
			self._timeTxtFormat=self.timeTxt:getString()
		end
		self.timeTxt:setString(os.date(self._timeTxtFormat,checkint(time)))
	end

    function viewNode:setHead(sex)
        if self.bottomNode then
            self.bottomNode:loadTexture(cc.exports.getHeadResPath(sex), 0)
        end
    end
	function viewNode:setMsg(msg)
		local gbkMsg=MCCharset:getInstance():utf82GbString( msg,string.len(msg) )
		local lines= my.splitStringByLen(gbkMsg,MAX_MESSAGE_LENGTH)
		gbkMsg=table.concat(lines,'\n')
		msg = MCCharset:getInstance():gb2Utf8String( gbkMsg,string.len(gbkMsg) )
--		local pos=1
--		local lines={}
--		repeat
--			lines[#lines+1]=msg:sub(pos,pos+24)
--			pos=pos+25
--		until(pos>msg:len())
--		msg=table.concat(lines,'\n')
		self.msgTxt:setString(msg)
		local textSize=self.msgTxt:getContentSize()
		self.topNode:setContentSize(cc.size(textSize.width+40,textSize.height+40))
	end

	function viewNode:getContentHeight()
		return self.topNode:getContentSize().height+self.bottomNode:getContentSize().height
			+self.topNode:getPositionY()-self.bottomNode:getPositionY()
	end

end

return viewCreator
