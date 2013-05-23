module(..., package.seeall)

local Memmory = require("scripts.util.Memmory")
local imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")
local eventTrack = require("scripts.util.EventTrack")

CastleViewController = {}

-- Constructor
function CastleViewController:new (o) --todo save (physics, world, game, x, y) at this point since tower is static
	o = o or {}   -- create object if user does not provide one
	o.bricks = {}
	o.events = eventTrack.EventTrack:new()
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function CastleViewController:render(physics, world, game, x, y) --todo remove redundant params
    local worldHeight = game.level_map.levelHeight

    local castle = game.level_map[self.castleName]

    -- todo write together!!!
    -- local castleImg = display.newImageRect("images/levels/" .. game.level_map.levelName .. "/" .. self.castleName .. ".png", castle.width * game.pixel, castle.height * game.pixel)
    -- castleImg:setReferencePoint(display.LeftTopReferencePoint)
    -- castleImg.x, castleImg.y = (x + castle.width / 2 - 1) * game.pixel, (y - castle.height / 2 + 1) * game.pixel
    -- world:insert(castleImg)    
    --

    self.leftX = x * game.pixel
    self.rightX = (x + castle.width) * game.pixel
    self.topY = (y - castle.height + 1) * game.pixel

    local pixels = imageHelper.renderImage(0, 0, castle, game.pixel)  --todo: explain magic numbers
    local castleGroup = display.newGroup()
    for i,v in ipairs(pixels) do
        self.bricks[i] = v
        castleGroup:insert(v)
        v.myName = "brick"
        Memmory.trackPhys(v); physics.addBody(v, "static")
    end
    castleGroup:setReferencePoint(display.BottomLeftReferencePoint)
    world:insert(castleGroup)
    castleGroup.x = x * game.pixel
    castleGroup.y =  (y + 1) * game.pixel

--[[
    local testRect = display.newRect(0, 0, 1, 1)
    testRect:setFillColor(255, 0, 0)
    testRect:setReferencePoint(display.CenterReferencePoint)
    world:insert(testRect)
    testRect.x = self.leftX
    testRect.y = self.topY

    local testRect2 = display.newRect(0, 0, 1, 1)
    testRect2:setFillColor(255, 0, 0)
    testRect2:setReferencePoint(display.CenterReferencePoint)
    world:insert(testRect2)
    testRect2.x = self.rightX
    testRect2.y = self.topY
]]


    self.totalHealth = self:health()
    self.width = castle.width * game.pixel

    self.healthBar = display.newRect(0, 0, self.width, 3)
    self.healthBar:setReferencePoint(display.BottomLeftReferencePoint)
    self.healthBar.x = self.leftX
    self.healthBar.y = self.topY - 15
    world:insert(self.healthBar)
   	self.healthBar:setFillColor(0, 255, 0, 150)

    print("Rendered castle with " .. x .. ", " .. y)
end

function CastleViewController:isDestroyed(game)
	if (self:healthPercent() < game.minCastleHealthPercet) then
		return true
	else
		return false
	end
end

function CastleViewController:updateHealth(game)
	local curr = self:healthPercent()

	local healthEstimation = (curr - game.minCastleHealthPercet ) / (100 - game.minCastleHealthPercet) * 30	
	if healthEstimation > 20 then
		self.healthBar:setFillColor(0, 255, 0, 150)
	elseif healthEstimation > 10 then
		self.healthBar:setFillColor(255, 255, 0, 150)
	else
		self.healthBar:setFillColor(255, 0, 0, 150)
	end

	if curr <= game.minCastleHealthPercet then
		self.healthBar.width = 1
	else		
		self.healthBar.width = self.width * (curr - game.minCastleHealthPercet ) / (100 - game.minCastleHealthPercet)
	end
end

function CastleViewController:showBubble(game, message)
	local bubbleGroup = display.newGroup()
	local bubble
	if (self.location == "left") then
		bubble = display.newImageRect("images/speech_left.png", 80, 60)
	else
		bubble = display.newImageRect("images/speech_right.png", 80, 60)
	end
	bubbleGroup:insert(bubble)

	local text = display.newText(message, -100, -100, "TrebuchetMS-Bold", 14)
    text:setReferencePoint(display.CenterReferencePoint)
    text:setTextColor(0, 0, 0)
    text.x, text.y = 0, -7
    bubbleGroup:insert(text)

	game.world:insert(bubbleGroup)
	bubbleGroup.x, bubbleGroup.y = self:cannonX(), self:cannonY()
	table.insert(Memmory.transitionStash, transition.to(bubbleGroup, {time = 3500, alpha = 0, y = self:cannonY() - 100}, function() bubbleGroup:removeSelf() end))
end

function CastleViewController:health()
	-- to let the castles die right away, return 5 health points
	-- return 5
	local score = 0
	for i, v in ipairs(self.bricks) do
		if (v ~= nil) then
			if (v.state == "removed") then
				self.events:keep({action = "hit"})
				table.remove(self.bricks, i)
			else
				score = score + 1
			end
		end
	end
	return score
end

function CastleViewController:healthPercent()
	return math.round(100 * self:health() / self.totalHealth)
end	

function CastleViewController:cannonX()
    if (self.location == "left") then
	    return self.rightX + 1
    else
        return self.leftX - 1
    end
end

function CastleViewController:cannonY()
    return self.topY - 1
end