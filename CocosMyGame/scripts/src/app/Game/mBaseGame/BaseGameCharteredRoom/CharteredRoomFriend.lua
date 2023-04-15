
local CharteredRoomFriend = class("CharteredRoomFriend")

local addDes
local idToCtrlList={}
function CharteredRoomFriend:create(panel)
    self._panel = panel

    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    local des = json.decode(ofile)
    addDes=des["CHARTEREDROOM_FRIENDSOURCE_RECOMMENDER"]

    ofile = MCFileUtils:getInstance():getStringFromFile("AppConfig.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    des = json.decode(ofile)

    self._basePos={}
    self._basePos.x=750
    self._basePos.y=60

    self:update()
end

function CharteredRoomFriend:update()
--get list
    local list = cc.exports.PUBLIC_INTERFACE.GetAllStranger()
    for i,v in pairs(self._panel:getChildren())do
        v:setVisible(false)
    end
    if(list.list==nil)then
        return
    end
    if(table.maxn(list.list)==0)then
        return
    end

--judge friend
    local idList={}
    for kk,dd in pairs(list.list)do
        table.insert(idList,dd.userId)
    end

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        for kk,dd in pairs(idList)do
            if(tcyFriendPlugin:isFriend(dd))then
                cc.exports.PUBLIC_INTERFACE.DeleteStranger(dd)
            end
        end
    end
--get new starnger list
    list = cc.exports.PUBLIC_INTERFACE.GetAllStranger()

    printf("~~~~~~~~~~start read FriendDes~~~~~~~~~~~")
    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    local des = json.decode(ofile)

--start show
    local user=mymodel('UserModel'):getInstance()
    idList={}
    for tt,jj in pairs(list.list)do
        if(jj.userId ~= user.nUserID)then
            table.insert(idList,jj)
        end
    end

    idToCtrlList={}
    local gap=30
    for ii,vv in pairs(idList)do
        
        local bind={}
        bind.index=ii
        bind.userId=vv.userId
        table.insert(idToCtrlList,bind)

        local name = "F_"..tostring(ii)
        local node = self._panel:getChildByName(name)
        if(node ~= nil)then
            node:getChildByName("Panel_back"):getChildByName("Text_name"):setString(vv.userName)

            local sub = os.time() - vv.time
            local timeDay, timeHour, timeMinute, timeSecond = CharteredRoomFriend:convertTimeForm(sub)
            local text=""
            if(timeDay~=0)then
                text = tostring(timeDay)..des.day..des.des
            elseif(timeHour~=0)then
                text = tostring(timeHour)..des.hour..des.des
            else
                text = tostring(timeMinute)..des.minute..des.des
            end
            node:getChildByName("Panel_back"):getChildByName("Text_time"):setString(text)

            node:getChildByName("Panel_back"):getChildByName("Btn_add"):onTouch(function(e)
                if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                    my.playClickBtnSound()
                elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    self._room:addFriend(vv.userId,addDes)
                elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
                elseif(e.name=='moved')then

                end
            end)

            node:setVisible(true)

            local b = node:getChildByName("Panel_back"):getChildByName("Img_head_bk"):getChildByName("Btn_head")
            b:setVisible(true)
            b:loadTextureNormal(cc.exports.getHeadResPath(vv.sex), ccui.TextureResType.localType)
            b:loadTexturePressed(cc.exports.getHeadResPath(vv.sex),ccui.TextureResType.localType)
            
            b:onTouch(function(e)
                if(e.name=='began')then
                    my.playClickBtnSound()
                elseif(e.name=='ended')then
                    local y = node:getPositionY()
                    local pos=self._basePos
                    pos.y=y+gap
                    if(pos.y>400)then
                        pos.y=400
                    end
                    self._room:showFlagForAddFriend(vv,pos,addDes)
                elseif(e.name=='cancelled')then
                elseif(e.name=='moved')then

                end
            end)
        end

    end

-- get head path
    if(table.maxn(idList)==0)then
        return
    end
    local data={}
    local userIds={}
    for q,da in pairs(idList)do
        local a={}
        a.userID=da.userId
        a.url=da.url
        if(a.url)then
            if(a.url~="")then
                table.insert(data,a)
            else
                table.insert(userIds,a.userID)
            end
        else
            table.insert(userIds,a.userID)
        end
    end

    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    local t = imageCtrl:getPortraitCacheForGS()
    imageCtrl:getImageForGameScene(data, 60-60, handler(self,self.onGetHeadPath))

    if(table.maxn(userIds)>0)then
        imageCtrl:getImageByUserIDs(userIds,'60-60',handler(self,self.onGetHeadPath))
    end

end

function CharteredRoomFriend:onGetHeadPath(list)
    if(not my.isInGame())then
        return
    end
    dump(list)
    for i,v in pairs(idToCtrlList)do
        for ii, vv in pairs(list)do
            if(v.userId == vv.userID)then
                local name = "F_"..tostring(v.index)
                local node = self._panel:getChildByName(name)
                if( (node ~= nil) and (vv.path~="") )then
                    
                    local b = node:getChildByName("Panel_back"):getChildByName("Img_head_bk"):getChildByName("Btn_head")
                    b:setVisible(true)
                    b:loadTextureNormal(vv.path, ccui.TextureResType.localType)
                    b:loadTexturePressed(vv.path,ccui.TextureResType.localType)
                break
                end
            end

        end
    end

end

function CharteredRoomFriend:convertTimeForm(second)
    local timeDay = math.floor(second/86400)
    local timeHour= math.fmod(math.floor(second/3600),24)
    local timeMinute = math.fmod(math.floor(second/60), 60)
    local timeSecond = math.fmod(second, 60)
    return timeDay, timeHour, timeMinute, timeSecond
end

return CharteredRoomFriend