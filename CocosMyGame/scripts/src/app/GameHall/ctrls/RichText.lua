
local RichText = class("RichLabel", cc.Node)	
local utf8String = cc.load('strings').Utf8String

--create(...)创建时数传默认字体颜色, 默认字体大小
--Reset(...)重置
--AddNode(...)添加非字符串节点, 比如图片
--AddString(...)添加字符串, 可包含'\n'
--AddStringTable(...)添加字符串table
--AddEnter()换行

function RichText:ctor(defColor, nDefFontSize)	
	self.m_cDefColor = defColor or cc.c3b(255, 255, 255)
	self.m_nDefSize = nDefFontSize or 28
	self.m_ptCurPos = cc.p(0, 0)
        self._defaultWidth = nil
end

function RichText:Reset()
	self:removeAllChildren()

	self.m_ptCurPos = cc.p(0, 0)

end

--Node输入, nHOffset高度位置偏移, 多用于添加图片, 节点之类
function RichText:AddNode(pNodeString, nHOffset)
	nHOffset = nHOffset or 0

	self:addChild(pNodeString)
	pNodeString:setAnchorPoint(cc.p(0, 0))
	pNodeString:setPosition(self.m_ptCurPos.x, self.m_ptCurPos.y + nHOffset)

	local nW = self:getContentSize().width
	local nH = self:getContentSize().height
	
	if nH == 0 then
		nH = nH + pNodeString:getContentSize().height * pNodeString:getScaleY()
	end

	self.m_ptCurPos.x = self.m_ptCurPos.x + pNodeString:getContentSize().width * pNodeString:getScaleX()

	if nW < self.m_ptCurPos.x then
		nW = self.m_ptCurPos.x
	end

	self:setContentSize(cc.size(nW, nH))
end
--顾名思义, 添加字符串, 可传参数字体颜色, 字体大小
function RichText:AddString(str, color3, nFontSize)
	if type(str) ~= 'string' then return end

	color3 = color3 or self.m_cDefColor
	nFontSize = nFontSize or self.m_nDefSize

	local nLen = string.len(str)
	if nLen <= 0 then return end
	
	local strTotal = str
	
	while string.len(strTotal) > 0 do
		local enterIndex = string.find(strTotal, '\n')
		local strTemp = strTotal
 
		if enterIndex and enterIndex == 1 then
			strTemp = '\n'

			self:AddEnter()			
		else
			if enterIndex then
				strTemp = string.sub(strTotal, 1, enterIndex - 1)
			end

            local bNeedAddEnter, subLen = self:needAddEnter(strTemp, nFontSize)
            if bNeedAddEnter == true then
                strTemp = utf8String.sub(strTotal, 1, subLen) 
            end

			local font = cc.Label:create()
            font:setString(strTemp)             	
			font:setSystemFontSize(nFontSize)
			font:setColor(color3)

			self:AddNode(font)      
            if bNeedAddEnter == true then
                self:AddEnter() 
            end   	
		end
		
		strTotal = string.sub(strTotal, string.len(strTemp) + 1)
	end
end
--按表添加多个字符串, 子table参数同AddString的参数
--local stringTable = {
--	{my.MCCharset.gb2Utf8String('胜', 2), cc.c3b(255, 201, 14), 14},
--	{my.MCCharset.gb2Utf8String('负', 2)},
--}
function RichText:AddStringTable(stringTable)
	if type(stringTable) ~= 'table' then return end

	for i, lableInfo in pairs(stringTable) do
		if type(lableInfo) == 'table' then
			self:AddString(lableInfo[1], lableInfo[2], lableInfo[3])
		end
	end
end

--换行,有时候字符串里\n无效时,请用这个
function RichText:AddEnter()

    local allChildren = self:getChildren()
    for i = 1, self:getChildrenCount() do
        local child = allChildren[i]
        if child then
            child:setPosition(child:getPositionX(), child:getPositionY() + self.m_nDefSize * 1.3)
        end
    end
	
	self.m_ptCurPos.x = 0

	self:setContentSize(cc.size(self:getContentSize().width, self:getContentSize().height + self.m_nDefSize * 1.3))
end

function RichText:removeEnter(utf8Str)
	local strInfo = ""
    --先解析"\n"成一个空格
	while utf8Str:len() > 0 do
        local posEnter = utf8Str:find("\n")
        if not posEnter then 
            break
        end
        
		--保存<font前面字符串
		if posEnter > 1 then
			local str = utf8Str:sub(1, posEnter - 1)
            strInfo = strInfo..str.." "
        else
            strInfo = strInfo.." "
		end
        utf8Str = utf8Str:sub(posEnter + 1)
    end

    strInfo = strInfo..utf8Str

    return strInfo
end

function RichText:convertColorStringTable(utf8Str)--{{color = 0, str = ""}}
    local colorStrings = {}
    local colorString = {color = 0, str = ""}

	while utf8Str:len() > 0 do
		local posL = utf8Str:find("<c=")
		local posC = utf8Str:find(">")
		local posR = utf8Str:find("<>")
		--解析<c=ff0000>xx<>
		if not posL or not posC or not posR or posL > posC or posC > posR then
			if utf8Str:len() > 0 then
                table.insert(colorStrings, {str = utf8Str})
			end
			break
		end

		--保存<c=ff0000>前面字符串
		if posL > 1 then
			local str = utf8Str:sub(1, posL - 1)
            table.insert(colorStrings, {str = str})
			utf8Str = utf8Str:sub(posL)
		end
		--删除"<c="
		utf8Str = utf8Str:sub(string.len("<c=") + 1)
		posC = utf8Str:find(">")
		--保存色值
		local strColor = utf8Str:sub(1, posC - 1);
		local color = self:convertColor(tonumber(strColor))
		utf8Str = utf8Str:sub(posC + 1)
		--中间字符串
		local str = utf8Str:sub(1, utf8Str:find("<>") - 1);
        table.insert(colorStrings, {color = color, str = str})
		utf8Str = utf8Str:sub(utf8Str:find("<>") + string.len("<>"))
	end

    return colorStrings
end

--富态文本解析<font color='#ff0000'>我是红色</font>
function RichText:setColorString(utf8Str)
	if not utf8Str or utf8Str:len() == 0 then return end
	self:Reset()
	self:addColorString(utf8Str)
end

function RichText:addColorString(utf8Str)
	if not utf8Str or utf8Str:len() == 0 then return end
	
	utf8Str = self:removeEnter(utf8Str)
	--local strInfo = self:removeEnter(utf8Str)
    local colorStrings = self:convertColorStringTable(utf8Str)--{{color = 0, str = ""}}

    for __, colorString in pairs(colorStrings) do
        self:AddString(colorString.str or "", colorString.color)
    end

    if true then return end

	while strInfo:len() > 0 do
		local posL = strInfo:find("<c=")
		local posC = strInfo:find(">")
		local posR = strInfo:find("<>")
		--解析<c=ff0000>xx<>
		if not posL or not posC or not posR or posL > posC or posC > posR then
			if strInfo:len() > 0 then
                self:AddString(strInfo)
			end
			break
		end

		--保存<c=ff0000>前面字符串
		if posL > 1 then
			local str = strInfo:sub(1, posL - 1)
            self:AddString(strInfo)
			strInfo = strInfo:sub(posL)
		end
		--删除"<c="
		strInfo = strInfo:sub(string.len("<c=") + 1)
		posC = strInfo:find(">")
		--保存色值
		local strColor = strInfo:sub(1, posC - 1);
		strInfo = strInfo:sub(posC + 1)
		local color = self:convertColor(tonumber(strColor))
		--中间字符串
		local str = strInfo:sub(1, strInfo:find("<>") - 1);
        self:AddString(str, color)
		strInfo = strInfo:sub(strInfo:find("<>") + string.len("<>"))
	end
end
--//b*256*256+g*256+r的数字转cc.c3b
-- 代码评审 jj 重构broadcast时，应该可以用到
function RichText:convertColor(nColor)
	local nR = nColor % 256

	nColor = (nColor - nR) / 256
	local nG = nColor % 256
	
	nColor = (nColor - nG) / 256
	local nB = nColor % 256

	return cc.c3b(nR, nG, nB)
end

--上面那个同胞函数不知道为什么搞的反的
--//r*256*256+g*256+b的数字转cc.c3b
function RichText:convertColorEX(nColor)
	local nB = nColor % 256

	nColor = (nColor - nB) / 256
	local nG = nColor % 256
	
	nColor = (nColor - nG) / 256
	local nR = nColor % 256

	return cc.c3b(nR, nG, nB)
end

function RichText:setDefaultWidth(nWidth)
    self._defaultWidth = nWidth
end

--是否超出预定的宽度需要换行
--return 是否需要换行 若需要换行，返回最多可以放的字符串的长度
function RichText:needAddEnter(strTemp, nFontSize)
    if not self._defaultWidth then return false end

	local nW = self:getContentSize().width
    local font = cc.Label:create()
    font:setString(strTemp)
    font:setSystemFontSize(nFontSize)

	local nNeedWith = self.m_ptCurPos.x + font:getContentSize().width * font:getScaleX()
    if nNeedWith > self._defaultWidth then
        local str = font:getString()
        local subLen = 0
        while self.m_ptCurPos.x + font:getContentSize().width * font:getScaleX() > self._defaultWidth do
            subLen = utf8String.len(str) - 1
            str = utf8String.sub(str, 1, subLen)     
            font:setString(str)  
        end
        --local stringLen = pNodeString:getStringLength()
        return true, subLen
    end
    return false
end

--让一个child 在当前行居中
--nIndex   child 的index
function RichText:makeChildToMid(nIndex)
    if not self._defaultWidth then return false end

    local nChildCount = self:getChildrenCount()
    local allChildren = self:getChildren()
    nIndex = nIndex and nIndex or nChildCount
    if nIndex > nChildCount then return end
    local item = allChildren[nIndex]
    if item then
        local nWidth = item:getContentSize().width
        local nX = (self._defaultWidth - nWidth) / 2
        item:setPosition( nX, item:getPositionY())
    end
end

return RichText