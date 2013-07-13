module(..., package.seeall);

local widget = require("widget")

local customUI = require("scripts.util.CustomUI")

TurnOverlay = {}

-- Constructor
function TurnOverlay:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function TurnOverlay:render()
    self.group = display.newGroup()

    local displayWidth = display.contentWidth - 2 * display.screenOriginX
    local displayHeight = display.contentHeight - 2 * display.screenOriginY

    self.alphaRect = display.newRect(0, 0, displayWidth, displayHeight)
    self.alphaRect:addEventListener("touch", function()
    		return true
    	end)
    self.alphaRect:setReferencePoint(display.CenterReferencePoint)
    if game.state.name == "P2" or  game.state.name == "TURN_P2" or game.state.name == "MOVE_TO_P2" then
    	self.alphaRect:setFillColor(212, 20, 90, 160)
    else
    	self.alphaRect:setFillColor(16, 105, 255, 160)
    end
    self.alphaRect.x, self.alphaRect.y = display.contentWidth / 2, display.contentHeight / 2
    self.group:insert(self.alphaRect)    

    local txt
    if game.mode == "versus" then
	    if game.state.name == "P2" or game.state.name == "TURN_P2" or game.state.name == "MOVE_TO_P2" then
	    	txt  = "Player 2!"
	    else
	    	txt  = "Player 1!"
	    end
    elseif game.mode == "campaign" then
    	print(game.state.name)
	    if game.state.name == "P2" or  game.state.name == "TURN_P2" or game.state.name == "MOVE_TO_P2" then
	    	txt  = "Opponent's turn!"
	    else
	    	txt  = "Your turn!"
	    end
    end

    self.text = customUI.danceText(txt, display.contentWidth / 2, display.contentHeight / 2 - 50, 28, self.group)
end

function TurnOverlay:dismiss()
	self.alphaRect:removeSelf()
	transition.to(self.text, {x = display.screenOriginX - display.contentWidth, time = 200, onComplete = function()
			self.group:removeSelf()		
		    self.group = nil
		end})	
end