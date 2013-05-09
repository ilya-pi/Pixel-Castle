module(..., package.seeall);

TutorialScreen = {}

-- Constructor
function TutorialScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function TutorialScreen:render()
    self.tutorialGroup = display.newGroup()

    local imageWidth = display.contentWidth
    local imageHeight = display.contentHeight
    local imageAspectRatio = imageWidth / imageHeight
    if display.screenOriginX ~= 0 then
        imageWidth = display.contentWidth - 2 * display.screenOriginX
        imageHeight = imageWidth / imageAspectRatio
    elseif display.screenOriginY ~= 0 then
        imageHeight = display.contentHeight - 2 * display.screenOriginY
        imageWidth = imageHeight * imageAspectRatio
    else
        imageWidth = display.contentWidth
        imageHeight = display.contentHeight
    end

    self.tutorialImage = display.newImageRect("images/tutorial-screen.png", imageWidth, imageHeight)
    self.tutorialImage.alpha = 0
    self.tutorialImage:setReferencePoint(display.CenterReferencePoint)
    self.tutorialImage.alpha, self.tutorialImage.x, self.tutorialImage.y = 1, display.contentWidth / 2, display.contentHeight / 2
    self.tutorialImage:addEventListener("touch", function()
        if  self.game.state.name == "TUTORIAL" then
            self.game:goto("P1")
        end
    end)
    self.tutorialGroup:insert(self.tutorialImage)
end

function TutorialScreen:dismiss()
    self.tutorialImage:removeSelf()
    self.tutorialImage = nil
    self.tutorialGroup:removeSelf()
    self.tutorialGroup = nil
end

