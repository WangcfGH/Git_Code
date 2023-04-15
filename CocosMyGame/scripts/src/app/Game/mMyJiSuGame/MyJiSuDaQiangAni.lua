local MyJiSuDaQiangAni = class("MyJiSuDaQiangAni")

function MyJiSuDaQiangAni:setGameController(gameController)
    self._gameController = gameController
end

--计算打枪动画顺序
function MyJiSuDaQiangAni:calcPlayDaQiangAniSequence(daqiangResult)
    print("calcPlayDaQiangAniSequence")
    local sequence = {}
    local chairCount = self._gameController:getTableChairCount()
    for i = 1, chairCount do
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(i - 1)
        local count = 0
        for j = 1, chairCount do
            if daqiangResult[i][j] ~= 0 then
                count = count + 1
            end
        end
        table.insert(sequence, {
            chairNO = i-1, 
            count = count,
            drawIndex = drawIndex
        })
    end
    --先按照从小枪到大枪，相同则按照drawindex
    table.sort(sequence, function (left, right)
        if left.count == right.count then
            return left.drawIndex < right.drawIndex
        end
        return left.count < right.count
    end)
    
    dump(daqiangResult, "daqiangResult")
    dump(sequence, "sequenceResult")
    return sequence
end

function MyJiSuDaQiangAni:getShouJiAniConfig(aniType)
    local aniConfig = {
        {
            path = "res/Game/Skeleton/NewPlayMode/zuolun/zuolun-shouji.ExportJson",
            name = "zuolun-shouji",
        },
        {
            path = "res/Game/Skeleton/NewPlayMode/chongfengqiang/cfq-shouji.ExportJson",
            name = "cfq-shouji",
        },
        {
            path = "res/Game/Skeleton/NewPlayMode/jiatelin/jtl-shouji.ExportJson",
            name = "jtl-shouji",
        },
    }
    return aniConfig[aniType]
end

function MyJiSuDaQiangAni:getShouJiPosition(aniType, drawIndex)
    local pos = self._gameController:getPlayerPosition(drawIndex)
    if aniType == 2 then
        pos.y = pos.y - 80
    elseif aniType == 3 then
        pos.y = pos.y - 100
    end
    return pos
end

function MyJiSuDaQiangAni:shoujiAni(aniType, drawIndex)
    local aniConfig = self:getShouJiAniConfig(aniType)
    local pos = self:getShouJiPosition(aniType, drawIndex)
    if not aniConfig then return end
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(aniConfig.path)
    local armature = ccs.Armature:create(aniConfig.name)
    armature:getAnimation():playWithIndex(0)
    armature:setPosition(pos)

    local function animationEvent(armatureBack,movementType,movementID)
        local id = movementID
        if movementType == ccs.MovementEventType.loopComplete then
            armature:removeFromParentAndCleanup()
        elseif movementType == ccs. MovementEventType.complete then
            armature:removeFromParentAndCleanup()
        elseif movementType == ccs. MovementEventType.start then
            
        end
    end

    armature:getAnimation():setMovementEventCallFunc(animationEvent)
    self._gameController._baseGameScene:addChild(armature)
end

function MyJiSuDaQiangAni:playDaQiangSound(aniType)
    local fileName = nil
    if aniType == 1 then
        fileName = "zuolun"
    elseif aniType == 2 then
        fileName = "chongfengqiang"
    elseif aniType == 3 then
        fileName = "jiatelin"
    end
    if fileName then
        local pathName = "res/Game/GameSound/NewPlayMode/" .. fileName..".mp3"
        audio.playSound(pathName, false)
    end
end

function MyJiSuDaQiangAni:getdaQiangAniConfig(aniType)
    local aniConfig = {
        {
            path = "res/Game/Skeleton/NewPlayMode/zuolun/zuolun.ExportJson",
            name = "zuolun",
        },
        {
            path = "res/Game/Skeleton/NewPlayMode/chongfengqiang/chongfengqiang.ExportJson",
            name = "chongfengqiang",
        },
        {
            path = "res/Game/Skeleton/NewPlayMode/jiatelin/jiatelin.ExportJson",
            name = "jiatelin",
        },
    }
    return aniConfig[aniType]
end

function MyJiSuDaQiangAni:isNeedFlipX(drawIndexFrom, drawIndexTo)
    local bRet = false --默认枪头朝左，枪柄朝下
    if drawIndexFrom == 3 then 
        if drawIndexTo == 2 then --3号朝2号打枪需要调整方向
            bRet = true
        else
            bRet = false
        end
    elseif drawIndexFrom == 2 then
        bRet = false
    else -- 1、4号位置 枪头朝右，枪柄朝下
        bRet = true
    end
    print("isNeedFlipX: ", bRet)
    return bRet
end

function MyJiSuDaQiangAni:getDaQiangPosition(aniType, drawIndex)
    local pos = self._gameController:getPlayerPosition(drawIndex)
    if aniType == 2 then
        pos.y = pos.y - 80
    elseif aniType == 3 then
        pos.y = pos.y - 100
    end
    return pos
end

function MyJiSuDaQiangAni:getAngleByPos(p1,p2)
    local p = {}
    p.x = p2.x - p1.x
    p.y = p2.y - p1.y
           
    local r = math.atan2(p.y,p.x)*180/math.pi
    print("夹角[-180 - 180]:",r)
    return r
end

function MyJiSuDaQiangAni:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo, bFlipX)
    local nRotation = 0
    local fromPos = self:getDaQiangPosition(aniType, drawIndexFrom)
    local toPos = self:getDaQiangPosition(aniType, drawIndexTo)

    local angle = self:getAngleByPos(fromPos, toPos)

    if bFlipX then
        nRotation = -angle
    else
        nRotation = 180 - angle
    end
    if nRotation > 180 and nRotation < 360 then
        nRotation = nRotation - 360
    elseif nRotation < -180 and nRotation > -360 then
        nRotation = 360 + nRotation
    end
    print("getDaQiangRotation: ", nRotation)
    return nRotation
end

function MyJiSuDaQiangAni:getZuoLunAni(aniType, drawIndexFrom, drawIndexTo)
    local closureInfo
    closureInfo = {
        callback = nil,
        playAni = function ()
            local aniConfig = self:getdaQiangAniConfig(aniType)
            if not aniConfig then return end
            local pos = self:getDaQiangPosition(aniType, drawIndexFrom)
            local bNeedFlipX = false --默认情况下，枪口朝左，枪柄朝下。需要根据情况将其翻转180
            bNeedFlipX = self:isNeedFlipX(drawIndexFrom, drawIndexTo[1])
            local nRotation = 0
            nRotation = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[1], bNeedFlipX)
            
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(aniConfig.path)
            local armature = ccs.Armature:create(aniConfig.name)
            armature:getAnimation():playWithIndex(0)
            if bNeedFlipX then
                armature:setScaleX(-1)
            end
            armature:setRotation(nRotation)
            armature:setPosition(pos)

            local function animationEvent(armatureBack,movementType,movementID)
                local id = movementID
                if movementType == ccs.MovementEventType.loopComplete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.complete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.start then
                    
                end
            end

            armature:getAnimation():setMovementEventCallFunc(animationEvent)
            self._gameController._baseGameScene:addChild(armature)

            local node = cc.Node:create()
            local delay = cc.DelayTime:create(0.5)
            local function callbackAfterDelay()
                for i = 1, #drawIndexTo do
                    self:shoujiAni(aniType, drawIndexTo[i])
                end
                self:playDaQiangSound(aniType)
                node:removeFromParentAndCleanup()
            end
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackAfterDelay))
            self._gameController._baseGameScene:addChild(node)
            node:runAction(sequence)
        end
    }
    return closureInfo
end

function MyJiSuDaQiangAni:getChongFengAni(aniType, drawIndexFrom, drawIndexTo)
    local closureInfo
    closureInfo = {
        callback = nil,
        playAni = function ()
            local aniConfig = self:getdaQiangAniConfig(aniType)
            if not aniConfig then return end
            local pos = self:getDaQiangPosition(aniType, drawIndexFrom)
            local bNeedFlipX = false --默认情况下，枪口朝左，枪柄朝下。需要根据情况将其翻转180
            bNeedFlipX = self:isNeedFlipX(drawIndexFrom, drawIndexTo[1])
            local nRotation1 = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[1], bNeedFlipX)
            local nRotation2 = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[2], bNeedFlipX)
            local nRotation = (nRotation1 + nRotation2) / 2 --先折中处理，之后看是否需要动画
            
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(aniConfig.path)
            local armature = ccs.Armature:create(aniConfig.name)
            armature:getAnimation():playWithIndex(0)
            if bNeedFlipX then
                armature:setScaleX(-1)
            end
            armature:setRotation(nRotation)
            armature:setPosition(pos)

            local function animationEvent(armatureBack,movementType,movementID)
                local id = movementID
                if movementType == ccs.MovementEventType.loopComplete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.complete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.start then
                    
                end
            end

            armature:getAnimation():setMovementEventCallFunc(animationEvent)
            self._gameController._baseGameScene:addChild(armature)

            local node = cc.Node:create()
            local delay = cc.DelayTime:create(1)
            local function callbackAfterDelay()
                for i = 1, #drawIndexTo do
                    self:shoujiAni(aniType, drawIndexTo[i])
                end
                self:playDaQiangSound(aniType)
                node:removeFromParentAndCleanup()
            end
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackAfterDelay))
            self._gameController._baseGameScene:addChild(node)
            node:runAction(sequence)
        end
    }
    return closureInfo
end

function MyJiSuDaQiangAni:getJiaTeLinAni(aniType, drawIndexFrom, drawIndexTo)
    local closureInfo
    closureInfo = {
        callback = nil,
        playAni = function ()
            local aniConfig = self:getdaQiangAniConfig(aniType)
            if not aniConfig then return end
            local pos = self:getDaQiangPosition(aniType, drawIndexFrom)
            local bNeedFlipX = false --默认情况下，枪口朝左，枪柄朝下。需要根据情况将其翻转180
            bNeedFlipX = self:isNeedFlipX(drawIndexFrom, drawIndexTo[1])
            local nRotation1 = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[1], bNeedFlipX)
            local nRotation2 = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[2], bNeedFlipX)
            local nRotation3 = self:getDaQiangRotation(aniType, drawIndexFrom, drawIndexTo[3], bNeedFlipX)
            local nRotation = (nRotation1 + nRotation2 + nRotation3) / 3 --先折中处理，之后看是否需要动画
            
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(aniConfig.path)
            local armature = ccs.Armature:create(aniConfig.name)
            armature:getAnimation():playWithIndex(0)
            if bNeedFlipX then
                armature:setScaleX(-1)
            end
            armature:setRotation(nRotation)
            armature:setPosition(pos)

            local function animationEvent(armatureBack,movementType,movementID)
                local id = movementID
                if movementType == ccs.MovementEventType.loopComplete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.complete then
                    armature:removeFromParentAndCleanup()
                    if type(closureInfo.callback) == 'function' then
                        closureInfo.callback()
                    end
                elseif movementType == ccs. MovementEventType.start then
                    
                end
            end

            armature:getAnimation():setMovementEventCallFunc(animationEvent)
            self._gameController._baseGameScene:addChild(armature)

            local node = cc.Node:create()
            local delay = cc.DelayTime:create(0.5)
            local function callbackAfterDelay()
                for i = 1, #drawIndexTo do
                    self:shoujiAni(aniType, drawIndexTo[i])
                end
                self:playDaQiangSound(aniType)
                node:removeFromParentAndCleanup()
            end
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackAfterDelay))
            self._gameController._baseGameScene:addChild(node)
            node:runAction(sequence)
        end
    }
    return closureInfo
end

function MyJiSuDaQiangAni:getDaQiangAni(aniType, drawIndexFrom, drawIndexTo)
    local closureInfo
    if aniType == 1 then
        closureInfo = self:getZuoLunAni(aniType, drawIndexFrom, drawIndexTo)
    elseif aniType == 2 then
        closureInfo = self:getChongFengAni(aniType, drawIndexFrom, drawIndexTo)
    elseif aniType == 3 then
        closureInfo = self:getJiaTeLinAni(aniType, drawIndexFrom, drawIndexTo)
    end

    return closureInfo
end

--按顺序播放打枪动画
function MyJiSuDaQiangAni:playDaQiangAni(daqiangResult, callback)
    local sequence = self:calcPlayDaQiangAniSequence(daqiangResult)
    local actSeq = {}
    for i, tbl in ipairs(sequence) do
        local chairNO = tbl.chairNO
        local result = daqiangResult[chairNO+1]
        local aniType = tbl.count
        local closureInfo = nil
        if aniType > 0 then
            local drawIndexTo = {}
            for j = 1, self._gameController:getTableChairCount() do
                if j ~= chairNO +1 and result[j] > 0 then
                    local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(j-1)
                    table.insert(drawIndexTo, drawIndex)
                end
            end
            closureInfo = self:getDaQiangAni(aniType, tbl.drawIndex, drawIndexTo)
        end
        if closureInfo then
            if #actSeq ~= 0 then
                actSeq[#actSeq].callback = closureInfo.playAni
            end
            table.insert(actSeq, closureInfo)
        end
    end
    if #actSeq ~= 0 then
        actSeq[#actSeq].callback = callback
        actSeq[1].playAni()
    else
        if type(callback) == 'function' then
            callback()
        end
    end
end

function MyJiSuDaQiangAni:testZuoLun( )
    local testZuoLun = {
        {1,2},{1,3},{1,4},
        {2,1},{2,3},{2,4},
        {3,1},{3,2},{3,4},
    }
    
    local seq = {}
    for i = 1, #testZuoLun do
        local closureInfo = MyJiSuGameController:getZuoLunAni(1,testZuoLun[i][1],{testZuoLun[i][2]})
        if closureInfo then
            if #seq ~= 0 then
                seq[#seq].callback = closureInfo.playAni
            end
            table.insert(seq, closureInfo)
        end
    end
    seq[1].playAni()
end

function MyJiSuDaQiangAni:testChongFeng( )
    local testChongFeng = {
        {1,2,3},{1,3,2},{1,2,4},{1,4,2},
        {2,1,3},{2,3,1},{2,1,4},{2,4,1},
        {3,1,2},{3,2,1},{3,1,4},{3,4,1},
    }
    -- testChongFeng = {{3,1,2}}

    local seq = {}
    for i = 1, #testChongFeng do
        local closureInfo = MyJiSuGameController:getChongFengAni(2,testChongFeng[i][1],{testChongFeng[i][2],testChongFeng[i][3]})
        if closureInfo then
            if #seq ~= 0 then
                seq[#seq].callback = closureInfo.playAni
            end
            table.insert(seq, closureInfo)
        end
    end
    seq[1].playAni()
end

function MyJiSuDaQiangAni:testJiaTeLin( )
    local testJiaTeLin = {
        {1,2,3,4}, {1,2,4,3}, {1,3,2,4}, {1,3,4,2}, {1,4,2,3}, {1,4,3,2}, 
        {2,1,3,4}, {2,1,4,3}, {2,3,1,4}, {2,3,4,1}, {2,4,1,3}, {2,4,3,1}, 
        {3,1,2,4}, {3,1,4,2}, {3,2,1,4}, {3,2,4,1}, {3,4,1,2}, {3,4,2,1},
        {4,1,2,3}, {4,1,3,2}, {4,2,1,3}, {4,2,3,1}, {4,3,1,2}, {4,3,2,1}, 
    }
    local seq = {}
    for i = 1, #testJiaTeLin do
        local closureInfo = MyJiSuGameController:getJiaTeLinAni(3,testJiaTeLin[i][1],{testJiaTeLin[i][2],testJiaTeLin[i][3],testJiaTeLin[i][4]})
        if closureInfo then
            if #seq ~= 0 then
                seq[#seq].callback = closureInfo.playAni
            end
            table.insert(seq, closureInfo)
        end
    end
    seq[1].playAni()
end

return MyJiSuDaQiangAni