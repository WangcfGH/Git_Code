local SmallGameInterface = {}

--[Comment]
--没有bgm留空
function SmallGameInterface:stopBGM()
	-- cc.exports.hallBGMplaying = false
    -- local MainCtrl = import('src.app.plugins.mainpanel.MainCtrl'):getInstance()
	-- MainCtrl:stopBGM()
end

--[Comment]
--没有bgm留空
function SmallGameInterface:startBGM()
    -- local MainCtrl = import('src.app.plugins.mainpanel.MainCtrl'):getInstance()
	-- MainCtrl:playBGM()
end

--[Comment]
--获取商城config
function SmallGameInterface:getShopItems()
    local payConfig = mymodel("UpdateConfigsModel"):getInstance():getShopConfigName()
    
    -- local itemList = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/" .. payConfig)
    -- return json.decode(itemList)
    local config = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/" .. payConfig)
    local itemList = json.decode(config)
    if itemList["payconfig"] and itemList["payconfig"]["products"] and itemList["payconfig"]["products"]["product"] then
        local products = itemList["payconfig"]["products"]["product"]
        local tempList = {}
        local index = 1
        for _, product in pairs(products) do
            if product["producttype"] ==1 then
                product["id"] = index
                index = index + 1
                table.insert( tempList, product)
            end
        end
        itemList["payconfig"]["products"]["product"] = tempList
    end

    return itemList
end

--[Comment]
--获取首冲配置
function SmallGameInterface:getCacheFirstItems()
    local shopModel = import('src.app.GameHall.models.ShopModel'):getInstance()
    local dataMap=my.readCache(shopModel:getCacheDataName())
    dataMap=checktable(dataMap)
    return dataMap["Data"] or {}
end

--[Comment]
--快速充值
function SmallGameInterface:quickCharge(params, callback)
    mymodel("PayModel"):getInstance()
    return payModel.quickChargeForSmallGame(params, callback)

    -- local shopModel = mymodel("ShopModel"):getInstance()
    -- local shopItems = shopModel:GetShopItemsInfo()
    -- for _, item in pairs(shopItems) do
    --     if item["price"] == params['Product_Price'] then
    --         shopModel:PayForProduct(item, 1)
    --         break
    --     end
    -- end
end

function SmallGameInterface:getNetProcess()
    return import('src.app.BaseModule.NetProcess'):getInstance()
end

return SmallGameInterface