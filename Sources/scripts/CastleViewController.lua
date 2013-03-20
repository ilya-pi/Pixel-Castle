module(..., package.seeall)

castle = require("data.castle")
imageHelper = require("scripts.util.image")

CastleViewController = {}

bricks = {}

-- Constructor
function CastleViewController:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function CastleViewController:render(physics, world, game, x, y)
    local worldHeight = game.worldHeight / game.pixel
    local castleImage = castle.castles[self.type]

    local pixels = imageHelper.renderImage(x, worldHeight - y - castleImage.height + 1, castleImage, game)  --todo: explain magic numbers
    for i,v in ipairs(pixels) do
        bricks[i] = v
        world:insert(v)
        v.myName = "brick"
        physics.addBody(v, "static")
    end
	print("Rendered castle with " .. x .. ", " .. y)	
end

function CastleViewController:cannonX(game)
	--todo move into the castel model
	--todo implement
end

function CastleViewController:cannonY(game)
	--todo move into the castel model
	--todo implement	
end