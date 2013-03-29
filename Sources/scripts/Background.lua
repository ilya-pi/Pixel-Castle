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
    local assets = imageHelper.loadImageData("data/other.json") --todo move to static initialization
    local pixels = imageHelper.renderImage(0, 30, assets.bg_pyramids, game.pixel)
    for i,v in ipairs(pixels) do
        world:insert(v)
    end
    local pixels = imageHelper.renderImage(50, 30, assets.bg_pyramids, game.pixel)
    for i,v in ipairs(pixels) do
        world:insert(v)
    end

    print("Rendered background ")
end
