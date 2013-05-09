module(..., package.seeall)

imageHelper = require("scripts.util.Image")
local customUI = require("scripts.util.CustomUI")

CastleViewController = {}

-- Constructor
function CastleViewController:new (o) --todo save (physics, world, game, x, y) at this point since tower is static
	o = o or {}   -- create object if user does not provide one
	o.bricks = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function CastleViewController:render(physics, world, game, x, y) --todo remove redundant params
    local worldHeight = game.level_map.level.height * game.pixel / game.pixel

    local castles = imageHelper.loadImageData("data/castles.json") --todo move to static initialization
    local castle = castles[self.castleName]

    self.leftX = x * game.pixel
    self.rightX = (x + castle.width) * game.pixel
    local topYPixels = worldHeight - y - castle.height + 1
    self.topY = topYPixels * game.pixel

    local pixels = imageHelper.renderImage(x, topYPixels, castle, game.pixel)  --todo: explain magic numbers
    for i,v in ipairs(pixels) do
        self.bricks[i] = v
        world:insert(v)
        v.myName = "brick"
        physics.addBody(v, "static")
    end
    self.totalHealth = self:health()
    self.width = castle.width * game.pixel

    self.healthBar = display.newRect(self.leftX, self.topY - 15, self.width, 3)
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

function CastleViewController:health()
	-- to let the castles die right away, return 5 health points
	-- return 5
	local score = 0
	for i, v in ipairs(self.bricks) do
		if (v ~= nil) then
			if (v.state == "removed") then
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
	    return self.rightX
    else
        return self.leftX
    end
end

function CastleViewController:cannonY()
    return self.topY
end