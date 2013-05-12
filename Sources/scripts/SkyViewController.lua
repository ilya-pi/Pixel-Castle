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
function SkyViewController:render(group, game)
    local sky = display.newImageRect("images/levels/" .. game.level_map.levelName .. "/sky.png", game.level_map.levelWidth * game.pixel, game.level_map.levelHeight * game.pixel)
    sky:setReferencePoint(display.TopLeftReferencePoint)
    sky.x = 0
    sky.y = 0
    group:insert(sky)

--[[
    local sky = display.newRect(display.screenOriginX, display.screenOriginY, game.level_map.levelWidth * game.pixel, game.level_map.levelHeight * game.pixel)
    sky:setFillColor(207, 229, 130)
    sky:setStrokeColor(207, 229, 130)
    group:insert(sky)
    local pixels = imageHelper.renderImage(0, 0, game.level_map.sky, game.pixel)
    for i,v in ipairs(pixels) do
        group:insert(v)
    end
]]
end
