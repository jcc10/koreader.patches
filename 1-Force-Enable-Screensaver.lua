-- Patches Kindle Device Definitions to allow for Screen Savers regardless of if the device is enrolled in the "ad supported" mode.
-- This is ONLY for devices that have had all support dropped as they can't exactly have the ads removed via payment.

local Kindle = require("device/kindle/device")

Kindle.supportsScreensaver = function(self) 
  return true

Kindle.isSpecialOffers = function(self)
  return false

Kindle.hasSpecialOffers = function(self)
  return false

-- Hopefully I actually understood how to write this?
