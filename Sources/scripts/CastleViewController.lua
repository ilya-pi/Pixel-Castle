module(..., package.seeall)

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

	for i=0,game.castleWidth do
		for l=0,game.castleHeight do
			local current = i * 10 + l;
			bricks[current] = display.newRect(x * game.pixel  + i * game.pixel, game.worldHeight - y * game.pixel - l * game.pixel, game.pixel , game.pixel)
			world:insert(bricks[current])
			bricks[current].myName = "brick"
			bricks[current].strokeWidth = 0
			bricks[current]:setFillColor(26, 55, 37)
			bricks[current]:setStrokeColor(26, 55, 37)

			physics.addBody(bricks[current], "static")
		end
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