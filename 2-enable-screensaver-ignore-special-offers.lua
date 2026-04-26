--[[
    copied from https://harsh17.in/kindle/
    untested right now, should do what my script was meant to do.
]]--

local Device = require("device")
Device.supportsScreensaver = function() return true end
Device.powerd:initWakeupMgr()
