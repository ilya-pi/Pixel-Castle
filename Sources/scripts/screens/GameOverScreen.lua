module(..., package.seeall)

local widget = require("widget")
local imageHelper = require("scripts.util.Image")

GameOverScreen = {} -- required arg: game

-- Constructor
function GameOverScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    o.displayGroup = display.newGroup()
    return o
end

local function infoText(message, x, y, size, group)
    local textShadow = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local text = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    textShadow:setReferencePoint(display.CenterReferencePoint)
    text:setReferencePoint(display.CenterReferencePoint)
    -- textShadow.x, textShadow.y = x + 2, y + 2
    -- text.x, text.y = x, y
    group:insert(textShadow)
    group:insert(text)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function GameOverScreen:render()
    local overlay = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    self.displayGroup:insert(overlay)
    overlay:setFillColor(195, 214, 93, 150)

    local playerTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 2, "TrebuchetMS-Bold", 48)
    local playerText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4, "TrebuchetMS-Bold", 48)
    self.displayGroup:insert(playerTextShadow)
    self.displayGroup:insert(playerText)
    playerTextShadow:setReferencePoint(display.CenterReferencePoint)
    playerText:setReferencePoint(display.CenterReferencePoint)
    playerTextShadow:setTextColor(255, 255, 255)
    playerText:setTextColor(37, 54, 34)

    local messageTextShadow = display.newText( ".", display.contentWidth / 2 + 2, display.contentHeight / 4 + 52 + 2, "TrebuchetMS-Bold", 48)
    local messageText = display.newText( ".", display.contentWidth / 2, display.contentHeight / 4 + 52, "TrebuchetMS-Bold", 48)
    self.displayGroup:insert(messageTextShadow)
    self.displayGroup:insert(messageText)
    messageTextShadow:setReferencePoint(display.CenterReferencePoint)
    messageText:setReferencePoint(display.CenterReferencePoint)
    messageTextShadow:setTextColor(255, 255, 255)
    messageText:setTextColor(37, 54, 34)

    if self.game.castle1:isDestroyed(self.game) and self.game.castle2:isDestroyed(self.game) then
        messageTextShadow.text = "Draw!"
        messageText.text = "Draw!"
        playerTextShadow:removeSelf()
        playerText:removeSelf()
    elseif self.game.castle2:isDestroyed(self.game) then
        messageTextShadow.text = "Wins!"
        messageText.text = "Wins!"
        playerTextShadow.text = "Player 1"
        playerText.text = "Player 1"
    else
        messageTextShadow.text = "Wins!"
        messageText.text = "Wins!"
        playerTextShadow.text = "Player 2"
        playerText.text = "Player 2"
    end

    infoText(self.game.castle1:health() .. " bricks", 20, display.contentHeight / 2 + 42, 24, self.displayGroup)
    infoText(self.game.castle2:health() .. " bricks", 3 * display.contentWidth / 4, display.contentHeight / 2 + 42, 24, self.displayGroup)

    local mainMenuBtn = widget.newButton{
        id = "menubtn",
        label = "Main menu",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
                print("main menu")
            end
    }
    self.displayGroup:insert(mainMenuBtn)
    mainMenuBtn.x, mainMenuBtn.y = 160, 280

    local playAgain = widget.newButton{
        id = "playbtn",
        label = "Play again",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
        emboss = false,
        color = 65,
        default = "images/button.png",
        over = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onEvent = function(event)
                print("play again")
                if  (self.game.state.name == "GAMEOVER") then    
                    self.game:goto("P1")
                    print("play")
                end

            end
    }
    self.displayGroup:insert(playAgain)
    playAgain.x, playAgain.y = 320, 280

    local castles = imageHelper.loadImageData("data/castles.json") --todo move to static initialization

    for i,v in ipairs(imageHelper.renderImage(5, 20, castles["castle1"], 5)) do
        self.displayGroup:insert(v)
    end
    for i,v in ipairs(imageHelper.renderImage(75, 20, castles["castle2"], 5)) do
        self.displayGroup:insert(v)
    end
end

function GameOverScreen:dismiss()
    self.displayGroup:removeSelf()
end
