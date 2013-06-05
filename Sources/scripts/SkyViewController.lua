module(..., package.seeall)

local imageHelper = require("scripts.util.Image")

SkyViewController = { clouds = true }

-- Constructor
function SkyViewController:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

-- physics — physics object to attach to
-- world - display group for the whole scene
function SkyViewController:render(group)
	imageHelper.ourImage("images/levels/" .. game.level_map.levelName .. "/sky.png", 
		game.level_map.levelWidth * game.pixel, 
		game.level_map.levelHeight * game.pixel,
		group)
end
