-- 用来播放Node动画和armature动画，不涉及其它逻辑 Node以对象池形式管理
cc.exports.AnimationPlayer = {}

local unactivatedAniNodes = {}
local activatedAniNodes = {}

local ANITYPE = {
    NODE = 1,
    ARMATURE = 2,
}

local countList = {

}

local function countJudge(nodeName)
    if not countList[nodeName] then
        countList[nodeName] = 0
    end
end 

local function createNode(nodeName, aniType)
    local node
    if aniType == ANITYPE.NODE then
        node = cc.CSLoader:createNode(nodeName)
        if not node.action then
            node.action = cc.CSLoader:createTimeline(nodeName)
            node.action:retain()
        end
    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(nodeName)  -- 加载动画文件
        local fileName = string.match(nodeName, ".+/([^/]*%.%w+)$")
        local idx = string.match(fileName, ".+()%.%w+$")
        local resName = string.sub(fileName, 1, idx-1)
        node = ccs.Armature:create(resName)
    end

    countJudge(nodeName)
    node.nodeName = nodeName
    node.countName = nodeName .. countList[nodeName]
    countList[nodeName] = countList[nodeName] + 1
    print("aniNode name is " .. node.countName)
    node:retain()

    return node
end

local function nameJudge(nodeName)
    if not nodeName then
        print('Need specify type')
        return
    end
    if not activatedAniNodes[nodeName] then
        activatedAniNodes[nodeName] = {}
    end

    if not unactivatedAniNodes[nodeName] then
        unactivatedAniNodes[nodeName] = {}
    end
end

local function getNode(nodeName, aniType)
    nameJudge(nodeName)
    local node = unactivatedAniNodes[nodeName][#unactivatedAniNodes[nodeName]]
    if node then
        table.remove(unactivatedAniNodes[nodeName], #unactivatedAniNodes[nodeName])
    else
        node = createNode(nodeName, aniType)
    end
    table.insert(activatedAniNodes[nodeName], node)
    return node
end

local function collectNode(node)
    local findRes = table.keyof(activatedAniNodes[node.nodeName], node)
    if not findRes then
        return
    end

    node:removeFromParent()
    node:stopAllActions()

    print("aniNode " .. node.countName .. " is collect")

    table.insert(unactivatedAniNodes[node.nodeName], node)
    table.removebyvalue(activatedAniNodes[node.nodeName], node)
end

-- 动画的预加载
-- function AnimationPlayer:preloadAni(nodeName, aniType, num, interval, callback)
--     nameJudge(nodeName)
--     interval = interval or 0
--     local sche = nil
--     sche = xyx.load("Scheduler"):schedule(function ()
--         if #activatedAniNodes[nodeName] + #unactivatedAniNodes[nodeName] < num then
--             local pptfPlugin = createNode(nodeName, aniType)
--             table.insert(unactivatedAniNodes[nodeName], pptfPlugin)
--         else
--             xyx.load("Scheduler"):unschedule(sche)
--             if callback then
--                 callback()
--             end
--         end
--     end, interval)
-- end

-- 播放已经添加在场景中的节点动画
-- params = {
--     aniNode,            -- 播放动画的节点
--     aniInfo = {
--         aniName,        -- 动画名称
--         resPath,        -- 资源路径
--         isLoop,         -- 是否循环
--     },
--     callback,           -- 非循环动画结束的回调
-- }
function AnimationPlayer:playExistNodeFrameAni(aniNode, aniInfo, callback)
    local parentNode = aniNode:getParent()
    if not parentNode then
        print("aniNode is not exist node")
        return
    end

    aniInfo.aniName = aniInfo.aniName or 'ani'
    aniInfo.isLoop = aniInfo.isLoop or false
    aniNode:stopAllActions()

    if not aniNode.action then
        aniNode.action = cc.CSLoader:createTimeline(aniInfo.resPath)
        aniNode.action:retain()
    end

    -- 父节点退出时回收action
    parentNode:registerScriptHandler(function(event)
        if event == "exit" then
            if aniNode.action then
                aniNode.action:release()
                aniNode.action = nil
            end
        end
    end)

    -- local action = cc.CSLoader:createTimeline(aniInfo.resPath)
    aniNode.action:play(aniInfo.aniName, aniInfo.isLoop)
    aniNode.action:setFrameEventCallFunc(function (frame)
        local eventName = frame:getEvent()
        if eventName == 'end' then
            aniNode:stopAllActions()
            if type(callback) == 'function' then
                callback()
            end
        end
    end)

    aniNode:runAction(aniNode.action)
    return aniNode
end

function AnimationPlayer:stopExistNodeFrameAni(aniNode)
    if aniNode then
        aniNode:stopAllActions()
    end
end

-- 播放需要先生成节点的帧动画
-- params = {
--     parentNode,         -- 需要添加动画的父节点
--     aniInfo = {
--         aniName,        -- 动画名称
--         resPath,        -- 资源路径
--         isLoop,         -- 是否循环
--         notCollect,     -- 检测到end帧事件之后是否自动回收节点
--     },
--     position,           -- 节点位置
--     customSetting       -- 对动画节点的自定义设置（比如子节点中的一些文字值）
--     eventListen         -- 其它自定义的帧事件监听
--     callback,           -- 动画结束的回调函数(暂时只对非Loop动画有效)
-- }
function AnimationPlayer:playNodeFrameAni(parentNode, aniInfo, position, customSetting, eventListen, callback)
    aniInfo.aniName = aniInfo.aniName or 'ani'
    aniInfo.isLoop = aniInfo.isLoop or false
    aniInfo.notCollect = aniInfo.notCollect or false
    position = position or cc.p(0, 0)

    local aniNode = getNode(aniInfo.resPath, ANITYPE.NODE)
    if aniNode:getParent() then
        aniNode:removeFromParent()
        print("aniNode" .. aniNode.countName .. " parent exist")
    end
    aniNode:stopAllActions()
    aniNode:setPosition(position)
    parentNode:addChild(aniNode)

    -- 父节点exit的时候需要移除节点
    parentNode:registerScriptHandler(function(event)
        if event == "exit" then
            collectNode(aniNode)
        end
    end)

    if type(customSetting) == 'function' then
        customSetting(aniNode)
    end

    -- 默认节点动画播放
    if not aniNode.action then
        aniNode.action = cc.CSLoader:createTimeline(aniInfo.resPath)
        aniNode.action:retain()
    end
    aniNode.action:play(aniInfo.aniName, aniInfo.isLoop)
    aniNode.action:setFrameEventCallFunc(function (frame)
        local eventName = frame:getEvent()
        if eventName == 'end' then
            -- 当不循环的时候才停止动画且从场景移除
            if (not aniInfo.isLoop) then
                if not aniInfo.notCollect then
                    collectNode(aniNode)
                end
                if type(callback) == 'function' then
                    callback()
                end
            end
        else
            if type(eventListen) == 'function' then
                eventListen(eventName)
            end
        end
    end)
    aniNode:runAction(aniNode.action)

    return aniNode
end


-- params = {
--     parentNode      -- 父节点
--     nodeResPath     -- 节点资源路径
--     position        -- 位置
--     customPlay      -- 自定义动画播放方式的函数function(aniNode, callback)
-- }
-- 一个作为动画出现的节点，且播放方式自己定义
function AnimationPlayer:playCustomNodeAni(parentNode, nodeResPath, position, customPlay)
    local aniNode = getNode(nodeResPath, ANITYPE.NODE)
    aniNode:stopAllActions()
    aniNode:setPosition(position)
    parentNode:addChild(aniNode)
    -- 父节点exit的时候需要移除节点
    parentNode:registerScriptHandler(function(event)
        if event == "exit" then
            collectNode(aniNode)
        end
    end)
    
    -- 调用callback即可自动回收aniNode，否则需要自己调用stopNodeFrameAni
    customPlay(aniNode, function ()
        collectNode(aniNode)
    end)

    return aniNode
end

-- 只能停止从AnimationPlayer生成的节点动画
function AnimationPlayer:stopNodeFrameAni(aniNode)
    collectNode(aniNode)
end

function AnimationPlayer:playExistArmatureAni(armature, aniInfo, callback)
    aniInfo.aniName = aniInfo.aniName or 'ani'
    local animation = armature:getAnimation()
    animation:setMovementEventCallFunc(function (armatureBack, movementType, movementID)
        if (movementType == ccs.MovementEventType.complete) or (movementType == ccs.MovementEventType.loopComplete) then
            if type(callback) == 'function' then
                callback()
            end
        end 
    end)
    animation:play(aniInfo.aniName)
end

function AnimationPlayer:playCustomArmatureAni(parentNode, armatureResPath, position, customPlay)
    position = position or cc.p(0, 0)
    local armature = getNode(armatureResPath , ANITYPE.ARMATURE)
    armature:setPosition(position)
    parentNode:addChild(armature)

    -- 父节点exit的时候需要移除节点
    parentNode:registerScriptHandler(function(event)
        if event == "exit" then
            collectNode(armature)
        end
    end)

    if type(customPlay) == 'function' then
        customPlay(armature, function ()
            collectNode(armature)
        end)
    end

    return armature
end

function AnimationPlayer:playArmatureAni(parentNode, aniInfo, position, callback)
    aniInfo.aniName = aniInfo.aniName or 'ani'
    aniInfo.scale = aniInfo.scale or 1
    position = position or cc.p(0, 0)
    local armature = getNode(aniInfo.resPath , ANITYPE.ARMATURE)
    armature:setPosition(position)
    armature:setScale(aniInfo.scale)
    parentNode:addChild(armature)

    -- 父节点exit的时候需要移除节点
    parentNode:registerScriptHandler(function(event)
        if event == "exit" then
            collectNode(armature)
        end
    end)

    local animation = armature:getAnimation()
    animation:setMovementEventCallFunc(function (armatureBack, movementType, movementID)
        if (movementType == ccs.MovementEventType.complete) or (movementType == ccs.MovementEventType.loopComplete) then
            if type(callback) == 'function' then
                callback()
            end
            collectNode(armature)
        end 
    end)
    animation:play(aniInfo.aniName)
    return armature
end

-- 回收所有已经激活的节点
function AnimationPlayer:collectAllAni()
    for _, v in pairs(activatedAniNodes) do
        collectNode(v)
    end
end

function AnimationPlayer:clearAllAnimations()
    for _, v in pairs(unactivatedAniNodes) do
        v:release()
    end

    for _, v in pairs(activatedAniNodes) do
        v:release()
    end

    unactivatedAniNodes = {}
    activatedAniNodes = {}
end

return AnimationPlayer