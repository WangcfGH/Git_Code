local UIHelper = class("UIHelper", import("src.app.common.global.UniqueObject"))
local MyResConfig = import("src.app.common.component.MyResConfig")

UIHelper.WHRATIO_OF_ADAPT_SEPERATE = 1.98 --FixedWidth和FixedHeight模式的分隔线

function UIHelper:ctor()
    --用于限制操作的串行性，或者操作的执行周期
    self._opeContextMap = {
        ["xxxx"] = {["isProcessing"] = false, ["beginTime"] = -1, ["endTime"] = -1},
    } 

    --计时器
    self._runtimeWatcher = {
        --[[["EnterGameScene"] = {
            ["timeBegin"] = {["positionName"] = "", ["timeStamp"] = 0},
            ["timeRecords"] = {
                {["positionName"] = "", ["timeStamp"] = 0, ["timeElapsed"] = 0}
            }
        }]]--
    }

    --节点缓存
    self._retainPool = {
        --["itemName"] = {["itemNode"] = nil}
    }
end

--以放大方式体现“按下”状态
function UIHelper:setTouchByScale(touchObj, clickFunc, targetObj, scaleRatio)
    if touchObj == nil or targetObj == nil then return end
    if scaleRatio == nil or type(scaleRatio) ~= "number" then scaleRatio = 1.07 end

    touchObj:addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
            targetObj:setScale(scaleRatio)
        elseif state == ccui.TouchEventType.moved then
        elseif state == ccui.TouchEventType.ended then
            targetObj:setScale(1.0)
            if clickFunc ~= nil and type(clickFunc) == "function" then
                clickFunc()
            end
        else
            targetObj:setScale(1.0)
        end
    end)
end

function UIHelper:setTouchByOpacity(touchObj, clickFunc, targetObj)
    if touchObj == nil or targetObj == nil then return end

    touchObj:addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
            targetObj:setColor(cc.c3b(166,166,166))
        elseif state == ccui.TouchEventType.moved then
        elseif state == ccui.TouchEventType.ended then
            targetObj:setColor(cc.c3b(255,255,255))
            if clickFunc ~= nil and type(clickFunc) == "function" then
                clickFunc()
            end
        else
            targetObj:setColor(cc.c3b(255,255,255))
        end
    end)
end

--对带spineAni节点的元素，setColor无法对spineAniNode生效，需要再单独对其setColor一下
function UIHelper:setTouchByOpacityForObjWithSpineAni(touchObj, clickFunc, targetObj, nodeSpineAniName)
    if touchObj == nil or targetObj == nil then return end

    touchObj:addTouchEventListener(function(sender, state)
        local nodeSpineAni = targetObj:getChildByName(nodeSpineAniName)

        if state == ccui.TouchEventType.began then
            targetObj:setColor(cc.c3b(166,166,166))
            if nodeSpineAni then nodeSpineAni:setColor(cc.c3b(166,166,166)) end
        elseif state == ccui.TouchEventType.moved then
        elseif state == ccui.TouchEventType.ended then
            targetObj:setColor(cc.c3b(255,255,255))
            if nodeSpineAni then nodeSpineAni:setColor(cc.c3b(255,255,255)) end
            if clickFunc ~= nil and type(clickFunc) == "function" then
                clickFunc()
            end
        else
            targetObj:setColor(cc.c3b(255,255,255))
            if nodeSpineAni then nodeSpineAni:setColor(cc.c3b(255,255,255)) end
        end
    end)
end

function UIHelper:setPanelTouch(touchObj, clickFunc)
    if touchObj == nil or clickFunc == nil then return end

    touchObj:addTouchEventListener(function(sender, state)
        if state == ccui.TouchEventType.began then
        elseif state == ccui.TouchEventType.moved then
        elseif state == ccui.TouchEventType.ended then
            clickFunc()
        end
    end)
end

function UIHelper:playAttentionAni(nodeObj, scaleRatio)
    if nodeObj == nil then return end
    scaleRatio = scaleRatio or 1.15

    local scaleTo1 = cc.ScaleTo:create(0.3, scaleRatio)
    local scaleTo2 = cc.ScaleTo:create(0.5, 1.0)
    local scaleTo3 = cc.ScaleTo:create(0.3, scaleRatio)
    local scaleTo4 = cc.ScaleTo:create(0.5, 1.0)
    local callBack  = cc.CallFunc:create(function()

    end)
    local sequence = cc.Sequence:create(scaleTo1, scaleTo2, scaleTo3, scaleTo4, callBack)
    nodeObj:runAction(sequence)
end

function UIHelper:doTextColorCopyAfterCloneNode(nodeRaw, nodeCloned)
    if nodeRaw == nil or nodeCloned == nil then return end

    for _, childNode in pairs(nodeCloned:getChildren()) do
        if tolua.type(childNode) == "ccui.Text" then
            childNode:setTextColor(nodeRaw:getChildByName(childNode:getName()):getTextColor())
        end

        self:doTextColorCopyAfterCloneNode(nodeRaw:getChildByName(childNode:getName()), childNode)
    end
end

function UIHelper:cloneNode(nodeRaw)
    if nodeRaw == nil then return nil end

    local nodeCloned = nodeRaw:clone() 
    UIHelper:doTextColorCopyAfterCloneNode(nodeRaw, nodeCloned) --字体颜色恢复

    return nodeCloned
end

--要求elements的X锚点为0
function UIHelper:adaptElementsToCenterX(elements, centerX, gapX)
    if elements == nil or centerX == nil then return end

    gapX = gapX or 5

    local totalWidth = 0
    for i = 1, #elements do
        totalWidth = totalWidth + elements[i]:getContentSize().width + gapX
    end
    totalWidth = totalWidth - gapX

    local curPosX = centerX - totalWidth / 2
    for i = 1, #elements do
        elements[i]:setPositionX(curPosX)
        curPosX = curPosX + elements[i]:getContentSize().width + gapX
    end
end

--要求bk的X锚点为0.5, elements的X锚点为0
function UIHelper:adaptPanelBkWidth(bk, elements)
    if bk == nil or elements == nil then return end

    local gapX = 3
    local paddingX = 5

    local totalWidth = 0
    for i = 1, #elements do
        totalWidth = totalWidth + elements[i]:getContentSize().width + gapX
    end
    totalWidth = totalWidth - gapX + paddingX * 2

    if bk:getContentSize().width < totalWidth then
        bk:setContentSize(cc.size(totalWidth, bk:getContentSize().height))
    end

    local curPosX = (bk:getPositionX() - bk:getContentSize().width / 2) + paddingX
    for i = 1, #elements do
        elements[i]:setPositionX(curPosX)
        curPosX = curPosX + elements[i]:getContentSize().width + gapX
    end
end

--要求layout锚点为(0.5, 0.5)
function UIHelper:calcGridLayoutConfig(layoutNode, layoutConfig, calcGapXMode, calcGapYMode)
    if layoutNode == nil or layoutConfig == nil then return end

    layoutConfig["visibleWidth"] = layoutNode:getContentSize().width
    layoutConfig["visibleHeight"] = layoutNode:getContentSize().height

    if calcGapXMode == "fillInitColums" then --刚好填充满初始列数
        if layoutConfig["visibleCols"] == 1 then
            layoutConfig["gapX"] = 0
        elseif layoutConfig["visibleCols"] > 1 then
            local totalGapX = layoutConfig["visibleWidth"] - 2 * layoutConfig["paddingX"] - layoutConfig["visibleCols"] * layoutConfig["itemWidth"]
            layoutConfig["gapX"] = totalGapX / (layoutConfig["visibleCols"] - 1)
        end
        if layoutConfig["gapX"] > layoutConfig["gapXMax"] then
            layoutConfig["gapX"] = layoutConfig["gapXMax"]
        end
    elseif calcGapXMode == "fillInitColumsAndAveragePaddingGap" then --刚好填充满初始列数，且等分两侧间隔和item间隔
        if layoutConfig["visibleCols"] == 1 then
            layoutConfig["gapX"] = 0
        elseif layoutConfig["visibleCols"] > 1 then
            local totalGapX = layoutConfig["visibleWidth"] - layoutConfig["visibleCols"] * layoutConfig["itemWidth"]
            layoutConfig["gapX"] = totalGapX / ((layoutConfig["visibleCols"] - 1) + 2)
            layoutConfig["paddingX"] = layoutConfig["gapX"]
        end
    end

    if calcGapYMode == "fillInitRows" then --刚好填充满初始行数
        if layoutConfig["visibleRows"] == 1 then
            layoutConfig["gapY"] = 0
        elseif layoutConfig["visibleRows"] > 1 then
            local totalGapY = layoutConfig["visibleHeight"] - 2 * layoutConfig["paddingY"] - layoutConfig["visibleRows"] * layoutConfig["itemHeight"]
            layoutConfig["gapY"] = totalGapY / (layoutConfig["visibleRows"] - 1)
        end
        if layoutConfig["gapY"] > layoutConfig["gapYMax"] then
            layoutConfig["gapY"] = layoutConfig["gapYMax"]
        end
    end

    layoutConfig["posXStartRaw"] = layoutConfig["itemWidth"] / 2 + layoutConfig["paddingX"]
    layoutConfig["posYStartRaw"] = layoutConfig["visibleHeight"] - layoutConfig["itemHeight"] / 2 - layoutConfig["paddingY"]

    layoutConfig["posXStart"] = layoutConfig["posXStartRaw"]
    layoutConfig["posYStart"] = layoutConfig["posYStartRaw"]
end

--根据rowIndex和colIndex计算
function UIHelper:calcGridItemPos(layoutConfig, rowIndex, colIndex)
    if layoutConfig == nil or rowIndex == nil or colIndex == nil then return end

    local posX = layoutConfig["posXStart"] + (colIndex - 1) * (layoutConfig["itemWidth"] + layoutConfig["gapX"])
    local posY = layoutConfig["posYStart"] - (rowIndex - 1) * (layoutConfig["itemHeight"] + layoutConfig["gapY"])
    return cc.p(posX, posY) 
end

--根据itemIndex计算
function UIHelper:calcGridItemPosEx(layoutConfig, itemIndex)
    if layoutConfig == nil or itemIndex == nil then return end

    local rowIndex, colIndex = nil
    if layoutConfig["scrollDirection"] == "y" then
        rowIndex = math.floor((itemIndex - 1) / layoutConfig["visibleCols"]) + 1
        colIndex = (itemIndex - 1) % layoutConfig["visibleCols"] + 1
    else
        rowIndex = (itemIndex - 1) % layoutConfig["visibleCols"] + 1
        colIndex = math.floor((itemIndex - 1) / layoutConfig["visibleRows"]) + 1
    end

    return self:calcGridItemPos(layoutConfig, rowIndex, colIndex)
end

--计算竖向scrollView的innerContentSize
function UIHelper:initInnerContentSizeForVerticalScrollView(scrollView, layoutConfig, rowsCount)
    if scrollView == nil or layoutConfig == nil or rowsCount == nil then
        return false
    end

    local contentWidth = layoutConfig["visibleWidth"]
    local contentHeight = rowsCount * layoutConfig["itemHeight"] + (rowsCount - 1) * layoutConfig["gapY"] + 2 * layoutConfig["paddingY"]
    if contentHeight < layoutConfig["visibleHeight"] then
        contentHeight = layoutConfig["visibleHeight"]
    end

    layoutConfig["posYStart"] = layoutConfig["posYStartRaw"] + (contentHeight - layoutConfig["visibleHeight"])

    scrollView:setInnerContainerSize(cc.size(contentWidth, contentHeight))

    return true
end

--检查周期
function UIHelper:checkOpeCycle(opeName, cycleLimit)
    local opeContext = self._opeContextMap[opeName]
    if opeContext == nil then return true end

    cycleLimit = cycleLimit or 0.5
    local timeElapsed = socket.gettime() - opeContext["beginTime"]
    if timeElapsed >= 0 and timeElapsed < cycleLimit then
        print("checkOpeCycle return false, opeName "..tostring(opeName))
        return false
    end

    return true
end

--检查串行
function UIHelper:checkOpeSerial(opeName, timeoutVal)
    local opeContext = self._opeContextMap[opeName]
    if opeContext == nil then return true end

    if opeContext["isProcessing"] ~= true then
        return true
    else
        timeoutVal = timeoutVal or 1.0
        local timeElapsed = socket.gettime() - opeContext["beginTime"]
        if timeElapsed >= 0 and timeElapsed < timeoutVal then
            print("checkOpeSerial, an ope already exist, opeName "..tostring(opeName))
            return false
        end
    end

    return true
end

--刷新being
function UIHelper:refreshOpeBegin(opeName)
    local opeContext = self._opeContextMap[opeName]
    if opeContext == nil then
        self._opeContextMap[opeName] = {
            ["isProcessing"] = false, 
            ["beginTime"] = -1, 
            ["endTime"] = -1
        }
        opeContext = self._opeContextMap[opeName]
    end
    opeContext["isProcessing"] = true
    opeContext["beginTime"] = socket.gettime()
    opeContext["endTime"] = -1
end

--刷新end
function UIHelper:refreshOpeEnd(opeName)
    local opeContext = self._opeContextMap[opeName]
    if opeContext == nil then return end

    opeContext["isProcessing"] = false
    opeContext["beginTime"] = -1
    opeContext["endTime"] = socket.gettime()
end

--在FixedHeight适配模式下保持某些界面元素足够大（比如卡牌、按钮等）
function UIHelper:getProperScaleOnFixedHeight()
    local curWHRatio = display.width / display.height
    local prefereedWHRatioOnFixedWidth = UIHelper.WHRATIO_OF_ADAPT_SEPERATE

    --长型屏幕，放大比例动态计算
    if curWHRatio >= prefereedWHRatioOnFixedWidth then
        local properScaleOffset = math.abs(prefereedWHRatioOnFixedWidth - curWHRatio) * 1.15
        properScaleOffset = math.max(properScaleOffset, 0.10)
        properScaleOffset = math.min(properScaleOffset, 0.25)
    
        return (1.0 + properScaleOffset)
    end

    return 1.0
end

--秒表功能，记录运行时间
function UIHelper:beginRuntime(instanceName, positionName)
    if instanceName == nil or positionName == nil then
        return
    end

    local runInstance = self._runtimeWatcher[instanceName]
    if runInstance == nil then
        self._runtimeWatcher[instanceName] = {
            ["timeBegin"] = {}, 
            ["timeRecords"] = {}
        }
        runInstance = self._runtimeWatcher[instanceName]
    end

    runInstance["timeBegin"] = {
        ["positionName"] = positionName,
        ["timeStamp"] = socket.gettime()
    }
    runInstance["timeRecords"] = {}
end

function UIHelper:recordRuntime(instanceName, positionName)
    local runInstance = self._runtimeWatcher[instanceName]
    if runInstance == nil then return end

    local timeBegin = runInstance["timeBegin"]
    local timeRecords = runInstance["timeRecords"]
    local curTimeStamp = socket.gettime()
    local record = {
        ["positionName"] = positionName,
        ["timeStamp"] = curTimeStamp,
        ["timeElapsed"] = curTimeStamp - timeBegin["timeStamp"]
    }
    timeRecords[#timeRecords + 1] = record
end

function UIHelper:printRuntime(instanceName)
    local runInstance = self._runtimeWatcher[instanceName]
    if runInstance == nil then
        print("UIHelper:printRuntime, no runInstance of "..tostring(instanceName))
        return 
    end

    local timeBegin = runInstance["timeBegin"]
    local timeRecords = runInstance["timeRecords"]

    printf("------rrrr runInstance of %s with timeBegin at %s------------------------", instanceName, timeBegin["positionName"])
    for i = 1, #timeRecords do
        printf("timeRecord at %s with time elapsed %f", timeRecords[i]["positionName"], timeRecords[i]["timeElapsed"])
    end
    printf("-----------------------------------------------------------------------------------")
end

function UIHelper:sendGameLoadingLog(enterCode)
    local JudgeNewPlayer = import("src.app.plugins.judgenewplayer.JudgeNewPlayer"):getInstance()
    if JudgeNewPlayer:isNewPlayer() ~= 1 then
        return
    end

    local runInstance = self._runtimeWatcher["EnterGameScene"]
    if runInstance == nil then
        print("UIHelper:printRuntime, no runInstance of EnterGameScene")
        return 
    end

    local timeBegin = runInstance["timeBegin"]

    local curTimeStamp = socket.gettime()
    local timeElapsed = curTimeStamp - timeBegin["timeStamp"]

    local data = {
        nUserID = mymodel('UserModel'):getInstance().nUserID,
        nLoadingTime = math.floor(timeElapsed * 1000),
        nIsEnterSuccess = enterCode,
    }

    local AssistCommon = require('src.app.GameHall.models.assist.common.AssistCommon'):getInstance()
    AssistCommon:onGameLoadingLogReq(data)
end

--节点缓存
function UIHelper:putNodeToRetainPool(itemName, itemNode)
    if itemName == nil or itemNode == nil then
        return false
    end

    if self._retainPool[itemName] == nil then
        itemNode:retain()
        self._retainPool[itemName] = {
            ["itemNode"] = itemNode
        }

        return true
    end

    return false
end

function UIHelper:removeNodeFromeRetainPool(itemName)
    if itemName == nil then
        return false
    end

    local itemRetained = self._retainPool[itemName]
    if itemRetained == nil then
        return false
    end

    itemRetained["itemNode"]:release()

    self._retainPool[itemName] = nil
end

function UIHelper:getNodeFromRetainPool(itemName)
    if itemName == nil then
        return nil
    end

    local itemRetained = self._retainPool[itemName]
    if itemRetained == nil then
        return nil
    end

    return itemRetained["itemNode"]
end

--资源预加载
function UIHelper:preloadGameSceneRes(preloadFinishCallback)
    print('UIHelper:preloadGameSceneRes begin')
    --print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

    local preloadNextImage = function(item)
        if item["resType"] == "plistImage" then
            display.loadImage(item["imagePath"])
            display.loadSpriteFrames(item["plistPath"], item["imagePath"])
            item["isPreloaded"] = true
        elseif item["resType"] == "imageOnly" then
            display.loadImage(item["imagePath"])
            item["isPreloaded"] = true
        end
    end

    for i = 1, #MyResConfig do
        preloadNextImage(MyResConfig[i])
    end
end

function UIHelper:unloadGameSceneRes()
    print('UIHelper:unloadGameSceneRes begin')
    --print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    
    for i = 1, #MyResConfig do
        if item["isPreloaded"] == true then
            display.removeImage(item["imagePath"])
            display.removeSpriteFrames(item["plistPath"], item["imagePath"])
        end
    end

    --[[my.scheduleOnce(function() 
        print('UIHelper:unloadGameSceneRes end')
        print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    end, 2.0)]]--
end

return UIHelper