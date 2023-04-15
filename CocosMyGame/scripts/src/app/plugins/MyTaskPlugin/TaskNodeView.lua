
local TaskNodeView = {
	Height  = 150,
    CsbPath = 'res/hallcocosstudio/Task/TaskNode.csb',

	ViewConfig = {
		backImage="Image_2",
		{
			_option={prefix='Image_2.'},
			TaskImage="Image_2",
			TaskDescription="Text_1",
            LoadingBar1="Image_2_0.LoadingBar_1",
            LoadingValue1="Text_2_0",
			--RewardImage1="Image_4",
            RewardValue1="Text_2_1",
			TaskBtn0="Button_1",
			TaskBtn1="Btn_Reward",
            TaskBtn2="Btn_Finish"
			--"Button_1_0",
            --TaskBtn2="Button_1_1",
        	--CheckImage="Image_2_1"
		}
	}
}

return TaskNodeView