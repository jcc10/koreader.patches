--[[
    copied from https://harsh17.in/kindle/
    Tested on a "Special" Kindle 3G running KO Reader 2026.03, and a "Normal" Kindle 4th Gen running KO Reader 20206.03. 
]]--

local Device = require("device")
Device.supportsScreensaver = function() return true end
Device.powerd:initWakeupMgr()
