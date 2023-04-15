local KeyBackManager = class("KeyBackManager", import(".UniqueObject"))

function KeyBackManager:ctor()
    self._ctrlStack = {}
end

function KeyBackManager:resetStack(stacName)
    if stacName == nil then return end

    self._ctrlStack[stacName] = {}
end

function KeyBackManager:getStackRootCtrlInfo(stacName)
    local theStack = self._ctrlStack[stacName]
    if theStack then
        return theStack[1]
    end

    return nil
end

function KeyBackManager:pushCtrl(stacName, ctrlName, closeFunc, checkBlock)
    if stacName == nil or ctrlName == nil then return
        false 
    end

    local ctrlInfo = {
        ["ctrlName"] = ctrlName,
        ["closeFunc"] = closeFunc,
        ["checkBlock"] = checkBlock
    }
    self:pushCtrlEx(stacName, ctrlInfo)
end

function KeyBackManager:pushCtrlEx(stacName, ctrlInfo)
    if stacName == nil or ctrlInfo == nil then return end

    if self._ctrlStack[stacName] == nil then
        self._ctrlStack[stacName] = {}
    end

    local theStack = self._ctrlStack[stacName]
    theStack[#theStack + 1] = ctrlInfo
end

--checkBlock返回true，则会让KeyBackManager的onKeyBack处理阻塞在该ctrl上并返回true；
--主要是用来处理某个ctrl弹出后，该ctrl又触发了若干个ctrl，而这些二次触发的弹窗又没办法入栈的情况；
--这个时候设置它的checkBlock()，在该ctrl的状态为关闭时才解除阻塞，这样就可以让该ctrl之上的ctrl先响应KeyBack事件
function KeyBackManager:onKeyBack(stacName)
    if stacName == nil then return end

    local nextCtrl = nil
    local theStack = self._ctrlStack[stacName]
    if theStack == nil then return end
    for i = #theStack, 1, -1 do
        --弹出栈顶ctrl
        nextCtrl = theStack[i]
        if nextCtrl["checkBlock"] then
            local isBlock = nextCtrl["checkBlock"]()
            if isBlock == true then
                return true
            end
        end
        theStack[i] = nil

        --响应返回键
        if nextCtrl["closeFunc"] then
            local isDisposed = nextCtrl["closeFunc"]()
            if isDisposed == true then
                return true
            end
        end
    end

    return false
end

return KeyBackManager