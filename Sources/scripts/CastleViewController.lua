module(..., package.seeall)

imageHelper = require("scripts.util.image")

CastleViewController = {}

-- Constructor
function CastleViewController:new (o)
	o = o or {}   -- create object if user does not provide one
	o.bricks = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function CastleViewController:render(physics, world, game, x, y)
    local worldHeight = game.worldHeight / game.pixel

    local castles = imageHelper.loadImageData("data/castles.json") --todo move to static initialization
    local castle
    for i=1, table.getn(castles), 1 do --todo modify json to get castle by name?
        if (castles[i].name == self.castleName) then
            castle = castles[i]
        end
    end

    local pixels = imageHelper.renderImage(x, worldHeight - y - castle.height + 1, castle, game)  --todo: explain magic numbers
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

function CastleViewController:cannonX(game)
	--todo move into the castel model
	--todo implement
end

function CastleViewController:cannonY(game)
	--todo move into the castel model
	--todo implement	
end