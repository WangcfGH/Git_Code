--[[
一个简单的富文本 Label，用法
	
	local txt = RichTextEx:create() -- 或 RichTextEx:create(26, cc.c3b(10, 10, 10))
	txt:setStringEx("<#333>你\t好<#800>\n\t&lt;世界&gt;<img temp.png><img_50*50 temp.png><33bad_fmt<#555><64>Big<#077><18>SMALL<")
	
	-- 多行模式要同时设置 ignoreContentAdaptWithSize(false) 和 contentSize
	txt:setMultiLineMode(true)	-- 这行其实就是 ignoreContentAdaptWithSize(false)
	txt:setContentSize(200, 400)
	
	addChild(txt)
	
基本选项是
	<#F00> = <#FF0000> 	= 文字颜色
	<32>				= 字体大小
	<font Arial>		= 文字字体 支持TTF
	<img filename>		= 图片（filename 可以是已经在 SpriteFrameCache 里的 key，或磁盘文件）
	<img_32*32 fname> 	= 指定大小的图片
	<+2> <-2> <*2> </2> = 当前字体大小 +-*/
	<!>					= 颜色、字体和字体大小恢复默认
	\n \t 				= 换行 和 tab，可能暂时实现得不是很好
	
示例选项是 (在 RichTextEx.defaultCb 中提供)
	<blink 文字>		= （动画）闪烁那些文字
	<rotate 文字>		= （动画）旋转那些文字
	<scale 文字>		= （动画）缩放那些文字
	(但如果你做了 setStringEx(t, callback) 除非你在 callback 主动调用 defaultCb，否则以上选项会被忽略)	
	
同时支持自定义特殊语法，加入 callback 回调就可，如
	
	txt:setStringEx("XXXXX <aaaa haha> <bbbb> <CCCC> xxx", function(text, sender) -- 第二个参数 sender 可选
		-- 对每一个自定义的 <***> 都会调用此 callback
		-- text 就等于 *** (不含<>)
		-- 简单的返回一个 Node 的子实例就可，如
		-- 如果接收第二个参数 sender，就可获取当前文字大小、颜色: sender._fontSize、sender._textColor
		
		if string.sub(text, 1, 4) == "aaaa" then
			return ccui.Text:create("aaa111" .. string.sub(text, 6)), "", 32)
		elseif text == "bbbb" then
			-- 用当前文字大小和颜色
			local lbl = ccui.Text:create("bbb111", "", sender._fontSize)
			lbl:setTextColor(sender._textColor)
			return lbl
		elseif string.sub(text, 1, 4) == "CCCC" then
			local img = ccui.ImageView:create(....)
			img:setScale(...)
			img:runAction(...)
			return img
		end
	end)

--]]

--/////////////////////////////////////////////////////////////////////////////

local _M = class("MyRichText", function()
		return ccui.Widget:create()
end)

--/////////////////////////////////////////////////////////////////////////////
local str_sub	= string.sub
local str_rep	= string.rep
local str_byte	= string.byte
local str_gsub	= string.gsub
local str_find	= string.find

local str_trim	= function(input)
	input = str_gsub(input, "^[ \t\n\r]+", "")
	return str_gsub(input, "[ \t\n\r]+$", "")
end

local C_AND		= str_byte("&")
local P_BEG		= str_byte("<")
local P_END		= str_byte(">")
local SHARP		= str_byte("#")
local ULINE		= str_byte("_")
local C_LN		= str_byte("\n")
local C_TAB		= str_byte("\t")
local C_RST		= str_byte("!")
local C_INC		= str_byte("+")
local C_DEC		= str_byte("-")
local C_MUL		= str_byte("*")
local C_DIV		= str_byte("/")

local function c3b_to_c4b(c3b)
	return { r = c3b.r, g = c3b.g,  b = c3b.b, a = 255 }
end

--------------------------------------------------------------------------------
-- #RRGGBB/#RGB to c3b
local function c3b_parse(s)
	local r, g, b = 0, 0, 0
	if #s == 4 then
		r, g, b = 	tonumber(str_rep(str_sub(s, 2, 2), 2), 16),
					tonumber(str_rep(str_sub(s, 3, 3), 2), 16),
					tonumber(str_rep(str_sub(s, 4, 4), 2), 16)
	elseif #s == 7 then
		r, g, b = 	tonumber(str_sub(s, 2, 3), 16),
					tonumber(str_sub(s, 4, 5), 16),
					tonumber(str_sub(s, 6, 7), 16)
	end
	return cc.c3b(r, g, b)
end

--返回当前字符实际占用的字符数
local function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

--获取中英混合UTF8字符串的真实字符数量
local function SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

local function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end


--截取中英混合的UTF8字符串，endIndex可缺省
local function SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--------------------------------------------------------------------------------
local _FIX = {
	["&lt;"] = "<",
	["&gt;"] = ">",
}
local function str_fix(s)
	for k, v in pairs(_FIX) do
		s = str_gsub(s, k, v)
	end
	return s
end

--/////////////////////////////////////////////////////////////////////////////

function _M:create()
	local myRichText = _M.new()
    return myRichText
end

function _M:ctor()
    self._leftSpaceWidth = 0
    self._verticalSpace = 0
    self._elementRenderersContainer = nil
    self._richElements = {}
    self._elementRenders = {}
    self._lines = 0
    self._numbers = 0

    self._text			= ""
	self._fontSizeDef	= 26
	self._textColorDef	= cc.c3b(11, 11, 11)
	self._fontSize		= self._fontSizeDef
	self._textColor		= self._textColorDef

    self:initRenderer()
end

function _M:initRenderer()
    if self._elementRenderersContainer and self._elementRenderersContainer:getParent() then
        return
    end

    self:setCascadeOpacityEnabled(true)
    self._elementRenderersContainer = ccui.Widget:create()
    self._elementRenderersContainer:setAnchorPoint(cc.p(0.5,0.5))
    self._elementRenderersContainer:setCascadeOpacityEnabled(true)
    self:addChild(self._elementRenderersContainer)
end

function _M:pushBackText(text,fontName,fontSize,color,opacity)
	local sfile = cc.FileUtils:getInstance():isFileExist(fontName)
    local textRenderer = nil
    if sfile then
        textRenderer = cc.LabelTTF:create(text,fontName,fontSize)
    else     
        textRenderer = cc.Label:create()
        textRenderer:setAnchorPoint(cc.p(0.5,0.5))
        textRenderer:setSystemFontName(fontName)
        textRenderer:setSystemFontSize(fontSize)
        textRenderer:setString(text)
    end

    local textRendererWidth = textRenderer:getContentSize().width
    self._leftSpaceWidth = self._leftSpaceWidth - textRendererWidth
    if self._leftSpaceWidth <= 0 then
        local overstepPercent = (-self._leftSpaceWidth)/textRendererWidth
        local curText = text
        local stringLength = SubStringGetTotalIndex(curText)
        local leftLength = stringLength * (1.0 - math.ceil(overstepPercent*10)/10)
        local leftWords = SubStringUTF8(curText,0,leftLength)
        local cutWords = SubStringUTF8(curText,leftLength+1,stringLength)
        if leftLength > 0 then
            local leftRenderer = nil
            if sfile then
                leftRenderer = cc.LabelTTF:create(SubStringUTF8(leftWords,0,leftLength),fontName,fontSize)
            else     
                leftRenderer = cc.Label:create()
                leftRenderer:setAnchorPoint(cc.p(0.5,0))
                leftRenderer:setSystemFontName(fontName)
                leftRenderer:setSystemFontSize(fontSize)
                leftRenderer:setString(SubStringUTF8(leftWords,0,leftLength))
            end

            if leftRenderer then
                leftRenderer:setOpacity(opacity)
                leftRenderer:setColor(color)
                self._numbers = self._numbers+1
                self._elementRenders[self._lines][self._numbers] = leftRenderer
            end
        end

        self:addNewLine()
        self:pushBackText(cutWords,fontName,fontSize,color,opacity)

    else
        textRenderer:setOpacity(opacity)
        textRenderer:setColor(color)
        self._numbers = self._numbers+1
        self._elementRenders[self._lines][self._numbers] = textRenderer
    end
end

function _M:pushBackImg(filePath,color,opacity)
    local sprite = cc.Sprite:create(filePath)
    self:pushBackCustom(sprite)
end

function _M:pushBackCustom(node)
    local imgSize = node:getContentSize()
    self._leftSpaceWidth = self._leftSpaceWidth - imgSize.width
    self._numbers = self._numbers+1
    if self._leftSpaceWidth < 0 then
        self:addNewLine()
        self._elementRenders[self._lines][self._numbers] = node
        self._leftSpaceWidth = self._leftSpaceWidth - imgSize.width
    else
        self._elementRenders[self._lines][self._numbers] = node
    end
end

function _M:formarRenderers()
    
    local newContentSizeHeight = 0
    local maxHeights = {}

    for i = 1, #self._elementRenders do
        local nodeList = self._elementRenders[i]
        local maxHeight = 0
        for j = 1, #nodeList do
            local node = nodeList[j]
            maxHeight = math.max(node:getContentSize().height,maxHeight)
        end
        maxHeights[i] = maxHeight
        newContentSizeHeight = newContentSizeHeight + maxHeights[i]
    end
    
    local nextPosY = self:getCustomSize().height
    for i = 1, #self._elementRenders do
        local nodeList = self._elementRenders[i]
        local nextPosX = 0
        nextPosY = nextPosY - (maxHeights[i] + self._verticalSpace);


        for j = 1, #nodeList do
            local node = nodeList[j]
            node:setAnchorPoint(cc.p(0,0))
            node:setPosition(cc.p(nextPosX,nextPosY))
            node:setCascadeOpacityEnabled(true)
            self._elementRenderersContainer:addChild(node)
            nextPosX = nextPosX + node:getContentSize().width;
        end
        self._elementRenderersContainer:setContentSize(self:getContentSize())
    end

    local size = self:getCustomSize()
    self:setContentSize(size)
    self._elementRenderersContainer:setPosition(cc.p(size.width/2,size.height/2))

end

function _M:removeAllElement()
    self._richElements = {}
    self._elementRenders = {}
    self._lines = 0
    self._numbers = 0
    self._leftSpaceWidth = 0
    self._elementRenderersContainer:removeAllChildren()
end

function _M:addNewLine()
    self._leftSpaceWidth = self:getCustomSize().width
    self._lines = self._lines + 1
    self._elementRenders[self._lines] = {}
    self._numbers = 0
end

function _M:setVerticalSpace(space)
    self._verticalSpace = space
end

function _M:setAnchorPoint(pt)
    --self:setAnchorPoint(pt)
    self._elementRenderersContainer:setAnchorPoint(pt)
end

function _M:getVirtualRendererSize()
    return self._elementRenderersContainer:getContentSize()
end

--/////////////////////////////////////////////////////////////////////////////
function _M.defaultCb(text, sender)
	local BLINK		= "blink "
	local ROTATE	= "rotate "
	local SCALE		= "scale "
	
	if str_sub(text, 1, #BLINK) == BLINK then
		local lbl = ccui.Text:create(str_fix(str_sub(text, #BLINK + 1)), "", sender._fontSize)
		lbl:setTextColor(c3b_to_c4b(sender._textColor))
		lbl:runAction(cc.RepeatForever:create(cc.Blink:create(10, 10)))
		return lbl
	elseif str_sub(text, 1, #ROTATE) == ROTATE then
		local lbl = ccui.Text:create(str_fix(str_sub(text, #ROTATE + 1)), "", sender._fontSize)
		lbl:setTextColor(c3b_to_c4b(sender._textColor))
		lbl:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1, 5)))
		return lbl
	elseif str_sub(text, 1, #SCALE) == SCALE then
		local lbl = ccui.Text:create(str_fix(str_sub(text, #SCALE + 1)), "", sender._fontSize)
		lbl:setTextColor(c3b_to_c4b(sender._textColor))
		lbl:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1.0, 0.1), cc.ScaleTo:create(1.0, 1.0))))
		return lbl
	end
	
	return nil
end

--/////////////////////////////////////////////////////////////////////////////
-- TODO: 对 http:// 开头的路径进行动态网络下载
function _M.defaultImgCb(text)
	local w, h = 0, 0
	if str_byte(text, 1) == ULINE then
		local p1 = str_find(text, "*")
		local p2 = str_find(text, " ")
		
		if p1 and p2 and p2 > p1 then
			w = tonumber(str_sub(text, 2, p1 - 1))
			h = tonumber(str_sub(text, p1 + 1, p2))
		end
		
		if p2 then
			text = str_trim(str_sub(text, p2 + 1))
		end
	end
	
	local spf, img = cc.SpriteFrameCache:getInstance():getSpriteFrame(text), nil
	if spf then
--		img = cc.Sprite:createWithSpriteFrame(spf)
		img = ccui.ImageView:create(text, ccui.TextureResType.plistType)
	elseif cc.FileUtils:getInstance():isFileExist(text) then
--	  	img = cc.Sprite:create(text)
		img = ccui.ImageView:create(text, ccui.TextureResType.localType)
	end

	if img and w and h and w > 0 and h > 0 then
		img:ignoreContentAdaptWithSize(false) -- cc.Sprite can't do this, so we use ccui.ImageView
		img:setContentSize(cc.size(w, h))
	end
	
	return img
end

--/////////////////////////////////////////////////////////////////////////////
function _M:addCustomNode(node)
	if node then
		local anc = node:getAnchorPoint()
		if anc.x ~= 0.0 or anc.y ~= 0.0 then
			local tmp = node
			local siz = node:getContentSize()
			node = cc.Node:create()
			node:setContentSize(siz)
			node:addChild(tmp)
			tmp:setPosition(cc.p(siz.width * anc.x, siz.height * anc.y))
		end
		self:pushBackCustom(node)
	end
end

--/////////////////////////////////////////////////////////////////////////////
-- 可以在 callback 里添加各种自定义<XXXXX XXX>语法控制
function _M:setStringEx(text, callback)
	assert(text)

	self._text = text
	self._callback = callback or self.defaultCb
	
	self._fontSize	= self._fontSizeDef
	self._textColor	= self._textColorDef
	
	-- clear
    self:removeAllElement()

	local p, i, b, c = 1, 1, false
	local str, len, chr, obj = "", #text
	
	while i <= len do
		c = str_byte(text, i)
		if c == P_BEG then	-- <
			if (not b) and (i > p) then
				str = str_sub(text, p, i - 1)
				self:pushBackText(str_fix(str),self._textFont,self._fontSize,self._textColor, 255)
			end
			
			b = true; p = i + 1; i = p
			
			while i < len do
				if str_byte(text, i) == P_END then	-- >
					b = false
					if i > p then
						str = str_trim(str_sub(text, p, i - 1))
						chr = str_byte(str, 1)
						if chr == SHARP and (#str == 4 or #str == 7) and tonumber(str_sub(str, 2), 16) then -- textColor
							self._textColor = c3b_parse(str)
						elseif chr == C_RST and #str == 1 then	-- reset
							self._textColor = self._textColorDef
							self._fontSize  = self._fontSizeDef
							self._textFont  = "" 
						elseif (chr == C_INC or chr == C_DEC or chr == C_MUL or chr == C_DIV)
								and tonumber(str_sub(str, 2)) then
							local v = tonumber(str_sub(str, 2)) or 0
							if chr == C_INC then
								self._fontSize = self._fontSize + v
							elseif chr == C_DEC then
								self._fontSize = self._fontSize - v
							elseif chr == C_MUL then
								self._fontSize = self._fontSize * v
							elseif v ~= 0 then
								self._fontSize = self._fontSize / v
							end
						elseif tonumber(str) then	-- fontSize
							self._fontSize = tonumber(str)
						elseif str_sub(str, 1, 5) == "font " or str_sub(str, 1, 5) == "font_" then
							self._textFont = str_trim(str_sub(str, 5, i - 1))
						elseif str_sub(str, 1, 4) == "img " or str_sub(str, 1, 4) == "img_" then
							self:addCustomNode(self.defaultImgCb(str_trim(str_sub(str, 4, i - 1))))
						elseif self._callback then
							self:addCustomNode(self._callback(str, self))
						end
					end
					
					break
				end
				i = i + 1
			end
			
			p = i + 1
		elseif c == C_LN or c == C_TAB then
			if (not b) and (i > p) then
				str = str_sub(text, p, i - 1)
				self:pushBackText(str_fix(str),self._textFont,self._fontSize,self._textColor, 255)
			end

			obj = cc.Node:create()
			if c == C_LN then
				obj:setContentSize(cc.size(self:getContentSize().width, 1))
			else
				obj:setContentSize(cc.size(self._fontSize * 2, 1))
			end
			self:addCustomNode(obj)


			p = i + 1
		end
		
		i = i + 1
	end

	if (not b) and (p <= len) then
		str = str_sub(text, p)
		self:pushBackText(str_fix(str),self._textFont,self._fontSize,self._textColor, 255)
	end

    self:formarRenderers()

	return self
end

function _M:setFontSize(size)
    self._fontSizeDef = size
end

function _M:setTextColor(color)
    self._textColorDef = color
end

return _M

