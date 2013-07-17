module(..., package.seeall)

local widget = require("widget")
local imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")

GameOverScreen = {} -- required arg: game

-- Constructor
function GameOverScreen:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

local function infoText(message, x, y, size, group)
    local textShadow = display.newText(message, x + 2, y + 2, "TrebuchetMS-Bold", size)
    local text = display.newText(message, x, y, "TrebuchetMS-Bold", size)
    textShadow:setReferencePoint(display.CenterReferencePoint)
    text:setReferencePoint(display.CenterReferencePoint)
    textShadow.x, textShadow.y = x + 2, y + 2
    text.x, text.y = x, y
    group:insert(textShadow)
    group:insert(text)
    textShadow:setTextColor(255, 255, 255)
    text:setTextColor(37, 54, 34)
    textShadow.text = message
    text.text = message
end

function GameOverScreen:renderVs()
    self.displayGroup = display.newGroup()

    local width = display.contentWidth - 2 * display.screenOriginX
    local height = display.contentHeight - 2 * display.screenOriginY
    
    local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
    self.displayGroup:insert(overlay)
    overlay:setFillColor(195, 214, 93, 150)

    local star = display.newImageRect("images/winner.png", 480, 480)
    local star2 = display.newImageRect("images/winner2.png", 480, 480)
    self.displayGroup:insert(star)
    self.displayGroup:insert(star2)
    star:setReferencePoint(display.CenterReferencePoint)
    star2:setReferencePoint(display.CenterReferencePoint)
    if self.game.castle1:isDestroyed(self.game) and self.game.castle2:isDestroyed(self.game) then
        star.x, star.y = display.contentWidth / 2, height / 2
        star2.x, star2.y = display.contentWidth / 2, height / 2
    elseif self.game.castle2:isDestroyed(self.game) then
        star.x, star.y = display.contentWidth / 6, height / 2
        star2.x, star2.y = display.contentWidth / 6, height / 2
    else
        star.x, star.y = 5 * display.contentWidth / 6, height / 2
        star2.x, star2.y = 5 * display.contentWidth / 6, height / 2
    end    

    self.startTimer = timer.performWithDelay(30, function()
            star.rotation = (star.rotation - 0.3) % 360
            star2.rotation = (star2.rotation + 0.3) % 360
        end, -1)

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
        -- self.game.db:levelComplete(self.game.selectedLevel, 1) --todo: think about screen
    else
        messageTextShadow.text = "Wins!"
        messageText.text = "Wins!"
        playerTextShadow.text = "Player 2"
        playerText.text = "Player 2"
    end

    local castle1 = display.newImageRect("images/levels/" .. self.game.levelName .. "/castle1.png", (100 / game.castle1.height) * game.castle1.width, 100)
    self.displayGroup:insert(castle1)
    castle1:setReferencePoint(display.CenterReferencePoint)
    castle1.x = display.contentWidth / 6
    castle1.y = height / 2

    local castle2 = display.newImageRect("images/levels/" .. self.game.levelName .. "/castle2.png", (100 / game.castle2.height) * game.castle2.width, 100)
    self.displayGroup:insert(castle2)
    castle2:setReferencePoint(display.CenterReferencePoint)
    castle2.x = 5 * display.contentWidth / 6
    castle2.y = height / 2

    infoText( (100 - self.game.castle1:healthPercent()) .. "% destroyed", display.contentWidth / 6, height / 2 + 65, 21, self.displayGroup)
    infoText( (100 - self.game.castle2:healthPercent()) .. "% destroyed", 5 * display.contentWidth / 6, height / 2 + 65, 21, self.displayGroup)    

    local mainMenuBtn = widget.newButton{
        id = "menubtn",
        label = "Main menu",
        font = "TrebuchetMS-Bold",
        fontSize = 24,
        width = 150, height = 40,
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("MAINMENU")
            return true
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
        defaultFile = "images/button.png",
        overFile = "images/button.png",
        labelColor = { default = { 255 }, over = { 0 } },
        onRelease = function(event)
            self.game:goto("LEVEL_INTRO")
            return true
        end
    }
    self.displayGroup:insert(playAgain)
    playAgain.x, playAgain.y = 320, 280    
end

function GameOverScreen:renderCampaign()
    if self.game.castle2:isDestroyed(self.game) then

        self.game.db:levelComplete(self.game.selectedLevel, 1)

        self.displayGroup = display.newGroup()
        local width = display.contentWidth + 2 * display.screenOriginX
        local height = display.contentHeight + 2 * display.screenOriginY
        
        local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
        self.displayGroup:insert(overlay)
        overlay:setFillColor(195, 214, 93, 100)

        local star = display.newImageRect("images/winner.png", 580, 580)
        local star2 = display.newImageRect("images/winner2.png", 580, 580)
        self.displayGroup:insert(star)
        self.displayGroup:insert(star2)
        star:setReferencePoint(display.CenterReferencePoint)
        star2:setReferencePoint(display.CenterReferencePoint)
        star.x, star.y = display.contentWidth / 2, display.contentHeight / 2
        star2.x, star2.y = display.contentWidth / 2, display.contentHeight / 2

        self.startTimer = timer.performWithDelay(30, function()
            star.rotation = (star.rotation - 1) % 360
            star2.rotation = (star2.rotation + 1) % 360
        end, -1)

        customUI.text2("LEVEL CLEAR!", display.contentWidth / 2, display.contentHeight / 2, 32, self.displayGroup)

        local selectBtn = widget.newButton{
            id = "selectbtn",
            label = "Level select",
            font = "TrebuchetMS-Bold",
            fontSize = 24,
            width = 150, height = 40,
            defaultFile = "images/button.png",
            overFile = "images/button.png",
            labelColor = { default = { 255 }, over = { 0 } },
            onRelease = function(event)
                self.game:goto("MAINMENU")
                self.game:goto("PLAYMENU")
                self.game:goto("LEVELSELECT")
                return true
            end
        }
        self.displayGroup:insert(selectBtn)
        selectBtn.x, selectBtn.y = 160, 280

        local nextBtn = widget.newButton{
            id = "nextbtn",
            label = "Next level",
            font = "TrebuchetMS-Bold",
            fontSize = 24,
            width = 150, height = 40,
            defaultFile = "images/button.png",
            overFile = "images/button.png",
            labelColor = { default = { 255 }, over = { 0 } },
            onRelease = function(event)
                if self.game.selectedLevel == 6 then
                    self.game:goto("MAINMENU")
                    self.game:goto("OPTIONS")
                    self.game:goto("CREDITS")
                else
                    self.game.selectedLevel = self.game.selectedLevel + 1
                    self.game:goto("LEVEL_INTRO")
                end
                return true
            end
        }
        self.displayGroup:insert(nextBtn)
        nextBtn.x, nextBtn.y = 320, 280

    else
        self.displayGroup = display.newGroup()
        local width = display.contentWidth + 2 * display.screenOriginX
        local height = display.contentHeight + 2 * display.screenOriginY
        
        local overlay = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth - 2 * display.screenOriginX, display.contentHeight - 2 * display.screenOriginY)
        self.displayGroup:insert(overlay)
        overlay:setFillColor(227, 100, 146, 150)

        customUI.text("You lose!", display.contentWidth / 2, display.contentHeight / 2, 32, self.displayGroup)

        local selectBtn = widget.newButton{
            id = "selectbtn",
            label = "Level select",
            font = "TrebuchetMS-Bold",
            fontSize = 24,
            width = 150, height = 40,
            defaultFile = "images/button.png",
            overFile = "images/button.png",
            labelColor = { default = { 255 }, over = { 0 } },
            onRelease = function(event)
                self.game:goto("MAINMENU")
                self.game:goto("PLAYMENU")
                self.game:goto("LEVELSELECT")
                return true
            end
        }
        self.displayGroup:insert(selectBtn)
        selectBtn.x, selectBtn.y = 160, 280

        local tryBtn = widget.newButton{
            id = "trybtn",
            label = "Try again",
            font = "TrebuchetMS-Bold",
            fontSize = 24,
            width = 150, height = 40,
            defaultFile = "images/button.png",
            overFile = "images/button.png",
            labelColor = { default = { 255 }, over = { 0 } },
            onRelease = function(event)
                self.game:goto("LEVEL_INTRO")
                return true
            end
        }
        self.displayGroup:insert(tryBtn)
        tryBtn.x, tryBtn.y = 320, 280     
    end
end

function GameOverScreen:dismiss()
    if self.startTimer ~= nil then
        timer.cancel(self.startTimer)
        self.startTimer = nil
    end
    self.displayGroup:removeSelf()
end
