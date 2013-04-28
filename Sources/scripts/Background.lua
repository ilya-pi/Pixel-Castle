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

function Background:render(world, game)
    local pixels = imageHelper.renderImage(0, 0, game.level_map.background, game.pixel)
    for i,v in ipairs(pixels) do
        world:insert(v)
    end
    print("Rendered background")
end
