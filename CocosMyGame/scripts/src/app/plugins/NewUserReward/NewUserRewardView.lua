local TabView = cc.load("myccui").TabView
local viewCreator = cc.load("ViewAdapter"):create()

viewCreator.viewConfig = {
    "res/hallcocosstudio/newuser/Layer_NewUserReward.csb",
    {
        panelShade = 'Panel_Shade',
        panelMain = "Panel_Main",
        {
            _option = {
                prefix = "Panel_Main."
            },
            nodeRewardBox = "Node_RewardBox",
            btnTakeReward = "Btn_TakeReward",
            {
                _option = {
                    prefix = "Btn_TakeReward."
                },
                textTakeReward = "Text_TakeReward"
            }
        }
    }
}

function viewCreator:onCreateView(viewNode)
end

return viewCreator
