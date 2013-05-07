module(..., package.seeall)

-- local dataDumper = require("scripts.ext.DataDumper")

GameModel = {
    delay = 100,
	pixel = 10,
	cameraGoBackDelay = 2500, -- delay between stop gragging the world map and a camera to go back to it's initial place
	castleWidth = 10, -- in Pixel  todo castle width should be dynamic
	castleHeight = 10, -- in Pixel todo castle height should be dynamic
	groundYOffset = 3,
	cannonYOffset = 5, -- in Pixel
	cameraState = "CASTLE1_FOCUS", -- "CASTLE2_FOCUS", "CANNONBALL_FOCUS", "FOCUSING"
	minCastleHealthPercet = 75,
    state = "PLAYER1", -- "PLAYER2", "PLAYER1_LOST", "PLAYER2_LOST"
    stateNumber = 1,
    states = {}
}

-- Constructor
function GameModel:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- state looks like {name = "STATE_NAME", transitions = {SECOND_STATE_NAME = transitionMethod, THIRD_STATE_NAME = thirdTransitionMethod}}
function GameModel:addState(state)
    self.states[state.name] = state
end

function GameModel:setState(stateName)        
    self.state = self.states[stateName]
end

function GameModel:goto(gotoState)
    print(self.state.name .. ' -> ' .. gotoState)
    self.state.transitions[gotoState]()
    self.state = self.states[gotoState]
end



-- physics — physics object to attach to
-- world - display group for the whole scene
-- function GameModel:render(physics, world)	
-- 	local test = display.newRect(200, 200, 27, 27);
-- 	test:setFillColor(26, 55, 37)
-- 	test:setStrokeColor(26, 55, 37)
-- 	test.myName = "brick"
-- 	world:insert(test)
-- 	physics.addBody(test, "static")

-- 	print("Rendered earth with " .. tostring(self.width) .. ", " .. tostring(self.height))
-- 	-- print("test")
-- end