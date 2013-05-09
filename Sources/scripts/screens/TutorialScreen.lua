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

    self.tutorialImage = display.newImageRect("images/tutorial-screen.png", 570, 360) --todo: explain magic numbers
    self.tutorialImage.alpha = 0
    self.tutorialImage:setReferencePoint(display.CenterReferencePoint)
    self.tutorialImage.alpha, self.tutorialImage.x, self.tutorialImage.y = 1, display.contentWidth / 2, display.contentHeight / 2
    self.tutorialImage:addEventListener("tap",
        function()
            self.game:goto("P1")
            print("start game")
        end
    )

    self.tutorialGroup:insert(self.tutorialImage)
end

function TutorialScreen:dismiss()
    self.tutorialGroup:removeSelf()
    self.tutorialImage:removeSelf()
end

