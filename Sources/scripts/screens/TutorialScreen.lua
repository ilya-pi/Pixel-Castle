module(..., package.seeall);

local customUI = require("scripts.util.CustomUI")

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

    self.alphaRect = display.newRect(0, 0, imageWidth, imageHeight)
    self.alphaRect.alpha = 0
    self.alphaRect:setReferencePoint(display.CenterReferencePoint)
    self.alphaRect:setFillColor(0, 0, 0, 255)
    self.alphaRect.alpha, self.alphaRect.x, self.alphaRect.y = 0.6, display.contentWidth / 2, display.contentHeight / 2
    self.alphaRect:addEventListener("touch",
        function(event)
            if event.phase == "ended" then
                self.game:goto("P1")
            end
            return true
        end
    )
    self.tutorialGroup:insert(self.alphaRect)

    -- self.controlAndHand = display.newImageRect("images/tutorial_hand.png", 120, 120)
    -- self.controlAndHand:setReferencePoint(display.CenterReferencePoint)
    -- self.controlAndHand.x = display.contentWidth / 2
    -- self.controlAndHand.y = display.contentHeight / 2 + 50
    -- self.tutorialGroup:insert(self.controlAndHand)

    -- customUI.text("Drag to adjust the firing angle!", display.contentWidth / 2, display.contentHeight / 2 - 50, 28, self.tutorialGroup)
    customUI.danceText("Hi!", display.contentWidth / 2, display.contentHeight / 2 - 50, 28, self.tutorialGroup)
end

function TutorialScreen:dismiss()
    transition.to( self.alphaRect, { time=400, alpha=0, onComplete=function()
        self.alphaRect:removeSelf()
        self.alphaRect = nil
    end } )
    transition.to( self.tutorialGroup, { time=400, alpha=0, onComplete=function()
        self.tutorialGroup:removeSelf()
        self.tutorialGroup = nil
    end } )
end

