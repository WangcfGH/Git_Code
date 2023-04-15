--Example: cc.load('qrutils').createQRNode("http://www.baidu.com")

local qrencode= import("src.packages.qrutils.QREncode")

local function createQRNode(context, qrsize)
    if not context then return nil end
    qrsize = qrsize or 200
    local ok, tab_or_message = qrencode.qrcode(context)
    if ok then
        local pointCount = #tab_or_message
        local pointSize = 5
        local bgSize = (pointCount + 2) * pointSize  --背景大小
        local drawNode = cc.DrawNode:create()
        drawNode:drawSolidRect(cc.p(0, 0), cc.p(bgSize, bgSize), cc.c4f(1, 1, 1, 1))
        for i,v in pairs(tab_or_message) do
            if v then
                for j,k in pairs(v) do
                    if k > 0 then
                        drawNode:drawSolidRect(cc.p(i * pointSize, bgSize - j * pointSize), cc.p((i + 1) * pointSize, bgSize - (j + 1) * pointSize), cc.c4f(0, 0, 0, 1))
                    end
                end
            else
                print("createQRNode not have v")
            end
        end
        drawNode:setScale(qrsize / bgSize)
        return drawNode
    end

    return nil
end
local _M = {
    createQRNode = createQRNode,
}
return _M
