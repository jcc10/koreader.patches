--[[
    This user patch changes how folders are displayed (adds icons and removes slashes).
--]]

local BD = require("ui/bidi")
local BookList = require("ui/widget/booklist")
local Device = require("device")
local DocumentRegistry = require("document/documentregistry")
local Event = require("ui/event")
local FileManagerShortcuts = require("apps/filemanager/filemanagershortcuts")
local ReadCollection = require("readcollection")
local UIManager = require("ui/uimanager")
local ffi = require("ffi")
local ffiUtil = require("ffi/util")
local filemanagerutil = require("apps/filemanager/filemanagerutil")
local lfs = require("libs/libkoreader-lfs")
local util = require("util")
local _ = require("gettext")
local Screen = Device.screen
local T = ffiUtil.template

local FileChooser = require("ui/widget/filechooser")

function FileChooser:getListItem(dirpath, f, fullpath, attributes, collate)
    local item = {
        text = f,
        path = fullpath,
        attr = attributes,
    }
    if attributes.mode == "file" then
        -- set to false to show all files in regular font
        -- set to "opened" to show opened files in bold
        -- otherwise, show new files in bold
        local show_file_in_bold = G_reader_settings:readSetting("show_file_in_bold")
        item.bidi_wrap_func = BD.filename
        item.is_file = true
        if collate.item_func ~= nil then
            collate.item_func(item, self.ui)
        end
        if show_file_in_bold ~= false then
            if item.opened == nil then -- could be set in item_func
                item.opened = BookList.hasBookBeenOpened(item.path)
            end
            item.bold = item.opened
            if show_file_in_bold ~= "opened" then
                item.bold = not item.bold
            end
        end
        item.dim = self.ui and self.ui.selected_files and self.ui.selected_files[item.path]
        item.mandatory = self:getMenuItemMandatory(item, collate)
    else -- folder
        if item.text == "./." then -- added as content of an unreadable directory
            item.text = _("Current folder not readable. Some content may not be shown.")
        else
            -- item.text = item.text.."/" -- Original code
            item.text = BD.mirroredUILayout() and BD.ltr(item.text .. " ") or (" " .. item.text)
            item.bidi_wrap_func = BD.directory
            if collate.can_collate_mixed and collate.item_func ~= nil then -- used by user plugin/patch, don't remove
                collate.item_func(item, self.ui)
            end
            if dirpath then -- file browser or PathChooser
                item.mandatory = self:getMenuItemMandatory(item)
            end
        end
    end
    return item
end

function FileChooser:genItemTable(dirs, files, path)
    local collate = self:getCollate()
    local collate_mixed = G_reader_settings:isTrue("collate_mixed")
    local reverse_collate = G_reader_settings:isTrue("reverse_collate")
    local sorting = self:getSortingFunction(collate, reverse_collate)

    local item_table = {}
    if collate.can_collate_mixed and collate_mixed then
        table.move(dirs, 1, #dirs, 1, item_table)
        table.move(files, 1, #files, #item_table + 1, item_table)
        table.sort(item_table, sorting)
    else
        table.sort(files, sorting)
        if not collate.can_collate_mixed then -- keep folders sorted by name not reversed
            sorting = self:getSortingFunction(self.collates.strcoll)
        end
        table.sort(dirs, sorting)
        table.move(dirs, 1, #dirs, 1, item_table)
        table.move(files, 1, #files, #item_table + 1, item_table)
    end

    if path then -- file browser or PathChooser
        if path ~= "/" and not (G_reader_settings:isTrue("lock_home_folder") and
                                path == G_reader_settings:readSetting("home_dir")) then
            table.insert(item_table, 1, {
                text = BD.mirroredUILayout() and BD.ltr("Back ") or " Back",
                path = path.."/..",
                is_go_up = true,
            })
        end
        if self.show_current_dir_for_hold then
            table.insert(item_table, 1, {
                text = _("Long-press here to choose current folder"),
                bold = true,
                path = path.."/.",
            })
        end
    end

    -- lfs.dir iterated node string may be encoded with some weird codepage on
    -- Windows we need to encode them to utf-8
    if ffi.os == "Windows" then
        for _, v in ipairs(item_table) do
            if v.text then
                v.text = ffiUtil.multiByteToUTF8(v.text) or ""
            end
        end
    end

    return item_table
end