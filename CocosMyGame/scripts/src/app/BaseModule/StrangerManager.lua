local manager = class("StrangerManager")
local fileName
local fullPath

local MAX_NUMBER = 4
local srangerList={}

function manager:Load()
    local user=mymodel('UserModel'):getInstance()
    local gameID=my.getGameID()
    fileName="StrangerData_"..tostring(user.nUserID).."_"..tostring(gameID)..".json"
    fullPath=my.getFullCachePath(fileName)

    local json = cc.load("json").json
    if(my.isCacheExist(fileName))then
        local ofile = MCFileUtils:getInstance():getStringFromFile(fullPath)
        if( ofile == "")then
            srangerList.list={}
            manager:Save()
            return
        end
        local des = json.decode(ofile)
        srangerList=des
        printf("~~~~~~~load ok [%s]~~~~~~~~~~~",fullPath)
    else
        srangerList.list={}
        manager:Save()
    end
end

function manager:Save()
    local json = cc.load("json").json
    local str = json.encode(srangerList)

    local f = io.open(fullPath, 'w')
    if(f)then
        f:write(str)
        f:close()
    end
end

function manager:AddStranger(param)
    for i,v in pairs(srangerList.list)do
        if(v.userId == param.userId)then
            table.remove(srangerList.list,i)
            break
        end
    end

    table.insert(srangerList.list,1,param)
    if(table.maxn(srangerList.list) > MAX_NUMBER)then
        table.remove(srangerList.list)
    end
    manager.Save()
end

function manager:DeleteStranger(userId)
    for i,v in pairs(srangerList.list)do
        if(v.userId == userId)then
            table.remove(srangerList.list,i)
            manager.Save()
            return
        end
    end
end

function manager:GetAllStranger()
    return srangerList
end

return manager