module(..., package.seeall);

local widget = require("widget")

local customUI = require("scripts.util.CustomUI")

PauseMenuOverlay = {}

-- Constructor
function PauseMenuOverlay:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function PauseMenuOverlay:renderButton()
    local pauseButton = widget.newButton{
        width = 60,
        height = 60,
        defaultFile = "images/menus_common/pause_button.png",
        overFile = "images/menus_common/pause_button_tapped.png",
        onRelease = function(event)
            self.game:goto("PAUSEMENU")
            return true
        end
    }
    pauseButton:setReferencePoint(display.TopRightReferencePoint)
    pauseButton.x = display.contentWidth + 2 * display.screenOriginX
    pauseButton.y = display.screenOriginY
    self.pauseButton = pauseButton
end

function PauseMenuOverlay:dismissButton()
    self.pauseButton:removeSelf()
    self.pauseButton = nil
end

function PauseMenuOverlay:renderPauseScreen()

end

function PauseMenuOverlay:dismissPauseScreen()

end



function PauseMenuOverlay:dismissAll()
    self.alphaRect:removeSelf()
    self.alphaRect = nil
    self.tutorialGroup:removeSelf()
    self.tutorialGroup = nil
end

