local UpdateLayer  = class("UpdateLayer")

local updatePath    = BusinessUtils:getInstance():getUpdateDirectory() .. BusinessUtils:getInstance():getAbbr() .. '/'
updatePath          = string.gsub(updatePath, "\\", "/")
local fileutils     = cc.FileUtils:getInstance()

local cacheFileName = fileutils:getGameWritablePath().."UpdateToolCache.json"
cacheFileName       = string.gsub(cacheFileName, "\\", "/")

UpdateLayer.RES_LINE    = {"res/gmtool/filelistupdate.csb", "res/gmtool/filelistdelete.csb"}

local utils = DownloadUtils:getInstance()

local MAXCACHE = 100
local UPDATETAB = 1
local DELTAB    = 2

local OPEN_FILE_FAILED   = 0x0001
local WRITE_FILE_FAILED  = 0x0002
local WRITE_FILE_SUCCESS = 0x0004

local FILE_FROM_PATH = 1
local FILE_FROM_ZIP  = 10

function UpdateLayer:ctor(resNode, gmLayer)
    resNode:setLocalZOrder(1)
    self._resNode = resNode
    self._gmLayer = gmLayer
    self._cacheConfig = {}
    self._cacheData   = {}
    self._cacheItem   = {}
    self:initChildName()

    self:readCache()
 
    if self._cacheConfig["updateServer"] then
        gDbgConfig.update_server = self._cacheConfig["updateServer"]
    end

    self:registEvent()
    self._session = import("src.debugtool.updateclient"):create()
    self._session:setDefaultCB(handler(self, self.onNotifyMsg))
    self._session:connect()
    self._fileList  = {}
    
    self:showFileList()
    self:selectTab(UPDATETAB)

    self._keyListener = nil
    self:registerKeyBoardEvent()
end

function UpdateLayer:selectTab(index)
    self.nodes.btnDelPanel:setEnabled(not (index == DELTAB))
    self.nodes.btnDelPanel:setBright(not (index == DELTAB))

    self.nodes.btnUpdatePanel:setEnabled(not (index == UPDATETAB))
    self.nodes.btnUpdatePanel:setBright(not (index == UPDATETAB))
    
    self.nodes.btnStartUpdate:setVisible(index == UPDATETAB)
    self.nodes.btnDelAll:setVisible(index == DELTAB)

    self.nodes.lvFileList:setVisible(index == UPDATETAB)
    self.nodes.lvFileListDel:setVisible(index == DELTAB)

    self.nodes.btnConnect:setEnabled(index == UPDATETAB)
end

function UpdateLayer:initChildName()
    local panel         = self._resNode:getChildByName("Panel")
    self.nodes = {
        panel           = panel,
        btnBack         = panel:getChildByName("Btn_Back"),
        btnStartUpdate  = panel:getChildByName("Btn_StartUpdate"),
        lvFileList      = panel:getChildByName("LV_Filelist"),
        lvFileListDel   = panel:getChildByName("LV_Filelist_Del"),
        lvTouchPanel    = panel:getChildByName("LV_TouchPanel"),
        txtIp           = panel:getChildByName("Panel_Ip"):getChildByName("Text_Ip"),
        txtConnect      = panel:getChildByName("Panel_Ip"):getChildByName("Text_Connect"),
        btnConnect      = panel:getChildByName("Panel_Ip"):getChildByName("Btn_Connect"),
        btnDelAll       = panel:getChildByName("Btn_DelAll"),
        btnUpdatePanel  = panel:getChildByName("Btn_UpdatePanel"),
        btnDelPanel     = panel:getChildByName("Btn_DelPanel"),
    }
end

function UpdateLayer:registEvent()
    self.nodes.btnStartUpdate:addClickEventListener(function()
        self:onbtnUpdate()
    end)

    self.nodes.btnBack:addClickEventListener(function()
        self:onBack()
    end)

    self.nodes.btnConnect:addClickEventListener(function()
        self:onBtnConnect()
    end)

    self.nodes.btnDelAll:addClickEventListener(function()
        self:onBtnDelAll()
    end)

    self.nodes.btnUpdatePanel:addClickEventListener(function() 
        self:selectTab(UPDATETAB)
    end)

    self.nodes.btnDelPanel:addClickEventListener(function()
        self:showDelFileList()
        self:selectTab(DELTAB)
    end)

    my.fixTextField(self.nodes,'txtIp',self.nodes.txtIp, "..")
    self:setUpdateToolIp(string.sub(gDbgConfig.update_server, string.len("ws:///"), -1))

    self.nodes.txtIp:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    self.nodes.txtIp:registerScriptEditBoxHandler(handler(self, self.onInputIpChanged))
    
end

function UpdateLayer:onInputIpChanged(strEventName, pSender)
     if strEventName ~= "changed" then return end
    if self.nodes and self.nodes.txtIp then
        local ip = self.nodes.txtIp:getString()
        self.nodes.txtIp:setString("")
        self.nodes.txtIp:setString(ip)
    end
end


function UpdateLayer:onNotifyMsg(nMsg, data)
    local netCallback = {}

    netCallback[UpdateClientDef.UPDATESERVER_CONNECT_OK] = function(data)
         DbgInterface:showMsg("server connect ok")
        self:updateBtnConnect(nMsg)
    end
   
    netCallback[UpdateClientDef.UPDATESERVER_CONNECT_FAILED] = function(data)
        DbgInterface:showMsg("server connect failed")
        self:updateBtnConnect(nMsg)
    end

    netCallback[UpdateClientDef.UPDATESERVER_CONNECT_CLOSE] = function(data)
        DbgInterface:showMsg("server connect close")
        self:updateBtnConnect(nMsg)
    end

    if netCallback[nMsg] then
        netCallback[nMsg](data)
    elseif nMsg > UpdateClientDef.UPDATESERVER_DOWNLOAD_MSG then
        self:receiveData(data)
    end
end

function UpdateLayer:onBack()

    self._session:disconnect()
    self._fileList  = {}

    self:saveCache()
    self._gmLayer:closeUpdate()
    self._cacheData = {}
    self._cacheItem = {}
end

function UpdateLayer:onQuit()
    self:onBack()
   
    if self.nodes.lvFileList then
        self.nodes.lvFileList:removeAllChildren()
    end

    if self.nodes.txtIp then
        self.nodes.txtIp:unregisterScriptEditBoxHandler()
    end

    self.nodes = {}
    self._keyListener = nil
end

function UpdateLayer:onBtnDelAll()

     local pos = 1
     for file, i in pairs(self._cacheConfig["delfilelist"])  do
         if self._cacheConfig["delfilelist"][file] > 0 then
            self:delFileListDelItem(pos)
            pos = pos + 1
         end
     end
     self.nodes.lvFileListDel:removeAllChildren()
end

function UpdateLayer:delFileListDelItem(index, item)

    if item then
        self.nodes.lvFileListDel:removeChild(item)
    end

    local pos = 1
    local fileinfo  = nil
    local fileValue = 0
    for file, i in pairs(self._cacheConfig["delfilelist"]) do
        if pos == index then
            fileinfo  = file
            fileValue = i
            break
        end
        pos = pos + 1
    end

    if fileinfo == nil then
        return
    end

     cc.FileUtils:getInstance():removeFile(updatePath..fileinfo)
     self._cacheConfig["delfilelist"][fileinfo] = 0

    --清空各个ip下对应的这个文件记录
    for i, ip in ipairs(self._cacheConfig["iplist"]) do
        if self._cacheConfig[ip][fileinfo] then
            self._cacheConfig[ip][fileinfo] = nil
        end
    end

    --恢复当前filelist下面对应文件的状态
    for i = 1, #self._fileList do
        if self._fileList[i].path == fileinfo and fileValue ~= 10 then
            self.nodes.lvFileList:pushBackCustomItem(self:creatLineItem(i, self._fileList[i], UPDATETAB))
        end
    end
end

function UpdateLayer:delFileListUpdateItem(index, item)
    if item then
        self.nodes.lvFileList:removeChild(item)
    end
end

-- 开始更新文件到Update文件夹
-- 一条条更新，调用updateAssets
function UpdateLayer:onbtnUpdate()
    if not next(self._fileList) then
        return
    end
    local itemIndex = 1
    for index, fileinfo in pairs(self._fileList) do
        if fileinfo.mtime ~= self._cacheConfig[gDbgConfig.update_server][fileinfo.path] then
            local item = self.nodes.lvFileList:getItem(itemIndex-1)
            itemIndex = itemIndex + 1
            self:downloadFile(index, fileinfo, item)
        end
    end

   
end

function UpdateLayer:onBtnConnect()
    if not self._session or not self.nodes.txtIp or not self.nodes.btnConnect then return end

    if self._session:isReady() then
        self._session:close()
        self._fileList  = {}
        self.nodes.lvFileList:removeAllChildren()

        return
    end

    local strIp = "ws://"..tostring(self.nodes.txtIp:getString())

    gDbgConfig.update_server = strIp

    local bFind = false
    for i, ip in pairs(self._cacheConfig["iplist"]) do
        if ip == strIp then
            bFind = true
        end
    end

    if false == bFind then
        table.insert(self._cacheConfig["iplist"], strIp)
    end

    if nil == self._cacheConfig[gDbgConfig.update_server] then
        self._cacheConfig[gDbgConfig.update_server] = {}
    end

    self.nodes.lvFileList:removeAllChildren()
    --self.nodes.lvFileListDel:removeAllChildren()

    self._fileList  = {}
    self._session:connect()
    self:showFileList()
end

function UpdateLayer:csdbg(...)
    local s = string.format(...)
	print(string.format( "csdbg:%s",s ))
end

function UpdateLayer:parseS2I(t)
    local i = 1
    while true do
        local si = tostring(i)
        if not t[si] then
            break
        end
        t[i] = t[si]
        t[si] = nil
        i = i + 1
    end
end

function UpdateLayer:getFileDir( filename )
    return string.match(filename, "(.+)/[^/]*%.%w+$").."/"
end

function UpdateLayer:freshFileList(filelists)
    for i = 1, #filelists do 
        if self._cacheConfig[gDbgConfig.update_server] and self._cacheConfig[gDbgConfig.update_server][filelists[i].path] and self._cacheConfig[gDbgConfig.update_server][filelists[i].path] ~= filelists[i].mtime then
            self:setItemChangeOnListView(i, true)
        end
    end
end

function UpdateLayer:getZipFilelist(zipfilename)
     self._session:reqMsg("ziplist", {filename = zipfilename}, function(rsp)
            self:parseS2I(rsp.filelist)
            local filelistzip = zipfilename.."filelist"
            if self._cacheConfig[gDbgConfig.update_server][filelistzip] == nil then
                self._cacheConfig[gDbgConfig.update_server][filelistzip] = {}
            end

            for i = 1, #rsp.filelist do
                local fileinfo = rsp.filelist[i]
                table.insert(self._cacheConfig[gDbgConfig.update_server][filelistzip], fileinfo.path)
            end
     end)
end

function UpdateLayer:cacheZipFilelist(filepath)
    local filelistzip = filepath.."filelist"

    if self._cacheConfig[gDbgConfig.update_server][filelistzip] == nil then
        return
    end

    for i, file in pairs(self._cacheConfig[gDbgConfig.update_server][filelistzip]) do
        if nil == self._cacheConfig["delfilelist"][file] or self._cacheConfig["delfilelist"][file] ~= FILE_FROM_PATH then
            self._cacheConfig["delfilelist"][file] = FILE_FROM_ZIP
        end
    end

    self._cacheConfig[gDbgConfig.update_server][filelistzip] = nil
end

function UpdateLayer:strippath(filename)
    filename = string.gsub(filename, "\\", "/")
   
    local tsfilename = string.reverse(filename)
    local _, i = string.find(tsfilename, '/')
    if i == nil then
        return filename
    end

    local pos = string.len(tsfilename) - i + 1

    return string.sub(filename, pos+1, string.len(tsfilename))
end

function UpdateLayer:showDelFileList(fileinfo)
    self.nodes.lvFileListDel:removeAllChildren()

    local index = 1
    for file, i in pairs(self._cacheConfig["delfilelist"]) do
        if self._cacheConfig["delfilelist"][file] >  0 then
            self.nodes.lvFileListDel:pushBackCustomItem(self:creatLineItem(index, {name = self:strippath(file)}, DELTAB))
            index = index + 1
        end
    end
end

function UpdateLayer:showFileList(date)
    self._session:reqMsg("filelist", function(rsp)

        if rsp.errorcode ~= "" then
            if rsp.errorcode == "wrong dir" then 
                DbgInterface:showMsg("服务端目录结构建错了,请检查update目录(应该包含游戏缩写例如update/yhwh/)")
            end
            return
        end

        self:parseS2I(rsp.filelist)
        print("请求文件列表成功，共"..#rsp.filelist.."份文件")
        self._fileList = rsp.filelist
        for i = 1, #rsp.filelist do
            if self._cacheConfig[gDbgConfig.update_server] and self._cacheConfig[gDbgConfig.update_server][self._fileList[i].path] and self._cacheConfig[gDbgConfig.update_server][self._fileList[i].path] == self._fileList[i].mtime then
                print( self._fileList[i].name.."已经更新过了,请检查文件")
            else
                self.nodes.lvFileList:pushBackCustomItem(self:creatLineItem(i, rsp.filelist[i], UPDATETAB))
            end
        end
        self:freshFileList(rsp.filelist)
    end)
end

function UpdateLayer:getTempFileName(filename)
    local idx = filename:match(".+()%.%w+$")

    if idx then 
        local file = filename:sub(1, idx - 1)
        local extra  = filename:sub(idx, filename:len())
        local tempfilename = file.."temp"..extra

        return tempfilename
    end

    return filename
end

function UpdateLayer:writeFileData(filename, filedata, mode)
    local filedir = self:getFileDir(filename)
    self:csdbg("Update filename:%s", filename)
    self:csdbg("Update filedir:%s", filedir)
    if not fileutils:isDirectoryExist(filedir) then
        fileutils:createDirectory(filedir)
    end

    if mode == nil then
        mode = "wb"
    end
    
    local f = io.open(filename, mode)
    if not f then
        return OPEN_FILE_FAILED
    end
    f:setvbuf("no")
    if not f:write(filedata) then
        return WRITE_FILE_FAILED
    end
    f:close()
    return WRITE_FILE_SUCCESS
end

function UpdateLayer:downLoadFileProgressEvent(event, item)
    if not event then return end

    local lineItem = self.nodes.lvFileList:getItem(event.index-1)
    if item and lineItem ~= item then
        lineItem = item
    end

    if not lineItem then return end
    local itemNode = lineItem:getChildByName("Node")
    if not itemNode then return end
    local panel = itemNode:getChildByName("Panel")
    if not panel then return end
    local downloadPanel = panel:getChildByName("Panel_Download")
    if not downloadPanel then return end

    local lbProcess  = downloadPanel:getChildByName("LB_Process")
    if event.currentSize == 0 then
        downloadPanel:show()
        lbProcess:setPercent(0)
        return
    end

    if event.currentSize < event.totalSize then
        lbProcess:setPercent(event.currentSize*100/event.totalSize)
    elseif event.currentSize >= event.totalSize then
        lbProcess:setPercent(100)
        downloadPanel:hide()
    end
end

function UpdateLayer:receiveData(rsp)
    local fileinfo = self._cacheItem[rsp.reqid].fileinfo
    local status = tonumber(rsp.status)
    if status > 0 then
        DbgInterface:showMsg(string.format("Update file:%s Error", fileinfo.name))
        return
    end

    local filedata = MCCrypto:decodeBase64(rsp.message, rsp.message:len())
    local filename = updatePath .. string.gsub(rsp.filename, "\\", "/")

    if self._cacheData[rsp.reqid] == nil then
        self._cacheData[rsp.reqid] = {}
    end

    table.insert(self._cacheData[rsp.reqid], filedata)

    if rsp.totalsize > rsp.currentsize and #self._cacheData[rsp.reqid] < MAXCACHE then
        local event = {
            index       = self._cacheItem[rsp.reqid].index,
            totalSize   = rsp.totalsize,
            currentSize = rsp.currentsize
        }
        self:downLoadFileProgressEvent(event, self._cacheItem[rsp.reqid].item)
        return
    end
        
    local tempfilename = self:getTempFileName(filename)
    local nResult      = self:writeFileData(tempfilename, table.concat(self._cacheData[rsp.reqid]), "a+b")
    self._cacheData[rsp.reqid] = nil

    if nResult == WRITE_FILE_SUCCESS then
        if rsp.totalsize <= rsp.currentsize and status == 0 then
                
            os.rename(tempfilename, filename)
            cc.FileUtils:getInstance():removeFile(tempfilename)
            if string.match(fileinfo.name, ".zip") then
                MCAgent:getInstance():decompress(filename, updatePath)
                -- cc.FileUtils:getInstance():removeFile(filename)
            end
                
            local event = {
                index       = self._cacheItem[rsp.reqid].index,
                totalSize   = rsp.totalsize,
                currentSize = rsp.currentsize
            }
            self:downLoadFileProgressEvent(event, self._cacheItem[rsp.reqid].item)

            self._cacheConfig[gDbgConfig.update_server][fileinfo.path] = fileinfo.mtime
            self._cacheConfig["delfilelist"][fileinfo.path] = FILE_FROM_PATH

            self._cacheData[rsp.reqid] = nil
            DbgInterface:showMsg("Update Ok")

            if string.match(fileinfo.name, ".zip") then
                self:cacheZipFilelist(fileinfo.path)
            end

            self:delFileListUpdateItem(self._cacheItem[rsp.reqid].index, self._cacheItem[rsp.reqid].item)
            self._cacheItem[rsp.reqid] = nil
        end

    elseif nResult == WRITE_FILE_FAILED then
            cc.FileUtils:getInstance():removeFile(tempfilename)
            self._cacheData[rsp.reqid] = nil
            DbgInterface:showMsg("Update Error Write")
    elseif nResult == OPEN_FILE_FAILED then
            self._cacheData[rsp.reqid] = nil
            cc.FileUtils:getInstance():removeFile(tempfilename)
            DbgInterface:showMsg("Update Error File Write")
    end
end

function UpdateLayer:downloadFile(index, fileinfo, item)
    DbgInterface:showMsg(string.format("Update file:%s", fileinfo.name))

     if string.match(fileinfo.name, ".zip") then
        self:getZipFilelist(fileinfo.path)
     end

     self:downLoadFileProgressEvent({index = index, currentSize = 0}, item);

     self._session:reqMsg("filedata", {filename = fileinfo.path}, function(rsp)
          self._cacheItem[rsp.reqid] = {index = index, item = item, fileinfo = fileinfo}
          self:receiveData(rsp)
    end)
end

----[[ 
--fileinfo 
--{
--    path,           -- send to server
--    name            -- show in ui
--}    
----]]
function UpdateLayer:creatLineItem(index, fileinfo, tab)
    local node = cc.CSLoader:createNode(self.RES_LINE[tab])
    local panel = node:getChildByName("Panel")
    panel:getChildByName("Text_FileName"):setString(fileinfo.name)

    node:setPosition(cc.p(0, 2))

    local custom_item = ccui.Layout:create()
    custom_item:addChild(node)
    custom_item:setAnchorPoint(0, 0)
    custom_item:setSwallowTouches(false)
    custom_item:setContentSize(cc.size(500, 70))

    panel:setSwallowTouches(false)
    local btnDel = panel:getChildByName("Btn_Del")
    if btnDel then
        btnDel:addClickEventListener(function() 
            self:delFileListDelItem(index, custom_item)
        end)
    end

    panel:addTouchEventListener(function(sender, state)
        if state == TOUCH_EVENT_ENDED then
             local begin_p = panel:getTouchBeganPosition()
             local end_p   = panel:getTouchEndPosition()
             if math.abs(end_p.y - begin_p.y) > 30 then
            
            else
                if tab and tab == UPDATETAB then
                    if fileinfo.mtime == self._cacheConfig[gDbgConfig.update_server][fileinfo.path] then
                        DbgInterface:showMsg(string.format("File:%s is the latest version", fileinfo.name))
                         return
                    end
                    self:downloadFile(index, fileinfo, custom_item)
                end
            end
        end
    end)

    return custom_item
end

function UpdateLayer:setItemChangeOnListView(index, bUpdate)
    local lineItem = self.nodes.lvFileList:getItem(index-1)
    if not lineItem then return end
    local itemNode = lineItem:getChildByName("Node")
    if not itemNode then return end
    local panel = itemNode:getChildByName("Panel")
    if not panel then return end

    if bUpdate == true then
        panel:getChildByName("Text_FileName"):setTextColor(cc.c3b(255,0,0))
    else
        panel:getChildByName("Text_FileName"):setTextColor(cc.c3b(252,252,252))
    end
end

function UpdateLayer:setUpdateToolIp(strServerIp)

    if self.nodes.txtIp then
        self.nodes.txtIp:setString("")
        self.nodes.txtIp:setTextColor(cc.c3b(78,252,131))
        self.nodes.txtIp:setString(strServerIp)
    end
end

function UpdateLayer:updateBtnConnect(nMsg)
    if not nMsg then return end

   
    if nMsg == UpdateClientDef.UPDATESERVER_CONNECT_FAILED or nMsg == UpdateClientDef.UPDATESERVER_CONNECT_CLOSE then
        self.nodes.btnConnect:setTitleText("连接")
        self.nodes.txtIp:setTouchEnabled(true)
        self.nodes.txtIp:setEnabled(true)
    end

     if nMsg == UpdateClientDef.UPDATESERVER_CONNECT_OK then
        self.nodes.btnConnect:setTitleText("断开连接")
        self.nodes.txtIp:setTouchEnabled(false)
        self.nodes.txtIp:setEnabled(false)
    end
end

function UpdateLayer:saveCache()
     for file, i in pairs(self._cacheConfig["delfilelist"]) do
        if self._cacheConfig["delfilelist"][file] == 0 then
            self._cacheConfig["delfilelist"][file] = nil
        end
     end

     self._cacheConfig["updateServer"] = gDbgConfig.update_server
     local data = cc.load("json").json.encode(self._cacheConfig)
     self:writeFileData(cacheFileName, data)
end

function UpdateLayer:readCache()
    if self:fileExists(cacheFileName) then
        local data  = fileutils:getStringFromFile(cacheFileName)
        self._cacheConfig = cc.load("json").json.decode(data)
    end
    
    if nil == self._cacheConfig[gDbgConfig.update_server] then
        self._cacheConfig[gDbgConfig.update_server] = {}
    end

    if nil == self._cacheConfig["iplist"] then
        self._cacheConfig["iplist"] = {}
    end
    table.insert(self._cacheConfig["iplist"], gDbgConfig.update_server)

    if nil == self._cacheConfig["delfilelist"] then
        self._cacheConfig["delfilelist"] = {}
    end

    return self._cacheConfig
end

function UpdateLayer:fileExists(path)
    local cacheFile = io.open(path, "rb")
    if cacheFile then
        cacheFile:close()
    end

    return cacheFile ~= nil
end

function UpdateLayer:registerKeyBoardEvent()
     self._keyListener = cc.EventListenerKeyboard:create()
     self._keyListener:registerScriptHandler(handler(self,self.onKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)

     self._resNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._keyListener, self._resNode)
end

function UpdateLayer:onKeyboardReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACK then
       self:onBack()
        -- 0 - 9按键, test用
    elseif keyCode >= cc.KeyCode.KEY_0 and keyCode <= cc.KeyCode.KEY_9 then
        self:onBack()
    end
end

return UpdateLayer
