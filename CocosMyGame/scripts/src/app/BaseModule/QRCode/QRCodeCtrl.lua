--绘制二维码
local qrencode = require("src/app/BaseModule/QRCode/qrencode.lua")
local QRCodeCtrl = class('QRCodeCtrl')
-- my.addInstance(QRCodeCtrl)

function QRCodeCtrl:ctor()

end

-- 生成二维码并绘制到目标容器中
function QRCodeCtrl:drawQRCode(panel, targetStr)
    local ok, tab_or_message = qrencode.qrcode(targetStr)
    local len = #tab_or_message[1]

    --绘制保存图片大小
    local rect = panel:getContentSize()
    local width = rect.width
    local height = rect.height

    --绘制顶点初始坐标
    local px = 0 
    local py = 0
    --绘制一个正方形的偏移量  clip = {cc.p(10,10),cc.p(10, 20),cc.p(20, 20),cc.p(20, 10)}
    local offset = height / len

    local color = cc.c4b(0, 0, 0, 1)
    local clip
    for x = 1, len do
        for y = len, 1, -1 do
            clip = { cc.p(px, py), cc.p(px, py + offset), cc.p(px + offset, py + offset), cc.p(px + offset, py) }
            color = cc.c4b(1, 1, 1, 1)
            if tab_or_message[x][y] > 0 then
                color = cc.c4b(0, 0, 0, 1)
            end
            --绘制单个矩形
            local draw = cc.DrawNode:create()
            panel:addChild(draw)
            draw:drawPolygon(clip, #clip, color, 0, color)

            py = py + offset
        end
        py = 0
        px = px + offset
    end
end

-- function QRCodeCtrl:drawQRCode(node, param)

--     param = param or {}

--     local qrcodeStr = param.qrcodeStr or "https://www.baidu.com"
--     local ok, tab_or_message = qrencode.qrcode(qrcodeStr)    
--     local len = #tab_or_message[1]
--     -- print(len, "MMMMMMMMMMMMMMMMMMMMMM")

--     --绘制保存图片大小
--     local rect = node:getContentSize()
--     local width = param.width or rect.width
--     local height = param.height or rect.height

--     --绘制顶点坐标
--     local px = param.x or 0
--     local py = param.y or 0
--     --绘制一个正方形的偏移量  clip = {cc.p(10,10),cc.p(10, 20),cc.p(20, 20),cc.p(20, 10)}
--     local p_y = 7

--     local fileName = param.fileName or "mytest.png" --保存的图片名称 
--     local format = param.isJPG and cc.IMAGE_FORMAT_JPG or cc.IMAGE_FORMAT_PNG --png or jpg 格式


--     local color = cc.c4b(0, 0, 0, 1)
--     local clip
--     for x = 1, len do
--         for y = len, 1, -1 do
--             clip = { cc.p(px, py), cc.p(px, py + p_y), cc.p(px + p_y, py), cc.p(px + p_y, py + p_y) }
--             color = cc.c4b(1, 1, 1, 1)
--             if tab_or_message[x][y] > 0 then
--                 color = cc.c4b(0, 0, 0, 1)
--             end
--             --绘制单个矩形
--             local draw = cc.DrawNode:create()
--             node:addChild(draw)
--             draw:drawPolygon(clip, #clip, color, 0, color)

--             py = py + p_y
--         end
--         py = param.y or 0
--         px = px + p_y
--     end

--     local outTexture = cc.RenderTexture:create(width, height)
--     -- local windowSize = cc.Director:getInstance():getWinSize()
--     -- outTexture:setVirtualViewport(cc.p(windowSize.width/2,windowSize.height/2), cc.rect(0, 0, windowSize.width, windowSize.height), cc.rect(0,0,windowSize.width, windowSize.height))
--     outTexture:setKeepMatrix(true)
--     outTexture:beginWithClear(0, 0, 0, 0, 0, 0)
--     node:visit()
--     outTexture:endToLua()
--     -- format: cc.IMAGE_FORMAT_PNG  cc.IMAGE_FORMAT_JPG
--     outTexture:saveToFile(fileName, format)
-- end

function QRCodeCtrl:CreateQrCodeImg()
    
end

return QRCodeCtrl

