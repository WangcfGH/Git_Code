
local Radio=cc.load('myui').Radio
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/settings/settings.csb',
	{
		backImage="Img_MainBox",
		{
			_option={
				prefix='Img_MainBox.'
			},
			musicSlider='Slider_Music',
			effectSlider='Slider_Sound',
			musicEnableBt='Button_MusicEnable',
			musicDisableBt='Button_MusicDisable',
			effectDisableBt='Button_SoundDisable',
			effectEnableBt='Button_SoundEnable',
			closeBt='Btn_Close',
			--shakeOpenBt='CheckBox_1',
			--shakeCloseBt='CheckBox_1_0',
			--savemodeOpenBt='CheckBox_1_1',
			--savemodeCloseBt='CheckBox_1_0_0',

			usernameTxt='Text_Account',
			usernameBkImg='Img_AccountBG',
			loginBt='Img_AccountSwitch',

			realNameBt='Btn_RegisterNomal',
			fangChengmiBt='Btn_RegisterAnti',
			moreGameBt='Btn_More',

			forbiddenBt='Check_Mute',
			forbiddenCheck='CheckBox_Forbidden_room',
			forbiddenCheckText1='Text_Forbidden_room',
			forbiddenCheckText2='Text_Forbidden_room_0',
			
			versionBt='Btn_ShowVersion',
			clearCacheBt = 'Btn_ClearCache',
			showDbgBt = "Btn_ShowDbg"
		}
	},
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode,isShakeable,isSavemode)
	--[[local shakeRadio=Radio:create(
		{
			viewNode.shakeOpenBt,
			viewNode.shakeCloseBt
		},
		isShakeable
	)
	local savemodeRadio=Radio:create(
		{
			viewNode.savemodeOpenBt,
			viewNode.savemodeCloseBt
		},
		isSavemode
	)
	
	viewNode.shakeRadio=shakeRadio
	viewNode.savemodeRadio=savemodeRadio]]
	if not cc.exports.isSocialSupported() then
		viewNode.forbiddenCheck:setVisible(false)
		viewNode.forbiddenCheckText1:setVisible(false)
		viewNode.forbiddenCheckText2:setVisible(false)
	end

end

return viewCreator