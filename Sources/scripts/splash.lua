module(..., package.seeall);

local splashGroup = display.newGroup()

fullSplash = display.newImageRect("images/splash.png", 320, 480)
fullSplash.alpha = 0

function splashScreen()
	splashGroup.alpha = 0
	fullSplash.alpha, fullSplash.x, fullSplash.y = 1, display.contentWidth / 2, display.contentHeight / 2
	beginText = display.newText("Tap to Begin", display.contentWidth / 2 - 50, (display.contentHeight * .75), native.systemFont, 24) 
end

function dismissSplashScreen()
	splashGroup:removeSelf()
	fullSplash:removeSelf()
	beginText:removeSelf()
end