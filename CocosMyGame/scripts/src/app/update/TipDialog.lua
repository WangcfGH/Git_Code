local TipDialog = class('TipDialog', require('src.app.update.PopupDialog'))

TipDialog.CSBPATH = 'res/hallcocosstudio/update/updatetip.csb'
TipDialog.BUTTONNAME = {'Btn_Cancel', 'Btn_Commit'}
TipDialog.VIEWNODENAME = {
    PANEL       = 'Img_MainBox',
    TITLE       = 'Text_Title',
    TIPS        = 'Text_UpdateSize',
    SUBTITLE    = 'nil',
}

return TipDialog