module(..., package.seeall)

imageHelper = require("scripts.util.Image")

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
    local worldHeight = game.worldHeight / game.pixel

    local castles = imageHelper.loadImageData("data/castles.json") --todo move to static initialization
    local castle = castles[self.castleName]

    self.leftX = x * game.pixel
    self.rightX = (x + castle.width) * game.pixel
    local topYPixels = worldHeight - y - castle.height + 1
    self.topY = topYPixels * game.pixel

    local pixels = imageHelper.renderImage(x, topYPixels, castle, game)  --todo: explain magic numbers
    for i,v in ipairs(pixels) do
        self.bricks[i] = v
        world:insert(v)
        v.myName = "brick"
        physics.addBody(v, "static")
    end
    print("Rendered castle with " .. x .. ", " .. y)
end

function CastleViewController:isDestroyed(game)
	if (self:health() < game.minCastleHealth) then
		return true
	else
		return false
	end
end

function CastleViewController:health()
	local score = 0
	for i, v in ipairs(self.bricks) do
		if (v ~= nil) then
			if (v.state == "removed") then
				print("found removed")
				table.remove(self.bricks, i)
			else
				score = score + 1
			end
		end
	end
	return score
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