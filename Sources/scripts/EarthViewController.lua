module(..., package.seeall)

EarthViewController = {}

local Memmory = require("scripts.util.Memmory")

local castle_module = require("scripts.CastleViewController")
local imageHelper = require("scripts.util.Image")

-- Constructor
function EarthViewController:new (o)
	o = o or {castleCount = 1}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function EarthViewController:render(physics)
    imageHelper.ourImage("images/levels/" .. game.level_map.levelName .. "/level.png", 
        game.level_map.levelWidth * game.pixel, 
        game.level_map.levelHeight * game.pixel,
        game.world)

    game.castle1 = castle_module.CastleViewController:new{castleName = "castle1", location = "left"}
    game.castle1:render(physics, game.world, game, game.level_map.castle1.x, game.level_map.castle1.y)

    game.castle2 = castle_module.CastleViewController:new{castleName = "castle2", location = "right"}
    game.castle2:render(physics, game.world, game, game.level_map.castle2.x, game.level_map.castle2.y)
end
