module(..., package.seeall)

imageHelper = require("scripts.util.Image")

Background = { clouds = true }

-- Constructor
function Background:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function Background:render(group, game)
    local background = display.newImageRect("images/levels/" .. game.level_map.levelName .. "/background.png", game.level_map.levelWidth * game.pixel, game.level_map.levelHeight * game.pixel)
    background:setReferencePoint(display.TopLeftReferencePoint)
    background.x = 0
    background.y = 0
    group:insert(background)


--[[
    local pixels = imageHelper.renderImage(0, 0, game.level_map.background, game.pixel)
    for i,v in ipairs(pixels) do
        group:insert(v)
    end
]]
    print("Rendered background")
end
