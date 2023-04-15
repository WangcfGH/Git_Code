
local json=json
local debug_getlocal = debug.getlocal

local function loadFile(filename,curPath)

	local lkwjelfkj=cc.FileUtils:getInstance():fullPathForFilename("")
	if not curPath then
		local n,v = debug_getlocal(3, 1)
		curPath = v
		local lines=string.split(curPath,'.')
		table.remove(lines,#lines)
		curPath=table.concat(lines,'/')
--		curPath='/data/data/com.uc108.mobile.erqs/files/debugruntime'..curPath
	end

	-- utf-8 without bom
	local content=cc.FileUtils:getInstance():getStringFromFile(curPath..'/'..filename)
	if(not content or content:len()==0)then
		content=cc.FileUtils:getInstance():getStringFromFile(curPath..'/'..filename..'.json')
	end
    local resPath='res/hall/hallstrings/'
    if(not content or content:len()==0)then
        content=cc.FileUtils:getInstance():getStringFromFile(resPath..filename)
    end
    if(not content or content:len()==0)then
        content=cc.FileUtils:getInstance():getStringFromFile(resPath..filename..'.json')
	end

	if(not content)then
		printError('file not found : %s',filename)
		return nil
	end
	
	local strings=json.decode(content)
	return strings

end

return {
	loadFile=loadFile
}