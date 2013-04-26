module(..., package.seeall);

local tutorialGroup = display.newGroup()

tutorialImage = display.newImageRect("images/tutorial-screen.png", 570, 360)
tutorialImage.alpha = 0
tutorialImage:setReferencePoint(display.CenterReferencePoint)

function tutorialScreen()
    tutorialImage.alpha, tutorialImage.x, tutorialImage.y = 1, display.contentWidth / 2, display.contentHeight / 2
end

function dismissTutorialScreen()
    tutorialGroup:removeSelf()
    tutorialImage:removeSelf()
end

