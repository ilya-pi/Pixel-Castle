module(..., package.seeall)

Conf = {
	-- absoluteWidth = 570,
	absoluteWidth = 480,
	absoluteHeight = 360
}

-- Conf.absXOffset = (display.contentWidth - Conf.absoluteWidth) / 2
Conf.absXOffset = display.screenOriginX
-- Conf.absYOffset = (display.contentHeight - Conf.absoluteHeight) / 2
Conf.absYOffset = display.screenOriginY

