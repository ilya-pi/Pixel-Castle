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
    pauseButton.x = display.contentWidth - display.screenOriginX
    pauseButton.y = display.screenOriginY
    self.pauseButton = pauseButton
end

function PauseMenuOverlay:dismissButton()
    self.pauseButton:removeSelf()
    self.pauseButton = nil
end

function PauseMenuOverlay:renderPauseScreen()
    self.pauseOverlayGroup = display.newGroup()

    local displayWidth = display.contentWidth - 2 * display.screenOriginX
    local displayHeight = display.contentHeight + 2 * display.screenOriginY

    self.alphaRect = display.newRect(0, 0, displayWidth, displayHeight)
    self.alphaRect.alpha = 0
    self.alphaRect:setReferencePoint(display.CenterReferencePoint)
    self.alphaRect:setFillColor(0, 0, 0, 255)
    self.alphaRect.alpha, self.alphaRect.x, self.alphaRect.y = 0.6, display.contentWidth / 2, display.contentHeight / 2
    self.pauseOverlayGroup:insert(self.alphaRect)

    customUI.text("Drag to adjust the firing angle!", display.contentWidth / 2, display.contentHeight / 2 - 50, 28, self.pauseOverlayGroup)

    local mainMenu = widget.newButton{
        width = 170,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "back_to_main_menu_btn",
        label = "Back to main menu",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("MAINMENU")
            return true
        end
    }
    mainMenu.x, mainMenu.y = display.contentWidth / 4, 260  --end of first quater of screen (center of button coords)
    self.pauseOverlayGroup:insert(mainMenu)

    local backToGame = widget.newButton{
        width = 170,
        height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button_over.png",
        id = "return_to_game",
        label = "Return to game",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto(self.game.exState)
            return true
        end
    }
    backToGame.x, backToGame.y = display.contentWidth / 4 * 3, 260  --end of third quater of screen (center of button coords)
    self.pauseOverlayGroup:insert(backToGame)
end

function PauseMenuOverlay:dismissPauseScreen()

end



function PauseMenuOverlay:dismissAll()
    self.alphaRect:removeSelf()
    self.alphaRect = nil
    self.tutorialGroup:removeSelf()
    self.tutorialGroup = nil
end

