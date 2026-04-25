--[[
    This user patch disables the back button when you are in the home folder.
--]]

local FileChooser = require("ui/widget/filechooser")


function FileChooser:onBack()
    local back_to_exit = G_reader_settings:readSetting("back_to_exit", "prompt")
    local back_in_filemanager = G_reader_settings:readSetting("back_in_filemanager", "default")
    if back_in_filemanager == "default" then
        if back_to_exit == "always" then
            return self:onClose()
        elseif back_to_exit == "disable" then
            return true
        elseif back_to_exit == "prompt" then
            UIManager:show(ConfirmBox:new{
                text = _("Exit KOReader?"),
                ok_text = _("Exit"),
                ok_callback = function()
                    self:onClose()
                end,
            })
            return true
        end
    elseif back_in_filemanager == "parent_folder" then
        -- self:changeToPath(string.format("%s/..", self.path)) -- Why force it when we have the below function?
        self:onFolderUp() -- This is it... It's so stupid.
        return true
    end
end
